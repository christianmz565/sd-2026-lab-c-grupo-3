# START-SNIPPET,worker
class WordCountWorkerServicer(pb2_grpc.WordCountWorkerServiceServicer):
    def CountWords(self, request, context):
        print(f"[Worker] Received text chunk of size {len(request.text)}")
        mapped_data = run_map(request.text)
        return pb2.CountWordsResponse(counts=mapped_data)

def run_worker() -> None:
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10), options=options)
    pb2_grpc.add_WordCountWorkerServiceServicer_to_server(
        WordCountWorkerServicer(), server
    )
    server.add_insecure_port(f"[::]:{port}")
    server.start()
    register_worker(f"{worker_host}:{port}")
    server.wait_for_termination()
# END-SNIPPET
