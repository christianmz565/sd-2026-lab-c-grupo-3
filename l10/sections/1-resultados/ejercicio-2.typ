#set par(justify: true)

= Ejercicio 2: Diseño Arquitectónico

== Arquitectura Distribuida - FedEx Perú

La arquitectura propuesta para FedEx Perú utiliza un modelo de replicación primario-replica (Primary-Replica) con replicación asíncrona entre cuatro centros de distribución ubicados en Lima, Bogotá, Santiago y Ciudad de México, de acuerdo con los patrones de almacenamiento distribuido discutidos por @kleppmann2017designing.

=== Diagrama Jerárquico

#figure(
  image("../../img/diagrama-jerarquico.png", height: 40%, fit: "contain"),
  caption: [Diagrama jerárquico de la arquitectura distribuida],
) <fig-jerarquico>

Justificación: Se adopta un modelo jerárquico con Lima como nodo principal (Primary) por ser la sede central de operaciones de FedEx Perú. Las demás sedes actúan como réplicas secundarias (Standby), recibiendo actualizaciones del nodo principal mediante replicación asíncrona. Esta estructura garantiza que las escrituras críticas se realicen en un único punto de coherencia, mientras que las lecturas se distribuyen geográficamente para reducir latencia.

=== Diagrama Geográfico

#figure(
  image("../../img/diagrama-geografico.png", height: 30%, fit: "contain"),
  caption: [Distribución geográfica de los centros de datos],
) <fig-geografico>

Justificación: La distribución geográfica responde a la cobertura operativa real de FedEx Perú en Latinoamérica. Las latencias estimadas entre sedes (80ms Lima-Bogotá, 100ms Lima-Santiago, 120ms Lima-Ciudad de México) son compatibles con replicación asíncrona, ya que el impacto en tiempos de respuesta es aceptable para el caso de uso empresarial. Los canales secundarios entre réplicas permiten sincronización regional en caso de fallo del nodo principal.

=== Diagrama de Flujo de Red

#figure(
  image("../../img/diagrama-flujo-red.png", height: 30%, fit: "contain"),
  caption: [Flujo de red y componentes técnicos por sede],
) <fig-flujo>

Justificación: Cada sede despliega un stack completo de Supabase reducido: PostgreSQL (base de datos), PostgREST (API REST automática) y Studio (panel administrativo). El Load Balancer distribuye las conexiones de clientes entre las réplicas de lectura. La replicación se realiza mediante WAL Shipping (Write-Ahead Log), que transfiere los registros de transacciones del nodo primario a las réplicas de forma asíncrona.

== Estrategia de Recuperación ante Fallos

La estrategia de recuperación implementada es la promoción automática de réplicas:

- Detección \
  El sistema monitorea la salud del nodo primario mediante heartbeats cada 10 segundos.
- Failover \
  Si el nodo primario (Lima) deja de responder, una de las réplicas secundarias es promovida a primario automáticamente.
- Promoción \
  La réplica con el WAL más reciente (menor pérdida de datos) asume el rol de escritura.
- Reintegración \
  Una vez recuperado el nodo original, se reincorpora como réplica secundaria mediante re-sincronización.

== Justificación de la Arquitectura Elegida

=== Replicación Asíncrona

Se eligió replicación asíncrona porque:

- Rendimiento \
  Las escrituras se confirman inmediatamente sin esperar confirmación de todas las réplicas.
- Tolerancia a fallos de red \
  La replicación no se bloquea por intermitencias en la conectividad entre sedes.
- Escalabilidad \
  Permite agregar nuevas réplicas sin impactar el rendimiento del nodo primario.

=== Consistencia Eventual

Para el caso de uso de FedEx (inventarios, envíos, pedidos), la consistencia eventual es aceptable porque:

- Los datos de inventario tienen una tolerancia de minutos para actualizarse entre sedes.
- Los pedidos en proceso se registran en la sede de origen y se replican posteriormente.
- Los reportes ejecutivos pueden consultar datos con ligera antigüedad sin afectar la toma de decisiones.

=== Tolerancia a Fallos

La arquitectura garantiza:

- Disponibilidad mayor al 99.9% \
  Con 4 réplicas, el sistema tolera la caída de hasta 3 nodos simultáneamente (siempre que al menos uno permanezca operativo).
- Recuperación automática \
  Failover en menos de 30 segundos sin intervención manual.
- Backup continuo \
  WAL-G configurado para backups incrementales a un punto en el tiempo.

== Datos Críticos y Flujo de Replicación

#figure(
  table(
    columns: (1fr, 1fr, 1fr, 1fr),
    align: left,
    stroke: 0.5pt,
    table.header([*Dato*], [*Frecuencia*], [*Prioridad*], [*Réplica*]),
    [Inventarios], [Cada 30 segundos], [Alta], [Completa],
    [Pedidos], [Tiempo real], [Crítica], [Completa],
    [Temperaturas], [Cada 60 segundos], [Alta], [Completa],
    [Estado envíos], [Tiempo real], [Crítica], [Completa],
    [Ubicación vehículos], [Cada 5 minutos], [Media], [Parcial],
    [Reportes ejecutivos], [Bajo demanda], [Baja], [Lazy load],
  ),
  caption: [Tabla de datos críticos y frecuencia de replicación],
) <tab-datos>

=== Verificación de la Infraestructura de Replicación

La infraestructura desplegada utiliza slots de replicación físicos y conexiones de streaming para mantener la sincronización entre el nodo primario (Lima) y los standbys (Bogotá, Santiago, Ciudad de México).

#grid(
  columns: (1fr, 1fr),
  [
    #figure(
      image("../../img/ev5.jpeg", width: 100%),
      caption: [Slots de replicación activos en el nodo primario],
    )
  ],
  [
    #figure(
      image("../../img/ev6.jpeg", width: 60%),
      caption: [Conexiones de standbys en estado streaming],
    )
  ],
)
