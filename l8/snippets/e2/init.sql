-- START-SNIPPET,init
CREATE TABLE cuentas (
    numero_cuenta VARCHAR(20) PRIMARY KEY,
    titular VARCHAR(100) NOT NULL,
    saldo DECIMAL(15, 2) NOT NULL CHECK (saldo >= 0)
);

INSERT INTO cuentas (numero_cuenta, titular, saldo)
VALUES ('123456', 'Juan Perez', 50000.00);
-- END-SNIPPET
