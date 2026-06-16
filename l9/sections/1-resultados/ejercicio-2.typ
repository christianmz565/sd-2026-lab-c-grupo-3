#import "/lib.typ": code-block

= Actividad 2: Casos de Prueba Funcionales

#let gray-header = rgb("#D9D9D9")
#let tc-cols = (0.6fr, 2.4fr)

== TC-001: Registro correcto de pedido

#table(
  columns: tc-cols, stroke: black + 0.4pt, inset: 0.3em,
  table.header(repeat: false, table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Campo]], table.cell(
    fill: gray-header,
  )[#text(weight: "bold", size: 7pt)[Detalle]]),
  [Objetivo], [Verificar que un pedido se registra correctamente y aparece con estado CONFIRMED],
  [Entrada], [Cliente `CLIENT-001`, producto "Pollo entero congelado", cantidad 5, precio S/ 25.50],
  [Esperado], [Estado `CONFIRMED`, total 5 x S/ 25.50 = S/ 127.50],
  [Obtenido], [PASS: Subtotal S/ 127.50, factura con IGV S/ 22.95 (total S/ 150.45), envío y notificación generados],
)

#grid(
  columns: (1fr, 1fr, 1fr),
  align: (horizon, horizon, horizon),
  gutter: 0.6em,
  figure(
    image("../../img/lab/casos-funcionales/tc001-formulario.png", width: 90%),
    caption: [Formulario: 5 unidades de Pollo, S/ 127.50],
  ),
  figure(
    image("../../img/lab/casos-funcionales/tc001-pedido-confirmado.png", width: 90%),
    caption: [Detalle CONFIRMED con factura],
  ),
  figure(
    image("../../img/lab/casos-funcionales/tc001-tc002-listado-pedidos.png", width: 90%),
    caption: [Listado de pedidos],
  ),
)

== TC-002: Pedido con inventario insuficiente

#table(
  columns: tc-cols, stroke: black + 0.4pt, inset: 0.3em,
  table.header(repeat: false, table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Campo]], table.cell(
    fill: gray-header,
  )[#text(weight: "bold", size: 7pt)[Detalle]]),
  [Objetivo], [Verificar cancelación automática por stock insuficiente],
  [Entrada], [Producto "Pollo" (stock: 500), cantidad 99999],
  [Esperado], [PENDING → CANCELLED tras procesamiento],
  [Obtenido], [PASS: HTTP 409 "Stock insuficiente", pedido CANCELLED, stock liberado, notificación ORDER_CANCELLED],
)

#grid(
  columns: (1fr, 1fr),
  align: (horizon, horizon),
  gutter: 0.6em,
  figure(
    image("../../img/lab/casos-funcionales/tc002-formulario-insuficiente.png", width: 90%),
    caption: [Cantidad 99999, S/ 2,549,974.50],
  ),
  figure(image("../../img/lab/casos-funcionales/tc002-pedido-cancelado.png", width: 90%), caption: [Detalle CANCELLED]),
)

== TC-003: Cancelación manual en PENDING

#table(
  columns: tc-cols, stroke: black + 0.4pt, inset: 0.3em,
  table.header(repeat: false, table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Campo]], table.cell(
    fill: gray-header,
  )[#text(weight: "bold", size: 7pt)[Detalle]]),
  [Objetivo], [Verificar cancelación manual de pedido en estado PENDING],
  [Entrada], [Pedido válido, cancelación vía `PATCH /orders/{id}/cancel`],
  [Esperado], [PENDING → CANCELLED],
  [Obtenido], [PASS parcial: Endpoint funciona, pero el procesamiento background cambia el estado a CONFIRMED antes de poder cancelarlo],
)

#grid(
  columns: (1fr, 1fr),
  align: (horizon, horizon),
  gutter: 0.6em,
  figure(image("../../img/lab/casos-funcionales/tc003-listado-pedidos.png", width: 50%), caption: [Estado PROCESSING]),
  figure(
    image("../../img/lab/casos-funcionales/tc003-pedido-processing.png", width: 90%),
    caption: [Detalle "Sincronizando…"],
  ),
)

== TC-004: Cancelar pedido CONFIRMED

#table(
  columns: tc-cols, stroke: black + 0.4pt, inset: 0.3em,
  table.header(repeat: false, table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Campo]], table.cell(
    fill: gray-header,
  )[#text(weight: "bold", size: 7pt)[Detalle]]),
  [Objetivo], [Verificar que no se puede cancelar un pedido ya confirmado],
  [Entrada], [Pedido CONFIRMED, intento de cancelación],
  [Esperado], [Error HTTP 400],
  [Obtenido], [PASS: HTTP 400 "No se puede cancelar un pedido en estado 'CONFIRMED'"],
)

#figure(
  image("../../img/lab/casos-funcionales/tc004-pedido-confirmado.png", width: 40%),
  caption: [Pedido CONFIRMED, no cancelable],
)

== TC-005: Promoción válida (VERANO10)

#table(
  columns: tc-cols, stroke: black + 0.4pt, inset: 0.3em,
  table.header(repeat: false, table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Campo]], table.cell(
    fill: gray-header,
  )[#text(weight: "bold", size: 7pt)[Detalle]]),
  [Objetivo], [Verificar aplicación correcta de descuento por promoción],
  [Entrada], [Carne de res ×10 (S/ 38.00), código `VERANO10`],
  [Esperado], [Subtotal S/ 380.00, total S/ 342.00 (−10%)],
  [Obtenido], [PASS: `discount_pct: 10.0`, `total_amount: 342.0`],
)

#figure(
  image("../../img/lab/casos-funcionales/tc005-pedido-con-promocion.png", width: 40%),
  caption: [Pedido con VERANO10: −10%, S/ 342.00],
)

