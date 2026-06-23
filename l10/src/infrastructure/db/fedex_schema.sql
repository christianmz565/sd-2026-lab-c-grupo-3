BEGIN;

-- =============================================================================
-- FEDEX PERU - SCHEMA COMPLETO DE REPLICACIÓN
-- Caso: Transporte de productos perecibles
-- Centros: Lima, Bogotá, Santiago, Ciudad de México
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. TABLA DE INVENTARIOS
-- Productos perecibles en cada centro de distribución
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS inventarios (
    id SERIAL PRIMARY KEY,
    centro VARCHAR(50) NOT NULL,
    producto VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    cantidad INTEGER NOT NULL DEFAULT 0,
    unidad VARCHAR(20) NOT NULL DEFAULT 'kg',
    fecha_caducidad DATE,
    temperatura_almacen DECIMAL(5,2),
    ubicacion_almacen VARCHAR(50),
    estado VARCHAR(20) DEFAULT 'disponible',
    fecha_registro TIMESTAMP DEFAULT NOW(),
    CONSTRAINT chk_estado_inventario CHECK (estado IN ('disponible', 'reservado', 'en_transito', 'vencido'))
);

INSERT INTO inventarios (centro, producto, categoria, cantidad, unidad, fecha_caducidad, temperatura_almacen, ubicacion_almacen, estado) VALUES
    ('Lima', 'Fresas Orgánicas', 'Frutas', 500, 'kg', '2026-06-30', 4.5, 'A1-01', 'disponible'),
    ('Lima', 'Filete de Salmón', 'Pescados', 300, 'kg', '2026-06-25', 2.0, 'B2-03', 'disponible'),
    ('Lima', 'Leche Fresca', 'Lácteos', 1000, 'litros', '2026-06-28', 3.5, 'C1-02', 'reservado'),
    ('Bogota', 'Aguacate Hass', 'Frutas', 800, 'kg', '2026-07-05', 12.0, 'A1-01', 'disponible'),
    ('Bogota', 'Yogurt Natural', 'Lácteos', 600, 'litros', '2026-06-30', 4.0, 'B1-01', 'disponible'),
    ('Bogota', 'Pollo Entero', 'Carnes', 450, 'kg', '2026-06-26', 1.5, 'C2-01', 'reservado'),
    ('Santiago', 'Uvas Seedless', 'Frutas', 700, 'kg', '2026-07-02', 8.0, 'A1-02', 'disponible'),
    ('Santiago', 'Salmón Ahumado', 'Pescados', 250, 'kg', '2026-06-29', 2.5, 'B1-03', 'disponible'),
    ('Santiago', 'Queso Fresco', 'Lácteos', 400, 'kg', '2026-07-01', 5.0, 'C1-01', 'disponible'),
    ('Mexico', 'Mango Ataulfo', 'Frutas', 900, 'kg', '2026-07-08', 10.0, 'A1-01', 'disponible'),
    ('Mexico', 'Crema Ácida', 'Lácteos', 350, 'litros', '2026-06-28', 4.0, 'B2-02', 'reservado'),
    ('Mexico', 'Camarón Jumbo', 'Mariscos', 200, 'kg', '2026-06-27', 0.5, 'C1-01', 'en_transito');

-- -----------------------------------------------------------------------------
-- 2. TABLA DE SEGUIMIENTO DE ENVÍOS
-- Tracking de envíos en tiempo real
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS seguimiento_envios (
    id SERIAL PRIMARY KEY,
    codigo_envio VARCHAR(30) UNIQUE NOT NULL,
    centro_origen VARCHAR(50) NOT NULL,
    centro_destino VARCHAR(50) NOT NULL,
    cliente VARCHAR(100) NOT NULL,
    tipo_producto VARCHAR(50) NOT NULL,
    peso DECIMAL(10,2),
    temperatura_requerida DECIMAL(5,2),
    estado VARCHAR(30) NOT NULL DEFAULT 'recibido',
    fecha_salida TIMESTAMP,
    fecha_entrega_estimada TIMESTAMP,
    fecha_entrega_real TIMESTAMP,
    ubicacion_actual VARCHAR(100),
    latitud DECIMAL(10,7),
    longitud DECIMAL(10,7),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT chk_estado_envio CHECK (estado IN ('recibido', 'en_almacen', 'en_transito', 'entregado', 'retrasado', 'cancelado'))
);

