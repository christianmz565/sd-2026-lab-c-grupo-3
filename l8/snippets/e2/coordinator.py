# START-SNIPPET,phase-one
    def _phase_one(
        self,
        txn_id: str,
        cuenta_origen: str,
        cuenta_destino: str,
        ciudad_origen: str,
        ciudad_destino: str,
        monto: float,
    ) -> _PreparedTxn:
        """
        Abre una transacción en cada sucursal, aplica los cambios y registra
        la decisión tentativa.
        """
        opened: list[tuple[str, psycopg.Connection]] = []
        # ... validación ...
        try:
            conn_origen = _open(ciudad_origen)
            saldo_origen_pre = db.lock_and_debit(conn_origen, cuenta_origen, monto)
            self.log.append(txn_id, "PREPARED", ciudad_origen, f"débito de S/ {monto:.2f}")
            
            conn_destino = _open(ciudad_destino)
            saldo_destino_pre = db.lock_and_credit(conn_destino, cuenta_destino, monto)
            self.log.append(txn_id, "PREPARED", ciudad_destino, f"crédito de S/ {monto:.2f}")
        except Exception as e:
            self._rollback_all(opened)
            raise TransferError(str(e)) from e
        return _PreparedTxn(txn_id=txn_id, conn_origen=conn_origen, conn_destino=conn_destino)
# END-SNIPPET

# START-SNIPPET,phase-two-commit
    def _phase_two_commit(
        self,
        prepared: _PreparedTxn,
        # ... parámetros ...
    ) -> dict:
        """Ejecuta commit en cada sucursal en orden. Garantiza atomicidad."""
        txn_id = prepared.txn_id
        plan = [
            (ciudad_origen, prepared.conn_origen, "origen"),
            (ciudad_destino, prepared.conn_destino, "destino"),
        ]
        # ... commit secuencial ...
        for ciudad, conn, key in plan:
            self.log.append(txn_id, "COMMIT", ciudad, "orden de commit enviada")
            conn.commit()
            self.log.append(txn_id, "COMMITTED", ciudad, "commit OK")
        # ... procesar respuesta ...
# END-SNIPPET
