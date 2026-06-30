#import "@preview/mmdr:0.2.2": mermaid

#set par(justify: true)

= Actividad 5: Sistema de Monitoreo y Auditoría

== Diagrama de Flujo del Sistema de Auditoría

#figure(
  box(width: 70%)[
    #mermaid(
      "
        flowchart TD
            subgraph Fuentes['Fuentes de Datos']
                API['Go API - 8000 - /metrics']
                TRAEFIK['Traefik v3.7 - Access logs']
                DOCKER['Docker Engine - cAdvisor']
            end

            subgraph Recoleccion['Capa de Recoleccion']
                PROM['Prometheus - Scrape 15s']
                 ALLOY['Alloy - Log discovery']
            end

            subgraph Almacenamiento['Capa de Almacenamiento']
                TSDB['Prometheus TSDB - Retencion 15d']
                LOKI['Loki - Retencion 30d - Indice 7d']
            end

            subgraph Dashboard['Grafana - Dashboard Unificado']
                PANELS_M['Paneles de Metricas']
                PANELS_L['Paneles de Logs']
                CORREL['Correlacion Metricas y Logs']
            end

            subgraph Alertas['Sistema de Alertas']
                RULES['Reglas de Alerta']
                AM['AlertManager']
                NOTIFY['Notificaciones - Email y Slack']
            end

            API -->|metrics /metrics| PROM
            API -->|stdout JSON logs| ALLOY
            TRAEFIK -->|metrics /metrics| PROM
            TRAEFIK -->|access log files| ALLOY
            DOCKER -->|cAdvisor metrics| PROM
            ALLOY -->|push logs| LOKI
            PROM-->|write time series|TSDB
            TSDB -->|PromQL queries| PANELS_M
            LOKI -->|LogQL queries| PANELS_L
            PANELS_M --> CORREL
            PANELS_L --> CORREL
            PROM -->|evaluate rules| RULES
            RULES -->|firing| AM
            AM -->|route| NOTIFY
        ",
    )
  ],
  caption: [Arquitectura del sistema de observabilidad con recolección, almacenamiento, visualización y alertas.],
)

== Descripción Técnica

=== Contexto

El sistema de auditoría está diseñado para la infraestructura de LogiMarket Perú S.A.C., compuesta por un API Go con Traefik como reverse proxy. El objetivo es implementar un sistema centralizado de monitoreo y registro que permita detectar incidentes de seguridad, cumplir con políticas de retención y proporcionar visibilidad completa sobre el estado del sistema a través de un dashboard unificado en Grafana. Este diseño sigue las recomendaciones del NIST Cybersecurity Framework para las funciones de Detect y Respond @nist2024csf.

=== Fuentes de datos

El sistema recopila datos de tres fuentes principales:

- *Go API (puerto 8000):* Expone métricas HTTP en formato Prometheus (`/metrics`) y genera logs estructurados en JSON incluyendo nivel de log, timestamp, método HTTP, path, status code y latencia de cada request. Los eventos registrados incluyen: intentos de acceso, operaciones sobre productos y usuarios, y errores de autenticación. Este enfoque de métricas y logs estructurados es consistente con las prácticas de observabilidad documentadas por @prometheus2026docs.
- *Traefik v3.7:* Como API Gateway, genera access logs detallados con información del cliente (IP, User-Agent), ruta solicitada, código de respuesta y tiempo de procesamiento. También expone métricas de requests HTTP, conexiones activas y latencia de backend @traefik2026docs.
- *Docker Engine:* A través de cAdvisor, se recolectan métricas de consumo de recursos de cada contenedor (CPU, memoria, red, disco), permitiendo detectar anomalías como picos de uso que podrían indicar ataques DoS o fugas de memoria.

=== Capa de recolección

- *Prometheus:* Se configura con un intervalo de scrape de 15 segundos. Contacta periódicamente los endpoints `/metrics` del API Go y de Traefik para obtener métricas en formato de texto. Cada muestra incluye labels como `method`, `path`, `status` y `instance`, lo que permite agregar datos por cualquier dimensión. Prometheus almacena las series temporales en su base de datos TSDB (Time Series Database) con compresión automática @prometheus2026docs.
- *Grafana Alloy:* Agente unificado de recolección de datos que reemplaza a Promtail. Descubre automáticamente los contenedores Docker a través del socket, recolecta logs de stdout/stderr y los envía a Loki con metadata como el nombre del contenedor, el servicio de compose y el nivel de log. Utiliza el lenguaje de configuración River para definir pipelines de procesamiento que incluyen parsing Docker, extracción de labels y filtrado @grafanaloki2026docs.

=== Capa de almacenamiento

