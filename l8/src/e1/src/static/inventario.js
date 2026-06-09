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
        let stockTotal = 0;
        for (const prod of productos) {
            const stocks = { arequipa: 0, lima: 0, cusco: 0 };
            for (const row of inventarioCache) {
                if (row.producto === prod) { stocks[row.almacen] = row.stock; stockTotal += row.stock; }
            }
            const tr = document.createElement('tr');
            const lo = 5;
            tr.innerHTML = `
                <td>${prod}</td>
                <td><span class="sp${stocks.arequipa <= lo ? ' lo' : ''}">${stocks.arequipa}</span></td>
                <td><span class="sp${stocks.lima <= lo ? ' lo' : ''}">${stocks.lima}</span></td>
                <td><span class="sp${stocks.cusco <= lo ? ' lo' : ''}">${stocks.cusco}</span></td>
            `;
            tbody.appendChild(tr);
        }
        document.getElementById('kpi-prod-val').textContent = productos.length;
        document.getElementById('kpi-stock-val').textContent = stockTotal.toLocaleString();
        renderInvModal(productos);
    } catch (e) {
        console.error('Error cargando inventario:', e);
    }
}

function renderInvModal(productos) {
    const tbody = document.getElementById('modal-inv-body');
    if (!tbody) return;
    tbody.innerHTML = '';
    for (const prod of productos) {
        const stocks = { arequipa: 0, lima: 0, cusco: 0 };
        for (const row of inventarioCache) {
            if (row.producto === prod) stocks[row.almacen] = row.stock;
        }
        const total = stocks.arequipa + stocks.lima + stocks.cusco;
        const lo = 5;
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${prod}</td>
            <td><span class="sp${stocks.arequipa <= lo ? ' lo' : ''}">${stocks.arequipa}</span></td>
            <td><span class="sp${stocks.lima <= lo ? ' lo' : ''}">${stocks.lima}</span></td>
            <td><span class="sp${stocks.cusco <= lo ? ' lo' : ''}">${stocks.cusco}</span></td>
            <td style="font-weight:600;color:var(--text)">${total}</td>
        `;
        tbody.appendChild(tr);
    }
}
