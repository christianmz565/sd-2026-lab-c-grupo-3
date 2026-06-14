"use client";

import Link from "next/link";
import { Button } from "@/components/ui/Button";

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div className="flex min-h-[60vh] flex-col items-center justify-center gap-3 text-center">
      <p className="text-xs uppercase tracking-wider text-slate-500">
        Error inesperado
      </p>
      <h1 className="text-2xl font-semibold">No se pudo cargar la página</h1>
      <p className="max-w-md text-sm text-slate-600">
        {error.message ||
          "Verifica que los microservicios estén levantados en localhost:8001-8005."}
      </p>
      {error.digest ? (
        <p className="font-mono text-xs text-slate-400">{error.digest}</p>
      ) : null}
      <div className="mt-2 flex gap-2">
        <Button onClick={() => reset()}>Reintentar</Button>
        <Link href="/dashboard">
          <Button variant="secondary">Ir al dashboard</Button>
        </Link>
      </div>
    </div>
  );
}
