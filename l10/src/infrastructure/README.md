# FedEx Peru - PostgreSQL Streaming Replication

## ARQUITECTURA

```
┌───────────────────────────────────────────────────────────────────┐
│                    inner-network (Docker)                         │
│                                                                   │
│   ┌──────────────┐                                                │
│   │  LIMA-DB     │  Puerto: 5432 (PRIMARY)                        │
│   │  (master)    │  - Writes & Reads                              │
│   │              │  - Replication slots: bogota, santiago, mexico │
│   └──────┬───────┘                                                │
│          │ Streaming Replication                                  │
│          │                                                        │
│   ┌──────┴───────┐ ┌──────────────┐ ┌──────────────┐              │
│   │  BOGOTA-DB   │ │  SANTIAGO-DB │ │  MEXICO-DB   │              │
│   │  Puerto: 5433│ │  Puerto: 5434│ │Puerto: 5435  │              │
│   │  (standby)   │ │  (standby)   │ │  (standby)   │              │
│   │  Read Only   │ │  Read Only   │ │  Read Only   │              │
│   └──────────────┘ └──────────────┘ └──────────────┘              │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
```

---

## PASOS PARA LEVANTAR

### 1. Ir al directorio de infraestructura

```bash
cd src/infrastructure
``` 

### 2. Limpiar volúmenes anteriores (si hay problemas)

```bash
docker compose -f docker-compose.multi.yml down -v
```

### 3. Levantar todos los nodos

```bash
docker compose -f docker-compose.multi.yml up -d
```

### 4. Esperar a que Lima esté healthy (~30 segundos)

```bash
docker compose -f docker-compose.multi.yml ps lima-db
```

### 5. Verificar que los standbys están corriendo

```bash
docker compose -f docker-compose.multi.yml ps
```

Deberías ver todos los contenedores en estado "healthy":
- lima-db, bogota-db, santiago-db, mexico-db

---

## VERIFICACIÓN DE REPLICACIÓN

### 1. Ver slots de replicación en Lima (PRIMARY)

```bash
docker compose -f docker-compose.multi.yml exec lima-db psql -U postgres -c "SELECT slot_name, active FROM pg_replication_slots;"
```

Deberías ver:
```
 slot_name   | active
-------------+--------
 bogota_slot | f
 santiago_slot | f
 mexico_slot | f
```

### 2. Ver estado de replicación en Lima

```bash
docker compose -f docker-compose.multi.yml exec lima-db psql -U postgres -c "SELECT application_name, state, sent_lsn, replay_lsn FROM pg_stat_replication;"
```

Deberías ver:
```
 application_name |   state   | sent_lsn  | replay_lsn
------------------+-----------+-----------+------------
 bogota           | streaming | 0/60204B8 | 0/60204B8
 mexico           | streaming | 0/60204B8 | 0/60204B8
 santiago         | streaming | 0/60204B8 | 0/60204B8
```

### 3. Verificar que standbys están en recovery

```bash
docker compose -f docker-compose.multi.yml exec bogota-db psql -U postgres -c "SELECT pg_is_in_recovery();"
```

Debería devolver: `t` (true = es standby)

---

## PRUEBA DE REPLICACIÓN

### 1. Crear tabla e insertar datos en LIMA (PRIMARY)

```bash
docker compose -f docker-compose.multi.yml exec lima-db psql -U postgres -c "
CREATE TABLE inventarios (
    id SERIAL PRIMARY KEY,
    centro VARCHAR(50),
    producto VARCHAR(100),
    cantidad INTEGER,
    fecha TIMESTAMP DEFAULT NOW()
);

INSERT INTO inventarios (centro, producto, cantidad) VALUES
    ('Lima', 'Paquetes', 1500),
    ('Lima', 'Sobres', 3000);
"
```

### 2. Verificar replicación en BOGOTÁ (STANDBY)

```bash
docker compose -f docker-compose.multi.yml exec bogota-db psql -U postgres -c "SELECT * FROM inventarios;"
```

Deberías ver los mismos datos replicados.

### 3. Verificar replicación en SANTIAGO

```bash
docker compose -f docker-compose.multi.yml exec santiago-db psql -U postgres -c "SELECT * FROM inventarios;"
```

### 4. Verificar replicación en MÉXICO

```bash
docker compose -f docker-compose.multi.yml exec mexico-db psql -U postgres -c "SELECT * FROM inventarios;"
```

---

## PRUEBA DE SOLO LECTURA EN STANDBY

### Intentar INSERT en Bogotá (debe FALLAR)

```bash
docker compose -f docker-compose.multi.yml exec bogota-db psql -U postgres -c "INSERT INTO inventarios (centro, producto, cantidad) VALUES ('Bogota', 'Test', 100);"
```

Deberías ver error:
```
ERROR:  cannot execute INSERT in a read-only transaction
```

---

## SIMULAR FALLO DEL PRIMARY (FAILOVER)

### 1. Bajar el nodo Lima

```bash
docker compose -f docker-compose.multi.yml stop lima-db
```

### 2. Promover Bogotá a PRIMARY

```bash
docker compose -f docker-compose.multi.yml exec bogota-db psql -U postgres -c "SELECT pg_promote();"
```

