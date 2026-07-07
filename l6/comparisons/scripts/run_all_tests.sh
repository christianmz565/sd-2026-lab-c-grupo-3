#!/bin/bash
# Run all comparison tests between REST and GraphQL

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="/tmp/opencode"
mkdir -p "$RESULTS_DIR"

REST_URL="${REST_URL:-http://localhost:8081}"
GRAPHQL_URL="${GRAPHQL_URL:-http://localhost:5003}"

echo "=== REST vs GraphQL Performance Comparison ==="
echo "REST API:     $REST_URL"
echo "GraphQL API:  $GRAPHQL_URL"
echo ""

# Check if services are running
echo "Checking service availability..."
if ! curl -s "$REST_URL/api/books" > /dev/null 2>&1; then
  echo "ERROR: REST API not available at $REST_URL"
  echo "Start with: cd l6/src && docker compose up -d e1"
  exit 1
fi

if ! curl -s -X POST "$GRAPHQL_URL/graphql" -H "Content-Type: application/json" -d '{"query":"{ books { id } }"}' > /dev/null 2>&1; then
  echo "ERROR: GraphQL API not available at $GRAPHQL_URL"
  echo "Start with: cd l6/src && docker compose up -d e3"
  exit 1
fi

echo "Services are running!"
echo ""

# Measure payload sizes
echo "=== Phase 1: Response Payload Size Analysis ==="
bash "$SCRIPT_DIR/measure_payload_size.sh"
echo ""

# Run performance tests
echo "=== Phase 2: Performance Load Tests ==="
echo ""

echo "--- Test 1: REST GET All Books ---"
REST_URL="$REST_URL" nix run nixpkgs#k6 -- run "$SCRIPT_DIR/rest_get_all.js" 2>&1 | tail -20
echo ""

echo "--- Test 2: GraphQL GET All Books ---"
GRAPHQL_URL="$GRAPHQL_URL" nix run nixpkgs#k6 -- run "$SCRIPT_DIR/graphql_get_all.js" 2>&1 | tail -20
echo ""

echo "--- Test 3: REST GET Single Book ---"
REST_URL="$REST_URL" nix run nixpkgs#k6 -- run "$SCRIPT_DIR/rest_get_one.js" 2>&1 | tail -20
echo ""

echo "--- Test 4: GraphQL GET Single Book ---"
GRAPHQL_URL="$GRAPHQL_URL" nix run nixpkgs#k6 -- run "$SCRIPT_DIR/graphql_get_one.js" 2>&1 | tail -20
echo ""

echo "--- Test 5: GraphQL Selective Fields (title+author only) ---"
GRAPHQL_URL="$GRAPHQL_URL" nix run nixpkgs#k6 -- run "$SCRIPT_DIR/graphql_selective_fields.js" 2>&1 | tail -20
echo ""

echo "--- Test 6: REST WRITE (Create Book) ---"
REST_URL="$REST_URL" nix run nixpkgs#k6 -- run "$SCRIPT_DIR/rest_write.js" 2>&1 | tail -20
echo ""

echo "--- Test 7: GraphQL WRITE (Create Book) ---"
GRAPHQL_URL="$GRAPHQL_URL" nix run nixpkgs#k6 -- run "$SCRIPT_DIR/graphql_write.js" 2>&1 | tail -20
echo ""

echo "=== All Tests Complete ==="
echo "Results saved to: $RESULTS_DIR/"
ls -la "$RESULTS_DIR"/*.json 2>/dev/null || echo "No JSON results found"
