// ============================================================
// app.js  –  UI Controller for BNC 2PC Simulator
// ============================================================

// ============================================================
// DOM READY
// ============================================================
document.addEventListener("DOMContentLoaded", () => {

    // 1. Register callbacks so client.js can push events to us
    BNC_Client.registerCallbacks({
        onLog: appendConsole,
        onStateChange: renderAccounts,
        onAnimate: animatePacket,
        onPhaseChange: updatePhaseBadge,
        onWALUpdate: renderWAL,
        onStatsUpdate: renderStats,
        onTxEnd: onTransactionEnd,
        onRestoreLine: restoreLineState
    });

    // 2. Initial render
    populateNodeSelectors();
    renderNetworkDiagram();
    renderAccounts();
    renderStats();

    // 3. Button bindings
    document.getElementById("btn-start").addEventListener("click", startTransactionUI);
    document.getElementById("btn-next").addEventListener("click", () => BNC_Client.executeNextStep());
    document.getElementById("btn-reset").addEventListener("click", () => {
        BNC_Client.resetSystem();
        populateNodeSelectors();
        renderNetworkDiagram();
        document.getElementById("btn-start").disabled = false;
        document.getElementById("btn-next").disabled = true;
    });

    appendConsole("system", "[SISTEMA] Front-end inicializado. Nodos: Arequipa, Lima, Cusco.");
});

// ============================================================
// NODE SELECTORS (dropdowns)
// ============================================================
function populateNodeSelectors() {
    const sourceSel = document.getElementById("source-select");
    const destSel   = document.getElementById("dest-select");

    [sourceSel, destSel].forEach(sel => {
        sel.innerHTML = "";
        Object.entries(BNC_Client.nodes).forEach(([key, node]) => {
            const opt = document.createElement("option");
            opt.value = key;
            opt.textContent = node.name;
            sel.appendChild(opt);
        });
    });

    // Default: source=arequipa, dest=cusco (if available)
    if (BNC_Client.nodes.arequipa) sourceSel.value = "arequipa";
    if (BNC_Client.nodes.cusco) destSel.value = "cusco";

    populateAccountDropdown("source");
    populateAccountDropdown("dest");

    // Also fill the account creation modal dropdown
    const accNodeSel = document.getElementById("acc-node-select");
    if (accNodeSel) {
        accNodeSel.innerHTML = "";
        Object.entries(BNC_Client.nodes).forEach(([key, node]) => {
            const opt = document.createElement("option");
            opt.value = key;
            opt.textContent = node.name;
            accNodeSel.appendChild(opt);
        });
    }
}

function populateAccountDropdown(side) {
    const nodeSel = document.getElementById(side === "source" ? "source-select" : "dest-select");
    const accSel  = document.getElementById(side === "source" ? "source-acc-select" : "dest-acc-select");
    const nodeKey = nodeSel.value;
    accSel.innerHTML = "";

    const accounts = BNC_Client.dbState[nodeKey] || {};
    Object.entries(accounts).forEach(([accId, acc]) => {
        const opt = document.createElement("option");
        opt.value = accId;
        opt.textContent = `${accId} — ${acc.owner} (S/ ${acc.balance.toLocaleString()})`;
        accSel.appendChild(opt);
    });

    if (Object.keys(accounts).length === 0) {
        const opt = document.createElement("option");
        opt.value = "";
        opt.textContent = "— Sin cuentas —";
        opt.disabled = true;
        accSel.appendChild(opt);
    }
}

// ============================================================
// NETWORK DIAGRAM (SVG lines + node elements)
// ============================================================
const nodePositions = {
    coordinator: { x: 50, y: 22 },
    arequipa:    { x: 15, y: 75 },
    lima:        { x: 50, y: 75 },
    cusco:       { x: 85, y: 75 }
};

