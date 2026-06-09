async function controlNodo(nombre, accion) {
    const btn = event.target;
    btn.disabled = true;
    try {
        const result = await safeFetch(`${window.API_BASE}/nodos/${nombre}/${accion}`, { method: 'POST' });
        if (!result.ok) {
            alert(`Error: ${result.data?.detail || result.data || 'Error desconocido'}`);
            return;
        }
        await Promise.all([cargarSalud(), cargarInventario()]);
        cargarProductos();
    } catch (e) {
        alert(`Error: ${e.message}`);
    } finally {
        btn.disabled = false;
    }
}
