import type { ReactNode } from "react";

export function PageHeader({
  title,
  description,
  actions,
}: {
  title: ReactNode;
  description?: ReactNode;
  actions?: ReactNode;
}) {
  return (
    <div className="mb-6 flex flex-wrap items-end justify-between gap-3">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">{title}</h1>
        {description ? (
          <p className="mt-1 text-sm text-slate-500">{description}</p>
        ) : null}
      </div>
      {actions ? (
        <div className="flex items-center gap-2">{actions}</div>
      ) : null}
    </div>
  );
}

export function KpiCard({
  label,
  value,
  hint,
  tone = "default",
}: {
  label: string;
  value: ReactNode;
  hint?: ReactNode;
  tone?: "default" | "warning" | "danger" | "success" | "primary";
}) {
  const accent: Record<string, string> = {
    default: "border-slate-200",
    warning: "border-amber-200",
    danger: "border-red-200",
    success: "border-emerald-200",
    primary: "border-teal-200",
  };
  const text: Record<string, string> = {
    default: "text-slate-900",
    warning: "text-amber-700",
    danger: "text-red-700",
    success: "text-emerald-700",
    primary: "text-teal-700",
  };
  return (
    <div
      className={`rounded-xl border ${accent[tone]} bg-[var(--surface)] p-5 shadow-sm`}
    >
      <p className="text-xs font-medium uppercase tracking-wider text-slate-500">
        {label}
      </p>
      <p className={`mt-2 text-2xl font-semibold ${text[tone]}`}>{value}</p>
      {hint ? <p className="mt-1 text-xs text-slate-500">{hint}</p> : null}
    </div>
  );
}
