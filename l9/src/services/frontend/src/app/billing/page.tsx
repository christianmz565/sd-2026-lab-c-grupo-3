import Link from "next/link";
import { Suspense } from "react";
import { KpiCard, PageHeader } from "@/components/PageHeader";
import { Badge } from "@/components/ui/Badge";
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
import { billingApi } from "@/lib/api";
import { formatCurrency, formatDate, formatNumber } from "@/lib/format";

export const dynamic = "force-dynamic";

async function BillingContent() {
  const invoices = await billingApi.listInvoices();
  const total = invoices.reduce((acc, i) => acc + i.total, 0);
  const taxes = invoices.reduce((acc, i) => acc + i.tax_amount, 0);
  const discounts = invoices.reduce((acc, i) => acc + i.discount_amount, 0);

  return (
    <>
      <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
        <KpiCard
          label="Facturas emitidas"
          value={formatNumber(invoices.length)}
        />
        <KpiCard
          label="Descuentos"
          value={formatCurrency(discounts)}
          tone="warning"
        />
        <KpiCard
          label="IGV recaudado"
          value={formatCurrency(taxes)}
          tone="primary"
        />
        <KpiCard
          label="Total facturado"
          value={formatCurrency(total)}
          tone="success"
        />
      </div>
      <Card>
        <CardBody className="p-0">
          <Table>
            <THead>
              <tr>
                <TH>N° Factura</TH>
                <TH>Pedido</TH>
                <TH>Cliente</TH>
                <TH className="text-right">Subtotal</TH>
                <TH className="text-right">Desc.</TH>
                <TH className="text-right">IGV</TH>
                <TH className="text-right">Total</TH>
                <TH>Estado</TH>
                <TH>Emitida</TH>
              </tr>
            </THead>
            <TBody>
              {invoices.length === 0 ? (
                <EmptyRow colSpan={9} message="Aún no se emitieron facturas" />
              ) : (
                invoices.map((i) => (
                  <TR key={i.id}>
                    <TD className="font-mono text-xs font-medium">
                      {i.invoice_number}
                    </TD>
                    <TD>
                      <Link
                        href={`/orders/${i.order_id}`}
                        className="font-mono text-xs text-[var(--primary)] hover:underline"
                      >
                        {i.order_id.slice(0, 8)}…
                      </Link>
                    </TD>
                    <TD className="text-slate-600">{i.client_id}</TD>
                    <TD className="text-right">{formatCurrency(i.subtotal)}</TD>
                    <TD className="text-right text-slate-500">
                      {i.discount_amount > 0
                        ? `−${formatCurrency(i.discount_amount)}`
                        : "—"}
                    </TD>
                    <TD className="text-right text-slate-500">
                      {formatCurrency(i.tax_amount)}
                    </TD>
                    <TD className="text-right font-semibold">
                      {formatCurrency(i.total)}
                    </TD>
                    <TD>
                      <Badge tone="success">{i.status}</Badge>
                    </TD>
                    <TD className="text-xs text-slate-500">
                      {formatDate(i.issued_at)}
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

function BillingFallback() {
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

export default function BillingPage() {
  return (
    <div className="space-y-6">
      <PageHeader
        title="Facturación"
        description="Historial de facturas emitidas (idempotentes, sin duplicados)"
      />
      <Suspense fallback={<BillingFallback />}>
        <BillingContent />
      </Suspense>
    </div>
  );
}
