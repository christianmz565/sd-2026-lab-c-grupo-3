import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const latency = new Trend('latency');

const BASE_URL = __ENV.REST_URL || 'http://localhost:8081';

export const options = {
  stages: [
    { duration: '10s', target: 5 },
    { duration: '30s', target: 20 },
    { duration: '10s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<1000'],
    errors: ['rate<0.15'],
  },
};

export default function () {
  const uniqueId = Date.now() + Math.floor(Math.random() * 10000);
  const payload = JSON.stringify({
    title: `Test Book ${uniqueId}`,
    author: 'Load Test Author',
    isbn: `${uniqueId}`,
    description: 'A book created during load testing',
  });

  const params = {
    headers: { 'Content-Type': 'application/json' },
  };

  const res = http.post(`${BASE_URL}/api/books`, payload, params);

  latency.add(res.timings.duration);
  check(res, {
    'status is 201': (r) => r.status === 201,
    'response has book id': (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.id !== undefined;
      } catch (e) {
        return false;
      }
    },
  }) || errorRate.add(1);

  sleep(0.2);
}

export function handleSummary(data) {
  const metrics = data.metrics;
  return {
    '/tmp/opencode/rest_write_results.json': JSON.stringify({
      test: 'REST WRITE (Create Book)',
      total_requests: metrics.http_reqs?.values?.count || 0,
      avg_duration: metrics.http_req_duration?.values?.avg || 0,
      p95_duration: metrics.http_req_duration?.values?.['p(95)'] || 0,
      p99_duration: metrics.http_req_duration?.values?.['p(99)'] || 0,
      max_duration: metrics.http_req_duration?.values?.max || 0,
      rps: metrics.http_reqs?.values?.rate || 0,
      error_rate: metrics.errors?.values?.rate || 0,
      data_received: metrics.data_received?.values?.count || 0,
      data_sent: metrics.data_sent?.values?.count || 0,
    }, null, 2),
  };
}
