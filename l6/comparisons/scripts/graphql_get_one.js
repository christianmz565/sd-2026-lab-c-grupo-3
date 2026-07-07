import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const latency = new Trend('latency');

const BASE_URL = __ENV.GRAPHQL_URL || 'http://localhost:5003';

const SINGLE_BOOK_QUERY = (id) => JSON.stringify({
  query: `{
    book(id: "${id}") {
      id
      title
      author
      isbn
      description
      imageUrl
    }
  }`,
});

export const options = {
  stages: [
    { duration: '10s', target: 10 },
    { duration: '30s', target: 50 },
    { duration: '10s', target: 100 },
    { duration: '30s', target: 50 },
    { duration: '10s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    errors: ['rate<0.1'],
  },
};

export default function () {
  const id = Math.floor(Math.random() * 15) + 1;
  const params = {
    headers: { 'Content-Type': 'application/json' },
  };

  const res = http.post(`${BASE_URL}/graphql`, SINGLE_BOOK_QUERY(id), params);

  latency.add(res.timings.duration);
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response has book fields': (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.data && body.data.book && body.data.book.title;
      } catch (e) {
        return false;
      }
    },
  }) || errorRate.add(1);

  sleep(0.1);
}

export function handleSummary(data) {
  const metrics = data.metrics;
  return {
    '/tmp/opencode/graphql_get_one_results.json': JSON.stringify({
      test: 'GraphQL GET Single Book',
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
