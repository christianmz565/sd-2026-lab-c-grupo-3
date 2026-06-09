CREATE TABLE IF NOT EXISTS cuentas (
    id SERIAL PRIMARY KEY,
    numero_cuenta VARCHAR(20) NOT NULL UNIQUE,
    titular VARCHAR(100) NOT NULL,
    saldo NUMERIC(15, 2) NOT NULL CHECK (saldo >= 0)
);

INSERT INTO cuentas(numero_cuenta, titular, saldo) VALUES
    ('ACC001', 'Juan García Pérez', 50000.00),
    ('ACC002', 'María Rodríguez López', 35000.00),
    ('ACC003', 'Carlos Martínez Flores', 75000.00);
