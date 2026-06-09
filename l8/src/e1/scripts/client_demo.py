"""Cliente CLI que demuestra el flujo del Ejercicio 1: Transferencia Exitosa.

Uso:
    uv run python scripts/client_demo.py
        # Ejecuta la transferencia canónica: 20 und. de Paracetamol
        # desde Arequipa hacia Lima.

    uv run python scripts/client_demo.py --origen lima --destino cusco \
        --producto Aspirina --cantidad 10
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import requests

DEFAULT_BASE = "http://127.0.0.1:9000"


def main() -> int:
    parser = argparse.ArgumentParser(description="Cliente demo FarmaAndes 2PC")
    parser.add_argument("--base", default=DEFAULT_BASE, help="URL base del servidor")
    parser.add_argument("--origen", default="arequipa")
    parser.add_argument("--destino", default="lima")
    parser.add_argument("--producto", default="Paracetamol")
    parser.add_argument("--cantidad", type=int, default=20)
    args = parser.parse_args()

    base = args.base.rstrip("/")

    def step(label: str) -> None:
        print(f"\n=== {label} ===")

    step(f"GET {base}/health")
    r = requests.get(f"{base}/health", timeout=5)
    print(r.status_code, r.json())
    r.raise_for_status()

    step(f"GET {base}/inventario (antes)")
    r = requests.get(f"{base}/inventario", timeout=5)
    print(r.status_code, json.dumps(r.json(), indent=2, ensure_ascii=False))
    r.raise_for_status()

    step(
        f"POST {base}/transferir "
        f"({args.origen} -> {args.destino}, {args.cantidad} x {args.producto})"
    )
    payload = {
        "origen": args.origen,
        "destino": args.destino,
        "producto": args.producto,
        "cantidad": args.cantidad,
    }
    r = requests.post(f"{base}/transferir", json=payload, timeout=10)
    print(r.status_code, json.dumps(r.json(), indent=2, ensure_ascii=False))
    r.raise_for_status()

    step(f"GET {base}/inventario (después)")
    r = requests.get(f"{base}/inventario", timeout=5)
    print(r.status_code, json.dumps(r.json(), indent=2, ensure_ascii=False))
    r.raise_for_status()

    step(f"GET {base}/log (últimas 10)")
    r = requests.get(f"{base}/log", timeout=5)
    print(r.status_code, json.dumps(r.json()["entries"][-10:], indent=2, ensure_ascii=False))
    r.raise_for_status()

    return 0


if __name__ == "__main__":
    sys.exit(main())
