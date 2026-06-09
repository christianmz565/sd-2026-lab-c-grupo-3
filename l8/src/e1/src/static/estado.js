async function cargarSalud() {
    try {
        const result = await safeFetch(`${window.API_BASE}/health`);
        if (!result.ok) throw new Error(result.data?.detail || result.data || 'Error desconocido');
        const data = result.data;
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
