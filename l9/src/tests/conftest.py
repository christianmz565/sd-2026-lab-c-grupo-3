import os
import uuid
import time
import httpx
import pytest

ORDERS_URL = os.getenv("ORDERS_URL", "http://localhost:8001")
INVENTORY_URL = os.getenv("INVENTORY_URL", "http://localhost:8002")
BILLING_URL = os.getenv("BILLING_URL", "http://localhost:8003")
TRANSPORT_URL = os.getenv("TRANSPORT_URL", "http://localhost:8004")
NOTIFICATIONS_URL = os.getenv("NOTIFICATIONS_URL", "http://localhost:8005")
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://logifresh:logifresh_pass@postgres/logifresh")

TIMEOUT = 15.0


@pytest.fixture(scope="session")
def client():
    with httpx.Client(timeout=TIMEOUT) as c:
        yield c


@pytest.fixture(scope="session")
def wait_for_services():
    """Ensure all services are healthy before running tests."""
    urls = [
        f"{ORDERS_URL}/health",
        f"{INVENTORY_URL}/health",
        f"{BILLING_URL}/health",
        f"{TRANSPORT_URL}/health",
        f"{NOTIFICATIONS_URL}/health",
    ]
    for url in urls:
        for attempt in range(30):
            try:
                r = httpx.get(url, timeout=5)
                if r.status_code == 200:
                    break
            except httpx.ConnectError:
                pass
            time.sleep(1)
        else:
            pytest.fail(f"Service not ready: {url}")


def create_order(client: httpx.Client, *, items: list[dict], promotion_code: str = None,
                 client_id: str = None, email: str = None) -> dict:
    """Helper to create an order and return the JSON response."""
    order_id = str(uuid.uuid4())[:8]
    payload = {
        "client_id": client_id or f"test-{order_id}",
        "client_email": email or f"test-{order_id}@logifresh.pe",
        "delivery_address": "Av. Test 123, Arequipa",
        "items": items,
    }
    if promotion_code:
        payload["promotion_code"] = promotion_code

    r = client.post(f"{ORDERS_URL}/orders", json=payload,
                    headers={"X-Idempotency-Key": f"test-{uuid.uuid4()}"})
    assert r.status_code == 202, f"Failed to create order: {r.text}"
    return r.json()


def wait_for_order_status(client: httpx.Client, order_id: str,
                          expected: str, timeout_s: float = 10.0) -> dict:
    """Poll until order reaches the expected status or timeout."""
    deadline = time.time() + timeout_s
    while time.time() < deadline:
        r = client.get(f"{ORDERS_URL}/orders/{order_id}")
        if r.status_code == 200:
            data = r.json()
            if data.get("status") == expected:
                return data
        time.sleep(0.3)
    # Return whatever we have for assertion failure message
    r = client.get(f"{ORDERS_URL}/orders/{order_id}")
    return r.json() if r.status_code == 200 else {}


def reset_drivers():
    """Reset all drivers to available and complete pending shipments.
    Uses direct DB access (available when running inside the orders container)."""
    try:
        from sqlalchemy import create_engine, text
        engine = create_engine(DATABASE_URL)
        with engine.begin() as conn:
            conn.execute(text(
                "UPDATE transport.shipments SET status = 'DELIVERED', delivered_at = NOW() "
                "WHERE status != 'DELIVERED'"
            ))
            conn.execute(text("UPDATE transport.drivers SET is_available = TRUE"))
    except Exception:
        pass  # If DB is not reachable, tests will handle via skip
