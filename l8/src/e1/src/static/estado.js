async function cargarSalud() {
    try {
        const result = await safeFetch(`${window.API_BASE}/health`);
        if (!result.ok) throw new Error(result.data?.detail || result.data || 'Error desconocido');
        const data = result.data;
        let activos = 0;
        for (const nodo of ['arequipa', 'lima', 'cusco']) {
            const el = document.getElementById(`node-${nodo}`);
            const status = data[nodo];
            const isOk = status === 'ok';
            if (isOk) activos++;
            el.className = `node-card ${isOk ? 'ok' : 'down'}`;
            el.querySelector('.node-st').textContent = isOk ? 'Activo' : 'Caído';
            el.querySelector('.node-icon').textContent = isOk ? '🟢' : '🔴';
        }
        document.getElementById('kpi-nodos-val').textContent = activos;
        renderNodosModal(data);
    } catch (e) {
        console.error('Error cargando salud:', e);
    }
}

function renderNodosModal(data) {
    const grid = document.getElementById('modal-nodes-grid');
    if (!grid) return;
    grid.innerHTML = '';
    for (const nodo of ['arequipa', 'lima', 'cusco']) {
        const isOk = data[nodo] === 'ok';
        const div = document.createElement('div');
        div.className = 'detail-stat';
        div.style.cursor = 'pointer';
        div.style.borderColor = isOk ? 'var(--green-b)' : 'var(--red-b)';
        div.innerHTML = `
            <div style="font-size:1.3rem;margin-bottom:0.25rem">${isOk ? '🟢' : '🔴'}</div>
            <div class="val" style="color:${isOk ? 'var(--green)' : 'var(--red)'}">${isOk ? 'OK' : 'DOWN'}</div>
            <div class="lbl">${nodo.charAt(0).toUpperCase() + nodo.slice(1)}</div>
        `;
        div.onclick = () => showNodeDetail(nodo, isOk);
        grid.appendChild(div);
    }
}

async function showNodeDetail(nodo, isOk) {
    const container = document.getElementById('modal-node-detail');
    container.innerHTML = '<div class="shimmer" style="height:50px;margin-top:0.6rem"></div>';
    try {
        const result = await safeFetch(`${window.API_BASE}/inventario`);
        if (!result.ok) throw new Error('Error cargando inventario');
        const items = result.data.inventario.filter(r => r.almacen === nodo);
        const total = items.reduce((s, r) => s + r.stock, 0);
        container.innerHTML = `
            <h4 style="font-size:0.8rem;margin-bottom:0.6rem;color:var(--text)">Inventario — ${nodo.charAt(0).toUpperCase() + nodo.slice(1)}</h4>
            <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:0.5rem;margin-bottom:0.6rem">
                <div class="detail-stat"><div class="val">${items.length}</div><div class="lbl">Productos</div></div>
                <div class="detail-stat"><div class="val">${total}</div><div class="lbl">Stock Total</div></div>
                <div class="detail-stat"><div class="val" style="color:${isOk?'var(--green)':'var(--red)'}">${isOk?'Activo':'Caído'}</div><div class="lbl">Estado</div></div>
            </div>
            <table class="detail-inv">
                <thead><tr><th>Producto</th><th>Stock</th></tr></thead>
                <tbody>${items.map(r => `<tr><td>${r.producto}</td><td style="text-align:center"><span class="sp${r.stock<=5?' lo':''}">${r.stock}</span></td></tr>`).join('')}</tbody>
            </table>
        `;
    } catch (e) {
        container.innerHTML = `<div style="color:var(--red);padding:0.6rem;font-size:0.8rem">Error: ${e.message}</div>`;
    }
}
