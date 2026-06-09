"""Capa de acceso a datos para los 3 nodos PostgreSQL del sistema financiero.

Cada nodo (sucursal_arequipa, sucursal_cusco, sucursal_trujillo) se identifica
por un nombre lógico. Esta capa provee operaciones atómicas por nodo
(check_saldo, lock_and_debit, lock_and_credit, commit, rollback) que el
coordinador 2PC compone para implementar el protocolo.
"""
from __future__ import annotations

import os
from contextlib import contextmanager
from dataclasses import dataclass
from decimal import Decimal
from typing import Iterator

import psycopg
from psycopg import errors as pg_errors


@dataclass(frozen=True)
class Sucursal:
    """Identificador lógico + DSN de una sucursal PostgreSQL."""
    nombre: str
    dsn: str


def _load_dsn(env_var: str, default_port: int, db_name: str) -> str:
    """Lee un DSN desde .env o construye uno por defecto apuntando a localhost."""
    dsn = os.getenv(env_var)
    if dsn:
        return dsn
    return (
        f"postgresql://postgres:postgres@localhost:{default_port}/{db_name}"
    )


def build_sucursales() -> dict[str, Sucursal]:
    """Construye el registro de las 3 sucursales desde variables de entorno."""
    return {
        "arequipa": Sucursal(
            nombre="arequipa",
            dsn=_load_dsn("DSN_AREQUIPA", 5438, "sucursal_arequipa"),
        ),
        "cusco": Sucursal(
            nombre="cusco",
            dsn=_load_dsn("DSN_CUSCO", 5439, "sucursal_cusco"),
        ),
        "trujillo": Sucursal(
            nombre="trujillo",
            dsn=_load_dsn("DSN_TRUJILLO", 5440, "sucursal_trujillo"),
        ),
    }


SUCURSALES: dict[str, Sucursal] = build_sucursales()


class SucursalDesconocidaError(KeyError):
    """Se pidió operar sobre una sucursal no registrada."""


def get_sucursal(nombre: str) -> Sucursal:
    if nombre not in SUCURSALES:
        raise SucursalDesconocidaError(
            f"Sucursal '{nombre}' no existe. Válidas: {list(SUCURSALES)}"
        )
    return SUCURSALES[nombre]


def simplify_db_error(e: Exception) -> str:
    """Simplifica mensajes de error verbosos de psycopg para la UI."""
    msg = str(e).strip()
    if "Connection refused" in msg or "Can't assign requested address" in msg:
        return "Conexión rechazada: el servidor no responde. Verifique que el contenedor Docker esté iniciado."
    if "password authentication failed" in msg:
        return "Fallo de autenticación en la base de datos."
    if "database" in msg and "does not exist" in msg:
        return "La base de datos no existe."
    if "terminating connection due to administrator command" in msg:
        return "Conexión terminada (el nodo fue detenido manualmente)."

    # Si hay múltiples líneas (como en fallos de conexión de psycopg), tomar la primera relevante
    lines = [l.strip() for l in msg.split("\n") if l.strip()]
    return lines[0] if lines else msg


@contextmanager
def sucursal_connection(nombre: str) -> Iterator[psycopg.Connection]:
    """Abre una conexión a una sucursal en modo transacción explícita (autocommit=False).

    El coordinador es responsable de hacer commit() o rollback() sobre la
    conexión antes de que el context manager la cierre.
    """
    sucursal = get_sucursal(nombre)
    conn = psycopg.connect(sucursal.dsn, autocommit=False)
    try:
        yield conn
    finally:
        conn.close()


def read_saldo(conn: psycopg.Connection, numero_cuenta: str) -> float | None:
    """Lee el saldo actual de una cuenta. Retorna None si no existe."""
    with conn.cursor() as cur:
        cur.execute(
            "SELECT saldo FROM cuentas WHERE numero_cuenta = %s",
            (numero_cuenta,),
        )
        row = cur.fetchone()
        return float(row[0]) if row else None


def read_cuentas(conn: psycopg.Connection) -> list[dict]:
    """Lista todas las cuentas de la sucursal."""
    with conn.cursor() as cur:
        cur.execute(
            "SELECT numero_cuenta, titular, saldo FROM cuentas ORDER BY numero_cuenta"
        )
        return [
            {"numero_cuenta": r[0], "titular": r[1], "saldo": float(r[2])}
            for r in cur.fetchall()
        ]


def lock_and_debit(
    conn: psycopg.Connection, numero_cuenta: str, monto: float
) -> float:
    """SELECT FOR UPDATE + UPDATE saldo -= monto. Retorna saldo resultante.

    Lanza:
      - LookupError si la cuenta no existe.
      - ValueError si no hay saldo suficiente.
      - psycopg.errors.CheckViolation si el CHECK (saldo >= 0) salta.
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


def lock_and_credit(
    conn: psycopg.Connection, numero_cuenta: str, monto: float
) -> float:
    """SELECT FOR UPDATE + UPDATE saldo += monto. Retorna saldo resultante.

    Lanza LookupError si la cuenta no existe.
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


def health_check(nombre: str) -> bool:
    """Ping simple: ejecuta SELECT 1. Retorna True si la sucursal responde."""
    try:
        with psycopg.connect(get_sucursal(nombre).dsn, autocommit=True) as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1")
                cur.fetchone()
        return True
    except psycopg.OperationalError:
        return False
    except pg_errors.Error:
        return False


def create_cuenta(conn: psycopg.Connection, numero_cuenta: str, titular: str, saldo: float) -> None:
    """Crea una nueva cuenta en la sucursal."""
    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO cuentas (numero_cuenta, titular, saldo) VALUES (%s, %s, %s)",
            (numero_cuenta, titular, Decimal(str(saldo))),
        )


def update_cuenta(conn: psycopg.Connection, numero_cuenta: str, titular: str, saldo: float) -> None:
    """Actualiza los datos de una cuenta existente."""
    with conn.cursor() as cur:
        cur.execute(
            "UPDATE cuentas SET titular = %s, saldo = %s WHERE numero_cuenta = %s",
            (titular, Decimal(str(saldo)), numero_cuenta),
        )
        if cur.rowcount == 0:
            raise LookupError(f"Cuenta '{numero_cuenta}' no existe")


def delete_cuenta(conn: psycopg.Connection, numero_cuenta: str) -> None:
    """Elimina una cuenta de la sucursal."""
    with conn.cursor() as cur:
        cur.execute(
            "DELETE FROM cuentas WHERE numero_cuenta = %s",
            (numero_cuenta,),
        )
        if cur.rowcount == 0:
            raise LookupError(f"Cuenta '{numero_cuenta}' no existe")
