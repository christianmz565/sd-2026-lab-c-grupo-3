"""
Integration tests: Pedido ↔ Facturación

Validates the interaction between the Orders service and the Billing service,
including invoice generation, idempotency, and discount calculations.
"""

import httpx
import pytest

from conftest import (
    ORDERS_URL, BILLING_URL, create_order, wait_for_order_status,
)

# Seed data
PRODUCT_POLLO = 1   # S/25.50
PRODUCT_CARNE = 2   # S/38.00
PROMO_VERANO10 = "VERANO10"  # 10% discount


@pytest.mark.usefixtures("wait_for_services")
class TestOrderBilling:

# START-SNIPPET,test-invoice-created
    def test_invoice_created_on_confirm(self, client: httpx.Client):
        """Order confirmed → invoice generated with correct IGV (18%)."""
        order = create_order(client, items=[
            {"product_id": PRODUCT_POLLO, "quantity": 10, "unit_price": 25.50}
        ])
        order_id = order["order_id"]

        result = wait_for_order_status(client, order_id, "CONFIRMED", timeout_s=10)
        assert result.get("status") == "CONFIRMED"

        # Check invoice exists
        r = client.get(f"{BILLING_URL}/invoices/{order_id}")
        assert r.status_code == 200, f"Invoice not found for order {order_id}"
        invoice = r.json()

        # Verify amounts: subtotal = 10 * 25.50 = 255.00
        expected_subtotal = 255.00
        expected_tax = round(expected_subtotal * 0.18, 2)  # IGV 18%
        expected_total = round(expected_subtotal + expected_tax, 2)

        assert invoice["subtotal"] == expected_subtotal, (
            f"Subtotal: expected {expected_subtotal}, got {invoice['subtotal']}"
        )
        assert invoice["tax_amount"] == expected_tax, (
            f"Tax: expected {expected_tax}, got {invoice['tax_amount']}"
        )
        assert invoice["total"] == expected_total, (
            f"Total: expected {expected_total}, got {invoice['total']}"
        )
        assert invoice["status"] == "ISSUED"
        assert invoice["invoice_number"].startswith("FAC-")
# END-SNIPPET

    def test_no_duplicate_invoice(self, client: httpx.Client):
        """Same order_id sent twice → only one invoice exists (idempotency)."""
        order = create_order(client, items=[
            {"product_id": PRODUCT_POLLO, "quantity": 2, "unit_price": 25.50}
        ])
        order_id = order["order_id"]
        wait_for_order_status(client, order_id, "CONFIRMED", timeout_s=10)

        # Request invoice creation again with same order_id (simulating retry)
        payload = {
            "order_id": order_id,
            "client_id": "test-idem-client",
            "subtotal": 51.00,
            "discount_pct": 0,
        }
        r = client.post(f"{BILLING_URL}/invoices", json=payload)
        assert r.status_code in (200, 201)
        body = r.json()
        assert body.get("idempotent") is True, "Should return idempotent=True on duplicate"

        # Verify only one invoice exists for this order
        r = client.get(f"{BILLING_URL}/invoices/{order_id}")
        assert r.status_code == 200

    def test_invoice_with_promo(self, client: httpx.Client):
        """Order with VERANO10 promo → invoice shows 10% discount."""
        order = create_order(
            client,
            items=[{"product_id": PRODUCT_CARNE, "quantity": 10, "unit_price": 38.00}],
            promotion_code=PROMO_VERANO10,
        )
        order_id = order["order_id"]

        # Verify order has discount
        assert order.get("discount_pct") == 10.0, (
            f"Order discount_pct should be 10, got {order.get('discount_pct')}"
        )

        result = wait_for_order_status(client, order_id, "CONFIRMED", timeout_s=10)
        assert result.get("status") == "CONFIRMED"

        # Check invoice
        r = client.get(f"{BILLING_URL}/invoices/{order_id}")
        assert r.status_code == 200
        invoice = r.json()

        # subtotal = 10 * 38.00 = 380.00, discount = 38.00 (10%)
        expected_subtotal = 380.00
        expected_discount = 38.00
        expected_tax = round((expected_subtotal - expected_discount) * 0.18, 2)
        expected_total = round(expected_subtotal - expected_discount + expected_tax, 2)

        assert invoice["discount_amount"] == expected_discount, (
            f"Discount: expected {expected_discount}, got {invoice['discount_amount']}"
        )
        assert invoice["tax_amount"] == expected_tax
        assert invoice["total"] == expected_total

    def test_invoice_without_promo(self, client: httpx.Client):
        """Order without promo → invoice has 0 discount."""
        order = create_order(client, items=[
            {"product_id": PRODUCT_POLLO, "quantity": 3, "unit_price": 25.50}
        ])
        order_id = order["order_id"]

        result = wait_for_order_status(client, order_id, "CONFIRMED", timeout_s=10)
        assert result.get("status") == "CONFIRMED"

        r = client.get(f"{BILLING_URL}/invoices/{order_id}")
        assert r.status_code == 200
        invoice = r.json()

        assert invoice["discount_amount"] == 0.0, (
            f"No discount expected, got {invoice['discount_amount']}"
        )
        # subtotal = 3 * 25.50 = 76.50, tax = 76.50 * 0.18 = 13.77
        assert invoice["subtotal"] == 76.50
        assert invoice["tax_amount"] == 13.77
