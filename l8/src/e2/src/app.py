from __future__ import annotations

import os
import subprocess
import time
from contextlib import asynccontextmanager
from pathlib import Path

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles

from . import db
from .coordinator import TransferError, TwoPhaseCommitCoordinator
from .log_store import LogStore
from .models import (
    CiudadLiteral,
    CuentaCreate,
    CuentaRow,
    CuentasResponse,
    CuentaUpdate,
    HealthResponse,
    TransferRequest,
    TransferResponse,
)

load_dotenv()
_SRC_DIR = Path(__file__).resolve().parent
_state: dict = {}


@asynccontextmanager
async def lifespan(app: FastAPI):
    log = LogStore()
    _state["log"] = log
    _state["coordinator"] = TwoPhaseCommitCoordinator(log=log)
    yield
    _state.clear()


app = FastAPI(
    title="Red Financiera 2PC Coordinator",
    description="Coordinador HTTP del protocolo Two-Phase Commit sobre 3 sucursales PostgreSQL (Arequipa, Cusco, Trujillo). Transferencias de dinero atómicas entre cuentas distribuidas. Caso de estudio Lab 08 - Sistemas Distribuidos.",
    version="0.2.0",
    lifespan=lifespan,
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
_STATIC_DIR = _SRC_DIR / "static"


@app.get("/")
def index() -> HTMLResponse:
    """Sirve la interfaz web principal."""
    index_path = _STATIC_DIR / "index.html"
    return HTMLResponse(content=index_path.read_text(encoding="utf-8"))


def _coord() -> TwoPhaseCommitCoordinator:
    return _state["coordinator"]


def _log() -> LogStore:
    return _state["log"]


@app.get("/health", response_model=HealthResponse)
def health() -> HealthResponse:
    """Ping a las 3 sucursales. Devuelve 'ok' o 'down' por sucursal."""

    def status(nombre: str) -> str:
        return "ok" if db.health_check(nombre) else "down"

    return HealthResponse(
        arequipa=status("arequipa"), cusco=status("cusco"), trujillo=status("trujillo")
    )


@app.get("/cuentas", response_model=CuentasResponse)
def cuentas() -> CuentasResponse:
    """Consulta las cuentas de las 3 sucursales y las devuelve en una lista plana."""
    rows: list[CuentaRow] = []
    for ciudad in ("arequipa", "cusco", "trujillo"):
        try:
            with db.sucursal_connection(ciudad) as conn:
                items = db.read_cuentas(conn)
        except Exception:
            continue
        for it in items:
            rows.append(
                CuentaRow(
                    ciudad=ciudad,
                    numero_cuenta=it["numero_cuenta"],
                    titular=it["titular"],
                    saldo=it["saldo"],
                )
            )
    return CuentasResponse(cuentas=rows)


@app.post("/cuentas", status_code=201)
def crear_cuenta(req: CuentaCreate) -> dict:
    """Crea una nueva cuenta en la sucursal especificada."""
    try:
        with db.sucursal_connection(req.ciudad) as conn:
            db.create_cuenta(conn, req.numero_cuenta, req.titular, req.saldo)
            conn.commit()
    except Exception as e:
        raise HTTPException(status_code=400, detail=db.simplify_db_error(e)) from e
    return {"message": "Cuenta creada", "numero_cuenta": req.numero_cuenta}


@app.put("/cuentas/{ciudad}/{numero_cuenta}")
def actualizar_cuenta(
    ciudad: CiudadLiteral, numero_cuenta: str, req: CuentaUpdate
) -> dict:
    """Actualiza los datos de una cuenta existente."""
    try:
        with db.sucursal_connection(ciudad) as conn:
            db.update_cuenta(conn, numero_cuenta, req.titular, req.saldo)
            conn.commit()
    except LookupError as e:
        raise HTTPException(status_code=404, detail=str(e)) from e
    except Exception as e:
        raise HTTPException(status_code=400, detail=db.simplify_db_error(e)) from e
    return {"message": "Cuenta actualizada", "numero_cuenta": numero_cuenta}


@app.delete("/cuentas/{ciudad}/{numero_cuenta}")
def eliminar_cuenta(ciudad: CiudadLiteral, numero_cuenta: str) -> dict:
    """Elimina una cuenta de la sucursal especificada."""
    try:
        with db.sucursal_connection(ciudad) as conn:
            db.delete_cuenta(conn, numero_cuenta)
            conn.commit()
    except LookupError as e:
        raise HTTPException(status_code=404, detail=str(e)) from e
    except Exception as e:
        raise HTTPException(status_code=400, detail=db.simplify_db_error(e)) from e
    return {"message": "Cuenta eliminada", "numero_cuenta": numero_cuenta}


@app.post("/transferir", response_model=TransferResponse)
def transferir(req: TransferRequest) -> TransferResponse:
    """
    Coordina la transferencia atómica entre dos cuentas vía 2PC.

    Flujo:
      1) Verifica que origen y destino sean sucursales distintas.
      2) FASE 1 (PREPARE): abre transacciones en ambas sucursales y aplica
         débito/crédito con SELECT FOR UPDATE.
      3) FASE 2A (COMMIT): si ambos PREPARED fueron OK, hace commit
         en cada sucursal. Si algo falla en PREPARED, hace rollback.
    """
    try:
        result = _coord().transferir(
            cuenta_origen=req.cuenta_origen,
            cuenta_destino=req.cuenta_destino,
            ciudad_origen=req.ciudad_origen,
            ciudad_destino=req.ciudad_destino,
            monto=req.monto,
            delay=req.delay,
        )
    except TransferError as e:
        raise HTTPException(status_code=400, detail=str(e)) from e
    return TransferResponse(**result)


@app.get("/log")
def ver_log() -> dict:
    """Devuelve la bitácora 2PC completa (en memoria)."""
    return {"entries": _log().all()}


@app.post("/sucursales/{nombre}/detener")
def detener_sucursal(nombre: CiudadLiteral) -> dict:
    """Detiene el contenedor Docker de una sucursal PostgreSQL."""
    container = f"red_financiera_{nombre}"
    result = subprocess.run(
        ["docker", "stop", container], capture_output=True, text=True, timeout=30
    )
    if result.returncode != 0:
        raise HTTPException(
            status_code=500,
            detail=f"Error deteniendo {container}: {result.stderr.strip()}",
        )
    return {"sucursal": nombre, "estado": "detenido"}


@app.post("/sucursales/{nombre}/iniciar")
def iniciar_sucursal(nombre: CiudadLiteral) -> dict:
    """Inicia el contenedor Docker de una sucursal PostgreSQL y espera a que esté listo."""
    container = f"red_financiera_{nombre}"
    result = subprocess.run(
        ["docker", "start", container], capture_output=True, text=True, timeout=30
    )
    if result.returncode != 0:
        raise HTTPException(
            status_code=500,
            detail=f"Error iniciando {container}: {result.stderr.strip()}",
        )
    for _ in range(10):
        time.sleep(1)
        if db.health_check(nombre):
            return {"sucursal": nombre, "estado": "iniciado"}
    return {
        "sucursal": nombre,
        "estado": "iniciado",
        "aviso": "Base de datos puede no estar lista aún",
    }


app.mount("/", StaticFiles(directory=str(_STATIC_DIR)), name="static")
if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "src.app:app", host="0.0.0.0", port=int(os.getenv("PORT", "9000")), reload=True
    )
