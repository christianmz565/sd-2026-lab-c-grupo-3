import csv
import json
import os
import statistics


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
        all_values = []
        for r in all_results:
            vals = r["metrics"][var]
            all_values.extend([vals["min"], vals["max"], vals["avg"]])

        var_data = [r["metrics"][var] for r in all_results]
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

    pred_temps = [r["metrics"]["predictions"]["temperature"] for r in all_results if r["metrics"]["predictions"]["temperature"] is not None]
    pred_hums = [r["metrics"]["predictions"]["humidity"] for r in all_results if r["metrics"]["predictions"]["humidity"] is not None]
    pred_winds = [r["metrics"]["predictions"]["wind_speed"] for r in all_results if r["metrics"]["predictions"]["wind_speed"] is not None]
    pred_precips = [r["metrics"]["predictions"]["precipitation"] for r in all_results if r["metrics"]["predictions"]["precipitation"] is not None]

    combined["metrics"]["predictions"] = {
        "temperature": round(statistics.mean(pred_temps), 2) if pred_temps else None,
        "humidity": round(statistics.mean(pred_hums), 2) if pred_hums else None,
        "wind_speed": round(statistics.mean(pred_winds), 2) if pred_winds else None,
        "precipitation": round(statistics.mean(pred_precips), 2) if pred_precips else None,
    }

    combined["worker_details"] = all_results
    return combined


def master_main(comm):
    size = comm.Get_size()

    rows = read_csv(INPUT_PATH)
    print(f"[Master] Read {len(rows)} rows from {INPUT_PATH}")

    chunks = split_data(rows, size)
    print(f"[Master] Split into {size} chunks: {[len(c) for c in chunks]}")

    comm.scatter(chunks, root=0)

    all_results = comm.gather(None, root=0)

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