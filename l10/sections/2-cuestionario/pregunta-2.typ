#set par(justify: true)

= Pregunta 2: Impactos de la Replicación Síncrona Universal

No es recomendable. Aunque garantiza consistencia inmediata, sus impactos negativos son significativos:

- *Técnicos*: La latencia WAN (~80-120ms) se suma a cada escritura, degradando el rendimiento. Si el nodo secundario falla, las escrituras en el primario se bloquean indefinidamente @postgres2026ha.
- *Económicos*: Requiere enlaces de red dedicados de ultra baja latencia y hardware idéntico en todas las réplicas, incrementando costos operativos.
- *Operativos*: Fluctuaciones normales de red causan micro-cortes perceptibles por el usuario. Mantenimiento de software requiere planes altamente complejos.

La replicación síncrona universal convierte al nodo más lento en cuello de botella del sistema completo @kleppmann2017designing.
