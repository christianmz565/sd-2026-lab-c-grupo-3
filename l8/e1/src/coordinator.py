"""Coordinador del protocolo Two-Phase Commit (2PC).

Implementa la variante clásica:
  - Fase 1 (PREPARE): el coordinador abre una transacción en cada nodo
    participante, aplica los cambios tentativa-mente y deja la transacción
    en estado "preparado" (no commiteada).
  - Decisión:
      * Si TODOS los nodos contestan OK  -> Fase 2A (COMMIT) en cada uno.
      * Si ALGUNO falla o rechaza        -> Fase 2B (ROLLBACK) en todos.

Nota sobre 2PC real: psycopg no expone XA, así que el "PREPARE" se modela
abriendo la transacción y aplicando los cambios; el "COMMIT" coordi nado
consiste en hacer commit() en cada nodo secuencialmente. Si el commit de
uno falla tras haber commiteado los anteriores, la transacción queda en
estado in-doubt (limitación conocida del 2PC, fuera del alcance del Ej.1).
"""
from __future__ import annotations

import uuid
from dataclasses import dataclass

import psycopg
from psycopg import errors as pg_errors

from . import db
from .log_store import LogStore


class TransferError(Exception):
    """Error controlado durante la transferencia. Se traduce a ROLLED_BACK."""


@dataclass
class _PreparedTxn:
    """Estado interno de una transacción 2PC que pasó la Fase 1."""
    txn_id: str
    conn_origen: psycopg.Connection
    conn_destino: psycopg.Connection


