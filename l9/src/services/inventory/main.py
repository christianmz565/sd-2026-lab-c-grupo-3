"""
Servicio de Inventario — LogiFresh S.A.
Puerto: 8002

Solución al problema de INVENTARIO INCONSISTENTE:
  → SELECT FOR UPDATE (locking pesimista) al reservar/liberar stock.
    Garantiza que dos peticiones concurrentes no lean el mismo stock
    disponible antes de decrementarlo.
"""

import os
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from sqlalchemy import create_engine, text
from sqlalchemy.orm import Session
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("inventory")

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://logifresh:logifresh_pass@postgres/logifresh")
engine = create_engine(DATABASE_URL, pool_size=10, max_overflow=20)


def get_db():
    with Session(engine) as session:
        yield session


# ─── Schemas ─────────────────────────────────────────────────────────────────

class ReserveRequest(BaseModel):
    order_id: str
    items: list[dict]  # [{product_id: int, quantity: int}]


class ReleaseRequest(BaseModel):
    order_id: str
    items: list[dict]


class RestockRequest(BaseModel):
    product_id: int
    quantity: int
    reason: str = "RESTOCK"


# ─── App ─────────────────────────────────────────────────────────────────────

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Inventory service started on port 8002")
    yield

app = FastAPI(
    title="LogiFresh — Servicio de Inventario",
    description="Gestión de stock con locking pesimista para evitar inconsistencias",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ─── Endpoints ───────────────────────────────────────────────────────────────

@app.get("/health")
def health():
    return {"status": "ok", "service": "inventory"}


@app.get("/products")
def list_products(db: Session = Depends(get_db)):
    """Lista todos los productos con su stock actual."""
    rows = db.execute(
        text("SELECT id, name, sku, stock, unit_price FROM inventory.products ORDER BY id")
    ).fetchall()
    return [
        {"id": r.id, "name": r.name, "sku": r.sku,
         "stock": r.stock, "unit_price": float(r.unit_price)}
        for r in rows
    ]


@app.get("/products/{product_id}")
def get_product(product_id: int, db: Session = Depends(get_db)):
    row = db.execute(
        text("SELECT id, name, sku, stock, unit_price FROM inventory.products WHERE id = :id"),
        {"id": product_id},
    ).fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    return {"id": row.id, "name": row.name, "sku": row.sku,
            "stock": row.stock, "unit_price": float(row.unit_price)}


# START-SNIPPET,reserve-stock
@app.post("/reserve", status_code=200)
def reserve_stock(req: ReserveRequest, db: Session = Depends(get_db)):
    """
    Reserva stock para un pedido.

    SOLUCIÓN — Inventario inconsistente:
    Se usa SELECT ... FOR UPDATE dentro de una transacción explícita.
    Ninguna otra transacción concurrente puede leer/modificar ese mismo
    registro hasta que se haga COMMIT, eliminando la race condition.
    """
    errors = []

    try:
        for item in req.items:
            product_id = item["product_id"]
            quantity = item["quantity"]

            # Bloqueo pesimista: SELECT FOR UPDATE
            product = db.execute(
                text("""
                    SELECT id, name, stock
                    FROM inventory.products
                    WHERE id = :id
                    FOR UPDATE
                """),
                {"id": product_id},
            ).fetchone()

            if not product:
                errors.append(f"Producto {product_id} no existe")
                raise ValueError(f"Producto {product_id} no existe")

            if product.stock < quantity:
                errors.append(
                    f"Stock insuficiente para '{product.name}': "
                    f"disponible={product.stock}, solicitado={quantity}"
                )
                raise ValueError("Stock insuficiente")

            # Decrementa stock
            db.execute(
                text("UPDATE inventory.products SET stock = stock - :qty WHERE id = :id"),
                {"qty": quantity, "id": product_id},
            )

            # Registra movimiento
            db.execute(
                text("""
                    INSERT INTO inventory.stock_movements (product_id, order_id, delta, reason)
                    VALUES (:pid, :oid, :delta, 'RESERVE')
                """),
                {"pid": product_id, "oid": req.order_id, "delta": -quantity},
            )

            logger.info(
                f"Reserva OK — order={req.order_id} product={product_id} qty={quantity}"
            )

        db.commit()

    except ValueError:
        raise HTTPException(status_code=409, detail=errors[0] if errors else "Error de reserva")

    return {"status": "reserved", "order_id": req.order_id}
# END-SNIPPET


@app.post("/release", status_code=200)
def release_stock(req: ReleaseRequest, db: Session = Depends(get_db)):
    """Libera stock reservado (p.ej. si el pedido fue cancelado)."""
    for item in req.items:
        product_id = item["product_id"]
        quantity = item["quantity"]

        db.execute(
            text("UPDATE inventory.products SET stock = stock + :qty WHERE id = :id"),
            {"qty": quantity, "id": product_id},
        )
        db.execute(
            text("""
                INSERT INTO inventory.stock_movements (product_id, order_id, delta, reason)
                VALUES (:pid, :oid, :delta, 'RELEASE')
            """),
            {"pid": product_id, "oid": req.order_id, "delta": quantity},
        )

    db.commit()
    logger.info(f"Stock liberado — order={req.order_id}")
    return {"status": "released", "order_id": req.order_id}


@app.post("/restock")
def restock(req: RestockRequest, db: Session = Depends(get_db)):
    """Reabastece un producto."""
    result = db.execute(
        text("""
            UPDATE inventory.products
            SET stock = stock + :qty
            WHERE id = :id
            RETURNING id, name, stock
        """),
        {"qty": req.quantity, "id": req.product_id},
    ).fetchone()

    if not result:
        raise HTTPException(status_code=404, detail="Producto no encontrado")

    db.execute(
        text("""
            INSERT INTO inventory.stock_movements (product_id, delta, reason)
            VALUES (:pid, :delta, :reason)
        """),
        {"pid": req.product_id, "delta": req.quantity, "reason": req.reason},
    )

    db.commit()

    return {"product_id": result.id, "name": result.name, "new_stock": result.stock}


@app.get("/movements/{order_id}")
def get_movements(order_id: str, db: Session = Depends(get_db)):
    """Historial de movimientos para un pedido (auditoría)."""
    rows = db.execute(
        text("""
            SELECT m.id, m.product_id, p.name, m.delta, m.reason, m.created_at
            FROM inventory.stock_movements m
            JOIN inventory.products p ON p.id = m.product_id
            WHERE m.order_id = :oid
            ORDER BY m.created_at
        """),
        {"oid": order_id},
    ).fetchall()
    return [
        {"id": r.id, "product_id": r.product_id, "product_name": r.name,
         "delta": r.delta, "reason": r.reason, "created_at": str(r.created_at)}
        for r in rows
    ]
