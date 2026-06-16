"""
Servicio de Pedidos — LogiFresh S.A.
Puerto: 8001

Soluciones implementadas:
  1. PEDIDOS SIN DESCUENTO → Validación del código de promoción dentro de
     la misma transacción de BD antes de confirmar el pedido.

  2. LENTITUD >8s → El endpoint POST /orders devuelve 202 Accepted
     inmediatamente con el order_id. El flujo completo (reserva inventario
     → factura → transporte → notificación) se ejecuta en background via
     BackgroundTasks de FastAPI.

  3. IDEMPOTENCIA → Header X-Idempotency-Key evita procesar el mismo
     pedido dos veces aunque el cliente reintente por timeout.
"""

import os
import logging
import uuid
import time
from contextlib import asynccontextmanager
from typing import Optional

import httpx
from fastapi import FastAPI, HTTPException, Depends, BackgroundTasks, Header, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from sqlalchemy import create_engine, text
from sqlalchemy.orm import Session
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("orders")

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://logifresh:logifresh_pass@postgres/logifresh")
INVENTORY_URL = os.getenv("INVENTORY_URL", "http://inventory:8002")
BILLING_URL = os.getenv("BILLING_URL", "http://billing:8003")
TRANSPORT_URL = os.getenv("TRANSPORT_URL", "http://transport:8004")
NOTIFICATIONS_URL = os.getenv("NOTIFICATIONS_URL", "http://notifications:8005")

engine = create_engine(DATABASE_URL, pool_size=10, max_overflow=20)

HTTP_TIMEOUT = 10.0  # segundos por llamada


def get_db():
    with Session(engine) as session:
        yield session


# ─── Schemas ─────────────────────────────────────────────────────────────────

class OrderItem(BaseModel):
    product_id: int
    quantity: int
    unit_price: float


class CreateOrderRequest(BaseModel):
    client_id: str
    items: list[OrderItem]
    promotion_code: Optional[str] = None
    delivery_address: str
    client_email: str


# ─── App ─────────────────────────────────────────────────────────────────────

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Orders service started on port 8001")
    yield

