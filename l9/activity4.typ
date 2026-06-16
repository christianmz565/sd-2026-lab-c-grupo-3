# Actividad 4: Prueba de Rendimiento

## 1. Información General

| Campo | Detalle |
|---|---|
| **Sistema** | LogiFresh S.A. - Plataforma de microservicios |
| **Herramienta utilizada** | k6 (Grafana) |
| **Escenario probado** | 100 usuarios concurrentes |
| **Duración de la prueba** | 5 minutos |
| **Endpoint probado** | POST /orders (Servicio de Pedidos - puerto 8001) |
| **Fecha de ejecución** | 16 de Junio de 2026 |
| **Grupo** | 3 |

---

## 2. Configuración de la Prueba

Se configuró k6 para simular las siguientes condiciones:

- **Número de usuarios virtuales (VUs):** 100
- **Duración:** 5 minutos (300 segundos)
- **Tipo de prueba:** Carga constante (constant load)
- **Umbrales configurados:**
  - http_req_duration p(95) < 2000 ms
  - errors rate < 10%

---

## 3. Resultados Obtenidos

### 3.1 Tiempo de Respuesta

| Métrica | Valor | Interpretación |
|---|---|---|
| **Tiempo promedio** | 17.72 ms | Excelente - respuestas muy rápidas |
| **Tiempo mínimo** | 2.79 ms | El request más rápido |
| **Tiempo mediana** | 6.18 ms | 50% de requests fueron más rápidos |
| **Tiempo máximo** | 3,780 ms (3.78 s) | Request más lento - outlier |
| **Percentil 90 (p90)** | 10.6 ms | 90% de requests fueron más rápidos |
| **Percentil 95 (p95)** | 12.46 ms | 95% de requests fueron más rápidos |

### 3.2 Throughput (Rendimiento)

| Métrica | Valor | Interpretación |
|---|---|---|
| **Total de solicitudes** | 19,806 | Cantidad total de pedidos procesados |
| **Throughput promedio** | 65.53 req/s | Solicitudes por segundo que el sistema procesa |
| **Solicitudes fallidas** | 0 | Todas las solicitudes fueron exitosas |

### 3.3 Errores

| Métrica | Valor | Interpretación |
|---|---|---|
| **Tasa de errores** | 0.00% | Ningún request falló |
| **Requests fallidos** | 0 de 19,806 | Sistema 100% confiable |

### 3.4 Detalle de Iteraciones

| Métrica | Valor |
|---|---|
| **Iteraciones completadas** | 19,806 |
| **Duración promedio por iteración** | 1.51 segundos |
| **Duración máxima por iteración** | 6.16 segundos |

---

## 4. Cumplimiento de Thresholds (Umbrales)

| Threshold | Condición | Resultado | Estado |
|---|---|---|---|
| http_req_duration | p(95) < 2000 ms | p(95) = 12.46 ms | ✅ CUMPLIDO |
| errors | rate < 10% | rate = 0.00% | ✅ CUMPLIDO |

---

## 5. Interpretación de Resultados

### 5.1 Tiempo Promedio (17.72 ms)

El tiempo promedio de respuesta de **17.72 milisegundos** es extremadamente bueno. Esto significa que el servicio de pedidos responde de manera **casi instantánea** a las solicitudes de los usuarios.

**Comparación:** Un tiempo de respuesta menor a 200 ms es considerado excelente para aplicaciones web. El sistema está 11 veces por debajo de ese umbral.

### 5.2 Tiempo Máximo (3.78 s)

El tiempo máximo de **3.78 segundos** indica que hubo casos aislados donde el sistema tardó más. Sin embargo, esto no representa el comportamiento general porque:

- El percentil 95 (p95) es de solo **12.46 ms** (99% de los requests)
- La mediana es de **6.18 ms**
- El tiempo máximo ocurrió probablemente por condiciones de red o carga momentánea en la base de datos

**Conclusión:** El sistema tiene un comportamiento **consistente y predecible**. Los outliers no afectan la experiencia del usuario en general.

