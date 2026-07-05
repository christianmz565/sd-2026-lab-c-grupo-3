const API_URL = "/estudiantes";

// ============================================
// ESTADO
// ============================================
let students = [];

// ============================================
// DOM READY
// ============================================
document.addEventListener("DOMContentLoaded", () => {
  fetchStudents();
  setupNav();
  setupSearch();
  setupFilters();
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

  ["coleccion", "comparativa"].forEach((s) => {
    const sec = document.getElementById(`sec-${s}`);
    if (sec) sec.classList.toggle("hidden", s !== name);
  });
}

// ============================================
// BUSQUEDA Y FILTROS
// ============================================
function setupSearch() {
  let timeout;
  document.getElementById("search-input").addEventListener("input", () => {
    clearTimeout(timeout);
    timeout = setTimeout(() => renderTable(), 200);
  });
}

function setupFilters() {
  document.getElementById("filter-estado").addEventListener("change", renderTable);
  document.getElementById("sort-by").addEventListener("change", renderTable);
}

function getFiltered() {
  const query = document.getElementById("search-input").value.toLowerCase().trim();
  const estado = document.getElementById("filter-estado").value;
  const sort = document.getElementById("sort-by").value;

  let filtered = students.filter((s) => {
    const matchQuery = [s.nombre, s.matricula, s.carrera, s.email, s.telefono]
      .some((v) => String(v || "").toLowerCase().includes(query));
    const matchEstado = estado === "all" || s.estado === estado;
    return matchQuery && matchEstado;
  });

  filtered.sort((a, b) => {
    if (sort === "edad") return (a.edad || 0) - (b.edad || 0);
    return String(a[sort] || "").localeCompare(String(b[sort] || ""), "es", { sensitivity: "base" });
  });

  return filtered;
}

// ============================================
// FETCH ESTUDIANTES (REST: GET /estudiantes)
// ============================================
async function fetchStudents() {
  showLoading(true);
  try {
    const res = await fetch(API_URL);
    if (!res.ok) throw new Error(`Error ${res.status}`);
    const data = await res.json();
    students = Array.isArray(data) ? data : [];
    renderTable();
    updateStats();
  } catch (e) {
    showToast("Error al cargar estudiantes: " + e.message, "danger");
  } finally {
    showLoading(false);
  }
}

// ============================================
// RENDER TABLA
// ============================================
function renderTable() {
  const tbody = document.getElementById("students-body");
  const empty = document.getElementById("empty-state");
  const table = document.getElementById("table-wrap");
  const loading = document.getElementById("loading-state");

  const filtered = getFiltered();
  loading.classList.add("hidden");

  if (filtered.length === 0) {
    table.classList.add("hidden");
    empty.classList.remove("hidden");
    return;
  }

  empty.classList.add("hidden");
  table.classList.remove("hidden");

  const estadoClasses = {
    Activo: "badge-success",
    "En riesgo": "badge-warning",
    Graduado: "badge-info",
    Baja: "badge-danger",
  };

  tbody.innerHTML = filtered
    .map((s) => {
      const initials = getInitials(s.nombre);
      const estadoClass = estadoClasses[s.estado] || "badge-muted";
      const matBadge = s.matriculado ? "badge-success" : "badge-muted";

      return `
      <tr>
        <td>#${s.id}</td>
        <td>
          <div style="display:flex;align-items:center;gap:10px;">
            <div style="width:36px;height:36px;border-radius:10px;background:var(--primary-light);color:var(--primary);display:grid;place-items:center;font-weight:700;font-size:13px;">${initials}</div>
            <div class="cell-stack">
              <strong>${s.nombre}</strong>
              <span>${s.matricula || ""}</span>
            </div>
          </div>
        </td>
        <td>${s.carrera}</td>
        <td>${s.edad}</td>
        <td style="font-size:12px;color:var(--text-secondary);">${s.email}</td>
        <td><span class="badge ${matBadge}">${s.matriculado ? "Si" : "No"}</span></td>
        <td><span class="badge ${estadoClass}">${s.estado}</span></td>
        <td>
          <div style="display:flex;gap:6px;">
            <button class="btn btn-icon btn-secondary btn-sm" onclick="editStudent(${s.id})" title="Editar">
              <i class="fa-solid fa-pen"></i>
            </button>
            <button class="btn btn-icon btn-danger btn-sm" onclick="deleteStudent(${s.id})" title="Eliminar">
              <i class="fa-solid fa-trash"></i>
            </button>
          </div>
        </td>
      </tr>`;
    })
    .join("");
}

// ============================================
// STATS
// ============================================
function updateStats() {
  document.getElementById("stat-total").textContent = students.length;
  const matriculados = students.filter((s) => s.matriculado).length;
  document.getElementById("stat-matriculados").textContent = matriculados;
}

// ============================================
// LOADING
// ============================================
function showLoading(show) {
  document.getElementById("loading-state").classList.toggle("hidden", !show);
  document.getElementById("table-wrap").classList.toggle("hidden", show);
}

// ============================================
// MODAL: CREAR/EDITAR
// ============================================
function openModal(studentId = null) {
  const modal = document.getElementById("student-modal");
  const form = document.getElementById("student-form");
  const title = document.getElementById("modal-title");

  form.reset();
  document.getElementById("input-id").value = "";

  if (studentId) {
    const s = students.find((x) => x.id === studentId);
    if (s) {
      document.getElementById("input-id").value = s.id;
      document.getElementById("input-matricula").value = s.matricula || "";
      document.getElementById("input-nombre").value = s.nombre || "";
      document.getElementById("input-carrera").value = s.carrera || "";
      document.getElementById("input-edad").value = s.edad || "";
      document.getElementById("input-email").value = s.email || "";
      document.getElementById("input-telefono").value = s.telefono || "";
      document.getElementById("input-matriculado").value = String(s.matriculado);
      document.getElementById("input-semestres").value = s.semestres || "";
      document.getElementById("input-estado").value = s.estado || "Activo";
      title.textContent = "Editar Estudiante";
    }
  } else {
    title.textContent = "Registrar Estudiante";
  }

  modal.classList.remove("hidden");
}

function closeModal() {
  document.getElementById("student-modal").classList.add("hidden");
}

function editStudent(id) {
  openModal(id);
}

// ============================================
// SUBMIT (REST: POST / PUT)
// ============================================
async function submitStudent() {
  const id = document.getElementById("input-id").value;
  const isEdit = id !== "";

  const payload = {
    matricula: document.getElementById("input-matricula").value,
    nombre: document.getElementById("input-nombre").value,
    carrera: document.getElementById("input-carrera").value,
    edad: parseInt(document.getElementById("input-edad").value),
    email: document.getElementById("input-email").value,
    telefono: document.getElementById("input-telefono").value,
    matriculado: document.getElementById("input-matriculado").value === "true",
    semestres: parseInt(document.getElementById("input-semestres").value) || 1,
    estado: document.getElementById("input-estado").value,
  };

  try {
    const url = isEdit ? `${API_URL}/${id}` : API_URL;
    const method = isEdit ? "PUT" : "POST";

    const res = await fetch(url, {
      method,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });

    if (res.ok) {
      showToast(isEdit ? "Estudiante actualizado" : "Estudiante registrado", "success");
      closeModal();
      fetchStudents();
    } else {
      throw new Error(`Error ${res.status}`);
    }
  } catch (e) {
    showToast("Error: " + e.message, "danger");
  }
}

// ============================================
// ELIMINAR (REST: DELETE /estudiantes/{id})
// ============================================
async function deleteStudent(id) {
  if (!confirm("Eliminar este estudiante?")) return;
  try {
    const res = await fetch(`${API_URL}/${id}`, { method: "DELETE" });
    if (!res.ok) throw new Error(`Error ${res.status}`);
    showToast("Estudiante eliminado", "success");
    fetchStudents();
  } catch (e) {
    showToast("Error: " + e.message, "danger");
  }
}

// ============================================
// UTILS
// ============================================
function getInitials(name) {
  if (!name) return "??";
  const parts = name.trim().split(" ");
  return ((parts[0]?.[0] || "") + (parts[1]?.[0] || "")).toUpperCase();
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
