-- START-SNIPPET,init
CREATE TABLE inventario (
    id SERIAL PRIMARY KEY,
    producto VARCHAR(100) UNIQUE NOT NULL,
    stock INTEGER NOT NULL CHECK (stock >= 0)
);

INSERT INTO inventario (producto, stock) VALUES ('Paracetamol', 100);
-- END-SNIPPET
