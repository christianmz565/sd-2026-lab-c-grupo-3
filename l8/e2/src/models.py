"""Schemas Pydantic para los request/response de la API financiera."""

from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field

CiudadLiteral = Literal["arequipa", "cusco", "trujillo"]


class TransferRequest(BaseModel):
    cuenta_origen: str = Field(..., description="Cuenta que envía dinero", min_length=1, max_length=50)
    cuenta_destino: str = Field(..., description="Cuenta que recibe dinero", min_length=1, max_length=50)
    ciudad_origen: CiudadLiteral = Field(..., description="Ciudad de la cuenta origen")
    ciudad_destino: CiudadLiteral = Field(..., description="Ciudad de la cuenta destino")
    monto: float = Field(..., gt=0, description="Dinero a transferir en S/")
    delay: float = Field(
        default=0.0,
        ge=0,
        description="Segundos de espera entre Fase 1 y Fase 2 (para simular fallos)",
    )


class TransferResponse(BaseModel):
    txn_id: str
    status: Literal["COMMITTED", "ROLLED_BACK", "FAILED"]
    cuenta_origen: str
    cuenta_destino: str
    ciudad_origen: CiudadLiteral
    ciudad_destino: CiudadLiteral
    monto: float
    saldo_origen_despues: float | None = None
    saldo_destino_despues: float | None = None
    log: list[dict]


class CuentaRow(BaseModel):
    ciudad: CiudadLiteral
    numero_cuenta: str
    titular: str
    saldo: float


class CuentasResponse(BaseModel):
    cuentas: list[CuentaRow]


class HealthResponse(BaseModel):
    arequipa: str
    cusco: str
    trujillo: str
