import Link from "next/link";
import { Suspense } from "react";
import { KpiCard, PageHeader } from "@/components/PageHeader";
import { Badge, OrderStatusBadge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Card, CardBody, CardHeader } from "@/components/ui/Card";
import { Skeleton, SkeletonList } from "@/components/ui/Feedback";
import {
  EmptyRow,
  Table,
  TBody,
  TD,
  TH,
  THead,
  TR,
} from "@/components/ui/Table";
import {
  inventoryApi,
  notificationsApi,
  ordersApi,
  transportApi,
} from "@/lib/api";
import { formatCurrency, formatDate, formatNumber } from "@/lib/format";

export const dynamic = "force-dynamic";

async function loadDashboard() {
  const [orders, products, drivers, queue] = await Promise.all([
    ordersApi.list(100).catch(() => []),
    inventoryApi.listProducts().catch(() => []),
    transportApi.listDrivers().catch(() => []),
    notificationsApi.queueSize().catch(() => ({ queue: "—", pending: 0 })),
  ]);
  return { orders, products, drivers, queue };
}

function lowStock(
  products: Awaited<ReturnType<typeof inventoryApi.listProducts>>,
) {
  return products
    .filter((p) => p.stock < 100)
    .sort((a, b) => a.stock - b.stock)
    .slice(0, 5);
}

function todayOrders(orders: Awaited<ReturnType<typeof ordersApi.list>>) {
  const today = new Date();
  return orders.filter((o) => {
    if (!o.created_at) return false;
    const d = new Date(o.created_at);
    return (
      d.getUTCFullYear() === today.getUTCFullYear() &&
      d.getUTCMonth() === today.getUTCMonth() &&
      d.getUTCDate() === today.getUTCDate()
    );
  });
}

function countByStatus(orders: Awaited<ReturnType<typeof ordersApi.list>>) {
  const counts: Record<string, number> = {};
  for (const o of orders) {
    counts[o.status] = (counts[o.status] ?? 0) + 1;
  }
  return counts;
}

