import { KpiCard, PageHeader } from "@/components/PageHeader";
import { Badge } from "@/components/ui/Badge";
import { Card, CardBody, CardHeader } from "@/components/ui/Card";
import { EmptyState } from "@/components/ui/Feedback";
import { transportApi } from "@/lib/api";
import { formatDate, formatNumber } from "@/lib/format";

export const dynamic = "force-dynamic";

export default async function ShippingPage() {
  const drivers = await transportApi.listDrivers();
  const available = drivers.filter((d) => d.available).length;
  const busy = drivers.length - available;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Transporte"
        description="Flota de conductores refrigerados disponibles"
      />

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <KpiCard
          label="Conductores totales"
          value={formatNumber(drivers.length)}
        />
        <KpiCard
          label="Disponibles"
          value={formatNumber(available)}
          tone="success"
        />
        <KpiCard label="En ruta" value={formatNumber(busy)} tone="warning" />
      </div>

      <Card>
        <CardHeader
          title="Conductores"
          subtitle="Asignación con SELECT FOR UPDATE SKIP LOCKED"
        />
        <CardBody>
          {drivers.length === 0 ? (
            <EmptyState
              title="Sin conductores registrados"
              description="Los conductores se siembran en init.sql al inicializar la BD."
            />
          ) : (
            <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
              {drivers.map((d) => (
                <div
                  key={d.id}
                  className="rounded-lg border border-[var(--border)] p-4"
                >
                  <div className="flex items-start justify-between">
                    <div>
                      <p className="font-medium text-[var(--foreground)]">
                        {d.name}
                      </p>
                      <p className="text-xs text-slate-500">{d.vehicle}</p>
                    </div>
                    <Badge tone={d.available ? "success" : "neutral"}>
                      {d.available ? "Disponible" : "En ruta"}
                    </Badge>
                  </div>
                </div>
              ))}
            </div>
          )}
        </CardBody>
      </Card>

      <Card>
        <CardHeader
          title="Estados de envío"
          subtitle="Flujo permitido: ASSIGNED → IN_TRANSIT → DELIVERED"
        />
        <CardBody>
          <div className="grid grid-cols-1 gap-3 md:grid-cols-3">
            <div className="rounded-lg border border-sky-200 bg-sky-50 p-4">
              <p className="text-xs uppercase tracking-wider text-sky-700">
                ASSIGNED
              </p>
              <p className="mt-1 text-sm text-sky-800">
                Conductor y vehículo asignados al pedido.
              </p>
            </div>
            <div className="rounded-lg border border-amber-200 bg-amber-50 p-4">
              <p className="text-xs uppercase tracking-wider text-amber-700">
                IN_TRANSIT
              </p>
              <p className="mt-1 text-sm text-amber-800">
                El pedido salió hacia la dirección del cliente.
              </p>
            </div>
            <div className="rounded-lg border border-emerald-200 bg-emerald-50 p-4">
              <p className="text-xs uppercase tracking-wider text-emerald-700">
                DELIVERED
              </p>
              <p className="mt-1 text-sm text-emerald-800">
                Entrega completada. El conductor queda liberado.
              </p>
            </div>
          </div>
          <p className="mt-3 text-xs text-slate-500">
            Las transiciones se ejecutan desde el detalle de cada pedido.
          </p>
        </CardBody>
      </Card>

      <p className="text-center text-xs text-slate-400">
        Última actualización: {formatDate(new Date().toISOString())}
      </p>
    </div>
  );
}
