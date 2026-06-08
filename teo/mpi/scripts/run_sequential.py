import csv
import json
import os
import time

from mpi_analysis.core import calculate_metrics


def main():
    input_path = "/data/input.csv"
    output_path = "/data/output/results_sequential.json"

    if not os.path.exists(input_path):
        input_path = "data/input.csv"
        output_path = "data/output/results_sequential.json"

    if not os.path.exists(input_path):
        print(f"Input file {input_path} not found. Generate it first.")
        return

    with open(input_path, "r") as f:
        rows = list(csv.DictReader(f))

    print(f"Processing {len(rows)} rows sequentially...")
    start_time = time.time()

    results = calculate_metrics(rows)

    end_time = time.time()

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "w") as f:
        json.dump(results, f, indent=2)

    print(f"Finished in {end_time - start_time:.4f} seconds")
    print(f"Results written to {output_path}")


if __name__ == "__main__":
    main()
