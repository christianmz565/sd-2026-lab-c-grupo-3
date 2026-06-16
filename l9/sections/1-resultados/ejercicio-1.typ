#import "/lib.typ": code-block

= Actividad 1: Identificación de Riesgos

Se elaboró una matriz de riesgos para los cinco microservicios de LogiFresh S.A., identificando las principales amenazas de calidad que podrían manifestarse durante campañas de alta demanda. Cada riesgo fue evaluado en términos de probabilidad de ocurrencia, impacto en el negocio y severidad global, lo que permite priorizar las acciones de mitigación de manera eficiente.

== Matriz de Riesgos

#let gray-header = rgb("#D9D9D9")
#table(
  columns: (auto, auto, 1.1fr, auto, auto, 1.5fr),
  align: (center, center, left, center, center, left),
  stroke: black + 0.4pt,
  inset: 0.3em,
  table.header(
    repeat: false,
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[N°]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Servicio]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Impacto]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Prob.]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Riesgo]],
    table.cell(fill: gray-header)[#text(weight: "bold", size: 7pt)[Mitigación]],
  ),
  [R1],
  [Pedidos / Inventario],
  [Pedidos sin descuento aplicado],
  [Alta],
  [Crítico],
  [Validar promoción dentro de la misma transacción de BD que crea el pedido, garantizando atomicidad],

  [R2],
  [Inventario],
  [Stock inconsistente por sobreventa],
  [Alta],
  [Crítico],
  [Bloqueo pesimista con `SELECT FOR UPDATE` al reservar stock, impidiendo lecturas concurrentes],

  [R3],
  [Facturación],
  [Facturas duplicadas por reintentos],
  [Media],
  [Alto],
  [Constraint `UNIQUE` en `order_id` más verificación idempotente antes de insertar],

  [R4],
  [Notificaciones],
  [Retrasos bloqueando flujo principal],
  [Media],
  [Alto],
  [Cola Redis con worker asíncrono, desacoplado del flujo de pedidos],

  [R5],
  [Pedidos / Todos],
  [Lentitud superior a 8 segundos],
  [Alta],
  [Crítico],
  [HTTP 202 Accepted con procesamiento en background via `BackgroundTasks`],

  [R6],
  [Pedidos],
  [Pedidos duplicados por reintentos],
  [Media],
  [Alto],
  [Header `X-Idempotency-Key` con constraint UNIQUE en base de datos],

  [R7],
  [Transporte],
  [Doble asignación de conductor],
  [Baja],
  [Medio],
  [`SELECT FOR UPDATE SKIP LOCKED` al asignar conductor disponible],
)
