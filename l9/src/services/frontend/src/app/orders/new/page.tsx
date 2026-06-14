import { Suspense } from "react";
import { PageHeader } from "@/components/PageHeader";
import { Card, CardBody } from "@/components/ui/Card";
import { SkeletonList } from "@/components/ui/Feedback";
import { inventoryApi, ordersApi } from "@/lib/api";
import { NewOrderForm } from "./form";

export const dynamic = "force-dynamic";

async function FormLoader() {
  const [products, promotions] = await Promise.all([
    inventoryApi.listProducts().catch(() => []),
    ordersApi.promotions().catch(() => []),
  ]);
  return <NewOrderForm products={products} promotions={promotions} />;
}

function FormSkeleton() {
  return (
    <Card>
      <CardBody>
        <div className="space-y-3">
          <SkeletonList count={5} className="h-10" />
        </div>
      </CardBody>
    </Card>
  );
}

export default function NewOrderPage() {
  return (
    <div className="space-y-6">
      <PageHeader
        title="Nuevo pedido"
        description="Registra un pedido. El sistema lo procesa en background tras aceptar la solicitud."
      />
      <Suspense fallback={<FormSkeleton />}>
        <FormLoader />
      </Suspense>
    </div>
  );
}
