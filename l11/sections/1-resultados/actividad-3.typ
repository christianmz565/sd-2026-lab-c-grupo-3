#import "/lib.typ": code-block

#set par(justify: true)

= Actividad 3: Seguridad de Comunicaciones

Se implementa una demostración completa de seguridad de comunicaciones para LogiMarket Perú S.A.C., incluyendo generación de certificados TLS, configuración de canal HTTPS, despliegue de API con métricas de seguridad y stack de monitoreo y auditoría. El sistema utiliza Docker Compose para orquestar todos los componentes.

== Generación de Certificados TLS Autofirmados

Se genera un certificado autofirmado RSA de 4096 bits utilizando OpenSSL con Subject Alternative Names (SAN) para múltiples dominios locales. El script #raw("generate-certs.sh") automatiza el proceso de generación:

#code-block(file: "l11/src/scripts/generate-certs.sh", snippet: "cert-generation", lang: "bash", prefix: "#")

El certificado generado incluye los campos #raw("keyUsage=digitalSignature,keyEncipherment") y #raw("extendedKeyUsage=serverAuth,clientAuth"), permitiendo su uso tanto para servidor como para cliente. Los SAN incluyen #raw("DNS:localhost"), #raw("DNS:traefik.localhost"), #raw("IP:127.0.0.1") e #raw("IP:::1") para compatibilidad completa con los diferentes endpoints de acceso.

== API Go con Métricas de Seguridad

La aplicación principal es un servidor HTTP en Go que implementa un middleware de métricas para registrar cada request con su nivel de severidad (info, warn, error), método HTTP, path, status code y latencia. Este enfoque permite correlacionar métricas de rendimiento con eventos de seguridad:

#code-block(file: "l11/src/app/main.go", snippet: "metrics-middleware", lang: "go", prefix: "//")

El endpoint #raw("/metrics") expone métricas en formato Prometheus incluyendo #raw("http_requests_total"), #raw("http_request_errors_total"), #raw("http_request_duration_seconds") (histograma) y #raw("process_uptime_seconds"), permitiendo el monitoreo continuo de la salud del servicio.

Los endpoints disponibles incluyen rutas protegidas para productos y usuarios, así como un endpoint de prueba de errores 500:

#code-block(file: "l11/src/app/main.go", snippet: "endpoints", lang: "go", prefix: "//")

== Configuración de Traefik Reverse Proxy

Traefik v3.7 funciona como API Gateway y reverse proxy, implementando redirección automática HTTP a HTTPS, terminación TLS y descubrimiento dinámico de servicios a través del Docker socket. La configuración incluye entrypoints para HTTP (puerto 80), HTTPS (puerto 443) y el dashboard de Traefik (puerto 8080):

#code-block(file: "l11/src/traefik/traefik.yml", snippet: "entrypoints", lang: "yaml", prefix: "#")

La redirección HTTP→HTTPS se configura a nivel de entrypoint con #raw("permanent: true"), garantizando que todas las solicitudes no cifradas sean redirigidas automáticamente al canal seguro. El certificado TLS se carga dinámicamente desde el volumen #raw("/certs/") montado como read-only.

== Orquestación con Docker Compose

El stack completo se despliega mediante Docker Compose con dos servicios principales: Traefik y la aplicación Go, conectados a través de una red Docker dedicada:

#code-block(file: "l11/src/compose.yaml", snippet: "services", lang: "yaml", prefix: "#")

Los labels de Traefik en cada contenedor definen las reglas de enrutamiento: #raw("Host(`localhost`)") para la aplicación y #raw("Host(`traefik.localhost`)") para el dashboard, ambos en el entrypoint #raw("websecure") (HTTPS) con TLS habilitado.

== Stack de Monitoreo y Auditoría

=== Prometheus - Recolección de Métricas

Prometheus se configura con un intervalo de scrape de 15 segundos, recolectando métricas del API Go y de Traefik:

#code-block(file: "l11/src/monitoring/prometheus/prometheus.yml", snippet: "scrape-configs", lang: "yaml", prefix: "#")

=== Grafana Alloy - Recolección de Logs

Alloy descubre automáticamente los contenedores Docker y procesa los logs estructurados en JSON, extrayendo el nivel de log como label para facilitar el filtrado en Loki:

#code-block(file: "l11/src/monitoring/alloy/alloy-config.river", snippet: "log-discovery", lang: "river", prefix: "//")

=== Evidencias de Implementación

#grid(
  columns: (1fr, 1fr),
  align: horizon,
  [
    #figure(
      image("../../img/https-site-localhost.png", width: 95%),
      caption: [Acceso HTTPS a la API en #raw("https://localhost/api/products")],
    )
  ],
  [
    #figure(
      image("../../img/traefik-config-http-https-redirect.png", width: 95%),
      caption: [Dashboard de Traefik mostrando routers HTTPS configurados],
    )
  ],
)

#grid(
  columns: (1fr, 1fr),
  align: horizon,
  [
    #figure(
      image("../../img/grafana-traefik-dashboard.png", width: 95%),
      caption: [Dashboard de Traefik en Grafana con métricas de requests por servicio y status code],
    )
  ],
  [
    #figure(
      image("../../img/grafana-traefik-logs.png", width: 95%),
      caption: [Panel de logs de Traefik en Loki con correlación temporal],
    )
  ],
)

#figure(
  image("../../img/grafana-monitoring.png", width: 50%),
  caption: [Dashboard unificado de Grafana con métricas de requests, latencia, errores y logs],
) <fig-grafana-monitoring>

Las capturas demuestran que el sistema opera correctamente: la aplicación Go responde vía HTTPS con datos JSON, Traefik gestiona el enrutamiento y la terminación TLS, y Grafana muestra un dashboard unificado que correlaciona métricas de Prometheus con logs de Loki, proporcionando visibilidad completa sobre el estado de seguridad del sistema.
