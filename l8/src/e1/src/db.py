"""Capa de acceso a datos para los 3 nodos PostgreSQL de FarmaAndes.

Cada nodo (almacen_arequipa, almacen_lima, almacen_cusco) se identifica por
un nombre lógico. Esta capa provee operaciones atómicas por nodo
(check_stock, lock_and_apply, commit, rollback) que el coordinador 2PC
compone para implementar el protocolo.
"""
from __future__ import annotations

import os
from contextlib import contextmanager
from dataclasses import dataclass
from typing import Iterator

import psycopg
from psycopg import errors as pg_errors


@dataclass(frozen=True)
class Nodo:
    """Identificador lógico + DSN de un nodo PostgreSQL."""
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


def build_nodos() -> dict[str, Nodo]:
    """Construye el registro de los 3 nodos FarmaAndes desde variables de entorno."""
    return {
        "arequipa": Nodo(
            nombre="arequipa",
            dsn=_load_dsn("DSN_AREQUIPA", 5435, "almacen_arequipa"),
        ),
        "lima": Nodo(
            nombre="lima",
            dsn=_load_dsn("DSN_LIMA", 5436, "almacen_lima"),
        ),
        "cusco": Nodo(
            nombre="cusco",
            dsn=_load_dsn("DSN_CUSCO", 5437, "almacen_cusco"),
        ),
    }


NODOS: dict[str, Nodo] = build_nodos()


class NodoDesconocidoError(KeyError):
    """Se pidió operar sobre un nodo no registrado."""


def get_nodo(nombre: str) -> Nodo:
    if nombre not in NODOS:
        raise NodoDesconocidoError(
            f"Nodo '{nombre}' no existe. Válidos: {list(NODOS)}"
        )
    return NODOS[nombre]


@contextmanager
def nodo_connection(nombre: str) -> Iterator[psycopg.Connection]:
    """Abre una conexión a un nodo en modo transacción explícita (autocommit=False).

    El coordinador es responsable de hacer commit() o rollback() sobre la
    conexión antes de que el context manager la cierre.
    """
    nodo = get_nodo(nombre)
    conn = psycopg.connect(nodo.dsn, autocommit=False)
    try:
        yield conn
    finally:
        conn.close()


def read_stock(conn: psycopg.Connection, producto: str) -> int | None:
    """Lee el stock actual de un producto. Retorna None si no existe."""
    with conn.cursor() as cur:
        cur.execute(
            "SELECT stock FROM inventario WHERE producto = %s",
            (producto,),
        )
        row = cur.fetchone()
        return row[0] if row else None


def read_inventario(conn: psycopg.Connection) -> list[dict]:
    """Lista todo el inventario del nodo."""
    with conn.cursor() as cur:
        cur.execute("SELECT producto, stock FROM inventario ORDER BY producto")
        return [{"producto": r[0], "stock": r[1]} for r in cur.fetchall()]


def lock_and_debit(
    conn: psycopg.Connection, producto: str, cantidad: int
) -> int:
    """SELECT FOR UPDATE + UPDATE stock -= cantidad. Retorna stock resultante.

    Lanza:
      - LookupError si el producto no existe.
      - ValueError si no hay stock suficiente.
      - psycopg.errors.CheckViolation si el CHECK (stock >= 0) salta.
    """
    with conn.cursor() as cur:
        cur.execute(
            "SELECT stock FROM inventario WHERE producto = %s FOR UPDATE",
            (producto,),
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


def lock_and_credit(
    conn: psycopg.Connection, producto: str, cantidad: int
) -> int:
    """SELECT FOR UPDATE + UPDATE stock += cantidad. Retorna stock resultante.

    Lanza LookupError si el producto no existe.
    """
    with conn.cursor() as cur:
        cur.execute(
            "SELECT stock FROM inventario WHERE producto = %s FOR UPDATE",
            (producto,),
        )
        row = cur.fetchone()
        if row is None:
            raise LookupError(f"Producto '{producto}' no existe en este nodo")
        cur.execute(
            "UPDATE inventario SET stock = stock + %s WHERE producto = %s",
            (cantidad, producto),
        )
        return row[0] + cantidad


def health_check(nombre: str) -> bool:
    """Ping simple: ejecuta SELECT 1. Retorna True si el nodo responde."""
    try:
        with psycopg.connect(get_nodo(nombre).dsn, autocommit=True) as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1")
                cur.fetchone()
        return True
    except psycopg.OperationalError:
        return False
    except pg_errors.Error:
        return False
