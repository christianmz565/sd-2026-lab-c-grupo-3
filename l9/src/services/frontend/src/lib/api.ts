import type {
  CreateOrderRequest,
  CreateOrderResponse,
  Driver,
  HealthStatus,
  Invoice,
  Notification,
  NotificationType,
  Order,
  Product,
  Promotion,
  QueueSize,
  Shipment,
  ShipmentStatus,
  StockMovement,
} from "./types";

const ORDERS_URL =
  process.env.NEXT_PUBLIC_ORDERS_URL ?? "http://localhost:8001";
const INVENTORY_URL =
  process.env.NEXT_PUBLIC_INVENTORY_URL ?? "http://localhost:8002";
const BILLING_URL =
  process.env.NEXT_PUBLIC_BILLING_URL ?? "http://localhost:8003";
const TRANSPORT_URL =
  process.env.NEXT_PUBLIC_TRANSPORT_URL ?? "http://localhost:8004";
const NOTIFICATIONS_URL =
  process.env.NEXT_PUBLIC_NOTIFICATIONS_URL ?? "http://localhost:8005";

export class ApiError extends Error {
  status: number;
  detail: string;
  constructor(status: number, detail: string) {
    super(detail);
    this.status = status;
    this.detail = detail;
    this.name = "ApiError";
  }
}

async function request<T>(
  url: string,
  init?: RequestInit & { idempotencyKey?: string },
): Promise<T> {
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    ...(init?.headers as Record<string, string> | undefined),
  };
  if (init?.idempotencyKey) {
    headers["X-Idempotency-Key"] = init.idempotencyKey;
  }

  const res = await fetch(url, { ...init, headers });
  if (!res.ok) {
    let detail = res.statusText;
    try {
      const body = await res.json();
      detail = body.detail ?? JSON.stringify(body);
    } catch {}
    throw new ApiError(res.status, detail);
  }
  if (res.status === 204) return undefined as T;
  return (await res.json()) as T;
}

export const ordersApi = {
  health: () => request<HealthStatus>(`${ORDERS_URL}/health`),
  list: (limit: number = 50, status?: string) => {
    const params = new URLSearchParams();
    params.set("limit", String(limit));
    if (status) params.set("status", status);
    return request<Order[]>(`${ORDERS_URL}/orders?${params.toString()}`);
  },
  get: (id: string) => request<Order>(`${ORDERS_URL}/orders/${id}`),
  create: (data: CreateOrderRequest, idempotencyKey?: string) =>
    request<CreateOrderResponse>(`${ORDERS_URL}/orders`, {
      method: "POST",
      body: JSON.stringify(data),
      idempotencyKey,
    }),
  cancel: (id: string) =>
    request<{ order_id: string; status: string }>(
      `${ORDERS_URL}/orders/${id}/cancel`,
      { method: "PATCH" },
    ),
  promotions: () => request<Promotion[]>(`${ORDERS_URL}/promotions`),
};

export const inventoryApi = {
  health: () => request<HealthStatus>(`${INVENTORY_URL}/health`),
  listProducts: () => request<Product[]>(`${INVENTORY_URL}/products`),
  getProduct: (id: number) =>
    request<Product>(`${INVENTORY_URL}/products/${id}`),
  restock: (productId: number, quantity: number, reason = "RESTOCK") =>
    request<{ product_id: number; name: string; new_stock: number }>(
      `${INVENTORY_URL}/restock`,
      {
        method: "POST",
        body: JSON.stringify({
          product_id: productId,
          quantity,
          reason,
        }),
      },
    ),
  getMovements: (orderId: string) =>
    request<StockMovement[]>(
      `${INVENTORY_URL}/movements/${encodeURIComponent(orderId)}`,
    ),
};

export const billingApi = {
  health: () => request<HealthStatus>(`${BILLING_URL}/health`),
  listInvoices: (limit: number = 50) =>
    request<Invoice[]>(`${BILLING_URL}/invoices?limit=${limit}`),
  getInvoice: (orderId: string) =>
    request<Invoice>(`${BILLING_URL}/invoices/${encodeURIComponent(orderId)}`),
};

export const transportApi = {
  health: () => request<HealthStatus>(`${TRANSPORT_URL}/health`),
  getShipment: (orderId: string) =>
    request<Shipment>(
      `${TRANSPORT_URL}/shipments/${encodeURIComponent(orderId)}`,
    ),
  updateStatus: (orderId: string, status: ShipmentStatus) =>
    request<{ order_id: string; new_status: ShipmentStatus }>(
      `${TRANSPORT_URL}/shipments/${encodeURIComponent(orderId)}/status`,
      {
        method: "PATCH",
        body: JSON.stringify({ status }),
      },
    ),
  listDrivers: () => request<Driver[]>(`${TRANSPORT_URL}/drivers`),
};

export const notificationsApi = {
  health: () => request<HealthStatus>(`${NOTIFICATIONS_URL}/health`),
  list: (limit: number = 50) =>
    request<Notification[]>(
      `${NOTIFICATIONS_URL}/notifications?limit=${limit}`,
    ),
  queueSize: () => request<QueueSize>(`${NOTIFICATIONS_URL}/queue/size`),
};

export type { NotificationType };
