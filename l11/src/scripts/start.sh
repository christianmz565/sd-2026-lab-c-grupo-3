#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

ACTION="${1:-up}"

if [ ! -f "certs/localhost.crt" ] || [ ! -f "certs/localhost.key" ]; then
  echo "▶ Certificados no encontrados. Generando..."
  "$SCRIPT_DIR/generate-certs.sh"
fi

COMPOSE_FILE="compose.yaml"

case "$ACTION" in
  up)
    echo "▶ Levantando stack (Traefik + app)..."
    docker compose -f "$COMPOSE_FILE" up -d --build
    echo ""
    echo "⏳ Esperando a que la app responda..."
    for _ in {1..30}; do
      if curl -fk -s https://localhost/health >/dev/null 2>&1; then
        echo "✔ Stack listo"
        break
      fi
      sleep 1
    done
    echo ""
    echo "=========================================="
    echo "  Servicios disponibles:"
    echo "=========================================="
    echo "  App:        https://localhost"
    echo "  Dashboard:  https://traefik.localhost"
    echo "  Redir HTTP: http://localhost  -> https"
    echo "=========================================="
    ;;
  down)
    echo "▶ Deteniendo stack..."
    docker compose -f "$COMPOSE_FILE" down
    ;;
  logs)
    docker compose -f "$COMPOSE_FILE" logs -f
    ;;
  rebuild)
    echo "▶ Reconstruyendo imágenes..."
    docker compose -f "$COMPOSE_FILE" build --no-cache
    ;;
  *)
    echo "Uso: $0 {up|down|logs|rebuild}"
    exit 1
    ;;
esac
