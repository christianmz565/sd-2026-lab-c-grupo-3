-- LogiFresh S.A. — Database initialization
-- Each microservice uses its own schema for isolation

CREATE SCHEMA IF NOT EXISTS orders;
CREATE SCHEMA IF NOT EXISTS inventory;
CREATE SCHEMA IF NOT EXISTS billing;
CREATE SCHEMA IF NOT EXISTS transport;
CREATE SCHEMA IF NOT EXISTS notifications;

-- ─── ORDERS SCHEMA ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders.promotions (
    id          SERIAL PRIMARY KEY,
    code        VARCHAR(50) UNIQUE NOT NULL,
    discount    NUMERIC(5,2) NOT NULL CHECK (discount > 0 AND discount <= 100),
    is_active   BOOLEAN DEFAULT TRUE,
    valid_from  TIMESTAMPTZ DEFAULT NOW(),
    valid_until TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS orders.orders (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id       VARCHAR(100) NOT NULL,
    status          VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    -- PENDING → PROCESSING → CONFIRMED → CANCELLED
    total_amount    NUMERIC(12,2),
    discount_pct    NUMERIC(5,2) DEFAULT 0,
    promotion_code  VARCHAR(50),
    idempotency_key VARCHAR(255) UNIQUE,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS orders.order_items (
    id          SERIAL PRIMARY KEY,
    order_id    UUID NOT NULL REFERENCES orders.orders(id) ON DELETE CASCADE,
    product_id  INTEGER NOT NULL,
    quantity    INTEGER NOT NULL CHECK (quantity > 0),
    unit_price  NUMERIC(12,2) NOT NULL
);

-- Seed promotions
INSERT INTO orders.promotions (code, discount, valid_until)
VALUES
    ('VERANO10', 10.00, NOW() + INTERVAL '1 year'),
    ('MAYO20',   20.00, NOW() + INTERVAL '6 months')
ON CONFLICT DO NOTHING;

-- ─── INVENTORY SCHEMA ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS inventory.products (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(200) NOT NULL,
    sku         VARCHAR(100) UNIQUE NOT NULL,
    stock       INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    unit_price  NUMERIC(12,2) NOT NULL,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inventory.stock_movements (
    id          SERIAL PRIMARY KEY,
    product_id  INTEGER NOT NULL REFERENCES inventory.products(id),
    order_id    UUID,
    delta       INTEGER NOT NULL,  -- negative = reservation, positive = release/restock
    reason      VARCHAR(100),
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Seed products
INSERT INTO inventory.products (name, sku, stock, unit_price)
VALUES
    ('Pollo entero congelado', 'POLLO-001', 500, 25.50),
    ('Carne de res (kg)',      'RES-001',   300, 38.00),
    ('Pescado merluza (kg)',   'MERLUZ-001',200, 15.75),
    ('Queso fresco (kg)',      'QSO-001',   150, 22.00),
    ('Leche evaporada (caja)', 'LECHE-001', 800, 45.00)
ON CONFLICT DO NOTHING;

-- ─── BILLING SCHEMA ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS billing.invoices (
    id              SERIAL PRIMARY KEY,
    invoice_number  VARCHAR(50) UNIQUE NOT NULL,
    order_id        UUID UNIQUE NOT NULL,   -- UNIQUE prevents duplicates
    client_id       VARCHAR(100) NOT NULL,
    subtotal        NUMERIC(12,2) NOT NULL,
    discount_amount NUMERIC(12,2) DEFAULT 0,
    tax_amount      NUMERIC(12,2) DEFAULT 0,
    total           NUMERIC(12,2) NOT NULL,
    status          VARCHAR(20) DEFAULT 'ISSUED',
    issued_at       TIMESTAMPTZ DEFAULT NOW()
);

-- ─── TRANSPORT SCHEMA ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS transport.drivers (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(200) NOT NULL,
    vehicle     VARCHAR(100),
    is_available BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS transport.shipments (
    id          SERIAL PRIMARY KEY,
    order_id    UUID UNIQUE NOT NULL,
    driver_id   INTEGER REFERENCES transport.drivers(id),
    status      VARCHAR(30) DEFAULT 'ASSIGNED',
    -- ASSIGNED → IN_TRANSIT → DELIVERED
    address     TEXT,
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    delivered_at TIMESTAMPTZ
);

-- Seed drivers
INSERT INTO transport.drivers (name, vehicle)
VALUES
    ('Carlos Mamani',  'Refrigerador A1 - ABC-123'),
    ('Rosa Quispe',    'Refrigerador B2 - XYZ-456'),
    ('Jorge Huanca',   'Furgón C3 - PQR-789')
ON CONFLICT DO NOTHING;

-- ─── NOTIFICATIONS SCHEMA ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS notifications.notifications (
    id          SERIAL PRIMARY KEY,
    order_id    UUID,
    recipient   VARCHAR(200) NOT NULL,
    type        VARCHAR(50) NOT NULL,  -- ORDER_CONFIRMED, ORDER_SHIPPED, etc.
    payload     JSONB,
    status      VARCHAR(20) DEFAULT 'PENDING',
    -- PENDING → SENT → FAILED
    attempts    INTEGER DEFAULT 0,
    sent_at     TIMESTAMPTZ,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);
