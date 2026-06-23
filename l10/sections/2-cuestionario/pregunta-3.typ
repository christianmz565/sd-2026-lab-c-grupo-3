#set par(justify: true)

= Pregunta 3: Estrategia de Replicación para Desastres Regionales en FedEx Perú

Como Arquitecto de Software de FedEx Perú, implementaría una Estrategia Híbrida Multi-Región con Replicación Síncrona Selectiva y Failover Automático por Consenso, basada en los principios de diseño de tolerancia a fallos discutidos por @kleppmann2017designing y las capacidades de PostgreSQL detalladas por @postgres2026ha. Las especificaciones del diseño arquitectónico serían las siguientes:

1. Topología de Nodos \
   - Nodo Primario (Lima) \
     Procesa todas las escrituras y cambios transaccionales del sistema central.
   - Standby Síncrono (Bogotá) \
     Configurado en modo de replicación física síncrona. La menor latencia de red WAN (~80ms) permite que la confirmación síncrona selectiva (synchronous_commit = on para tablas de Inventarios y Pedidos) sea viable. Esto garantiza un RPO = 0 (Recovery Point Objective) para los datos comerciales más críticos.
   - Standbys Asíncronos (Santiago y Ciudad de México) \
     Reciben actualizaciones mediante WAL streaming asíncrono. Absorben las consultas pesadas de lectura de sus respectivas regiones y sirven como nodos de contingencia de segundo nivel.

2. Mecanismo de Conmutación por Error (Failover) \
   - Integración de Patroni junto con un clúster distribuido de etcd (desplegado en Lima, Bogotá y Santiago para mantener quórum e impedir el Split-Brain).
   - Ante un desastre regional en Perú (p. ej., terremoto, caída total de energía en el data center de Lima):
     - El clúster etcd detecta la pérdida de conectividad de Lima.
     - Bogotá (al ser el standby síncrono y poseer el WAL idéntico al primario) es promovido automáticamente a Primario por Patroni.
     - Los balanceadores de carga globales (mediante DNS dinámico o Anycast) desvían el tráfico de escrituras hacia Bogotá.
     - Los nodos de Santiago y México se reconectan automáticamente a Bogotá para recibir su flujo de replicación.

3. Justificación del Diseño \
   - Tolerancia a Desastres \
     El sistema tolera la pérdida total de la sede principal (Lima) garantizando que no se perderá ningún pedido facturado ni registro crítico de inventario, con un tiempo de recuperación operativa (RTO) menor a 30 segundos.
   - Rendimiento Balanceado \
     Al limitar la replicación síncrona únicamente a la conexión Lima-Bogotá (la de menor latencia) y solo para transacciones selectivas, no se estrangula la experiencia del usuario general en el resto del continente, manteniendo una alta disponibilidad.