function renderNetworkDiagram() {
    const container = document.getElementById("network-diagram-container");
    const svg = document.getElementById("network-svg");

    // Remove old node elements (except coordinator + svg)
    container.querySelectorAll(".network-node:not(.node-coordinator)").forEach(el => el.remove());

    // Remove old lines
    svg.querySelectorAll("line, .packet-group").forEach(el => el.remove());

    Object.entries(BNC_Client.nodes).forEach(([key, node]) => {
        const pos = nodePositions[key];
        if (!pos) return;

        // Draw SVG line from coordinator to this node
        const line = document.createElementNS("http://www.w3.org/2000/svg", "line");
        line.setAttribute("x1", `${nodePositions.coordinator.x}%`);
        line.setAttribute("y1", `${nodePositions.coordinator.y}%`);
        line.setAttribute("x2", `${pos.x}%`);
        line.setAttribute("y2", `${pos.y}%`);
        line.setAttribute("class", "network-line line-off");
        line.setAttribute("data-node", key);
        svg.appendChild(line);

        // Node element
        const el = document.createElement("div");
        el.className = `network-node node-participant`;
        el.id = `node-el-${key}`;
        el.style.left = `${pos.x}%`;
        el.style.top = `${pos.y}%`;
        el.innerHTML = `
            <div class="node-icon" style="position:relative;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <rect x="2" y="2" width="20" height="8" rx="2" ry="2"/>
                    <rect x="2" y="14" width="20" height="8" rx="2" ry="2"/>
                    <line x1="6" y1="6" x2="6.01" y2="6"/>
                    <line x1="6" y1="18" x2="6.01" y2="18"/>
                </svg>
                <span class="status-dot ${node.status === 'online' ? 'online' : 'offline'}"></span>
            </div>
            <div class="node-label">
                <strong>${node.name.toUpperCase()}</strong>
                <span class="node-sub">${node.code.toUpperCase()} — <em id="status-text-${key}">${node.status}</em></span>
            </div>
            <div class="node-controls centered">
                <button class="nbtn on"  title="Online"  onclick="setNodeUI('${key}','online')">ON</button>
                <button class="nbtn off" title="Offline" onclick="setNodeUI('${key}','offline')">OFF</button>
            </div>
        `;
        container.appendChild(el);
    });
}

function setNodeUI(nodeKey, status) {
    BNC_Client.setNodeStatus(nodeKey, status);
    const statusText = document.getElementById(`status-text-${nodeKey}`);
    if (statusText) statusText.textContent = status;
    const dot = document.querySelector(`#node-el-${nodeKey} .status-dot`);
    if (dot) dot.className = `status-dot ${status}`;
    populateAccountDropdown("source");
    populateAccountDropdown("dest");
}

// ============================================================
// DATABASE RENDERING
// ============================================================
function renderAccounts() {
    const container = document.getElementById("databases-container");
    container.innerHTML = "";

    Object.entries(BNC_Client.nodes).forEach(([key, node]) => {
        const code = node.code;
        const accounts = BNC_Client.dbState[key] || {};

        const card = document.createElement("div");
        card.className = `db-card ${node.status !== 'online' ? 'node-offline' : ''}`;
        card.innerHTML = `
            <div class="db-card-header">
                <div class="db-card-header-left">
                    <svg class="db-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <ellipse cx="12" cy="5" rx="9" ry="3"/>
                        <path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"/>
                        <path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"/>
                    </svg>
                    <h4>BD Regional: ${node.name}</h4>
                </div>
            </div>
            <table class="db-table">
                <thead>
                    <tr><th>Cuenta</th><th>Titular</th><th>Saldo (S/)</th><th>Estado</th><th>Acciones</th></tr>
                </thead>
                <tbody id="db-${code}-tbody">
                </tbody>
            </table>
        `;
        container.appendChild(card);

        const tbody = card.querySelector(`#db-${code}-tbody`);
        const entries = Object.entries(accounts);
        if (entries.length === 0) {
            tbody.innerHTML = `<tr><td colspan="5" class="text-center text-muted">Sin cuentas</td></tr>`;
        } else {
            entries.forEach(([accId, acc]) => {
                const lockClass = acc.locked ? "locked" : "free";
                const lockText = acc.locked ? "Bloqueado" : "Libre";
                const tr = document.createElement("tr");
                tr.innerHTML = `
                    <td><strong>${accId}</strong></td>
                    <td>${acc.owner}</td>
                    <td>S/ ${acc.balance.toLocaleString()}</td>
                    <td><span class="lock-badge ${lockClass}">${lockText}</span></td>
                    <td class="actions-cell">
                        <button class="db-action-btn" onclick="openEditAccountModal('${key}', '${accId}')" title="Editar">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="14" height="14">
                                <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
                                <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
                            </svg>
                        </button>
                        <button class="db-action-btn delete" onclick="openDeleteAccountModal('${key}', '${accId}')" title="Eliminar">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="14" height="14">
                                <polyline points="3 6 5 6 21 6"/>
                                <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
                                <line x1="10" y1="11" x2="10" y2="17"/>
                                <line x1="14" y1="11" x2="14" y2="17"/>
                            </svg>
                        </button>
                    </td>
                `;
                tbody.appendChild(tr);
            });
        }
    });

    // Also update the dot indicators on the network diagram
    Object.entries(BNC_Client.nodes).forEach(([key, node]) => {
        const dot = document.querySelector(`#node-el-${key} .status-dot`);
        if (dot) dot.className = `status-dot ${node.status}`;
        const statusText = document.getElementById(`status-text-${key}`);
        if (statusText) statusText.textContent = node.status;
    });
}

