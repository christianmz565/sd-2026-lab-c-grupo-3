import os
import sys
import grpc
from concurrent import futures

from http.server import HTTPServer

from mapreduce.map.map import run_map
from mapreduce.reduce.reduce import run_reduce

from mapreduce.master_handler import MasterHandler

path = os.path.dirname(os.path.abspath(__file__))
path_grpc = os.path.abspath(os.path.join(path, "grpc"))

if path_grpc not in os.sys.path:
    sys.path.append(path_grpc)
   
# Try to import gRPC generated files, but handle the case where they don't exist.
try:
    import wordcount_pb2 as pb2
    import wordcount_pb2_grpc as pb2_grpc
except ModuleNotFoundError:
    print(f"\n⚠️ [Warning] gRPC generated files not found")
    pb2, pb2_grpc = None, None


# Define proto service
class WordCountWorkerServicer(pb2_grpc.WordCountServiceServicer):
    def CountWords(self, request, context):
        print(f"[Worker] Received text chunk of size {len(request.text)}")
        
        mapped_data = run_map(request.text)
        total_counts = run_reduce(mapped_data)
    
        return pb2.WordCountResponse(counts=total_counts)

def run_master() -> None:
    # Daniel here
    print("role=master")
    
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
    print("role=worker - Starting gRPC server...")
    
    # Create and start gRPC server
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    pb2_grpc.add_WordCountServiceServicer_to_server(WordCountWorkerServicer(), server)
    
    # Listen on port 50051
    server.add_insecure_port('[::]:50051')
    server.start()
    print("[Worker] gRPC server started on port 50051")
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
