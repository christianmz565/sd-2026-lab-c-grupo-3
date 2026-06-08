import argparse
import csv
import math
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


# Define station-specific tendencies (biases)
STATION_BIASES = {
    "Quito": -5.0,
    "Guayaquil": 7.0,
    "Cuenca": -2.0,
    "Ambato": 0.0,
    "Machala": 5.0,
    "Portoviejo": 4.0,
    "Durán": 6.0,
    "Ibarra": -1.0,
    "Loja": -3.0,
    "Riobamba": -4.0,
}

def generate_row(timestamp: datetime, station: str, index: int, total_rows: int) -> dict:
    # Normalized time (0 to 1 over the whole dataset) for trends
    t = index / total_rows
    
    # Diurnal cycle (24h)
    hour = timestamp.hour + timestamp.minute / 60.0
    
    # Weekly cycle
    day_of_week = timestamp.weekday()
    
    # Base temperature with a slight upward trend and diurnal cycle
    # Incorporate station-specific bias
    station_bias = STATION_BIASES.get(station, 0.0)
    base_temp = 18.0 + station_bias
    
    trend = 8.0 * t  # Increased from 3.0 to 8.0 for clearer trend
    diurnal = 12.0 * math.sin((hour - 6) * math.pi / 12) # Increased from 6.0 to 12.0
    weekly = 3.0 * math.cos(day_of_week * 2 * math.pi / 7) # Increased from 1.5 to 3.0
    
    # Add a longer-term oscillation (seasonal/monthly)
    monthly = 6.0 * math.sin(t * 5)
    
    noise = random.gauss(0, 0.3) # Reduced noise from 0.8 to 0.3
    temperature = base_temp + trend + diurnal + weekly + monthly + noise
    
    # Humidity: strongly inverse to temperature + some independent oscillation
    humidity_base = 85.0 - (temperature - 10) * 1.8
    humidity = humidity_base + 8.0 * math.sin(t * 12) + random.gauss(0, 3)
    humidity = max(10.0, min(100.0, humidity))
    
    # Wind speed: higher in the afternoon, with some gusts
    wind_base = 4.0 + 4.0 * max(0, math.sin((hour - 10) * math.pi / 12))
    wind_speed = wind_base + 10.0 * t + random.uniform(0, 5)
    
    # Precipitation: dependent on humidity and some "storm" periods
    is_storm = math.sin(t * 15) > 0.6
    precip_prob = (humidity / 100.0) * (0.7 if is_storm else 0.05)
    precipitation = round(random.uniform(2, 20), 1) if random.random() < precip_prob else 0.0

    return {
        "timestamp": timestamp.isoformat(),
        "station_name": station,
        "temperature": round(temperature, 1),
        "humidity": round(humidity, 1),
        "wind_speed": round(wind_speed, 1),
        "precipitation": precipitation,
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

    current_time = datetime.now()
    
    rows_data = []
    temp_time = current_time
    # Generate in reverse to use index correctly for trends
    for i in range(args.rows - 1, -1, -1):
        station = random.choice(STATIONS)
        rows_data.append(generate_row(temp_time, station, i, args.rows))
        temp_time -= timedelta(seconds=30)
    
    # Rows were generated with decresing time but increasing index, 
    # so index 0 is at (now - rows*30s) and index (rows-1) is at "now".
    # Just need to sort by timestamp to be sure.
    rows_data.sort(key=lambda x: x["timestamp"])

    with open(output_path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=HEADERS)
        writer.writeheader()
        writer.writerows(rows_data)

    print(f"Generated {args.rows} rows -> {output_path}")


if __name__ == "__main__":
    main()


if __name__ == "__main__":
    main()
