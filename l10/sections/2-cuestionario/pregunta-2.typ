#set par(justify: true)

= Pregunta 2: Impactos de la Replicación Síncrona Universal

No se recomienda utilizar replicación síncrona de manera universal para todos los sistemas empresariales. Aunque proporciona consistencia inmediata y evita la pérdida de datos, sus consecuencias negativas en otros atributos del sistema son significativas:

1. Impactos Técnicos \
   - Latencia Acumulada \
     En sistemas distribuidos geográficamente, la velocidad de confirmación de una escritura local queda acoplada al tiempo de viaje de ida y vuelta (RTT) de la red WAN hacia el nodo réplica más lento. Esto añade decenas o cientos de milisegundos a transacciones que durarían menos de 5 ms.
   - Riesgo de Disponibilidad \
     Si se configura una replicación síncrona estricta y el nodo secundario cae o sufre cortes de red, las escrituras en el nodo principal se bloquean indefinidamente para preservar la consistencia, dejando al negocio inoperativo, como se advierte en @postgres2026ha.
   - Limitación del Throughput \
     El rendimiento transaccional (TPS) del clúster se reduce al nivel del nodo réplica más lento o con menor rendimiento de hardware, de acuerdo con @kleppmann2017designing.

2. Impactos Económicos \
   - Costos de Conectividad Extremos \
     Mantener enlaces de red dedicados, redundantes y de ultra baja latencia entre regiones geográficas para evitar que la replicación síncrona estrangule al sistema tiene costos de proveedor extremadamente elevados.
   - Sobredimensionamiento de Hardware \
     Las réplicas síncronas deben contar con especificaciones idénticas de CPU y almacenamiento (SSD NVMe, alta capacidad IOPS) que el primario para no retrasar el procesamiento del WAL.

3. Impactos Operativos \
   - Sensibilidad a Fallas Menores \
     Fluctuaciones temporales de red que pasarían desapercibidas con replicación asíncrona causan micro-cortes y lentitud generalizada en la aplicación de cara al cliente.
   - Complejidad de Mantenimiento \
     Realizar parches de seguridad o actualizaciones de software requiere planes de mantenimiento altamente complejos para evitar detener el flujo transaccional.
