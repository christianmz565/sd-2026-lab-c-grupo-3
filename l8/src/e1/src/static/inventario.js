let inventarioCache = [];

async function cargarInventario() {
    try {
        const result = await safeFetch(`${window.API_BASE}/inventario`);
        if (!result.ok) throw new Error(result.data?.detail || result.data || 'Error desconocido');
        const data = result.data;
        inventarioCache = data.inventario;
        const productos = [...new Set(inventarioCache.map(r => r.producto))].sort();
        const tbody = document.getElementById('inventario-body');
        tbody.innerHTML = '';
        for (const prod of productos) {
            const stocks = { arequipa: 0, lima: 0, cusco: 0 };
            for (const row of inventarioCache) {
                if (row.producto === prod) stocks[row.almacen] = row.stock;
            }
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${prod}</td>
                <td>${stocks.arequipa}</td>
                <td>${stocks.lima}</td>
                <td>${stocks.cusco}</td>
            `;
            tbody.appendChild(tr);
        }
    } catch (e) {
        console.error('Error cargando inventario:', e);
    }
}
