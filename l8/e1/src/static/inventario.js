async function cargarInventario() {
    try {
        const res = await fetch('/inventario');
        const data = await res.json();
        const inventario = data.inventario;
        const productos = [...new Set(inventario.map(r => r.producto))].sort();
        const tbody = document.getElementById('inventario-body');
        tbody.innerHTML = '';
        for (const prod of productos) {
            const stocks = { arequipa: 0, lima: 0, cusco: 0 };
            for (const row of inventario) {
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
