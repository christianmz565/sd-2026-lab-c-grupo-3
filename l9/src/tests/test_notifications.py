"""
Integration tests: Notifications flow

Validates that order confirmations and cancellations trigger the correct
notifications through the Redis queue, and that the worker processes them.
"""

import time
import httpx
import pytest

from conftest import (
    ORDERS_URL, NOTIFICATIONS_URL, create_order, wait_for_order_status,
)

PRODUCT_POLLO = 1
PRODUCT_MERLUZA = 3


@pytest.mark.usefixtures("wait_for_services")
class TestNotifications:

    def _find_notification(self, client: httpx.Client, order_id: str,
                           notif_type: str, timeout_s: float = 10.0) -> dict | None:
        """Poll notifications list until we find one matching order_id and type."""
        deadline = time.time() + timeout_s
        while time.time() < deadline:
            r = client.get(f"{NOTIFICATIONS_URL}/notifications", params={"limit": 100})
            if r.status_code == 200:
                for n in r.json():
                    if n.get("order_id") == order_id and n.get("type") == notif_type:
                        return n
            time.sleep(0.5)
        return None

    def test_notification_on_confirm(self, client: httpx.Client):
        """Order confirmed → ORDER_CONFIRMED notification exists."""
        email = "test-notif-confirm@logifresh.pe"
        order = create_order(
            client,
            items=[{"product_id": PRODUCT_POLLO, "quantity": 2, "unit_price": 25.50}],
            email=email,
        )
        order_id = order["order_id"]
        wait_for_order_status(client, order_id, "CONFIRMED", timeout_s=10)

        notif = self._find_notification(client, order_id, "ORDER_CONFIRMED", timeout_s=10)
        assert notif is not None, (
            f"No ORDER_CONFIRMED notification found for order {order_id}"
        )
        assert notif["recipient"] == email
        assert notif["status"] == "SENT"

    def test_notification_on_cancel(self, client: httpx.Client):
        """Cancelled order → ORDER_CANCELLED notification."""
        email = "test-notif-cancel@logifresh.pe"
        order = create_order(
            client,
            items=[{"product_id": PRODUCT_MERLUZA, "quantity": 99999, "unit_price": 15.75}],
            email=email,
        )
        order_id = order["order_id"]
        wait_for_order_status(client, order_id, "CANCELLED", timeout_s=10)

        notif = self._find_notification(client, order_id, "ORDER_CANCELLED", timeout_s=10)
        assert notif is not None, (
            f"No ORDER_CANCELLED notification found for order {order_id}"
        )
        assert notif["recipient"] == email

    def test_notification_status_sent(self, client: httpx.Client):
        """After worker processes → notification status becomes SENT."""
        order = create_order(
            client,
            items=[{"product_id": PRODUCT_POLLO, "quantity": 1, "unit_price": 25.50}],
        )
        order_id = order["order_id"]
        wait_for_order_status(client, order_id, "CONFIRMED", timeout_s=10)

        notif = self._find_notification(client, order_id, "ORDER_CONFIRMED", timeout_s=10)
        assert notif is not None
        assert notif["status"] == "SENT", (
            f"Notification should be SENT after worker, got: {notif['status']}"
        )
        assert notif["sent_at"] is not None, "sent_at should be set"
        assert notif["attempts"] >= 1, "attempts should be >= 1"
