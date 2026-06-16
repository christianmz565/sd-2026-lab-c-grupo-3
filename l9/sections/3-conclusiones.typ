#import "/lib.typ": lab-section

#lab-section(title: "CONCLUSIONES")[
  #show heading: set text(weight: "bold")
  #set par(justify: true)

  == CONCLUSIONES

  + La matriz de riesgos identificó 7 amenazas (3 críticas, 3 altas, 1 media) con soluciones técnicas específicas: bloqueo pesimista `SELECT FOR UPDATE` para inventario, procesamiento asíncrono con HTTP 202 para lentitud, e idempotencia con `X-Idempotency-Key` para duplicados. Cada riesgo fue validado con pruebas funcionales e de integración.

  + Las pruebas funcionales alcanzaron 95% de efectividad (9/10 PASS), y las pruebas de integración confirmaron que los mecanismos de concurrencia, idempotencia y rollback funcionan correctamente. La prueba de rendimiento validó 100 VUs/5min con 21.57 ms promedio y 0% errores, demostrando escalabilidad de la arquitectura asíncrona.

  + La estrategia de mejora propuesta (CI/CD automatizado, observabilidad con Prometheus/Grafana, Circuit Breaker y monitoreo continuo) establece las bases para transformar el sistema de una arquitectura funcional a una plataforma resiliente preparada para la expansión nacional de LogiFresh.

  == RECOMENDACIONES

  + Implementar pipeline CI/CD con pruebas de integración automatizadas en cada commit, y desplegar stack Prometheus + Grafana con Golden Signals (latencia, tráfico, errores, saturación) y alertas automáticas.

  + Adoptar el patrón Circuit Breaker en las llamadas síncronas entre servicios para prevenir fallos en cascada, con activación después de 5 fallos consecutivos y fallbacks configurados.

  + Implementar distributed tracing con OpenTelemetry para correlacionar solicitudes a través de microservicios, y definir SLOs de negocio (tasa de pedidos exitosos, tiempo de entrega) con alertas configuradas.
]
