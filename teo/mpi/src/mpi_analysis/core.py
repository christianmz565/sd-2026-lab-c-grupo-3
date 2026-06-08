import statistics
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor

def calculate_metrics(data):
    if not data:
        return {
            "record_count": 0,
            "temperature": {"avg": 0, "min": 0, "max": 0, "std": 0},
            "humidity": {"avg": 0, "min": 0, "max": 0, "std": 0},
            "wind_speed": {"avg": 0, "min": 0, "max": 0, "std": 0},
            "precipitation": {"avg": 0, "min": 0, "max": 0, "std": 0},
            "stations": {},
            "predictions": {},
        }

    df = pd.DataFrame(data)
    # Convert types
    for col in ["temperature", "humidity", "wind_speed", "precipitation"]:
        df[col] = pd.to_numeric(df[col])

    stations = df["station_name"].value_counts().to_dict()

    predictions = predict_heavy_compute(df)

    return {
        "record_count": len(df),
        "temperature": {
            "avg": round(df["temperature"].mean(), 2),
            "min": round(df["temperature"].min(), 2),
            "max": round(df["temperature"].max(), 2),
            "std": round(df["temperature"].std(), 2) if len(df) > 1 else 0,
        },
        "humidity": {
            "avg": round(df["humidity"].mean(), 2),
            "min": round(df["humidity"].min(), 2),
            "max": round(df["humidity"].max(), 2),
            "std": round(df["humidity"].std(), 2) if len(df) > 1 else 0,
        },
        "wind_speed": {
            "avg": round(df["wind_speed"].mean(), 2),
            "min": round(df["wind_speed"].min(), 2),
            "max": round(df["wind_speed"].max(), 2),
            "std": round(df["wind_speed"].std(), 2) if len(df) > 1 else 0,
        },
        "precipitation": {
            "avg": round(df["precipitation"].mean(), 2),
            "min": round(df["precipitation"].min(), 2),
            "max": round(df["precipitation"].max(), 2),
            "std": round(df["precipitation"].std(), 2) if len(df) > 1 else 0,
        },
        "stations": stations,
        "predictions": predictions,
    }


def predict_heavy_compute(df):
    """
    Simulates a heavy compute task using Random Forest Regressor.
    Predicts next temperature based on current values.
    """
    if len(df) < 50:
        return {"temperature": None}

    # Features: humidity, wind_speed, precipitation
    # Target: temperature
    X = df[["humidity", "wind_speed", "precipitation"]].values
    y = df["temperature"].values

    # Increase complexity to make it heavy
    model = RandomForestRegressor(n_estimators=500, max_depth=12, n_jobs=1)
    model.fit(X, y)
    
    # Predict on the last row
    last_row = X[-1].reshape(1, -1)
    prediction = model.predict(last_row)[0]

    return {
        "temperature": round(float(prediction), 2)
    }
