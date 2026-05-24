import json
import os
import time
from http.server import SimpleHTTPRequestHandler
from tracemalloc import start

import grpc
from mapreduce.app import WordCountWorkerServicer
from mapreduce.reduce.reduce import run_reduce

try:
    import wordcount_pb2 as pb2
    import wordcount_pb2_grpc as pb2_grpc
except ModuleNotFoundError:
    print(f"\n⚠️ [Warning] gRPC generated files not found")
    pb2, pb2_grpc = None, None

WORKERS = []


def split_text(text, chunk_size=100):

    words = text.split()

    chunks = []
    for i in range(0, len(words), chunk_size):
        chunks.append(" ".join(words[i : i + chunk_size]))

    return chunks


def distribute_map_tasks(chunks):

    partial_results = []

    for i, chunk in enumerate(chunks):
        worker = WORKERS[i % len(WORKERS)]

        print(f"[Master] Enviando chunk a {worker}")

        channel = grpc.insecure_channel(worker)

        stub = pb2_grpc.WordCountServiceStub(channel)

        request = pb2.WordCountRequest(text=chunk)

        response = stub.CountWords(request)

        partial_results.append(dict(response.counts))

    return partial_results


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

            if len(WORKERS) == 0:
                self.send_response(500)
                self.end_headers()

                self.wfile.write(b"No workers available")
                return

            start = time.perf_counter()
            chunks = split_text(text, chunk_size=50)
            partial_results = distribute_map_tasks(chunks)

            final_result = run_reduce(partial_results)

            end = time.perf_counter()
            execution_time = end - start

            word_counts = sorted(final_result.items(), key=lambda x: x[1], reverse=True)
            mock_response = {
                "summary": {
                    "total_words": sum(final_result[x] for x in final_result),
                    "unique_words": len(final_result),
                    "execution_time_ms": execution_time * 1000,
                },
                "word_counts": word_counts,
            }

            response_bytes = json.dumps(mock_response).encode("utf-8")

            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
            self.send_header("Access-Control-Allow-Headers", "Content-Type")
            self.end_headers()
            self.wfile.write(response_bytes)
        elif self.path == "/register":
            content_length = int(self.headers["Content-Length"])

            body = self.rfile.read(content_length)
            data = json.loads(body)
            worker_address = data.get("worker")

            if worker_address not in WORKERS:
                WORKERS.append(worker_address)

            print(f"[Master] Worker registrado: {worker_address}")

            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header("Access-Control-Allow-Methods", "POST")
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
