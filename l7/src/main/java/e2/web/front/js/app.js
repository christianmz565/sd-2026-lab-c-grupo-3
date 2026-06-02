/**
 * app.js
 * Main application controller for StoreSOAP product manager.
 * Uses API (mock-api.js) — swap API.* calls for real fetch/SOAP calls
 * once server.py is implemented.
 */

/* ═══════════════════════════════════════════════════════════════
   STATE
═══════════════════════════════════════════════════════════════ */
let allProducts = [];
let editMode = false;      // true = editing existing product
let editTarget = null;     // nombre of product being edited
let deleteTarget = null;   // nombre of product to delete
let buyTarget = null;      // item object for buy modal

/* ═══════════════════════════════════════════════════════════════
   EMOJI MAP — give products a fun icon
═══════════════════════════════════════════════════════════════ */
const EMOJI_MAP = {
  gaseosa: '🥤', galletas: '🍪', celular: '📱', auriculares: '🎧',
  mochila: '🎒', cuaderno: '📓', laptop: '💻', camisa: '👕',
  zapatos: '👟', libro: '📚', reloj: '⌚', tablet: '📲',
  cafe: '☕', chocolate: '🍫', leche: '🥛', pan: '🍞',
  arroz: '🍚', agua: '💧', jugo: '🧃', cerveza: '🍺',
};
function getEmoji(nombre) {
  const key = nombre.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
  for (const [k, v] of Object.entries(EMOJI_MAP)) {
    if (key.includes(k)) return v;
  }
  return '📦';
}

/* ═══════════════════════════════════════════════════════════════
   DOM REFS
═══════════════════════════════════════════════════════════════ */
const $ = id => document.getElementById(id);

const dom = {
  skeleton:     $('skeleton-grid'),
  grid:         $('products-grid'),
  emptyState:   $('empty-state'),
  searchInput:  $('search-input'),
  clearSearch:  $('clear-search'),
  stockFilter:  $('stock-filter'),
  btnRefresh:   $('btn-refresh'),

  // Stats
  statTotal:    $('stat-total'),
  statStock:    $('stat-stock'),
  statValue:    $('stat-value'),

  // Modals
  modalProduct: $('modal-product'),
  formProduct:  $('form-product'),
  modalTitle:   $('modal-product-title'),
  btnSubmitProduct: $('btn-submit-product'),
  btnSubmitLabel:   $('btn-submit-label'),
  spinnerProduct:   $('spinner-product'),
  inputNombre:  $('input-nombre'),
  inputCantidad:$('input-cantidad'),
  inputCosto:   $('input-costo'),
  errorNombre:  $('error-nombre'),
  errorCantidad:$('error-cantidad'),
  errorCosto:   $('error-costo'),

  modalBuy:     $('modal-buy'),
  formBuy:      $('form-buy'),
  buyProductName: $('buy-product-name'),
  buyStock:     $('buy-stock'),
  buyPrice:     $('buy-price'),
  buyTotal:     $('buy-total'),
  inputBuyCantidad: $('input-buy-cantidad'),
  errorBuyCantidad: $('error-buy-cantidad'),
  spinnerBuy:   $('spinner-buy'),

  modalDelete:  $('modal-delete'),
  deleteProductName: $('delete-product-name'),
  spinnerDelete:$('spinner-delete'),

  modalResult:  $('modal-result'),
  resultContent:$('result-content'),

  toastContainer: $('toast-container'),
  statusDot:    $('status-dot'),
  statusLabel:  $('status-label'),
};

/* ═══════════════════════════════════════════════════════════════
   TOAST NOTIFICATIONS
═══════════════════════════════════════════════════════════════ */
function showToast(message, type = 'info') {
  const icons = { success: '✅', error: '❌', info: 'ℹ️' };
  const toast = document.createElement('div');
  toast.className = `toast toast-${type}`;
  toast.innerHTML = `<span class="toast-icon">${icons[type]}</span><span>${message}</span>`;
  dom.toastContainer.appendChild(toast);
  setTimeout(() => {
    toast.classList.add('exit');
    toast.addEventListener('animationend', () => toast.remove());
  }, 3200);
}

