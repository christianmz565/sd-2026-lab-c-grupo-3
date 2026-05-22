// Application State Management
let appState = {
    books: [],
    selectedBookId: null,
    searchQuery: ""
};

// Endpoints
const API_URL = "/api/books";

// Gradients for books without custom covers
const COVER_GRADIENTS = [
    'linear-gradient(135deg, #6366f1 0%, #a855f7 100%)', // Indigo -> Purple
    'linear-gradient(135deg, #3b82f6 0%, #06b6d4 100%)', // Blue -> Cyan
    'linear-gradient(135deg, #10b981 0%, #059669 100%)', // Emerald -> Green
    'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)', // Amber -> Orange
    'linear-gradient(135deg, #ec4899 0%, #be185d 100%)', // Pink -> Rose
    'linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%)'  // Violet -> Dark Violet
];

// Get cover gradient deterministically based on book title
function getCoverGradient(title) {
    let hash = 0;
    for (let i = 0; i < title.length; i++) {
        hash = title.charCodeAt(i) + ((hash << 5) - hash);
    }
    const index = Math.abs(hash) % COVER_GRADIENTS.length;
    return COVER_GRADIENTS[index];
}

// DOM Elements
const elements = {
    booksGrid: document.getElementById("books-grid"),
    loadingState: document.getElementById("loading-state"),
    emptyState: document.getElementById("empty-state"),
    booksCountBadge: document.getElementById("books-count-badge"),
    searchInput: document.getElementById("search-input"),
    
    // Modals
    addBookModal: document.getElementById("add-book-modal"),
    bookDetailModal: document.getElementById("book-detail-modal"),
    
    // Forms & Inputs
    addBookForm: document.getElementById("add-book-form"),
    inputImage: document.getElementById("input-image"),
    imageUploadWrapper: document.getElementById("image-upload-wrapper"),
    uploadPlaceholder: document.getElementById("upload-placeholder"),
    uploadPreviewContainer: document.getElementById("upload-preview-container"),
    uploadPreview: document.getElementById("upload-preview"),
    btnRemoveImage: document.getElementById("btn-remove-image"),
    submitBtnText: document.getElementById("submit-btn-text"),
    submitSpinner: document.getElementById("submit-spinner"),
    
    // Detail View elements
    detailContent: document.getElementById("detail-content"),
    btnDetailDelete: document.getElementById("btn-detail-delete"),
    
    // Action Buttons
    btnOpenAddModal: document.getElementById("btn-open-add-modal"),
    btnEmptyAdd: document.getElementById("btn-empty-add"),
    btnCloseAddModal: document.getElementById("btn-close-add-modal"),
    btnCancelAdd: document.getElementById("btn-cancel-add"),
    btnCloseDetailModal: document.getElementById("btn-close-detail-modal"),
    btnCloseDetail: document.getElementById("btn-close-detail"),
    toastContainer: document.getElementById("toast-container")
};

// Initialize Application
document.addEventListener("DOMContentLoaded", () => {
    fetchBooks();
    setupEventListeners();
});

// Event Listeners Registration
function setupEventListeners() {
    // Open/Close Add Book Modal
    elements.btnOpenAddModal.addEventListener("click", openAddModal);
    elements.btnEmptyAdd.addEventListener("click", openAddModal);
    elements.btnCloseAddModal.addEventListener("click", closeAddModal);
    elements.btnCancelAdd.addEventListener("click", closeAddModal);
    
    // Close Detail Modal
    elements.btnCloseDetailModal.addEventListener("click", closeDetailModal);
    elements.btnCloseDetail.addEventListener("click", closeDetailModal);
    
    // Search input handler (Debounced)
    let searchTimeout;
    elements.searchInput.addEventListener("input", (e) => {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => {
            appState.searchQuery = e.target.value.toLowerCase().trim();
            renderBooks();
        }, 200);
    });

    // Form Submission
    elements.addBookForm.addEventListener("submit", handleFormSubmit);

    // Image Upload Mechanics
    elements.imageUploadWrapper.addEventListener("click", () => {
        elements.inputImage.click();
    });
    
    elements.inputImage.addEventListener("change", handleFileSelect);
    elements.btnRemoveImage.addEventListener("click", removeSelectedFile);

    // Drag and drop upload zone
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

    // Detail Modal actions
    elements.btnDetailDelete.addEventListener("click", () => {
        if (appState.selectedBookId) {
            deleteBook(appState.selectedBookId);
        }
    });

    // Close Modals on Outer Backdrop Click
    window.addEventListener("click", (e) => {
        if (e.target === elements.addBookModal) closeAddModal();
        if (e.target === elements.bookDetailModal) closeDetailModal();
    });
}

