#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_DIR="$(dirname "$SCRIPT_DIR")"

NETWORK=$(docker compose -f "$COMPOSE_DIR/docker-compose.yml" ps orders --format json 2>/dev/null | jq -r '.[0].Networks[0]' 2>/dev/null | head -1)
NETWORK=${NETWORK:-src_default}

USE_INFLUX=false
if docker compose -f "$COMPOSE_DIR/docker-compose.yml" ps influxdb 2>/dev/null | grep -q "Up"; then
    USE_INFLUX=true
    echo "✓ InfluxDB detectado - métricas se enviarán a Grafana"
fi

echo "=========================================="
echo "  k6 Load Test - LogiFresh Microservices"
echo "=========================================="
echo "  URL base: http://orders:8001"
echo "  Red Docker: ${NETWORK}"
echo "  Escenario: 100 VUs, 5 minutos"
echo "=========================================="
echo ""

K6_CMD="docker run --rm \
    --network '${NETWORK}' \
    -v '$SCRIPT_DIR/load-test.js:/scripts/load-test.js' \
    grafana/k6 run /scripts/load-test.js"

if [ "$USE_INFLUX" = true ]; then
    K6_CMD="$K6_CMD --out influxdb=http://admin:adminpass@influxdb:8086/k6"
fi

eval $K6_CMD