/* ═══════════════════════════════════════════════════════════════
   MODAL HELPERS
═══════════════════════════════════════════════════════════════ */
function openModal(el) {
  el.classList.remove('hidden');
  document.body.style.overflow = 'hidden';
}
function closeModal(el) {
  el.classList.add('hidden');
  document.body.style.overflow = '';
}

// Close on overlay click
document.querySelectorAll('.modal-overlay').forEach(overlay => {
  overlay.addEventListener('click', e => {
    if (e.target === overlay) closeModal(overlay);
  });
});

// Close buttons
$('modal-product-close').addEventListener('click', () => closeModal(dom.modalProduct));
$('btn-cancel-product').addEventListener('click', () => closeModal(dom.modalProduct));
$('modal-buy-close').addEventListener('click', () => closeModal(dom.modalBuy));
$('btn-cancel-buy').addEventListener('click', () => closeModal(dom.modalBuy));
$('modal-delete-close').addEventListener('click', () => closeModal(dom.modalDelete));
$('btn-cancel-delete').addEventListener('click', () => closeModal(dom.modalDelete));
$('modal-result-close').addEventListener('click', () => closeModal(dom.modalResult));
$('btn-close-result').addEventListener('click', () => closeModal(dom.modalResult));

/* ═══════════════════════════════════════════════════════════════
   ESC KEY
═══════════════════════════════════════════════════════════════ */
document.addEventListener('keydown', e => {
  if (e.key === 'Escape') {
    [dom.modalProduct, dom.modalBuy, dom.modalDelete, dom.modalResult]
      .forEach(m => { if (!m.classList.contains('hidden')) closeModal(m); });
  }
});

