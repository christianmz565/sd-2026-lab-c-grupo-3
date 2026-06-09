async function cargarLog() {
    try {
        const result = await safeFetch(`${window.API_BASE}/log`);
        if (!result.ok) throw new Error(result.data?.detail || result.data || 'Error desconocido');
        const data = result.data;
        const list = document.getElementById('log-list');
        if (data.entries.length === 0) {
            list.innerHTML = 'Sin eventos registrados.';
            return;
        }
        list.innerHTML = '';
        for (const entry of data.entries.slice().reverse()) {
            const div = document.createElement('div');
            div.className = 'log-entry';
            const ts = new Date(entry.timestamp * 1000).toLocaleTimeString();
            div.innerHTML = `
                <span class="ts">[${ts}]</span>
                <span class="fase">${entry.fase}</span>
                ${entry.nodo ? `<span>(${entry.nodo})</span>` : ''}
                <span>${entry.detalle}</span>
            `;
            list.appendChild(div);
        }
    } catch (e) {
        console.error('Error cargando log:', e);
    }
}
