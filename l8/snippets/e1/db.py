# START-SNIPPET,lock-debit
def lock_and_debit(conn: psycopg.Connection, producto: str, cantidad: int) -> int:
    """
    SELECT FOR UPDATE + UPDATE stock -= cantidad. Retorna stock resultante.
    """
    with conn.cursor() as cur:
        cur.execute(
            "SELECT stock FROM inventario WHERE producto = %s FOR UPDATE", (producto,)
        )
        row = cur.fetchone()
        if row is None:
            raise LookupError(f"Producto '{producto}' no existe en este nodo")
        if row[0] < cantidad:
            raise ValueError(
                f"Stock insuficiente: hay {row[0]}, se requieren {cantidad}"
            )
        cur.execute(
            "UPDATE inventario SET stock = stock - %s WHERE producto = %s",
            (cantidad, producto),
        )
        return row[0] - cantidad
# END-SNIPPET

# START-SNIPPET,lock-credit
def lock_and_credit(conn: psycopg.Connection, producto: str, cantidad: int) -> int:
    """
    SELECT FOR UPDATE + UPDATE stock += cantidad. Retorna stock resultante.
    """
    with conn.cursor() as cur:
        cur.execute(
            "SELECT stock FROM inventario WHERE producto = %s FOR UPDATE", (producto,)
        )
        row = cur.fetchone()
        if row is None:
            raise LookupError(f"Producto '{producto}' no existe en este nodo")
        cur.execute(
            "UPDATE inventario SET stock = stock + %s WHERE producto = %s",
            (cantidad, producto),
        )
        return row[0] + cantidad
# END-SNIPPET