class TwoPhaseCommitCoordinator:
    """Orquesta una transferencia distribuida entre dos nodos."""

    def __init__(self, log: LogStore | None = None) -> None:
        self.log = log or LogStore()

    def transferir(
        self, origen: str, destino: str, producto: str, cantidad: int
    ) -> dict:
        if origen == destino:
            raise TransferError("origen y destino deben ser distintos")

        txn_id = uuid.uuid4().hex
        self.log.append(txn_id, "START", None,
                        f"{origen}->{destino} {cantidad} und. de {producto}")

        # ------------------------------------------------------------------
        # FASE 1: PREPARE en cada nodo participante
        # ------------------------------------------------------------------
        prepared = self._phase_one(txn_id, origen, destino, producto, cantidad)

        # ------------------------------------------------------------------
        # FASE 2A: COMMIT en cada nodo (todos ya están "preparados")
        # ------------------------------------------------------------------
        return self._phase_two_commit(prepared, origen, destino, producto, cantidad)

    # ----------------------------------------------------------------------
    # Fase 1
    # ----------------------------------------------------------------------
    def _phase_one(
        self,
        txn_id: str,
        origen: str,
        destino: str,
        producto: str,
        cantidad: int,
    ) -> _PreparedTxn:
        """Abre una transacción en cada nodo, aplica los cambios y registra
        la decisión tentativa. Si algo falla, hace rollback en los nodos que
        ya estén abiertos antes de propagar la excepción.
        """
        opened: list[tuple[str, psycopg.Connection]] = []
        self.log.append(txn_id, "VALIDATE", origen, "verificando stock en origen")

        # Abrimos conexiones explícitamente para poder hacer rollback
        # nosotros mismos si algo falla a mitad del PREPARE.
        conn_origen = _open(origen)
        opened.append((origen, conn_origen))

        try:
            stock_origen_pre = db.lock_and_debit(conn_origen, producto, cantidad)
            self.log.append(
                txn_id, "PREPARED", origen,
                f"debited {cantidad} (stock pre={stock_origen_pre + cantidad})",
            )
        except (LookupError, ValueError) as e:
            self.log.append(txn_id, "FAILED", origen, f"rechazo en PREPARE: {e}")
            self._rollback_all(opened)
            raise TransferError(str(e)) from e
        except (pg_errors.Error, psycopg.OperationalError) as e:
            self.log.append(txn_id, "FAILED", origen, f"error DB: {e}")
            self._rollback_all(opened)
            raise TransferError(f"Fallo de BD en nodo {origen}: {e}") from e

        conn_destino = _open(destino)
        opened.append((destino, conn_destino))

        try:
            stock_destino_pre = db.lock_and_credit(conn_destino, producto, cantidad)
            self.log.append(
                txn_id, "PREPARED", destino,
                f"credited {cantidad} (stock pre={stock_destino_pre - cantidad})",
            )
        except LookupError as e:
            self.log.append(txn_id, "FAILED", destino, f"rechazo en PREPARE: {e}")
            self._rollback_all(opened)
            raise TransferError(str(e)) from e
        except (pg_errors.Error, psycopg.OperationalError) as e:
            self.log.append(txn_id, "FAILED", destino, f"error DB: {e}")
            self._rollback_all(opened)
            raise TransferError(f"Fallo de BD en nodo {destino}: {e}") from e

        return _PreparedTxn(
            txn_id=txn_id,
            conn_origen=conn_origen,
            conn_destino=conn_destino,
        )

    # ----------------------------------------------------------------------
    # Fase 2A
    # ----------------------------------------------------------------------
    def _phase_two_commit(
        self,
        prepared: _PreparedTxn,
        origen: str,
        destino: str,
        producto: str,
        cantidad: int,
    ) -> dict:
        """Ejecuta commit en cada nodo en orden. Construye la respuesta final."""
        txn_id = prepared.txn_id

        stock_origen_despues: int | None = None
        stock_destino_despues: int | None = None
        fallos_commit: list[str] = []

        for nodo, conn, key in (
            (origen, prepared.conn_origen, "origen"),
            (destino, prepared.conn_destino, "destino"),
        ):
            try:
                self.log.append(txn_id, "COMMIT", nodo, "orden de commit enviada")
                conn.commit()
                self.log.append(txn_id, "COMMITTED", nodo, "commit OK")
            except (pg_errors.Error, psycopg.OperationalError) as e:
                self.log.append(
                    txn_id, "FAILED", nodo, f"commit falló: {e}"
                )
                fallos_commit.append(f"{nodo}: {e}")
                continue

            try:
                with psycopg.connect(db.get_nodo(nodo).dsn, autocommit=True) as c2:
                    stock = db.read_stock(c2, producto)
                    if key == "origen":
                        stock_origen_despues = stock
                    else:
                        stock_destino_despues = stock
            except Exception:
                pass

            finally:
                conn.close()

        if fallos_commit:
            self.log.append(
                txn_id, "FAILED", None,
                f"estado in-doubt: {fallos_commit}",
            )
            return _build_response(
                txn_id=txn_id,
                status="FAILED",
                origen=origen, destino=destino,
                producto=producto, cantidad=cantidad,
                stock_origen_despues=stock_origen_despues,
                stock_destino_despues=stock_destino_despues,
                log_entries=self.log.all(),
            )

        self.log.append(txn_id, "COMMITTED", None, "transacción confirmada")
        return _build_response(
            txn_id=txn_id,
            status="COMMITTED",
            origen=origen, destino=destino,
            producto=producto, cantidad=cantidad,
            stock_origen_despues=stock_origen_despues,
            stock_destino_despues=stock_destino_despues,
            log_entries=self.log.all(),
        )

    # ----------------------------------------------------------------------
    # Helpers
    # ----------------------------------------------------------------------
    def _rollback_all(self, opened: list[tuple[str, psycopg.Connection]]) -> None:
        """Hace rollback en todas las conexiones abiertas y las cierra."""
        for nodo, conn in opened:
            try:
                conn.rollback()
            except Exception:
                pass
            try:
                conn.close()
            except Exception:
                pass


# ---------------------------------------------------------------------------
# Helpers de módulo
# ---------------------------------------------------------------------------
def _open(nombre: str) -> psycopg.Connection:
    """Abre una conexión a un nodo en modo transacción explícita."""
    nodo = db.get_nodo(nombre)
    return psycopg.connect(nodo.dsn, autocommit=False)


def _build_response(
    *,
    txn_id: str,
    status: str,
    origen: str,
    destino: str,
    producto: str,
    cantidad: int,
    stock_origen_despues: int | None,
    stock_destino_despues: int | None,
    log_entries: list[dict],
) -> dict:
    """Filtra el log para devolver sólo las entradas de esta transacción."""
    return {
        "txn_id": txn_id,
        "status": status,
        "origen": origen,
        "destino": destino,
        "producto": producto,
        "cantidad": cantidad,
        "stock_origen_despues": stock_origen_despues,
        "stock_destino_despues": stock_destino_despues,
        "log": [e for e in log_entries if e["txn_id"] == txn_id],
    }
