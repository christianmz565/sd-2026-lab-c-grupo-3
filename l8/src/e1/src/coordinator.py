from __future__ import annotations

import time
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
        self,
        origen: str,
        destino: str,
        producto: str,
        cantidad: int,
        delay: float = 0.0,
    ) -> dict:
        if origen == destino:
            raise TransferError("origen y destino deben ser distintos")
        txn_id = uuid.uuid4().hex
        self.log.append(
            txn_id, "START", None, f"{origen}->{destino} {cantidad} und. de {producto}"
        )
        prepared = self._phase_one(txn_id, origen, destino, producto, cantidad)
        try:
            if delay > 0:
                self.log.append(
                    txn_id,
                    "DELAY",
                    None,
                    f"esperando {delay}s — puede detener un nodo ahora",
                )
                time.sleep(delay)
            self._validate_prepared_connections(prepared)
            return self._phase_two_commit(prepared, origen, destino, producto, cantidad)
        except (Exception, KeyboardInterrupt) as e:
            self.log.append(txn_id, "FAILED", None, f"error detectado: {e}")
            self._phase_two_rollback(prepared, origen, destino)
            return _build_response(
                txn_id=txn_id,
                status="ROLLED_BACK",
                origen=origen,
                destino=destino,
                producto=producto,
                cantidad=cantidad,
                stock_origen_despues=None,
                stock_destino_despues=None,
                log_entries=self.log.all(),
            )

    def _validate_prepared_connections(self, prepared: _PreparedTxn) -> None:
        """Verifica que las conexiones sigan activas antes de decidir el COMMIT."""
        for name, conn in [
            ("origen", prepared.conn_origen),
            ("destino", prepared.conn_destino),
        ]:
            try:
                with conn.cursor() as cur:
                    cur.execute("SELECT 1")
            except (pg_errors.Error, psycopg.OperationalError) as e:
                clean_err = db.simplify_db_error(e)
                raise TransferError(
                    f"Nodo {name} no responde tras el retraso: {clean_err}"
                ) from e

    def _phase_one(
        self, txn_id: str, origen: str, destino: str, producto: str, cantidad: int
    ) -> _PreparedTxn:
        """
        Abre una transacción en cada nodo, aplica los cambios y registra
        la decisión tentativa. Si algo falla, hace rollback en los nodos que
        ya estén abiertos antes de propagar la excepción.
        """
        opened: list[tuple[str, psycopg.Connection]] = []
        self.log.append(txn_id, "VALIDATE", origen, "verificando stock en origen")
        try:
            conn_origen = _open(origen)
        except (pg_errors.Error, psycopg.OperationalError) as e:
            clean_err = db.simplify_db_error(e)
            self.log.append(txn_id, "FAILED", origen, f"error de conexión: {clean_err}")
            raise TransferError(
                f"No se pudo conectar al nodo {origen}: {clean_err}"
            ) from e
        opened.append((origen, conn_origen))
        try:
            stock_origen_pre = db.lock_and_debit(conn_origen, producto, cantidad)
            self.log.append(
                txn_id,
                "PREPARED",
                origen,
                f"debited {cantidad} (stock pre={stock_origen_pre + cantidad})",
            )
        except (LookupError, ValueError) as e:
            self.log.append(txn_id, "FAILED", origen, f"rechazo en PREPARE: {e}")
            self._rollback_all(opened)
            raise TransferError(str(e)) from e
        except (pg_errors.Error, psycopg.OperationalError) as e:
            clean_err = db.simplify_db_error(e)
            self.log.append(txn_id, "FAILED", origen, f"error DB: {clean_err}")
            self._rollback_all(opened)
            raise TransferError(f"Fallo de BD en nodo {origen}: {clean_err}") from e
        try:
            conn_destino = _open(destino)
        except (pg_errors.Error, psycopg.OperationalError) as e:
            clean_err = db.simplify_db_error(e)
            self.log.append(
                txn_id, "FAILED", destino, f"error de conexión: {clean_err}"
            )
            self._rollback_all(opened)
            raise TransferError(
                f"No se pudo conectar al nodo {destino}: {clean_err}"
            ) from e
        opened.append((destino, conn_destino))
        try:
            stock_destino_pre = db.lock_and_credit(conn_destino, producto, cantidad)
            self.log.append(
                txn_id,
                "PREPARED",
                destino,
                f"credited {cantidad} (stock pre={stock_destino_pre - cantidad})",
            )
        except LookupError as e:
            self.log.append(txn_id, "FAILED", destino, f"rechazo en PREPARE: {e}")
            self._rollback_all(opened)
            raise TransferError(str(e)) from e
        except (pg_errors.Error, psycopg.OperationalError) as e:
            clean_err = db.simplify_db_error(e)
            self.log.append(txn_id, "FAILED", destino, f"error DB: {clean_err}")
            self._rollback_all(opened)
            raise TransferError(f"Fallo de BD en nodo {destino}: {clean_err}") from e
        return _PreparedTxn(
            txn_id=txn_id, conn_origen=conn_origen, conn_destino=conn_destino
        )

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
        plan = [
            (origen, prepared.conn_origen, "origen"),
            (destino, prepared.conn_destino, "destino"),
        ]
        commits_exitosos = 0
        fallos_commit: list[str] = []
        for i, (nodo, conn, key) in enumerate(plan):
            try:
                self.log.append(txn_id, "COMMIT", nodo, "orden de commit enviada")
                conn.commit()
                self.log.append(txn_id, "COMMITTED", nodo, "commit OK")
                commits_exitosos += 1
            except (pg_errors.Error, psycopg.OperationalError, Exception) as e:
                clean_err = db.simplify_db_error(e)
                self.log.append(txn_id, "FAILED", nodo, f"commit falló: {clean_err}")
                fallos_commit.append(f"{nodo}: {clean_err}")
                if commits_exitosos == 0:
                    self.log.append(
                        txn_id,
                        "ROLLBACK",
                        None,
                        "abortando tras fallo en primer commit",
                    )
                    try:
                        conn.close()
                    except Exception:
                        pass
                    pendientes = plan[i + 1 :]
                    for p_nodo, p_conn, _ in pendientes:
                        try:
                            self.log.append(
                                txn_id,
                                "ROLLBACK",
                                p_nodo,
                                "abortando transacción preparada",
                            )
                            p_conn.rollback()
                            p_conn.close()
                        except Exception:
                            pass
                    return _build_response(
                        txn_id=txn_id,
                        status="ROLLED_BACK",
                        origen=origen,
                        destino=destino,
                        producto=producto,
                        cantidad=cantidad,
                        stock_origen_despues=None,
                        stock_destino_despues=None,
                        log_entries=self.log.all(),
                    )
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
                try:
                    conn.close()
                except Exception:
                    pass
        if fallos_commit:
            self.log.append(
                txn_id,
                "FAILED",
                None,
                f"estado in-doubt (consistencia parcial): {fallos_commit}",
            )
            return _build_response(
                txn_id=txn_id,
                status="FAILED",
                origen=origen,
                destino=destino,
                producto=producto,
                cantidad=cantidad,
                stock_origen_despues=stock_origen_despues,
                stock_destino_despues=stock_destino_despues,
                log_entries=self.log.all(),
            )
        self.log.append(txn_id, "COMMITTED", None, "transacción confirmada")
        return _build_response(
            txn_id=txn_id,
            status="COMMITTED",
            origen=origen,
            destino=destino,
            producto=producto,
            cantidad=cantidad,
            stock_origen_despues=stock_origen_despues,
            stock_destino_despues=stock_destino_despues,
            log_entries=self.log.all(),
        )

    def _phase_two_rollback(
        self, prepared: _PreparedTxn, origen: str, destino: str
    ) -> None:
        """Fase de rollback cuando se decide no commitear."""
        txn_id = prepared.txn_id
        for nodo, conn in [
            (origen, prepared.conn_origen),
            (destino, prepared.conn_destino),
        ]:
            try:
                self.log.append(txn_id, "ROLLBACK", nodo, "abortando transacción")
                conn.rollback()
            except Exception as e:
                self.log.append(txn_id, "FAILED", nodo, f"error en rollback: {e}")
            finally:
                try:
                    conn.close()
                except Exception:
                    pass
        self.log.append(txn_id, "ROLLED_BACK", None, "transacción abortada")

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
