const API_URL = '/estudiantes';

// Elementos del DOM
const tbody = document.getElementById('students-table-body');
const modal = document.getElementById('student-modal');
const form = document.getElementById('student-form');
const inputId = document.getElementById('student-id');
const inputMatricula = document.getElementById('matricula');
const inputNombre = document.getElementById('nombre');
const inputCarrera = document.getElementById('carrera');
const inputEdad = document.getElementById('edad');
const inputEmail = document.getElementById('email');
const inputTelefono = document.getElementById('telefono');
const inputMatriculado = document.getElementById('matriculado');
const inputSemestres = document.getElementById('semestres');
const inputEstado = document.getElementById('estado');
const modalTitle = document.getElementById('modal-title');
const searchInput = document.getElementById('search-input');
const filterMatriculado = document.getElementById('filter-matriculado');
const filterEstado = document.getElementById('filter-estado');
const sortBy = document.getElementById('sort-by');
const btnExport = document.getElementById('btn-export');
const statTotal = document.getElementById('stat-total');
const statMatriculados = document.getElementById('stat-matriculados');
const statEdad = document.getElementById('stat-edad');
const statCarreras = document.getElementById('stat-carreras');
const deleteModal = document.getElementById('delete-modal');
const btnCloseDelete = document.getElementById('btn-close-delete');
const btnCancelDelete = document.getElementById('btn-cancel-delete');
const btnConfirmDelete = document.getElementById('btn-confirm-delete');

const btnOpenModal = document.getElementById('btn-open-modal');
const btnCloseModal = document.getElementById('btn-close-modal');
const btnCancel = document.getElementById('btn-cancel');

let studentsCache = [];

// Event Listeners
document.addEventListener('DOMContentLoaded', fetchStudents);
btnOpenModal.addEventListener('click', () => openModal());
btnCloseModal.addEventListener('click', closeModal);
btnCancel.addEventListener('click', closeModal);
form.addEventListener('submit', handleFormSubmit);
searchInput.addEventListener('input', () => renderTable(studentsCache));
filterMatriculado.addEventListener('change', () => renderTable(studentsCache));
filterEstado.addEventListener('change', () => renderTable(studentsCache));
sortBy.addEventListener('change', () => renderTable(studentsCache));
btnExport.addEventListener('click', handleExport);
btnCloseDelete.addEventListener('click', closeDeleteModal);
btnCancelDelete.addEventListener('click', closeDeleteModal);
btnConfirmDelete.addEventListener('click', confirmDelete);

// Cargar Estudiantes
async function fetchStudents() {
    try {
        const response = await fetch(API_URL);
        const data = await response.json();
        studentsCache = Array.isArray(data) ? data : [];
        renderTable(studentsCache);
        updateStats(studentsCache);
    } catch (error) {
        console.error("Error cargando estudiantes:", error);
        tbody.innerHTML = `<tr><td colspan="10" class="text-center">Error al cargar los datos</td></tr>`;
    }
}

// Renderizar Tabla
function renderTable(students) {
    const filtered = applyFilters(students);

    if (filtered.length === 0) {
        tbody.innerHTML = `<tr><td colspan="10" class="text-center">No hay estudiantes registrados.</td></tr>`;
        return;
    }

    tbody.innerHTML = '';
    filtered.forEach(student => {
        const tr = document.createElement('tr');
        const estadoClass = getEstadoClass(student.estado);
        const matriculaBadge = student.matriculado ? 'Si' : 'No';
        tr.innerHTML = `
            <td>#${student.id}</td>
            <td>
                <div class="student-cell">
                    <div class="student-avatar">${getInitials(student.nombre)}</div>
                    <div>
                        <strong>${student.nombre}</strong>
                        <span>${student.matricula || 'Sin matricula'}</span>
                    </div>
                </div>
            </td>
            <td>
                <div class="cell-stack">
                    <strong>${student.carrera}</strong>
                </div>
            </td>
            <td class="hide-mobile">${student.edad}</td>
            <td class="hide-mobile">${student.email}</td>
            <td class="hide-tablet">${student.telefono}</td>
            <td><span class="badge ${student.matriculado ? 'badge-success' : 'badge-muted'}">${matriculaBadge}</span></td>
            <td class="hide-mobile">${student.semestres}</td>
            <td><span class="badge ${estadoClass}">${student.estado}</span></td>
            <td class="actions-cell">
                <button class="icon-btn" onclick="editStudent(${student.id})" title="Editar">
                    <i class="fa-solid fa-pen"></i>
                </button>
                <button class="icon-btn danger" onclick="deleteStudent(${student.id})" title="Eliminar">
                    <i class="fa-solid fa-trash"></i>
                </button>
            </td>
        `;
        tbody.appendChild(tr);
    });
}

// Modal Mgt
function openModal(isEdit = false) {
    if (!isEdit) {
        form.reset();
        inputId.value = '';
        inputMatriculado.value = 'true';
        inputEstado.value = 'Activo';
        modalTitle.textContent = 'Registrar Estudiante';
    }
    modal.classList.remove('hidden');
}

function closeModal() {
    modal.classList.add('hidden');
}

