#import "@preview/mmdr:0.2.2": mermaid

= Actividad 5: Sistema de Monitoreo y Auditoria

== Diagrama de Flujo del Sistema de Auditoria

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
          PROMTAIL['Promtail - Log discovery']
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
      API -->|stdout JSON logs| PROMTAIL
      TRAEFIK -->|metrics /metrics| PROM
      TRAEFIK -->|access log files| PROMTAIL
      DOCKER -->|cAdvisor metrics| PROM
      PROMTAIL -->|push logs| LOKI
      PROM-->|write time series|TSDB
      TSDB -->|PromQL queries| PANELS_M
      LOKI -->|LogQL queries| PANELS_L
      PANELS_M --> CORREL
      PANELS_L --> CORREL
      PROM -->|evaluate rules| RULES
      RULES -->|firing| AM
      AM -->|route| NOTIFY
  ",
  base-theme: "modern",
  layout: (
    node_spacing: 50,
  ),
)

== Descripcion Tecnica

=== Contexto

El sistema de auditoria esta disenado para la infraestructura de *LogiMarket Peru S.A.C.*, compuesta por un API Go con Traefik como reverse proxy. El objetivo es implementar un sistema centralizado de monitoreo y registro que permita detectar incidentes de seguridad, cumplir con politicas de retencion y proporcionar visibilidad completa sobre el estado del sistema a traves de un dashboard unificado en Grafana.

=== Fuentes de datos

El sistema recopila datos de tres fuentes principales:

- *Go API (puerto 8000):* Expone metricas HTTP en formato Prometheus (`/metrics`) y genera logs estructurados en JSON incluyendo nivel de log, timestamp, metodo HTTP, path, status code y latitud de cada request. Los eventos registrados incluyen: intentos de acceso, operaciones sobre productos y usuarios, y errores de autenticacion.
- *Traefik v3.7:* Como API Gateway, genera access logs detallados con informacion del cliente (IP, User-Agent), ruta solicitada, codigo de respuesta y tiempo de procesamiento. Tambien expone metricas de requests HTTP, conexiones activas y latencia de backend.
- *Docker Engine:* A traves de cAdvisor, se recolectan metricas de consumo de recursos de cada contenedor (CPU, memoria, red, disco), permitiendo detectar anomalias como picos de uso que podrian indicar ataques DoS o fugas de memoria.

=== Capa de recoleccion

- *Prometheus:* Se configura con un intervalo de scrape de 15 segundos. Contacta periodicamente los endpoints `/metrics` del API Go y de Traefik para obtener metricas en formato de texto. Cada muestra incluye labels como `method`, `path`, `status` y `instance`, lo que permite agregar datos por cualquier dimension. Prometheus almacena las series temporales en su base de datos TSDB (Time Series Database) con compresion automatica.
- *Promtail:* Es un agente ligero disenado especificamente para Loki. Descubre automaticamente los archivos de log (stdout de Docker, access logs de Traefik) y los envia a Loki con metadata como el nombre del contenedor, el nivel de log y el servicio de origen. Cada flujo de logs se identifica por un conjunto de labels unicas.

=== Capa de almacenamiento

- *Prometheus TSDB:* Almacena metricas con una retencion de *15 dias*. Este periodo es suficiente para analizar tendencias de corto plazo, detectar picos anomales y generar alertas en tiempo real. Las metricas se compactan automaticamente y se eliminan las series temporales que exceden la ventana de retencion. Prometheus soporta consultas PromQL para calcular tasas (`rate()`), percentiles (`histogram_quantile()`) y agregaciones temporales.
- *Loki:* Base de datos de logs indexada por labels (no por contenido completo), con una retencion de *30 dias* para logs y *7 dias* para el indice invertido. Esta arquitectura permite busquedas eficientes por labels (servicio, nivel, contenedor) sin el overhead de indexar cada palabra. Los logs se almacenan en bloques comprimidos en object storage. Loki soporta consultas LogQL, un lenguaje similar a PromQL disenado para filtrar y procesar flujos de logs.

=== Dashboard unificado en Grafana

Grafana se configura como el punto unico de visualizacion, conectando simultaneamente a Prometheus (para metricas) y Loki (para logs). El dashboard incluye:

- *Paneles de metricas:* Tasa de requests por segundo, histograma de latencia (P50, P95, P99), tasa de errores HTTP (4xx, 5xx), uso de recursos por contenedor y uptime del servicio.
- *Paneles de logs:* Stream de logs en tiempo real con filtros por nivel (INFO, WARN, ERROR), busqueda full-text y visualizacion de logs estructurados JSON. Permite correlacionar un pico de metricas con los logs especificos que lo causaron.
- *Correlacion metricas-logs:* La funcionalidad de "explore" en Grafana permite seleccionar un punto en un grafico de metricas y ver automaticamente los logs correspondientes a ese rango de tiempo, facilitando la investigacion de incidentes.

=== Reglas de alerta

Se definen reglas de alerta basadas en umbrales criticos:

- *Error rate > 5%:* Si mas del 5% de los requests retornan codigo 5xx durante un periodo de 5 minutos, se dispara una alerta indicando un fallo potencial del servicio.
- *Latencia P95 > 2 segundos:* Un aumento sostenido de la latencia del percentil 95 por encima de 2 segundos indica degradacion del rendimiento que afecta la experiencia del usuario.
- *Fallos de autenticacion > 10/min:* Un volumen inusual de errores de autenticacion puede indicar un ataque de fuerza bruta o credenciales comprometidas.

Las alertas pasan por *AlertManager*, que se encarga de agrupar alertas similares, aplicar reglas de enrutamiento (por severidad o servicio) y silenciar notificaciones duplicadas durante ventanas de mantenimiento. Las notificaciones se envian por email, Slack o webhooks configurables.

=== Politicas de retencion

#figure(
  table(
    columns: (auto, auto, auto, 1fr),
    align: (center, center, center, left),
    table.header([*Componente*], [*Tipo de dato*], [*Retencion*], [*Justificacion*]),
    [Prometheus], [Metricas], [15 dias], [Analisis de tendencias de corto plazo, alertas en tiempo real],
    [Loki], [Logs], [30 dias], [Investigacion de incidentes, cumplimiento normativo],
    [Loki], [Indice invertido], [7 dias], [Busquedas recientes eficientes, reduccion de costo],
  ),
  caption: [Politicas de retencion de datos del sistema de auditoria],
) <fig:retention>

=== Eventos registrados

Los eventos auditables capturados por el sistema incluyen:

- *Intentos de acceso:* Requests autenticados y no autenticados, con IP de origen y usuario identificado.
- *Operaciones criticas:* Creacion, actualizacion y eliminacion de recursos (productos, usuarios, pagos).
- *Errores de autenticacion:* Credenciales invalidas, tokens expirados, intentos de acceso con permisos insuficientes.
- *Cambios de configuracion:* Modificaciones a Traefik, variables de entorno del API y cambios en politicas de seguridad.

=== Beneficios

- *Cumplimiento normativo:* Los logs retenidos por 30 dias permiten responder a auditorias de seguridad y requisitos regulatorios.
- *Trazabilidad:* Cada request puede rastrearse desde su origen (IP, usuario) hasta su resultado (status code, latencia), facilitando investigaciones forenses.
- *Deteccion de incidentes:* Las alertas automaticas permiten respuesta inmediata ante comportamientos anormales, reduciendo el tiempo de deteccion (MTTD) y el tiempo de respuesta (MTTR).
