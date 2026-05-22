// Estado de la Aplicación
let appState = {
    books: [],
    selectedBookId: null,
    searchQuery: "",
    imageSourceMode: "file" // "file" o "url"
};

// Endpoints
const API_URL = "/api/books";

// Gradientes deterministas para libros sin portada
const COVER_GRADIENTS = [
    'linear-gradient(135deg, #6366f1 0%, #a855f7 100%)', // Índigo -> Púrpura
    'linear-gradient(135deg, #3b82f6 0%, #06b6d4 100%)', // Azul -> Cian
    'linear-gradient(135deg, #10b981 0%, #059669 100%)', // Esmeralda -> Verde
    'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)', // Ámbar -> Naranja
    'linear-gradient(135deg, #ec4899 0%, #be185d 100%)', // Rosa -> Clavel
    'linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%)'  // Violeta -> Violeta Oscuro
];

function getCoverGradient(title) {
    let hash = 0;
    for (let i = 0; i < title.length; i++) {
        hash = title.charCodeAt(i) + ((hash << 5) - hash);
    }
    const index = Math.abs(hash) % COVER_GRADIENTS.length;
    return COVER_GRADIENTS[index];
}

// Elementos del DOM
const elements = {
    booksGrid: document.getElementById("books-grid"),
    loadingState: document.getElementById("loading-state"),
    emptyState: document.getElementById("empty-state"),
    booksCountBadge: document.getElementById("books-count-badge"),
    searchInput: document.getElementById("search-input"),
    
    // Modales
    addBookModal: document.getElementById("add-book-modal"),
    bookDetailModal: document.getElementById("book-detail-modal"),
    modalFormTitle: document.getElementById("modal-form-title"),
    
    // Formularios e Inputs
    addBookForm: document.getElementById("add-book-form"),
    inputBookId: document.getElementById("input-book-id"),
    inputTitle: document.getElementById("input-title"),
    inputAuthor: document.getElementById("input-author"),
    inputIsbn: document.getElementById("input-isbn"),
    inputDescription: document.getElementById("input-description"),
    
    // Pestañas de Imagen
    tabBtnFile: document.getElementById("tab-btn-file"),
    tabBtnUrl: document.getElementById("tab-btn-url"),
    imageUploadWrapper: document.getElementById("image-upload-wrapper"),
    imageUrlWrapper: document.getElementById("image-url-wrapper"),
    
    // Inputs de Imagen y Previsualizaciones
    inputImage: document.getElementById("input-image"),
    inputImageUrl: document.getElementById("input-image-url"),
    uploadPlaceholder: document.getElementById("upload-placeholder"),
    uploadPreviewContainer: document.getElementById("upload-preview-container"),
    uploadPreview: document.getElementById("upload-preview"),
    btnRemoveImage: document.getElementById("btn-remove-image"),
    
    urlPreviewContainer: document.getElementById("url-preview-container"),
    urlPreview: document.getElementById("url-preview"),
    btnRemoveUrl: document.getElementById("btn-remove-url"),
    
    submitBtnText: document.getElementById("submit-btn-text"),
    submitSpinner: document.getElementById("submit-spinner"),
    
    // Detalle de Libro
    detailContent: document.getElementById("detail-content"),
    btnDetailEdit: document.getElementById("btn-detail-edit"),
    btnDetailDelete: document.getElementById("btn-detail-delete"),
    
    // Botones de acción general
    btnOpenAddModal: document.getElementById("btn-open-add-modal"),
    btnEmptyAdd: document.getElementById("btn-empty-add"),
    btnCloseAddModal: document.getElementById("btn-close-add-modal"),
    btnCancelAdd: document.getElementById("btn-cancel-add"),
    btnCloseDetailModal: document.getElementById("btn-close-detail-modal"),
    btnCloseDetail: document.getElementById("btn-close-detail"),
    toastContainer: document.getElementById("toast-container")
};

// Inicialización de la App
document.addEventListener("DOMContentLoaded", () => {
    fetchBooks();
    setupEventListeners();
});

