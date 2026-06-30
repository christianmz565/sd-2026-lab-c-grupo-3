#set par(justify: true)

= Actividad 1: Identificación de Amenazas

Para el caso empresarial de LogiMarket Perú S.A.C., se realiza un análisis de amenazas siguiendo la metodología del NIST Cybersecurity Framework @nist2024csf y las categorías de riesgo del OWASP API Security Top 10 @owasp2023api. Se identifican los activos críticos de la plataforma, las amenazas potenciales asociadas, las vulnerabilidades subyacentes, el impacto potencial y el nivel de riesgo resultante.

#v(0.5em)

#figure(
  table(
    columns: (1fr, 1.2fr, 1.2fr, 1fr, 0.7fr),
    align: left,
    stroke: 0.5pt,
    inset: (x: 6pt, y: 5pt),
    fill: (x, y) => if y == 0 { rgb("#E8E8E8") } else if calc.odd(y) { rgb("#F9F9F9") } else { none },
    table.header([*Activo*], [*Amenaza*], [*Vulnerabilidad*], [*Impacto*], [*Riesgo*]),
    [Servicio de Autenticación],
    [Broken Authentication (API2), credential stuffing, fuerza bruta @owasp2023api],
    [Ausencia de MFA, contraseñas débiles, tokens JWT sin validación de expiración],
    [Compromiso total de cuentas de usuarios, acceso no autorizado a datos personales y financieros],
    [Crítico],

    [Servicio de Inventario],
    [Inyección SQL, broken object-level authorization (BOLA) @owasp2023api],
    [Falta de validación de parámetros en endpoints REST, ausencia de RBAC por objeto],
    [Manipulación de stock, pérdida de integridad de datos de inventario, sobreventa],
    [Alto],

    [Servicio de Pagos],
    [Exposición de datos sensibles, interceptación de tráfico entre servicios],
    [Comunicación sin cifrado entre microservicios, almacenamiento de datos de pago en texto plano],
    [Pérdida de información financiera, fraude en transacciones, multas regulatorias],
    [Crítico],

    [Servicio de Logística],
    [Broken access control, acceso no autorizado a información de envíos],
    [Ausencia de control de acceso basado en roles, credenciales compartidas entre empleados],
    [Acceso no autorizado a rutas de envío, manipulación de estados de entrega],
    [Alto],

    [Portal Web para Clientes],
    [XSS, CSRF, server-side request forgery (SSRF) @owasp2023api],
    [Falta de validación de entrada en formularios, ausencia de headers de seguridad],
    [Robo de sesiones de clientes, inyección de código malicioso, robo de credenciales],
    [Alto],

    [Aplicación Móvil],
    [Improper inventory management (API9), exposición de endpoints deprecated],
    [API keys embebidas en el código fuente, versiones obsoletas sin parches de seguridad],
    [Acceso a funcionalidades no autorizadas, extracción de datos del cliente],
    [Alto],
  ),
  caption: [Matriz de riesgos de seguridad para los activos críticos de LogiMarket Perú S.A.C.],
) <tab-riesgos>

#v(0.5em)

El análisis revela que la combinación de autenticación débil, comunicación sin cifrar entre servicios y ausencia de mecanismos de auditoría constituye una superficie de ataque significativa. Según el OWASP API Security Top 10 @owasp2023api, los errores de autenticación y autorización representan las categorías de riesgo más prevalentes en APIs empresariales. La propuesta de seguridad integral para LogiMarket aborda estos vectores mediante autenticación multifactor, cifrado TLS y monitoreo continuo, como se detalla en las siguientes actividades.
