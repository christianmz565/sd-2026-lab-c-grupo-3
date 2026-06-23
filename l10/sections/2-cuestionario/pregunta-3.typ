#set par(justify: true)

= Pregunta 3: Si usted fuera el arquitecto de software de FedEx Perú ¿qué estrategia de replicación implementaría para garantizar continuidad del negocio ante desastres regionales y por qué?

Como arquitecto de software de FedEx Perú, implementaría una estrategia híbrida multi-región con replicación síncrona selectiva @kleppmann2017designing @postgres2026ha.

La topología de nodos se organiza de la siguiente manera. El nodo primario se ubica en Lima y procesa todas las escrituras transaccionales de la región. Un standby síncrono se despliega en Bogotá con replicación física síncrona y la configuración synchronous_commit activada para las tablas criticas de inventarios y pedidos, garantizando un RPO igual a cero para estos datos. Los standbys asíncronos en Santiago y Ciudad de México utilizan streaming de WAL de forma asíncrona y absorben las consultas de lectura pesadas sin impactar la latencia de escritura del nodo primario.

El mecanismo de failover se basa en Patroni con un clúster de etcd distribuido entre Lima, Bogotá y Santiago para alcanzar consenso por quórum y prevenir escenarios de split-brain. Ante un desastre regional en Perú, etcd detecta la pérdida de conectividad, Bogotá es promovido automáticamente al rol de primario, el DNS dinámico desvía el tráfico de clientes hacia Bogotá, y los standbys restantes se reconectan al nuevo líder.
