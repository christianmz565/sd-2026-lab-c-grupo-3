async function cargarLog() {
    try {
        const result = await safeFetch(`${window.API_BASE}/log`);
        if (!result.ok) throw new Error(result.data?.detail || result.data || 'Error desconocido');
        const data = result.data;
        document.getElementById('kpi-events-val').textContent = data.entries.length;
        const list = document.getElementById('log-list');
        if (data.entries.length === 0) {
            list.innerHTML = '<div style="text-align:center;padding:2rem;color:var(--muted);font-size:0.8rem">Sin eventos registrados</div>';
            renderLogModal([]);
            return;
        }
        const entries = data.entries.slice().reverse();
        list.innerHTML = '';
        for (const entry of entries.slice(0, 20)) {
            const div = document.createElement('div');
            div.className = 'log-row';
            const ts = new Date(entry.timestamp * 1000).toLocaleTimeString('es-PE', { hour12: false });
            div.innerHTML = `
                <span class="log-ts">[${ts}]</span>
                <span class="log-fa">${entry.fase}</span>
                ${entry.nodo ? `<span class="log-no">(${entry.nodo})</span>` : ''}
                <span class="log-de">${entry.detalle}</span>
            `;
            list.appendChild(div);
        }
        renderLogModal(entries);
    } catch (e) {
        console.error('Error cargando log:', e);
    }
}

function renderLogModal(entries) {
    const body = document.getElementById('modal-log-body');
    if (!body) return;
    if (entries.length === 0) {
        body.innerHTML = '<div style="text-align:center;padding:2rem;color:var(--muted)">Sin eventos</div>';
        return;
    }
    body.innerHTML = '';
    for (const entry of entries) {
        const div = document.createElement('div');
        div.className = 'log-row';
        const ts = new Date(entry.timestamp * 1000).toLocaleTimeString('es-PE', { hour12: false });
        div.innerHTML = `
            <span class="log-ts">[${ts}]</span>
            <span class="log-fa">${entry.fase}</span>
            ${entry.nodo ? `<span class="log-no">(${entry.nodo})</span>` : ''}
            <span class="log-de">${entry.detalle}</span>
        `;
        body.appendChild(div);
    }
}
