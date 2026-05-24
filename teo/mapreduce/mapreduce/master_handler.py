import json
import os
import sys
import time
from http.server import SimpleHTTPRequestHandler

import grpc
from mapreduce.reduce.reduce import run_reduce

path = os.path.dirname(os.path.abspath(__file__))
path_grpc = os.path.abspath(os.path.join(path, "..", "rpc", "generated"))

if path_grpc not in os.sys.path:
    sys.path.append(path_grpc)

try:
    import wordcount_pb2 as pb2
    import wordcount_pb2_grpc as pb2_grpc
except ModuleNotFoundError:
    print("\n⚠️ [Warning] gRPC generated files not found")
    pb2, pb2_grpc = None, None

WORKERS = []


def split_text(text: str, chunk_size: int = 100) -> list[str]:
    """
    Splits the input text into chunks of approximately 'chunk_size' words.
    """
    words = text.split()
    chunks = []
    for i in range(0, len(words), chunk_size):
        chunks.append(" ".join(words[i : i + chunk_size]))
    return chunks


def distribute_map_tasks(chunks: list[str]) -> list[dict]:
    """
    Distributes map tasks across registered workers using gRPC.
    """
    partial_results = []

    for i, chunk in enumerate(chunks):
        worker = WORKERS[i % len(WORKERS)]
        print(f"[Master] Sending chunk to {worker}")

        try:
            channel = grpc.insecure_channel(worker)
            stub = pb2_grpc.WordCountWorkerServiceStub(channel)
            request = pb2.CountWordsRequest(text=chunk)
            response = stub.CountWords(request)
            partial_results.append(dict(response.counts))
        except Exception as e:
            print(f"[Master] Error communicating with worker {worker}: {e}")

    return partial_results


class MasterHandler(SimpleHTTPRequestHandler):
    """
    HTTP Handler for the Master node, providing API endpoints and serving the GUI.
    """

    def translate_path(self, path: str) -> str:
        base_dir = os.path.dirname(os.path.abspath(__file__))
        static_dir = os.path.join(base_dir, "static")

        if path == "/" or path == "/index.html":
            return os.path.join(static_dir, "index.html")

        return os.path.join(static_dir, path.lstrip("/"))

    def do_POST(self) -> None:
        if self.path == "/api/count":
            content_length = int(self.headers["Content-Length"])
            post_data = self.rfile.read(content_length)

            try:
                payload = json.loads(post_data.decode("utf-8"))
                text = payload.get("text", "")
            except Exception:
                text = ""

            if not WORKERS:
                self.send_response(503)
                self.end_headers()
                self.wfile.write(b"No workers available")
                return

            print(f"[Master] Processing request: {len(text)} characters")
            start_time = time.perf_counter()
            chunks = split_text(text, chunk_size=50)
            partial_results = distribute_map_tasks(chunks)

            final_result = run_reduce(partial_results)
            end_time = time.perf_counter()
            execution_time = end_time - start_time

            word_counts = sorted(final_result.items(), key=lambda x: x[1], reverse=True)
            response_data = {
                "summary": {
                    "total_words": sum(final_result.values()),
                    "unique_words": len(final_result),
                    "execution_time_ms": execution_time * 1000,
                },
                "word_counts": word_counts,
            }

            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps(response_data).encode("utf-8"))

        elif self.path == "/register":
            content_length = int(self.headers["Content-Length"])
            body = self.rfile.read(content_length)
            data = json.loads(body)
            worker_address = data.get("worker")

            if worker_address and worker_address not in WORKERS:
                WORKERS.append(worker_address)
                print(f"[Master] Registered worker: {worker_address}")

            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(b'{"status":"registered"}')
        else:
            self.send_error(404, "Not Found")

    def do_OPTIONS(self):
        # Support CORS preflight requests for local development
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()
