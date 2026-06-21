"""
Servicio de Transporte — LogiFresh S.A.
Puerto: 8004

Responsabilidades:
  - Asignar un conductor/vehículo disponible a un pedido confirmado.
  - Gestionar estados de entrega: ASSIGNED → IN_TRANSIT → DELIVERED.
  - Liberar conductor al completar entrega.
"""

import os
import logging
from contextlib import asynccontextmanager
from typing import Optional

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy import create_engine, text
from sqlalchemy.orm import Session
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("transport")

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://logifresh:logifresh_pass@postgres/logifresh")
engine = create_engine(DATABASE_URL, pool_size=10, max_overflow=20)


def get_db():
    with Session(engine) as session:
        yield session


# ─── Schemas ─────────────────────────────────────────────────────────────────

class AssignShipmentRequest(BaseModel):
    order_id: str
    address: str
    client_id: Optional[str] = None


class UpdateStatusRequest(BaseModel):
    status: str  # IN_TRANSIT | DELIVERED


# ─── App ─────────────────────────────────────────────────────────────────────

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Transport service started on port 8004")
    yield

app = FastAPI(
    title="LogiFresh — Servicio de Transporte",
    description="Asignación y seguimiento de envíos refrigerados",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ─── Endpoints ───────────────────────────────────────────────────────────────

@app.get("/health")
def health():
    return {"status": "ok", "service": "transport"}


@app.post("/shipments", status_code=201)#De parte del servicio de orders o del admin
def assign_shipment(req: AssignShipmentRequest, db: Session = Depends(get_db)):
    """
    Asigna el próximo conductor disponible al pedido.
    Si ya existe un envío para ese order_id, devuelve el existente (idempotente).
    """
    # Idempotencia
    existing = db.execute(
        text("SELECT * FROM transport.shipments WHERE order_id = :oid"),
        {"oid": req.order_id},
    ).fetchone()
    if existing:
        logger.info(f"Envío ya asignado para order={req.order_id}")
        return _shipment_to_dict(existing)

    # Busca conductor disponible con FOR UPDATE para evitar doble asignación
    driver = db.execute(
        text("""
            SELECT id, name, vehicle
            FROM transport.drivers
            WHERE is_available = TRUE
            ORDER BY id
            LIMIT 1
            FOR UPDATE SKIP LOCKED
        """)
    ).fetchone()

    if not driver:
        raise HTTPException(
            status_code=503,
            detail="No hay conductores disponibles en este momento"
        )

    # Marca conductor como no disponible
    db.execute(
        text("UPDATE transport.drivers SET is_available = FALSE WHERE id = :id"),
        {"id": driver.id},
    )

    # Crea envío
    row = db.execute(
        text("""
            INSERT INTO transport.shipments (order_id, driver_id, address, status)
            VALUES (:oid, :did, :addr, 'ASSIGNED')
            RETURNING *
        """),
        {"oid": req.order_id, "did": driver.id, "addr": req.address},
    ).fetchone()

    db.commit()

    logger.info(
        f"Envío asignado — order={req.order_id} driver='{driver.name}' vehicle='{driver.vehicle}'"
    )
    result = _shipment_to_dict(row)
    result["driver"] = {"id": driver.id, "name": driver.name, "vehicle": driver.vehicle}
    return result


@app.get("/shipments/{order_id}")#De parte del admin, del usuario y del conductor
def get_shipment(order_id: str, db: Session = Depends(get_db)):
    row = db.execute(
        text("""
            SELECT s.*, d.name as driver_name, d.vehicle
            FROM transport.shipments s
            LEFT JOIN transport.drivers d ON d.id = s.driver_id
            WHERE s.order_id = :oid
        """),
        {"oid": order_id},
    ).fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Envío no encontrado")
    return {
        **_shipment_to_dict(row),
        "driver_name": row.driver_name,
        "vehicle": row.vehicle,
    }


@app.patch("/shipments/{order_id}/status")#De parte del conductor
def update_status(order_id: str, req: UpdateStatusRequest, db: Session = Depends(get_db)):
    """Actualiza el estado del envío. Al entregar, libera el conductor."""
    valid_transitions = {
        "ASSIGNED": ["IN_TRANSIT"],
        "IN_TRANSIT": ["DELIVERED"],
    }

    shipment = db.execute(
        text("SELECT * FROM transport.shipments WHERE order_id = :oid FOR UPDATE"),
        {"oid": order_id},
    ).fetchone()

    if not shipment:
        raise HTTPException(status_code=404, detail="Envío no encontrado")

    allowed = valid_transitions.get(shipment.status, [])
    if req.status not in allowed:
        raise HTTPException(
            status_code=400,
            detail=f"Transición inválida: {shipment.status} → {req.status}",
        )

    update_sql = "UPDATE transport.shipments SET status = :status"
    params: dict = {"status": req.status, "oid": order_id}

    if req.status == "DELIVERED":
        update_sql += ", delivered_at = NOW()"
        # Libera conductor
        db.execute(
            text("UPDATE transport.drivers SET is_available = TRUE WHERE id = :did"),
            {"did": shipment.driver_id},
        )

    db.execute(text(update_sql + " WHERE order_id = :oid"), params)
    db.commit()

    logger.info(f"Envío {order_id}: {shipment.status} → {req.status}")
    return {"order_id": order_id, "new_status": req.status}


@app.get("/drivers")#De parte del admin
def list_drivers(db: Session = Depends(get_db)):
    rows = db.execute(
        text("SELECT id, name, vehicle, is_available FROM transport.drivers ORDER BY id")
    ).fetchall()
    return [
        {"id": r.id, "name": r.name, "vehicle": r.vehicle, "available": r.is_available}
        for r in rows
    ]


def _shipment_to_dict(row) -> dict:
    return {
        "id": row.id,
        "order_id": str(row.order_id),
        "driver_id": row.driver_id,
        "status": row.status,
        "address": row.address,
        "assigned_at": str(row.assigned_at),
        "delivered_at": str(row.delivered_at) if row.delivered_at else None,
    }