== TC-006: Sin promoción

#table(
  columns: tc-cols, stroke: black + 0.4pt, inset: 0.3em,
  table.header(repeat: false, table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Campo]], table.cell(
    fill: gray-header,
  )[#text(weight: "bold", size: 7pt)[Detalle]]),
  [Objetivo], [Verificar registro con precio completo sin descuento],
  [Entrada], [Merluza ×2 (S/ 15.75), sin promoción],
  [Esperado], [Subtotal = total = S/ 31.50],
  [Obtenido], [PASS: `discount_pct: 0.0`, `total_amount: 31.5`],
)

#grid(
  columns: (1fr, 1fr),
  align: (horizon, horizon),
  gutter: 0.6em,
  figure(
    image("../../img/lab/casos-funcionales/tc006-formulario-sin-promo.png", width: 90%),
    caption: [Formulario sin promo],
  ),
  figure(image("../../img/lab/casos-funcionales/tc006-pedido-sin-promo.png", width: 90%), caption: [Detalle CONFIRMED]),
)

== TC-007: Factura con IGV

#table(
  columns: tc-cols, stroke: black + 0.4pt, inset: 0.3em,
  table.header(repeat: false, table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Campo]], table.cell(
    fill: gray-header,
  )[#text(weight: "bold", size: 7pt)[Detalle]]),
  [Objetivo], [Verificar generación automática de factura con IGV 18%],
  [Entrada], [Leche evaporada ×20 (S/ 45.00), cliente `CLIENT-005`],
  [Esperado], [Subtotal S/ 900.00, IGV S/ 162.00, total S/ 1,062.00],
  [Obtenido], [PASS: `subtotal: 900.0`, `tax_amount: 162.0`, `total: 1062.0`],
)

#figure(
  image("../../img/lab/casos-funcionales/tc007-facturas-igv.png", width: 40%),
  caption: [Facturas con IGV visible],
)

== TC-008: Idempotencia

#table(
  columns: tc-cols, stroke: black + 0.4pt, inset: 0.3em,
  table.header(repeat: false, table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Campo]], table.cell(
    fill: gray-header,
  )[#text(weight: "bold", size: 7pt)[Detalle]]),
  [Objetivo], [Verificar que requests duplicados con misma clave idempotente no crean registros],
  [Entrada], [Dos requests con `X-Idempotency-Key: test-idem-001`],
  [Esperado], [Un solo pedido, segundo request devuelve el existente],
  [Obtenido], [PASS: `{"idempotent": true, "message": "Pedido ya registrado previamente"}`],
)

#figure(
  image("../../img/lab/casos-funcionales/tc001-pedido-confirmado.png", width: 40%),
  caption: [Detalle del pedido creado (idempotencia)],
)

== TC-009: Notificación ORDER_CONFIRMED

#table(
  columns: tc-cols, stroke: black + 0.4pt, inset: 0.3em,
  table.header(repeat: false, table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Campo]], table.cell(
    fill: gray-header,
  )[#text(weight: "bold", size: 7pt)[Detalle]]),
  [Objetivo], [Verificar generación de notificación al confirmar pedido],
  [Entrada], [Pedido CONFIRMED con email `test@logifresh.pe`],
  [Esperado], [Notificación `ORDER_CONFIRMED` con `status: SENT`],
  [Obtenido], [PASS: Notificación visible en panel con status SENT],
)

#figure(
  image("../../img/lab/casos-funcionales/tc009-notificaciones-confirmadas.png", width: 40%),
  caption: [Notificaciones ORDER_CONFIRMED visibles en el panel],
)

== TC-010: Notificación ORDER_CANCELLED

#table(
  columns: tc-cols, stroke: black + 0.4pt, inset: 0.3em,
  table.header(repeat: false, table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Campo]], table.cell(
    fill: gray-header,
  )[#text(weight: "bold", size: 7pt)[Detalle]]),
  [Objetivo], [Verificar notificación al cancelar por stock insuficiente],
  [Entrada], [Pedido con cantidad 99999, cancelado por stock],
  [Esperado], [Notificación `ORDER_CANCELLED` con `status: SENT`],
  [Obtenido], [PASS: Notificación con recipient test2\@logifresh.pe y status SENT],
)

#grid(
  columns: (1fr, 1fr),
  align: (horizon, horizon),
  gutter: 0.6em,
  figure(
    image("../../img/lab/casos-funcionales/tc009-notificaciones-confirmadas.png", width: 90%),
    caption: [Notificaciones CONFIRMED],
  ),
  figure(
    image("../../img/lab/casos-funcionales/tc009-tc010-notificaciones.png", width: 70%),
    caption: [CONFIRMED y CANCELLED],
  ),
)

== Resumen de Cobertura

#table(
  columns: (1.2fr, 0.8fr, auto),
  stroke: black + 0.4pt,
  inset: 0.3em,
  table.header(
    repeat: false,
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Escenario]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Casos]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Estado]],
  ),
  [Registro de pedidos], [TC-001], [PASS],
  [Inventario insuficiente], [TC-002, TC-010], [PASS],
  [Cancelación manual (TC-003)], [TC-003], [PASS (Parcial)],
  [Cancelar pedido CONFIRMED (TC-004)], [TC-004], [PASS],
  [Promociones], [TC-005, TC-006], [PASS],
  [Factura automática], [TC-007], [PASS],
  [Idempotencia], [TC-008], [PASS],
  [Notificaciones], [TC-009, TC-010], [PASS],
)

Nueve de diez casos obtuvieron PASS completo y uno PASS parcial (TC-003). Tasa de éxito: 95%.
