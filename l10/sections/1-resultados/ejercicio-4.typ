#set par(justify: true)

= Actividad 4: Simulación de un Fallo (Failover)

Para validar la resiliencia y el comportamiento del sistema ante fallos, se simuló la caída completa del nodo principal en Lima durante 20 minutos. A continuación, se detallan las respuestas a las interrogantes planteadas y el flujo técnico ejecutado:

== Respuestas a las Interrogantes del Escenario de Fallo

1. ¿Qué nodo debería asumir el servicio? \
  El nodo de Bogotá (bogota-db) debe asumir el rol principal. Esto se debe a que geográficamente tiene la menor latencia de comunicación con el nodo principal original (~80ms) y es el nodo secundario configurado para el primer nivel de contingencia.

2. ¿Cómo se garantizaría la continuidad operativa? \
  Se realiza un proceso de conmutación por error (failover), siguiendo los principios de alta disponibilidad descritos por @postgres2026ha:
  - Promoción \
    Se promueve la réplica de Bogotá a modo Primary mediante la función pg_promote(). Esto rompe su estado de solo lectura y le permite aceptar transacciones de escritura.
  - Re-enrutamiento \
    El balanceador de carga o DNS interno re-dirige el tráfico de escritura de los clientes al puerto 5433 (Bogotá) en lugar del 5432 (Lima).
  - Reconfiguración \
    Los nodos standby de Santiago y México deben reconfigurarse para establecer su conexión de replicación (primary_conninfo) apuntando a Bogotá.

3. ¿Qué información podría perderse si la replicación fuera asíncrona? \
  Toda transacción que haya sido confirmada localmente en Lima pero que no haya sido transmitida a través de la red hacia el buffer de Bogotá en el momento exacto de la caída. Esto se conoce como pérdida por lag de replicación, un trade-off fundamental detallado por @kleppmann2017designing. En condiciones normales, el lag es de milisegundos a pocos segundos, por lo que la pérdida potencial de transacciones (pedidos o registros de temperatura) es mínima (RPO mayor a 0).

4. ¿Cómo afectaría una replicación síncrona? \
  - Ventaja \
    Cero pérdida de datos (RPO igual a 0), ya que ninguna transacción en Lima se confirma al cliente sin antes haber sido escrita en el WAL de Bogotá.
  - Desventaja (Gran Impacto Operativo) \
    Si la conexión de red entre Lima y Bogotá experimenta latencias altas o cortes, todas las escrituras en Lima se bloquearán o fallarán. Esto incrementa la latencia transaccional local de menor a 5 ms a mayor a 80 ms (el viaje de ida y vuelta de red WAN), afectando gravemente el rendimiento del negocio.

== Evidencia de la Simulación

Las siguientes capturas validan el comportamiento del sistema durante la simulación de fallo:

#grid(
  columns: (1fr, 1fr),
  [
    #figure(
      image("../../img/ev3.jpeg", width: 90%),
      caption: [Escritura exitosa en el nodo primario (Lima)],
    )
  ],
  [
    #figure(
      image("../../img/ev2.jpeg", width: 70%),
      caption: [Error de escritura en el standby (Bogotá), transacción de solo lectura],
    )
  ],
)

#figure(
  image("../../img/ev4.jpeg", width: 60%),
  caption: [Datos replicados visibles en Bogotá: el registro insertado en Lima aparece en la réplica],
) <fig-replicated>
