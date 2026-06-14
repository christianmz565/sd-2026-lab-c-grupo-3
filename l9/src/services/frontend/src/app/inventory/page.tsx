import { Suspense } from "react";
import { KpiCard, PageHeader } from "@/components/PageHeader";
import { Card, CardBody } from "@/components/ui/Card";
import { SkeletonList } from "@/components/ui/Feedback";
import { inventoryApi } from "@/lib/api";
import { formatCurrency, formatNumber } from "@/lib/format";
import { InventoryTable } from "./table";

export const dynamic = "force-dynamic";

async function InventoryContent() {
  const products = await inventoryApi.listProducts();
  const totalSkus = products.length;
  const lowStock = products.filter((p) => p.stock < 100).length;
  const outOfStock = products.filter((p) => p.stock === 0).length;
  const totalValue = products.reduce(
    (acc, p) => acc + p.stock * p.unit_price,
    0,
  );
  return (
    <>
      <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
        <KpiCard label="SKUs" value={formatNumber(totalSkus)} />
        <KpiCard
          label="Stock bajo"
          value={formatNumber(lowStock)}
          tone={lowStock > 0 ? "warning" : "success"}
        />
        <KpiCard
          label="Sin stock"
          value={formatNumber(outOfStock)}
          tone={outOfStock > 0 ? "danger" : "success"}
        />
        <KpiCard
          label="Valor de inventario"
          value={formatCurrency(totalValue)}
          tone="primary"
        />
      </div>
      <Card>
        <CardBody className="p-0">
          <InventoryTable products={products} />
        </CardBody>
      </Card>
    </>
  );
}

function InventoryFallback() {
  return (
    <Card>
      <CardBody>
        <div className="space-y-2">
          <SkeletonList count={5} className="h-12" />
        </div>
      </CardBody>
    </Card>
  );
}

export default function InventoryPage() {
  return (
    <div className="space-y-6">
      <PageHeader
        title="Inventario"
        description="Productos y stock actual del sistema"
      />
      <Suspense fallback={<InventoryFallback />}>
        <InventoryContent />
      </Suspense>
    </div>
  );
}
