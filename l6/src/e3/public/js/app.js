const API = "/graphql";

// ============================================
// ESTADO
// ============================================
let books = [];
let selectedId = null;

// ============================================
// GraphQL Helper
// ============================================
async function gql(query, variables = {}) {
  const res = await fetch(API, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ query, variables }),
  });
  const json = await res.json();
  if (json.errors) throw new Error(json.errors.map((e) => e.message).join(", "));
  return json.data;
}

// ============================================
// DOM READY
// ============================================
document.addEventListener("DOMContentLoaded", () => {
  fetchBooks();
  setupNav();
  setupSearch();
  setupForm();
});

// ============================================
// NAVEGACION
// ============================================
function setupNav() {
  document.querySelectorAll(".nav-item[data-section]").forEach((item) => {
    item.addEventListener("click", (e) => {
      e.preventDefault();
      openSection(item.dataset.section);
    });
  });
}

function openSection(name) {
  document.querySelectorAll(".nav-item").forEach((n) => n.classList.remove("active"));
  document.querySelector(`.nav-item[data-section="${name}"]`)?.classList.add("active");

  ["coleccion", "consola", "comparativa"].forEach((s) => {
    const sec = document.getElementById(`sec-${s}`);
    if (sec) sec.classList.toggle("hidden", s !== name);
  });
}

// ============================================
// BUSQUEDA
// ============================================
function setupSearch() {
  let timeout;
  document.getElementById("search-input").addEventListener("input", (e) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => renderBooks(e.target.value.toLowerCase().trim()), 200);
  });
}

// ============================================
// FETCH LIBROS
// ============================================
async function fetchBooks() {
  showLoading(true);
  try {
    const data = await gql(`{ books { id title author isbn description imageUrl } }`);
    books = data.books;
    renderBooks();
    updateStats();
  } catch (e) {
    showToast("Error al cargar libros: " + e.message, "danger");
  } finally {
    showLoading(false);
  }
}

// ============================================
// RENDER LIBROS
// ============================================
function renderBooks(query = "") {
  const grid = document.getElementById("books-grid");
  const empty = document.getElementById("empty-state");
  const loading = document.getElementById("loading-state");

  const filtered = books.filter((b) => {
    if (!query) return true;
    return (
      b.title.toLowerCase().includes(query) ||
      b.author.toLowerCase().includes(query) ||
      b.isbn.toLowerCase().includes(query)
    );
  });

  loading.classList.add("hidden");

  if (filtered.length === 0) {
    grid.classList.add("hidden");
    empty.classList.remove("hidden");
    return;
  }

  empty.classList.add("hidden");
  grid.classList.remove("hidden");

  const gradients = [
    "linear-gradient(135deg, #ec4899 0%, #8b5cf6 100%)",
    "linear-gradient(135deg, #3b82f6 0%, #06b6d4 100%)",
    "linear-gradient(135deg, #10b981 0%, #059669 100%)",
    "linear-gradient(135deg, #f59e0b 0%, #d97706 100%)",
    "linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%)",
  ];

  grid.innerHTML = filtered
    .map((b, i) => {
      const grad = gradients[i % gradients.length];
      const cover = b.imageUrl
        ? `<img src="${b.imageUrl}" alt="${b.title}" style="width:100%;height:100%;object-fit:cover;" onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
           <div class="card-cover" style="background:${grad};display:none;position:absolute;inset:0;">
             <div class="card-cover-content"><div class="card-cover-tag">${b.isbn}</div><div class="card-cover-title">${b.title}</div></div>
           </div>`
        : `<div class="card-cover" style="background:${grad};"><div class="card-cover-content"><div class="card-cover-tag">${b.isbn}</div><div class="card-cover-title">${b.title}</div></div></div>`;

      return `
      <div class="card" onclick="openDetail('${b.id}')">
        <div style="height:180px;position:relative;overflow:hidden;">${cover}</div>
        <div class="card-body">
          <div class="card-author">${b.author}</div>
          <div class="card-meta">
            <span class="card-isbn">${b.isbn}</span>
            <button class="btn btn-icon btn-danger btn-sm" onclick="event.stopPropagation();deleteBook('${b.id}')" title="Eliminar">
              <i class="fa-solid fa-trash"></i>
            </button>
          </div>
        </div>
      </div>`;
    })
    .join("");
}

// ============================================
// STATS
// ============================================
function updateStats() {
  document.getElementById("stat-total").textContent = books.length;
  const autores = new Set(books.map((b) => b.author));
  document.getElementById("stat-autores").textContent = autores.size;
}

// ============================================
// LOADING
// ============================================
function showLoading(show) {
  document.getElementById("loading-state").classList.toggle("hidden", !show);
  document.getElementById("books-grid").classList.toggle("hidden", show);
}

// ============================================
// MODAL: CREAR/EDITAR
// ============================================
function openModal(bookId = null) {
  const modal = document.getElementById("book-modal");
  const form = document.getElementById("book-form");
  const title = document.getElementById("modal-title");

  form.reset();
  document.getElementById("input-id").value = "";

  if (bookId) {
    const book = books.find((b) => b.id === bookId);
    if (book) {
      document.getElementById("input-id").value = book.id;
      document.getElementById("input-title").value = book.title;
      document.getElementById("input-author").value = book.author;
      document.getElementById("input-isbn").value = book.isbn;
      document.getElementById("input-description").value = book.description || "";
      document.getElementById("input-imageUrl").value = book.imageUrl || "";
      title.textContent = "Editar Libro";
    }
  } else {
    title.textContent = "Registrar Nuevo Libro";
  }

  modal.classList.remove("hidden");
}

