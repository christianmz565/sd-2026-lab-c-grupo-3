async function controlNodo(nombre, accion) {
    const btn = event.target;
    btn.disabled = true;
    try {
        const res = await fetch(`/nodos/${nombre}/${accion}`, { method: 'POST' });
        const data = await res.json();
        if (!res.ok) {
            alert(`Error: ${data.detail || 'Error desconocido'}`);
            return;
        }
        cargarSalud();
    } catch (e) {
        alert(`Error de red: ${e.message}`);
    } finally {
        btn.disabled = false;
    }
}