// Fetch Books from REST API
async function fetchBooks() {
    showLoading(true);
    try {
        const response = await fetch(API_URL);
        if (!response.ok) {
            throw new Error(`Server returned code ${response.status}`);
        }
        appState.books = await response.json();
        renderBooks();
    } catch (error) {
        console.error("Error loading books:", error);
        showToast("Error loading book repository", "danger");
    } finally {
        showLoading(false);
    }
}

// Render Books Grid
function renderBooks() {
    const filteredBooks = appState.books.filter(book => {
        return book.title.toLowerCase().includes(appState.searchQuery) ||
               book.author.toLowerCase().includes(appState.searchQuery) ||
               book.isbn.toLowerCase().includes(appState.searchQuery);
    });

    // Update Counter Badge
    elements.booksCountBadge.textContent = `${filteredBooks.length} Book${filteredBooks.length === 1 ? '' : 's'}`;

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
            coverHtml = `<img src="${book.imageUrl}" alt="${book.title}" class="book-cover">`;
        } else {
            const gradient = getCoverGradient(book.title);
            coverHtml = `
                <div class="fallback-cover" style="background: ${gradient}">
                    <div class="fallback-decorations">
                        <span>Repository</span>
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
                        <button class="btn-icon-danger btn-delete-card" data-id="${book.id}" title="Delete Book">
                            <i class="fa-solid fa-trash-can"></i>
                        </button>
                    </div>
                </div>
            </div>
        `;

        // Click on card opens detailed view (Find by ID API consumption)
        card.addEventListener("click", (e) => {
            // Prevent opening details if clicking the delete button
            if (e.target.closest(".btn-delete-card")) {
                return;
            }
            openDetailModal(book.id);
        });

        // Delete button inside card handler
        const btnDelete = card.querySelector(".btn-delete-card");
        btnDelete.addEventListener("click", (e) => {
            e.stopPropagation();
            if (confirm(`Are you sure you want to delete "${book.title}"?`)) {
                deleteBook(book.id);
            }
        });

        elements.booksGrid.appendChild(card);
    });
}

// Show/Hide Loading Animation
function showLoading(show) {
    if (show) {
        elements.loadingState.classList.remove("hidden");
        elements.booksGrid.classList.add("hidden");
        elements.emptyState.classList.add("hidden");
    } else {
        elements.loadingState.classList.add("hidden");
    }
}

// Open / Close Add modal
function openAddModal() {
    elements.addBookForm.reset();
    removeSelectedFile();
    elements.addBookModal.classList.remove("hidden");
    document.body.style.overflow = "hidden"; // Prevent background scroll
}

function closeAddModal() {
    elements.addBookModal.classList.add("hidden");
    document.body.style.overflow = "";
}

