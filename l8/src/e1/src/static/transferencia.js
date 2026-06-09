function cargarProductos() {
    const origen = document.getElementById('origen').value;
    const select = document.getElementById('producto');
    const productos = inventarioCache.filter(r => r.almacen === origen && r.stock > 0).map(r => r.producto);
    select.innerHTML = '';
    if (productos.length === 0) { select.innerHTML = '<option value="">Sin productos disponibles</option>'; return; }
    for (const p of [...new Set(productos)].sort()) {
        const opt = document.createElement('option');
        opt.value = p; opt.textContent = p;
        select.appendChild(opt);
    }
}

function renderTimeline(entries) {
    if (!entries || entries.length === 0) return '';
    return entries.map((e, i) => `
        <div class="tl ${e.fase}" style="animation-delay:${i * 0.06}s">
            <span class="tl-f">${e.fase}</span>
            <span class="tl-d">${e.nodo ? `<span class="tl-n">(${e.nodo})</span> ` : ''}${e.detalle}</span>
        </div>
    `).join('');
}

function renderBadge(status) {
    const cls = { COMMITTED: 'green', ROLLED_BACK: 'red', FAILED: 'amber' }[status] || 'amber';
    return `<span class="badge ${cls}">${status}</span>`;
}

let countdownInterval = null;

function startCountdown(seconds, resultDiv) {
    let remaining = seconds;
    const msg = document.createElement('div');
    msg.id = 'countdown-msg';
    msg.className = 'countdown';
    msg.innerHTML = `Puede detener un nodo ahora — <strong>${remaining}s</strong> restantes`;
    resultDiv.appendChild(msg);
    countdownInterval = setInterval(() => {
        remaining--;
        if (remaining <= 0) { clearInterval(countdownInterval); msg.innerHTML = 'Reanudando...'; msg.style.borderColor = 'var(--green-b)'; msg.style.background = 'var(--green-bg)'; msg.style.color = 'var(--green)'; return; }
        msg.innerHTML = `Puede detener un nodo ahora — <strong>${remaining}s</strong> restantes`;
    }, 1000);
}

function stopCountdown() {
    if (countdownInterval) { clearInterval(countdownInterval); countdownInterval = null; }
    const msg = document.getElementById('countdown-msg');
    if (msg) msg.remove();
}

async function ejecutarTransferencia(e) {
    e.preventDefault();
    const btn = document.getElementById('btn-transferir');
    const resultDiv = document.getElementById('transfer-result');
    btn.disabled = true; btn.textContent = 'Transfiriendo...';
    resultDiv.innerHTML = '<div class="result-box" style="text-align:center;color:var(--text2)">Ejecutando protocolo 2PC...</div>';

    const delay = parseFloat(document.getElementById('delay').value) || 0;
    const payload = {
        origen: document.getElementById('origen').value,
        destino: document.getElementById('destino').value,
        producto: document.getElementById('producto').value,
        cantidad: parseInt(document.getElementById('cantidad').value, 10),
        delay: delay,
    };
    if (delay > 0) startCountdown(delay, resultDiv);

    try {
        const result = await safeFetch(`${window.API_BASE}/transferir`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) });
        stopCountdown();
        if (!result.ok) { resultDiv.innerHTML = `<div class="result-box error"><strong>Error:</strong> ${result.data?.detail || result.data || 'Error desconocido'}</div>`; return; }

        const data = result.data;
        resultDiv.innerHTML = `
            <div class="result-box">
                <div class="result-meta">${renderBadge(data.status)}<span style="font-size:0.65rem;font-family:var(--mono);color:var(--muted)">Txn: ${data.txn_id.slice(0, 8)}...</span></div>
                <div class="result-det"><strong>${data.producto}</strong>: ${data.origen} → ${data.destino} (${data.cantidad} und.)</div>
                ${data.stock_origen_despues !== null ? `<div class="result-stk">Stock después: ${data.origen} = ${data.stock_origen_despues}, ${data.destino} = ${data.stock_destino_despues}</div>` : ''}
                <div class="timeline">${renderTimeline(data.log)}</div>
            </div>
        `;
        await Promise.all([cargarInventario(), cargarLog()]);
        cargarProductos();
    } catch (err) {
        stopCountdown();
        resultDiv.innerHTML = `<div class="result-box error"><strong>Error de red:</strong> ${err.message}</div>`;
    } finally {
        btn.disabled = false; btn.textContent = 'Ejecutar Transferencia';
    }
}
