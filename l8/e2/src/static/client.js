// BNC - Banco Cooperativo Nacional
// Simulación del Backend y Protocolo 2PC

const NODES_CONFIG = {
    arequipa: { name: "Arequipa", code: "AQ", status: "online" },
    lima: { name: "Lima", code: "LI", status: "online" },
    cusco: { name: "Cusco", code: "CU", status: "online" }
};

const DEFAULT_ACCOUNTS = {
    arequipa: {
        "AQ-101": { owner: "Juan Pérez", balance: 50000, locked: false },
        "AQ-102": { owner: "Sofía Málaga", balance: 12000, locked: false }
    },
    lima: {
        "LI-301": { owner: "Pedro Castillo", balance: 15000, locked: false },
        "LI-302": { owner: "Lucía Díaz", balance: 22000, locked: false }
    },
    cusco: {
        "CU-201": { owner: "Carlos Quispe", balance: 5000, locked: false },
        "CU-202": { owner: "Ana Flores", balance: 30000, locked: false }
    }
};

window.BNC_Client = {
    // ------------------------------------------
    // ESTADO DE LA SIMULACIÓN
    // ------------------------------------------
    nodes: JSON.parse(JSON.stringify(NODES_CONFIG)),
    dbState: JSON.parse(JSON.stringify(DEFAULT_ACCOUNTS)),
    
    coordinatorWAL: [],
    
    stats: {
        success: 0,
        total: 0
    },
    
    activeTx: null,
    stepExecutor: null,
    inDoubtRecovery: null,

    // Callbacks para notificar a la interfaz de usuario (Desacoplamiento)
    uiCallbacks: {
        onLog: null,         // (type, message)
        onStateChange: null, // ()
        onAnimate: null,     // (from, to, type, callback)
        onPhaseChange: null, // (phaseText, className)
        onWALUpdate: null,   // ()
        onStatsUpdate: null, // ()
        onTxEnd: null,        // ()
        onRestoreLine: null   // (nodeKey)
    },

    registerCallbacks(callbacks) {
        this.uiCallbacks = { ...this.uiCallbacks, ...callbacks };
    },

    // ------------------------------------------
    // MÉTODOS DE APOYO INTERNOS
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
                const nodeKey = to === "coordinator" ? from : to;
                setTimeout(() => {
                    if (this.uiCallbacks.onRestoreLine) {
                        this.uiCallbacks.onRestoreLine(nodeKey);
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
    // CONTROLADORES DE OPERACIÓN
    // ------------------------------------------
    resetSystem() {
        this.dbState = JSON.parse(JSON.stringify(DEFAULT_ACCOUNTS));
        Object.keys(this.nodes).forEach(key => this.nodes[key].status = "online");
        this.coordinatorWAL = [];
        this.activeTx = null;
        this.stepExecutor = null;
        this.inDoubtRecovery = null;
        
        this._triggerStateChange();
        this._triggerWALUpdate();
        this._triggerStatsUpdate();
        this._triggerPhaseChange("Estado: Inactivo", "phase-badge");
        this._log("success", "Base de datos y bitácora restablecidas a sus valores iniciales.");
    },

    setNodeStatus(node, status) {
        this.nodes[node].status = status;
        this._log("system", `Estado de nodo [${node.toUpperCase()}] cambiado a [${status.toUpperCase()}].`);
        
        if (status === "online" && this.inDoubtRecovery && this.inDoubtRecovery.failedNode === node) {
            this.ejecutarRecuperacionPosterior();
        }
    },

    // ------------------------------------------
    // FLUJO PRINCIPAL 2PC (TWO-PHASE COMMIT)
    // ------------------------------------------
    startTransaction(sourceNode, sourceAcc, destNode, destAcc, amount, isStepByStep, stepDelay) {
        if (this.inDoubtRecovery) {
            this._log("error", "Error: Existe una transacción 'IN-DOUBT' colgada. Debe recuperar el nodo primero.");
            return false;
        }
        
        const injectCrash = this.activeTx && this.activeTx.injectPhase2Crash;

        this.activeTx = {
            txId: "tx_" + Math.random().toString(36).substr(2, 9),
            sourceNode,
            destNode,
            sourceAcc,
            destAcc,
            amount,
            status: "RUNNING",
            votes: {},
            acks: {},
            locksAcquired: [],
            decision: null,
            injectPhase2Crash: injectCrash,
            step: 0,
            stepDelay: stepDelay || 500
        };

        if (isStepByStep) {
            this.stepExecutor = this._getTransactionStepsGenerator();
            this.executeNextStep();
        } else {
            this._runAutomaticTransaction();
        }
        return true;
    },

    executeNextStep() {
        if (this.stepExecutor) {
            const next = this.stepExecutor.next();
            if (next.done) {
                this.stepExecutor = null;
                if (this.uiCallbacks.onTxEnd) this.uiCallbacks.onTxEnd();
            }
        }
    },

    // Generador interno que ejecuta cada paso del 2PC paso a paso
    *_getTransactionStepsGenerator() {
        const tx = this.activeTx;
        
        // ----------------------------------------------------
        // PASO 1: Inicio de Transacción y registro en WAL
        // ----------------------------------------------------
        tx.step = 1;
        this._triggerPhaseChange("Fase 1: START", "phase-badge active-prepare");
        this._appendWAL(tx.txId, "START", null, `Transferir S/ ${tx.amount} de ${tx.sourceNode} (${tx.sourceAcc}) a ${tx.destNode} (${tx.destAcc})`);
        
        this._log("coord", `[COORDINATOR] [TX-${tx.txId.substring(0,6)}] Transacción iniciada.`);
        this._log("coord", `[COORDINATOR] [TX-${tx.txId.substring(0,6)}] Log WAL registrado: START_TX`);
        this._log("coord", `[COORDINATOR] [TX-${tx.txId.substring(0,6)}] ---> Enviando orden PREPARE a nodos participantes...`);
        
        this._animate("coordinator", tx.sourceNode, "prepare");
        this._animate("coordinator", tx.destNode, "prepare");
        
        yield "Inicio registrado. Prepárese para evaluar Fase 1.";

        // ----------------------------------------------------
        // PASO 2: Fase 1 (Prepare) - Procesamiento en Participantes
        // ----------------------------------------------------
        tx.step = 2;
        this._triggerPhaseChange("Fase 1: PREPARE", "phase-badge active-prepare");
        
        let origenVote = "VOTE_COMMIT";
        let origenMsg = "Voto de confirmación listo";
        
        if (this.nodes[tx.sourceNode].status === "offline") {
            origenVote = "TIMEOUT";
            origenMsg = "Nodo desconectado / Sin respuesta";
            this._log("error", `[${tx.sourceNode.toUpperCase()}] [TX-${tx.txId.substring(0,6)}] Error de red: Nodo inalcanzable.`);
        } else if (this.nodes[tx.sourceNode].status === "slow") {
            origenVote = "TIMEOUT";
            origenMsg = "Excedió tiempo de espera (Timeout de red > 3s)";
            this._log("warning", `[${tx.sourceNode.toUpperCase()}] [TX-${tx.txId.substring(0,6)}] Respondiendo lento...`);
        } else {
            const sourceAccount = this.dbState[tx.sourceNode][tx.sourceAcc];
            if (sourceAccount.balance < tx.amount) {
                origenVote = "VOTE_ABORT";
                origenMsg = `Fondos insuficientes (Monto: S/ ${tx.amount}, Saldo: S/ ${sourceAccount.balance})`;
                this._log("error", `[${tx.sourceNode.toUpperCase()}] [TX-${tx.txId.substring(0,6)}] Fase 1 Falló: Fondos insuficientes.`);
            } else {
                sourceAccount.locked = true;
                tx.locksAcquired.push({ node: tx.sourceNode, acc: tx.sourceAcc });
                this._log("aq", `[${tx.sourceNode.toUpperCase()}] [TX-${tx.txId.substring(0,6)}] Fase 1 PREPARE OK. Cuenta ${tx.sourceAcc} bloqueada. Voto: VOTE_COMMIT`);
                this._triggerStateChange();
            }
        }
        
        let destVote = "VOTE_COMMIT";
        let destMsg = "Voto de confirmación listo";
        
        if (this.nodes[tx.destNode].status === "offline") {
            destVote = "TIMEOUT";
            destMsg = "Nodo desconectado / Sin respuesta";
            this._log("error", `[${tx.destNode.toUpperCase()}] [TX-${tx.txId.substring(0,6)}] Error de red: Nodo inalcanzable.`);
        } else if (this.nodes[tx.destNode].status === "slow") {
            destVote = "TIMEOUT";
            destMsg = "Excedió tiempo de espera (Timeout de red > 3s)";
            this._log("warning", `[${tx.destNode.toUpperCase()}] [TX-${tx.txId.substring(0,6)}] Respondiendo lento...`);
        } else {
            const destAccount = this.dbState[tx.destNode][tx.destAcc];
            destAccount.locked = true;
            tx.locksAcquired.push({ node: tx.destNode, acc: tx.destAcc });
            this._log("cu", `[${tx.destNode.toUpperCase()}] [TX-${tx.txId.substring(0,6)}] Fase 1 PREPARE OK. Cuenta ${tx.destAcc} bloqueada. Voto: VOTE_COMMIT`);
            this._triggerStateChange();
        }
        
        tx.votes[tx.sourceNode] = { vote: origenVote, msg: origenMsg };
        tx.votes[tx.destNode] = { vote: destVote, msg: destMsg };
        
        this._appendWAL(tx.txId, "PREPARE", tx.sourceNode, `Voto: ${origenVote} (${origenMsg})`);
        this._appendWAL(tx.txId, "PREPARE", tx.destNode, `Voto: ${destVote} (${destMsg})`);

        if (origenVote !== "TIMEOUT") {
            this._animate(tx.sourceNode, "coordinator", origenVote === "VOTE_COMMIT" ? "vote_commit" : "vote_abort");
        }
        if (destVote !== "TIMEOUT") {
            this._animate(tx.destNode, "coordinator", destVote === "VOTE_COMMIT" ? "vote_commit" : "vote_abort");
        }

        yield "Votos recibidos en el Coordinador. Procediendo a tomar decisión.";

        // ----------------------------------------------------
        // PASO 3: Decisión del Coordinador e Inicio Fase 2
        // ----------------------------------------------------
        tx.step = 3;
        
        const votesList = Object.values(tx.votes);
        const allCommit = votesList.every(v => v.vote === "VOTE_COMMIT");
        
        if (allCommit) {
            tx.decision = "COMMIT";
            this._triggerPhaseChange("Decision: COMMIT", "phase-badge active-commit");
            this._appendWAL(tx.txId, "COMMIT", null, "Decisión global: COMMIT");
            this._log("coord", `[COORDINATOR] [TX-${tx.txId.substring(0,6)}] Decision global registrada: COMMIT.`);
        } else {
            tx.decision = "ABORT";
            this._triggerPhaseChange("Decision: ABORT", "phase-badge active-abort");
            this._appendWAL(tx.txId, "ABORT", null, "Decisión global: ABORT");
            this._log("error", `[COORDINATOR] [TX-${tx.txId.substring(0,6)}] Decision global registrada: ABORT.`);
            
            votesList.forEach((v, index) => {
                if (v.vote !== "VOTE_COMMIT") {
                    const nodeName = index === 0 ? tx.sourceNode : tx.destNode;
                    this._log("coord", `[COORDINATOR] [TX-${tx.txId.substring(0,6)}] Causa: Nodo [${nodeName.toUpperCase()}] reportó: ${v.msg}`);
                }
            });
        }
        
        // Simulación de caída de Cusco en este instante si el escenario lo requiere
        if (tx.decision === "COMMIT" && tx.injectPhase2Crash) {
            this.nodeStatus.cusco = "offline";
            this._log("error", `[INYECTOR DE FALLOS] !!! El nodo [CUSCO] acaba de caerse en este instante (Simulación de fallo durante Fase 2) !!!`);
        }
        
        this._log("coord", `[COORDINATOR] [TX-${tx.txId.substring(0,6)}] ---> Enviando orden de ${tx.decision} a los participantes...`);
        this._animate("coordinator", tx.sourceNode, tx.decision.toLowerCase());
        this._animate("coordinator", tx.destNode, tx.decision.toLowerCase());
        
        yield `Decisión global [${tx.decision}] distribuida a los participantes.`;

        // ----------------------------------------------------
        // PASO 4: Procesar Fase 2 en Participantes y Enviar ACKs
        // ----------------------------------------------------
        tx.step = 4;
        
        // Procesar origen
        if (this.nodes[tx.sourceNode].status === "offline") {
            this._log("error", `[${tx.sourceNode.toUpperCase()}] [TX-${tx.txId.substring(0,6)}] No responde al ${tx.decision} (Nodo desconectado).`);
        } else {
            const sourceAccount = this.dbState[tx.sourceNode][tx.sourceAcc];
            if (tx.decision === "COMMIT") {
                sourceAccount.balance -= tx.amount;
                this._log("success", `[${tx.sourceNode.toUpperCase()}] [TX-${tx.txId.substring(0,6)}] Base de datos local: DEBITADA S/ ${tx.amount} de cuenta ${tx.sourceAcc}.`);
            } else {
                this._log("system", `[${tx.sourceNode.toUpperCase()}] [TX-${tx.txId.substring(0,6)}] Base de datos local: Descartando cambios tentativos y liberando cuenta.`);
            }
            sourceAccount.locked = false;
            tx.locksAcquired = tx.locksAcquired.filter(l => !(l.node === tx.sourceNode && l.acc === tx.sourceAcc));
            tx.acks[tx.sourceNode] = true;
            this._log("aq", `[${tx.sourceNode.toUpperCase()}] [TX-${tx.txId.substring(0,6)}] Cuenta ${tx.sourceAcc} desbloqueada. Enviando ACK.`);
            this._animate(tx.sourceNode, "coordinator", "vote_commit");
        }
        
        // Procesar destino
        if (this.nodes[tx.destNode].status === "offline") {
            this._log("error", `[${tx.destNode.toUpperCase()}] [TX-${tx.txId.substring(0,6)}] No responde al ${tx.decision} (Nodo desconectado).`);
        } else {
            const destAccount = this.dbState[tx.destNode][tx.destAcc];
            if (tx.decision === "COMMIT") {
                destAccount.balance += tx.amount;
                this._log("success", `[${tx.destNode.toUpperCase()}] [TX-${tx.txId.substring(0,6)}] Base de datos local: ACREDITADA S/ ${tx.amount} a cuenta ${tx.destAcc}.`);
            } else {
                this._log("system", `[${tx.destNode.toUpperCase()}] [TX-${tx.txId.substring(0,6)}] Base de datos local: Descartando cambios tentativos y liberando cuenta.`);
            }
            destAccount.locked = false;
            tx.locksAcquired = tx.locksAcquired.filter(l => !(l.node === tx.destNode && l.acc === tx.destAcc));
            tx.acks[tx.destNode] = true;
            this._log("cu", `[${tx.destNode.toUpperCase()}] [TX-${tx.txId.substring(0,6)}] Cuenta ${tx.destAcc} desbloqueada. Enviando ACK.`);
            this._animate(tx.destNode, "coordinator", "vote_commit");
        }
        
        this._triggerStateChange();
        yield "Nodos activos ejecutaron localmente y retornaron confirmación (ACK).";

        // ----------------------------------------------------
        // PASO 5: Cierre de la Transacción en el Coordinador
        // ----------------------------------------------------
        tx.step = 5;
        
        const participants = [tx.sourceNode, tx.destNode];
        const allAcked = participants.every(p => tx.acks[p]);
        
        this.stats.total++;
        
        if (allAcked) {
            tx.status = tx.decision === "COMMIT" ? "COMMITTED" : "ABORTED";
            this._appendWAL(tx.txId, tx.status, null, `Transacción finalizada como ${tx.status}`);
            
            this._triggerPhaseChange(`Final: ${tx.status}`, tx.status === "COMMITTED" ? "phase-badge active-commit" : "phase-badge active-abort");
            
            if (tx.status === "COMMITTED") {
                this.stats.success++;
                this._log("success", `[COORDINATOR] [TX-${tx.txId.substring(0,6)}] Transacción confirmada en todos los nodos (COMMITTED). Propiedades ACID garantizadas.`);
            } else {
                this._log("error", `[COORDINATOR] [TX-${tx.txId.substring(0,6)}] Transacción revertida globalmente (ROLLBACK). Consistencia de datos preservada.`);
            }
        } else {
            tx.status = "IN_DOUBT";
            this._appendWAL(tx.txId, "IN_DOUBT", null, `Fase 2 incompleta. Pendiente de confirmación.`);
            this._triggerPhaseChange("IN-DOUBT (Bloqueado)", "phase-badge active-abort");
            
            const failedNode = participants.find(p => !tx.acks[p]);
            const successNode = participants.find(p => tx.acks[p]);
            
            this.inDoubtRecovery = {
                txId: tx.txId,
                decision: tx.decision,
                failedNode: failedNode,
                successNode: successNode,
                amount: tx.amount,
                sourceAcc: tx.sourceAcc,
                destAcc: tx.destAcc,
                sourceNode: tx.sourceNode,
                destNode: tx.destNode
            };
            
            this._log("error", `[COORDINATOR] [TX-${tx.txId.substring(0,6)}] ALERTA: Estado IN-DOUBT.`);
            this._log("error", `[COORDINATOR] [TX-${tx.txId.substring(0,6)}] El nodo [${failedNode.toUpperCase()}] no confirmó el COMMIT. El recurso sigue bloqueado para preservar consistencia.`);
            this._log("system", `[SISTEMA] El protocolo 2PC exige que se mantengan los recursos bloqueados en el nodo afectado hasta que se recupere. Para forzar la recuperación, cambie el estado del nodo [${failedNode.toUpperCase()}] a ONLINE.`);
        }
        
        this._triggerStatsUpdate();
        this.activeTx = null;
        yield "Transacción terminada.";
    },

    // ------------------------------------------
    // EJECUCIÓN AUTOMÁTICA
    // ------------------------------------------
    _runAutomaticTransaction() {
        const tx = this.activeTx;
        
        // Paso 1: Inicio
        this._appendWAL(tx.txId, "START", null, `Auto Transferir S/ ${tx.amount} de ${tx.sourceNode} (${tx.sourceAcc}) a ${tx.destNode} (${tx.destAcc})`);
        this._log("coord", `[COORDINATOR] [TX-${tx.txId.substring(0,6)}] Transacción automática iniciada.`);
        
        this._animate("coordinator", tx.sourceNode, "prepare");
        this._animate("coordinator", tx.destNode, "prepare", () => {
            
            // Fase 1: Prepare
            let origenVote = "VOTE_COMMIT";
            let destVote = "VOTE_COMMIT";
            
            // Origen
            if (this.nodes[tx.sourceNode].status === "offline" || this.nodes[tx.sourceNode].status === "slow") {
                origenVote = "TIMEOUT";
                this._log("error", `[${tx.sourceNode.toUpperCase()}] [TX-${tx.txId.substring(0,6)}] Error de red / Timeout.`);
            } else {
                const sourceAccount = this.dbState[tx.sourceNode][tx.sourceAcc];
                if (sourceAccount.balance < tx.amount) {
                    origenVote = "VOTE_ABORT";
                    this._log("error", `[${tx.sourceNode.toUpperCase()}] [TX-${tx.txId.substring(0,6)}] Fondos insuficientes.`);
                } else {
                    sourceAccount.locked = true;
                    tx.locksAcquired.push({ node: tx.sourceNode, acc: tx.sourceAcc });
                    this._log("aq", `[${tx.sourceNode.toUpperCase()}] [TX-${tx.txId.substring(0,6)}] Prepare OK. Cuenta bloqueada.`);
                }
            }
            
            // Destino
            if (this.nodes[tx.destNode].status === "offline" || this.nodes[tx.destNode].status === "slow") {
                destVote = "TIMEOUT";
                this._log("error", `[${tx.destNode.toUpperCase()}] [TX-${tx.txId.substring(0,6)}] Error de red / Timeout.`);
            } else {
                const destAccount = this.dbState[tx.destNode][tx.destAcc];
                destAccount.locked = true;
                tx.locksAcquired.push({ node: tx.destNode, acc: tx.destAcc });
                this._log("cu", `[${tx.destNode.toUpperCase()}] [TX-${tx.txId.substring(0,6)}] Prepare OK. Cuenta bloqueada.`);
            }
            
            tx.votes[tx.sourceNode] = { vote: origenVote };
            tx.votes[tx.destNode] = { vote: destVote };
            
            this._appendWAL(tx.txId, "PREPARE", tx.sourceNode, `Voto: ${origenVote}`);
            this._appendWAL(tx.txId, "PREPARE", tx.destNode, `Voto: ${destVote}`);
            
            this._triggerStateChange();
            
            // Retorno de votos
            this._animate(tx.sourceNode, "coordinator", origenVote === "VOTE_COMMIT" ? "vote_commit" : "vote_abort");
            this._animate(tx.destNode, "coordinator", destVote === "VOTE_COMMIT" ? "vote_commit" : "vote_abort", () => {
                
                // Decisión
                const votesList = Object.values(tx.votes);
                const allCommit = votesList.every(v => v.vote === "VOTE_COMMIT");
                tx.decision = allCommit ? "COMMIT" : "ABORT";
                
                this._appendWAL(tx.txId, tx.decision, null, `Decisión global automática: ${tx.decision}`);
                
                // Simulación de caída de Cusco en Fase 2 si es requerido
                if (tx.decision === "COMMIT" && tx.injectPhase2Crash) {
this.nodes.cusco.status = "offline";
                    this._log("error", `[INYECTOR DE FALLOS] !!! El nodo [CUSCO] acaba de caerse en este instante (Simulación de fallo durante Fase 2) !!!`);
                }
                
                // Envío decisión
                this._animate("coordinator", tx.sourceNode, tx.decision.toLowerCase());
                this._animate("coordinator", tx.destNode, tx.decision.toLowerCase(), () => {
                    
                    // Fase 2: Aplicar cambios
                    // Origen
                    if (this.nodes[tx.sourceNode].status !== "offline") {
                        const acc = this.dbState[tx.sourceNode][tx.sourceAcc];
                        if (tx.decision === "COMMIT") acc.balance -= tx.amount;
                        acc.locked = false;
                        tx.acks[tx.sourceNode] = true;
                    }
                    
                    // Destino
                    if (this.nodes[tx.destNode].status !== "offline") {
                        const acc = this.dbState[tx.destNode][tx.destAcc];
                        if (tx.decision === "COMMIT") acc.balance += tx.amount;
                        acc.locked = false;
                        tx.acks[tx.destNode] = true;
                    }
                    
                    this._triggerStateChange();
                    
                    // Cierre
                    this.stats.total++;
                    const participants = [tx.sourceNode, tx.destNode];
                    const allAcked = participants.every(p => tx.acks[p]);
                    
                    if (allAcked) {
                        tx.status = tx.decision === "COMMIT" ? "COMMITTED" : "ABORTED";
                        this._appendWAL(tx.txId, tx.status, null, `Transacción automática completada como ${tx.status}`);
                        this._triggerPhaseChange(`Final: ${tx.status}`, tx.status === "COMMITTED" ? "phase-badge active-commit" : "phase-badge active-abort");
                        
                        if (tx.status === "COMMITTED") {
                            this.stats.success++;
                            this._log("success", `[COORDINATOR] [TX-${tx.txId.substring(0,6)}] Auto-Transacción exitosa (COMMITTED).`);
                        } else {
                            this._log("error", `[COORDINATOR] [TX-${tx.txId.substring(0,6)}] Auto-Transacción fallida y revertida.`);
                        }
                    } else {
                        tx.status = "IN_DOUBT";
                        this._appendWAL(tx.txId, "IN_DOUBT", null, `Fase 2 automática incompleta.`);
                        this._triggerPhaseChange("IN-DOUBT (Bloqueado)", "phase-badge active-abort");
                        
                        const failedNode = participants.find(p => !tx.acks[p]);
                        
                        this.inDoubtRecovery = {
                            txId: tx.txId,
                            decision: tx.decision,
                            failedNode: failedNode,
                            amount: tx.amount,
                            sourceAcc: tx.sourceAcc,
                            destAcc: tx.destAcc,
                            sourceNode: tx.sourceNode,
                            destNode: tx.destNode
                        };
                        this._log("error", `[COORDINATOR] [TX-${tx.txId.substring(0,6)}] Transacción en estado IN-DOUBT. Nodo ${failedNode.toUpperCase()} no disponible en Fase 2.`);
                    }
                    
                    this._triggerStatsUpdate();
                    this.activeTx = null;
                    if (this.uiCallbacks.onTxEnd) this.uiCallbacks.onTxEnd();
                });
            });
        });
    },

    // ------------------------------------------
    // RECUPERACIÓN POSTERIOR (POST-RECOVERY)
    // ------------------------------------------
    ejecutarRecuperacionPosterior() {
        if (!this.inDoubtRecovery) return;
        
        const rec = this.inDoubtRecovery;
        
        this._log("system", `[RECUPERACIÓN] [TX-${rec.txId.substring(0,6)}] Detectado nodo [${rec.failedNode.toUpperCase()}] ONLINE.`);
        this._log("system", `[RECUPERACIÓN] [TX-${rec.txId.substring(0,6)}] Leyendo log local del Coordinador... Encontrado estado: ${rec.decision}`);
        this._log("coord", `[COORDINATOR] [TX-${rec.txId.substring(0,6)}] ---> Resolviendo transacción colgada. Re-enviando orden: ${rec.decision}`);
        
        this._animate("coordinator", rec.failedNode, rec.decision.toLowerCase(), () => {
            const accounts = this.dbState[rec.failedNode];
            const targetAccId = rec.failedNode === rec.sourceNode ? rec.sourceAcc : rec.destAcc;
            const account = accounts[targetAccId];
            
            if (rec.decision === "COMMIT") {
                if (rec.failedNode === rec.sourceNode) {
                    account.balance -= rec.amount;
                } else {
                    account.balance += rec.amount;
                }
                this._log("success", `[${rec.failedNode.toUpperCase()}] [TX-${rec.txId.substring(0,6)}] Base de datos recuperada y sincronizada: Se aplicó ${rec.decision}.`);
            } else {
                this._log("system", `[${rec.failedNode.toUpperCase()}] [TX-${rec.txId.substring(0,6)}] Base de datos recuperada: Transacción descartada.`);
            }
            
            account.locked = false;
            
            this._appendWAL(rec.txId, "COMMITTED", rec.failedNode, `Recuperación exitosa de nodo ${rec.failedNode}. Sincronizado.`);
            
            this._animate(rec.failedNode, "coordinator", "vote_commit", () => {
                this._log("coord", `[COORDINATOR] [TX-${rec.txId.substring(0,6)}] Recibido ACK de nodo recuperado. Estado consistente restablecido.`);
                
                this.stats.success++;
                this.inDoubtRecovery = null;
                
                this._triggerStateChange();
                this._triggerStatsUpdate();
                this._triggerPhaseChange("Recuperado: COMMITTED", "phase-badge active-commit");
            });
        });
    },

    createAccount(nodeKey, accId, owner, balance) {
        if (!this.nodes[nodeKey]) {
            return { success: false, msg: "Nodo no existe." };
        }
        if (!this.dbState[nodeKey]) {
            this.dbState[nodeKey] = {};
        }
        if (this.dbState[nodeKey][accId]) {
            return { success: false, msg: `La cuenta ${accId} ya existe en ${this.nodes[nodeKey].name}.` };
        }
        this.dbState[nodeKey][accId] = { owner, balance, locked: false };
        this._log("success", `Cuenta ${accId} (${owner}) creada exitosamente en ${this.nodes[nodeKey].name}.`);
        this._triggerStateChange();
        return { success: true };
    },

    updateAccount(nodeKey, accId, owner, balance) {
        if (!this.dbState[nodeKey] || !this.dbState[nodeKey][accId]) {
            return { success: false, msg: `La cuenta ${accId} no existe en ${this.nodes[nodeKey].name}.` };
        }
        this.dbState[nodeKey][accId].owner = owner;
        this.dbState[nodeKey][accId].balance = balance;
        this._log("success", `Cuenta ${accId} actualizada exitosamente.`);
        this._triggerStateChange();
        return { success: true };
    },

    deleteAccount(nodeKey, accId) {
        if (!this.dbState[nodeKey] || !this.dbState[nodeKey][accId]) {
            return { success: false, msg: `La cuenta ${accId} no existe en ${this.nodes[nodeKey].name}.` };
        }
        const acc = this.dbState[nodeKey][accId];
        if (acc.locked) {
            return { success: false, msg: `No se puede eliminar la cuenta ${accId}: está bloqueada por una transacción activa.` };
        }
        delete this.dbState[nodeKey][accId];
        this._log("success", `Cuenta ${accId} (${acc.owner}) eliminada exitosamente de ${this.nodes[nodeKey].name}.`);
        this._triggerStateChange();
        return { success: true };
    }
};