// ============================================================
// CONSOLE / LOG
// ============================================================
function appendConsole(type, msg) {
    const con = document.getElementById("console-output");
    const line = document.createElement("div");
    line.className = `console-line ${type}`;
    const time = new Date().toLocaleTimeString();
    line.textContent = `[${time}] ${msg}`;
    con.appendChild(line);
    con.scrollTop = con.scrollHeight;
}

function clearConsole() {
    document.getElementById("console-output").innerHTML =
        '<div class="console-line system">[SISTEMA] Consola limpiada.</div>';
}

function copyConsoleLogs() {
    const lines = document.querySelectorAll("#console-output .console-line");
    const text = Array.from(lines).map(l => l.textContent).join("\n");
    navigator.clipboard.writeText(text).then(() => {
        appendConsole("success", "[SISTEMA] Logs copiados al portapapeles.");
    });
}

// ============================================================
// WAL TABLE
// ============================================================
function renderWAL() {
    const tbody = document.getElementById("wal-tbody");
    if (!tbody) return;
    const wal = BNC_Client.coordinatorWAL;
    if (wal.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4" class="text-center text-muted">Sin registros</td></tr>';
        return;
    }
    tbody.innerHTML = "";
    wal.forEach(entry => {
        const tr = document.createElement("tr");
        const nodeName = entry.node ? (BNC_Client.nodes[entry.node] ? BNC_Client.nodes[entry.node].name : entry.node) : "—";
        const stateClass = entry.state === "COMMITTED" ? "text-success" :
                           entry.state === "ABORT" || entry.state === "IN_DOUBT" ? "text-error" : "";
        tr.innerHTML = `
            <td>${entry.txId.substring(0, 10)}</td>
            <td class="${stateClass}">${entry.state}</td>
            <td>${nodeName}</td>
            <td>${entry.message}</td>
        `;
        tbody.appendChild(tr);
    });
}

// ============================================================
// STATS
// ============================================================
function renderStats() {
    const stats = BNC_Client.stats;
    document.getElementById("tx-stats").textContent = `${stats.success} / ${stats.total}`;
    document.getElementById("coord-log-count").textContent = `${BNC_Client.coordinatorWAL.length} entradas`;
}

// ============================================================
// PHASE BADGE
// ============================================================
function updatePhaseBadge(text, className) {
    const badge = document.getElementById("current-phase-badge");
    if (badge) {
        badge.textContent = text;
        badge.className = className || "phase-badge";
    }
}

// ============================================================
// PACKET ANIMATION (line glow)
// ============================================================
function animatePacket(from, to, type, callback) {
    const nodeKey = to === "coordinator" ? from : to;
    const line = document.querySelector(`.network-line[data-node="${nodeKey}"]`);

    if (line) {
        line.classList.add("line-active");
    }
    if (callback) callback();
}

