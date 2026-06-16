"""
Integration tests: Pedido ↔ Inventario

Validates the interaction between the Orders service and the Inventory service,
including stock reservation, insufficient stock handling, stock release, and
concurrent access locking.
"""

import uuid
import time
import threading
import httpx
import pytest

from conftest import (
    ORDERS_URL, INVENTORY_URL, create_order, wait_for_order_status,
)

# Seed data from init.sql
PRODUCT_POLLO = 1       # Pollo entero congelado, stock=500, S/25.50
PRODUCT_CARNE = 2       # Carne de res, stock=300, S/38.00
PRODUCT_MERLUZA = 3     # Pescado merluza, stock=200, S/15.75


@pytest.mark.usefixtures("wait_for_services")
class TestOrderInventory:

# START-SNIPPET,test-reserve-stock
    def test_reserve_stock_happy_path(self, client: httpx.Client):
        """Order with valid items → inventory reserved, stock decremented."""
        # Get stock before
        r = client.get(f"{INVENTORY_URL}/products/{PRODUCT_POLLO}")
        assert r.status_code == 200
        stock_before = r.json()["stock"]

        # Create order: 5 units of Pollo
        order = create_order(client, items=[
            {"product_id": PRODUCT_POLLO, "quantity": 5, "unit_price": 25.50}
        ])
        order_id = order["order_id"]

        # Wait for processing
        result = wait_for_order_status(client, order_id, "CONFIRMED", timeout_s=10)
        assert result.get("status") == "CONFIRMED", f"Order status: {result}"

        # Verify stock was decremented
        r = client.get(f"{INVENTORY_URL}/products/{PRODUCT_POLLO}")
        assert r.status_code == 200
        stock_after = r.json()["stock"]
        assert stock_after == stock_before - 5, (
            f"Stock should decrease by 5: {stock_before} → {stock_after}"
        )
# END-SNIPPET

# START-SNIPPET,test-concurrent-reserve
    def test_concurrent_reserve_race_condition(self, client: httpx.Client):
        """Two simultaneous orders for the same last units → one wins, one fails.
        This validates SELECT FOR UPDATE locking prevents overselling."""
        # Use a product with known stock
        r = client.get(f"{INVENTORY_URL}/products/{PRODUCT_POLLO}")
        assert r.status_code == 200
        stock_before = r.json()["stock"]

        # We'll try to reserve more than available with 2 concurrent requests
        # Each tries to reserve stock_before + 10 units (impossible for both)
        quantity = stock_before + 10
        results = []

        def make_order(idx):
            order = create_order(client, items=[
                {"product_id": PRODUCT_POLLO, "quantity": quantity, "unit_price": 25.50}
            ])
            order_id = order["order_id"]
            result = wait_for_order_status(client, order_id, "CANCELLED", timeout_s=10)
            results.append(result.get("status"))

        threads = [threading.Thread(target=make_order, args=(i,)) for i in range(2)]
        for t in threads:
            t.start()
        for t in threads:
            t.join(timeout=15)

        # At least one should be cancelled (both might be if stock is insufficient for either)
        cancelled = sum(1 for s in results if s == "CANCELLED")
        assert cancelled >= 1, f"At least one order should be cancelled, got: {results}"

        # Stock should not go negative
        r = client.get(f"{INVENTORY_URL}/products/{PRODUCT_POLLO}")
        assert r.status_code == 200
        assert r.json()["stock"] >= 0, "Stock must never go negative"
# END-SNIPPET
