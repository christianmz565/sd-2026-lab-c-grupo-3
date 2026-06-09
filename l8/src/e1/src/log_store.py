"""Log en memoria (thread-safe) para registrar los eventos del protocolo 2PC.

Sólo persiste durante la vida del proceso; al reiniciar se pierde. Suficiente
para el Ejercicio 1, donde el objetivo es la demostración, no la
recuperación ante crashes.
"""
from __future__ import annotations

import threading
import time
from collections import deque
from dataclasses import dataclass, field
from typing import Deque, Literal

Fase = Literal["START", "VALIDATE", "PREPARE", "PREPARED", "DELAY", "COMMIT", "COMMITTED", "ROLLBACK", "ROLLED_BACK", "FAILED"]
Estado = Literal["COMMITTED", "ROLLED_BACK", "FAILED"]


@dataclass
class LogEntry:
    txn_id: str
    timestamp: float
    fase: Fase
    nodo: str | None
    detalle: str = ""

    def to_dict(self) -> dict:
        return {
            "txn_id": self.txn_id,
            "timestamp": self.timestamp,
            "fase": self.fase,
            "nodo": self.nodo,
            "detalle": self.detalle,
        }


@dataclass
class LogStore:
    """Almacén append-only de eventos 2PC con tamaño máximo."""
    max_entries: int = 1000
    _entries: Deque[LogEntry] = field(default_factory=deque)
    _lock: threading.Lock = field(default_factory=threading.Lock)

    def append(self, txn_id: str, fase: Fase, nodo: str | None, detalle: str = "") -> None:
        entry = LogEntry(
            txn_id=txn_id,
            timestamp=time.time(),
            fase=fase,
            nodo=nodo,
            detalle=detalle,
        )
        with self._lock:
            self._entries.append(entry)
            while len(self._entries) > self.max_entries:
                self._entries.popleft()

    def all(self) -> list[dict]:
        with self._lock:
            return [e.to_dict() for e in self._entries]

    def clear(self) -> None:
        with self._lock:
            self._entries.clear()
