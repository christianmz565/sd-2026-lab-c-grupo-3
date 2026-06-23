#set par(justify: true)

= Actividad 3: Selección del Tipo de Replicación

Para cada uno de los tipos de datos manejados por FedEx Perú, se determina y justifica la estrategia de replicación óptima considerando el teorema CAP y el equilibrio entre consistencia, disponibilidad y latencia (rendimiento), basándose en la taxonomía de compensaciones de consistencia descrita por @abadi2012consistency y las recomendaciones de @kleppmann2017designing:

#v(0.5em)

#figure(
  table(
    columns: (1fr, 1.2fr, 2.5fr, 1.8fr),
    align: left,
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { gray.lighten(60%) } else if calc.odd(y) { rgb("#F9F9F9") } else { none },
    table.header(
      [*Tipo de Dato*],
      [*Mecanismo Seleccionado*],
      [*Justificación Técnica*],
      [*Trade-off (Consistencia vs. Rendimiento)*],
    ),
    [Inventarios],
    [Replicación Asíncrona con Asignación de Cuotas Locales o Bloqueos Optimistas.],
    [
      El inventario debe ser altamente disponible para la venta local. Un esquema síncrono degradaría las escrituras debido a la latencia WAN (~80ms-120ms).

      La replicación asíncrona rápida permite operaciones locales inmediatas y actualizaciones eventuales en milisegundos.
    ],
    [Consistencia Eventual / Alta Disponibilidad: Se asume consistencia eventual. Para mitigar colisiones, se segmenta el stock por país o se reservan cuotas de seguridad por sucursal.],

    [Seguimiento de envíos],
    [Replicación Asíncrona (Unidireccional / Lectura).],
    [
      Los datos de tracking de un paquete son de naturaleza aditiva e histórica (nuevos eventos que se añaden al historial de ruta).

      No ocurren escrituras concurrentes conflictivas sobre el mismo registro. Los clientes leen desde réplicas locales reduciendo la carga del nodo de origen (Lima).
    ],
    [Consistencia Eventual / Alto Rendimiento: Un lag de replicación de segundos es imperceptible para el usuario final y permite procesar miles de actualizaciones de estado simultáneamente.],

    [Historial de pedidos],
    [Replicación Asíncrona.],
    [
      Los pedidos finalizados son registros históricos inmutables. Se registran en la sede donde se realiza el envío y se replican asíncronamente al resto de sedes para auditoría, consulta de clientes y reportes.

      No requiere sincronización síncrona obligatoria durante la transacción.
    ],
    [Consistencia Eventual / Alta Disponibilidad: La transacción se confirma inmediatamente en la sede de origen. La sincronización global ocurre de fondo sin penalizar al usuario.],

    [Reportes ejecutivos],
    [Replicación Asíncrona (Réplicas de Solo Lectura Dedicadas).],
    [
      Las consultas analíticas y de reportería consolidan grandes volúmenes de datos e introducen sobrecarga en la base de datos.
      Utilizar una réplica de solo lectura (Standby) evita la degradación del rendimiento en el nodo transaccional principal (Lima).
    ],
    [Consistencia Diferida / Aislamiento de Carga: Los reportes analíticos toleran consistencia eventual de minutos u horas, priorizando no interferir con las operaciones transaccionales activas.],
  ),
  caption: [Tabla comparativa y justificación de estrategias de replicación por tipo de datos para FedEx Perú.],
) <tab-estrategias>

=== Vistas de Negocio para Monitoreo

Se crearon vistas SQL en el nodo primario para consolidar la información de los cuatro centros de distribución, permitiendo reportes ejecutivos en tiempo real:

#grid(
  columns: (1fr, 1fr),
  [
    #figure(
      image("../../img/ev7.jpeg", width: 70%),
      caption: [Vista `resumen_centros`: inventario consolidado por sede],
    )
  ],
  [
    #figure(
      image("../../img/ev8.jpeg", width: 70%),
      caption: [Vista `envios_por_estado`: distribución de envíos],
    )
  ],
)

#figure(
  image("../../img/ev9.jpeg", width: 40%),
  caption: [Tabla `inventarios`: datos completos replicados desde los cuatro centros],
) <fig-inventarios>
