function cargarProductos() {
    const origen = document.getElementById('origen').value;
    const select = document.getElementById('producto');
    const productos = inventarioCache
        .filter(r => r.almacen === origen && r.stock > 0)
        .map(r => r.producto);
    select.innerHTML = '';
    if (productos.length === 0) {
        select.innerHTML = '<option value="">Sin productos disponibles</option>';
        return;
    }
    for (const p of [...new Set(productos)].sort()) {
        const opt = document.createElement('option');
        opt.value = p;
        opt.textContent = p;
        select.appendChild(opt);
    }
}

function renderTimeline(entries) {
    if (!entries || entries.length === 0) return '';
    return entries.map(e => `
        <div class="timeline-entry ${e.fase}">
            <span class="fase">${e.fase}</span>
            <span class="detalle">${e.nodo ? `(${e.nodo}) ` : ''}${e.detalle}</span>
        </div>
    `).join('');
}

function renderStatusBadge(status) {
    const cls = {
        'COMMITTED': 'committed',
        'ROLLED_BACK': 'rolled_back',
        'FAILED': 'failed',
    }[status] || 'failed';
    return `<span class="status-badge ${cls}">${status}</span>`;
}

let countdownInterval = null;

function startCountdown(seconds, resultDiv) {
    let remaining = seconds;
    const msg = document.createElement('div');
    msg.id = 'countdown-msg';
    msg.style.cssText = 'padding:1rem; background:#e8eaf6; border-radius:6px; margin-top:0.5rem; text-align:center; font-size:1.1rem;';
    msg.innerHTML = `Puede detener un nodo ahora — <strong>${remaining}s</strong> restantes`;
    resultDiv.appendChild(msg);
    countdownInterval = setInterval(() => {
        remaining--;
        if (remaining <= 0) {
            clearInterval(countdownInterval);
            msg.innerHTML = 'Reanudando...';
            return;
        }
        msg.innerHTML = `Puede detener un nodo ahora — <strong>${remaining}s</strong> restantes`;
    }, 1000);
}

function stopCountdown() {
    if (countdownInterval) {
        clearInterval(countdownInterval);
        countdownInterval = null;
    }
    const msg = document.getElementById('countdown-msg');
    if (msg) msg.remove();
}

async function ejecutarTransferencia(e) {
    e.preventDefault();
    const btn = document.getElementById('btn-transferir');
    const resultDiv = document.getElementById('transfer-result');
    btn.disabled = true;
    btn.textContent = 'Transfiriendo...';
    resultDiv.innerHTML = '<p>Ejecutando protocolo 2PC...</p>';

    const delay = parseFloat(document.getElementById('delay').value) || 0;
    const payload = {
        origen: document.getElementById('origen').value,
        destino: document.getElementById('destino').value,
        producto: document.getElementById('producto').value,
        cantidad: parseInt(document.getElementById('cantidad').value, 10),
        delay: delay,
    };

    if (delay > 0) {
        startCountdown(delay, resultDiv);
    }

    try {
        const res = await fetch('/transferir', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload),
        });
        stopCountdown();
        const data = await res.json();

        if (!res.ok) {
            resultDiv.innerHTML = `
                <div style="padding: 1rem; background: #ffebee; border-radius: 6px;">
                    <strong>Error:</strong> ${data.detail || 'Error desconocido'}
                </div>
            `;
            return;
        }

        resultDiv.innerHTML = `
            <div style="margin-bottom: 1rem;">
                ${renderStatusBadge(data.status)}
                <span style="margin-left: 0.5rem; font-size: 0.875rem; color: #666;">
                    Txn: ${data.txn_id.slice(0, 8)}...
                </span>
            </div>
            <div style="font-size: 0.875rem; margin-bottom: 0.5rem;">
                <strong>${data.producto}</strong>: ${data.origen} → ${data.destino} (${data.cantidad} und.)
            </div>
            ${data.stock_origen_despues !== null ? `
                <div style="font-size: 0.875rem; color: #666;">
                    Stock después: ${data.origen} = ${data.stock_origen_despues},
                    ${data.destino} = ${data.stock_destino_despues}
                </div>
            ` : ''}
            <div class="timeline">
                ${renderTimeline(data.log)}
            </div>
        `;
        cargarInventario();
        cargarLog();
    } catch (err) {
        stopCountdown();
        resultDiv.innerHTML = `
            <div style="padding: 1rem; background: #ffebee; border-radius: 6px;">
                <strong>Error de red:</strong> ${err.message}
            </div>
        `;
    } finally {
        btn.disabled = false;
        btn.textContent = 'Transferir';
    }
}
