export type OrderStatus =
  | "PENDING"
  | "PROCESSING"
  | "CONFIRMED"
  | "CANCELLED"
  | "ERROR";

export type ShipmentStatus = "ASSIGNED" | "IN_TRANSIT" | "DELIVERED";

export type NotificationStatus = "PENDING" | "SENT" | "FAILED";

export type NotificationType =
  | "ORDER_CONFIRMED"
  | "ORDER_SHIPPED"
  | "ORDER_CANCELLED";

export interface OrderItem {
  product_id: number;
  quantity: number;
  unit_price: number;
}

export interface Order {
  id: string;
  client_id: string;
  status: OrderStatus;
  total_amount: number | null;
  discount_pct: number;
  promotion_code: string | null;
  items?: OrderItem[];
  created_at?: string;
  updated_at?: string;
}

export interface CreateOrderRequest {
  client_id: string;
  client_email: string;
  delivery_address: string;
  promotion_code?: string | null;
  items: OrderItem[];
}

export interface CreateOrderResponse {
  order_id: string;
  status: OrderStatus;
  subtotal: number;
  discount_pct: number;
  total: number;
  message: string;
  response_time_ms?: number;
  idempotent?: boolean;
}

export interface Promotion {
  code: string;
  discount_pct: number;
  valid_from: string;
  valid_until: string | null;
}

export interface Product {
  id: number;
  name: string;
  sku: string;
  stock: number;
  unit_price: number;
}

export interface StockMovement {
  id: number;
  product_id: number;
  product_name: string;
  delta: number;
  reason: string;
  created_at: string;
}

export interface Invoice {
  id: number;
  invoice_number: string;
  order_id: string;
  client_id: string;
  subtotal: number;
  discount_amount: number;
  tax_amount: number;
  total: number;
  status: string;
  issued_at: string;
}

export interface Driver {
  id: number;
  name: string;
  vehicle: string;
  available: boolean;
}

export interface Shipment {
  id: number;
  order_id: string;
  driver_id: number | null;
  status: ShipmentStatus;
  address: string;
  assigned_at: string;
  delivered_at: string | null;
  driver_name?: string;
  vehicle?: string;
}

export interface Notification {
  id: number;
  order_id: string | null;
  recipient: string;
  type: string;
  status: NotificationStatus;
  attempts: number;
  sent_at: string | null;
  created_at: string;
}

export interface QueueSize {
  queue: string;
  pending: number;
}

export interface HealthStatus {
  status: string;
  service: string;
  redis?: boolean;
}
