"""Aplicación FastAPI: coordinador 2PC para FarmaAndes S.A.

Endpoints:
  GET  /health       - ping a los 3 nodos
  GET  /inventario   - vista agregada del stock en los 3 almacenes
  POST /transferir   - ejecuta una transferencia con protocolo 2PC
  GET  /log          - bitácora en memoria de las últimas transacciones
  POST /nodos/{nombre}/detener  - detiene el contenedor Docker de un nodo
  POST /nodos/{nombre}/iniciar  - inicia el contenedor Docker de un nodo
"""
from __future__ import annotations

import os
import subprocess
import sys
from contextlib import asynccontextmanager
from pathlib import Path

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException

# Permite ejecutar con `uvicorn src.app:app` y `python -m src.app`
_SRC_DIR = Path(__file__).resolve().parent
if str(_SRC_DIR.parent) not in sys.path:
    sys.path.insert(0, str(_SRC_DIR.parent))

from src import db  # noqa: E402
from src.coordinator import TwoPhaseCommitCoordinator, TransferError  # noqa: E402
from src.log_store import LogStore  # noqa: E402
from src.models import (  # noqa: E402
    HealthResponse,
    InventarioResponse,
    InventarioRow,
    NodoLiteral,
    TransferRequest,
    TransferResponse,
)

load_dotenv()

# Estado compartido: log en memoria + coordinador
_state: dict = {}


@asynccontextmanager
async def lifespan(app: FastAPI):
    log = LogStore()
    _state["log"] = log
    _state["coordinator"] = TwoPhaseCommitCoordinator(log=log)
    yield
    _state.clear()


app = FastAPI(
    title="FarmaAndes 2PC Coordinator",
    description=(
        "Coordinador HTTP del protocolo Two-Phase Commit sobre 3 nodos "
        "PostgreSQL (Arequipa, Lima, Cusco). Caso de estudio Lab 08 - "
        "Sistemas Distribuidos."
    ),
    version="0.1.0",
    lifespan=lifespan,
)


def _coord() -> TwoPhaseCommitCoordinator:
    return _state["coordinator"]


def _log() -> LogStore:
    return _state["log"]


@app.get("/health", response_model=HealthResponse)
def health() -> HealthResponse:
    """Ping a los 3 nodos. Devuelve 'ok' o 'down' por nodo."""
    def status(nombre: str) -> str:
        return "ok" if db.health_check(nombre) else "down"

    return HealthResponse(
        arequipa=status("arequipa"),
        lima=status("lima"),
        cusco=status("cusco"),
    )


@app.get("/inventario", response_model=InventarioResponse)
def inventario() -> InventarioResponse:
    """Consulta el inventario de los 3 almacenes y lo devuelve en una lista plana."""
    rows: list[InventarioRow] = []
    for nodo in ("arequipa", "lima", "cusco"):
        try:
            with db.nodo_connection(nodo) as conn:
                items = db.read_inventario(conn)
        except Exception as e:
            raise HTTPException(
                status_code=503,
                detail=f"No se pudo leer inventario de {nodo}: {e}",
            ) from e
        for it in items:
            rows.append(InventarioRow(
                almacen=nodo,  # type: ignore[arg-type]
                producto=it["producto"],
                stock=it["stock"],
            ))
    return InventarioResponse(inventario=rows)


@app.post("/transferir", response_model=TransferResponse)
def transferir(req: TransferRequest) -> TransferResponse:
    """Coordina la transferencia atómica entre dos almacenes vía 2PC.

    Flujo:
      1) Verifica que origen y destino sean nodos distintos.
      2) FASE 1 (PREPARE): abre transacciones en ambos nodos y aplica
         debit/credit con SELECT FOR UPDATE.
      3) FASE 2A (COMMIT): si ambos PREPARED fueron OK, hace commit
         en cada nodo. Si algo falla en PREPARED, hace rollback.
    """
    try:
        result = _coord().transferir(
            origen=req.origen,
            destino=req.destino,
            producto=req.producto,
            cantidad=req.cantidad,
            delay=req.delay,
        )
    except TransferError as e:
        raise HTTPException(status_code=400, detail=str(e)) from e

    return TransferResponse(**result)


@app.get("/log")
def ver_log() -> dict:
    """Devuelve la bitácora 2PC completa (en memoria)."""
    return {"entries": _log().all()}


@app.post("/nodos/{nombre}/detener")
def detener_nodo(nombre: NodoLiteral) -> dict:
    """Detiene el contenedor Docker de un nodo PostgreSQL."""
    container = f"farmaandes_{nombre}"
    result = subprocess.run(
        ["docker", "stop", container],
        capture_output=True, text=True, timeout=30,
    )
    if result.returncode != 0:
        raise HTTPException(status_code=500, detail=f"Error deteniendo {container}: {result.stderr.strip()}")
    return {"nodo": nombre, "estado": "detenido"}


@app.post("/nodos/{nombre}/iniciar")
def iniciar_nodo(nombre: NodoLiteral) -> dict:
    """Inicia el contenedor Docker de un nodo PostgreSQL."""
    container = f"farmaandes_{nombre}"
    result = subprocess.run(
        ["docker", "start", container],
        capture_output=True, text=True, timeout=30,
    )
    if result.returncode != 0:
        raise HTTPException(status_code=500, detail=f"Error iniciando {container}: {result.stderr.strip()}")
    return {"nodo": nombre, "estado": "iniciado"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "src.app:app",
        host="0.0.0.0",
        port=int(os.getenv("PORT", "8000")),
        reload=True,
    )
