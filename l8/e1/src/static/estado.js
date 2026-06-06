async function cargarSalud() {
    try {
        const res = await fetch('/health');
        const data = await res.json();
        for (const nodo of ['arequipa', 'lima', 'cusco']) {
            const el = document.getElementById(`node-${nodo}`);
            const status = data[nodo];
            el.className = `node-card ${status === 'ok' ? 'ok' : 'down'}`;
            el.querySelector('.status').textContent = status === 'ok' ? 'Activo' : 'Caído';
        }
    } catch (e) {
        console.error('Error cargando salud:', e);
    }
}