// Form Submit (Crear o Actualizar)
async function handleFormSubmit(e) {
    e.preventDefault();

    const id = inputId.value;
    const isEdit = id !== '';
    
    const payload = {
        matricula: inputMatricula.value,
        nombre: inputNombre.value,
        carrera: inputCarrera.value,
        edad: parseInt(inputEdad.value),
        email: inputEmail.value,
        telefono: inputTelefono.value,
        matriculado: inputMatriculado.value === 'true',
        semestres: parseInt(inputSemestres.value),
        estado: inputEstado.value
    };

    try {
        const url = isEdit ? `${API_URL}/${id}` : API_URL;
        const method = isEdit ? 'PUT' : 'POST';

        const response = await fetch(url, {
            method: method,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload)
        });

        if (response.ok) {
            closeModal();
            fetchStudents();
        } else {
            alert("Ocurrió un error al guardar.");
        }
    } catch (error) {
        console.error("Error al guardar estudiante:", error);
    }
}

// Editar Estudiante
window.editStudent = function(id) {
    const student = studentsCache.find(item => item.id === id);
    if (!student) return;
    inputId.value = student.id;
    inputMatricula.value = student.matricula || '';
    inputNombre.value = student.nombre || '';
    inputCarrera.value = student.carrera || '';
    inputEdad.value = student.edad || '';
    inputEmail.value = student.email || '';
    inputTelefono.value = student.telefono || '';
    inputMatriculado.value = String(student.matriculado);
    inputSemestres.value = student.semestres || '';
    inputEstado.value = student.estado || 'Activo';
    modalTitle.textContent = 'Editar Estudiante';
    openModal(true);
};

// Eliminar Estudiante
window.deleteStudent = async function(id) {
    openDeleteModal(id);
};

async function confirmDelete() {
    const id = deleteModal.dataset.id;
    if (!id) return;
    try {
        const response = await fetch(`${API_URL}/${id}`, {
            method: 'DELETE'
        });

        if (response.ok) {
            closeDeleteModal();
            fetchStudents();
        } else {
            alert("No se pudo eliminar el estudiante.");
        }
    } catch (error) {
        console.error("Error al eliminar estudiante:", error);
    }
}

function openDeleteModal(id) {
    deleteModal.dataset.id = id;
    deleteModal.classList.remove('hidden');
}

function closeDeleteModal() {
    deleteModal.dataset.id = '';
    deleteModal.classList.add('hidden');
}

function updateStats(students) {
    const total = students.length;
    const matriculados = students.filter(s => s.matriculado).length;
    const edadProm = total ? (students.reduce((acc, s) => acc + (s.edad || 0), 0) / total) : 0;
    const carreras = new Set(students.map(s => s.carrera)).size;
    statTotal.textContent = total;
    statMatriculados.textContent = matriculados;
    statEdad.textContent = edadProm.toFixed(1);
    statCarreras.textContent = carreras;
}

function getEstadoClass(estado) {
    switch (estado) {
        case 'Activo':
            return 'badge-success';
        case 'En riesgo':
            return 'badge-warning';
        case 'Graduado':
            return 'badge-info';
        case 'Baja':
            return 'badge-danger';
        default:
            return 'badge-muted';
    }
}

function getInitials(name) {
    if (!name) return '??';
    const parts = name.trim().split(' ');
    const first = parts[0]?.[0] || '';
    const last = parts[1]?.[0] || '';
    return `${first}${last}`.toUpperCase();
}

function applyFilters(students) {
    const query = searchInput.value.toLowerCase().trim();
    const estadoFiltro = filterEstado.value;
    const matriculadoFiltro = filterMatriculado.value;

    let filtered = students.filter(student => {
        const matchesQuery = [
            student.nombre,
            student.matricula,
            student.carrera,
            student.email,
            student.telefono
        ].some(value => String(value || '').toLowerCase().includes(query));

        const matchesEstado = estadoFiltro === 'all' || student.estado === estadoFiltro;
        const matchesMatriculado = matriculadoFiltro === 'all' || String(student.matriculado) === matriculadoFiltro;

        return matchesQuery && matchesEstado && matchesMatriculado;
    });

    const order = sortBy.value;
    filtered = filtered.sort((a, b) => {
        if (order === 'edad' || order === 'semestres') {
            return (a[order] || 0) - (b[order] || 0);
        }
        return String(a[order] || '').localeCompare(String(b[order] || ''), 'es', { sensitivity: 'base' });
    });

    return filtered;
}

function handleExport() {
    const filtered = applyFilters(studentsCache);
    const headers = ['id', 'matricula', 'nombre', 'carrera', 'edad', 'email', 'telefono', 'matriculado', 'semestres', 'estado'];
    const rows = filtered.map(student => [
        student.id,
        student.matricula,
        student.nombre,
        student.carrera,
        student.edad,
        student.email,
        student.telefono,
        student.matriculado,
        student.semestres,
        student.estado
    ]);

    const csvContent = [headers, ...rows]
        .map(row => row.map(value => `"${String(value ?? '').replace(/"/g, '""')}"`).join(','))
        .join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = 'estudiantes.csv';
    link.click();
    URL.revokeObjectURL(url);
}
