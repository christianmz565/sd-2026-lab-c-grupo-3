#set par(justify: true)

= Pregunta 1: En una empresa multinacional con millones de transacciones diarias, ¿cómo equilibraría la necesidad de consistencia fuerte con los requisitos de disponibilidad y baja latencia? Sustente su respuesta con ejemplos.

Según el Teorema CAP @gilbert2002brewer y PACELC @abadi2012consistency, en una empresa multinacional no es viable aplicar una única estrategia de replicación para todos los dominios de datos. En su lugar, se debe clasificar los datos por dominio y asignar a cada uno la estrategia que mejor se ajuste a sus requisitos de consistencia, disponibilidad y rendimiento.

Los datos de alta criticidad financiera, como saldos y transferencias, requieren consistencia fuerte garantizada por transacciones ACID. En estos escenarios se acepta sacrificar latencia a cambio de integridad, utilizando bases de datos con mecanismos de consenso distribuido como Raft o Paxos, presentes en sistemas como Google Spanner o CockroachDB. Por otro lado, los datos operacionales, como el carrito de compras o búsquedas de productos, priorizan disponibilidad y baja latencia bajo el modelo BASE. Si un cliente observa stock desactualizado por unos segundos, el negocio puede compensar con reembolsos o sugerencias alternativas, lo cual es preferible a perder ventas globales por la latencia de una sincronización síncrona. @kleppmann2017designing.