/* ═══════════════════════════════════════════════════════════════
   HERO / STATS UPDATER
═══════════════════════════════════════════════════════════════ */
function updateHeroStats(products) {
  const total      = products.length;
  const totalUnits = products.reduce((s, p) => s + p.cantidad, 0);
  const totalVal   = products.reduce((s, p) => s + p.cantidad * p.costo, 0);

  animateNumber(dom.statTotal, total, 0);
  animateNumber(dom.statStock, totalUnits, 0);
  dom.statValue.textContent = `S/. ${totalVal.toLocaleString('es-PE', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}

function animateNumber(el, target, start) {
  const duration = 700;
  const startTime = performance.now();
  function step(now) {
    const progress = Math.min((now - startTime) / duration, 1);
    const ease = 1 - Math.pow(1 - progress, 3);
    el.textContent = Math.round(start + (target - start) * ease);
    if (progress < 1) requestAnimationFrame(step);
  }
  requestAnimationFrame(step);
}

/* ═══════════════════════════════════════════════════════════════
   STOCK BADGE
═══════════════════════════════════════════════════════════════ */
function stockBadge(cantidad) {
  if (cantidad === 0) return '<span class="card-badge-stock badge-out-stock">Sin Stock</span>';
  if (cantidad <= 3)  return '<span class="card-badge-stock badge-low-stock">Stock Bajo</span>';
  return '<span class="card-badge-stock badge-in-stock">Disponible</span>';
}

/* ═══════════════════════════════════════════════════════════════
   RENDER PRODUCTS
═══════════════════════════════════════════════════════════════ */
function renderProducts(products) {
  dom.grid.innerHTML = '';

  if (!products.length) {
    dom.grid.classList.add('hidden');
    dom.emptyState.classList.remove('hidden');
    return;
  }

  dom.emptyState.classList.add('hidden');
  dom.grid.classList.remove('hidden');

  products.forEach((p, i) => {
    const card = document.createElement('div');
    card.className = 'product-card';
    card.style.animationDelay = `${i * 0.06}s`;
    card.dataset.nombre = p.nombre;

    const outOfStock = p.cantidad === 0;

    card.innerHTML = `
      ${stockBadge(p.cantidad)}
      <div class="card-icon-wrap">${getEmoji(p.nombre)}</div>
      <div class="card-body">
        <div class="card-title">${p.nombre}</div>
        <div class="card-meta">
          <div class="meta-item">
            <span class="meta-label">Stock</span>
            <span class="meta-value">${p.cantidad} uds.</span>
          </div>
          <div class="meta-item">
            <span class="meta-label">Precio</span>
            <span class="meta-value price">S/. ${p.costo.toFixed(2)}</span>
          </div>
          <div class="meta-item">
            <span class="meta-label">Total Stock</span>
            <span class="meta-value">S/. ${(p.cantidad * p.costo).toFixed(2)}</span>
          </div>
        </div>
      </div>
      <div class="card-actions">
        <button class="action-btn action-buy" data-action="buy" data-nombre="${p.nombre}" ${outOfStock ? 'disabled title="Sin stock disponible"' : ''}>
          🛒 Comprar
        </button>
        <button class="action-btn action-edit" data-action="edit" data-nombre="${p.nombre}">
          ✏️ Editar
        </button>
        <button class="action-btn action-delete" data-action="delete" data-nombre="${p.nombre}">
          🗑️
        </button>
      </div>
    `;
    dom.grid.appendChild(card);
  });

  // Delegate card action events
  dom.grid.querySelectorAll('[data-action]').forEach(btn => {
    btn.addEventListener('click', handleCardAction);
  });
}

/* ═══════════════════════════════════════════════════════════════
   FILTER & SEARCH
═══════════════════════════════════════════════════════════════ */
function getFilteredProducts() {
  const query = dom.searchInput.value.trim().toLowerCase();
  const stockFilter = dom.stockFilter.value;
  return allProducts.filter(p => {
    const matchName = p.nombre.toLowerCase().includes(query);
    const matchStock = stockFilter === 'all'
      ? true
      : stockFilter === 'in-stock' ? p.cantidad > 0 : p.cantidad === 0;
    return matchName && matchStock;
  });
}

function applyFilters() {
  renderProducts(getFilteredProducts());
  dom.clearSearch.classList.toggle('visible', dom.searchInput.value.length > 0);
}

dom.searchInput.addEventListener('input', applyFilters);
dom.stockFilter.addEventListener('change', applyFilters);
dom.clearSearch.addEventListener('click', () => {
  dom.searchInput.value = '';
  applyFilters();
});

/* ═══════════════════════════════════════════════════════════════
   LOAD PRODUCTS (getItems)
═══════════════════════════════════════════════════════════════ */
async function loadProducts(showSkeleton = true) {
  if (showSkeleton) {
    dom.skeleton.classList.remove('hidden');
    dom.grid.classList.add('hidden');
    dom.emptyState.classList.add('hidden');
  }

  try {
    allProducts = await API.getItems();
    updateHeroStats(allProducts);
    applyFilters();
    setConnectionStatus(API.getMode());
  } catch (err) {
    showToast('Error al cargar productos: ' + err.message, 'error');
    setConnectionStatus('mock');
  } finally {
    dom.skeleton.classList.add('hidden');
  }
}

/* ═══════════════════════════════════════════════════════════════
   CONNECTION STATUS
═══════════════════════════════════════════════════════════════ */
function setConnectionStatus(mode) {
  dom.statusDot.className = 'status-dot';
  if (mode === 'soap') {
    dom.statusDot.classList.add('connected');
    dom.statusLabel.textContent = 'SOAP ✓';
  } else if (mode === 'mock') {
    // No extra class needed — 'status-dot' alone renders the amber warning color
    dom.statusLabel.textContent = 'Mock (sin servidor)';
  } else {
    dom.statusLabel.textContent = 'Conectando...';
  }
}

/* ═══════════════════════════════════════════════════════════════
   REFRESH
═══════════════════════════════════════════════════════════════ */
dom.btnRefresh.addEventListener('click', () => loadProducts(true));

/* ═══════════════════════════════════════════════════════════════
   CARD ACTIONS HANDLER
═══════════════════════════════════════════════════════════════ */
function handleCardAction(e) {
  const btn = e.currentTarget;
  const action = btn.dataset.action;
  const nombre = btn.dataset.nombre;
  const product = allProducts.find(p => p.nombre === nombre);

  if (action === 'buy')    openBuyModal(product);
  if (action === 'edit')   openEditModal(product);
  if (action === 'delete') openDeleteModal(product);
}

/* ═══════════════════════════════════════════════════════════════
   ADD / EDIT PRODUCT MODAL
═══════════════════════════════════════════════════════════════ */
function openAddModal() {
  editMode = false;
  editTarget = null;
  dom.modalTitle.textContent = 'Nuevo Producto';
  dom.btnSubmitLabel.textContent = 'Guardar Producto';
  dom.formProduct.reset();
  clearFormErrors();
  dom.inputNombre.disabled = false;
  openModal(dom.modalProduct);
  setTimeout(() => dom.inputNombre.focus(), 100);
}

function openEditModal(product) {
  editMode = true;
  editTarget = product.nombre;
  dom.modalTitle.textContent = `Editar: ${product.nombre}`;
  dom.btnSubmitLabel.textContent = 'Actualizar Producto';
  dom.inputNombre.value = product.nombre;
  dom.inputNombre.disabled = true; // nombre is the key — can't change
  dom.inputCantidad.value = product.cantidad;
  dom.inputCosto.value = product.costo;
  clearFormErrors();
  openModal(dom.modalProduct);
  setTimeout(() => dom.inputCantidad.focus(), 100);
}

function clearFormErrors() {
  [dom.errorNombre, dom.errorCantidad, dom.errorCosto].forEach(el => el.textContent = '');
  [dom.inputNombre, dom.inputCantidad, dom.inputCosto].forEach(el => el.classList.remove('error'));
}

function validateProductForm() {
  let valid = true;
  const nombre   = dom.inputNombre.value.trim();
  const cantidad = parseFloat(dom.inputCantidad.value);
  const costo    = parseFloat(dom.inputCosto.value);

  if (!editMode && !nombre) {
    dom.errorNombre.textContent = 'El nombre es requerido.';
    dom.inputNombre.classList.add('error');
    valid = false;
  }
  if (isNaN(cantidad) || cantidad < 1) {
    dom.errorCantidad.textContent = 'Ingrese una cantidad mayor a 0.';
    dom.inputCantidad.classList.add('error');
    valid = false;
  }
  if (isNaN(costo) || costo <= 0) {
    dom.errorCosto.textContent = 'Ingrese un costo mayor a 0.';
    dom.inputCosto.classList.add('error');
    valid = false;
  }
  return valid;
}

dom.formProduct.addEventListener('submit', async e => {
  e.preventDefault();
  if (!validateProductForm()) return;

  const cantidad = parseInt(dom.inputCantidad.value);
  const costo    = parseFloat(dom.inputCosto.value);

  // Loading state
  dom.spinnerProduct.classList.remove('hidden');
  dom.btnSubmitProduct.disabled = true;

  try {
    if (editMode) {
      const ok = await API.setItem(editTarget, cantidad, costo);
      if (ok) {
        showToast(`Producto "${editTarget}" actualizado.`, 'success');
        closeModal(dom.modalProduct);
        await loadProducts(false);
      } else {
        showToast('No se pudo actualizar el producto.', 'error');
      }
    } else {
      const nombre = dom.inputNombre.value.trim();
      const ok = await API.addItem({ nombre, cantidad, costo });
      if (ok) {
        showToast(`Producto "${nombre}" agregado exitosamente.`, 'success');
        closeModal(dom.modalProduct);
        await loadProducts(false);
      } else {
        dom.errorNombre.textContent = 'El nombre ya existe o los datos son inválidos.';
        dom.inputNombre.classList.add('error');
      }
    }
  } catch (err) {
    showToast('Error: ' + err.message, 'error');
  } finally {
    dom.spinnerProduct.classList.add('hidden');
    dom.btnSubmitProduct.disabled = false;
  }
});

// Nav + empty state triggers
$('btn-add-product').addEventListener('click', openAddModal);
$('btn-add-empty').addEventListener('click', openAddModal);

/* ═══════════════════════════════════════════════════════════════
   BUY MODAL
═══════════════════════════════════════════════════════════════ */
function openBuyModal(product) {
  buyTarget = product;
  dom.buyProductName.textContent = product.nombre;
  dom.buyStock.textContent = product.cantidad;
  dom.buyPrice.textContent = `S/. ${product.costo.toFixed(2)}`;
  dom.inputBuyCantidad.value = '';
  dom.inputBuyCantidad.max = product.cantidad;
  dom.buyTotal.textContent = 'S/. 0.00';
  dom.errorBuyCantidad.textContent = '';
  openModal(dom.modalBuy);
  setTimeout(() => dom.inputBuyCantidad.focus(), 100);
}

// Live total preview
dom.inputBuyCantidad.addEventListener('input', () => {
  const qty = parseInt(dom.inputBuyCantidad.value) || 0;
  if (buyTarget && qty > 0) {
    dom.buyTotal.textContent = `S/. ${(qty * buyTarget.costo).toFixed(2)}`;
  } else {
    dom.buyTotal.textContent = 'S/. 0.00';
  }
  dom.errorBuyCantidad.textContent = '';
});

dom.formBuy.addEventListener('submit', async e => {
  e.preventDefault();
  const qty = parseInt(dom.inputBuyCantidad.value);
  if (!qty || qty < 1) {
    dom.errorBuyCantidad.textContent = 'Ingrese una cantidad válida.';
    return;
  }
  if (qty > buyTarget.cantidad) {
    dom.errorBuyCantidad.textContent = `Stock máximo: ${buyTarget.cantidad}.`;
    return;
  }

  $('spinner-buy').classList.remove('hidden');
  $('btn-submit-buy').disabled = true;

  try {
    const result = await API.buyItem(buyTarget.nombre, qty);
    closeModal(dom.modalBuy);

    // Show result in result modal
    dom.resultContent.innerHTML = `
      <strong>✅ Compra realizada</strong><br /><br />
      ${result.replace(/\s/g, '&nbsp;')}
    `;
    openModal(dom.modalResult);
    await loadProducts(false);
    showToast('Compra realizada exitosamente.', 'success');
  } catch (err) {
    showToast('Error al comprar: ' + err.message, 'error');
  } finally {
    $('spinner-buy').classList.add('hidden');
    $('btn-submit-buy').disabled = false;
  }
});

/* ═══════════════════════════════════════════════════════════════
   DELETE MODAL
═══════════════════════════════════════════════════════════════ */
function openDeleteModal(product) {
  deleteTarget = product.nombre;
  dom.deleteProductName.textContent = product.nombre;
  openModal(dom.modalDelete);
}

$('btn-confirm-delete').addEventListener('click', async () => {
  if (!deleteTarget) return;

  dom.spinnerDelete.classList.remove('hidden');
  $('btn-confirm-delete').disabled = true;

  try {
    const ok = await API.deleteItem(deleteTarget);
    closeModal(dom.modalDelete);
    if (ok) {
      showToast(`Producto "${deleteTarget}" eliminado correctamente.`, 'success');
      await loadProducts(false);
    } else {
      showToast('No se pudo eliminar el producto.', 'error');
    }
  } catch (err) {
    showToast('Error: ' + err.message, 'error');
  } finally {
    dom.spinnerDelete.classList.add('hidden');
    $('btn-confirm-delete').disabled = false;
    deleteTarget = null;
  }
});

/* ═══════════════════════════════════════════════════════════════
   NAVBAR SCROLL EFFECT
═══════════════════════════════════════════════════════════════ */
window.addEventListener('scroll', () => {
  $('navbar').classList.toggle('scrolled', window.scrollY > 20);
});

/* ═══════════════════════════════════════════════════════════════
   BOOT
═══════════════════════════════════════════════════════════════ */
(async () => {
  // Prueba si el servidor SOAP está vivo; actualiza el indicador de estado
  const mode = await API.init(setConnectionStatus);
  if (mode === 'mock') {
    showToast('Servidor SOAP no disponible. Usando datos de prueba.', 'info');
  }
  await loadProducts(true);
})();
