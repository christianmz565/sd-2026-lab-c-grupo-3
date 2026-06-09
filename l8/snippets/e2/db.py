# START-SNIPPET,lock-debit
def lock_and_debit(conn: psycopg.Connection, numero_cuenta: str, monto: float) -> float:
    """
    SELECT FOR UPDATE + UPDATE saldo -= monto. Retorna saldo resultante.
    """
    monto_decimal = Decimal(str(monto))
    with conn.cursor() as cur:
        cur.execute(
            "SELECT saldo FROM cuentas WHERE numero_cuenta = %s FOR UPDATE",
            (numero_cuenta,),
        )
        row = cur.fetchone()
        if row is None:
            raise LookupError(f"Cuenta '{numero_cuenta}' no existe en esta sucursal")
        if row[0] < monto_decimal:
            raise ValueError(
                f"Saldo insuficiente: hay S/ {float(row[0]):.2f}, se requieren S/ {monto:.2f}"
            )
        cur.execute(
            "UPDATE cuentas SET saldo = saldo - %s WHERE numero_cuenta = %s",
            (monto_decimal, numero_cuenta),
        )
        return float(row[0] - monto_decimal)
# END-SNIPPET

# START-SNIPPET,lock-credit
def lock_and_credit(
    conn: psycopg.Connection, numero_cuenta: str, monto: float
) -> float:
    """
    SELECT FOR UPDATE + UPDATE saldo += monto. Retorna saldo resultante.
    """
    monto_decimal = Decimal(str(monto))
    with conn.cursor() as cur:
        cur.execute(
            "SELECT saldo FROM cuentas WHERE numero_cuenta = %s FOR UPDATE",
            (numero_cuenta,),
        )
        row = cur.fetchone()
        if row is None:
            raise LookupError(f"Cuenta '{numero_cuenta}' no existe en esta sucursal")
        cur.execute(
            "UPDATE cuentas SET saldo = saldo + %s WHERE numero_cuenta = %s",
            (monto_decimal, numero_cuenta),
        )
        return float(row[0] + monto_decimal)
# END-SNIPPET
