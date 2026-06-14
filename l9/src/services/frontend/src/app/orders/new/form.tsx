"use client";

import { useRouter } from "next/navigation";
import { useMemo, useState } from "react";
import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Card, CardBody, CardHeader } from "@/components/ui/Card";
import { Field, Input, Select, Textarea } from "@/components/ui/Input";
import { ApiError, ordersApi } from "@/lib/api";
import { formatCurrency, generateIdempotencyKey } from "@/lib/format";
import type { OrderItem, Product, Promotion } from "@/lib/types";

interface DraftItem {
  product_id: number | "";
  quantity: number;
}

const emptyItem = (): DraftItem => ({ product_id: "", quantity: 1 });

export function NewOrderForm({
  products,
  promotions,
}: {
  products: Product[];
  promotions: Promotion[];
}) {
  const router = useRouter();
  const [clientId, setClientId] = useState("");
  const [clientEmail, setClientEmail] = useState("");
  const [address, setAddress] = useState("");
  const [promoCode, setPromoCode] = useState("");
  const [idempotencyKey, setIdempotencyKey] = useState("");
  const [items, setItems] = useState<DraftItem[]>([emptyItem()]);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const productMap = useMemo(
    () => new Map(products.map((p) => [p.id, p])),
    [products],
  );

  const subtotal = useMemo(() => {
    return items.reduce((acc, it) => {
      if (it.product_id === "") return acc;
      const product = productMap.get(it.product_id);
      if (!product) return acc;
      return acc + product.unit_price * it.quantity;
    }, 0);
  }, [items, productMap]);

  const discountPct = useMemo(() => {
    const promo = promotions.find((p) => p.code === promoCode.trim());
    return promo?.discount_pct ?? 0;
  }, [promoCode, promotions]);

  const total = subtotal * (1 - discountPct / 100);

  const updateItem = (index: number, patch: Partial<DraftItem>) => {
    setItems((prev) =>
      prev.map((it, i) => (i === index ? { ...it, ...patch } : it)),
    );
  };
  const addItem = () => setItems((prev) => [...prev, emptyItem()]);
  const removeItem = (i: number) =>
    setItems((prev) =>
      prev.length === 1 ? prev : prev.filter((_, idx) => idx !== i),
    );

  const canSubmit =
    clientId.trim() &&
    clientEmail.trim() &&
    address.trim() &&
    items.every((it) => it.product_id !== "" && it.quantity > 0);

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!canSubmit) return;
    setSubmitting(true);
    setError(null);
    try {
      const payloadItems: OrderItem[] = items
        .map((it) => {
          const product =
            it.product_id === "" ? undefined : productMap.get(it.product_id);
          if (!product) return null;
          return {
            product_id: it.product_id as number,
            quantity: it.quantity,
            unit_price: product.unit_price,
          };
        })
        .filter((it): it is OrderItem => it !== null);
      const res = await ordersApi.create(
        {
          client_id: clientId.trim(),
          client_email: clientEmail.trim(),
          delivery_address: address.trim(),
          promotion_code: promoCode.trim() || null,
          items: payloadItems,
        },
        idempotencyKey.trim() || undefined,
      );
      router.push(`/orders/${res.order_id}`);
    } catch (err) {
      if (err instanceof ApiError) {
        setError(err.detail);
      } else {
        setError("Error inesperado al crear el pedido");
      }
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <form onSubmit={onSubmit} className="grid grid-cols-1 gap-6 lg:grid-cols-3">
      <div className="space-y-6 lg:col-span-2">
        <Card>
          <CardHeader title="Datos del cliente" />
          <CardBody className="grid grid-cols-1 gap-4 md:grid-cols-2">
            <Field label="ID del cliente" required>
              <Input
                value={clientId}
                onChange={(e) => setClientId(e.target.value)}
                placeholder="cliente-001"
                required
              />
            </Field>
            <Field label="Email" required>
              <Input
                type="email"
                value={clientEmail}
                onChange={(e) => setClientEmail(e.target.value)}
                placeholder="cliente@ejemplo.com"
                required
              />
            </Field>
            <Field
              label="Dirección de entrega"
              required
              className="md:col-span-2"
            >
              <Textarea
                value={address}
                onChange={(e) => setAddress(e.target.value)}
                placeholder="Av. La Marina 123, Lima"
                rows={2}
                required
              />
            </Field>
          </CardBody>
        </Card>

        <Card>
          <CardHeader
            title="Ítems del pedido"
            subtitle="Selecciona los productos y sus cantidades"
            action={
              <Button
                type="button"
                variant="secondary"
                size="sm"
                onClick={addItem}
              >
                + Agregar ítem
              </Button>
            }
          />
          <CardBody className="space-y-3">
            {items.map((it, i) => {
              const product =
                it.product_id !== "" ? productMap.get(it.product_id) : null;
              const itemKey = `row-${i}-${it.product_id}-${it.quantity}`;
              return (
                <div
                  key={itemKey}
                  className="grid grid-cols-12 items-end gap-3 rounded-lg border border-[var(--border)] p-3"
                >
                  <Field label="Producto" className="col-span-12 md:col-span-7">
                    <Select
                      value={it.product_id === "" ? "" : String(it.product_id)}
                      onChange={(e) =>
                        updateItem(i, {
                          product_id:
                            e.target.value === "" ? "" : Number(e.target.value),
                        })
                      }
                      required
                    >
                      <option value="">Seleccionar producto…</option>
                      {products.map((p) => (
                        <option
                          key={p.id}
                          value={p.id}
                          disabled={p.stock === 0}
                        >
                          {p.name} · {p.sku} · stock {p.stock} · S/{" "}
                          {p.unit_price.toFixed(2)}
                        </option>
                      ))}
                    </Select>
                  </Field>
                  <Field label="Cantidad" className="col-span-6 md:col-span-3">
                    <Input
                      type="number"
                      min={1}
                      max={product?.stock ?? 9999}
                      value={it.quantity}
                      onChange={(e) =>
                        updateItem(i, { quantity: Number(e.target.value) || 1 })
                      }
                      required
                    />
                  </Field>
                  <div className="col-span-6 flex items-center justify-end gap-3 md:col-span-2">
                    {product ? (
                      <span className="text-sm font-medium text-slate-700">
                        {formatCurrency(product.unit_price * it.quantity)}
                      </span>
                    ) : null}
                    <Button
                      type="button"
                      variant="ghost"
                      size="sm"
                      onClick={() => removeItem(i)}
                      disabled={items.length === 1}
                      aria-label="Eliminar ítem"
                    >
                      ×
                    </Button>
                  </div>
                </div>
              );
            })}
          </CardBody>
        </Card>
      </div>

      <div className="space-y-6">
        <Card>
          <CardHeader title="Promoción e idempotencia" />
          <CardBody className="space-y-4">
            <Field
              label="Código de promoción"
              hint={
                promotions.length === 0
                  ? "No hay promociones activas"
                  : `${promotions.length} promoción(es) activa(s)`
              }
            >
              <Select
                value={promoCode}
                onChange={(e) => setPromoCode(e.target.value)}
              >
                <option value="">— Sin promoción —</option>
                {promotions.map((p) => (
                  <option key={p.code} value={p.code}>
                    {p.code} ({p.discount_pct}%)
                  </option>
                ))}
              </Select>
            </Field>
            <Field
              label="X-Idempotency-Key"
              hint="Opcional. Evita duplicados si reintenta la misma petición"
            >
              <div className="flex gap-2">
                <Input
                  value={idempotencyKey}
                  onChange={(e) => setIdempotencyKey(e.target.value)}
                  placeholder="miclave-001"
                />
                <Button
                  type="button"
                  variant="secondary"
                  size="sm"
                  onClick={() => setIdempotencyKey(generateIdempotencyKey())}
                >
                  Generar
                </Button>
              </div>
            </Field>
          </CardBody>
        </Card>

        <Card>
          <CardHeader title="Resumen" />
          <CardBody className="space-y-2 text-sm">
            <div className="flex justify-between text-slate-600">
              <span>Subtotal</span>
              <span>{formatCurrency(subtotal)}</span>
            </div>
            {discountPct > 0 ? (
              <div className="flex justify-between text-emerald-700">
                <span className="flex items-center gap-2">
                  Descuento
                  <Badge tone="success">{promoCode}</Badge>
                </span>
                <span>−{discountPct}%</span>
              </div>
            ) : null}
            <div className="flex justify-between border-t border-[var(--border)] pt-2 text-base font-semibold">
              <span>Total</span>
              <span>{formatCurrency(total)}</span>
            </div>
          </CardBody>
          <div className="border-t border-[var(--border)] p-4">
            {error ? (
              <p className="mb-3 rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-700">
                {error}
              </p>
            ) : null}
            <Button
              type="submit"
              loading={submitting}
              disabled={!canSubmit}
              className="w-full"
            >
              Registrar pedido
            </Button>
            <p className="mt-2 text-center text-[11px] text-slate-500">
              El pedido se acepta en &lt;500ms; el resto del flujo es asíncrono.
            </p>
          </div>
        </Card>
      </div>
    </form>
  );
}