// Configuración de los escuchas de eventos
function setupEventListeners() {
    // Abrir/Cerrar Modal de Registro
    elements.btnOpenAddModal.addEventListener("click", () => openAddModal());
    elements.btnEmptyAdd.addEventListener("click", () => openAddModal());
    elements.btnCloseAddModal.addEventListener("click", closeAddModal);
    elements.btnCancelAdd.addEventListener("click", closeAddModal);
    
    // Cerrar Modal de Detalles
    elements.btnCloseDetailModal.addEventListener("click", closeDetailModal);
    elements.btnCloseDetail.addEventListener("click", closeDetailModal);
    
    // Filtro de Búsqueda (Debounce)
    let searchTimeout;
    elements.searchInput.addEventListener("input", (e) => {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => {
            appState.searchQuery = e.target.value.toLowerCase().trim();
            renderBooks();
        }, 200);
    });

    // Enviar Formulario
    elements.addBookForm.addEventListener("submit", handleFormSubmit);

    // Eventos de Pestañas de Origen de Imagen
    elements.tabBtnFile.addEventListener("click", () => setImageSourceMode("file"));
    elements.tabBtnUrl.addEventListener("click", () => setImageSourceMode("url"));

    // Funcionalidades de Subida de Archivos
    elements.imageUploadWrapper.addEventListener("click", (e) => {
        // Evitar que el click se propague si se presiona el botón quitar
        if (e.target.closest("#btn-remove-image")) return;
        elements.inputImage.click();
    });
    
    elements.inputImage.addEventListener("change", handleFileSelect);
    elements.btnRemoveImage.addEventListener("click", removeSelectedFile);

    // Eventos Drag and Drop
    ['dragenter', 'dragover'].forEach(eventName => {
        elements.imageUploadWrapper.addEventListener(eventName, (e) => {
            e.preventDefault();
            elements.imageUploadWrapper.style.borderColor = "var(--primary)";
            elements.imageUploadWrapper.style.backgroundColor = "rgba(99, 102, 241, 0.04)";
        }, false);
    });

    ['dragleave', 'drop'].forEach(eventName => {
        elements.imageUploadWrapper.addEventListener(eventName, (e) => {
            e.preventDefault();
            elements.imageUploadWrapper.style.borderColor = "var(--border-color)";
            elements.imageUploadWrapper.style.backgroundColor = "rgba(255, 255, 255, 0.01)";
        }, false);
    });

    elements.imageUploadWrapper.addEventListener('drop', (e) => {
        const dt = e.dataTransfer;
        const files = dt.files;
        if (files.length > 0) {
            elements.inputImage.files = files;
            handleFileSelect();
        }
    }, false);

    // Funcionalidades de URL de Imagen
    elements.inputImageUrl.addEventListener("input", handleUrlInput);
    elements.btnRemoveUrl.addEventListener("click", removeSelectedUrl);

    // Modales - Botón de Editar y Eliminar dentro de Detalles
    elements.btnDetailEdit.addEventListener("click", () => {
        if (appState.selectedBookId) {
            openEditModal(appState.selectedBookId);
        }
    });

    elements.btnDetailDelete.addEventListener("click", () => {
        if (appState.selectedBookId) {
            const book = appState.books.find(b => b.id === appState.selectedBookId);
            if (book && confirm(`¿Estás seguro de que deseas eliminar "${book.title}"?`)) {
                deleteBook(appState.selectedBookId);
            }
        }
    });

    // Cerrar modales haciendo click fuera
    window.addEventListener("click", (e) => {
        if (e.target === elements.addBookModal) closeAddModal();
        if (e.target === elements.bookDetailModal) closeDetailModal();
    });
}

// Alternar entre las pestañas de Subir Archivo y Dirección URL
function setImageSourceMode(mode) {
    appState.imageSourceMode = mode;
    if (mode === "file") {
        elements.tabBtnFile.classList.add("active");
        elements.tabBtnUrl.classList.remove("active");
        elements.imageUploadWrapper.classList.remove("hidden");
        elements.imageUrlWrapper.classList.add("hidden");
    } else {
        elements.tabBtnFile.classList.remove("active");
        elements.tabBtnUrl.classList.add("active");
        elements.imageUploadWrapper.classList.add("hidden");
        elements.imageUrlWrapper.classList.remove("hidden");
    }
}

// Cargar Libros de la API REST
async function fetchBooks() {
    showLoading(true);
    try {
        const response = await fetch(API_URL);
        if (!response.ok) {
            throw new Error(`El servidor respondió con código ${response.status}`);
        }
        appState.books = await response.json();
        renderBooks();
    } catch (error) {
        console.error("Error al cargar libros:", error);
        showToast("Error al cargar la colección de libros", "danger");
    } finally {
        showLoading(false);
    }
}

