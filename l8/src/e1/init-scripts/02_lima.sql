CREATE TABLE IF NOT EXISTS inventario (
    id SERIAL PRIMARY KEY,
    producto VARCHAR(100) NOT NULL UNIQUE,
    stock INTEGER NOT NULL CHECK (stock >= 0)
);

INSERT INTO inventario(producto, stock) VALUES
    ('Paracetamol', 50),
    ('Ibuprofeno',  30),
    ('Aspirina',    25);
