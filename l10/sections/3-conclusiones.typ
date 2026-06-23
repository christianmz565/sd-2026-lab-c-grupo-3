#import "/lib.typ": lab-section

#lab-section(title: "CONCLUSIONES")[
  #show heading: set text(weight: "bold")
  #set par(justify: true)

  == CONCLUSIONES

  + La implementación de la replicación por streaming físico en PostgreSQL mediante Docker Compose demostró ser un mecanismo altamente eficiente para descentralizar las consultas de lectura y asegurar la tolerancia a fallos, permitiendo un lag inferior a un megabyte de transacciones en condiciones de red estables.

  + La evaluación de la arquitectura bajo los postulados teóricos del teorema CAP y PACELC evidenció que para una estructura geográficamente dispersa como la de FedEx Perú, la replicación asíncrona es el diseño óptimo, evitando el estrangulamiento del rendimiento de escrituras locales por latencias de red intercontinentales.

  + La simulación de fallos local confirmó que la promoción de un nodo secundario a primario mediante la función de base de datos pg_promote de PostgreSQL permite la recuperación de la capacidad de escritura en menos de 30 segundos, restableciendo de forma efectiva la continuidad operativa.

  == RECOMENDACIONES

  + Integrar un orquestador de alta disponibilidad basado en Patroni y un almacén de configuración distribuida como etcd para automatizar la promoción de réplicas de forma segura por quórum y prevenir escenarios de split-brain en producción.

  + Desplegar proxies de base de datos como HAProxy y PgBouncer delante de las instancias para realizar un enrutamiento transparente de lectura y escritura (read-write splitting), optimizando la gestión de conexiones y aislando al cliente de la topología física.

  + Configurar un esquema de confirmación síncrona selectiva a nivel de transacción mediante el parámetro synchronous_commit, aplicándolo únicamente para los registros críticos de pedidos e inventarios financieros, y dejando la telemetría secundaria en modo asíncrono.
]
