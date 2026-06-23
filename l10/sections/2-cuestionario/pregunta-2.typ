#set par(justify: true)

= Pregunta 2: ¿Es recomendable utilizar replicación síncrona para todos los sistemas empresariales? Analice los posibles impactos técnicos, económicos y operativos de esa decisión.

No es recomendable utilizar replicación síncrona para todos los sistemas empresariales. Aunque garantiza consistencia inmediata entre nodos, sus impactos negativos son significativos en múltiples dimensiones.

En el ámbito técnico, la latencia de red WAN típica entre centros de datos geográficamente dispersos (aproximadamente 80 a 120 milisegundos) se suma a cada operación de escritura, degradando de forma considerable el rendimiento del sistema. Si el nodo secundario deja de estar disponible, las escrituras en el primario se bloquean indefinidamente @postgres2026ha.

En el ámbito económico, la replicación síncrona universal requiere enlaces de red dedicados de ultra baja latencia y hardware idéntico en todas las réplicas para evitar cuellos de botella asimétricos, lo que incrementa significativamente los costos operativos y de infraestructura.

En el ámbito operativo, las fluctuaciones normales de la red causan micro-interrupciones que son perceptibles por el usuario final. Además, el mantenimiento de software en los nodos requiere planes altamente complejos para evitar interrumpir la sincronización activa. La replicación síncrona universal convierte al nodo más lento del sistema en el cuello de botella de toda la operación @kleppmann2017designing.
