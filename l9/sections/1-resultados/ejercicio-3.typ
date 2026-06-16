= Actividad 3: Pruebas de Integración

Se implementaron pruebas de integración automatizadas utilizando Python, pytest y httpx para validar la comunicación entre los microservicios del sistema LogiFresh. Las pruebas se ejecutan dentro de la red Docker, permitiendo verificar la interacción real entre componentes distribuidos sin depender de mocks o simulaciones.

== Diseño del Catálogo de Pruebas

=== Pedido y Inventario

La interacción entre Pedidos e Inventario es crítica para garantizar la consistencia del stock. Se diseñaron cinco pruebas que cubren el flujo completo de reserva, manejo de errores y concurrencia.

#let tc-cols = (0.3fr, 0.7fr, 2.2fr)
#let gray-header = rgb("#D9D9D9")
#table(
  columns: tc-cols,
  stroke: black + 0.4pt,
  inset: 0.3em,
  table.header(
    repeat: false,
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[ID]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Escenario]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Validación]],
  ),
  [TI-01],
  [Reserva exitosa de stock],
  [Crear pedido con stock suficiente y verificar que el stock se decrementa exactamente en el servicio de Inventario],

  [TI-02],
  [Stock insuficiente],
  [Crear pedido con cantidad mayor al stock disponible y verificar que el pedido se cancela y el stock permanece sin cambios],

  [TI-03],
  [Liberación de stock],
  [Reservar stock y luego liberarlo simulando un fallo en facturación, verificando que el stock se restaura al valor original],

  [TI-04],
  [Concurrencia],
  [Dos pedidos simultáneos que solicitan más unidades de las disponibles, validando que al menos uno se cancela y el stock nunca es negativo],

  [TI-05],
  [Producto inexistente],
  [Crear pedido con un product_id que no existe y verificar que el sistema cancela el pedido],
)

=== Pedido y Facturación

La interacción entre Pedidos y Facturación debe generar exactamente una factura por pedido, sin duplicados, aplicando correctamente el IGV del 18% y los descuentos de promoción.

#table(
  columns: tc-cols,
  stroke: black + 0.4pt,
  inset: 0.3em,
  table.header(
    repeat: false,
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[ID]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Escenario]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Validación]],
  ),
  [TF-01], [Factura con IGV], [Pedido confirmado genera factura con IGV 18% calculado sobre la base imponible],
  [TF-02],
  [Idempotencia de factura],
  [Dos llamadas al endpoint de facturación con el mismo order_id devuelven la factura existente sin crear duplicados],

  [TF-03],
  [Factura con promoción],
  [Pedido con código VERANO10 genera factura con descuento del 10% aplicado antes del cálculo del IGV],

  [TF-04], [Factura sin promoción], [Pedido sin código de descuento genera factura con `discount_amount: 0.0`],
)

=== Pedido y Transporte

La interacción entre Pedidos y Transporte asigna un conductor disponible al pedido confirmado, gestionando las transiciones de estado del envío.

#table(
  columns: tc-cols,
  stroke: black + 0.4pt,
  inset: 0.3em,
  table.header(
    repeat: false,
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[ID]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Escenario]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Validación]],
  ),
  [TT-01],
  [Asignación de conductor],
  [Al confirmar un pedido, se asigna automáticamente un conductor disponible con estado ASSIGNED],

  [TT-02], [Conductores ocupados], [Cuando los 3 conductores están ocupados, el servicio responde con HTTP 503],
  [TT-03],
  [Transiciones de estado],
  [El envío sigue la cadena ASSIGNED → IN_TRANSIT → DELIVERED, liberando el conductor al entregar],

  [TT-04],
  [Idempotencia de envío],
  [Solicitudes duplicadas con el mismo order_id devuelven el envío existente sin duplicar],
)

=== Notificaciones

#table(
  columns: tc-cols,
  stroke: black + 0.4pt,
  inset: 0.3em,
  table.header(
    repeat: false,
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[ID]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Escenario]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Validación]],
  ),
  [TN-01],
  [Confirmación de pedido],
  [Al confirmar un pedido, se genera una notificación ORDER_CONFIRMED visible en el panel con status SENT],

  [TN-02],
  [Cancelación de pedido],
  [Al cancelar un pedido por stock insuficiente, se genera una notificación ORDER_CANCELLED automáticamente],

  [TN-03],
  [Estado del worker],
  [Tras procesar la cola Redis, la notificación tiene `sent_at` definido y `attempts` mayor o igual a 1],
)

== Evidencia de Ejecución

#figure(
  image("../../img/lab/integracion/reporte-pytest.png", width: 60%),
  caption: [Reporte de ejecución de pruebas de integración con pytest, validando la comunicación entre los microservicios],
)

== Manejo de Fallos y Mecanismos de Recuperación

Las interacciones entre servicios en un sistema distribuido están expuestas a múltiples puntos de fallo: desconexiones de red, respuestas tardías, agotamiento de recursos y errores en servicios dependientes. Cada interacción fue analizada para diseñar mecanismos de recuperación apropiados.

#table(
  columns: (1fr, 1.3fr, 1.7fr),
  stroke: black + 0.4pt,
  inset: 0.3em,
  table.header(
    repeat: false,
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Interacción]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Fallo posible]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Mecanismo de recuperación]],
  ),
  [Pedido y Inventario],
  [Desconexión o respuesta tardía durante la reserva de stock],
  [Timeout de 10 segundos. Si la reserva falla, el pedido se actualiza a CANCELLED y se notifica al cliente],

  [Pedido y Facturación],
  [Error 500 o servicio no disponible al crear la factura],
  [Rollback: se invoca `POST /release` al servicio de Inventario para liberar el stock reservado, y se cancela el pedido],

  [Pedido y Transporte],
  [No hay conductores disponibles o servicio caído],
  [El fallo de transporte es no-crítico. El pedido se confirma igualmente y el envío se puede asignar manualmente después],

  [Pedido y Notificaciones],
  [Cola Redis saturada o servicio no responde],
  [Las notificaciones se procesan de forma asíncrona con reintentos automáticos hasta 3 veces. El pedido no se ve afectado por fallos en notificaciones],
)
