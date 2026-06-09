// client-api.js – Cliente Real que se conecta a la API FastAPI
// Mantiene la misma interfaz de callbacks que client.js pero con llamadas HTTP reales

window.API_BASE = "";

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
        failed: 0
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
    async _safeFetch(url, options = {}) {
        try {
            const resp = await fetch(url, options);
            const contentType = resp.headers.get("content-type");
            let data = null;

            if (contentType && contentType.includes("application/json")) {
                data = await resp.json();
            } else {
                const text = await resp.text();
                if (!resp.ok) {
                    throw new Error(text || `Error del servidor (${resp.status})`);
                }
                return { ok: true, status: resp.status, data: text };
            }

            return { ok: resp.ok, status: resp.status, data };
        } catch (err) {
            throw err;
        }
    },

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
        this._log("system", "Conectando a API en " + window.API_BASE + "...");
        try {
            // 1. Verificar health de nodos
            const result = await this._safeFetch(`${window.API_BASE}/health`);
            if (!result.ok) throw new Error("Health check falló");
            const health = result.data;
            
            Object.keys(this.nodes).forEach(key => {
                const status = health[key]; // "ok" o "down"
                this.nodes[key].status = status === "ok" ? "online" : "offline";
            });

            this._log("success", "✓ Conexión a nodos verificada");

            // 2. Cargar inventario/cuentas actuales
            await this.loadAccountsFromAPI();
            
            // 3. Cargar logs y stats
            await this.loadLogFromAPI();
            
            this._triggerStateChange();
            this._triggerPhaseChange("Listo: En línea", "phase-badge");
        } catch (err) {
            this._log("error", "Error inicializando: " + err.message);
        }
    },

    async loadAccountsFromAPI() {
        try {
            const result = await this._safeFetch(`${window.API_BASE}/cuentas`);
            if (!result.ok) throw new Error("GET /cuentas falló");
            const data = result.data;

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
            const result = await this._safeFetch(`${window.API_BASE}/log`);
            if (!result.ok) throw new Error("GET /log falló");
            const data = result.data;

            this.coordinatorWAL = data.entries.map(entry => ({
                txId: entry.txn_id || entry.txId,
                state: entry.fase,
                node: entry.ciudad || entry.nodo,
                message: entry.detalle,
                timestamp: new Date(entry.timestamp * 1000).toISOString()
            }));

            // Calcular estadísticas sin duplicar transacciones fallidas
            const seenTxIds = new Set();
            this.stats.success = 0;
            this.stats.failed = 0;
            
            // Recorremos de más reciente a más antiguo para tomar el último estado de cada TX
            const reversedEntries = [...data.entries].reverse();
            for (const e of reversedEntries) {
                const txId = e.txn_id || e.txId;
                if (!txId || seenTxIds.has(txId)) continue;
                
                // Solo nos interesan estados finales globales (sin ciudad/nodo)
                if ((e.fase === "COMMITTED" || e.fase === "ROLLED_BACK" || e.fase === "FAILED") && !e.ciudad && !e.nodo) {
                    seenTxIds.add(txId);
                    if (e.fase === "COMMITTED") {
                        this.stats.success++;
                    } else {
                        this.stats.failed++;
                    }
                }
            }
            this.stats.inDoubt = data.entries.some(e => e.fase === "FAILED");

            this._triggerWALUpdate();
            this._triggerStatsUpdate();
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
                    const result = await this._safeFetch(`${window.API_BASE}/sucursales/${nodeKey}/iniciar`, { method: "POST" });
                    if (result.ok) {
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
            this.stats.success = 0;
            this.stats.failed = 0;
            this.stats.inDoubt = false;

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
            const result = await this._safeFetch(`${window.API_BASE}/sucursales/${nodeKey}/${endpoint}`, { method: "POST" });
            
            if (result.ok) {
                this.nodes[nodeKey].status = status;
                this._log("success", `✓ Nodo ${nodeKey} ahora está ${status}`);
                await this.loadAccountsFromAPI();
            } else {
                throw new Error(result.data?.detail || "Error cambiando estado");
            }
        } catch (err) {
            this._log("error", "Error: " + err.message);
        }
    },

    // ------------------------------------------
    // TRANSFERENCIA 2PC REAL
    // ------------------------------------------
    async startTransaction(sourceNode, sourceAcc, destNode, destAcc, amount, delay) {
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
            stepDelay: delay || 0,
            phase: "PREPARE"
        };

        this._log("system", `Iniciando transacción ${this.activeTx.txId}`);
        this._appendWAL(this.activeTx.txId, "START", null, 
            `Transferencia S/ ${amount} de ${sourceNode} (${sourceAcc}) a ${destNode} (${destAcc})`);

        return await this.executeFullTransaction();
    },

    // Ejecutar transacción completa
    async executeFullTransaction() {
        const cleanup = async () => {
            await this.loadAccountsFromAPI();
            await this.loadLogFromAPI();
            this._triggerStateChange();
            this._triggerPhaseChange("Estado: Inactivo", "phase-badge");
            if (this.uiCallbacks.onTxEnd) this.uiCallbacks.onTxEnd();
        };

        try {
            const payload = {
                cuenta_origen: this.activeTx.sourceAcc,
                cuenta_destino: this.activeTx.destAcc,
                ciudad_origen: this.activeTx.sourceNode,
                ciudad_destino: this.activeTx.destNode,
                monto: this.activeTx.amount,
                delay: this.activeTx.stepDelay
            };

            this._log("system", "Enviando transferencia a coordinador...");
            this._animate(this.activeTx.sourceNode, "coordinator", "PREPARE", async () => {
                try {
                    const result = await this._safeFetch(`${window.API_BASE}/transferir`, {
                        method: "POST",
                        headers: { "Content-Type": "application/json" },
                        body: JSON.stringify(payload)
                    });

                    if (!result.ok) {
                        const errorMsg = result.data?.detail || result.data || "Error desconocido";
                        this._log("error", "Error en transferencia: " + errorMsg);
                        this._appendWAL(this.activeTx.txId, "FAILED", null, errorMsg);
                        await cleanup();
                        return false;
                    }

                    const data = result.data;
                    this._appendWAL(this.activeTx.txId, data.status, null, `Resultado: ${data.status}`);

                    // Registrar cada paso del log de la API
                    if (data.log && Array.isArray(data.log)) {
                        data.log.forEach(entry => {
                            this._appendWAL(entry.txn_id, entry.fase, entry.ciudad || entry.nodo, entry.detalle);
                        });
                    }

                    if (data.status === "COMMITTED") {
                        this._log("success", `✓ Transacción ${data.status}`);
                    } else {
                        this._log("warning", `⚠ Transacción ${data.status}`);
                    }

                    await cleanup();
                    return true;
                } catch (err) {
                    this._log("error", "Error de red: " + err.message);
                    this._appendWAL(this.activeTx.txId, "FAILED", null, err.message);
                    await cleanup();
                    return false;
                }
            });

        } catch (err) {
            this._log("error", "Error ejecutando transferencia: " + err.message);
            await cleanup();
            return false;
        }
    },

    // ------------------------------------------
    // GESTIÓN DE CUENTAS
    // ------------------------------------------
    async createAccount(nodeKey, accId, owner, balance) {
        try {
            const payload = {
                ciudad: nodeKey,
                numero_cuenta: accId,
                titular: owner,
                saldo: balance
            };
            const result = await this._safeFetch(`${window.API_BASE}/cuentas`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
            });

            if (result.ok) {
                this._log("success", `Cuenta ${accId} (${owner}) creada exitosamente.`);
                await this.loadAccountsFromAPI();
                return { success: true };
            } else {
                return { success: false, msg: result.data?.detail || "Error creando cuenta" };
            }
        } catch (err) {
            return { success: false, msg: err.message };
        }
    },

    async updateAccount(nodeKey, accId, owner, balance) {
        try {
            const payload = {
                titular: owner,
                saldo: balance
            };
            const result = await this._safeFetch(`${window.API_BASE}/cuentas/${nodeKey}/${accId}`, {
                method: "PUT",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
            });

            if (result.ok) {
                this._log("success", `Cuenta ${accId} actualizada exitosamente.`);
                await this.loadAccountsFromAPI();
                return { success: true };
            } else {
                return { success: false, msg: result.data?.detail || "Error actualizando cuenta" };
            }
        } catch (err) {
            return { success: false, msg: err.message };
        }
    },

    async deleteAccount(nodeKey, accId) {
        try {
            const result = await this._safeFetch(`${window.API_BASE}/cuentas/${nodeKey}/${accId}`, {
                method: "DELETE"
            });

            if (result.ok) {
                this._log("success", `Cuenta ${accId} eliminada exitosamente.`);
                await this.loadAccountsFromAPI();
                return { success: true };
            } else {
                return { success: false, msg: result.data?.detail || "Error eliminando cuenta" };
            }
        } catch (err) {
            return { success: false, msg: err.message };
        }
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