### 3. Verificar que Bogotá ya NO está en recovery

```bash
docker compose -f docker-compose.multi.yml exec bogota-db psql -U postgres -c "SELECT pg_is_in_recovery();"
```

Debería devolver: `f` (false = ya es primary)

### 4. Ahora Bogotá acepta writes

```bash
docker compose -f docker-compose.multi.yml exec bogota-db psql -U postgres -c "INSERT INTO inventarios (centro, producto, cantidad) VALUES ('Bogota', 'Post-failover', 999);"
```

### 5. Para re-establecer la replicación (requiere reconfigurar)

Después de un failover, Lima y los otros nodos necesitan ser reconfigurados como nuevos standbys.

---

## COMANDOS ÚTILES

### Ver todos los contenedores

```bash
docker compose -f docker-compose.multi.yml ps
```

### Ver logs de un nodo específico

```bash
docker compose -f docker-compose.multi.yml logs -f lima-db
docker compose -f docker-compose.multi.yml logs -f bogota-db
```

### Ver uso de recursos

```bash
docker stats
```

### Reiniciar un nodo específico

```bash
docker compose -f docker-compose.multi.yml restart bogota-db
```

### Bajar todo

```bash
docker compose -f docker-compose.multi.yml down
```

### Bajar todo Y eliminar datos (CUIDADO - borra todo)

```bash
docker compose -f docker-compose.multi.yml down -v
```

---

## PUERTOS DISPONIBLES

| Nodo | Puerto DB | Puerto Studio | Puerto REST API |
|------|-----------|---------------|-----------------|
| Lima | 5432 | 3000 | 3001 |
| Bogotá | 5433 | 3010 | 3011 |
| Santiago | 5434 | 3020 | 3021 |
| México | 5435 | 3030 | 3031 |

### Acceder a Studio (interfaz web Supabase)

- Lima: http://localhost:3000
- Bogotá: http://localhost:3010
- Santiago: http://localhost:3020
- México: http://localhost:3030

---

## VERIFICACIÓN AVANZADA

### Ver lag de replicación

```bash
docker compose -f docker-compose.multi.yml exec lima-db psql -U postgres -c "
SELECT
  application_name,
  state,
  (pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn) / 1024 / 1024)::numeric(10,2) AS lag_mb
FROM pg_stat_replication;
"
```

### Ver tamaño de WAL

```bash
docker compose -f docker-compose.multi.yml exec lima-db psql -U postgres -c "SELECT pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), '0/0')::pg_lsn);"
```

### Ver conexiones activas

```bash
docker compose -f docker-compose.multi.yml exec lima-db psql -U postgres -c "SELECT * FROM pg_stat_activity WHERE state = 'active';"
```

---

## TROUBLESHOOTING

### Problema: "no pg_hba.conf entry for replication"

1. Verificar que pg_hba.conf está montado en Lima:
```bash
docker compose -f docker-compose.multi.yml exec lima-db cat /etc/postgresql/pg_hba.conf | grep replication
```

2. Recargar configuración:
```bash
docker compose -f docker-compose.multi.yml exec lima-db psql -U supabase_admin -c "SELECT pg_reload_conf();"
```

### Problema: Standby no se conecta

1. Verificar que Lima está corriendo: `docker compose -f docker-compose.multi.yml ps lima-db`
2. Ver logs del standby: `docker compose -f docker-compose.multi.yml logs bogota-db`
3. Verificar que los slots existen:
```bash
docker compose -f docker-compose.multi.yml exec lima-db psql -U postgres -c "SELECT * FROM pg_replication_slots;"
```

### Problema: "max_replication_slots exceeded"

```bash
docker compose -f docker-compose.multi.yml exec lima-db psql -U postgres -c "SELECT pg_drop_replication_slot('nombre_slot');"
```

### Problema: Volumen corrupto

Si hay errores de "invalid magic number" o "could not create file":
```bash
docker compose -f docker-compose.multi.yml down -v
docker volume rm sd-lab-db-multi_lima-db-data sd-lab-db-multi_bogota-db-data sd-lab-db-multi_santiago-db-data sd-lab-db-multi_mexico-db-data
docker compose -f docker-compose.multi.yml up -d
```

---

## LIMITACIONES

- Réplicas son **SOLO LECTURA** (no puedes hacer INSERT/UPDATE/DELETE)
- Writes solo van al PRIMARY (Lima)
- Réplicas pueden tener un pequeño lag (normalmente < 1MB)
- Después de un failover, se requiere reconfiguración manual de los nodos caídos

## Comando de verificación rápida de replicación
```bash
# 1. Ver estado de todos los containers
docker compose -f docker-compose.multi.yml ps

# 2. Ver replication slots
docker compose -f docker-compose.multi.yml exec lima-db psql -U postgres -c "SELECT * FROM pg_replication_slots;"

# 3. Ver streaming replication
docker compose -f docker-compose.multi.yml exec lima-db psql -U postgres -c "SELECT * FROM pg_stat_replication;"

# 4. Verificar que standbys están en recovery
docker compose -f docker-compose.multi.yml exec bogota-db psql -U postgres -c "SELECT pg_is_in_recovery();"

# 5. Ver logs de un nodo
docker compose -f docker-compose.multi.yml logs lima-db
```
