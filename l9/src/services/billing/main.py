"""
Servicio de Facturación — LogiFresh S.A.
Puerto: 8003

Solución al problema de FACTURAS DUPLICADAS:
  → La tabla billing.invoices tiene un UNIQUE constraint en order_id.
    Adicionalmente, se verifica explícitamente antes de insertar y se
    devuelve la factura existente si ya fue creada (idempotencia).
    Esto garantiza que, aunque el servicio de pedidos llame dos veces
    por error o por reintento, solo se genere UNA factura por pedido.
"""

import os
import logging
from contextlib import asynccontextmanager
from decimal import Decimal

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy import create_engine, text
from sqlalchemy.orm import Session
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("billing")

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://logifresh:logifresh_pass@postgres/logifresh")
engine = create_engine(DATABASE_URL, pool_size=10, max_overflow=20)

TAX_RATE = Decimal("0.18")  # IGV Peru


def get_db():
    with Session(engine) as session:
        yield session


def generate_invoice_number() -> str:
    import uuid
    return f"FAC-{uuid.uuid4().hex[:8].upper()}"


# ─── Schemas ─────────────────────────────────────────────────────────────────

class CreateInvoiceRequest(BaseModel):
    order_id: str
    client_id: str
    subtotal: float
    discount_pct: float = 0.0  # porcentaje, ej. 10 = 10%


# ─── App ─────────────────────────────────────────────────────────────────────

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Billing service started on port 8003")
    yield

app = FastAPI(
    title="LogiFresh — Servicio de Facturación",
    description="Generación idempotente de facturas (sin duplicados)",
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
    return {"status": "ok", "service": "billing"}


# START-SNIPPET,create-invoice
@app.post("/invoices", status_code=201)
def create_invoice(req: CreateInvoiceRequest, db: Session = Depends(get_db)):
    """
    Crea una factura para un pedido.

    SOLUCIÓN — Facturas duplicadas:
    1. Primero busca si ya existe una factura para este order_id.
    2. Si existe → devuelve la existente (HTTP 200) sin crear otra.
    3. Si no existe → la crea e inserta con UNIQUE constraint como red de seguridad.
    """
    # ── Paso 1: Verificar idempotencia ──
    existing = db.execute(
        text("SELECT * FROM billing.invoices WHERE order_id = :oid"),
        {"oid": req.order_id},
    ).fetchone()

    if existing:
        logger.info(f"Factura ya existe para order={req.order_id} → {existing.invoice_number}")
        return {
            "idempotent": True,
            "invoice": _row_to_dict(existing),
        }

    # ── Paso 2: Calcular montos ──
    subtotal = Decimal(str(req.subtotal))
    discount_pct = Decimal(str(req.discount_pct))
    discount_amount = (subtotal * discount_pct / 100).quantize(Decimal("0.01"))
    taxable_base = subtotal - discount_amount
    tax_amount = (taxable_base * TAX_RATE).quantize(Decimal("0.01"))
    total = taxable_base + tax_amount

    # ── Paso 3: Insertar factura ──
    invoice_number = generate_invoice_number()
    try:
        row = db.execute(
            text("""
                INSERT INTO billing.invoices
                    (invoice_number, order_id, client_id,
                     subtotal, discount_amount, tax_amount, total)
                VALUES
                    (:inv_num, :oid, :cid, :sub, :disc, :tax, :total)
                RETURNING *
            """),
            {
                "inv_num": invoice_number,
                "oid": req.order_id,
                "cid": req.client_id,
                "sub": float(subtotal),
                "disc": float(discount_amount),
                "tax": float(tax_amount),
                "total": float(total),
            },
        ).fetchone()

        db.commit()
        logger.info(f"Factura creada: {invoice_number} — order={req.order_id} total={total}")
        return {"idempotent": False, "invoice": _row_to_dict(row)}

    except Exception as e:
        # El UNIQUE constraint de BD actúa como última línea de defensa
        logger.warning(f"Conflicto al insertar factura para order={req.order_id}: {e}")
        existing = db.execute(
            text("SELECT * FROM billing.invoices WHERE order_id = :oid"),
            {"oid": req.order_id},
        ).fetchone()
        if existing:
            return {"idempotent": True, "invoice": _row_to_dict(existing)}
        raise HTTPException(status_code=500, detail="Error al crear factura")
# END-SNIPPET


@app.get("/invoices/{order_id}")
def get_invoice_by_order(order_id: str, db: Session = Depends(get_db)):
    row = db.execute(
        text("SELECT * FROM billing.invoices WHERE order_id = :oid"),
        {"oid": order_id},
    ).fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="Factura no encontrada")
    return _row_to_dict(row)


@app.get("/invoices")
def list_invoices(limit: int = 50, db: Session = Depends(get_db)):
    rows = db.execute(
        text("SELECT * FROM billing.invoices ORDER BY issued_at DESC LIMIT :lim"),
        {"lim": limit},
    ).fetchall()
    return [_row_to_dict(r) for r in rows]


def _row_to_dict(row) -> dict:
    return {
        "id": row.id,
        "invoice_number": row.invoice_number,
        "order_id": str(row.order_id),
        "client_id": row.client_id,
        "subtotal": float(row.subtotal),
        "discount_amount": float(row.discount_amount),
        "tax_amount": float(row.tax_amount),
        "total": float(row.total),
        "status": row.status,
        "issued_at": str(row.issued_at),
    }
