import { PageHeader } from "@/components/PageHeader";
import { Badge } from "@/components/ui/Badge";
import { Card, CardBody, CardHeader } from "@/components/ui/Card";
import { EmptyState } from "@/components/ui/Feedback";
import { ordersApi } from "@/lib/api";
import { formatDate, formatPercent } from "@/lib/format";

export const dynamic = "force-dynamic";

export default async function PromotionsPage() {
  const promotions = await ordersApi.promotions().catch(() => []);

  return (
    <div className="space-y-6">
      <PageHeader
        title="Promociones"
        description="Códigos de descuento activos para aplicar en pedidos"
      />

      {promotions.length === 0 ? (
        <Card>
          <EmptyState
            title="Sin promociones activas"
            description="Cuando se registren promociones aparecerán en esta pantalla."
          />
        </Card>
      ) : (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {promotions.map((p) => (
            <Card key={p.code}>
              <CardHeader
                title={
                  <span className="font-mono text-lg tracking-wide">
                    {p.code}
                  </span>
                }
                action={
                  <Badge tone="primary">{formatPercent(p.discount_pct)}</Badge>
                }
              />
              <CardBody className="space-y-2 text-sm">
                <div className="flex justify-between text-slate-500">
                  <span>Válido desde</span>
                  <span>{formatDate(p.valid_from)}</span>
                </div>
                <div className="flex justify-between text-slate-500">
                  <span>Válido hasta</span>
                  <span>{p.valid_until ? formatDate(p.valid_until) : "—"}</span>
                </div>
                <p className="mt-2 rounded-md bg-slate-50 p-2 text-xs text-slate-500">
                  Se aplica atómicamente al crear el pedido. Se valida en la
                  misma transacción de BD que la creación.
                </p>
              </CardBody>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
