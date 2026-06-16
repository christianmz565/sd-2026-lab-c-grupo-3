#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "  LogiFresh - Iniciando stack completo"
echo "=========================================="
echo ""

docker compose up -d

echo "⏳ Esperando a que los servicios estén healthy (~30s)..."
sleep 30

echo ""
echo "=========================================="
echo "  Servicios disponibles:"
echo "=========================================="
echo "  Orders:        http://localhost:8001/docs"
echo "  Inventory:      http://localhost:8002/docs"
echo "  Billing:        http://localhost:8003/docs"
echo "  Transport:      http://localhost:8004/docs"
echo "  Notifications:  http://localhost:8005/docs"
echo ""
echo "  InfluxDB:       http://localhost:8086"
echo "  Grafana:        http://localhost:3000 (admin/admin)"
echo "=========================================="
echo ""
echo "Para ejecutar k6:"
echo "  ./run-load-test.sh"
echo ""
