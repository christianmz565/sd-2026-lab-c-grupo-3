#set par(justify: true)

= Pregunta 1: Equilibrio entre Consistencia Fuerte, Disponibilidad y Baja Latencia

Según el Teorema CAP @gilbert2002brewer y PACELC @abadi2012consistency, en una empresa multinacional no es viable aplicar una única estrategia. Se debe clasificar los datos por dominio:

- *Datos de Alta Criticidad Financiera* (saldos, transferencias): Requieren consistencia fuerte (ACID). Se prefiere sacrificar latencia. Ejemplo: bases de datos con consenso Raft/Paxos (Google Spanner, CockroachDB).
- *Datos Operacionales* (carrito de compras, búsquedas): Se prioriza disponibilidad y baja latencia (BASE). Si un cliente ve stock desactualizado por 2 segundos, el negocio compensa con reembolso o sugerencia, lo cual es preferible a perder ventas globales por latencia de sincronización síncrona.

La clave es aplicar *consistencia políglota*: cada tipo de dato usa la estrategia óptima según su criticidad.