// Open / Close Detail modal
async function openDetailModal(bookId) {
    appState.selectedBookId = bookId;
    elements.detailContent.innerHTML = `
        <div class="loading-state">
            <div class="spinner"></div>
            <p>Retrieving details...</p>
        </div>
    `;
    elements.bookDetailModal.classList.remove("hidden");
    document.body.style.overflow = "hidden";

    try {
        // GET /api/books/{id} (Find by ID)
        const response = await fetch(`${API_URL}/${bookId}`);
        if (!response.ok) {
            throw new Error(`Failed to load details. Code: ${response.status}`);
        }
        
        const book = await response.json();
        
        let coverHtml = "";
        if (book.imageUrl) {
            coverHtml = `<img src="${book.imageUrl}" alt="${book.title}">`;
        } else {
            const gradient = getCoverGradient(book.title);
            coverHtml = `
                <div class="fallback-cover" style="background: ${gradient}">
                    <div class="fallback-decorations">
                        <span>Repository</span>
                        <i class="fa-solid fa-bookmark"></i>
                    </div>
                    <div class="fallback-title">${book.title}</div>
                    <div class="fallback-author">${book.author}</div>
                </div>
            `;
        }

        const descriptionHtml = book.description 
            ? `<p class="detail-description">${escapeHtml(book.description)}</p>` 
            : `<p class="detail-description no-description">No description provided for this repository entry.</p>`;

        elements.detailContent.innerHTML = `
            <div class="detail-cover-box">
                ${coverHtml}
            </div>
            <div class="detail-info">
                <h1 class="detail-title">${escapeHtml(book.title)}</h1>
                <p class="detail-author">by ${escapeHtml(book.author)}</p>
                
                <div class="detail-meta-row">
                    <span class="detail-badge isbn-badge">ISBN: ${escapeHtml(book.isbn)}</span>
                    <span class="detail-badge">Database ID: #${book.id}</span>
                </div>
                
                <div class="detail-label">Summary / Description</div>
                ${descriptionHtml}
            </div>
        `;

    } catch (error) {
        console.error("Error retrieving book details:", error);
        showToast("Error retrieving book details from server", "danger");
        closeDetailModal();
    }
}

function closeDetailModal() {
    elements.bookDetailModal.classList.add("hidden");
    document.body.style.overflow = "";
    appState.selectedBookId = null;
}

// Handle Image File Select Preview
function handleFileSelect() {
    const file = elements.inputImage.files[0];
    if (file) {
        // Validate file type
        if (!file.type.startsWith("image/")) {
            showToast("Only image files are allowed", "danger");
            removeSelectedFile();
            return;
        }
        // Validate file size (5MB)
        if (file.size > 5 * 1024 * 1024) {
            showToast("Cover image must be smaller than 5MB", "danger");
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

// Handle Form Submit (Register book)
async function handleFormSubmit(e) {
    e.preventDefault();

    // Visual loading state
    elements.submitBtnText.textContent = "Saving...";
    elements.submitSpinner.classList.remove("hidden");
    elements.addBookForm.querySelectorAll("input, textarea, button").forEach(el => el.disabled = true);

    const formData = new FormData();
    formData.append("title", document.getElementById("input-title").value);
    formData.append("author", document.getElementById("input-author").value);
    formData.append("isbn", document.getElementById("input-isbn").value);
    formData.append("description", document.getElementById("input-description").value);
    
    const file = elements.inputImage.files[0];
    if (file) {
        formData.append("image", file);
    }

    try {
        const response = await fetch(API_URL, {
            method: "POST",
            body: formData
        });

        if (response.status === 201) {
            showToast("Book registered successfully!", "success");
            closeAddModal();
            fetchBooks();
        } else if (response.status === 409) {
            showToast("ISBN already registered. Check detail logs.", "danger");
        } else {
            const errorMsg = await response.text();
            throw new Error(errorMsg || `Server responded with status ${response.status}`);
        }

    } catch (error) {
        console.error("Error registering book:", error);
        showToast(error.message || "Failed to register book. Server error.", "danger");
    } finally {
        // Reset loading state
        elements.submitBtnText.textContent = "Save Book";
        elements.submitSpinner.classList.add("hidden");
        elements.addBookForm.querySelectorAll("input, textarea, button").forEach(el => el.disabled = false);
    }
}

// Delete Book API consumption
async function deleteBook(bookId) {
    try {
        const response = await fetch(`${API_URL}/${bookId}`, {
            method: "DELETE"
        });

        if (response.ok) {
            showToast("Book deleted successfully", "success");
            closeDetailModal();
            fetchBooks();
        } else {
            throw new Error(`Delete request failed. Code: ${response.status}`);
        }
    } catch (error) {
        console.error("Error deleting book:", error);
        showToast("Error deleting book. Check connection.", "danger");
    }
}

// Show Toast Notification
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

    // Remove toast after animation ends
    setTimeout(() => {
        toast.style.animation = 'toast-in 0.3s cubic-bezier(0.16, 1, 0.3, 1) reverse forwards';
        setTimeout(() => {
            toast.remove();
        }, 300);
    }, 4000);
}

// Utility function to escape HTML special characters
function escapeHtml(text) {
    if (!text) return "";
    return text
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}