INSERT INTO seguimiento_envios (codigo_envio, centro_origen, centro_destino, cliente, tipo_producto, peso, temperatura_requerida, estado, fecha_salida, fecha_entrega_estimada, ubicacion_actual, latitud, longitud) VALUES
    ('FE-2026-001', 'Lima', 'Bogota', 'Almacenes Éxito', 'Frutas', 150.50, 8.0, 'en_transito', '2026-06-23 08:00:00', '2026-06-25 18:00:00', 'Aeropuerto Lima', -12.0219, -77.1143),
    ('FE-2026-002', 'Bogota', 'Santiago', 'Cencosud', 'Lácteos', 200.00, 4.0, 'en_almacen', NULL, '2026-06-27 12:00:00', 'Centro Bogota', 4.7110, -74.0721),
    ('FE-2026-003', 'Santiago', 'Mexico', 'Walmart México', 'Pescados', 180.75, 2.0, 'recibido', NULL, '2026-06-30 10:00:00', 'Centro Santiago', -33.4489, -70.6693),
    ('FE-2026-004', 'Mexico', 'Lima', 'Plaza Vea', 'Frutas', 300.00, 10.0, 'en_transito', '2026-06-22 14:00:00', '2026-06-24 20:00:00', 'En vuelo Mexico-Lima', 19.4363, -99.0721),
    ('FE-2026-005', 'Lima', 'Santiago', 'Jumbo Chile', 'Carnes', 120.00, 1.5, 'entregado', '2026-06-20 06:00:00', '2026-06-22 18:00:00', 'Centro Santiago', -33.4489, -70.6693),
    ('FE-2026-006', 'Bogota', 'Lima', 'Metro Lima', 'Lácteos', 250.00, 3.5, 'retrasado', '2026-06-21 10:00:00', '2026-06-23 14:00:00', 'Aduana Colombia', 4.7110, -74.0721),
    ('FE-2026-007', 'Mexico', 'Bogota', 'Éxito Colombia', 'Mariscos', 95.50, 0.5, 'en_transito', '2026-06-23 06:00:00', '2026-06-25 22:00:00', 'En vuelo México-Bogota', 19.4363, -99.0721),
    ('FE-2026-008', 'Santiago', 'Lima', 'Ripley Peru', 'Frutas', 175.00, 8.0, 'recibido', NULL, '2026-07-01 08:00:00', 'Centro Santiago', -33.4489, -70.6693);

-- -----------------------------------------------------------------------------
-- 3. TABLA DE HISTORIAL DE PEDIDOS
-- Registro completo de todos los pedidos realizados
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS historial_pedidos (
    id SERIAL PRIMARY KEY,
    numero_pedido VARCHAR(30) UNIQUE NOT NULL,
    centro VARCHAR(50) NOT NULL,
    cliente VARCHAR(100) NOT NULL,
    contacto_cliente VARCHAR(100),
    email_cliente VARCHAR(100),
    fecha_pedido TIMESTAMP DEFAULT NOW(),
    fecha_confirmacion TIMESTAMP,
    fecha_despacho TIMESTAMP,
    fecha_entrega TIMESTAMP,
    monto_total DECIMAL(12,2),
    moneda VARCHAR(3) DEFAULT 'USD',
    estado VARCHAR(30) NOT NULL DEFAULT 'pendiente',
    observaciones TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT chk_estado_pedido CHECK (estado IN ('pendiente', 'confirmado', 'en_preparacion', 'despachado', 'en_transito', 'entregado', 'retrasado', 'cancelado'))
);

INSERT INTO historial_pedidos (numero_pedido, centro, cliente, contacto_cliente, email_cliente, fecha_pedido, fecha_confirmacion, monto_total, estado, observaciones) VALUES
    ('PED-2026-0001', 'Lima', 'Almacenes Éxito', 'Juan Pérez', 'juan.perez@exito.com', '2026-06-20 09:15:00', '2026-06-20 09:30:00', 4500.00, 'en_transito', 'Envío urgente - producto perecedero'),
    ('PED-2026-0002', 'Bogota', 'Cencosud Colombia', 'María García', 'mgarcia@cencosud.co', '2026-06-21 11:00:00', '2026-06-21 11:15:00', 3200.00, 'en_preparacion', 'Temperatura controlada requerida'),
    ('PED-2026-0003', 'Santiago', 'Walmart Chile', 'Carlos López', 'clopez@walmart.cl', '2026-06-22 08:45:00', '2026-06-22 09:00:00', 5800.00, 'despachado', 'Pedido grande - 3 palets'),
    ('PED-2026-0004', 'Mexico', 'Plaza Vea Peru', 'Ana Martínez', 'amartinez@plazavea.pe', '2026-06-22 14:30:00', '2026-06-22 15:00:00', 2900.00, 'en_transito', 'Mango Ataulfo - 900kg'),
    ('PED-2026-0005', 'Lima', 'Jumbo Chile', 'Pedro Sánchez', 'psanchez@jumbo.cl', '2026-06-19 16:00:00', '2026-06-19 16:20:00', 6700.00, 'entregado', 'Entregado el 22/06'),
    ('PED-2026-0006', 'Bogota', 'Metro Peru', 'Laura Díaz', 'ldiaz@metro.pe', '2026-06-21 10:00:00', '2026-06-21 10:30:00', 4100.00, 'retrasado', 'Retraso en aduana colombiana'),
    ('PED-2026-0007', 'Mexico', 'Éxito Colombia', 'Roberto Hernández', 'rhernandez@exito.co', '2026-06-23 07:00:00', NULL, 1850.00, 'pendiente', 'Esperando confirmación de stock'),
    ('PED-2026-0008', 'Santiago', 'Ripley Peru', 'Sofía Morales', 'smorales@ripley.pe', '2026-06-22 12:00:00', '2026-06-22 12:30:00', 3400.00, 'confirmado', 'Uvas seedless premium');