// Renderizar la rejilla de libros
function renderBooks() {
    const filteredBooks = appState.books.filter(book => {
        return book.title.toLowerCase().includes(appState.searchQuery) ||
               book.author.toLowerCase().includes(appState.searchQuery) ||
               book.isbn.toLowerCase().includes(appState.searchQuery);
    });

    elements.booksCountBadge.textContent = `${filteredBooks.length} Libro${filteredBooks.length === 1 ? '' : 's'}`;

    if (filteredBooks.length === 0) {
        elements.booksGrid.classList.add("hidden");
        elements.emptyState.classList.remove("hidden");
        return;
    }

    elements.emptyState.classList.add("hidden");
    elements.booksGrid.classList.remove("hidden");
    elements.booksGrid.innerHTML = "";

    filteredBooks.forEach(book => {
        const card = document.createElement("div");
        card.className = "book-card";
        
        let coverHtml = "";
        if (book.imageUrl) {
            coverHtml = `<img src="${book.imageUrl}" alt="${book.title}" class="book-cover" onerror="this.src=''; this.className='hidden'; this.nextElementSibling.classList.remove('hidden');">
                         <div class="fallback-cover hidden" style="background: ${getCoverGradient(book.title)}">
                             <div class="fallback-decorations">
                                 <span>Repositorio</span>
                                 <i class="fa-solid fa-bookmark"></i>
                             </div>
                             <div class="fallback-title">${book.title}</div>
                             <div class="fallback-author">${book.author}</div>
                         </div>`;
        } else {
            const gradient = getCoverGradient(book.title);
            coverHtml = `
                <div class="fallback-cover" style="background: ${gradient}">
                    <div class="fallback-decorations">
                        <span>Repositorio</span>
                        <i class="fa-solid fa-bookmark"></i>
                    </div>
                    <div class="fallback-title">${book.title}</div>
                    <div class="fallback-author">${book.author}</div>
                </div>
            `;
        }

        card.innerHTML = `
            <div class="book-cover-container">
                ${coverHtml}
            </div>
            <div class="book-details">
                <h3 class="book-title" title="${book.title}">${book.title}</h3>
                <p class="book-author" title="${book.author}">${book.author}</p>
                <div class="book-footer">
                    <span class="book-isbn">${book.isbn}</span>
                    <div class="card-actions">
                        <button class="btn-icon-danger btn-delete-card" data-id="${book.id}" title="Eliminar Libro">
                            <i class="fa-solid fa-trash-can"></i>
                        </button>
                    </div>
                </div>
            </div>
        `;

        // Abrir detalles del libro al hacer click en la tarjeta
        card.addEventListener("click", (e) => {
            if (e.target.closest(".btn-delete-card")) return;
            openDetailModal(book.id);
        });

        // Botón de eliminar en tarjeta
        const btnDelete = card.querySelector(".btn-delete-card");
        btnDelete.addEventListener("click", (e) => {
            e.stopPropagation();
            if (confirm(`¿Estás seguro de que deseas eliminar "${book.title}"?`)) {
                deleteBook(book.id);
            }
        });

        elements.booksGrid.appendChild(card);
    });
}

// Carga visual
function showLoading(show) {
    if (show) {
        elements.loadingState.classList.remove("hidden");
        elements.booksGrid.classList.add("hidden");
        elements.emptyState.classList.add("hidden");
    } else {
        elements.loadingState.classList.add("hidden");
    }
}

// Abrir Modal de Registro (Modo Creación)
function openAddModal() {
    elements.addBookForm.reset();
    elements.inputBookId.value = "";
    elements.modalFormTitle.textContent = "Registrar Nuevo Libro";
    elements.submitBtnText.textContent = "Guardar Libro";
    
    removeSelectedFile();
    removeSelectedUrl();
    setImageSourceMode("file");
    
    elements.addBookModal.classList.remove("hidden");
    document.body.style.overflow = "hidden";
}

// Abrir Modal de Edición (Modo Actualización)
function openEditModal(bookId) {
    const book = appState.books.find(b => b.id === bookId);
    if (!book) return;

    elements.inputBookId.value = book.id;
    elements.inputTitle.value = book.title;
    elements.inputAuthor.value = book.author;
    elements.inputIsbn.value = book.isbn;
    elements.inputDescription.value = book.description || "";
    
    elements.modalFormTitle.textContent = "Editar Libro";
    elements.submitBtnText.textContent = "Guardar Cambios";
    
    removeSelectedFile();
    removeSelectedUrl();
    
    // Determinar si la imagen es una subida local o una URL externa
    if (book.imageUrl) {
        if (book.imageUrl.startsWith("/uploads/")) {
            setImageSourceMode("file");
            // Mostrar previsualización de la imagen actual
            elements.uploadPreview.src = book.imageUrl;
            elements.uploadPlaceholder.classList.add("hidden");
            elements.uploadPreviewContainer.classList.remove("hidden");
        } else {
            setImageSourceMode("url");
            elements.inputImageUrl.value = book.imageUrl;
            elements.urlPreview.src = book.imageUrl;
            elements.urlPreviewContainer.classList.remove("hidden");
        }
    } else {
        setImageSourceMode("file");
    }
    
    // Cerrar el modal de detalles y abrir el modal del formulario
    closeDetailModal();
    elements.addBookModal.classList.remove("hidden");
    document.body.style.overflow = "hidden";
}

