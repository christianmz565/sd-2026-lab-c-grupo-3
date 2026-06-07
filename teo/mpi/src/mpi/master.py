import csv
import json
import os


INPUT_PATH = "/data/input.csv"
OUTPUT_PATH = "/data/output/results.json"


def read_csv(path):
    with open(path, "r") as f:
        return list(csv.DictReader(f))


def split_data(data, n_chunks):
    chunk_size = len(data) // n_chunks
    return [
        data[i * chunk_size : (i + 1) * chunk_size if i < n_chunks - 1 else len(data)]
        for i in range(n_chunks)
    ]


def master_main(comm):
    size = comm.Get_size()

    rows = read_csv(INPUT_PATH)
    print(f"[Master] Read {len(rows)} rows from {INPUT_PATH}")

    chunks = split_data(rows, size)
    print(f"[Master] Split into {size} chunks: {[len(c) for c in chunks]}")

    my_chunk = comm.scatter(chunks, root=0)

    my_result = [{"worker_rank": 0, **row} for row in reversed(my_chunk)]

    all_results = comm.gather(my_result, root=0)

    combined = [r for batch in all_results for r in batch]

    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    output = {
        "metadata": {
            "total_records": len(combined),
            "workers_used": size,
            "input_file": INPUT_PATH,
        },
        "results": combined,
    }
    with open(OUTPUT_PATH, "w") as f:
        json.dump(output, f, indent=2)

    print(f"[Master] Wrote {len(combined)} records to {OUTPUT_PATH}")
