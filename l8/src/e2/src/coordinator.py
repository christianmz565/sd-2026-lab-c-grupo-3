"""Coordinador del protocolo Two-Phase Commit (2PC) para transferencias bancarias.

Implementa la variante clásica:
  - Fase 1 (PREPARE): el coordinador abre una transacción en cada sucursal
    participante, aplica los cambios tentativa-mente y deja la transacción
    en estado "preparado" (no commiteada).
  - Decisión:
      * Si TODOS los nodos contestan OK  -> Fase 2A (COMMIT) en cada uno.
      * Si ALGUNO falla o rechaza        -> Fase 2B (ROLLBACK) en todos.

Nota sobre 2PC real: psycopg no expone XA, así que el "PREPARE" se modela
abriendo la transacción y aplicando los cambios; el "COMMIT" coordinado
consiste en hacer commit() en cada nodo secuencialmente. Si el commit de
uno falla tras haber commiteado los anteriores, la transacción queda en
estado in-doubt (limitación conocida del 2PC, fuera del alcance del Ej.2).
"""

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
    """Orquesta una transferencia distribuida entre dos sucursales."""

    def __init__(self, log: LogStore | None = None) -> None:
        self.log = log or LogStore()

    def transferir(
        self,
        cuenta_origen: str,
        cuenta_destino: str,
        ciudad_origen: str,
        ciudad_destino: str,
        monto: float,
        delay: float = 0.0,
    ) -> dict:
        if ciudad_origen == ciudad_destino:
            raise TransferError("Las sucursales origen y destino deben ser distintas")

        txn_id = uuid.uuid4().hex
        self.log.append(
            txn_id, "START", None,
            f"{ciudad_origen}({cuenta_origen})->{ciudad_destino}({cuenta_destino}) "
            f"S/ {monto:.2f}"
        )

        # ------------------------------------------------------------------
        # FASE 1: PREPARE en cada sucursal participante
        # ------------------------------------------------------------------
        prepared = self._phase_one(
            txn_id, cuenta_origen, cuenta_destino, ciudad_origen, ciudad_destino, monto
        )

        try:
            # ------------------------------------------------------------------
            # Espera configurable entre fases (para simular fallos)
            # ------------------------------------------------------------------
            if delay > 0:
                self.log.append(
                    txn_id,
                    "DELAY",
                    None,
                    f"esperando {delay}s — puede detener una sucursal ahora",
                )
                time.sleep(delay)

            # ------------------------------------------------------------------
            # VALIDACIÓN PRE-COMMIT: verificamos que todos sigan vivos
            # ------------------------------------------------------------------
            self._validate_prepared_connections(prepared)

            # ------------------------------------------------------------------
            # FASE 2A: COMMIT en cada sucursal (todos ya están "preparados")
            # ------------------------------------------------------------------
            return self._phase_two_commit(
                prepared, cuenta_origen, cuenta_destino, ciudad_origen, ciudad_destino, monto
            )

        except (Exception, KeyboardInterrupt) as e:
            # Si algo falla antes o durante el inicio de la fase 2,
            # intentamos abortar todo lo que esté "preparado".
            self.log.append(txn_id, "FAILED", None, f"error detectado: {e}")
            self._phase_two_rollback(prepared, ciudad_origen, ciudad_destino)
            
            # Devolvemos una respuesta de error para la UI
            return _build_response(
                txn_id=txn_id,
                status="ROLLED_BACK",
                cuenta_origen=cuenta_origen,
                cuenta_destino=cuenta_destino,
                ciudad_origen=ciudad_origen,
                ciudad_destino=ciudad_destino,
                monto=monto,
                saldo_origen_despues=None,
                saldo_destino_despues=None,
                log_entries=self.log.all(),
            )

    # ----------------------------------------------------------------------
    # Fase 1
    # ----------------------------------------------------------------------
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
                raise TransferError(f"Sucursal {name} no responde tras el retraso: {clean_err}") from e

    def _phase_one(
        self,
        txn_id: str,
        cuenta_origen: str,
        cuenta_destino: str,
        ciudad_origen: str,
        ciudad_destino: str,
        monto: float,
    ) -> _PreparedTxn:
        """Abre una transacción en cada sucursal, aplica los cambios y registra
        la decisión tentativa. Si algo falla, hace rollback en las sucursales que
        ya estén abiertas antes de propagar la excepción.
        """
        opened: list[tuple[str, psycopg.Connection]] = []
        self.log.append(
            txn_id, "VALIDATE", ciudad_origen,
            f"verificando saldo en cuenta {cuenta_origen}"
        )

        # Abrimos conexiones explícitamente para poder hacer rollback
        # nosotros mismos si algo falla a mitad del PREPARE.
        try:
            conn_origen = _open(ciudad_origen)
        except (pg_errors.Error, psycopg.OperationalError) as e:
            clean_err = db.simplify_db_error(e)
            self.log.append(txn_id, "FAILED", ciudad_origen, f"error de conexión: {clean_err}")
            raise TransferError(f"No se pudo conectar a la sucursal {ciudad_origen}: {clean_err}") from e
            
        opened.append((ciudad_origen, conn_origen))

        try:
            saldo_origen_pre = db.lock_and_debit(conn_origen, cuenta_origen, monto)
            self.log.append(
                txn_id,
                "PREPARED",
                ciudad_origen,
                f"débito de S/ {monto:.2f} (saldo pre=S/ {saldo_origen_pre + monto:.2f})",
            )
        except (LookupError, ValueError) as e:
            self.log.append(txn_id, "FAILED", ciudad_origen, f"rechazo en PREPARE: {e}")
            self._rollback_all(opened)
            raise TransferError(str(e)) from e
        except (pg_errors.Error, psycopg.OperationalError) as e:
            clean_err = db.simplify_db_error(e)
            self.log.append(txn_id, "FAILED", ciudad_origen, f"error DB: {clean_err}")
            self._rollback_all(opened)
            raise TransferError(f"Fallo de BD en sucursal {ciudad_origen}: {clean_err}") from e

        try:
            conn_destino = _open(ciudad_destino)
        except (pg_errors.Error, psycopg.OperationalError) as e:
            clean_err = db.simplify_db_error(e)
            self.log.append(txn_id, "FAILED", ciudad_destino, f"error de conexión: {clean_err}")
            self._rollback_all(opened)
            raise TransferError(f"No se pudo conectar a la sucursal {ciudad_destino}: {clean_err}") from e
            
        opened.append((ciudad_destino, conn_destino))

        try:
            saldo_destino_pre = db.lock_and_credit(conn_destino, cuenta_destino, monto)
            self.log.append(
                txn_id,
                "PREPARED",
                ciudad_destino,
                f"crédito de S/ {monto:.2f} (saldo pre=S/ {saldo_destino_pre - monto:.2f})",
            )
        except LookupError as e:
            self.log.append(txn_id, "FAILED", ciudad_destino, f"rechazo en PREPARE: {e}")
            self._rollback_all(opened)
            raise TransferError(str(e)) from e
        except (pg_errors.Error, psycopg.OperationalError) as e:
            clean_err = db.simplify_db_error(e)
            self.log.append(txn_id, "FAILED", ciudad_destino, f"error DB: {clean_err}")
            self._rollback_all(opened)
            raise TransferError(f"Fallo de BD en sucursal {ciudad_destino}: {clean_err}") from e

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
        cuenta_origen: str,
        cuenta_destino: str,
        ciudad_origen: str,
        ciudad_destino: str,
        monto: float,
    ) -> dict:
        """Ejecuta commit en cada sucursal en orden. Construye la respuesta final."""
        txn_id = prepared.txn_id

        saldo_origen_despues: float | None = None
        saldo_destino_despues: float | None = None
        
        # Guardamos conexiones en una lista para iterar
        plan = [
            (ciudad_origen, prepared.conn_origen, "origen"),
            (ciudad_destino, prepared.conn_destino, "destino"),
        ]
        
        commits_exitosos = 0
        fallos_commit: list[str] = []

        for i, (ciudad, conn, key) in enumerate(plan):
            try:
                self.log.append(txn_id, "COMMIT", ciudad, "orden de commit enviada")
                conn.commit()
                self.log.append(txn_id, "COMMITTED", ciudad, "commit OK")
                commits_exitosos += 1
            except (pg_errors.Error, psycopg.OperationalError, Exception) as e:
                clean_err = db.simplify_db_error(e)
                self.log.append(txn_id, "FAILED", ciudad, f"commit falló: {clean_err}")
                fallos_commit.append(f"{ciudad}: {clean_err}")
                
                # Si falla el PRIMER commit, aún podemos intentar rollback en el resto
                # para mantener la atomicidad.
                if commits_exitosos == 0:
                    self.log.append(txn_id, "ROLLBACK", None, "abortando tras fallo en primer commit")
                    # Cerramos esta conexión fallida
                    try:
                        conn.close()
                    except Exception:
                        pass
                    
                    # Hacemos rollback en los demás que siguen en el plan
                    pendientes = plan[i+1:]
                    for p_ciudad, p_conn, _ in pendientes:
                        try:
                            self.log.append(txn_id, "ROLLBACK", p_ciudad, "abortando transacción preparada")
                            p_conn.rollback()
                            p_conn.close()
                        except Exception:
                            pass
                    
                    return _build_response(
                        txn_id=txn_id,
                        status="ROLLED_BACK",
                        cuenta_origen=cuenta_origen,
                        cuenta_destino=cuenta_destino,
                        ciudad_origen=ciudad_origen,
                        ciudad_destino=ciudad_destino,
                        monto=monto,
                        saldo_origen_despues=None,
                        saldo_destino_despues=None,
                        log_entries=self.log.all(),
                    )
                
                # Si ya hubo algún commit exitoso, estamos en estado "in-doubt"
                continue

            # Consultar saldo final para la UI
            try:
                with psycopg.connect(db.get_sucursal(ciudad).dsn, autocommit=True) as c2:
                    saldo = db.read_saldo(c2, cuenta_origen if key == "origen" else cuenta_destino)
                    if key == "origen":
                        saldo_origen_despues = saldo
                    else:
                        saldo_destino_despues = saldo
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
                cuenta_origen=cuenta_origen,
                cuenta_destino=cuenta_destino,
                ciudad_origen=ciudad_origen,
                ciudad_destino=ciudad_destino,
                monto=monto,
                saldo_origen_despues=saldo_origen_despues,
                saldo_destino_despues=saldo_destino_despues,
                log_entries=self.log.all(),
            )

        self.log.append(txn_id, "COMMITTED", None, "transacción confirmada")
        return _build_response(
            txn_id=txn_id,
            status="COMMITTED",
            cuenta_origen=cuenta_origen,
            cuenta_destino=cuenta_destino,
            ciudad_origen=ciudad_origen,
            ciudad_destino=ciudad_destino,
            monto=monto,
            saldo_origen_despues=saldo_origen_despues,
            saldo_destino_despues=saldo_destino_despues,
            log_entries=self.log.all(),
        )

    # ----------------------------------------------------------------------
    # Fase 2B (Abortar)
    # ----------------------------------------------------------------------
    def _phase_two_rollback(self, prepared: _PreparedTxn, ciudad_origen: str, ciudad_destino: str) -> None:
        """Fase de rollback cuando se decide no commitear."""
        txn_id = prepared.txn_id
        for ciudad, conn in [
            (ciudad_origen, prepared.conn_origen),
            (ciudad_destino, prepared.conn_destino),
        ]:
            try:
                self.log.append(txn_id, "ROLLBACK", ciudad, "abortando transacción")
                conn.rollback()
            except Exception as e:
                self.log.append(txn_id, "FAILED", ciudad, f"error en rollback: {e}")
            finally:
                try:
                    conn.close()
                except Exception:
                    pass
        self.log.append(txn_id, "ROLLED_BACK", None, "transacción abortada")

    # ----------------------------------------------------------------------
    # Helpers
    # ----------------------------------------------------------------------
    def _rollback_all(self, opened: list[tuple[str, psycopg.Connection]]) -> None:
        """Hace rollback en todas las conexiones abiertas y las cierra."""
        for ciudad, conn in opened:
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
    """Abre una conexión a una sucursal en modo transacción explícita."""
    sucursal = db.get_sucursal(nombre)
    return psycopg.connect(sucursal.dsn, autocommit=False)


def _build_response(
    *,
    txn_id: str,
    status: str,
    cuenta_origen: str,
    cuenta_destino: str,
    ciudad_origen: str,
    ciudad_destino: str,
    monto: float,
    saldo_origen_despues: float | None,
    saldo_destino_despues: float | None,
    log_entries: list[dict],
) -> dict:
    """Filtra el log para devolver sólo las entradas de esta transacción."""
    return {
        "txn_id": txn_id,
        "status": status,
        "cuenta_origen": cuenta_origen,
        "cuenta_destino": cuenta_destino,
        "ciudad_origen": ciudad_origen,
        "ciudad_destino": ciudad_destino,
        "monto": monto,
        "saldo_origen_despues": saldo_origen_despues,
        "saldo_destino_despues": saldo_destino_despues,
        "log": [e for e in log_entries if e["txn_id"] == txn_id],
    }
