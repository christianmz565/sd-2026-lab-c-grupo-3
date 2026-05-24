# START-SNIPPET,distribute
def distribute_map_tasks(chunks: list[str]) -> list[dict]:
    """
    Distributes map tasks across registered workers using gRPC.
    """
    def process_chunk(args):
        i, chunk = args
        worker = WORKERS[i % len(WORKERS)]
        try:
            with grpc.insecure_channel(worker, options=options) as channel:
                stub = pb2_grpc.WordCountWorkerServiceStub(channel)
                request = pb2.CountWordsRequest(text=chunk)
                response = stub.CountWords(request, timeout=60)
                return dict(response.counts)
        except Exception as e:
            return {}

    with concurrent.futures.ThreadPoolExecutor(
        max_workers=min(20, len(WORKERS) * 2)
    ) as executor:
        results = list(executor.map(process_chunk, enumerate(chunks)))
    return [r for r in results if r]
# END-SNIPPET
