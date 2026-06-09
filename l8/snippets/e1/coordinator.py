# START-SNIPPET,phase-one
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
        # ... (lógica similar para el nodo destino)
# END-SNIPPET

# START-SNIPPET,phase-two-commit
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
        # ... inicialización ...
        for i, (nodo, conn, key) in enumerate(plan):
            try:
                self.log.append(txn_id, "COMMIT", nodo, "orden de commit enviada")
                conn.commit()
                self.log.append(txn_id, "COMMITTED", nodo, "commit OK")
                commits_exitosos += 1
            except (pg_errors.Error, psycopg.OperationalError, Exception) as e:
                # Manejar fallo de commit (recuperación atómica)
                # ...
# END-SNIPPET
