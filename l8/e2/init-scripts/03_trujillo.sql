CREATE TABLE IF NOT EXISTS cuentas (
    id SERIAL PRIMARY KEY,
    numero_cuenta VARCHAR(20) NOT NULL UNIQUE,
    titular VARCHAR(100) NOT NULL,
    saldo NUMERIC(15, 2) NOT NULL CHECK (saldo >= 0)
);

INSERT INTO cuentas(numero_cuenta, titular, saldo) VALUES
    ('ACC401', 'Roberto Morales Castillo', 55000.00),
    ('ACC402', 'Sofía Gutierrez Ramírez', 70000.00),
    ('ACC403', 'Diego Navarro Jiménez', 42000.00);
