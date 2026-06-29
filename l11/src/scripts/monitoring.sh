#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONITORING_DIR="$SCRIPT_DIR/../monitoring"

ACTION="${1:-up}"

cd "$MONITORING_DIR"

case "$ACTION" in
  up)
    echo "▶ Levantando stack de monitoreo..."
    docker compose up -d
    echo ""
    echo "=========================================="
    echo "  Servicios de Monitoreo:"
    echo "=========================================="
    echo "  Grafana:     http://localhost:3000"
    echo "  Prometheus: http://localhost:9090"
    echo "  Alertmanager: http://localhost:9093"
    echo "=========================================="
    ;;
  down)
    echo "▶ Deteniendo stack de monitoreo..."
    docker compose down
    ;;
  logs)
    docker compose logs -f
    ;;
  ps)
    docker compose ps
    ;;
  restart)
    echo "▶ Reiniciando stack de monitoreo..."
    docker compose restart
    ;;
  *)
    echo "Uso: $0 {up|down|logs|ps|restart}"
    echo ""
    echo "  up:    Levanta el stack de monitoreo"
    echo "  down:  Detiene el stack de monitoreo"
    echo "  logs:  Ver logs en tiempo real"
    echo "  ps:    Ver estado de los contenedores"
    echo "  restart: Reiniciar los contenedores"
    exit 1
    ;;
esac

# 1. Generar tráfico normal:
# for i in {1..20}; do curl -s http://localhost/ > /dev/null; done
# 2. Generar errores 4xx (recurso no encontrado):
# curl -s http://localhost/api/users/99999  # 404
# 3. Generar errores 5xx:
# curl -s http://localhost/api/500  # 500 Internal Server Error

# 4. Ver que aparecen en métricas
# curl -s http://localhost:9090/api/v1/query?query='sum by(status)(http_requests_total)'
