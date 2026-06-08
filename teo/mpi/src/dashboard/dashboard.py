import json
import os
import subprocess
from datetime import datetime

import dash
import dash_bootstrap_components as dbc
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from dash import Input, Output, State, dcc, html

INPUT_PATH = os.getenv("INPUT_PATH", "/data/input.csv")
OUTPUT_PATH = os.getenv("OUTPUT_PATH", "/data/output/results.json")
SCRIPTS_DIR = "scripts"

app = dash.Dash(
    __name__,
    external_stylesheets=[dbc.themes.FLATLY],
    title="Panel de Análisis Meteorológico",
)


def create_header():
    return dbc.NavbarSimple(
        brand="Sistema de Análisis de Datos Meteorológicos",
        brand_href="#",
        color="primary",
        dark=True,
        className="mb-4",
    )


def create_control_panel():
    return dbc.Card(
        [
            dbc.CardHeader(html.H5("Controles del Sistema", className="mb-0")),
            dbc.CardBody(
                [
                    html.Div(
                        [
                            dbc.Label("Cantidad de Filas a Generar"),
                            dbc.Input(
                                id="rows-input",
                                type="number",
                                value=10000,
                                step=1000,
                                className="mb-3",
                            ),
                        ]
                    ),
                    dbc.Button(
                        "Regenerar Datos y Ejecutar",
                        id="run-pipeline-btn",
                        color="danger",
                        className="w-100 mb-2",
                    ),
                    dbc.Button(
                        "Actualizar Panel",
                        id="refresh-btn",
                        color="secondary",
                        className="w-100",
                    ),
                    dcc.Loading(
                        id="loading-pipeline",
                        type="circle",
                        children=html.Div(
                            id="pipeline-status", className="mt-3 small text-muted"
                        ),
                    ),
                ]
            ),
        ],
        className="mb-4",
    )


def create_stats_cards(data=None):
    if not data:
        return dbc.Row(
            [
                dbc.Col(
                    dbc.Alert(
                        "No hay datos procesados disponibles. Ejecute el pipeline para comenzar.",
                        color="warning",
                    )
                ),
            ]
        )

    meta = data.get("metadata", {})
    metrics = data.get("metrics", {})

    cards = [
        ("Registros Totales", f"{meta.get('total_records', 0):,}", "info"),
        (
            "Temperatura Global",
            f"{metrics.get('temperature', {}).get('global_avg', 0)} °C",
            "success",
        ),
        (
            "Humedad Promedio",
            f"{metrics.get('humidity', {}).get('global_avg', 0)} %",
            "primary",
        ),
        (
            "Velocidad de Viento",
            f"{metrics.get('wind_speed', {}).get('global_avg', 0)} km/h",
            "warning",
        ),
    ]

    return dbc.Row(
        [
            dbc.Col(
                dbc.Card(
                    [
                        dbc.CardBody(
                            [
                                html.H6(
                                    title, className="card-subtitle text-muted mb-2"
                                ),
                                html.H4(value, className="card-title"),
                            ]
                        )
                    ],
                    color=color,
                    outline=True,
                ),
                md=3,
            )
            for title, value, color in cards
        ],
        className="mb-4",
    )