function closeAddModal() {
    elements.addBookModal.classList.add("hidden");
    document.body.style.overflow = "";
}

// Abrir Modal de Detalles (GET por ID)
async function openDetailModal(bookId) {
    appState.selectedBookId = bookId;
    elements.detailContent.innerHTML = `
        <div class="loading-state">
            <div class="spinner"></div>
            <p>Cargando detalles...</p>
        </div>
    `;
    elements.bookDetailModal.classList.remove("hidden");
    document.body.style.overflow = "hidden";

    try {
        const response = await fetch(`${API_URL}/${bookId}`);
        if (!response.ok) {
            throw new Error(`Error al cargar los detalles. Código: ${response.status}`);
        }
        
        const book = await response.json();
        
        let coverHtml = "";
        if (book.imageUrl) {
            coverHtml = `<img src="${book.imageUrl}" alt="${book.title}" onerror="this.src=''; this.className='hidden'; this.nextElementSibling.classList.remove('hidden');">
                         <div class="fallback-cover hidden" style="background: ${getCoverGradient(book.title)}">
                             <div class="fallback-decorations">
                                 <span>Repositorio</span>
                                 <i class="fa-solid fa-bookmark"></i>
                             </div>
                             <div class="fallback-title">${book.title}</div>
                             <div class="fallback-author">${book.author}</div>
                         </div>`;
        } else {
            const gradient = getCoverGradient(book.title);
            coverHtml = `
                <div class="fallback-cover" style="background: ${gradient}">
                    <div class="fallback-decorations">
                        <span>Repositorio</span>
                        <i class="fa-solid fa-bookmark"></i>
                    </div>
                    <div class="fallback-title">${book.title}</div>
                    <div class="fallback-author">${book.author}</div>
                </div>
            `;
        }

        const descriptionHtml = book.description 
            ? `<p class="detail-description">${escapeHtml(book.description)}</p>` 
            : `<p class="detail-description no-description">Sin descripción proporcionada para este libro.</p>`;

        elements.detailContent.innerHTML = `
            <div class="detail-cover-box">
                ${coverHtml}
            </div>
            <div class="detail-info">
                <h1 class="detail-title">${escapeHtml(book.title)}</h1>
                <p class="detail-author">por ${escapeHtml(book.author)}</p>
                
                <div class="detail-meta-row">
                    <span class="detail-badge isbn-badge">ISBN: ${escapeHtml(book.isbn)}</span>
                    <span class="detail-badge">ID Base de datos: #${book.id}</span>
                </div>
                
                <div class="detail-label">Resumen / Descripción</div>
                ${descriptionHtml}
            </div>
        `;

    } catch (error) {
        console.error("Error al obtener detalles del libro:", error);
        showToast("Error al obtener los detalles del libro", "danger");
        closeDetailModal();
    }
}

function closeDetailModal() {
    elements.bookDetailModal.classList.add("hidden");
    document.body.style.overflow = "";
    appState.selectedBookId = null;
}

// Mecánicas de Subida de Archivos
function handleFileSelect() {
    const file = elements.inputImage.files[0];
    if (file) {
        if (!file.type.startsWith("image/")) {
            showToast("Solo se permiten archivos de imagen", "danger");
            removeSelectedFile();
            return;
        }
        if (file.size > 5 * 1024 * 1024) {
            showToast("La imagen de portada debe pesar menos de 5MB", "danger");
            removeSelectedFile();
            return;
        }

        const reader = new FileReader();
        reader.onload = (e) => {
            elements.uploadPreview.src = e.target.result;
            elements.uploadPlaceholder.classList.add("hidden");
            elements.uploadPreviewContainer.classList.remove("hidden");
        };
        reader.readAsDataURL(file);
    }
}

function removeSelectedFile(e) {
    if (e) e.stopPropagation();
    elements.inputImage.value = "";
    elements.uploadPreview.src = "";
    elements.uploadPreviewContainer.classList.add("hidden");
    elements.uploadPlaceholder.classList.remove("hidden");
}

