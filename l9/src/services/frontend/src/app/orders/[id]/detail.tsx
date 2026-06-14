"use client";

import { useRouter } from "next/navigation";
import { useCallback, useEffect, useState } from "react";
import { ConfirmDialog } from "@/components/ConfirmDialog";
import {
  NotificationStatusBadge,
  OrderStatusBadge,
  ShipmentStatusBadge,
} from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Card, CardBody, CardHeader } from "@/components/ui/Card";
import { ErrorBox } from "@/components/ui/Feedback";
import {
  ApiError,
  billingApi,
  inventoryApi,
  notificationsApi,
  ordersApi,
  transportApi,
} from "@/lib/api";
import { formatCurrency, formatDate } from "@/lib/format";
import type {
  Invoice,
  Notification,
  Order,
  Shipment,
  ShipmentStatus,
  StockMovement,
} from "@/lib/types";

const TERMINAL: ReadonlyArray<Order["status"]> = [
  "CONFIRMED",
  "CANCELLED",
  "ERROR",
];

export function OrderDetail({ initialOrder }: { initialOrder: Order }) {
  const router = useRouter();
  const [order, setOrder] = useState<Order>(initialOrder);
  const [invoice, setInvoice] = useState<Invoice | null>(null);
  const [shipment, setShipment] = useState<Shipment | null>(null);
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [movements, setMovements] = useState<StockMovement[]>([]);
  const [cancelOpen, setCancelOpen] = useState(false);
  const [cancelLoading, setCancelLoading] = useState(false);
  const [cancelError, setCancelError] = useState<string | null>(null);
  const [shipmentLoading, setShipmentLoading] = useState(false);
  const [shipmentError, setShipmentError] = useState<string | null>(null);

  const refresh = useCallback(async () => {
    const fresh = await ordersApi.get(order.id);
    setOrder(fresh);
    return fresh;
  }, [order.id]);

  useEffect(() => {
    let mounted = true;
    const load = async () => {
      try {
        const [inv, ship, notif, mov] = await Promise.allSettled([
          billingApi.getInvoice(order.id),
          transportApi.getShipment(order.id),
          notificationsApi.list(),
          inventoryApi.getMovements(order.id),
        ]);
        if (!mounted) return;
        if (inv.status === "fulfilled") setInvoice(inv.value);
        if (ship.status === "fulfilled") setShipment(ship.value);
        if (notif.status === "fulfilled") {
          setNotifications(notif.value.filter((n) => n.order_id === order.id));
        }
        if (mov.status === "fulfilled") setMovements(mov.value);
      } catch {}
    };
    void load();
    return () => {
      mounted = false;
    };
  }, [order.id]);

  useEffect(() => {
    if (TERMINAL.includes(order.status)) return;
    const id = setInterval(async () => {
      try {
        await refresh();
      } catch {}
    }, 2000);
    return () => clearInterval(id);
  }, [order.status, refresh]);

  const onCancel = async () => {
    setCancelLoading(true);
    setCancelError(null);
    try {
      await ordersApi.cancel(order.id);
      await refresh();
      setCancelOpen(false);
      router.refresh();
    } catch (err) {
      if (err instanceof ApiError) setCancelError(err.detail);
      else setCancelError("Error al cancelar");
    } finally {
      setCancelLoading(false);
    }
  };

  const updateShipment = async (next: ShipmentStatus) => {
    setShipmentLoading(true);
    setShipmentError(null);
    try {
      await transportApi.updateStatus(order.id, next);
      const fresh = await transportApi.getShipment(order.id);
      setShipment(fresh);
    } catch (err) {
      if (err instanceof ApiError) setShipmentError(err.detail);
      else setShipmentError("Error al actualizar envío");
    } finally {
      setShipmentLoading(false);
    }
  };

  const subtotal = order.items?.reduce(
    (acc, it) => acc + it.unit_price * it.quantity,
    0,
  );

  return (
    <div className="space-y-6">
      <Card>
        <CardBody className="flex flex-wrap items-center justify-between gap-4">
          <div className="space-y-1">
            <div className="flex items-center gap-3">
              <h2 className="text-lg font-semibold">
                Pedido {order.id.slice(0, 8)}…
              </h2>
              <OrderStatusBadge status={order.status} />
              {!TERMINAL.includes(order.status) ? (
                <span className="inline-flex items-center gap-1 text-xs text-slate-500">
                  <span className="h-1.5 w-1.5 animate-pulse rounded-full bg-amber-500" />
                  Sincronizando…
                </span>
              ) : null}
            </div>
            <p className="text-sm text-slate-600">
              Cliente: <span className="font-medium">{order.client_id}</span> ·
              Creado {formatDate(order.created_at)}
            </p>
          </div>
          {order.status === "PENDING" ? (
            <Button variant="danger" onClick={() => setCancelOpen(true)}>
              Cancelar pedido
            </Button>
          ) : null}
        </CardBody>
      </Card>

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        <Card>
          <CardHeader title="Ítems y totales" />
          <CardBody className="space-y-2 text-sm">
            {order.items && order.items.length > 0 ? (
              <ul className="divide-y divide-[var(--border)]">
                {order.items.map((it) => (
                  <li
                    key={`item-${it.product_id}-${it.unit_price}`}
                    className="flex items-center justify-between py-2"
                  >
                    <span className="text-slate-700">
                      Producto #{it.product_id} · {it.quantity} ×{" "}
                      {formatCurrency(it.unit_price)}
                    </span>
                    <span className="font-medium">
                      {formatCurrency(it.unit_price * it.quantity)}
                    </span>
                  </li>
                ))}
              </ul>
            ) : (
              <p className="text-slate-500">Sin ítems</p>
            )}
            <div className="border-t border-[var(--border)] pt-2 space-y-1">
              <div className="flex justify-between text-slate-600">
                <span>Subtotal</span>
                <span>{formatCurrency(subtotal)}</span>
              </div>
              {order.discount_pct > 0 ? (
                <div className="flex justify-between text-emerald-700">
                  <span>
                    Descuento
                    {order.promotion_code ? ` (${order.promotion_code})` : ""}
                  </span>
                  <span>−{order.discount_pct}%</span>
                </div>
              ) : null}
              <div className="flex justify-between text-base font-semibold">
                <span>Total</span>
                <span>{formatCurrency(order.total_amount)}</span>
              </div>
            </div>
          </CardBody>
        </Card>

        <Card>
          <CardHeader title="Factura" />
          <CardBody>
            {invoice ? (
              <dl className="space-y-2 text-sm">
                <div className="flex justify-between">
                  <dt className="text-slate-500">N° factura</dt>
                  <dd className="font-mono font-medium">
                    {invoice.invoice_number}
                  </dd>
                </div>
                <div className="flex justify-between">
                  <dt className="text-slate-500">Subtotal</dt>
                  <dd>{formatCurrency(invoice.subtotal)}</dd>
                </div>
                <div className="flex justify-between">
                  <dt className="text-slate-500">Descuento</dt>
                  <dd>−{formatCurrency(invoice.discount_amount)}</dd>
                </div>
                <div className="flex justify-between">
                  <dt className="text-slate-500">IGV (18%)</dt>
                  <dd>{formatCurrency(invoice.tax_amount)}</dd>
                </div>
                <div className="flex justify-between border-t border-[var(--border)] pt-2 text-base font-semibold">
                  <dt>Total</dt>
                  <dd>{formatCurrency(invoice.total)}</dd>
                </div>
                <p className="text-xs text-slate-500">
                  Emitida: {formatDate(invoice.issued_at)}
                </p>
              </dl>
            ) : (
              <p className="text-sm text-slate-500">
                {order.status === "CANCELLED"
                  ? "Pedido cancelado — sin factura"
                  : "La factura aparecerá cuando el pedido sea confirmado."}
              </p>
            )}
          </CardBody>
        </Card>

        <Card>
          <CardHeader
            title="Envío"
            action={
              shipment ? <ShipmentStatusBadge status={shipment.status} /> : null
            }
          />
          <CardBody>
            {shipment ? (
              <div className="space-y-3 text-sm">
                <div className="flex justify-between">
                  <span className="text-slate-500">Conductor</span>
                  <span className="font-medium">
                    {shipment.driver_name ?? "—"}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Vehículo</span>
                  <span className="font-medium">{shipment.vehicle ?? "—"}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Asignado</span>
                  <span>{formatDate(shipment.assigned_at)}</span>
                </div>
                {shipment.delivered_at ? (
                  <div className="flex justify-between">
                    <span className="text-slate-500">Entregado</span>
                    <span>{formatDate(shipment.delivered_at)}</span>
                  </div>
                ) : null}
                {shipmentError ? <ErrorBox message={shipmentError} /> : null}
                {shipment.status === "ASSIGNED" ? (
                  <Button
                    onClick={() => updateShipment("IN_TRANSIT")}
                    loading={shipmentLoading}
                    size="sm"
                  >
                    Marcar en tránsito
                  </Button>
                ) : null}
                {shipment.status === "IN_TRANSIT" ? (
                  <Button
                    onClick={() => updateShipment("DELIVERED")}
                    loading={shipmentLoading}
                    size="sm"
                  >
                    Marcar entregado
                  </Button>
                ) : null}
              </div>
            ) : (
              <p className="text-sm text-slate-500">
                Aún no se ha asignado un envío.
              </p>
            )}
          </CardBody>
        </Card>

        <Card>
          <CardHeader title="Notificaciones enviadas" />
          <CardBody>
            {notifications.length === 0 ? (
              <p className="text-sm text-slate-500">
                Sin notificaciones registradas para este pedido.
              </p>
            ) : (
              <ul className="space-y-2 text-sm">
                {notifications.map((n) => (
                  <li
                    key={n.id}
                    className="flex items-center justify-between rounded-md border border-[var(--border)] px-3 py-2"
                  >
                    <div>
                      <p className="font-medium text-slate-800">{n.type}</p>
                      <p className="text-xs text-slate-500">
                        → {n.recipient} · {formatDate(n.sent_at)}
                      </p>
                    </div>
                    <NotificationStatusBadge status={n.status} />
                  </li>
                ))}
              </ul>
            )}
          </CardBody>
        </Card>

        <Card className="lg:col-span-2">
          <CardHeader
            title="Movimientos de inventario"
            subtitle="Auditoría de stock reservado / liberado para este pedido"
          />
          <CardBody>
            {movements.length === 0 ? (
              <p className="text-sm text-slate-500">
                Sin movimientos registrados.
              </p>
            ) : (
              <ul className="space-y-1 text-sm">
                {movements.map((m) => (
                  <li
                    key={m.id}
                    className="flex items-center justify-between rounded border border-[var(--border)] px-3 py-2"
                  >
                    <span>
                      <span className="font-medium">{m.product_name}</span> ·{" "}
                      <span className="text-slate-500">{m.reason}</span>
                    </span>
                    <span
                      className={`font-mono text-sm ${
                        m.delta < 0 ? "text-red-600" : "text-emerald-600"
                      }`}
                    >
                      {m.delta > 0 ? `+${m.delta}` : m.delta}
                    </span>
                  </li>
                ))}
              </ul>
            )}
          </CardBody>
        </Card>
      </div>

      <ConfirmDialog
        open={cancelOpen}
        title="Cancelar pedido"
        description={`Esta acción cancelará el pedido ${order.id.slice(0, 8)}… y liberará el stock reservado. No se puede deshacer.`}
        confirmLabel="Sí, cancelar"
        variant="danger"
        loading={cancelLoading}
        onConfirm={onCancel}
        onCancel={() => {
          setCancelOpen(false);
          setCancelError(null);
        }}
      />
      {cancelError ? (
        <p className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700">
          {cancelError}
        </p>
      ) : null}
    </div>
  );
}
