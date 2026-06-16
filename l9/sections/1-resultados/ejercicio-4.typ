#import "/lib.typ": code-block

= Actividad 4: Prueba de Rendimiento

Se ejecutó una prueba de rendimiento utilizando k6 para simular 100 usuarios concurrentes durante 5 minutos, solicitando el endpoint `POST /orders` del servicio de Pedidos.

== Configuración de la Prueba

#let gray-header = rgb("#D9D9D9")
#table(
  columns: (0.5fr, 1fr),
  stroke: black + 0.4pt,
  inset: 0.3em,
  table.header(
    repeat: false,
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Parámetro]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Valor]],
  ),
  [Herramienta], [k6],
  [Endpoint bajo prueba], [POST /orders (puerto 8001)],
  [Usuarios virtuales (VUs)], [100],
  [Tipo de prueba], [Carga constante (constant-vus)],
  [Duración], [5 minutos],
  [Threshold de latencia], [`http_req_duration p(95) < 2000 ms`],
  [Threshold de errores], [`errors rate < 10%`],
)

== Payload de Solicitud

#code-block(
  file: "l9/src/k6/load-test.js",
  snippet: "load-test-payload",
  lang: "javascript",
  prefix: "//",
)

== Resultados Obtenidos

=== Resumen de Métricas

#table(
  columns: (0.5fr, 0.5fr, 1fr),
  stroke: black + 0.4pt,
  inset: 0.3em,
  table.header(
    repeat: false,
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Métrica Solicitada]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Resultado Obtenido]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Descripción]],
  ),
  [Tiempo promedio], [21.57 ms], [http_req_duration promedio],
  [Tiempo máximo], [4.71 s], [http_req_duration máximo],
  [Errores], [0.00%], [Tasa de solicitudes fallidas],
  [Throughput], [65.71 req/s], [Solicitudes procesadas por segundo],
)

=== Detalle por Percentiles

#table(
  columns: (0.5fr, 0.5fr, 1fr),
  stroke: black + 0.4pt,
  inset: 0.3em,
  table.header(
    repeat: false,
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Percentil]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Tiempo]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Significado]],
  ),
  [p50 (mediana)], [6.18 ms], [50% de usuarios esperan menos que este tiempo],
  [p90], [10.6 ms], [90% de usuarios esperan menos que este tiempo],
  [p95], [12.46 ms], [95% de usuarios esperan menos que este tiempo],
)

La distribución de percentiles muestra que el sistema mantiene tiempos de respuesta consistentes incluso bajo carga pesada. La brecha significativa entre el p95 (12.46 ms) y el máximo (4.71 s) indica que los outliers son excepcionales.

=== Cumplimiento de Umbrales

#table(
  columns: (0.8fr, 0.8fr, 0.8fr, 0.6fr),
  stroke: black + 0.4pt,
  inset: 0.3em,
  table.header(
    repeat: false,
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Threshold]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Condición]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Resultado]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Estado]],
  ),
  [`http_req_duration`], [p(95) < 2000 ms], [12.46 ms], [CUMPLIDO],
  [`errors`], [rate < 10%], [0.00%], [CUMPLIDO],
)

== Interpretación de Resultados

El tiempo promedio de 21.57 milisegundos es excelente, muy por debajo de los 200 ms considerados aceptables para aplicaciones web interactivas. Incluso considerando que cada request genera múltiples operaciones en la base de datos (reserva de stock, creación de factura, asignación de envío, encolado de notificación), el tiempo total se mantiene en rangos aceptables.

La tasa de errores del 0.00% demuestra que el sistema es 100% confiable bajo carga sostenida. La comunicación entre los cinco microservicios funcionó sin interrupciones durante los 5 minutos completos de prueba, procesando un total de 19,806 solicitudes.

El throughput de 65.71 solicitudes por segundo equivale a aproximadamente 236,556 solicitudes por hora.

== Evidencias de Ejecución

#grid(
  columns: (1fr, 1fr),
  align: (horizon, horizon),
  figure(
    image("../../img/lab/k6/k6-start.png", width: 60%),
    caption: [Inicio de la prueba de carga: 100 VUs durante 5 minutos],
  ),
  figure(
    image("../../img/lab/k6/k6-end.png", width: 60%),
    caption: [Finalización: resumen de métricas, 0% errores, 65.71 req/s],
  ),
)
