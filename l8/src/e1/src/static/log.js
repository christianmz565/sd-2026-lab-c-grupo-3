async function cargarLog() {
    try {
        const res = await fetch('/log');
        const data = await res.json();
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
