"""Schemas Pydantic para los request/response de la API."""

from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field

NodoLiteral = Literal["arequipa", "lima", "cusco"]


class TransferRequest(BaseModel):
    origen: NodoLiteral = Field(..., description="Almacén que entrega stock")
    destino: NodoLiteral = Field(..., description="Almacén que recibe stock")
    producto: str = Field(..., min_length=1, max_length=100)
    cantidad: int = Field(..., gt=0, description="Unidades a transferir")
    delay: float = Field(
        default=0.0,
        ge=0,
        description="Segundos de espera entre Fase 1 y Fase 2 (para simular fallos)",
    )


class TransferResponse(BaseModel):
    txn_id: str
    status: Literal["COMMITTED", "ROLLED_BACK", "FAILED"]
    origen: str
    destino: str
    producto: str
    cantidad: int
    stock_origen_despues: int | None = None
    stock_destino_despues: int | None = None
    log: list[dict]


class InventarioRow(BaseModel):
    almacen: NodoLiteral
    producto: str
    stock: int


class InventarioResponse(BaseModel):
    inventario: list[InventarioRow]


class HealthResponse(BaseModel):
    arequipa: str
    lima: str
    cusco: str
