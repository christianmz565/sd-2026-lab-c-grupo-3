import Link from "next/link";
import { Suspense } from "react";
import { KpiCard, PageHeader } from "@/components/PageHeader";
import { Badge, NotificationStatusBadge } from "@/components/ui/Badge";
import { Card, CardBody, CardHeader } from "@/components/ui/Card";
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
import { notificationsApi } from "@/lib/api";
import { formatDate, formatNumber } from "@/lib/format";

export const dynamic = "force-dynamic";

const TYPE_TONE: Record<string, "primary" | "info" | "warning" | "danger"> = {
  ORDER_CONFIRMED: "primary",
  ORDER_SHIPPED: "info",
  ORDER_CANCELLED: "warning",
  ORDER_IN_TRANSIT: "info",
};

async function NotificationsContent() {
  const [list, queue] = await Promise.all([
    notificationsApi.list(),
    notificationsApi.queueSize(),
  ]);
  const sent = list.filter((n) => n.status === "SENT").length;
  const pending = list.filter((n) => n.status === "PENDING").length;
  const failed = list.filter((n) => n.status === "FAILED").length;

  return (
    <>
      <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
        <KpiCard
          label="Cola Redis"
          value={formatNumber(queue.pending)}
          hint={queue.queue}
          tone={queue.pending > 0 ? "warning" : "success"}
        />
        <KpiCard label="Enviadas" value={formatNumber(sent)} tone="success" />
        <KpiCard
          label="Pendientes"
          value={formatNumber(pending)}
          tone="warning"
        />
        <KpiCard
          label="Fallidas"
          value={formatNumber(failed)}
          tone={failed > 0 ? "danger" : "default"}
        />
      </div>

      <Card>
        <CardHeader
          title="Historial de notificaciones"
          subtitle="Cola asíncrona procesada por worker en background"
        />
        <CardBody className="p-0">
          <Table>
            <THead>
              <tr>
                <TH>ID</TH>
                <TH>Tipo</TH>
                <TH>Destinatario</TH>
                <TH>Pedido</TH>
                <TH>Estado</TH>
                <TH>Intentos</TH>
                <TH>Enviada</TH>
              </tr>
            </THead>
            <TBody>
              {list.length === 0 ? (
                <EmptyRow
                  colSpan={7}
                  message="Sin notificaciones registradas todavía"
                />
              ) : (
                list.map((n) => (
                  <TR key={n.id}>
                    <TD className="text-xs text-slate-500">#{n.id}</TD>
                    <TD>
                      <Badge tone={TYPE_TONE[n.type] ?? "neutral"}>
                        {n.type}
                      </Badge>
                    </TD>
                    <TD className="text-sm text-slate-700">{n.recipient}</TD>
                    <TD>
                      {n.order_id ? (
                        <Link
                          href={`/orders/${n.order_id}`}
                          className="font-mono text-xs text-[var(--primary)] hover:underline"
                        >
                          {n.order_id.slice(0, 8)}…
                        </Link>
                      ) : (
                        <span className="text-xs text-slate-400">—</span>
                      )}
                    </TD>
                    <TD>
                      <NotificationStatusBadge status={n.status} />
                    </TD>
                    <TD className="text-center text-slate-600">{n.attempts}</TD>
                    <TD className="text-xs text-slate-500">
                      {formatDate(n.sent_at)}
                    </TD>
                  </TR>
                ))
              )}
            </TBody>
          </Table>
        </CardBody>
      </Card>
    </>
  );
}

function NotificationsFallback() {
  return (
    <Card>
      <CardBody>
        <div className="space-y-2">
          <SkeletonList count={5} className="h-10" />
        </div>
      </CardBody>
    </Card>
  );
}

export default function NotificationsPage() {
  return (
    <div className="space-y-6">
      <PageHeader
        title="Notificaciones"
        description="Cola Redis de emails transaccionales y su historial"
      />
      <Suspense fallback={<NotificationsFallback />}>
        <NotificationsContent />
      </Suspense>
    </div>
  );
}
