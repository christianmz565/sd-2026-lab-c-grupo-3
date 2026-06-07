import argparse
import csv
import random
from datetime import datetime, timedelta
from pathlib import Path

STATIONS = [
    "Quito",
    "Guayaquil",
    "Cuenca",
    "Ambato",
    "Machala",
    "Portoviejo",
    "Durán",
    "Ibarra",
    "Loja",
    "Riobamba",
]

HEADERS = ["timestamp", "station_name", "temperature", "humidity", "wind_speed", "precipitation"]


def generate_row(timestamp: datetime, station: str) -> dict:
    return {
        "timestamp": timestamp.isoformat(),
        "station_name": station,
        "temperature": round(random.uniform(5.0, 35.0), 1),
        "humidity": round(random.uniform(20.0, 100.0), 1),
        "wind_speed": round(random.uniform(0.0, 80.0), 1),
        "precipitation": round(random.uniform(0.0, 50.0), 1),
    }


def main():
    parser = argparse.ArgumentParser(description="Generate mock meteorological data")
    parser.add_argument("--rows", type=int, default=1000, help="Number of rows to generate (default: 1000)")
    parser.add_argument(
        "--output",
        type=str,
        default="data/input.csv",
        help="Output CSV file path (default: data/input.csv)",
    )
    parser.add_argument("--seed", type=int, default=None, help="Random seed for reproducibility")
    args = parser.parse_args()

    if args.seed is not None:
        random.seed(args.seed)

    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    start_date = datetime.now() - timedelta(days=30)
    interval = timedelta(minutes=random.randint(15, 60))

    with open(output_path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=HEADERS)
        writer.writeheader()

        current_time = start_date
        for _ in range(args.rows):
            station = random.choice(STATIONS)
            writer.writerow(generate_row(current_time, station))
            current_time += interval

    print(f"Generated {args.rows} rows -> {output_path}")


if __name__ == "__main__":
    main()
