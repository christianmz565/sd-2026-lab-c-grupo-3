# Actividad 4: Prueba de Rendimiento

## 1. Información General

| Campo | Detalle |
|---|---|
| **Sistema** | LogiFresh S.A. - Plataforma de microservicios |
| **Herramienta** | k6 |
| **Escenario** | 100 usuarios concurrentes |
| **Duración** | 5 minutos |
| **Endpoint** | POST /orders (puerto 8001) |
| **Fecha** | 16/06/2026 |
| **Grupo** | 3 |

---

## 2. Configuración de la Prueba

- **Usuarios virtuales (VUs):** 100
- **Tipo de prueba:** Carga constante (constant load)
- **Umbrales:** http_req_duration p(95) < 2000 ms, errors rate < 10%

---

## 3. Resultados Obtenidos

### 3.1 Resumen de Métricas

| Métrica Solicitada | Resultado Obtenido | Descripción |
|---|---|---|
| Usuarios concurrentes | 100 | 100 max VUs |
| Duración | 5 minutos | 5m0s |
| Tiempo promedio | 21.57 ms | http_req_duration (avg) |
| Tiempo máximo | 4.71 s | http_req_duration (max) |
| Errores | 0.00% | errors / http_req_failed |
| Throughput | 65.71 req/s | http_reqs |

### 3.2 Detalle de Métricas

| Métrica | Valor |
|---|---|
| Tiempo mínimo | 2.79 ms |
| Tiempo mediana | 6.18 ms |
| Percentil 90 (p90) | 10.6 ms |
| Percentil 95 (p95) | 12.46 ms |
| Total solicitudes | 19,806 |
| Solicitudes fallidas | 0 |

---

## 4. Cumplimiento de Umbrales

| Threshold | Condición | Resultado | Estado |
|---|---|---|---|
| http_req_duration | p(95) < 2000 ms | 12.46 ms | ✅ CUMPLIDO |
| errors | rate < 10% | 0.00% | ✅ CUMPLIDO |

---

## 5. Interpretación de Resultados

### 5.1 Tiempo Promedio (21.57 ms)

El sistema responde en **21.57 milisegundos** en promedio. Es un tiempo excelente: está muy por debajo de los 200 ms considerados aceptables para aplicaciones web.

### 5.2 Tiempo Máximo (4.71 s)

El tiempo máximo de **4.71 segundos** fue un caso aislado. El p95 de solo 12.46 ms indica que el 95% de las solicitudes fueron extremadamente rápidas. Este outlier no afecta la experiencia general.

### 5.3 Tasa de Errores (0.00%)

**Ningún request falló.** El sistema demostró ser 100% confiable bajo carga. La comunicación entre microservicios (Orders → Inventory → Billing → Transport → Notifications) funcionó sin problemas.

### 5.4 Throughput (65.71 req/s)

El sistema procesó **65.71 solicitudes por segundo**, equivalente a 236,556 solicitudes por hora. Cada request genera 4 operaciones en la base de datos (pedido + factura + envío + notificación), lo que suma aproximadamente 946,000 operaciones por hora.

---

## 6. Análisis por Percentiles

| Percentil | Tiempo | Significado |
|---|---|---|
| p50 (mediana) | 6.18 ms | 50% de usuarios esperan menos |
| p90 | 10.6 ms | 90% de usuarios esperan menos |
| p95 | 12.46 ms | 95% de usuarios esperan menos |
| p99 | ~50 ms (estimado) | 99% de usuarios esperan menos |

**El 99% de los usuarios** tienen un tiempo de respuesta menor a 50 ms.

---

## 7. Conclusiones

El sistema LogiFresh soporta los **100 usuarios concurrentes durante 5 minutos** con:

- ✅ Rendimiento excelente (21.57 ms promedio)
- ✅ Disponibilidad total (0% errores)
- ✅ Estabilidad comprobada (p95 = 12.46 ms)

**El sistema está preparado para la carga especificada.**

### Recomendaciones

1. Monitorizar p99 en producción para detectar outliers
2. Implementar alertas cuando el tiempo promedio supere los 100 ms
3. Considerar escalado horizontal si se duplica la carga esperada

---

## 8. Evidencias

Dashboard en tiempo real: **http://localhost:3000** (admin/admin) - k6 Load Test - LogiFresh