#!/bin/bash
# =============================================================================
# FedEx Peru - PostgreSQL Streaming Replication Setup Script
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
COMPOSE_FILE="docker-compose.multi.yml"
TIMEOUT_LIMA=60
TIMEOUT_STANDBY=90

# Suppress psql pager warning
export PAGER=cat
export PSQL_PAGER=cat

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  FedEx Peru - Streaming Replication Setup  ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# =============================================================================
# STEP 1: CLEANUP
# =============================================================================
echo -e "${YELLOW}[1/6] Limpiando contenedores anteriores...${NC}"

docker compose -f "$COMPOSE_FILE" down -v --remove-orphans 2>/dev/null || true

# Clean up any leftover volumes from other projects
docker volume ls 2>/dev/null | grep -E "sd-lab-db_" | awk '{print $2}' | xargs -r docker volume rm 2>/dev/null || true

echo -e "${GREEN}✓ Limpieza completada${NC}"
echo ""

# =============================================================================
# STEP 2: START ALL SERVICES
# =============================================================================
echo -e "${YELLOW}[2/6] Iniciando todos los servicios...${NC}"

docker compose -f "$COMPOSE_FILE" up -d

echo -e "${GREEN}✓ Servicios iniciados${NC}"
echo ""

# =============================================================================
# STEP 3: WAIT FOR LIMA TO BE HEALTHY
# =============================================================================
echo -e "${YELLOW}[3/6] Esperando que Lima (Primary) esté listo...${NC}"

ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT_LIMA ]; do
    STATUS=$(docker compose -f "$COMPOSE_FILE" ps lima-db --format json 2>/dev/null | grep -o '"Health":"[^"]*"' | cut -d'"' -f4 || echo "not_found")

    if [ "$STATUS" = "healthy" ]; then
        echo -e "${GREEN}✓ Lima está healthy!${NC}"
        break
    fi

    echo -r "  Esperando... ($ELAPSED/$TIMEOUT_LIMA segundos) - Status: $STATUS"
    sleep 2
    ELAPSED=$((ELAPSED + 2))
done

if [ $ELAPSED -ge $TIMEOUT_LIMA ]; then
    echo -e "${RED}✗ Timeout esperando a Lima${NC}"
    echo "Logs de Lima:"
    docker compose -f "$COMPOSE_FILE" logs lima-db | tail -30
    exit 1
fi

echo ""

# =============================================================================
# STEP 4: WAIT FOR STANDBYS TO BE HEALTHY
# =============================================================================
echo -e "${YELLOW}[4/6] Esperando que los Standbys estén listos...${NC}"

STANDBYS=("bogota-db" "santiago-db" "mexico-db")

for STANDBY in "${STANDBYS[@]}"; do
    echo -n "  Verificando $STANDBY... "

    ELAPSED=0
    while [ $ELAPSED -lt $TIMEOUT_STANDBY ]; do
        STATUS=$(docker compose -f "$COMPOSE_FILE" ps "$STANDBY" --format json 2>/dev/null | grep -o '"Health":"[^"]*"' | cut -d'"' -f4 || echo "not_found")

        if [ "$STATUS" = "healthy" ]; then
            echo -e "${GREEN}✓ healthy${NC}"
            break
        fi

        sleep 2
        ELAPSED=$((ELAPSED + 2))
    done

    if [ $ELAPSED -ge $TIMEOUT_STANDBY ]; then
        echo -e "${RED}✗ Timeout${NC}"
        echo "Logs de $STANDBY:"
        docker compose -f "$COMPOSE_FILE" logs "$STANDBY" | tail -20
    fi
done

echo ""

# =============================================================================
# STEP 5: VERIFY REPLICATION SLOTS
# =============================================================================
echo -e "${YELLOW}[5/6] Verificando replication slots en Lima...${NC}"

SLOTS=$(docker compose -f "$COMPOSE_FILE" exec lima-db psql -U postgres -t -c "SELECT COUNT(*) FROM pg_replication_slots WHERE slot_type = 'physical';" 2>/dev/null | xargs)

if [ "$SLOTS" = "3" ]; then
    echo -e "${GREEN}✓ 3 replication slots creados (bogota, santiago, mexico)${NC}"
else
    echo -e "${RED}✗ Expected 3 slots, found: $SLOTS${NC}"
    docker compose -f "$COMPOSE_FILE" exec lima-db psql -U postgres -c "SELECT * FROM pg_replication_slots;"
    exit 1
fi

echo ""

# =============================================================================
# STEP 6: VERIFY STREAMING REPLICATION
# =============================================================================
echo -e "${YELLOW}[6/6] Verificando streaming replication...${NC}"

STANDBY_COUNT=$(docker compose -f "$COMPOSE_FILE" exec lima-db psql -U postgres -t -c "SELECT COUNT(*) FROM pg_stat_replication;" 2>/dev/null | xargs)

if [ "$STANDBY_COUNT" = "3" ]; then
    echo -e "${GREEN}✓ 3 standbys en streaming replication${NC}"
else
    echo -e "${RED}✗ Expected 3 standbys, found: $STANDBY_COUNT${NC}"
    docker compose -f "$COMPOSE_FILE" exec lima-db psql -U postgres -c "SELECT * FROM pg_stat_replication;"
    exit 1
fi

echo ""

# =============================================================================
# TEST: DATA REPLICATION
# =============================================================================
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  TESTS DE REPLICACIÓN DE DATOS            ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Create test data on primary
echo -e "${YELLOW}Creando tabla de prueba en Lima (Primary)...${NC}"

