"use client";

import { useRouter, useSearchParams } from "next/navigation";

interface Status {
  value: string;
  label: string;
}

export function OrdersFilters({
  statuses,
  current,
}: {
  statuses: Status[];
  current: string;
}) {
  const router = useRouter();
  const params = useSearchParams();

  const onChange = (value: string) => {
    const next = new URLSearchParams(params.toString());
    if (value) next.set("status", value);
    else next.delete("status");
    router.push(`/orders${next.toString() ? `?${next}` : ""}`);
  };

  return (
    <div className="flex flex-wrap items-center gap-2">
      <span className="text-xs uppercase tracking-wider text-slate-500">
        Estado:
      </span>
      {statuses.map((s) => {
        const active = current === s.value;
        return (
          <button
            key={s.value}
            type="button"
            onClick={() => onChange(s.value)}
            className={`rounded-full border px-3 py-1 text-xs font-medium transition-colors ${
              active
                ? "border-[var(--primary)] bg-[var(--primary)] text-white"
                : "border-[var(--border-strong)] bg-[var(--surface)] text-slate-600 hover:bg-[var(--surface-muted)]"
            }`}
          >
            {s.label}
          </button>
        );
      })}
    </div>
  );
}
