"use client";

import { useEffect, useState } from "react";
import {
  billingApi,
  inventoryApi,
  notificationsApi,
  ordersApi,
  transportApi,
} from "@/lib/api";

interface ServiceStatus {
  name: string;
  ok: boolean | null;
}

async function ping(name: string, fn: () => Promise<unknown>) {
  try {
    await fn();
    return { name, ok: true } satisfies ServiceStatus;
  } catch {
    return { name, ok: false } satisfies ServiceStatus;
  }
}

const services: Array<{ name: string; ping: () => Promise<ServiceStatus> }> = [
  { name: "Pedidos", ping: () => ping("Pedidos", ordersApi.health) },
  {
    name: "Inventario",
    ping: () => ping("Inventario", inventoryApi.health),
  },
  { name: "Facturación", ping: () => ping("Facturación", billingApi.health) },
  { name: "Transporte", ping: () => ping("Transporte", transportApi.health) },
  {
    name: "Notificaciones",
    ping: () => ping("Notificaciones", notificationsApi.health),
  },
];

export function HealthIndicator() {
  const [statuses, setStatuses] = useState<ServiceStatus[]>(() =>
    services.map((s) => ({ name: s.name, ok: null })),
  );

  useEffect(() => {
    let mounted = true;
    const check = async () => {
      const results = await Promise.all(services.map((s) => s.ping()));
      if (mounted) setStatuses(results);
    };
    void check();
    const id = setInterval(check, 15000);
    return () => {
      mounted = false;
      clearInterval(id);
    };
  }, []);

  return (
    <div className="flex flex-wrap items-center gap-1.5">
      {statuses.map((s) => {
        const color =
          s.ok === null
            ? "bg-slate-200 text-slate-500"
            : s.ok
              ? "bg-emerald-100 text-emerald-700 border border-emerald-200"
              : "bg-red-100 text-red-700 border border-red-200";
        return (
          <span
            key={s.name}
            className={`inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-[11px] font-medium ${color}`}
            title={`Servicio ${s.name}: ${s.ok === null ? "verificando" : s.ok ? "ok" : "caído"}`}
          >
            <span
              className={`h-1.5 w-1.5 rounded-full ${
                s.ok === null
                  ? "bg-slate-400"
                  : s.ok
                    ? "bg-emerald-500"
                    : "bg-red-500"
              }`}
            />
            {s.name}
          </span>
        );
      })}
    </div>
  );
}
