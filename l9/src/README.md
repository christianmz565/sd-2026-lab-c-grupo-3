# LogiFresh S.A. — Sistema de Microservicios

Sistema distribuido basado en microservicios para la empresa **LogiFresh S.A.**, empresa peruana dedicada a la distribución de alimentos refrigerados.

## Arquitectura

```
┌──────────────────────────────────────────────────────────────┐
│                        Cliente / API                         │
└──────────────────────┬───────────────────────────────────────┘
                       │ HTTP
                       ▼
         ┌─────────────────────────┐
         │   Servicio de Pedidos   │  :8001  (orquestador)
         └──┬──────┬──────┬───────┘
            │      │      │
    ┌───────┘  ┌───┘  ┌───┘
    ▼          ▼      ▼
┌──────────┐ ┌──────────┐ ┌──────────────┐
│Inventario│ │Facturación│ │  Transporte  │
│  :8002   │ │  :8003   │ │    :8004     │
└──────────┘ └──────────┘ └──────────────┘
                                │
                       ┌────────┘
                       ▼
              ┌────────────────┐     ┌───────┐
              │ Notificaciones │────▶│ Redis │
              │    :8005       │     └───────┘
              └────────────────┘
                       │
              ┌────────────────┐
              │   PostgreSQL   │  (schemas por servicio)
              └────────────────┘
```

## Problemas resueltos

| Problema reportado | Solución implementada |
|---|---|
| Pedidos sin descuento | Validación del código de promo en la misma transacción DB que crea el pedido (atomicidad) |
| Inventario inconsistente | `SELECT FOR UPDATE` (locking pesimista) al reservar/liberar stock |
| Facturas duplicadas | `UNIQUE constraint` en `order_id` + verificación de idempotencia antes de insertar |
| Notificaciones lentas | Cola Redis asíncrona — el pedido no espera el envío del email |
| Lentitud >8 segundos | `202 Accepted` inmediato + procesamiento del flujo completo en background |

## Servicios

| Servicio | Puerto | Tecnología | Descripción |
|---|---|---|---|
| Pedidos | 8001 | FastAPI + PostgreSQL + Redis | Orquestador principal |
| Inventario | 8002 | FastAPI + PostgreSQL | Gestión de stock con locking |
| Facturación | 8003 | FastAPI + PostgreSQL | Generación idempotente de facturas |
| Transporte | 8004 | FastAPI + PostgreSQL | Asignación de rutas y conductores |
| Notificaciones | 8005 | FastAPI + PostgreSQL + Redis | Envío asíncrono de emails |

## Inicio rápido

```bash
# 1. Clonar / posicionarse en l9/src
cd l9/src

# 2. Copiar variables de entorno
cp .env.example .env

# 3. Levantar todos los servicios
docker compose up --build -d

# 4. Verificar que todo esté corriendo
docker compose ps
```

## Endpoints principales

### Pedidos (`:8001`)
```
POST   /orders                  # Crear pedido (responde en <500ms)
GET    /orders/{id}             # Estado del pedido
GET    /orders?status=CONFIRMED # Listar pedidos
PATCH  /orders/{id}/cancel      # Cancelar pedido
GET    /promotions              # Promociones activas
```

**Ejemplo de creación de pedido:**
```bash
curl -X POST http://localhost:8001/orders \
  -H "Content-Type: application/json" \
  -H "X-Idempotency-Key: mi-clave-unica-123" \
  -d '{
    "client_id": "cliente-001",
    "client_email": "cliente@ejemplo.com",
    "delivery_address": "Av. La Marina 123, Lima",
    "promotion_code": "VERANO10",
    "items": [
      {"product_id": 1, "quantity": 10, "unit_price": 25.50},
      {"product_id": 3, "quantity": 5,  "unit_price": 15.75}
    ]
  }'
```

### Inventario (`:8002`)
```
GET    /products                # Listar productos con stock
GET    /products/{id}           # Detalle de producto
POST   /reserve                 # Reservar stock (usado por pedidos)
POST   /release                 # Liberar stock (cancelaciones)
POST   /restock                 # Reabastecer producto
GET    /movements/{order_id}    # Historial de movimientos
```

### Facturación (`:8003`)
```
POST   /invoices                # Crear factura (idempotente)
GET    /invoices/{order_id}     # Factura por pedido
GET    /invoices                # Listar facturas
```

### Transporte (`:8004`)
```
POST   /shipments               # Asignar envío
GET    /shipments/{order_id}    # Estado del envío
PATCH  /shipments/{order_id}/status  # Actualizar estado
GET    /drivers                 # Listar conductores
```

### Notificaciones (`:8005`)
```
POST   /notify                  # Encolar notificación
GET    /notifications           # Historial
GET    /queue/size              # Tamaño de cola Redis
```

## Documentación interactiva (Swagger)

Cada servicio expone su documentación en `/docs`:
- Pedidos: http://localhost:8001/docs
- Inventario: http://localhost:8002/docs
- Facturación: http://localhost:8003/docs
- Transporte: http://localhost:8004/docs
- Notificaciones: http://localhost:8005/docs