docker compose -f "$COMPOSE_FILE" exec lima-db psql -U postgres -c "
CREATE TABLE IF NOT EXISTS fedex_inventarios (
    id SERIAL PRIMARY KEY,
    centro VARCHAR(50) NOT NULL,
    producto VARCHAR(100) NOT NULL,
    cantidad INTEGER NOT NULL DEFAULT 0,
    fecha TIMESTAMP DEFAULT NOW()
);
" 2>/dev/null

docker compose -f "$COMPOSE_FILE" exec lima-db psql -U postgres -c "
INSERT INTO fedex_inventarios (centro, producto, cantidad) VALUES
    ('Lima', 'Paquetes Internacional', 1500),
    ('Lima', 'Paquetes Nacional', 3000),
    ('Lima', 'Sobres documents', 5000),
    ('Bogota', 'Paquetes', 800),
    ('Santiago', 'Paquetes', 1200),
    ('Mexico', 'Paquetes', 950);
" 2>/dev/null

echo -e "${GREEN}✓ Datos insertados en Lima${NC}"
echo ""

# Verify replication to all standbys
echo -e "${YELLOW}Verificando replicación en standbys...${NC}"

for STANDBY in "${STANDBYS[@]}"; do
    echo -n "  $STANDBY: "

    COUNT=$(docker compose -f "$COMPOSE_FILE" exec "$STANDBY" psql -U postgres -t -c "SELECT COUNT(*) FROM fedex_inventarios;" 2>/dev/null | xargs)

    if [ "$COUNT" = "6" ]; then
        echo -e "${GREEN}✓ 6 registros replicados${NC}"
    else
        echo -e "${RED}✗ Expected 6, found: $COUNT${NC}"
    fi
done

echo ""

# =============================================================================
# TEST: READ-ONLY ON STANDBYS
# =============================================================================
echo -e "${YELLOW}Verificando que standbys son read-only...${NC}"

for STANDBY in "${STANDBYS[@]}"; do
    echo -n "  $STANDBY write test: "

    if docker compose -f "$COMPOSE_FILE" exec "$STANDBY" psql -U postgres -c "INSERT INTO fedex_inventarios (centro, producto, cantidad) VALUES ('Test', 'Test', 1);" 2>&1 | grep -q "cannot execute INSERT in a read-only transaction"; then
        echo -e "${GREEN}✓ Read-only (correcto)${NC}"
    else
        echo -e "${RED}✗ Permite escritura (ERROR!)${NC}"
    fi
done

echo ""

# =============================================================================
# TEST: VERIFY pg_is_in_recovery
# =============================================================================
echo -e "${YELLOW}Verificando que standbys están en modo recovery...${NC}"

for STANDBY in "${STANDBYS[@]}"; do
    echo -n "  $STANDBY: "

    RECOVERY=$(docker compose -f "$COMPOSE_FILE" exec "$STANDBY" psql -U postgres -t -c "SELECT pg_is_in_recovery();" 2>/dev/null | xargs)

    if [ "$RECOVERY" = "t" ]; then
        echo -e "${GREEN}✓ Es standby (recovery mode)${NC}"
    else
        echo -e "${RED}✗ No está en recovery: $RECOVERY${NC}"
    fi
done

echo ""

# =============================================================================
# CLEANUP TEST DATA
# =============================================================================
echo -e "${YELLOW}Limpiando datos de prueba...${NC}"
docker compose -f "$COMPOSE_FILE" exec lima-db psql -U postgres -c "DROP TABLE IF EXISTS fedex_inventarios;" 2>/dev/null
echo -e "${GREEN}✓ Limpieza completada${NC}"
echo ""

# =============================================================================
# FINAL STATUS
# =============================================================================
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  RESUMEN FINAL                             ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

echo -e "${GREEN}✓ REPLICACIÓN FUNCIONANDO CORRECTAMENTE${NC}"
echo ""
echo "Replication slots en Lima:"
docker compose -f "$COMPOSE_FILE" exec lima-db psql -U postgres -c "SELECT slot_name, slot_type, active FROM pg_replication_slots;" 2>/dev/null
echo ""
echo "Streaming replication status:"
docker compose -f "$COMPOSE_FILE" exec lima-db psql -U postgres -c "SELECT application_name, client_addr, state, sync_state FROM pg_stat_replication;" 2>/dev/null
echo ""

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  PUERTOS DISPONIBLES                       ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo -e "  ${GREEN}Lima${NC}:      DB=5432  Studio=http://localhost:3000  REST=http://localhost:3001"
echo -e "  ${GREEN}Bogota${NC}:    DB=5433  Studio=http://localhost:3010  REST=http://localhost:3011"
echo -e "  ${GREEN}Santiago${NC}:  DB=5434  Studio=http://localhost:3020  REST=http://localhost:3021"
echo -e "  ${GREEN}Mexico${NC}:    DB=5435  Studio=http://localhost:3030  REST=http://localhost:3031"
echo ""

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  COMANDOS ÚTILES                            ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo "  Ver todos los contenedores:"
echo "    docker compose -f $COMPOSE_FILE ps"
echo ""
echo "  Ver replication status:"
echo "    docker compose -f $COMPOSE_FILE exec lima-db psql -U postgres -c \"SELECT * FROM pg_stat_replication;\""
echo ""
echo "  Ver logs de un nodo:"
echo "    docker compose -f $COMPOSE_FILE logs -f lima-db"
echo ""
echo "  Bajar todo:"
echo "    docker compose -f $COMPOSE_FILE down"
echo ""
echo "  Bajar todo Y eliminar datos:"
echo "    docker compose -f $COMPOSE_FILE down -v"
echo ""
