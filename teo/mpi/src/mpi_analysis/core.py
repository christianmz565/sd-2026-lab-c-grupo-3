import logging

import numpy as np
import pandas as pd
from sklearn.linear_model import Ridge
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import PolynomialFeatures, StandardScaler

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger("mpi_analysis.core")


def calculate_metrics(data):
    if not data:
        logger.warning("Empty data received in calculate_metrics")
        return {
            "record_count": 0,
            "temperature": {"avg": 0, "min": 0, "max": 0, "std": 0},
            "humidity": {"avg": 0, "min": 0, "max": 0, "std": 0},
            "wind_speed": {"avg": 0, "min": 0, "max": 0, "std": 0},
            "precipitation": {"avg": 0, "min": 0, "max": 0, "std": 0},
            "stations": {},
            "predictions": {},
            "historical_sample": {},
            "station_metrics": {},
        }

    df = pd.DataFrame(data)
    cols = ["temperature", "humidity", "wind_speed", "precipitation"]
    for col in cols:
        df[col] = pd.to_numeric(df[col])

    stations_count = df["station_name"].value_counts().to_dict()

    station_metrics = df.groupby("station_name")[cols].mean().to_dict()

    predictions = predict_heavy_compute(df)

    historical_sample = {}
    for col in cols:
        historical_sample[col] = df[col].tail(100).tolist()

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
        "stations": stations_count,
        "predictions": predictions,
        "historical_sample": historical_sample,
        "station_metrics": station_metrics,
    }


def predict_heavy_compute(df):
    results = {}
    cols = ["temperature", "humidity", "wind_speed", "precipitation"]
    PRED_COUNT = 100

    if len(df) < 50:
        logger.debug(f"Insufficient data for prediction ({len(df)} rows)")
        return {col: [0.0] * PRED_COUNT for col in cols}

    try:
        df = df.copy()
        df["dt"] = pd.to_datetime(df["timestamp"])

        def extract_features(dt_series):
            hours = (
                dt_series.dt.hour
                + dt_series.dt.minute / 60.0
                + dt_series.dt.second / 3600.0
            )
            dows = dt_series.dt.dayofweek
            ref_date = pd.Timestamp("2026-01-01")
            days_since = (dt_series - ref_date).dt.total_seconds() / 86400.0

            seasonal_p = 30.0

            base_f = np.column_stack(
                [
                    days_since,
                    np.sin(2 * np.pi * hours / 24),
                    np.cos(2 * np.pi * hours / 24),
                    np.sin(2 * np.pi * dows / 7),
                    np.cos(2 * np.pi * dows / 7),
                    np.sin(2 * np.pi * days_since / seasonal_p),
                    np.cos(2 * np.pi * days_since / seasonal_p),
                ]
            )
            return base_f

        X = extract_features(df["dt"])

        last_dt = df["dt"].max()
        future_dts = pd.Series(
            [last_dt + pd.Timedelta(seconds=30 * i) for i in range(1, PRED_COUNT + 1)]
        )
        X_future = extract_features(future_dts)

        for col in cols:
            y = df[col].values

            model = make_pipeline(
                StandardScaler(),
                PolynomialFeatures(degree=2, include_bias=False),
                Ridge(alpha=0.1),
            )

            model.fit(X, y)
            preds = model.predict(X_future)

            results[col] = [round(float(p), 3) for p in preds]

            p_min, p_max = min(preds), max(preds)
            p_range = p_max - p_min
            logger.info(
                f"[{col}] Prediction: start={preds[0]:.3f}, end={preds[-1]:.3f}, range={p_range:.6f}"
            )

    except Exception as e:
        logger.error(f"Error during prediction: {e}", exc_info=True)
        return {col: [0.0] * PRED_COUNT for col in cols}

    return results
