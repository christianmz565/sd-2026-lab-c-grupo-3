"""Cliente CLI que demuestra el flujo del Ejercicio 2: Transferencia Bancaria Exitosa.

Uso:
    uv run python scripts/client_demo.py
        # Ejecuta la transferencia canónica: S/ 25,000 
        # desde cuenta en Arequipa hacia cuenta en Cusco.

    uv run python scripts/client_demo.py --cuenta-origen ACC001 --cuenta-destino ACC201 \
        --ciudad-origen arequipa --ciudad-destino cusco --monto 15000
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import requests

DEFAULT_BASE = "http://localhost:8000"


def main() -> int:
    parser = argparse.ArgumentParser(description="Cliente demo Red Financiera 2PC")
    parser.add_argument("--base", default=DEFAULT_BASE, help="URL base del servidor")
    parser.add_argument("--cuenta-origen", default="ACC001")
    parser.add_argument("--cuenta-destino", default="ACC201")
    parser.add_argument("--ciudad-origen", default="arequipa")
    parser.add_argument("--ciudad-destino", default="cusco")
    parser.add_argument("--monto", type=float, default=25000.0)
    args = parser.parse_args()

    base = args.base.rstrip("/")

    def step(label: str) -> None:
        print(f"\n=== {label} ===")

    step(f"GET {base}/health")
    r = requests.get(f"{base}/health", timeout=5)
    print(r.status_code, r.json())
    r.raise_for_status()

    step(f"GET {base}/cuentas (antes)")
    r = requests.get(f"{base}/cuentas", timeout=5)
    print(r.status_code, json.dumps(r.json(), indent=2, ensure_ascii=False))
    r.raise_for_status()

    step(
        f"POST {base}/transferir "
        f"({args.ciudad_origen} {args.cuenta_origen} -> {args.ciudad_destino} {args.cuenta_destino}, S/ {args.monto:,.2f})"
    )
    payload = {
        "cuenta_origen": args.cuenta_origen,
        "cuenta_destino": args.cuenta_destino,
        "ciudad_origen": args.ciudad_origen,
        "ciudad_destino": args.ciudad_destino,
        "monto": args.monto,
    }
    r = requests.post(f"{base}/transferir", json=payload, timeout=10)
    print(r.status_code, json.dumps(r.json(), indent=2, ensure_ascii=False))
    r.raise_for_status()

    step(f"GET {base}/cuentas (después)")
    r = requests.get(f"{base}/cuentas", timeout=5)
    print(r.status_code, json.dumps(r.json(), indent=2, ensure_ascii=False))
    r.raise_for_status()

    step(f"GET {base}/log (últimas 10)")
    r = requests.get(f"{base}/log", timeout=5)
    print(r.status_code, json.dumps(r.json()["entries"][-10:], indent=2, ensure_ascii=False))
    r.raise_for_status()

    return 0


if __name__ == "__main__":
    sys.exit(main())