-- -----------------------------------------------------------------------------
-- 4. TABLA DE TEMPERATURAS DE ALMACENAMIENTO
-- Monitoreo de temperatura en tiempo real
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS temperaturas_almacen (
    id SERIAL PRIMARY KEY,
    centro VARCHAR(50) NOT NULL,
    almacen VARCHAR(50) NOT NULL,
    sensor_id VARCHAR(30),
    temperatura DECIMAL(5,2) NOT NULL,
    unidad VARCHAR(1) DEFAULT 'C',
    humedad DECIMAL(5,2),
    fecha_hora TIMESTAMP DEFAULT NOW(),
    alerta BOOLEAN DEFAULT FALSE,
    CONSTRAINT chk_alerta CHECK (alerta IN (TRUE, FALSE))
);

INSERT INTO temperaturas_almacen (centro, almacen, sensor_id, temperatura, humedad, fecha_hora, alerta) VALUES
    ('Lima', 'Almacen A', 'SEN-LIM-A01', 4.5, 85.0, '2026-06-23 15:00:00', FALSE),
    ('Lima', 'Almacen B', 'SEN-LIM-B01', 2.0, 90.0, '2026-06-23 15:00:00', FALSE),
    ('Lima', 'Almacen C', 'SEN-LIM-C01', 3.5, 88.0, '2026-06-23 15:00:00', FALSE),
    ('Bogota', 'Almacen A', 'SEN-BOG-A01', 12.5, 75.0, '2026-06-23 15:00:00', FALSE),
    ('Bogota', 'Almacen B', 'SEN-BOG-B01', 4.2, 82.0, '2026-06-23 15:00:00', FALSE),
    ('Bogota', 'Almacen C', 'SEN-BOG-C01', 1.8, 92.0, '2026-06-23 15:00:00', FALSE),
    ('Santiago', 'Almacen A', 'SEN-SCL-A01', 8.2, 78.0, '2026-06-23 15:00:00', FALSE),
    ('Santiago', 'Almacen B', 'SEN-SCL-B01', 2.5, 89.0, '2026-06-23 15:00:00', FALSE),
    ('Santiago', 'Almacen C', 'SEN-SCL-C01', 5.0, 80.0, '2026-06-23 15:00:00', FALSE),
    ('Mexico', 'Almacen A', 'SEN-MEX-A01', 10.2, 70.0, '2026-06-23 15:00:00', FALSE),
    ('Mexico', 'Almacen B', 'SEN-MEX-B01', 4.0, 85.0, '2026-06-23 15:00:00', FALSE),
    ('Mexico', 'Almacen C', 'SEN-MEX-C01', 0.3, 95.0, '2026-06-23 15:00:00', FALSE),
    ('Lima', 'Almacen A', 'SEN-LIM-A01', 4.8, 84.5, '2026-06-23 15:05:00', FALSE),
    ('Bogota', 'Almacen C', 'SEN-BOG-C01', 2.1, 91.5, '2026-06-23 15:05:00', FALSE),
    ('Santiago', 'Almacen B', 'SEN-SCL-B01', 2.8, 88.5, '2026-06-23 15:05:00', FALSE),
    ('Mexico', 'Almacen C', 'SEN-MEX-C01', 0.5, 94.5, '2026-06-23 15:05:00', FALSE);

-- -----------------------------------------------------------------------------
-- 5. TABLA DE UBICACIÓN DE VEHÍCULOS
-- Tracking GPS de la flota de transporte
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ubicacion_vehiculos (
    id SERIAL PRIMARY KEY,
    vehiculo_id VARCHAR(30) UNIQUE NOT NULL,
    tipo_vehiculo VARCHAR(30) NOT NULL,
    centro_asignado VARCHAR(50) NOT NULL,
    conductor VARCHAR(100),
    patente VARCHAR(20),
    latitud DECIMAL(10,7) NOT NULL,
    longitud DECIMAL(10,7) NOT NULL,
    velocidad DECIMAL(5,2),
    direccion VARCHAR(100),
    estado VARCHAR(20) DEFAULT 'activo',
    fecha_hora TIMESTAMP DEFAULT NOW(),
    CONSTRAINT chk_estado_vehiculo CHECK (estado IN ('activo', 'inactivo', 'mantenimiento', 'en_ruta'))
);