def create_visualizations(data=None):
    if not data:
        return html.Div()

    metrics = data.get("metrics", {})
    predictions = metrics.get("predictions", {})
    historical = metrics.get("historical_sample", {})
    station_metrics = metrics.get("station_metrics", {})

    variables = [
        ("temperature", "Temperatura (°C)", "#ff7f0e"),
        ("humidity", "Humedad (%)", "#1f77b4"),
        ("wind_speed", "Viento (km/h)", "#2ca02c"),
        ("precipitation", "Precipitación (mm)", "#d62728"),
    ]

    ts_charts = []
    for var_key, label, color in variables:
        fig = go.Figure()

        hist_y = historical.get(var_key, [])
        pred_y = predictions.get(var_key, [])

        hist_df = pd.Series(hist_y)
        ma_y = hist_df.rolling(window=12, min_periods=1).mean().dropna().tolist()

        if hist_y:
            fig.add_trace(
                go.Scatter(
                    x=list(range(-len(ma_y) + 1, 1)),
                    y=ma_y,
                    mode="lines",
                    name="Tendencia Histórica",
                    line=dict(color="#444444", width=3),
                )
            )

        if pred_y:
            combined_pred_y = [ma_y[-1]] + pred_y if ma_y else pred_y
            combined_pred_x = list(range(0, len(pred_y) + (1 if ma_y else 0)))

            fig.add_trace(
                go.Scatter(
                    x=combined_pred_x,
                    y=combined_pred_y,
                    mode="lines",
                    name="Proyección",
                    line=dict(color=color, width=4, dash="solid"),
                )
            )

        fig.update_layout(
            title=f"Evolución de {label}",
            xaxis_title="Tiempo Relativo",
            yaxis_title=label,
            template="plotly_white",
            legend=dict(
                orientation="h", yanchor="bottom", y=1.02, xanchor="right", x=1
            ),
            margin=dict(l=40, r=40, t=80, b=40),
            height=350,
        )
        ts_charts.append(dbc.Col(dcc.Graph(figure=fig), md=6, className="mb-4"))

    station_charts = []

    def create_station_bar(metric_key, title, color):
        data_map = station_metrics.get(metric_key, {})
        if not data_map:
            return None
        df = pd.DataFrame(
            [{"Estación": k, "Valor": v} for k, v in data_map.items()]
        ).sort_values("Valor")
        fig = px.bar(
            df,
            x="Valor",
            y="Estación",
            orientation="h",
            title=title,
            template="plotly_white",
            color_discrete_sequence=[color],
        )
        fig.update_layout(
            height=300,
            margin=dict(l=20, r=20, t=50, b=20),
            xaxis_title="Valor Promedio",
            yaxis_title="",
        )
        return dbc.Col(dcc.Graph(figure=fig), md=6, className="mb-4")

    station_charts.append(
        create_station_bar(
            "temperature", "Temperatura Promedio por Estación", "#ff7f0e"
        )
    )
    station_charts.append(
        create_station_bar("humidity", "Humedad Promedio por Estación", "#1f77b4")
    )
    station_charts.append(
        create_station_bar("wind_speed", "Velocidad de Viento por Estación", "#2ca02c")
    )
    station_charts.append(
        create_station_bar(
            "precipitation", "Precipitación Acumulada por Estación", "#d62728"
        )
    )

    return html.Div(
        [
            html.H4(
                "Análisis de Tendencias y Proyecciones",
                className="mb-3 mt-4 text-primary border-bottom pb-2",
            ),
            dbc.Row(ts_charts),
            html.Hr(),
            html.H4(
                "Desglose Geoestadístico por Estación",
                className="mb-3 mt-4 text-primary border-bottom pb-2",
            ),
            dbc.Row([c for c in station_charts if c is not None]),
        ]
    )


app.layout = html.Div(
    [
        create_header(),
        dbc.Container(
            [
                dbc.Row(
                    [
                        dbc.Col(create_control_panel(), md=3),
                        dbc.Col(
                            [
                                html.Div(id="stats-container"),
                                html.Div(id="viz-container"),
                            ],
                            md=9,
                        ),
                    ]
                ),
            ],
            fluid=True,
        ),
        dcc.Interval(id="auto-refresh", interval=60 * 1000, n_intervals=0),
    ]
)


@app.callback(
    [
        Output("stats-container", "children"),
        Output("viz-container", "children"),
        Output("pipeline-status", "children"),
    ],
    [
        Input("run-pipeline-btn", "n_clicks"),
        Input("refresh-btn", "n_clicks"),
        Input("auto-refresh", "n_intervals"),
    ],
    [State("rows-input", "value")],
)
def update_dashboard(run_n, refresh_n, auto_n, rows):
    ctx = dash.callback_context
    status_msg = ""
    np_val = 4

    if ctx.triggered:
        prop_id = ctx.triggered[0]["prop_id"].split(".")[0]
        if prop_id == "run-pipeline-btn" and run_n:
            try:
                print(
                    f"[{datetime.now().strftime('%H:%M:%S')}] Starting data generation: {rows} rows"
                )
                status_msg = "Generando datos..."
                gen_cmd = [
                    "uv",
                    "run",
                    os.path.join(SCRIPTS_DIR, "generate_data.py"),
                    "--output",
                    INPUT_PATH,
                    "--rows",
                    str(rows),
                ]
                subprocess.run(gen_cmd, check=True, capture_output=True, text=True)

                print(
                    f"[{datetime.now().strftime('%H:%M:%S')}] Starting MPI processing"
                )
                status_msg = "Procesando datos..."
                mpi_cmd = ["bash", os.path.join(SCRIPTS_DIR, "run_mpi.sh"), str(np_val)]
                result = subprocess.run(
                    mpi_cmd, check=True, capture_output=True, text=True
                )
                print(f"MPI STDOUT: {result.stdout}")

                status_msg = (
                    f"Última ejecución: {datetime.now().strftime('%H:%M:%S')} (Éxito)"
                )
                print(
                    f"[{datetime.now().strftime('%H:%M:%S')}] Pipeline finished successfully"
                )
            except subprocess.CalledProcessError as e:
                err_msg = e.stderr if e.stderr else e.stdout
                print(f"PIPELINE ERROR ({e.returncode}):\n{err_msg}")
                status_msg = (
                    f"Error en pipeline: {err_msg[:1000]}..."
                    if err_msg
                    else "Error en pipeline"
                )
            except Exception as e:
                print(f"UNEXPECTED ERROR: {str(e)}")
                status_msg = f"Error inesperado: {str(e)}"

    data = None
    if os.path.exists(OUTPUT_PATH):
        try:
            with open(OUTPUT_PATH, "r") as f:
                data = json.load(f)
        except Exception as e:
            print(f"ERROR LOADING DATA: {str(e)}")

    return create_stats_cards(data), create_visualizations(data), status_msg


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8050, debug=True, use_reloader=False)
