#set par(justify: true)

= Actividad 1: Identificación de Necesidades

En esta actividad se identifican los requisitos operacionales y de datos para el sistema de distribución de datos de FedEx Perú, siguiendo las metodologías de diseño y análisis de sistemas distribuidos propuestas por @tanenbaum2008sistemas. La empresa maneja productos perecibles que requieren consistencia estricta en ciertos aspectos (como la cadena de frío) y alta disponibilidad en otros (como el seguimiento de envíos). A continuación, se presenta la tabla de diagnóstico que clasifica la criticidad de los datos, su susceptibilidad de replicación, los riesgos actuales y los beneficios esperados:

#v(0.5em)
#figure(
  table(
    columns: (1fr, 1.2fr, 1.8fr, 1.8fr),
    align: left,
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { gray.lighten(60%) } else if calc.odd(y) { rgb("#F9F9F9") } else { none },
    table.header([*Dato Crítico*], [*Susceptibilidad de Replicación*], [*Riesgos Actuales*], [*Beneficios Esperados*]),
    [Inventarios],
    [Susceptibilidad Alta. Requiere replicación rápida para evitar discrepancias de stock entre sedes.],
    [Sobreventa de productos, descalce de stock y retrasos críticos en la actualización de inventarios entre los países.],
    [Consistencia global de stock, optimización de asignación de despachos y visibilidad regional inmediata.],

    [Pedidos],
    [Susceptibilidad Crítica. Debe replicarse en tiempo real para asegurar la tolerancia a fallos.],
    [Pérdida de transacciones durante la caída de la base de datos principal e inoperabilidad del registro de ventas.],
    [Persistencia distribuida de facturación, tolerancia a fallos regional y continuidad operativa ininterrumpida.],

    [Temperaturas de almacenamiento],
    [Susceptibilidad Alta. Datos históricos y de telemetría continuos.],
    [Pérdida de trazabilidad de la cadena de frío, descomposición de productos perecibles y multas regulatorias.],
    [Garantía de calidad del producto, almacenamiento redundante distribuido y cumplimiento de estándares sanitarios.],

    [Estado de los envíos],
    [Susceptibilidad Crítica. Requiere consistencia eventual rápida para el cliente.],
    [Clientes visualizando estados contradictorios según la sucursal o réplica consultada, generando desconfianza.],
    [Experiencia de usuario homogénea y consultas de tracking de alta velocidad optimizadas localmente.],

    [Ubicación de vehículos],
    [Susceptibilidad Media. Telemetría GPS en tiempo real.],
    [Pérdida de seguimiento de vehículos, estimaciones de tiempo de entrega (ETA) desactualizadas en los paneles locales.],
    [Monitoreo logístico geográfico consolidado y optimización de rutas a partir de réplicas de lectura.],
  ),
  caption: [Matriz de necesidades de datos, riesgos de punto único de fallo y beneficios de replicación para FedEx Perú.],
) <tab-necesidades>

#v(0.5em)
El análisis revela que la falta de un esquema distribuido convierte al servidor principal en un Punto Único de Fallo (SPOF) como se explica en @postgres2026ha, lo cual expone a FedEx Perú a pérdidas financieras y operativas severas. La implementación de una base de datos distribuida con replicación física resuelve estas limitaciones, aislando las fallas y distribuyendo la carga de lectura geográficamente.
