import Link from "next/link";
import { notFound } from "next/navigation";
import { Suspense } from "react";
import { PageHeader } from "@/components/PageHeader";
import { Button } from "@/components/ui/Button";
import { Skeleton, SkeletonList } from "@/components/ui/Feedback";
import { ordersApi } from "@/lib/api";
import { OrderDetail } from "./detail";

export const dynamic = "force-dynamic";

async function OrderLoader({ id }: { id: string }) {
  try {
    const order = await ordersApi.get(id);
    return <OrderDetail initialOrder={order} />;
  } catch (err: unknown) {
    const status = (err as { status?: number })?.status;
    if (status === 404) notFound();
    throw err;
  }
}

function DetailSkeleton() {
  return (
    <div className="space-y-4">
      <Skeleton className="h-24" />
      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        <SkeletonList count={4} className="h-48" />
      </div>
    </div>
  );
}

export default async function OrderDetailPage(props: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await props.params;
  return (
    <div className="space-y-6">
      <PageHeader
        title="Detalle del pedido"
        description={`ID: ${id}`}
        actions={
          <Link href="/orders">
            <Button variant="secondary">← Volver al listado</Button>
          </Link>
        }
      />
      <Suspense fallback={<DetailSkeleton />}>
        <OrderLoader id={id} />
      </Suspense>
    </div>
  );
}
