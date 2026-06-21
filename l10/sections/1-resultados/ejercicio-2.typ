= Ejercicio 2: Diseño Arquitectónico

== Arquitectura Distribuida - FedEx Perú

La arquitectura propuesta para FedEx Perú utiliza un modelo de *replicación primario-replica (Primary-Replica)* con replicación asíncrona entre cuatro centros de distribución ubicados en Lima, Bogotá, Santiago y Ciudad de México.

=== Diagrama Jerárquico

#figure(
  image("../../img/diagrama-jerarquico.png", width: 70%),
  caption: [Diagrama jerárquico de la arquitectura distribuida],
) <fig-jerarquico>

*Justificación:* Se adopta un modelo jerárquico con Lima como nodo principal (Primary) por ser la sede central de operaciones de FedEx Perú. Las demás sedes actúan como réplicas secundarias (Standby), recibiendo actualizaciones del nodo principal mediante replicación asíncrona. Esta estructura garantiza que las escrituras críticas se realicen en un único punto de coherencia, mientras que las lecturas se distribuyen geográficamente para reducir latencia.

=== Diagrama Geográfico

#figure(
  image("../../img/diagrama-geografico.png", width: 55%),
  caption: [Distribución geográfica de los centros de datos],
) <fig-geografico>

*Justificación:* La distribución geográfica responde a la cobertura operativa real de FedEx Perú en Latinoamérica. Las latencias estimadas entre sedes (80ms Lima-Bogotá, 100ms Lima-Santiago, 120ms Lima-Ciudad de México) son compatibles con replicación asíncrona, ya que el impacto en tiempos de respuesta es aceptable para el caso de uso empresarial. Los canales secundarios entre réplicas permiten sincronización regional en caso de fallo del nodo principal.

=== Diagrama de Flujo de Red

#figure(
  image("../../img/diagrama-flujo-red.png", width: 65%),
  caption: [Flujo de red y componentes técnicos por sede],
) <fig-flujo>

*Justificación:* Cada sede despliega un stack completo de Supabase reducido: PostgreSQL (base de datos), PostgREST (API REST automática) y Studio (panel administrativo). El Load Balancer distribuye las conexiones de clientes entre las réplicas de lectura. La replicación se realiza mediante *WAL Shipping* (Write-Ahead Log), que transfiere los registros de transacciones del nodo primario a las réplicas de forma asíncrona.

== Estrategia de Recuperación ante Fallos

La estrategia de recuperación implementada es la *promoción automática de réplicas*:

- *Detección:* El sistema monitorea la salud del nodo primario mediante heartbeats cada 10 segundos.
- *Failover:* Si el nodo primario (Lima) deja de responder, una de las réplicas secundarias es promovida a primario automáticamente.
- *Promoción:* La réplica con el WAL más reciente (menor pérdida de datos) asume el rol de escritura.
- *Reintegración:* Una vez recuperado el nodo original, se reincorpora como réplica secundaria mediante re-sincronización.

== Justificación de la Arquitectura Elegida

=== Replicación Asíncrona

Se eligió replicación asíncrona porque:

- *Rendimiento:* Las escrituras se confirman inmediatamente sin esperar confirmación de todas las réplicas.
- *Tolerancia a fallos de red:* La replicación no se bloquea por intermitencias en la conectividad entre sedes.
- *Escalabilidad:* Permite agregar nuevas réplicas sin impactar el rendimiento del nodo primario.

=== Consistencia Eventual

Para el caso de uso de FedEx (inventarios, envíos, pedidos), la consistencia eventual es aceptable porque:

- Los datos de inventario tienen una tolerancia de minutos para actualizarse entre sedes.
- Los pedidos en proceso se registran en la sede de origen y se replican posteriormente.
- Los reportes ejecutivos pueden consultar datos con ligera antigüedad sin afectar la toma de decisiones.

=== Tolerancia a Fallos

La arquitectura garantiza:

- *Disponibilidad > 99.9%:* Con 4 réplicas, el sistema tolera la caída de hasta 3 nodos simultáneamente (siempre que al menos uno permanezca operativo).
- *Recuperación automática:* Failover en menos de 30 segundos sin intervención manual.
- *Backup continuo:* WAL-G configurado para backups incrementales a un punto en el tiempo.

== Datos Críticos y Flujo de Replicación

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: left,
    stroke: 0.5pt,
    [*Dato*], [*Frecuencia*], [*Prioridad*], [*Réplica*],
    [Inventarios], [Cada 30 segundos], [Alta], [Completa],
    [Pedidos], [Tiempo real], [Crítica], [Completa],
    [Temperaturas], [Cada 60 segundos], [Alta], [Completa],
    [Estado envíos], [Tiempo real], [Crítica], [Completa],
    [Ubicación vehículos], [Cada 5 minutos], [Media], [Parcial],
    [Reportes ejecutivos], [Bajo demanda], [Baja], [Lazy load],
  ),
  caption: [Tabla de datos críticos y frecuencia de replicación],
) <tab-datos>
