"use client";

import { useRouter } from "next/navigation";
import { useState, useTransition } from "react";
import { ConfirmDialog } from "@/components/ConfirmDialog";
import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Field, Input } from "@/components/ui/Input";
import {
  EmptyRow,
  Table,
  TBody,
  TD,
  TH,
  THead,
  TR,
} from "@/components/ui/Table";
import { ApiError, inventoryApi } from "@/lib/api";
import { formatCurrency, formatNumber } from "@/lib/format";
import type { Product } from "@/lib/types";

export function InventoryTable({ products }: { products: Product[] }) {
  const router = useRouter();
  const [restockTarget, setRestockTarget] = useState<Product | null>(null);
  const [quantity, setQuantity] = useState(50);
  const [pending, startTransition] = useTransition();
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState("");

  const filtered = products.filter(
    (p) =>
      !filter ||
      p.name.toLowerCase().includes(filter.toLowerCase()) ||
      p.sku.toLowerCase().includes(filter.toLowerCase()),
  );

  const onConfirm = async () => {
    if (!restockTarget) return;
    setError(null);
    try {
      await inventoryApi.restock(restockTarget.id, quantity);
      setRestockTarget(null);
      setQuantity(50);
      startTransition(() => router.refresh());
    } catch (err) {
      if (err instanceof ApiError) setError(err.detail);
      else setError("Error al reabastecer");
    }
  };

  return (
    <div>
      <div className="flex items-center justify-between gap-3 border-b border-[var(--border)] px-4 py-3">
        <p className="text-sm text-slate-500">{filtered.length} producto(s)</p>
        <input
          type="search"
          placeholder="Buscar por nombre o SKU…"
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
          className="w-64 rounded-lg border border-[var(--border-strong)] bg-[var(--surface)] px-3 py-1.5 text-sm focus:border-[var(--primary)] focus:outline-none focus:ring-2 focus:ring-[var(--primary)]/20"
        />
      </div>
      <Table>
        <THead>
          <tr>
            <TH>Producto</TH>
            <TH>SKU</TH>
            <TH className="text-right">Precio</TH>
            <TH className="text-right">Stock</TH>
            <TH>Estado</TH>
            <TH className="text-right">Valor</TH>
            <TH className="text-right"></TH>
          </tr>
        </THead>
        <TBody>
          {filtered.length === 0 ? (
            <EmptyRow colSpan={7} message="No se encontraron productos" />
          ) : (
            filtered.map((p) => (
              <TR key={p.id}>
                <TD className="font-medium">{p.name}</TD>
                <TD className="font-mono text-xs text-slate-500">{p.sku}</TD>
                <TD className="text-right">{formatCurrency(p.unit_price)}</TD>
                <TD className="text-right font-semibold">
                  {formatNumber(p.stock)}
                </TD>
                <TD>
                  {p.stock === 0 ? (
                    <Badge tone="danger">Agotado</Badge>
                  ) : p.stock < 100 ? (
                    <Badge tone="warning">Bajo</Badge>
                  ) : (
                    <Badge tone="success">OK</Badge>
                  )}
                </TD>
                <TD className="text-right text-slate-600">
                  {formatCurrency(p.stock * p.unit_price)}
                </TD>
                <TD className="text-right">
                  <Button
                    size="sm"
                    variant="secondary"
                    onClick={() => {
                      setRestockTarget(p);
                      setError(null);
                    }}
                  >
                    Reabastecer
                  </Button>
                </TD>
              </TR>
            ))
          )}
        </TBody>
      </Table>

      <ConfirmDialog
        open={restockTarget !== null}
        title="Reabastecer producto"
        description={
          restockTarget
            ? `Agregar stock a "${restockTarget.name}" (${restockTarget.sku})`
            : ""
        }
        confirmLabel="Confirmar restock"
        loading={pending}
        onConfirm={onConfirm}
        onCancel={() => {
          setRestockTarget(null);
          setError(null);
        }}
      >
        <div className="mt-3">
          <Field label="Cantidad a agregar" required>
            <Input
              type="number"
              min={1}
              value={quantity}
              onChange={(e) => setQuantity(Number(e.target.value) || 1)}
            />
          </Field>
          {error ? (
            <p className="mt-2 rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-700">
              {error}
            </p>
          ) : null}
        </div>
      </ConfirmDialog>
    </div>
  );
}
