import statistics


def calculate_metrics(data):
    if not data:
        return {
            "record_count": 0,
            "temperature": {"avg": None, "min": None, "max": None, "std": None},
            "humidity": {"avg": None, "min": None, "max": None, "std": None},
            "wind_speed": {"avg": None, "min": None, "max": None, "std": None},
            "precipitation": {"avg": None, "min": None, "max": None, "std": None},
            "stations": {},
            "predictions": {},
        }

    temps = [float(row["temperature"]) for row in data]
    hums = [float(row["humidity"]) for row in data]
    winds = [float(row["wind_speed"]) for row in data]
    precips = [float(row["precipitation"]) for row in data]

    stations = {}
    for row in data:
        s = row["station_name"]
        stations[s] = stations.get(s, 0) + 1

    predictions = predict_next_values(data)

    return {
        "record_count": len(data),
        "temperature": {
            "avg": round(statistics.mean(temps), 2),
            "min": round(min(temps), 2),
            "max": round(max(temps), 2),
            "std": round(statistics.stdev(temps) if len(temps) > 1 else 0, 2),
        },
        "humidity": {
            "avg": round(statistics.mean(hums), 2),
            "min": round(min(hums), 2),
            "max": round(max(hums), 2),
            "std": round(statistics.stdev(hums) if len(hums) > 1 else 0, 2),
        },
        "wind_speed": {
            "avg": round(statistics.mean(winds), 2),
            "min": round(min(winds), 2),
            "max": round(max(winds), 2),
            "std": round(statistics.stdev(winds) if len(winds) > 1 else 0, 2),
        },
        "precipitation": {
            "avg": round(statistics.mean(precips), 2),
            "min": round(min(precips), 2),
            "max": round(max(precips), 2),
            "std": round(statistics.stdev(precips) if len(precips) > 1 else 0, 2),
        },
        "stations": stations,
        "predictions": predictions,
    }


def predict_next_values(data):
    if len(data) < 3:
        return {"temperature": None, "humidity": None, "wind_speed": None, "precipitation": None}

    n = min(10, len(data))
    recent = data[-n:]

    def linear_predict(values):
        if len(values) < 2:
            return None
        x = list(range(len(values)))
        y = list(values)
        x_mean = sum(x) / len(x)
        y_mean = sum(y) / len(y)
        num = sum((x[i] - x_mean) * (y[i] - y_mean) for i in range(len(x)))
        den = sum((x[i] - x_mean) ** 2 for i in range(len(x)))
        if den == 0:
            return round(values[-1], 2)
        slope = num / den
        intercept = y_mean - slope * x_mean
        next_val = intercept + slope * len(values)
        return round(next_val, 2)

    temps = [float(row["temperature"]) for row in recent]
    hums = [float(row["humidity"]) for row in recent]
    winds = [float(row["wind_speed"]) for row in recent]
    precips = [float(row["precipitation"]) for row in recent]

    return {
        "temperature": linear_predict(temps),
        "humidity": linear_predict(hums),
        "wind_speed": linear_predict(winds),
        "precipitation": linear_predict(precips),
    }


def worker_main(comm):
    rank = comm.Get_rank()

    my_chunk = comm.scatter(None, root=0)

    metrics = calculate_metrics(my_chunk)
    my_result = {
        "worker_rank": rank,
        "record_count": len(my_chunk),
        "metrics": metrics,
    }

    comm.gather(my_result, root=0)