app = FastAPI(
    title="LogiFresh — Servicio de Pedidos",
    description=(
        "Orquestador principal: registra pedidos, aplica descuentos, "
        "coordina inventario, facturación, transporte y notificaciones."
    ),
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


# ─── Helpers ─────────────────────────────────────────────────────────────────

def _get_discount(db: Session, promotion_code: str) -> float:
    """
    Consulta el descuento de una promoción dentro de la misma sesión de BD.

    SOLUCIÓN — Pedidos sin descuento:
    La validación ocurre en la misma transacción que crea el pedido,
    garantizando que si la promoción existe y es válida, el descuento
    siempre se aplica — sin race conditions entre servicios.
    """
    row = db.execute(
        text("""
            SELECT discount FROM orders.promotions
            WHERE code = :code
              AND is_active = TRUE
              AND (valid_until IS NULL OR valid_until > NOW())
        """),
        {"code": promotion_code},
    ).fetchone()
    return float(row.discount) if row else 0.0


async def _process_order_async(order_id: str, order_data: dict):
    """
    Flujo completo de procesamiento del pedido — ejecutado en background.

    SOLUCIÓN — Lentitud >8s:
    El cliente recibe 202 Accepted al instante. Este método corre
    de forma asíncrona sin bloquear la respuesta HTTP.
    """
    start = time.time()
    logger.info(f"🚀 Procesando pedido {order_id} en background")

    async with httpx.AsyncClient(timeout=HTTP_TIMEOUT) as client:
        try:
            # ── Paso 1: Actualizar estado a PROCESSING ──
            _update_order_status(order_id, "PROCESSING")

            # ── Paso 2: Reservar inventario ──
            inv_resp = await client.post(
                f"{INVENTORY_URL}/reserve",
                json={
                    "order_id": order_id,
                    "items": [
                        {"product_id": it["product_id"], "quantity": it["quantity"]}
                        for it in order_data["items"]
                    ],
                },
            )
            if inv_resp.status_code != 200:
                logger.error(f"Error reservando inventario: {inv_resp.text}")
                _update_order_status(order_id, "CANCELLED", error="Inventario insuficiente")
                await _notify(client, order_id, order_data, "ORDER_CANCELLED",
                              {"reason": "Inventario insuficiente"})
                return

            # ── Paso 3: Crear factura ──
            bill_resp = await client.post(
                f"{BILLING_URL}/invoices",
                json={
                    "order_id": order_id,
                    "client_id": order_data["client_id"],
                    "subtotal": order_data["subtotal"],
                    "discount_pct": order_data["discount_pct"],
                },
            )
            if bill_resp.status_code not in (200, 201):
                logger.error(f"Error creando factura: {bill_resp.text}")
                # Liberar stock
                await client.post(
                    f"{INVENTORY_URL}/release",
                    json={"order_id": order_id, "items": order_data["items"]},
                )
                _update_order_status(order_id, "CANCELLED", error="Error de facturación")
                return

            invoice = bill_resp.json().get("invoice", {})

            # ── Paso 4: Asignar transporte ──
            trans_resp = await client.post(
                f"{TRANSPORT_URL}/shipments",
                json={
                    "order_id": order_id,
                    "address": order_data["delivery_address"],
                    "client_id": order_data["client_id"],
                },
            )
            if trans_resp.status_code not in (200, 201):
                logger.warning(f"Transporte no disponible: {trans_resp.text} — pedido confirmado igualmente")

            # ── Paso 5: Confirmar pedido ──
            _update_order_status(order_id, "CONFIRMED")

            # ── Paso 6: Notificar al cliente (asíncrono, no bloquea) ──
            await _notify(
                client, order_id, order_data, "ORDER_CONFIRMED",
                {"total": invoice.get("total"), "invoice_number": invoice.get("invoice_number")},
            )

            elapsed = time.time() - start
            logger.info(f"✅ Pedido {order_id} procesado en {elapsed:.2f}s")

        except httpx.TimeoutException as e:
            logger.error(f"Timeout procesando pedido {order_id}: {e}")
            _update_order_status(order_id, "ERROR", error="Timeout en servicio externo")
        except Exception as e:
            logger.error(f"Error inesperado procesando pedido {order_id}: {e}")
            _update_order_status(order_id, "ERROR", error=str(e))


async def _notify(client: httpx.AsyncClient, order_id: str, order_data: dict,
                  type_: str, payload: dict):
    try:
        await client.post(
            f"{NOTIFICATIONS_URL}/notify",
            json={
                "order_id": order_id,
                "recipient": order_data.get("client_email", "cliente@logifresh.pe"),
                "type": type_,
                "payload": payload,
            },
        )
    except Exception as e:
        logger.warning(f"No se pudo encolar notificación: {e}")


def _update_order_status(order_id: str, status: str, error: Optional[str] = None):
    with Session(engine) as db:
        with db.begin():
            db.execute(
                text("""
                    UPDATE orders.orders
                    SET status = :status, updated_at = NOW()
                    WHERE id = :id
                """),
                {"status": status, "id": order_id},
            )
    if error:
        logger.warning(f"Pedido {order_id} → {status}: {error}")
    else:
        logger.info(f"Pedido {order_id} → {status}")


# ─── Endpoints ───────────────────────────────────────────────────────────────

@app.get("/health")
def health():
    return {"status": "ok", "service": "orders"}


@app.post("/orders", status_code=202)
async def create_order(
    req: CreateOrderRequest,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
    x_idempotency_key: Optional[str] = Header(default=None),
):
    """
    Registra un nuevo pedido.

    SOLUCIÓN — Lentitud >8s:
    Devuelve 202 Accepted inmediatamente con el order_id.
    El procesamiento (inventario, factura, transporte, notificación)
    ocurre en background sin bloquear al cliente.

    SOLUCIÓN — Pedidos sin descuento:
    Validación del código de promoción ocurre dentro de la misma
    transacción que crea el pedido (atomicidad garantizada).

    SOLUCIÓN — Idempotencia:
    Si se envía X-Idempotency-Key y ya existe un pedido con esa clave,
    se devuelve el pedido existente sin crear uno nuevo.
    """
    t0 = time.time()

    # ── Idempotencia ──
    if x_idempotency_key:
        existing = db.execute(
            text("SELECT id, status FROM orders.orders WHERE idempotency_key = :key"),
            {"key": x_idempotency_key},
        ).fetchone()
        if existing:
            logger.info(f"Pedido idempotente — key={x_idempotency_key} → order={existing.id}")
            return JSONResponse(
                status_code=202,
                content={
                    "idempotent": True,
                    "order_id": str(existing.id),
                    "status": existing.status,
                    "message": "Pedido ya registrado previamente",
                },
            )

    # ── Calcular subtotal ──
    subtotal = sum(item.quantity * item.unit_price for item in req.items)

    # ── Validar y aplicar descuento (DENTRO de la transacción) ──
    discount_pct = 0.0
    if req.promotion_code:
        discount_pct = _get_discount(db, req.promotion_code)
        if discount_pct == 0.0:
            logger.warning(f"Código de promoción inválido o expirado: {req.promotion_code}")

    total = subtotal * (1 - discount_pct / 100)

    # ── Crear pedido ──
    order_id_val = str(uuid.uuid4())
    db.execute(
        text("""
            INSERT INTO orders.orders
                (id, client_id, status, total_amount, discount_pct,
                 promotion_code, idempotency_key)
            VALUES
                (:id, :cid, 'PENDING', :total, :disc, :promo, :ikey)
        """),
        {
            "id": order_id_val,
            "cid": req.client_id,
            "total": round(total, 2),
            "disc": discount_pct,
            "promo": req.promotion_code,
            "ikey": x_idempotency_key,
        },
    )

    # ── Insertar ítems ──
    for item in req.items:
        db.execute(
            text("""
                INSERT INTO orders.order_items
                    (order_id, product_id, quantity, unit_price)
                VALUES (:oid, :pid, :qty, :price)
            """),
            {
                "oid": order_id_val,
                "pid": item.product_id,
                "qty": item.quantity,
                "price": item.unit_price,
            },
        )

    db.commit()

    # ── Datos para el procesamiento asíncrono ──
    order_data = {
        "client_id": req.client_id,
        "client_email": req.client_email,
        "delivery_address": req.delivery_address,
        "subtotal": subtotal,
        "discount_pct": discount_pct,
        "total": total,
        "items": [
            {"product_id": it.product_id, "quantity": it.quantity, "unit_price": it.unit_price}
            for it in req.items
        ],
    }

    # ── Delegar procesamiento al background ──
    background_tasks.add_task(_process_order_async, order_id_val, order_data)

    elapsed_ms = (time.time() - t0) * 1000
    logger.info(f"📦 Pedido {order_id_val} aceptado en {elapsed_ms:.1f}ms — procesando en background")

    return {
        "order_id": order_id_val,
        "status": "PENDING",
        "subtotal": round(subtotal, 2),
        "discount_pct": discount_pct,
        "total": round(total, 2),
        "message": "Pedido recibido. Procesando en background.",
        "response_time_ms": round(elapsed_ms, 1),
    }


@app.get("/orders/{order_id}")
def get_order(order_id: str, db: Session = Depends(get_db)):
    """Consulta el estado actual de un pedido."""
    order = db.execute(
        text("""
            SELECT id, client_id, status, total_amount, discount_pct,
                   promotion_code, created_at, updated_at
            FROM orders.orders WHERE id = :id
        """),
        {"id": order_id},
    ).fetchone()

    if not order:
        raise HTTPException(status_code=404, detail="Pedido no encontrado")

    items = db.execute(
        text("""
            SELECT product_id, quantity, unit_price
            FROM orders.order_items WHERE order_id = :oid
        """),
        {"oid": order_id},
    ).fetchall()

    return {
        "id": str(order.id),
        "client_id": order.client_id,
        "status": order.status,
        "total_amount": float(order.total_amount) if order.total_amount else None,
        "discount_pct": float(order.discount_pct),
        "promotion_code": order.promotion_code,
        "items": [
            {"product_id": it.product_id, "quantity": it.quantity, "unit_price": float(it.unit_price)}
            for it in items
        ],
        "created_at": str(order.created_at),
        "updated_at": str(order.updated_at),
    }


@app.get("/orders")
def list_orders(limit: int = 50, status: Optional[str] = None, db: Session = Depends(get_db)):
    """Lista pedidos con filtro opcional por estado."""
    if status:
        rows = db.execute(
            text("""
                SELECT id, client_id, status, total_amount, discount_pct, created_at
                FROM orders.orders
                WHERE status = :status
                ORDER BY created_at DESC LIMIT :lim
            """),
            {"status": status, "lim": limit},
        ).fetchall()
    else:
        rows = db.execute(
            text("""
                SELECT id, client_id, status, total_amount, discount_pct, created_at
                FROM orders.orders
                ORDER BY created_at DESC LIMIT :lim
            """),
            {"lim": limit},
        ).fetchall()

    return [
        {
            "id": str(r.id),
            "client_id": r.client_id,
            "status": r.status,
            "total_amount": float(r.total_amount) if r.total_amount else None,
            "discount_pct": float(r.discount_pct),
            "created_at": str(r.created_at),
        }
        for r in rows
    ]


@app.patch("/orders/{order_id}/cancel")
def cancel_order(order_id: str, db: Session = Depends(get_db)):
    """Cancela un pedido en estado PENDING."""
    order = db.execute(
        text("SELECT id, status FROM orders.orders WHERE id = :id FOR UPDATE"),
        {"id": order_id},
    ).fetchone()

    if not order:
        raise HTTPException(status_code=404, detail="Pedido no encontrado")

    if order.status not in ("PENDING",):
        raise HTTPException(
            status_code=400,
            detail=f"No se puede cancelar un pedido en estado '{order.status}'",
        )

    db.execute(
        text("UPDATE orders.orders SET status = 'CANCELLED', updated_at = NOW() WHERE id = :id"),
        {"id": order_id},
    )

    db.commit()
    logger.info(f"Pedido {order_id} cancelado manualmente")
    return {"order_id": order_id, "status": "CANCELLED"}


@app.get("/promotions")
def list_promotions(db: Session = Depends(get_db)):
    """Lista promociones activas."""
    rows = db.execute(
        text("""
            SELECT code, discount, valid_from, valid_until
            FROM orders.promotions
            WHERE is_active = TRUE AND (valid_until IS NULL OR valid_until > NOW())
            ORDER BY discount DESC
        """)
    ).fetchall()
    return [
        {"code": r.code, "discount_pct": float(r.discount),
         "valid_from": str(r.valid_from), "valid_until": str(r.valid_until) if r.valid_until else None}
        for r in rows
    ]
