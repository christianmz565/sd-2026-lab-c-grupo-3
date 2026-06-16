= Actividad 5: Estrategia de Mejora

Se proponen cinco acciones estratégicas para mejorar la calidad del sistema distribuido LogiFresh, considerando automatización de pruebas, observabilidad, balanceo de carga, Circuit Breaker, monitoreo continuo e integración continua @newman2021building.

== 1. Automatización de Pruebas con CI/CD

Se debe implementar un pipeline de integración continua que ejecute automáticamente las pruebas unitarias, de integración y de contrato antes de cada despliegue @humble2010continuous. Actualmente las pruebas se ejecutan manualmente, lo que retrasa la detección de defectos y aumenta el riesgo de regresiones. El pipeline propuesto incluye: pruebas unitarias en cada commit para validar la lógica individual de cada microservicio, pruebas de integración después de las unitarias para validar la comunicación entre servicios y pruebas de contrato para verificar que los contratos API entre servicios no se rompen con cambios en el esquema

== 2. Observabilidad con Prometheus y Grafana

Se debe implementar un stack de observabilidad que permita entender el estado interno del sistema a partir de sus salidas externas, superando el monitoreo tradicional de "arriba/abajo" @glukhov2026observability. El sistema actual carece de visibilidad sobre el comportamiento interno de los microservicios, lo que impossibilita identificar cuellos de botella o detectar anomalías.

#figure(
  image("../../img/lab/grafana/dashboard.png", width: 45%),
  caption: [Dashboard de Grafana mostrando métricas en tiempo real durante la prueba de carga con k6: latencia, throughput y estado de servicios],
)

== 3. Balanceo de Carga y Escalado Horizontal

Se debe implementar balanceo de carga entre réplicas de cada microservicio para distribuir el tráfico de forma uniforme y evitar que un solo nodo se convierta en cuello de botella @richardson2018microservices. Actualmente cada microservicio se ejecuta como una sola instancia, lo que representa un punto único de fallo, el algoritmo recomendado es Least Connections, que dirige las solicitudes al nodo con menor cantidad de conexiones activas.

== 4. Circuit Breaker para Tolerancia a Fallos

Se debe implementar el patrón Circuit Breaker en las llamadas entre microservicios para prevenir fallos en cascada @circuitbreaker2026. Cuando un microservicio falla o responde con latencia elevada, las llamadas síncronas acumulan timeouts que pueden agotar los hilos del sistema y provocar el colapso de servicios dependientes. El Circuit Breaker opera con tres estados: Closed, Open y Half-Open, se recomienda activar el Circuit Breaker después de 5 fallos consecutivos o cuando la tasa de error supere el 50% en una ventana de 60 segundos.

== 5. Monitoreo Continuo e Integración Continua

Se debe establecer un ciclo de mejora continua que combine monitoreo en producción, retroalimentación automática y despliegues seguros @humble2010continuous. La calidad del software no es un estado estático sino un proceso continuo. El monitoreo en producción debe mantener dashboards de Grafana actualizados con métricas de percentiles de latencia, tasas de error, throughput y saturación de recursos. Se deben revisar semanalmente las tendencias de métricas para identificar degradaciones graduales.