INSERT INTO ubicacion_vehiculos (vehiculo_id, tipo_vehiculo, centro_asignado, conductor, patente, latitud, longitud, velocidad, direccion, estado) VALUES
    ('VH-LIM-001', 'Camión Refrigerado', 'Lima', 'Carlos Mendoza', 'ABC-123', -12.0464, -77.0428, 65.5, 'Av. Panamericana Norte', 'en_ruta'),
    ('VH-LIM-002', 'Furgón Refrigerado', 'Lima', 'Luis Torres', 'DEF-456', -12.0580, -77.0370, 0.0, 'Centro Lima', 'activo'),
    ('VH-BOG-001', 'Camión Refrigerado', 'Bogota', 'Andrés Ramírez', 'GHI-789', 4.6097, -74.0817, 45.2, 'Autopista Norte', 'en_ruta'),
    ('VH-BOG-002', 'Furgón Refrigerado', 'Bogota', 'Diana Suárez', 'JKL-012', 4.7110, -74.0721, 0.0, 'Centro Bogota', 'activo'),
    ('VH-SCL-001', 'Camión Refrigerado', 'Santiago', 'Pedro Vega', 'MNO-345', -33.4489, -70.6693, 70.3, 'Ruta 5 Norte', 'en_ruta'),
    ('VH-SCL-002', 'Furgón Refrigerado', 'Santiago', 'María López', 'PQR-678', -33.4569, -70.6638, 0.0, 'Centro Santiago', 'activo'),
    ('VH-MEX-001', 'Camión Refrigerado', 'Mexico', 'Jorge Hernández', 'STU-901', 19.4326, -99.1332, 55.8, 'Autopista México-Puebla', 'en_ruta'),
    ('VH-MEX-002', 'Furgón Refrigerado', 'Mexico', 'Rosa García', 'VWX-234', 19.4363, -99.0721, 0.0, 'Centro México', 'activo'),
    ('VH-LIM-003', 'Camión Refrigerado', 'Lima', 'Miguel Ángel Ríos', 'YZA-567', -12.0219, -77.1143, 80.0, 'Aeropuerto Lima', 'en_ruta'),
    ('VH-BOG-003', 'Furgón Refrigerado', 'Bogota', 'Sandra Milena Rodríguez', 'BCD-890', 4.5981, -74.0761, 30.0, 'Centro Comercial', 'en_ruta');

-- -----------------------------------------------------------------------------
-- 6. TABLA DE REPORTES EJECUTIVOS
-- Resumen ejecutivo para dashboards
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS reportes_ejecutivos (
    id SERIAL PRIMARY KEY,
    centro VARCHAR(50) NOT NULL,
    tipo_reporte VARCHAR(50) NOT NULL,
    fecha_reporte DATE NOT NULL,
    total_envios INTEGER DEFAULT 0,
    envios_entregados INTEGER DEFAULT 0,
    envios_en_transito INTEGER DEFAULT 0,
    envios_retrasados INTEGER DEFAULT 0,
    monto_total_ventas DECIMAL(12,2) DEFAULT 0,
    temperatura_promedio DECIMAL(5,2),
    tasa_exito DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(centro, tipo_reporte, fecha_reporte)
);

INSERT INTO reportes_ejecutivos (centro, tipo_reporte, fecha_reporte, total_envios, envios_entregados, envios_en_transito, envios_retrasados, monto_total_ventas, temperatura_promedio, tasa_exito) VALUES
    ('Lima', 'Diario', '2026-06-23', 45, 38, 5, 2, 28500.00, 3.8, 84.44),
    ('Lima', 'Semanal', '2026-06-23', 312, 280, 25, 7, 198000.00, 4.1, 89.74),
    ('Bogota', 'Diario', '2026-06-23', 38, 32, 4, 2, 22400.00, 5.8, 84.21),
    ('Bogota', 'Semanal', '2026-06-23', 265, 235, 22, 8, 156000.00, 6.2, 88.68),
    ('Santiago', 'Diario', '2026-06-23', 52, 47, 3, 2, 34200.00, 5.2, 90.38),
    ('Santiago', 'Semanal', '2026-06-23', 358, 320, 28, 10, 245000.00, 5.5, 89.39),
    ('Mexico', 'Diario', '2026-06-23', 61, 54, 5, 2, 41500.00, 4.9, 88.52),
    ('Mexico', 'Semanal', '2026-06-23', 425, 380, 32, 13, 298000.00, 5.1, 89.41);

COMMIT;
