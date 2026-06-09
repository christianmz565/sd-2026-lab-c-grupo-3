// client-api.js – Cliente Real que se conecta a la API FastAPI
// Mantiene la misma interfaz de callbacks que client.js pero con llamadas HTTP reales

const API_BASE = "http://localhost:8000";

window.BNC_ClientAPI = {
    // ------------------------------------------
    // ESTADO
    // ------------------------------------------
    nodes: {
        arequipa: { name: "Arequipa", code: "AQ", status: "online" },
        cusco: { name: "Cusco", code: "CU", status: "online" },
        trujillo: { name: "Trujillo", code: "TR", status: "online" }
    },
    
    dbState: {}, // { nodeName: { accountId: { owner, saldo }, ... } }
    coordinatorWAL: [],
    
    stats: {
        success: 0,
        total: 0
    },
    
    activeTx: null,
    stepExecutor: null,

    // Callbacks para notificar a la interfaz (igual que client.js)
    uiCallbacks: {
        onLog: null,
        onStateChange: null,
        onAnimate: null,
        onPhaseChange: null,
        onWALUpdate: null,
        onStatsUpdate: null,
        onTxEnd: null,
        onRestoreLine: null
    },

    registerCallbacks(callbacks) {
        this.uiCallbacks = { ...this.uiCallbacks, ...callbacks };
    },

    // ------------------------------------------
    // MÉTODOS DE APOYO
    // ------------------------------------------
    _log(type, msg) {
        if (this.uiCallbacks.onLog) this.uiCallbacks.onLog(type, msg);
    },

    _triggerStateChange() {
        if (this.uiCallbacks.onStateChange) this.uiCallbacks.onStateChange();
    },

    _triggerWALUpdate() {
        if (this.uiCallbacks.onWALUpdate) this.uiCallbacks.onWALUpdate();
    },

    _triggerStatsUpdate() {
        if (this.uiCallbacks.onStatsUpdate) this.uiCallbacks.onStatsUpdate();
    },

    _triggerPhaseChange(phase, className) {
        if (this.uiCallbacks.onPhaseChange) this.uiCallbacks.onPhaseChange(phase, className);
    },

    _animate(from, to, type, callback) {
        if (this.uiCallbacks.onAnimate) {
            this.uiCallbacks.onAnimate(from, to, type, () => {
                const delay = this.activeTx?.stepDelay || 500;
                setTimeout(() => {
                    if (this.uiCallbacks.onRestoreLine) {
                        this.uiCallbacks.onRestoreLine(to === "coordinator" ? from : to);
                    }
                    if (callback) callback();
                }, delay);
            });
        } else if (callback) {
            callback();
        }
    },

    _appendWAL(txId, state, node, message) {
        this.coordinatorWAL.push({
            txId,
            state,
            node,
            message,
            timestamp: new Date().toISOString()
        });
        this._triggerWALUpdate();
        this._triggerStatsUpdate();
    },

    // ------------------------------------------
    // INICIALIZACIÓN: Traer datos reales de la API
    // ------------------------------------------
    async init() {
        this._log("system", "Conectando a API en " + API_BASE + "...");
        try {
            // 1. Verificar health de nodos
            const healthResp = await fetch(`${API_BASE}/health`);
            if (!healthResp.ok) throw new Error("Health check falló");
            const health = await healthResp.json();
            
            Object.keys(this.nodes).forEach(key => {
                const status = health[key]; // "ok" o "down"
                this.nodes[key].status = status === "ok" ? "online" : "offline";
            });

            this._log("success", "✓ Conexión a nodos verificada");

            // 2. Cargar inventario/cuentas actuales
            await this.loadAccountsFromAPI();
            
            this._triggerStateChange();
            this._triggerPhaseChange("Listo: En línea", "phase-badge");
        } catch (err) {
            this._log("error", "Error inicializando: " + err.message);
        }
    },

    async loadAccountsFromAPI() {
        try {
            const resp = await fetch(`${API_BASE}/cuentas`);
            if (!resp.ok) throw new Error("GET /cuentas falló");
            const data = await resp.json();

            // Reorganizar respuesta en estructura local
            this.dbState = {};
            Object.keys(this.nodes).forEach(key => {
                this.dbState[key] = {};
            });

            data.cuentas.forEach(row => {
                const ciudad = row.ciudad;
                const accId = row.numero_cuenta;
                if (!this.dbState[ciudad]) this.dbState[ciudad] = {};
                this.dbState[ciudad][accId] = {
                    owner: row.titular,
                    balance: row.saldo,
                    locked: false
                };
            });

            this._triggerStateChange();
        } catch (err) {
            this._log("error", "Error cargando cuentas: " + err.message);
        }
    },

    async loadLogFromAPI() {
        try {
            const resp = await fetch(`${API_BASE}/log`);
            if (!resp.ok) throw new Error("GET /log falló");
            const data = await resp.json();

            this.coordinatorWAL = data.entries.map(entry => ({
                txId: entry.txn_id || entry.txId,
                state: entry.fase,
                node: entry.ciudad || entry.nodo,
                message: entry.detalle,
                timestamp: new Date(entry.timestamp * 1000).toISOString()
            }));

            this._triggerWALUpdate();
        } catch (err) {
            this._log("error", "Error cargando log: " + err.message);
        }
    },

    // ------------------------------------------
    // RESETEAR SISTEMA (reiniciar nodos)
    // ------------------------------------------
    async resetSystem() {
        this._log("system", "Reiniciando sistema...");
        try {
            // Reiniciar todos los nodos
            for (const nodeKey of Object.keys(this.nodes)) {
                try {
                    const resp = await fetch(`${API_BASE}/sucursales/${nodeKey}/iniciar`, { method: "POST" });
                    if (resp.ok) {
                        this.nodes[nodeKey].status = "online";
                        this._log("success", `✓ Nodo ${nodeKey} reiniciado`);
                    }
                } catch (err) {
                    this._log("warning", `No se pudo reiniciar ${nodeKey}: ${err.message}`);
                }
            }

            this.coordinatorWAL = [];
            this.activeTx = null;
            this.stepExecutor = null;

            await this.loadAccountsFromAPI();
            this._triggerWALUpdate();
            this._triggerStatsUpdate();
            this._triggerPhaseChange("Estado: Inactivo", "phase-badge");
            this._log("success", "Sistema restablecido");
        } catch (err) {
            this._log("error", "Error reiniciando sistema: " + err.message);
        }
    },

    // ------------------------------------------
    // CONTROL DE NODOS
    // ------------------------------------------
    async setNodeStatus(nodeKey, status) {
        this._log("system", `Cambiando estado de [${nodeKey}] a [${status}]...`);
        try {
            const endpoint = status === "online" ? "iniciar" : "detener";
            const resp = await fetch(`${API_BASE}/sucursales/${nodeKey}/${endpoint}`, { method: "POST" });
            
            if (resp.ok) {
                this.nodes[nodeKey].status = status;
                this._log("success", `✓ Nodo ${nodeKey} ahora está ${status}`);
                await this.loadAccountsFromAPI();
            } else {
                const errData = await resp.json();
                throw new Error(errData.detail || "Error cambiando estado");
            }
        } catch (err) {
            this._log("error", "Error: " + err.message);
        }
    },

    // ------------------------------------------
    // TRANSFERENCIA 2PC REAL
    // ------------------------------------------
    async startTransaction(sourceNode, sourceAcc, destNode, destAcc, amount, isStepByStep, stepDelay) {
        if (sourceNode === destNode) {
            this._log("error", "Las sucursales origen y destino deben ser distintas");
            return false;
        }

        this.activeTx = {
            txId: "tx_" + Math.random().toString(36).substr(2, 9),
            sourceNode,
            sourceAcc,
            destNode,
            destAcc,
            amount,
            isStepByStep,
            stepDelay: stepDelay || 500,
            phase: "PREPARE",
            prepareResults: { source: null, dest: null },
            commitResults: { source: null, dest: null }
        };

        this._log("system", `Iniciando transacción ${this.activeTx.txId}`);
        this._appendWAL(this.activeTx.txId, "START", null, 
            `Transferencia S/ ${amount} de ${sourceNode} (${sourceAcc}) a ${destNode} (${destAcc})`);

        // Si NO es paso a paso, ejecutar todo de una vez
        if (!isStepByStep) {
            return await this.executeFullTransaction();
        }

        // Si es paso a paso, habilitar botón "Siguiente"
        this._triggerPhaseChange("Fase 1: PREPARE (esperando siguiente paso)", "phase-phase1");
        return true;
    },

    // Ejecutar transacción completa
    async executeFullTransaction() {
        try {
            const payload = {
                cuenta_origen: this.activeTx.sourceAcc,
                cuenta_destino: this.activeTx.destAcc,
                ciudad_origen: this.activeTx.sourceNode,
                ciudad_destino: this.activeTx.destNode,
                monto: this.activeTx.amount,
                delay: this.activeTx.stepDelay / 1000 // convertir a segundos
            };

            this._log("system", "Enviando transferencia a coordinador...");
            this._animate(this.activeTx.sourceNode, "coordinator", "PREPARE", async () => {
                const resp = await fetch(`${API_BASE}/transferir`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify(payload)
                });

                if (!resp.ok) {
                    const errData = await resp.json();
                    this._log("error", "Error en transferencia: " + errData.detail);
                    this._appendWAL(this.activeTx.txId, "FAILED", null, errData.detail);
                    await this.loadAccountsFromAPI();
                    await this.loadLogFromAPI();
                    return false;
                }

                const result = await resp.json();
                this._appendWAL(this.activeTx.txId, result.status, null, `Resultado: ${result.status}`);

                // Registrar cada paso del log de la API
                if (result.log && Array.isArray(result.log)) {
                    result.log.forEach(entry => {
                        this._appendWAL(entry.txn_id, entry.fase, entry.nodo, entry.detalle);
                    });
                }

                this.stats.total++;
                if (result.status === "COMMITTED") {
                    this.stats.success++;
                    this._log("success", `✓ Transacción ${result.status}`);
                } else {
                    this._log("warning", `⚠ Transacción ${result.status}`);
                }

                await this.loadAccountsFromAPI();
                this._triggerStateChange();
                this._triggerPhaseChange("Estado: Inactivo", "phase-badge");
                
                if (this.uiCallbacks.onTxEnd) this.uiCallbacks.onTxEnd();
                return true;
            });

        } catch (err) {
            this._log("error", "Error ejecutando transferencia: " + err.message);
            return false;
        }
    },

    // Ejecutar paso a paso (por ahora, ejecutar todo)
    async executeNextStep() {
        if (!this.activeTx) {
            this._log("warning", "No hay transacción activa");
            return;
        }

        await this.executeFullTransaction();
    },

    // ------------------------------------------
    // CARGAR ESCENARIOS (para debug/demo)
    // ------------------------------------------
    loadScenario(scenarioName) {
        const scenarios = {
            normal: {
                sourceNode: "arequipa",
                destNode: "cusco",
                amount: 25000
            },
            insufficient_funds: {
                sourceNode: "arequipa",
                destNode: "cusco",
                amount: 100000
            },
            node_crash: {
                sourceNode: "arequipa",
                destNode: "cusco",
                amount: 15000,
                crashNode: "cusco",
                crashPhase: "PREPARE"
            }
        };

        const scenario = scenarios[scenarioName];
        if (!scenario) {
            this._log("warning", "Escenario desconocido: " + scenarioName);
            return;
        }

        // Llenar formulario con valores del escenario
        document.getElementById("amount-input").value = scenario.amount;
        document.getElementById("source-select").value = scenario.sourceNode;
        document.getElementById("dest-select").value = scenario.destNode;

        // Disparar cambio de selectores para actualizar cuentas
        document.getElementById("source-select").dispatchEvent(new Event("change"));
        document.getElementById("dest-select").dispatchEvent(new Event("change"));

        this._log("system", `Escenario "${scenarioName}" cargado`);
    }
};

// Auto-inicializar cuando cargue el DOM
document.addEventListener("DOMContentLoaded", () => {
    // Esperar un poco para que app.js se cargue primero
    setTimeout(() => {
        if (window.BNC_ClientAPI && window.BNC_ClientAPI.init) {
            window.BNC_ClientAPI.init();
        }
    }, 100);
});
