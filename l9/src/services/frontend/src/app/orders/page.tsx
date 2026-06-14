import Link from "next/link";
import { Suspense } from "react";
import { PageHeader } from "@/components/PageHeader";
import { OrderStatusBadge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Card, CardBody } from "@/components/ui/Card";
import { SkeletonList } from "@/components/ui/Feedback";
import {
  EmptyRow,
  Table,
  TBody,
  TD,
  TH,
  THead,
  TR,
} from "@/components/ui/Table";
import { ordersApi } from "@/lib/api";
import { formatCurrency, formatDate } from "@/lib/format";
import { OrdersFilters } from "./filters";

export const dynamic = "force-dynamic";

const STATUSES = [
  { value: "", label: "Todos" },
  { value: "PENDING", label: "Pending" },
  { value: "PROCESSING", label: "Processing" },
  { value: "CONFIRMED", label: "Confirmed" },
  { value: "CANCELLED", label: "Cancelled" },
  { value: "ERROR", label: "Error" },
];

async function OrdersList({ status }: { status?: string }) {
  const orders = await ordersApi.list(100, status || undefined);

  return (
    <Card>
      <CardBody className="p-0">
        <Table>
          <THead>
            <tr>
              <TH>ID</TH>
              <TH>Cliente</TH>
              <TH>Estado</TH>
              <TH>Promo</TH>
              <TH className="text-right">Descuento</TH>
              <TH className="text-right">Total</TH>
              <TH>Creado</TH>
              <TH></TH>
            </tr>
          </THead>
          <TBody>
            {orders.length === 0 ? (
              <EmptyRow
                colSpan={8}
                message={
                  status
                    ? `No hay pedidos en estado ${status}`
                    : "Aún no se han registrado pedidos"
                }
              />
            ) : (
              orders.map((o) => (
                <TR key={o.id}>
                  <TD>
                    <Link
                      href={`/orders/${o.id}`}
                      className="font-mono text-xs text-[var(--primary)] hover:underline"
                    >
                      {o.id.slice(0, 8)}…
                    </Link>
                  </TD>
                  <TD className="font-medium text-slate-700">{o.client_id}</TD>
                  <TD>
                    <OrderStatusBadge status={o.status} />
                  </TD>
                  <TD>
                    {o.promotion_code ? (
                      <span className="rounded bg-slate-100 px-1.5 py-0.5 font-mono text-xs text-slate-700">
                        {o.promotion_code}
                      </span>
                    ) : (
                      <span className="text-xs text-slate-400">—</span>
                    )}
                  </TD>
                  <TD className="text-right text-slate-600">
                    {o.discount_pct ? `${o.discount_pct}%` : "—"}
                  </TD>
                  <TD className="text-right font-medium">
                    {formatCurrency(o.total_amount)}
                  </TD>
                  <TD className="text-xs text-slate-500">
                    {formatDate(o.created_at)}
                  </TD>
                  <TD className="text-right">
                    <Link href={`/orders/${o.id}`}>
                      <Button variant="ghost" size="sm">
                        Ver
                      </Button>
                    </Link>
                  </TD>
                </TR>
              ))
            )}
          </TBody>
        </Table>
      </CardBody>
    </Card>
  );
}

function ListSkeleton() {
  return (
    <Card>
      <CardBody>
        <div className="space-y-2">
          <SkeletonList count={6} className="h-10" />
        </div>
      </CardBody>
    </Card>
  );
}

export default async function OrdersPage(props: {
  searchParams: Promise<{ status?: string }>;
}) {
  const searchParams = await props.searchParams;
  const status = searchParams.status ?? "";

  return (
    <div className="space-y-6">
      <PageHeader
        title="Pedidos"
        description="Listado de pedidos registrados en el sistema"
        actions={
          <Link href="/orders/new">
            <Button>+ Nuevo pedido</Button>
          </Link>
        }
      />

      <OrdersFilters statuses={STATUSES} current={status} />

      <Suspense key={status} fallback={<ListSkeleton />}>
        <OrdersList status={status} />
      </Suspense>
    </div>
  );
}
