#!/bin/bash
# Measure response payload sizes for REST vs GraphQL

echo "=== Response Payload Size Comparison ==="
echo ""

# REST: Get all books (returns all fields)
echo "REST: GET /api/books (all fields)"
REST_ALL=$(curl -s http://localhost:8081/api/books)
echo "  Response size: $(echo "$REST_ALL" | wc -c) bytes"
echo "  Books count: $(echo "$REST_ALL" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo 'N/A')"
echo ""

# GraphQL: Get all books (all fields)
echo "GraphQL: POST /graphql (all fields)"
GRAPHQL_ALL=$(curl -s -X POST http://localhost:5003/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ books { id title author isbn description imageUrl } }"}')
echo "  Response size: $(echo "$GRAPHQL_ALL" | wc -c) bytes"
echo ""

# GraphQL: Get all books (selective fields - title + author only)
echo "GraphQL: POST /graphql (selective fields: title, author only)"
GRAPHQL_SELECTIVE=$(curl -s -X POST http://localhost:5003/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ books { id title author } }"}')
echo "  Response size: $(echo "$GRAPHQL_SELECTIVE" | wc -c) bytes"
echo ""

# GraphQL: Single book query
echo "GraphQL: POST /graphql (single book, all fields)"
GRAPHQL_SINGLE=$(curl -s -X POST http://localhost:5003/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ book(id: \"1\") { id title author isbn description imageUrl } }"}')
echo "  Response size: $(echo "$GRAPHQL_SINGLE" | wc -c) bytes"
echo ""

# REST: Single book
echo "REST: GET /api/books/1 (all fields)"
REST_SINGLE=$(curl -s http://localhost:8081/api/books/1)
echo "  Response size: $(echo "$REST_SINGLE" | wc -c) bytes"
echo ""

echo "=== Summary ==="
REST_ALL_SIZE=$(echo "$REST_ALL" | wc -c)
GRAPHQL_ALL_SIZE=$(echo "$GRAPHQL_ALL" | wc -c)
GRAPHQL_SELECTIVE_SIZE=$(echo "$GRAPHQL_SELECTIVE" | wc -c)
echo "REST (all fields):             $REST_ALL_SIZE bytes"
echo "GraphQL (all fields):          $GRAPHQL_ALL_SIZE bytes"
echo "GraphQL (selective fields):    $GRAPHQL_SELECTIVE_SIZE bytes"
echo ""
echo "Overhead saved by selective fields: $(( REST_ALL_SIZE - GRAPHQL_SELECTIVE_SIZE )) bytes ($(( (REST_ALL_SIZE - GRAPHQL_SELECTIVE_SIZE) * 100 / REST_ALL_SIZE ))% reduction)"
