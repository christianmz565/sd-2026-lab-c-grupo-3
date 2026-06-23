BEGIN;

-- =============================================================================
-- VISTAS PARA REPORTES EJECUTIVOS
-- =============================================================================

-- Vista resumen por centro
CREATE OR REPLACE VIEW public.resumen_centros AS
SELECT
    centro,
    COUNT(*) as total_productos,
    SUM(cantidad) as stock_total,
    COUNT(DISTINCT categoria) as categorias,
    AVG(temperatura_almacen) as temp_promedio,
    MIN(fecha_caducidad) as proxima_caducidad
FROM inventarios
WHERE estado = 'disponible'
GROUP BY centro
ORDER BY centro;

-- Vista de envíos por estado
CREATE OR REPLACE VIEW public.envios_por_estado AS
SELECT
    estado,
    COUNT(*) as cantidad,
    AVG(peso) as peso_promedio,
    SUM(CASE WHEN fecha_entrega_real <= fecha_entrega_estimada THEN 1 ELSE 0 END) as a_tiempo
FROM seguimiento_envios
GROUP BY estado
ORDER BY cantidad DESC;

-- Vista de pedidos recientes
CREATE OR REPLACE VIEW public.pedidos_recientes AS
SELECT
    numero_pedido,
    centro,
    cliente,
    monto_total,
    estado,
    fecha_pedido,
    AGE(NOW(), fecha_pedido) as tiempo_transcurrido
FROM historial_pedidos
ORDER BY fecha_pedido DESC
LIMIT 10;

-- Vista de alertas de temperatura
CREATE OR REPLACE VIEW public.alertas_temperatura AS
SELECT
    centro,
    almacen,
    sensor_id,
    temperatura,
    humedad,
    fecha_hora,
    CASE
        WHEN temperatura > 15 THEN 'CRÍTICO - Demasiado caliente'
        WHEN temperatura < -2 THEN 'CRÍTICO - Demasiado frío'
        WHEN temperatura > 10 AND temperatura <= 15 THEN 'ALERTA - Temperatura elevada'
        WHEN temperatura < 0 AND temperatura >= -2 THEN 'ALERTA - Temperatura baja'
        ELSE 'NORMAL'
    END as estado_temperatura
FROM temperaturas_almacen
ORDER BY fecha_hora DESC, centro;

-- Vista de flota activa
CREATE OR REPLACE VIEW public.flota_activa AS
SELECT
    vehiculo_id,
    tipo_vehiculo,
    centro_asignado,
    conductor,
    patente,
    velocidad,
    direccion,
    estado,
    fecha_hora
FROM ubicacion_vehiculos
WHERE estado != 'inactivo'
ORDER BY centro_asignado, vehiculo_id;

-- Vista de reporte ejecutivo consolidado
CREATE OR REPLACE VIEW public.reporte_consolidado AS
SELECT
    r.centro,
    r.fecha_reporte,
    r.total_envios,
    r.envios_entregados,
    r.envios_en_transito,
    r.envios_retrasados,
    r.monto_total_ventas,
    r.tasa_exito,
    (SELECT COUNT(*) FROM inventarios i WHERE i.centro = r.centro AND i.estado = 'disponible') as productos_disponibles,
    (SELECT AVG(temperatura) FROM temperaturas_almacen t WHERE t.centro = r.centro AND t.fecha_hora::date = r.fecha_reporte) as temp_promedio_dia
FROM reportes_ejecutivos r
WHERE r.tipo_reporte = 'Diario'
ORDER BY r.fecha_reporte DESC, r.centro;

COMMIT;
