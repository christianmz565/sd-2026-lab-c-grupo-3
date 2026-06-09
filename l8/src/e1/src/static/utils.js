async function safeFetch(url, options = {}) {
    try {
        const res = await fetch(url, options);
        const contentType = res.headers.get('content-type');
        let data = null;
        if (contentType && contentType.includes('application/json')) {
            data = await res.json();
        } else {
            const text = await res.text();
            if (!res.ok) {
                throw new Error(text || `Error del servidor (${res.status})`);
            }
            return { ok: true, status: res.status, data: text };
        }
        return { ok: res.ok, status: res.status, data };
    } catch (err) {
        throw err;
    }
}
