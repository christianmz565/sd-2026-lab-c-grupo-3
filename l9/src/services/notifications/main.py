"""
Servicio de Notificaciones — LogiFresh S.A.
Puerto: 8005

Solución al problema de RETRASOS EN CONFIRMACIONES POR EMAIL:
  → Procesamiento 100% asíncrono mediante cola Redis.
  → El servicio de pedidos encola la notificación y retorna inmediatamente
    (no espera a que el email sea "enviado").
  → Un worker interno consume la cola en background con reintentos.

Simula el envío de email mediante logs (para no requerir credenciales SMTP).
"""

import os
import json
import logging
import asyncio
from contextlib import asynccontextmanager
from datetime import datetime
from typing import Optional

import redis as redis_lib
from fastapi import FastAPI, HTTPException, Depends, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy import create_engine, text
from sqlalchemy.orm import Session
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("notifications")

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://logifresh:logifresh_pass@postgres/logifresh")
REDIS_URL = os.getenv("REDIS_URL", "redis://redis:6379/0")
QUEUE_NAME = "notifications:queue"
MAX_RETRIES = 3

engine = create_engine(DATABASE_URL, pool_size=10, max_overflow=20)
redis_client = redis_lib.from_url(REDIS_URL, decode_responses=True)


def get_db():
    with Session(engine) as session:
        yield session


# ─── Schemas ─────────────────────────────────────────────────────────────────

class NotifyRequest(BaseModel):
    order_id: Optional[str] = None
    recipient: str          # email del cliente
    type: str               # ORDER_CONFIRMED | ORDER_SHIPPED | ORDER_CANCELLED
    payload: Optional[dict] = None


# ─── Background worker ───────────────────────────────────────────────────────

async def notification_worker():
    """
    Worker asíncrono que consume la cola Redis y 'envía' notificaciones.
    Se ejecuta en background durante toda la vida del servicio.

    SOLUCIÓN — Retrasos en notificaciones:
    El procesamiento ocurre desacoplado del flujo principal de pedidos.
    El pedido no espera la confirmación de email para responder al cliente.
    """
    logger.info("🔔 Notification worker iniciado — escuchando cola Redis")
    while True:
        try:
            # BLPOP bloquea hasta que haya un mensaje (timeout=5s para no bloquear forever)
            result = await asyncio.to_thread(redis_client.blpop, QUEUE_NAME, 5)
            if not result:
                continue

            _, raw = result
            message = json.loads(raw)
            notification_id = message.get("notification_id")

            logger.info(f"📨 Procesando notificación {notification_id} — type={message.get('type')}")

            # Simula envío de email (en producción: smtplib, SendGrid, etc.)
            await _simulate_send_email(message)

            # Marca como enviada en BD
            _mark_sent(notification_id)
            logger.info(f"✅ Notificación {notification_id} enviada a {message.get('recipient')}")

        except json.JSONDecodeError as e:
            logger.error(f"Mensaje inválido en cola: {e}")
        except Exception as e:
            logger.error(f"Error en worker de notificaciones: {e}")
            await asyncio.sleep(1)

#Mejorar a envio real de email
async def _simulate_send_email(message: dict):
    """Simula latencia de envío de email (50-200ms)."""
    await asyncio.sleep(0.1)
    recipient = message.get("recipient", "unknown")
    type_ = message.get("type", "UNKNOWN")
    order_id = message.get("order_id", "N/A")
    payload = message.get("payload", {})

    templates = {
        "ORDER_CONFIRMED": (
            f"✉️  EMAIL → {recipient}\n"
            f"   Asunto: Su pedido #{order_id} fue confirmado\n"
            f"   Cuerpo: Estimado cliente, su pedido ha sido registrado. "
            f"Total: S/ {payload.get('total', 'N/A')}"
        ),
        "ORDER_SHIPPED": (
            f"✉️  EMAIL → {recipient}\n"
            f"   Asunto: Su pedido #{order_id} está en camino\n"
            f"   Cuerpo: Conductor: {payload.get('driver', 'N/A')}"
        ),
        "ORDER_CANCELLED": (
            f"✉️  EMAIL → {recipient}\n"
            f"   Asunto: Su pedido #{order_id} fue cancelado\n"
            f"   Cuerpo: Lamentamos los inconvenientes. Motivo: {payload.get('reason', 'N/A')}"
        ),
    }
    log_msg = templates.get(type_, f"✉️  EMAIL → {recipient} | type={type_}")
    logger.info(log_msg)


def _mark_sent(notification_id: int):
    with Session(engine) as db:
        with db.begin():
            db.execute(
                text("""
                    UPDATE notifications.notifications
                    SET status = 'SENT', sent_at = NOW(), attempts = attempts + 1
                    WHERE id = :id
                """),
                {"id": notification_id},
            )


# ─── App ─────────────────────────────────────────────────────────────────────

_worker_task = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    global _worker_task
    # Inicia el worker en background al arrancar
    _worker_task = asyncio.create_task(notification_worker())
    logger.info("Notifications service started on port 8005")
    yield
    # Limpia al apagar
    if _worker_task:
        _worker_task.cancel()

app = FastAPI(
    title="LogiFresh — Servicio de Notificaciones",
    description="Envío asíncrono de notificaciones por email via cola Redis",
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
    try:
        redis_client.ping()
        redis_ok = True
    except Exception:
        redis_ok = False
    return {"status": "ok", "service": "notifications", "redis": redis_ok}


@app.post("/notify", status_code=202)
def enqueue_notification(req: NotifyRequest, db: Session = Depends(get_db)):
    """
    Encola una notificación para envío asíncrono.
    Retorna 202 Accepted inmediatamente — no espera el envío real.
    """
    row = db.execute(
        text("""
            INSERT INTO notifications.notifications
                (order_id, recipient, type, payload, status)
            VALUES (:oid, :rec, :type, :payload, 'PENDING')
            RETURNING id
        """),
        {
            "oid": req.order_id,
            "rec": req.recipient,
            "type": req.type,
            "payload": json.dumps(req.payload or {}),
        },
    ).fetchone()
    notification_id = row.id
    db.commit()

    # Encola en Redis para procesamiento asíncrono
    message = {
        "notification_id": notification_id,
        "order_id": req.order_id,
        "recipient": req.recipient,
        "type": req.type,
        "payload": req.payload or {},
        "enqueued_at": datetime.utcnow().isoformat(),
    }
    redis_client.rpush(QUEUE_NAME, json.dumps(message))

    logger.info(f"Notificación {notification_id} encolada — type={req.type} to={req.recipient}")
    return {
        "status": "queued",
        "notification_id": notification_id,
        "message": "La notificación será procesada en breve",
    }


@app.get("/notifications")
def list_notifications(limit: int = 50, db: Session = Depends(get_db)):
    rows = db.execute(
        text("""
            SELECT id, order_id, recipient, type, status, attempts, sent_at, created_at
            FROM notifications.notifications
            ORDER BY created_at DESC
            LIMIT :lim
        """),
        {"lim": limit},
    ).fetchall()
    return [
        {
            "id": r.id,
            "order_id": str(r.order_id) if r.order_id else None,
            "recipient": r.recipient,
            "type": r.type,
            "status": r.status,
            "attempts": r.attempts,
            "sent_at": str(r.sent_at) if r.sent_at else None,
            "created_at": str(r.created_at),
        }
        for r in rows
    ]


@app.get("/queue/size")
def queue_size():
    """Muestra cuántas notificaciones están pendientes en la cola."""
    size = redis_client.llen(QUEUE_NAME)
    return {"queue": QUEUE_NAME, "pending": size}