// Mecánicas de Entrada URL de Imagen
function handleUrlInput() {
    const url = elements.inputImageUrl.value.trim();
    if (url) {
        elements.urlPreview.src = url;
        elements.urlPreviewContainer.classList.remove("hidden");
    } else {
        removeSelectedUrl();
    }
}

function removeSelectedUrl(e) {
    if (e) e.stopPropagation();
    elements.inputImageUrl.value = "";
    elements.urlPreview.src = "";
    elements.urlPreviewContainer.classList.add("hidden");
}

// Envío del Formulario (Guardar / Actualizar)
async function handleFormSubmit(e) {
    e.preventDefault();

    const isEditMode = elements.inputBookId.value !== "";
    const bookId = elements.inputBookId.value;

    elements.submitBtnText.textContent = isEditMode ? "Actualizando..." : "Guardando...";
    elements.submitSpinner.classList.remove("hidden");
    elements.addBookForm.querySelectorAll("input, textarea, button").forEach(el => el.disabled = true);

    const formData = new FormData();
    formData.append("title", elements.inputTitle.value);
    formData.append("author", elements.inputAuthor.value);
    formData.append("isbn", elements.inputIsbn.value);
    formData.append("description", elements.inputDescription.value);

    // Adjuntar la imagen según el origen activo
    if (appState.imageSourceMode === "file") {
        const file = elements.inputImage.files[0];
        if (file) {
            formData.append("image", file);
        } else if (isEditMode) {
            // Si está editando, y el contenedor de vista previa está oculto, significa que quitó la imagen
            if (elements.uploadPreviewContainer.classList.contains("hidden")) {
                formData.append("imageUrl", ""); // Cadena vacía para quitar la imagen
            }
        }
    } else {
        const url = elements.inputImageUrl.value.trim();
        formData.append("imageUrl", url); // Envia la url o cadena vacía si fue quitada
    }

    try {
        let response;
        if (isEditMode) {
            // PUT /api/books/{id} (Actualizar)
            response = await fetch(`${API_URL}/${bookId}`, {
                method: "PUT",
                body: formData
            });
        } else {
            // POST /api/books (Registrar)
            response = await fetch(API_URL, {
                method: "POST",
                body: formData
            });
        }

        if (response.status === 201 || response.status === 200) {
            showToast(isEditMode ? "¡Libro actualizado correctamente!" : "¡Libro registrado correctamente!", "success");
            closeAddModal();
            fetchBooks();
        } else if (response.status === 409) {
            showToast("El ISBN ingresado ya está registrado por otro libro.", "danger");
        } else {
            const errorMsg = await response.text();
            throw new Error(errorMsg || `Error de servidor: ${response.status}`);
        }

    } catch (error) {
        console.error("Error al procesar el libro:", error);
        showToast(error.message || "Error al conectar con el servidor", "danger");
    } finally {
        elements.submitBtnText.textContent = isEditMode ? "Guardar Cambios" : "Guardar Libro";
        elements.submitSpinner.classList.add("hidden");
        elements.addBookForm.querySelectorAll("input, textarea, button").forEach(el => el.disabled = false);
    }
}

// Eliminar un Libro de la API
async function deleteBook(bookId) {
    try {
        const response = await fetch(`${API_URL}/${bookId}`, {
            method: "DELETE"
        });

        if (response.ok) {
            showToast("Libro eliminado de la colección", "success");
            closeDetailModal();
            fetchBooks();
        } else {
            throw new Error(`Error en la solicitud de eliminación. Código: ${response.status}`);
        }
    } catch (error) {
        console.error("Error al eliminar libro:", error);
        showToast("Error al eliminar el libro. Revisa la conexión.", "danger");
    }
}

// Mostrar notificaciones Toast
function showToast(message, type = "info") {
    const toast = document.createElement("div");
    toast.className = `toast toast-${type}`;
    
    let icon = '<i class="fa-solid fa-circle-info toast-icon"></i>';
    if (type === "success") {
        icon = '<i class="fa-solid fa-circle-check toast-icon"></i>';
    } else if (type === "danger") {
        icon = '<i class="fa-solid fa-triangle-exclamation toast-icon"></i>';
    }

    toast.innerHTML = `
        ${icon}
        <span>${message}</span>
    `;

    elements.toastContainer.appendChild(toast);

    setTimeout(() => {
        toast.style.animation = 'toast-in 0.3s cubic-bezier(0.16, 1, 0.3, 1) reverse forwards';
        setTimeout(() => {
            toast.remove();
        }, 300);
    }, 4000);
}

// Limpiar HTML
function escapeHtml(text) {
    if (!text) return "";
    return text
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}