function restoreLineState(nodeKey) {
    const line = document.querySelector(`.network-line[data-node="${nodeKey}"]`);
    if (line) {
        line.classList.remove("line-active");
        line.classList.add("line-off");
    }
}

// ============================================================
// START TRANSACTION (UI → Client)
// ============================================================
function startTransactionUI() {
    const sourceNode = document.getElementById("source-select").value;
    const destNode   = document.getElementById("dest-select").value;
    const sourceAcc  = document.getElementById("source-acc-select").value;
    const destAcc    = document.getElementById("dest-acc-select").value;
    const amount     = parseFloat(document.getElementById("amount-input").value) || 0;
    const isStep     = document.getElementById("step-by-step-toggle").checked;
    const stepDelay  = parseInt(document.getElementById("step-delay-input").value) || 500;

    if (!sourceAcc || !destAcc) {
        appendConsole("error", "[SISTEMA] Selecciona cuentas válidas de origen y destino.");
        return;
    }
    if (sourceNode === destNode && sourceAcc === destAcc) {
        appendConsole("error", "[SISTEMA] La cuenta de origen y destino no pueden ser la misma.");
        return;
    }
    if (amount <= 0) {
        appendConsole("error", "[SISTEMA] El monto debe ser mayor a 0.");
        return;
    }

    document.getElementById("btn-start").disabled = true;
    document.getElementById("btn-next").disabled = !isStep;

    const ok = BNC_Client.startTransaction(sourceNode, sourceAcc, destNode, destAcc, amount, isStep, stepDelay);
    if (!ok) {
        document.getElementById("btn-start").disabled = false;
        document.getElementById("btn-next").disabled = true;
    }
}

function openEditAccountModal(nodeKey, accId) {
    const acc = BNC_Client.dbState[nodeKey][accId];
    document.getElementById("edit-acc-key").value = nodeKey;
    document.getElementById("edit-acc-id").value = accId;
    document.getElementById("edit-acc-owner").value = acc.owner;
    document.getElementById("edit-acc-balance").value = acc.balance;
    openModal("modal-edit-account");
}

function submitEditAccount(e) {
    e.preventDefault();
    const nodeKey = document.getElementById("edit-acc-key").value;
    const accId = document.getElementById("edit-acc-id").value;
    const owner = document.getElementById("edit-acc-owner").value;
    const balance = parseFloat(document.getElementById("edit-acc-balance").value);

    const result = BNC_Client.updateAccount(nodeKey, accId, owner, balance);
    if (result.success) {
        closeModal("modal-edit-account");
        renderAccounts();
        populateAccountDropdown("source");
        populateAccountDropdown("dest");
    } else {
        appendConsole("error", `[SISTEMA] ${result.msg}`);
    }
}

let pendingDeleteNode = null;
let pendingDeleteAcc = null;

function openDeleteAccountModal(nodeKey, accId) {
    pendingDeleteNode = nodeKey;
    pendingDeleteAcc = accId;
    const acc = BNC_Client.dbState[nodeKey][accId];
    document.getElementById("delete-confirm-msg").innerHTML =
        `¿Estás seguro de eliminar la cuenta <strong>${accId}</strong> de <strong>${acc.owner}</strong> en <strong>${BNC_Client.nodes[nodeKey].name}</strong>?`;
    openModal("modal-delete-account");
}

function confirmDeleteAccount() {
    if (!pendingDeleteNode || !pendingDeleteAcc) return;

    const result = BNC_Client.deleteAccount(pendingDeleteNode, pendingDeleteAcc);
    if (result.success) {
        closeModal("modal-delete-account");
        renderAccounts();
        populateAccountDropdown("source");
        populateAccountDropdown("dest");
    } else {
        appendConsole("error", `[SISTEMA] ${result.msg}`);
        closeModal("modal-delete-account");
    }
    pendingDeleteNode = null;
    pendingDeleteAcc = null;
}

