#import "/lib.typ": lab-section

#lab-section(title: "CUESTIONARIO")[
  #show heading: set text(weight: "bold")
  #set par(justify: true)

  == 1. En una arquitectura distribuida, ¿por qué aumentar la cobertura de pruebas unitarias no garantiza necesariamente la calidad global del sistema? Analice el papel de las interacciones entre servicios y proponga mecanismos complementarios de aseguramiento de la calidad.

  Las pruebas unitarias validan la lógica interna de cada componente de forma aislada, pero en una arquitectura distribuida la calidad del sistema depende de las interacciones entre servicios, que están expuestas a fallos de red, condiciones de carrera, incompatibilidad de esquemas y dependencias externas que las unitarias no detectan @martinfowler2012testpyramid. En LogiFresh, una unitaria puede verificar que el cálculo de descuento es correcto, pero no que el servicio de Facturación recibe ese descuento cuando hay latencia de red o timeout. Los mecanismos complementarios recomendados son: pruebas de integración que validen la comunicación real entre pares de servicios, contract testing para verificar compatibilidad de contratos API, pruebas de resiliencia que simulen fallos de red y latencia artificial, y chaos engineering para inyectar fallos controlados en producción y descubrir debilidades que las pruebas pre-producción no revelan.

  == 2. Si una organización dispone de recursos limitados para pruebas, ¿qué criterios utilizaría para priorizar las pruebas funcionales, de integración y de rendimiento? Justifique su decisión considerando el impacto en el negocio y el riesgo técnico.

  La priorización debe seguir el principio de risk-oriented testing @istqb2023, asignando recursos a las pruebas que maximizan la reducción de riesgo por unidad de esfuerto. Los criterios son: impacto en negocio (funcionalidades críticas de ingresos primero), frecuencia de uso (operaciones de alta demanda primero), complejidad de integración (puntos de unión entre servicios primero) y costo del fallo (errores con pérdida financiera directa primero). En LogiFresh, la distribución recomendada es: 40% para pruebas funcionales críticas (pedidos, facturación), 35% para integración (Pedido↔Inventario, Pedido↔Facturación), 15% para rendimiento (periódicas, no en cada build) y 10% para unitarias (lógica de negocio compleja).

  == 3. Imagine que las pruebas muestran un excelente desempeño bajo carga, pero los usuarios continúan reportando fallos intermitentes en producción. ¿Qué hipótesis investigaría y qué evidencias adicionales recopilaría para explicar esta discrepancia?

  Esta discrepancia puede explicarse por: (1) diferencias de entorno, donde datos reales, infraestructura compartida y carga impredecible difieren de las pruebas controladas; (2) fallos de estado transitorio, donde servicios quedan en estados inconsistentes por fallos parciales; (3) condiciones de carrera no reproducibles, donde patrones de acceso caóticos en producción generan conflictos que las pruebas no simulan; (4) dependencias externas como DNS, disco o servicios de correo que no se prueban directamente; y (5) acumulación de deuda técnica como fugas de memoria o pools de conexiones que se agotan gradualmente @kleppmann2017designing. La evidencia clave incluye: logs de estados de pedidos en producción, métricas de bloqueo de base de datos, tendencias de uso de memoria y CPU, y distributed tracing con OpenTelemetry para rastrear solicitudes a través de todos los microservicios.
]