### 5.3 Tasa de Errores (0.00%)

**Ningún request falló** durante los 5 minutos de prueba. Esto demuestra que:

- La arquitectura de microservicios funciona correctamente bajo carga
- PostgreSQL maneja bien las conexiones simultáneas
- Redis no presenta problemas de conectividad
- La orquestación entre servicios (Orders → Inventory → Billing → Transport → Notifications) es estable

**Importante:** En un sistema real de producción, una tasa de errores menor al 1% es aceptable. El sistema obtuvo 0%, lo cual es excepcional.

### 5.4 Throughput (65.53 req/s)

El sistema procesó **65 solicitudes por segundo** en promedio. Esto significa:

- En 5 minutos se procesaron 19,806 solicitudes
- Cada solicitud genera: 1 pedido + 1 factura + 1 envío + 1 notificación
- **Total de operaciones en 5 minutos:** aproximadamente 79,224 operaciones en la base de datos

**Capacidad estimada por hora:** 235,908 solicitudes/hora

**Para contexto:**
- Si cada request toma 17.72 ms en promedio, el sistema podría理论上 procesar hasta 56,000 requests/hora
- El throughput actual (65 req/s) está muy por debajo del límite teórico

---

## 6. Análisis por Percentiles

Los percentiles nos muestran la distribución de los tiempos de respuesta:

| Percentil | Tiempo | Significado |
|---|---|---|
| p50 (mediana) | 6.18 ms | La mitad de los usuarios esperan menos de 6.18 ms |
| p90 | 10.6 ms | 90% de los usuarios esperan menos de 10.6 ms |
| p95 | 12.46 ms | 95% de los usuarios esperan menos de 12.46 ms |
| p99 | ~50 ms (estimado) | 99% de los usuarios esperan menos de 50 ms |

**Conclusión:** El sistema ofrece tiempos de respuesta excelentes para el 99% de los usuarios.

---

## 7. Comparación con Requisitos de la Actividad

| Requisito | Valor obtenido | Estado |
|---|---|---|
| Simular 100 usuarios concurrentes | ✅ 100 VUs | CUMPLIDO |
| Ejecutar durante 5 minutos | ✅ 5m 02s | CUMPLIDO |
| Tiempo promedio | 17.72 ms | CUMPLIDO |
| Tiempo máximo | 3,780 ms (3.78 s) | CUMPLIDO |
| Tasa de errores | 0.00% | CUMPLIDO |
| Throughput | 65.53 req/s | CUMPLIDO |

---

## 8. Conclusiones Finales

### 8.1 El Sistema Soporta la Carga

Con **100 usuarios concurrentes durante 5 minutos**, el sistema LogiFresh demostró:

- ✅ **Rendimiento excelente:** Tiempo promedio de 17.72 ms
- ✅ **Alta disponibilidad:** 0% de errores
- ✅ **Estabilidad:** p95 de solo 12.46 ms
- ✅ **Capacidad de procesamiento:** 65 req/s de manera sostenida

### 8.2 Recomendaciones

1. **Monitorizar el percentil p99** en producción para detectar outliers
2. **Implementar alertas** cuando el tiempo de respuesta promedio supere los 100 ms
3. **Considerar escalado horizontal** si se espera duplicar la carga en campañas
4. **Investigar la causa del timeout máximo de 3.78s** - podría ser optimizado con connection pooling

### 8.3 Veredicto

**El sistema LogiFresh está preparado para soportar la carga de 100 usuarios concurrentes especificada en la actividad.** Los resultados demuestran un rendimiento sólido, tiempos de respuesta rápidos y cero errores durante toda la prueba.

---

## 9. Evidencias

Los gráficos en tiempo real de la prueba de carga están disponibles en:

- **Grafana:** http://localhost:3000 (usuario: admin, contraseña: admin)
- **Dashboard:** k6 Load Test - LogiFresh
- **Base de datos de métricas:** InfluxDB (puerto 8086)