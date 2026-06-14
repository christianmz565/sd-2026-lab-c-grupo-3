import type { ReactNode } from "react";

type Tone = "neutral" | "info" | "success" | "warning" | "danger" | "primary";

const toneStyles: Record<Tone, string> = {
  neutral: "bg-slate-100 text-slate-700 border-slate-200",
  info: "bg-sky-50 text-sky-700 border-sky-200",
  success: "bg-emerald-50 text-emerald-700 border-emerald-200",
  warning: "bg-amber-50 text-amber-700 border-amber-200",
  danger: "bg-red-50 text-red-700 border-red-200",
  primary: "bg-teal-50 text-teal-700 border-teal-200",
};

export function Badge({
  tone = "neutral",
  children,
  className = "",
}: {
  tone?: Tone;
  children: ReactNode;
  className?: string;
}) {
  return (
    <span
      className={`inline-flex items-center gap-1 rounded-full border px-2.5 py-0.5 text-xs font-medium ${toneStyles[tone]} ${className}`}
    >
      {children}
    </span>
  );
}

const orderStatusTone: Record<string, Tone> = {
  PENDING: "warning",
  PROCESSING: "info",
  CONFIRMED: "success",
  CANCELLED: "neutral",
  ERROR: "danger",
};

export function OrderStatusBadge({ status }: { status: string }) {
  return <Badge tone={orderStatusTone[status] ?? "neutral"}>{status}</Badge>;
}

const shipmentStatusTone: Record<string, Tone> = {
  ASSIGNED: "info",
  IN_TRANSIT: "warning",
  DELIVERED: "success",
};

export function ShipmentStatusBadge({ status }: { status: string }) {
  return <Badge tone={shipmentStatusTone[status] ?? "neutral"}>{status}</Badge>;
}

const notificationStatusTone: Record<string, Tone> = {
  PENDING: "warning",
  SENT: "success",
  FAILED: "danger",
};

export function NotificationStatusBadge({ status }: { status: string }) {
  return (
    <Badge tone={notificationStatusTone[status] ?? "neutral"}>{status}</Badge>
  );
}
