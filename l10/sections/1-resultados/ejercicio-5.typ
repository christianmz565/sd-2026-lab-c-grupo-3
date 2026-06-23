#set par(justify: true)

= Actividad 5: Evaluación Crítica y Propuesta de Mejoras

Para maximizar la robustez, escalabilidad y resiliencia de la infraestructura de base de datos distribuida de FedEx Perú, se proponen tres mejoras tecnológicas avanzadas que superan las limitaciones de la replicación física estándar, fundamentadas en patrones de diseño para sistemas de alta disponibilidad expuestos por @kleppmann2017designing:

== 1. Orquestación y Automatización del Failover con Patroni y etcd
El esquema actual de failover requiere intervención manual o un script que ejecute pg_promote(). Esto presenta el riesgo de Split-Brain (donde dos nodos creen ser el primario a la vez) y genera tiempos de inactividad mientras se diagnostica el fallo.
- Solución \
  Implementar Patroni, un gestor de alta disponibilidad basado en plantillas para PostgreSQL. Patroni utiliza un almacén de valor-clave distribuido (DCS) como etcd o Consul para rastrear el estado del clúster mediante consenso (algoritmo Raft).
- Impacto \
  Si el nodo de Lima falla, Patroni detecta la pérdida de conectividad en segundos, selecciona automáticamente al standby más actualizado (p. ej., Bogotá), lo promueve y reconfigura los standbys restantes para seguir al nuevo líder sin intervención humana, reduciendo el RTO (Recovery Time Objective) a menos de 10 segundos.

== 2. Balanceo de Carga y Enrutamiento Inteligente (Read/Write Splitting) con HAProxy y PgBouncer
Actualmente, las aplicaciones cliente deben conocer explícitamente a qué dirección IP y puerto conectarse según si desean leer o escribir. Esto aumenta el acoplamiento y dificulta la conmutación por error.
- Solución \
  Introducir una capa de proxy de base de datos compuesta por PgBouncer (para la gestión eficiente del pool de conexiones en cada nodo) y HAProxy como balanceador de carga central.
- Impacto \
  Las peticiones de la aplicación llegan a un único punto de entrada. HAProxy inspecciona las conexiones y redirige los flujos de escritura (puerto transaccional) al Primary actual, mientras distribuye las consultas de lectura (SELECT) mediante round-robin entre los nodos Standby saludables más cercanos, optimizando las latencias locales.

== 3. Estrategia Híbrida de Replicación con Replicación Síncrona Selectiva
La replicación completamente asíncrona expone a la empresa a pérdidas de datos recientes en fallos imprevistos, mientras que la síncrona degrada el rendimiento de todas las sedes debido a la latencia de la red WAN (~80-120ms).
- Solución \
  Configurar un esquema híbrido utilizando los parámetros de confirmación síncrona selectiva de PostgreSQL (synchronous_commit) como se detalla en @postgres2026ha. Se define a Bogotá como un standby síncrono potencial y a los demás como asíncronos.
- Impacto \
  Para transacciones de alta criticidad (como el cobro e inserción de un nuevo Pedido), la aplicación establece el parámetro para forzar que la transacción se escriba en Lima y se confirme en Bogotá antes de retornar éxito al cliente. Para actualizaciones de temperatura o telemetría GPS, se desactiva la confirmación síncrona, garantizando baja latencia y escrituras locales rápidas sin comprometer la consistencia de los datos críticos.
