#set par(justify: true)

= Pregunta 1: Equilibrio entre Consistencia Fuerte, Disponibilidad y Baja Latencia

De acuerdo al Teorema CAP, formulado por @gilbert2002brewer, y su extensión el Teorema PACELC, propuesto por @abadi2012consistency, si existe una partición de red (P), el sistema debe elegir entre Disponibilidad (A) o Consistencia (C); si no la hay (E), el sistema debe balancear Latencia (L) y Consistencia (C). Para una empresa multinacional con millones de transacciones, no es viable aplicar una única regla. Se debe clasificar los datos según su dominio crítico:

1. Clasificación de Datos y Consistencia Políglota \
   - Datos de Alta Criticidad Financiera (Ej. Saldos y Transferencias) \
     Requieren consistencia fuerte (ACID). Se prefiere sacrificar latencia e incluso disponibilidad temporal. Ejemplos de uso son bases de datos distribuidas con consenso Raft o Paxos (como Google Spanner o CockroachDB), garantizando que dos retiros simultáneos no sobrepasen el balance disponible.
   - Datos Operacionales y de Catálogo (Ej. Carrito de Compras, Búsqueda de Productos) \
     Se prioriza la disponibilidad y la baja latencia (Eventual Consistency / BASE), de acuerdo con los enfoques discutidos por @kleppmann2017designing. Si un cliente ve un stock desactualizado por 2 segundos y compra un artículo agotado, el negocio compensa este fallo en el flujo de negocio (reembolso, disculpas, sugerencia de producto similar), lo cual es financieramente preferible a perder ventas globales porque la base de datos se ralentizó tratando de sincronizar síncronamente.

2. Patrones Arquitectónicos de Mitigación \
   - CQRS (Command Query Responsibility Segregation) \
     Separa el modelo de escritura (consistencia fuerte en el Primario) del modelo de lectura (alta disponibilidad y baja latencia en réplicas asíncronas, ElasticSearch o Redis).
   - Arquitectura Basada en Sagas \
     Para transacciones de larga duración que cruzan múltiples servicios. En lugar de un bloqueo distribuido síncrono (Two-Phase Commit), cada microservicio ejecuta una transacción local y emite un evento. Si un paso posterior falla, se ejecutan transacciones compensatorias.