- *Prometheus TSDB:* Almacena métricas con una retención de 15 días. Este periodo es suficiente para analizar tendencias de corto plazo, detectar picos anómalos y generar alertas en tiempo real. Las métricas se compactan automáticamente y se eliminan las series temporales que exceden la ventana de retención. Prometheus soporta consultas PromQL para calcular tasas (`rate()`), percentiles (`histogram_quantile()`) y agregaciones temporales @prometheus2026docs.
- *Loki:* Base de datos de logs indexada por labels (no por contenido completo), con una retención de 30 días para logs y 7 días para el índice invertido. Esta arquitectura permite búsquedas eficientes por labels (servicio, nivel, contenedor) sin el overhead de indexar cada palabra. Los logs se almacenan en bloques comprimidos en object storage. Loki soporta consultas LogQL, un lenguaje similar a PromQL diseñado para filtrar y procesar flujos de logs @grafanaloki2026docs.

=== Dashboard unificado en Grafana

Grafana se configura como el punto único de visualización, conectando simultáneamente a Prometheus (para métricas) y Loki (para logs). El dashboard incluye:

- *Paneles de métricas:* Tasa de requests por segundo, histograma de latencia (P50, P95, P99), tasa de errores HTTP (4xx, 5xx), uso de recursos por contenedor y uptime del servicio.
- *Paneles de logs:* Stream de logs en tiempo real con filtros por nivel (INFO, WARN, ERROR), búsqueda full-text y visualización de logs estructurados JSON. Permite correlacionar un pico de métricas con los logs específicos que lo causaron.
- *Correlación métricas-logs:* La funcionalidad de "explore" en Grafana permite seleccionar un punto en un gráfico de métricas y ver automáticamente los logs correspondientes a ese rango de tiempo, facilitando la investigación de incidentes @grafanaloki2026docs.

=== Reglas de alerta

Se definen reglas de alerta basadas en umbrales críticos:

- *Error rate > 5%:* Si más del 5% de los requests retornan código 5xx durante un periodo de 5 minutos, se dispara una alerta indicando un fallo potencial del servicio.
- *Latencia P95 > 2 segundos:* Un aumento sostenido de la latencia del percentil 95 por encima de 2 segundos indica degradación del rendimiento que afecta la experiencia del usuario.
- *Fallos de autenticación > 10/min:* Un volumen inusual de errores de autenticación puede indicar un ataque de fuerza bruta o credenciales comprometidas @owasp2023api.

Las alertas pasan por AlertManager, que se encarga de agrupar alertas similares, aplicar reglas de enrutamiento (por severidad o servicio) y silenciar notificaciones duplicadas durante ventanas de mantenimiento. Las notificaciones se envían por email, Slack o webhooks configurables.

=== Políticas de retención

#figure(
  table(
    columns: (auto, auto, auto, 1fr),
    align: (center, center, center, left),
    stroke: 0.5pt,
    inset: (x: 6pt, y: 5pt),
    fill: (x, y) => if y == 0 { rgb("#E8E8E8") } else if calc.odd(y) { rgb("#F9F9F9") } else { none },
    table.header([*Componente*], [*Tipo de dato*], [*Retención*], [*Justificación*]),
    [Prometheus], [Métricas], [15 días], [Análisis de tendencias de corto plazo, alertas en tiempo real],
    [Loki], [Logs], [30 días], [Investigación de incidentes, cumplimiento normativo],
    [Loki], [Índice invertido], [7 días], [Búsquedas recientes eficientes, reducción de costo],
  ),
  caption: [Políticas de retención de datos del sistema de auditoría],
) <fig:retention>

=== Eventos registrados

Los eventos auditables capturados por el sistema incluyen:

- *Intentos de acceso:* Requests autenticados y no autenticados, con IP de origen y usuario identificado.
- *Operaciones críticas:* Creación, actualización y eliminación de recursos (productos, usuarios, pagos).
- *Errores de autenticación:* Credenciales inválidas, tokens expirados, intentos de acceso con permisos insuficientes @owasp2023api.
- *Cambios de configuración:* Modificaciones a Traefik, variables de entorno del API y cambios en políticas de seguridad.

=== Beneficios

- *Cumplimiento normativo:* Los logs retenidos por 30 días permiten responder a auditorías de seguridad y requisitos regulatorios, alineándose con las funciones Identify y Protect del NIST CSF @nist2024csf.
- *Trazabilidad:* Cada request puede rastrearse desde su origen (IP, usuario) hasta su resultado (status code, latencia), facilitando investigaciones forenses.
- *Detección de incidentes:* Las alertas automáticas permiten respuesta inmediata ante comportamientos anormales, reduciendo el tiempo de detección (MTTD) y el tiempo de respuesta (MTTR).