function onTransactionEnd() {
    document.getElementById("btn-start").disabled = false;
    document.getElementById("btn-next").disabled = true;
    populateAccountDropdown("source");
    populateAccountDropdown("dest");
    Object.keys(BNC_Client.nodes).forEach(key => restoreLineState(key));
}

// ============================================================
// SCENARIOS
// ============================================================
function loadScenario(name) {
    // Reset first
    BNC_Client.resetSystem();
    populateNodeSelectors();
    renderNetworkDiagram();

    const srcSel  = document.getElementById("source-select");
    const dstSel  = document.getElementById("dest-select");
    const amtInp  = document.getElementById("amount-input");

    switch (name) {
        case "normal":
            srcSel.value = "arequipa"; populateAccountDropdown("source");
            dstSel.value = "cusco";    populateAccountDropdown("dest");
            document.getElementById("source-acc-select").value = "AQ-101";
            document.getElementById("dest-acc-select").value = "CU-201";
            amtInp.value = 25000;
            appendConsole("system", "[ESCENARIO] Normal: Transferencia S/ 25,000 de AQ-101 (Arequipa) → CU-201 (Cusco). Se espera COMMIT exitoso.");
            break;

        case "insufficient_funds":
            srcSel.value = "arequipa"; populateAccountDropdown("source");
            dstSel.value = "cusco";    populateAccountDropdown("dest");
            document.getElementById("source-acc-select").value = "AQ-101";
            document.getElementById("dest-acc-select").value = "CU-201";
            amtInp.value = 80000;
            appendConsole("system", "[ESCENARIO] Fondos Insuficientes: Transferencia S/ 80,000 (saldo AQ-101 = S/ 50,000). Se espera ABORT en Fase 1.");
            break;

        case "node_crash":
            BNC_Client.setNodeStatus("cusco", "offline");
            renderNetworkDiagram();
            srcSel.value = "arequipa"; populateAccountDropdown("source");
            dstSel.value = "cusco";    populateAccountDropdown("dest");
            document.getElementById("source-acc-select").value = "AQ-101";
            document.getElementById("dest-acc-select").value = "CU-201";
            amtInp.value = 25000;
            appendConsole("system", "[ESCENARIO] Nodo Caído: Cusco desconectado. Transferencia S/ 25,000 AQ → CU. Se espera ABORT (timeout Fase 1).");
            break;

        case "in_doubt_recovery":
            srcSel.value = "arequipa"; populateAccountDropdown("source");
            dstSel.value = "cusco";    populateAccountDropdown("dest");
            document.getElementById("source-acc-select").value = "AQ-101";
            document.getElementById("dest-acc-select").value = "CU-201";
            amtInp.value = 25000;
            // Set the crash flag on activeTx (we'll inject it before the transaction starts)
            BNC_Client.activeTx = { injectPhase2Crash: true };
            appendConsole("system", "[ESCENARIO] In-Doubt & Recovery: Cusco caerá durante Fase 2. COMMIT parcial → IN-DOUBT. Recuperar cambiando Cusco a ONLINE.");
            break;
    }
}

// ============================================================
// MODAL: Create Account
// ============================================================
function openModal(id) {
    const modal = document.getElementById(id);
    if (modal) modal.classList.add("visible");
}

function closeModal(id) {
    const modal = document.getElementById(id);
    if (modal) modal.classList.remove("visible");
}

function submitCreateAccount(e) {
    e.preventDefault();
    const nodeKey = document.getElementById("acc-node-select").value;
    const accId   = document.getElementById("acc-new-id").value;
    const balance = document.getElementById("acc-new-balance").value;
    const owner   = document.getElementById("acc-new-owner").value;

    const result = BNC_Client.createAccount(nodeKey, accId, owner, parseFloat(balance));
    if (result.success) {
        closeModal("modal-account");
        renderAccounts();
        populateAccountDropdown("source");
        populateAccountDropdown("dest");
        document.getElementById("create-account-form").reset();
    } else {
        appendConsole("error", `[SISTEMA] ${result.msg}`);
    }
}
