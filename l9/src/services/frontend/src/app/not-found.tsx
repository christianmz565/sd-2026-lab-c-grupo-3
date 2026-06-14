import Link from "next/link";
import { Button } from "@/components/ui/Button";

export default function NotFound() {
  return (
    <div className="flex min-h-[60vh] flex-col items-center justify-center gap-3 text-center">
      <p className="text-xs uppercase tracking-wider text-slate-500">404</p>
      <h1 className="text-2xl font-semibold">Recurso no encontrado</h1>
      <p className="max-w-md text-sm text-slate-600">
        El pedido o recurso que buscas no existe o fue eliminado.
      </p>
      <Link href="/orders">
        <Button>Ver pedidos</Button>
      </Link>
    </div>
  );
}
