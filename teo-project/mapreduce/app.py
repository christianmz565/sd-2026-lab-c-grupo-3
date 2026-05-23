import json
import os
from http.server import HTTPServer, SimpleHTTPRequestHandler


class MasterHandler(SimpleHTTPRequestHandler):
    def translate_path(self, path):
        base_dir = os.path.dirname(os.path.abspath(__file__))
        static_dir = os.path.join(base_dir, "static")

        if path == "/" or path == "/index.html":
            return os.path.join(static_dir, "index.html")

        return os.path.join(static_dir, path.lstrip("/"))

    def do_POST(self):
        if self.path == "/api/count":
            content_length = int(self.headers["Content-Length"])
            post_data = self.rfile.read(content_length)

            try:
                payload = json.loads(post_data.decode("utf-8"))
                text = payload.get("text", "")
            except Exception:
                text = ""

            words = text.split()
            mock_response = {
                "summary": {
                    "total_words": len(words) if words else 1284,
                    "unique_words": len(set(words)) if words else 342,
                    "execution_time_ms": 142.5,
                },
                "word_counts": [
                    ("distributed", 48),
                    ("systems", 42),
                    ("mapreduce", 38),
                    ("worker", 29),
                    ("master", 25),
                    ("word", 22),
                    ("count", 21),
                    ("grpc", 18),
                    ("python", 15),
                    ("docker", 12),
                    ("kubernetes", 10),
                    ("data", 9),
                    ("network", 8),
                    ("concurrency", 7),
                    ("parallel", 6),
                ],
            }

            response_bytes = json.dumps(mock_response).encode("utf-8")

            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
            self.send_header("Access-Control-Allow-Headers", "Content-Type")
            self.end_headers()
            self.wfile.write(response_bytes)
        else:
            self.send_error(404, "Not Found")

    def do_OPTIONS(self):
        # Support CORS preflight requests for local development
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()


def run_master() -> None:
    port = 8000
    server_address = ("", port)
    httpd = HTTPServer(server_address, MasterHandler)
    print(
        f"\033[92m[Master] Servidor HTTP escuchando en http://localhost:{port}/\033[0m"
    )
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n[Master] Deteniendo servidor HTTP...")
        httpd.server_close()


def run_worker() -> None:
    print(
        "[Worker] Rol de worker inicializado (Esperando implementación distributed)..."
    )


def main() -> None:
    role = os.environ.get("MAPREDUCE_ROLE", "master").strip().lower()
    if role == "master":
        run_master()
        return
    if role == "worker":
        run_worker()
        return
    print(f"unknown role: {role}")


if __name__ == "__main__":
    main()
