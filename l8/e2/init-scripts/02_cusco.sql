CREATE TABLE IF NOT EXISTS cuentas (
    id SERIAL PRIMARY KEY,
    numero_cuenta VARCHAR(20) NOT NULL UNIQUE,
    titular VARCHAR(100) NOT NULL,
    saldo NUMERIC(15, 2) NOT NULL CHECK (saldo >= 0)
);

INSERT INTO cuentas(numero_cuenta, titular, saldo) VALUES
    ('ACC201', 'Pedro Sánchez Quispe', 60000.00),
    ('ACC202', 'Ana Condori Mamani', 45000.00),
    ('ACC203', 'Luis Huamán Yupanqui', 80000.00);
