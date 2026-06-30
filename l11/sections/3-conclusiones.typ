#import "/lib.typ": lab-section

#lab-section(title: "CONCLUSIONES")[
  #show heading: set text(weight: "bold")
  #set par(justify: true)

  == CONCLUSIONES

  + La implementación de un sistema de seguridad integral para LogiMarket Perú S.A.C. demostró que la combinación de cifrado TLS con certificados autofirmados, reverse proxy con Traefik y un stack de monitoreo centralizado proporciona una defensa en profundidad efectiva contra los vectores de ataque identificados en el OWASP API Security Top 10 @owasp2023api.

  + El diseño de la arquitectura de autenticación con MFA, gestión de identidades y tokens JWT, siguiendo las directrices del NIST Cybersecurity Framework @nist2024csf, establece un modelo de confianza cero que mitiga los riesgos de accesos no autorizados y credenciales comprometidas descritos por @bugcrowd2025mfa.

  + El stack de monitoreo y auditoría compuesto por Prometheus, Grafana, Loki y AlertManager permite la detección en tiempo real de incidentes de seguridad, cumpliendo con los principios de registro y auditoría establecidos por @owasp2023api y proporcionando trazabilidad completa de cada request a través del sistema.

  + La evaluación del impacto del cifrado en el rendimiento confirma que TLS 1.3 con aceleración por hardware (AES-NI) añade menos del 1% de overhead en CPUs modernas, refutando la creencia de que el cifrado degrada significativamente el rendimiento @isTLSfast @easecloud2026tls.

  == RECOMENDACIONES

  + Implementar un Identity Provider centralizado como Keycloak o Auth0 para consolidar la autenticación y autorización, siguiendo el patrón de autenticación a nivel de borde (edge-level) recomendado por @owasp2024microservices, eliminando la duplicación de lógica de autenticación en cada microservicio.

  + Migrar los certificados autofirmados a una PKI interna con CA propia para producción, y considerar la integración de Let's Encrypt para ambientes de staging, siguiendo las mejores prácticas de gestión de certificados documentadas por @openssl2026docs.

  + Establecer políticas de retención de datos alineadas con requisitos regulatorios específicos del sector fintech en Perú, y configurar reglas de alerta en Prometheus y Loki adaptadas a los patrones de tráfico de LogiMarket para reducir la tasa de falsos positivos.

  + Implementar rate limiting y circuit breakers a nivel de API Gateway (Traefik) para proteger los microservicios frente a ataques DoS/DDoS, complementando las métricas de monitoreo existentes con métricas de negocio específicas.
]
