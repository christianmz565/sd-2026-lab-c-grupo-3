// START-SNIPPET,load-test-config
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const responseTime = new Trend('response_time');

export const options = {
  scenarios: {
    constant_load: {
      executor: 'constant-vus',
      vus: 100,
      duration: '5m',
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<2000'],
    errors: ['rate<0.1'],
  },
};
// END-SNIPPET

const BASE_URL = __ENV.BASE_URL || 'http://orders:8001';

// START-SNIPPET,load-test-payload
const payload = JSON.stringify({
  client_id: 'cliente-load-test',
  client_email: 'loadtest@ejemplo.com',
  delivery_address: 'Av. Test 123, Lima',
  promotion_code: 'VERANO10',
  items: [
    { product_id: 1, quantity: 2, unit_price: 25.50 },
    { product_id: 3, quantity: 1, unit_price: 15.75 },
  ],
});

const params = {
  headers: {
    'Content-Type': 'application/json',
    'X-Idempotency-Key': `load-test-${Date.now()}-${Math.random()}`,
  },
};
// END-SNIPPET

// START-SNIPPET,load-test-execution
export default function () {
  const start = Date.now();
  const res = http.post(`${BASE_URL}/orders`, payload, params);
  const duration = Date.now() - start;

  responseTime.add(duration);

  const success = check(res, {
    'status is 202 or 200': (r) => r.status === 202 || r.status === 200,
    'response has body': (r) => r.body && r.body.length > 0,
  });

  errorRate.add(!success);

  sleep(Math.random() * 2 + 0.5);
}
// END-SNIPPET