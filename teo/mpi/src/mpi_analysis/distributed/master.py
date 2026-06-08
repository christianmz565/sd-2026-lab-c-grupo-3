import csv
import json
import os
import statistics

import pandas as pd

from mpi_analysis.core import calculate_metrics

INPUT_PATH = os.getenv("INPUT_PATH", "/data/input.csv")
OUTPUT_DIR = os.getenv("OUTPUT_DIR", "/data/output")
OUTPUT_PATH = os.path.join(OUTPUT_DIR, "results.json")


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
        var_data = [
            r["metrics"][var]
            for r in all_results
            if r["metrics"][var]["avg"] is not None
        ]
        if not var_data:
            combined["metrics"][var] = {
                "global_avg": 0,
                "global_min": 0,
                "global_max": 0,
                "global_std": 0,
            }
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

    combined["metrics"]["predictions"] = {}

    all_results_sorted = sorted(all_results, key=lambda x: x["worker_rank"])
    latest_worker_results = all_results_sorted[-1]

    for var in variables:
        if var in latest_worker_results["metrics"]["predictions"]:
            combined["metrics"]["predictions"][var] = latest_worker_results["metrics"][
                "predictions"
            ][var]
        else:
            combined["metrics"]["predictions"][var] = []

    merged_station_metrics = {}
    for var in variables:
        merged_station_metrics[var] = {}
        for r in all_results:
            worker_stations = r["metrics"].get("station_metrics", {}).get(var, {})
            for station, value in worker_stations.items():
                if station not in merged_station_metrics[var]:
                    merged_station_metrics[var][station] = []
                merged_station_metrics[var][station].append(value)

        # Average the collected values
        for station in merged_station_metrics[var]:
            merged_station_metrics[var][station] = round(
                statistics.mean(merged_station_metrics[var][station]), 2
            )

    combined["metrics"]["station_metrics"] = merged_station_metrics
    combined["worker_details"] = all_results
    return combined


def master_main(comm):
    size = comm.Get_size()
    rank = comm.Get_rank()

    rows = read_csv(INPUT_PATH)
    print(f"[Master] Read {len(rows)} rows from {INPUT_PATH}")

    global_hist = {}
    variables = ["temperature", "humidity", "wind_speed", "precipitation"]
    df_full = pd.DataFrame(rows)
    for var in variables:
        df_full[var] = pd.to_numeric(df_full[var])
        global_hist[var] = df_full[var].tail(100).tolist()

    chunks = split_data(rows, size)
    print(f"[Master] Split into {size} chunks: {[len(c) for c in chunks]}")

    my_chunk = comm.scatter(chunks, root=0)

    my_metrics = calculate_metrics(my_chunk)
    my_result = {
        "worker_rank": rank,
        "record_count": len(my_chunk),
        "metrics": my_metrics,
    }

    all_results = comm.gather(my_result, root=0)

    combined = combine_metrics(all_results)
    combined["metrics"]["historical_sample"] = global_hist

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