async function DashboardContent() {
  const { orders, products, drivers, queue } = await loadDashboard();
  const counts = countByStatus(orders);
  const today = todayOrders(orders);
  const availableDrivers = drivers.filter((d) => d.available).length;
  const low = lowStock(products);
  const recent = [...orders]
    .sort((a, b) => (b.created_at ?? "").localeCompare(a.created_at ?? ""))
    .slice(0, 6);

  return (
    <div className="space-y-6">
      <PageHeader
        title="Dashboard"
        description="Resumen en tiempo real del sistema distribuido de LogiFresh"
        actions={
          <Link href="/orders/new">
            <Button>+ Nuevo pedido</Button>
          </Link>
        }
      />

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <KpiCard
          label="Pedidos hoy"
          value={formatNumber(today.length)}
          hint={`Total registrados: ${formatNumber(orders.length)}`}
          tone="primary"
        />
        <KpiCard
          label="Pendientes / Procesando"
          value={formatNumber((counts.PENDING ?? 0) + (counts.PROCESSING ?? 0))}
          hint="Esperando confirmación del backend"
          tone="warning"
        />
        <KpiCard
          label="Confirmados"
          value={formatNumber(counts.CONFIRMED ?? 0)}
          tone="success"
        />
        <KpiCard
          label="Cola de notificaciones"
          value={formatNumber(queue.pending)}
          hint="Redis · notifications:queue"
        />
      </div>

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        <Card>
          <CardHeader
            title="Stock crítico"
            subtitle="Productos con inventario bajo"
            action={
              <Link href="/inventory">
                <Button variant="ghost" size="sm">
                  Ver todo →
                </Button>
              </Link>
            }
          />
          <CardBody className="p-0">
            <Table>
              <THead>
                <tr>
                  <TH>Producto</TH>
                  <TH>SKU</TH>
                  <TH className="text-right">Stock</TH>
                  <TH className="text-right">Precio</TH>
                </tr>
              </THead>
              <TBody>
                {low.length === 0 ? (
                  <EmptyRow
                    colSpan={4}
                    message="Todo el inventario se encuentra saludable"
                  />
                ) : (
                  low.map((p) => (
                    <TR key={p.id}>
                      <TD className="font-medium">{p.name}</TD>
                      <TD className="text-slate-500">{p.sku}</TD>
                      <TD className="text-right">
                        <Badge tone={p.stock === 0 ? "danger" : "warning"}>
                          {p.stock}
                        </Badge>
                      </TD>
                      <TD className="text-right">
                        {formatCurrency(p.unit_price)}
                      </TD>
                    </TR>
                  ))
                )}
              </TBody>
            </Table>
          </CardBody>
        </Card>

        <Card>
          <CardHeader
            title="Pedidos recientes"
            subtitle="Últimos movimientos del sistema"
            action={
              <Link href="/orders">
                <Button variant="ghost" size="sm">
                  Ver todo →
                </Button>
              </Link>
            }
          />
          <CardBody className="p-0">
            <Table>
              <THead>
                <tr>
                  <TH>ID</TH>
                  <TH>Cliente</TH>
                  <TH>Estado</TH>
                  <TH className="text-right">Total</TH>
                </tr>
              </THead>
              <TBody>
                {recent.length === 0 ? (
                  <EmptyRow
                    colSpan={4}
                    message="Aún no hay pedidos registrados"
                  />
                ) : (
                  recent.map((o) => (
                    <TR key={o.id}>
                      <TD>
                        <Link
                          href={`/orders/${o.id}`}
                          className="font-mono text-xs text-[var(--primary)] hover:underline"
                        >
                          {o.id.slice(0, 8)}…
                        </Link>
                      </TD>
                      <TD className="text-slate-600">{o.client_id}</TD>
                      <TD>
                        <OrderStatusBadge status={o.status} />
                      </TD>
                      <TD className="text-right">
                        {formatCurrency(o.total_amount)}
                      </TD>
                    </TR>
                  ))
                )}
              </TBody>
            </Table>
          </CardBody>
        </Card>

        <Card>
          <CardHeader
            title="Conductores disponibles"
            subtitle="Flota de transporte refrigerado"
            action={
              <Link href="/shipping">
                <Button variant="ghost" size="sm">
                  Ver →
                </Button>
              </Link>
            }
          />
          <CardBody>
            <div className="grid grid-cols-1 gap-3 sm:grid-cols-3">
              {drivers.map((d) => (
                <div
                  key={d.id}
                  className="flex items-center justify-between rounded-lg border border-[var(--border)] px-3 py-2"
                >
                  <div className="min-w-0">
                    <p className="truncate text-sm font-medium">{d.name}</p>
                    <p className="truncate text-xs text-slate-500">
                      {d.vehicle}
                    </p>
                  </div>
                  <Badge tone={d.available ? "success" : "neutral"}>
                    {d.available ? "Libre" : "En ruta"}
                  </Badge>
                </div>
              ))}
            </div>
            <p className="mt-3 text-xs text-slate-500">
              {availableDrivers} de {drivers.length} disponibles
            </p>
          </CardBody>
        </Card>

        <Card>
          <CardHeader
            title="Resumen por estado"
            subtitle="Distribución actual de pedidos"
          />
          <CardBody>
            <div className="space-y-2">
              {(
                [
                  "PENDING",
                  "PROCESSING",
                  "CONFIRMED",
                  "CANCELLED",
                  "ERROR",
                ] as const
              ).map((status) => {
                const n = counts[status] ?? 0;
                const total = orders.length || 1;
                const pct = Math.round((n / total) * 100);
                return (
                  <div key={status}>
                    <div className="mb-1 flex items-center justify-between text-xs">
                      <OrderStatusBadge status={status} />
                      <span className="text-slate-500">
                        {n} pedidos · {pct}%
                      </span>
                    </div>
                    <div className="h-1.5 w-full overflow-hidden rounded-full bg-slate-100">
                      <div
                        className="h-full rounded-full bg-[var(--primary)]"
                        style={{ width: `${pct}%` }}
                      />
                    </div>
                  </div>
                );
              })}
            </div>
          </CardBody>
        </Card>
      </div>

      <p className="text-center text-xs text-slate-400">
        Última actualización: {formatDate(new Date().toISOString())}
      </p>
    </div>
  );
}

function DashboardSkeleton() {
  return (
    <div className="space-y-6">
      <Skeleton className="h-10 w-64" />
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <SkeletonList count={4} className="h-24" />
      </div>
      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        <SkeletonList count={4} className="h-64" />
      </div>
    </div>
  );
}

export default function DashboardPage() {
  return (
    <Suspense fallback={<DashboardSkeleton />}>
      <DashboardContent />
    </Suspense>
  );
}
