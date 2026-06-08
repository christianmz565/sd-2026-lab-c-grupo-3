import csv
import json
import os
import statistics
from mpi_analysis.core import calculate_metrics


INPUT_PATH = "/data/input.csv"
OUTPUT_DIR = "/data/output"
OUTPUT_PATH = f"{OUTPUT_DIR}/results.json"


def read_csv(path):
    with open(path, "r") as f:
        return list(csv.DictReader(f))


def split_data(data, n_chunks):
    chunk_size = len(data) // n_chunks
    return [
        data[i * chunk_size : (i + 1) * chunk_size if i < n_chunks - 1 else len(data)]
        for i in range(n_chunks)
    ]


def combine_metrics(all_results):
    combined = {
        "total_records": sum(r["record_count"] for r in all_results),
        "workers_used": len(all_results),
        "metrics": {},
    }

    variables = ["temperature", "humidity", "wind_speed", "precipitation"]
    for var in variables:
        var_data = [r["metrics"][var] for r in all_results if r["metrics"][var]["avg"] is not None]
        if not var_data:
            combined["metrics"][var] = {"global_avg": 0, "global_min": 0, "global_max": 0, "global_std": 0}
            continue
            
        combined["metrics"][var] = {
            "global_avg": round(statistics.mean([d["avg"] for d in var_data]), 2),
            "global_min": round(min(d["min"] for d in var_data), 2),
            "global_max": round(max(d["max"] for d in var_data), 2),
            "global_std": round(statistics.mean([d["std"] for d in var_data]), 2),
        }

    all_stations = {}
    for r in all_results:
        for station, count in r["metrics"]["stations"].items():
            all_stations[station] = all_stations.get(station, 0) + count
    combined["metrics"]["stations"] = all_stations

    pred_temps = [r["metrics"]["predictions"]["temperature"] for r in all_results if "temperature" in r["metrics"]["predictions"] and r["metrics"]["predictions"]["temperature"] is not None]

    combined["metrics"]["predictions"] = {
        "temperature": round(statistics.mean(pred_temps), 2) if pred_temps else None,
    }

    combined["worker_details"] = all_results
    return combined


def master_main(comm):
    size = comm.Get_size()
    rank = comm.Get_rank()

    rows = read_csv(INPUT_PATH)
    print(f"[Master] Read {len(rows)} rows from {INPUT_PATH}")

    chunks = split_data(rows, size)
    print(f"[Master] Split into {size} chunks: {[len(c) for c in chunks]}")

    # Root also receives its own chunk
    my_chunk = comm.scatter(chunks, root=0)

    # Master processes its chunk too
    my_metrics = calculate_metrics(my_chunk)
    my_result = {
        "worker_rank": rank,
        "record_count": len(my_chunk),
        "metrics": my_metrics,
    }

    all_results = comm.gather(my_result, root=0)

    combined = combine_metrics(all_results)

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    output = {
        "metadata": {
            "total_records": combined["total_records"],
            "workers_used": combined["workers_used"],
            "input_file": INPUT_PATH,
        },
        "metrics": combined["metrics"],
        "worker_details": combined["worker_details"],
    }
    with open(OUTPUT_PATH, "w") as f:
        json.dump(output, f, indent=2)

    print(f"[Master] Wrote results to {OUTPUT_PATH}")
