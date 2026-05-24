import os
import sys
from concurrent import futures
from http.server import HTTPServer

import grpc
import requests

from mapreduce.map.map import run_map
from mapreduce.master_handler import MasterHandler

path = os.path.dirname(os.path.abspath(__file__))
path_grpc = os.path.abspath(os.path.join(path, "..", "rpc", "generated"))

if path_grpc not in os.sys.path:
    sys.path.append(path_grpc)

try:
    import wordcount_pb2 as pb2
    import wordcount_pb2_grpc as pb2_grpc
except ModuleNotFoundError:
    print("\n[Warning] gRPC generated files not found")
    pb2, pb2_grpc = None, None


class WordCountWorkerServicer(pb2_grpc.WordCountWorkerServiceServicer):
    def CountWords(self, request, context):
        print(f"[Worker] Received text chunk of size {len(request.text)}")

        mapped_data = run_map(request.text)

        return pb2.CountWordsResponse(counts=mapped_data)


def register_worker(worker_address: str) -> None:
    """
    Registers the worker with the master node.
    """
    master_host = os.environ.get("MASTER_HOST", "localhost")
    master_url = f"http://{master_host}:9000/register"
    payload = {"worker": worker_address}
    try:
        response = requests.post(master_url, json=payload, timeout=5)
        if response.status_code == 200:
            print(f"[Worker] Successfully registered at {master_url}")
        else:
            print(f"[Worker] Registration failed with status {response.status_code}")
    except Exception as e:
        print(f"[Worker] Error registering with master: {e}")


def run_master() -> None:
    """
    Starts the HTTP server for the master node.
    """
    port = 9000
    server_address = ("", port)
    httpd = HTTPServer(server_address, MasterHandler)
    print(f"\033[92m[Master] HTTP server listening on http://localhost:{port}/\033[0m")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n[Master] Stopping HTTP server...")
        httpd.server_close()


def run_worker() -> None:
    """
    Starts the gRPC server for the worker node and registers with the master.
    """
    import socket

    print("[Worker] Starting gRPC server...")
    port = os.environ.get("WORKER_PORT", "50051")

    worker_host = os.environ.get("WORKER_HOST", socket.gethostname())

    options = [
        ("grpc.max_send_message_length", 100 * 1024 * 1024),
        ("grpc.max_receive_message_length", 100 * 1024 * 1024),
    ]
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10), options=options)
    pb2_grpc.add_WordCountWorkerServiceServicer_to_server(
        WordCountWorkerServicer(), server
    )

    server.add_insecure_port(f"[::]:{port}")
    server.start()

    register_worker(f"{worker_host}:{port}")

    print(f"[Worker] gRPC server started on {worker_host}:{port}")
    server.wait_for_termination()


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