function closeModal() {
  document.getElementById("book-modal").classList.add("hidden");
}

function setupForm() {
  document.getElementById("book-form").addEventListener("submit", (e) => {
    e.preventDefault();
    submitBook();
  });
}

async function submitBook() {
  const id = document.getElementById("input-id").value;
  const input = {
    title: document.getElementById("input-title").value,
    author: document.getElementById("input-author").value,
    isbn: document.getElementById("input-isbn").value,
    description: document.getElementById("input-description").value || undefined,
    imageUrl: document.getElementById("input-imageUrl").value || undefined,
  };

  try {
    if (id) {
      await gql(
        `mutation($id: ID!, $input: UpdateBookInput!) { updateBook(id: $id, input: $input) { id title } }`,
        { id, input }
      );
      showToast("Libro actualizado correctamente", "success");
    } else {
      await gql(
        `mutation($input: CreateBookInput!) { createBook(input: $input) { id title } }`,
        { input }
      );
      showToast("Libro registrado correctamente", "success");
    }
    closeModal();
    fetchBooks();
  } catch (e) {
    showToast("Error: " + e.message, "danger");
  }
}

// ============================================
// DETALLE
// ============================================
async function openDetail(id) {
  selectedId = id;
  const modal = document.getElementById("detail-modal");
  const body = document.getElementById("detail-body");

  body.innerHTML = '<div class="loading-state"><div class="spinner"></div><p>Cargando...</p></div>';
  modal.classList.remove("hidden");

  try {
    const data = await gql(
      `query($id: ID!) { book(id: $id) { id title author isbn description imageUrl } }`,
      { id }
    );
    const b = data.book;
    if (!b) {
      body.innerHTML = '<p class="text-center">Libro no encontrado.</p>';
      return;
    }

    body.innerHTML = `
      <div style="display:flex;gap:20px;flex-wrap:wrap;">
        <div style="flex:1;min-width:200px;">
          <div class="form-group"><label>Titulo</label><div style="font-size:16px;font-weight:700;">${b.title}</div></div>
          <div class="form-group"><label>Autor</label><div>${b.author}</div></div>
          <div class="form-group"><label>ISBN</label><div style="font-family:var(--font-mono);font-size:13px;">${b.isbn}</div></div>
          ${b.description ? `<div class="form-group"><label>Descripcion</label><div style="color:var(--text-secondary);font-size:13px;">${b.description}</div></div>` : ""}
          <div class="form-group"><label>ID</label><div style="font-family:var(--font-mono);font-size:12px;color:var(--text-muted);">${b.id}</div></div>
        </div>
      </div>`;

    document.getElementById("btn-delete-detail").onclick = () => {
      if (confirm(`Eliminar "${b.title}"?`)) {
        deleteBook(b.id);
        closeDetail();
      }
    };
  } catch (e) {
    body.innerHTML = `<p class="text-center" style="color:var(--danger);">${e.message}</p>`;
  }
}

function closeDetail() {
  document.getElementById("detail-modal").classList.add("hidden");
  selectedId = null;
}

// ============================================
// ELIMINAR
// ============================================
async function deleteBook(id) {
  try {
    await gql(`mutation($id: ID!) { deleteBook(id: $id) }`, { id });
    showToast("Libro eliminado", "success");
    fetchBooks();
  } catch (e) {
    showToast("Error: " + e.message, "danger");
  }
}

// ============================================
// CONSOLA GRAPHQL
// ============================================
const presets = {
  listar: `{ books {\n  id\n  title\n  author\n  isbn\n  description\n} }`,
  crear: `mutation {\n  createBook(input: {\n    title: "Nuevo Libro"\n    author: "Autor"\n    isbn: "978-1234567890"\n  }) {\n    id\n    title\n    author\n  }\n}`,
  eliminar: `mutation {\n  deleteBook(id: "1")\n}`,
};

function loadPreset(name) {
  document.getElementById("gql-editor").value = presets[name] || "";
}

async function executeGql() {
  const query = document.getElementById("gql-editor").value.trim();
  const result = document.getElementById("gql-result");

  if (!query) return;

  result.textContent = "Ejecutando...";
  try {
    const data = await gql(query);
    result.textContent = JSON.stringify(data, null, 2);
  } catch (e) {
    result.textContent = JSON.stringify({ error: e.message }, null, 2);
  }
}

// ============================================
// TOAST
// ============================================
function showToast(message, type = "info") {
  const container = document.getElementById("toast-container");
  const toast = document.createElement("div");
  toast.className = `toast ${type}`;

  const icons = { success: "fa-check-circle", danger: "fa-exclamation-circle", info: "fa-info-circle" };
  toast.innerHTML = `<i class="fa-solid ${icons[type] || icons.info}"></i><span>${message}</span>`;

  container.appendChild(toast);
  setTimeout(() => {
    toast.style.animation = "slideIn 0.3s ease reverse forwards";
    setTimeout(() => toast.remove(), 300);
  }, 3500);
}
