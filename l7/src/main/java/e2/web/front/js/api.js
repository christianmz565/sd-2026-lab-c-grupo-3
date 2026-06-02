
const API = (() => {
  const BASE_URL = 'http://localhost:3001/api';
  let _mode = 'unknown';
  const onModeChange = [];
  function setMode(m) {
    _mode = m;
    onModeChange.forEach(cb => cb(m));
  }

  async function request(path, options = {}) {
    const headers = { ...(options.headers || {}) };
    if (options.body) {
      headers['Content-Type'] = 'application/json';
    }
    const res = await fetch(`${BASE_URL}${path}`, {
      ...options,
      headers,
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return res.json();
  }

  async function init(cb) {
    if (cb) onModeChange.push(cb);
    try {
      await request('/health');
      setMode('soap');
    } catch {
      setMode('mock');
    }
    return _mode;
  }

  async function getItems() {
    return request('/items');
  }
  async function addItem(item) {
    const { ok } = await request('/items', {
      method: 'POST',
      body: JSON.stringify(item),
    });
    return ok === true;
  }
  async function setItem(nombre, cantidad, costo) {
    const { ok } = await request(`/items/${encodeURIComponent(nombre)}`, {
      method: 'PUT',
      body: JSON.stringify({ cantidad, costo }),
    });
    return ok === true;
  }
  async function deleteItem(nombre) {
    const { ok } = await request(`/items/${encodeURIComponent(nombre)}`, {
      method: 'DELETE',
    });
    return ok === true;
  }
  async function buyItem(nombre, cantidad) {
    const { result } = await request(`/items/${encodeURIComponent(nombre)}/buy`, {
      method: 'POST',
      body: JSON.stringify({ cantidad }),
    });
    return result || '';
  }

  return { init, getItems, addItem, setItem, deleteItem, buyItem, getMode: () => _mode };
})();
