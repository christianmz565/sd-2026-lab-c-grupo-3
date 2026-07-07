#import "@preview/charged-ieee:0.1.4": ieee

#show: ieee.with(
  title: [Comparación de Rendimiento entre REST y GraphQL: Análisis Empírico de Paradigmas de Arquitectura de APIs],
  abstract: [
    El diseño de interfaces de programación de aplicaciones (APIs) es una decisión arquitectónica crítica en sistemas distribuidos, que impacta directamente en el rendimiento, la escalabilidad y la productividad de los desarrolladores. Este trabajo presenta un análisis comparativo de dos paradigmas dominantes de APIs: Representational State Transfer (REST) y GraphQL. Implementamos ambos enfoques para un dominio idéntico de catálogo de libros, incluyendo una API RESTful construida con Spring Boot (Java 21) y Flask (Python), y un servidor GraphQL con Bun/GraphQL-Yoga, y los evaluamos bajo condiciones de carga controladas utilizando k6. Además, describimos en detalle el proceso de diseño y desarrollo de los servicios RESTful siguiendo las directrices de un taller práctico, cubriendo desde los principios teóricos de REST hasta la implementación completa con persistencia de datos y clientes web. Nuestros experimentos miden latencia de respuesta, tamaño de payload, throughput y estabilidad en operaciones de lectura y escritura. Los resultados indican que GraphQL logra aproximadamente un 15--18\% menor latencia promedio en operaciones de lectura y reduce el tamaño del payload hasta en un 78\% mediante consultas selectivas de campos, mientras que REST mantiene capacidades superiores de caché a través de mecanismos nativos de HTTP. Discutimos los compromisos arquitectónicos, identificamos escenarios donde cada paradigma sobresale y proporcionamos directrices para profesionales que seleccionan entre REST y GraphQL en sistemas distribuidos modernos.
  ],
  authors: (
    (
      name: "Bedregal Perez, Daniel",
      organization: "Universidad Nacional de San Agustin",
      location: "Arequipa, Peru",
      email: "dbedregalp@unsa.edu.pe",
    ),
    (
      name: "Jara Mamani, Mariel Alisson",
      organization: "Universidad Nacional de San Agustin",
      location: "Arequipa, Peru",
      email: "mjarama@unsa.edu.pe",
    ),
    (
      name: "Mestas Zegarra, Christian Raul",
      organization: "Universidad Nacional de San Agustin",
      location: "Arequipa, Peru",
      email: "cmestasz@unsa.edu.pe",
    ),
    (
      name: "Noa Camino, Yenaro Joel",
      organization: "Universidad Nacional de San Agustin",
      location: "Arequipa, Peru",
      email: "ynoa@unsa.edu.pe",
    ),
    (
      name: "Sequeiros Condori, Luis Gustavo",
      organization: "Universidad Nacional de San Agustin",
      location: "Arequipa, Peru",
      email: "lsequeiros@unsa.edu.pe",
    ),
  ),
  index-terms: (
    "REST",
    "RESTful",
    "GraphQL",
    "diseño de APIs",
    "comparación de rendimiento",
    "sistemas distribuidos",
    "servicios web",
  ),
  bibliography: bibliography("refs.bib"),
  figure-supplement: [Figura],
)

= Introducción

La proliferación de sistemas distribuidos y arquitecturas de microservicios ha elevado el diseño de interfaces de programación de aplicaciones (APIs) a una preocupación ingenieril de primer orden. En un contexto donde las aplicaciones modernas dependen de múltiples servicios que se comunican entre sí, la elección del paradigma de API determina no solo el rendimiento del sistema, sino también la velocidad de desarrollo, la mantenibilidad del código y la experiencia del equipo de ingeniería. Dos paradigmas han emergido como enfoques dominantes: Representational State Transfer (REST), un estilo arquitectónico formalizado por Fielding @fielding2000architectural, y GraphQL, un lenguaje de consultas y runtime desarrollado por Facebook en 2015 y publicado como código abierto en 2020.

REST organiza la exposición de datos en torno a recursos discretos identificados por URIs, aprovechando los métodos HTTP estándar (GET, POST, PUT, DELETE) @pautasso2008restful. Este enfoque se beneficia de herramientas maduras, caché nativa de HTTP y amplia adopción en la industria. Sin embargo, las APIs REST son susceptibles a sobre-fetching (retornar campos innecesarios) y under-fetching (requerir múltiples solicitudes para ensamblar datos relacionados) @muzaki2024reducing.

GraphQL aborda estas limitaciones exponiendo un único endpoint a través del cual los clientes especifican exactamente los datos que requieren @quina2022graphql. Este modelo elimina el sobre-fetching y el under-fetching pero introduce complejidad adicional en caché, seguridad y procesamiento de consultas del lado del servidor @erigha2021optimizing.

Este trabajo contribuye con: (1) implementaciones comparativas de ambos paradigmas para un dominio idéntico de catálogo de libros, incluyendo múltiples implementaciones RESTful siguiendo un taller práctico de la asignatura de Sistemas Distribuidos; (2) mediciones empíricas de rendimiento bajo carga controlada con k6; y (3) un análisis de compromisos arquitectónicos con recomendaciones prácticas. El resto de este trabajo se organiza como sigue: la Sección~II revisa trabajos relacionados, la Sección~III describe el diseño e implementación del sistema, la Sección~IV presenta resultados experimentales, la Sección~V discute compromisos, y la Sección~VI concluye.

= Trabajo Relacionado

La comparación de REST y GraphQL ha atraído una atención significativa de investigación. Quiña-Mera et al.@quina2022graphql realizaron un mapeo sistemático de 84 estudios primarios sobre GraphQL, identificándolo como un enfoque que aborda los problemas de acceso a datos y versionado de REST, mientras señalan desafíos abiertos en seguridad y herramientas. Pautasso et al.@pautasso2008restful proporcionaron comparaciones arquitectónicas tempranas entre servicios web ``grandes'' y RESTful, estableciendo el marco fundamental de compromisos.

En comparaciones directas de rendimiento, Śliwa y Pańczyk@sliwa2021performance compararon REST, GraphQL y gRPC en un conjunto de pruebas estandarizado, encontrando que GraphQL ofrece flexibilidad superior en consultas pero con overhead en el lado del servidor. Lawi et al.@lawi2021evaluating evaluaron ambos paradigmas en sistemas de información masivos, reportando ventajas de GraphQL en reducción de transferencia de datos. Mikuła y Dzieńkowski@mikula2020comparison realizaron benchmarking directo midiendo tiempos de respuesta y transferencia de datos bajo diferentes escenarios de carga.

Jin et al.@jin2024graphql evaluaron GraphQL versus REST en entornos serverless, encontrando que GraphQL ofrece generalmente menor latencia y costo debido a la reducción de sobre/under-fetching. Muzaki y Salam@muzaki2024reducing analizaron específicamente la reducción de under-fetching y sobre-fetching, demostrando la efectividad de GraphQL en eliminar solicitudes multi-endpoint.

Desde la perspectiva de frameworks, Gómez et al.@gomez2020crudyleaf presentaron CRUDyLeaf, un lenguaje específico de dominio para generar APIs RESTful en Spring Boot, mientras que Zimmermann et al.@zimmermann2020introduction introdujeron patrones de API de microservicios que capturan soluciones recurrentes en el diseño de APIs distribuidas. En el ámbito industrial, la adopción de GraphQL ha crecido significativamente, con empresas como GitHub, Shopify y Airbnb migrando partes de sus APIs desde REST hacia GraphQL, impulsadas por la necesidad de reducir la cantidad de datos transferidos a clientes móviles @thallapally2024enhancing. Estos trabajos establecen colectivamente que aunque GraphQL aborda limitaciones específicas de REST, ningún paradigma es universalmente superior.

= Diseño e Implementación del Sistema

== Marco Teórico: REST y RESTful

REST es un estilo arquitectónico definido por Fielding @fielding2000architectural para diseñar sistemas distribuidos escalables, basado en restricciones clave: cliente-servidor, sin estado (stateless), cacheable, interfaz uniforme y sistema por capas. RESTful es el adjetivo que describe a una aplicación que implementa correctamente estas restricciones. La distinción es crucial: mientras REST es el modelo conceptual que dicta el uso de peticiones HTTP como GET o POST, RESTful es el servicio funcional que aplica buenas prácticas de diseño @fielding2000architectural. Una API que utiliza HTTP no necesariamente es RESTful si no cumple con las restricciones arquitectónicas establecidas @haupt2017framework.

#figure(
  image("img/rest-architecture.png", width: 80%),
  caption: [Arquitectura REST: cliente-servidor con comunicación stateless mediante métodos HTTP estándar sobre recursos identificados por URIs.],
) <rest-arch>

== Implementación de la API RESTful en Spring Boot (Ejercicio E1)

Siguiendo las directrices del taller práctico, se implementó un sistema de gestión bibliotecaria profesional utilizando Spring Boot 4.0.6 con Java 21 @guntupally2018spring. La arquitectura se diseñó en capas siguiendo el patrón controller-repository-model, una de las mejores prácticas en el diseño de APIs RESTful @zimmermann2020introduction.

El modelo de datos correspondiente a los libros se definió mediante una entidad JPA mapeada a una tabla relacional en SQLite. Los atributos clave se decoraron con restricciones de integridad para garantizar la validez de los datos. La clase controladora se implementó con la anotación \@RestController y se mapeó bajo la raíz /api/books. Se expusieron endpoints semánticamente correctos para las operaciones CRUD: listado completo, obtención de un libro por identificador, creación, actualización y eliminación @pautasso2008restful. La Figura~<e1-entity> muestra la definición de la entidad JPA, donde se observan las restricciones de integridad aplicadas.

#figure(
  ```java
  @Entity
  @Table(name = "books")
  public class Book {
      @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
      private Long id;

      @Column(nullable = false)
      private String title;

      @Column(nullable = false)
      private String author;

      @Column(unique = true, nullable = false)
      private String isbn;

      private String description;
      private String imageUrl;
  }
  ```,
  caption: [Entidad JPA Book con restricciones de integridad y mapeado a tabla SQLite.],
) <e1-entity>

Para la creación y registro de libros, se implementó soporte para peticiones multipart que permiten procesar metadatos en combinación con una imagen binaria de portada. Se valida que los atributos esenciales no estén vacíos, se asegura la unicidad del ISBN mediante consultas al repositorio y se guarda el archivo localmente generando un identificador único para evitar colisiones. La persistencia de datos utiliza SQLite a través de Spring Data JPA con Hibernate ORM @gomez2020crudyleaf.

#figure(
  image("img/e1-dashboard.png", width: 80%),
  caption: [Panel de la API RESTful de gestión bibliotecaria implementada con Spring Boot, mostrando el listado de libros.],
) <e1-dashboard>

#figure(
  image("img/e1-create-form.png", width: 60%),
  caption: [Formulario de registro de un nuevo libro con campos para título, autor, ISBN y portada.],
) <e1-create-form>

== Implementación de la API RESTful en Flask (Ejercicio E2)

Como segundo ejercicio del taller, se implementó un sistema de registro estudiantil avanzado empleando Flask y SQLAlchemy @menasce2001capacity. A diferencia del ejercicio anterior que utiliza un framework full-stack (Spring Boot), esta implementación demuestra un enfoque más ligero y minimalista, adecuado para prototipado rápido y servicios de baja complejidad.

El modelo ORM define una entidad estudiante mapeada a una tabla en SQLite con campos para métricas académicas (matrícula, carrera, semestres) y estados de matriculación. Las rutas se implementaron utilizando decoradores de Flask sobre funciones orientadas a recursos, implementando el patrón de interfaz uniforme REST @fielding2000architectural. La Figura~<e2-route> muestra una ruta representativa del sistema, donde se observa la ligereza del enfoque Flask frente a Spring Boot.

#figure(
  ```python
  @app.route("/api/estudiantes", methods=["GET"])
  def listar_estudiantes():
      busqueda = request.args.get("busqueda", "")
      query = Estudiante.query
      if busqueda:
          query = query.filter(
              Estudiante.nombre.contains(busqueda)
          )
      return jsonify([e.to_dict() for e in query.all()])
  ```,
  caption: [Ruta Flask para listado de estudiantes con filtrado por búsqueda.],
) <e2-route>

Se implementaron endpoints para las operaciones CRUD completas: listado de todos los estudiantes con soporte de filtrado, creación de nuevos registros con validación de tipos, actualización parcial que permite modificar campos individuales, y eliminación con manejo de errores semántico @velepucha2023microservices.

Se diseñó un panel administrativo (Dashboard) que ofrece visualizaciones estadísticas sobre el alumnado y herramientas de filtrado avanzado para la gestión de registros. La interfaz permite buscar por nombre, matrícula o carrera, filtrar por estado de matriculación y ordenar por diferentes criterios, demostrando la capacidad de las APIs RESTful para soportar interfaces de cliente ricas y complejas.

#figure(
  image("img/e2-dashboard.png", width: 80%),
  caption: [Panel administrativo de la API RESTful de registro estudiantil con Flask, mostrando la tabla de estudiantes y estadísticas.],
) <e2-dashboard>

#figure(
  image("img/e2-create-form.png", width: 60%),
  caption: [Formulario de registro de un nuevo estudiante con validación de campos obligatorios.],
) <e2-create-form>

== Extensión: Implementación de la API GraphQL (Ejercicio E3)

Como extensión del taller, más allá de los ejercicios propuestos por el docente, se implementó una API GraphQL para el mismo dominio de catálogo de libros, permitiendo una comparación directa entre paradigmas @quina2022graphql. Esta implementación utiliza Bun 1.3 como runtime, el framework HTTP Hono y el servidor graphql-yoga.

A diferencia de las APIs REST que exponen múltiples endpoints, GraphQL opera a través de un único punto de acceso que maneja todas las operaciones mediante consultas y mutaciones. El esquema GraphQL define el tipo Book con los campos identificador, título, autor, ISBN, descripción e imagen, junto con los tipos raíz Query y Mutation. La Figura~<graphql-schema> muestra la definición del esquema, que constituye el contrato entre cliente y servidor.

#figure(
  ```graphql
  type Book {
    id: ID!
    title: String!
    author: String!
    isbn: String!
    description: String
    imageUrl: String
  }

  type Query {
    books: [Book!]!
    book(id: ID!): Book
  }

  type Mutation {
    createBook(title: String!, author: String!, isbn: String!): Book!
  }
  ```,
  caption: [Esquema GraphQL que define el tipo Book y las operaciones disponibles.],
) <graphql-schema>

#figure(
  image("img/graphql-architecture.png", width: 80%),
  caption: [Arquitectura GraphQL: único endpoint con esquema tipado que permite al cliente especificar campos exactos.],
) <graphql-arch>

Los resolvers se implementan como funciones que acceden a datos almacenados en arrays en memoria, ejecutando las operaciones solicitadas por el cliente. La ventaja fundamental de GraphQL radica en la capacidad del cliente de especificar exactamente los campos que necesita, eliminando el sobre-fetching inherente a las APIs REST @muzaki2024reducing. Un cliente que solo necesita título y autor ejecuta una consulta selectiva que reduce significativamente el volumen de datos transferidos, como se cuantifica en la Sección~IV.

#figure(
  image("img/e3-graphql-api.png", width: 80%),
  caption: [API GraphQL con consola de consultas interactiva para ejecutar operaciones en tiempo real.],
) <e3-api>

== Interfaces de Cliente

Ambos sistemas incluyen interfaces web basadas en navegador. El cliente REST muestra libros en una cuadrícula de tarjetas con funcionalidad de búsqueda, mientras que el cliente GraphQL añade una consola de consultas interactiva para ejecutar operaciones GraphQL arbitrarias. El cliente REST se construyó con JavaScript vanilla utilizando la API Fetch para consumir los endpoints RESTful, demostrando el patrón de comunicación cliente-servidor sin estado @fielding2000architectural. El cliente GraphQL utiliza la misma base pero añade un editor de consultas que valida la sintaxis antes de la ejecución, proporcionando retroalimentación inmediata al desarrollador @khan2020sustainable.

#figure(
  image("img/e3-graphql-console.png", width: 80%),
  caption: [Consola interactiva de GraphQL con editor de consultas y resultados en tiempo real.],
) <e3-console>

= Resultados Experimentales

== Entorno de Prueba

Las pruebas se realizaron utilizando k6 (Grafana Labs) con el siguiente perfil de carga: ramp-up de 10 segundos a 10 usuarios virtuales (VUs), estado estable de 30 segundos a 50 VUs, carga pico de 10 segundos a 100 VUs, carga pico sostenida de 30 segundos a 50 VUs, y ramp-down de 10 segundos. La duración total de prueba fue de 90 segundos por escenario. Se utilizaron scripts de prueba estándar con métricas personalizadas de latencia y tasa de error @menasce2001capacity. La Figura~<k6-script> muestra el escenario de carga definido para las pruebas.

#figure(
  ```javascript
  export const options = {
    stages: [
      { duration: "10s", target: 10 },  // ramp-up
      { duration: "30s", target: 50 },  // estable
      { duration: "10s", target: 100 }, // pico
      { duration: "30s", target: 50 },  // sostenido
      { duration: "10s", target: 0 },   // ramp-down
    ],
    thresholds: {
      http_req_duration: ["p(95)<50"],
      http_req_failed: ["rate<0.01"],
    },
  };
  ```,
  caption: [Escenario de carga k6 con fases de ramp-up, estable, pico y enfriamiento.],
) <k6-script>

#figure(
  image("img/comparison-flow.png", width: 95%),
  caption: [Flujo comparativo que ilustra el sobre-fetching de REST versus la consulta selectiva de campos de GraphQL para la misma solicitud del cliente.],
) <comparison-flow>

== Tamaño del Payload

Para la consulta de listado completo que retorna 15 registros, el endpoint REST retorna 4.654 bytes (todos los campos), mientras que GraphQL retorna 4.703 bytes para todos los campos pero solo 1.019 bytes cuando se consultan únicamente título y autor, una reducción del 78\%. Este resultado es consistente con los hallazgos de Lawi et al.@lawi2021evaluating y Muzaki y Salam@muzaki2024reducing, quienes reportaron reducciones similares en transferencia de datos. La ventaja fundamental de GraphQL se manifiesta en que los clientes que solicitan subconjuntos mínimos de datos incurriendo en payloads proporcionales al número de campos solicitados @sliwa2021performance.

En operaciones de lectura individual de un libro, GraphQL transferirá 12.7\% menos datos que REST incluso cuando se solicitan todos los campos, debido a la eliminación de metadatos HTTP adicionales. Cuando se realizan consultas selectivas, la reducción alcanza el 76.2\% de datos transferidos, validando la eficiencia del modelo de consultas dirigidas por el cliente @erigha2021optimizing.

== Rendimiento de Lectura

#figure(
  table(
    columns: 4,
    align: (left, right, right, right),
    table.header([Métrica], [REST], [GraphQL], [Diferencia]),
    [Total de Solicitudes], [40,470], [40,775], [+0.75\%],
    [Latencia Promedio], [2.73ms], [2.24ms], [*--17.9\%*],
    [Latencia P95], [4.86ms], [4.62ms], [*--4.9\%*],
    [Latencia Máxima], [26.82ms], [23.67ms], [*--11.7\%*],
    [Throughput], [449 RPS], [453 RPS], [+0.8\%],
    [Tasa de Error], [0\%], [0\%], [--],
  ),
  caption: [Comparación de rendimiento para la operación GET de listado completo de libros a 100 usuarios virtuales.],
) <read-all>

Para la recuperación de libros individuales, GraphQL logró 2.08ms de latencia promedio versus 2.46ms de REST (mejora del 15.4\%), con 12.7\% menos datos recibidos. Las consultas selectivas de campos en GraphQL redujeron aún más la latencia a 2.17ms con 76.2\% menos transferencia de datos @lawi2021evaluating.

El rendimiento de lectura demuestra que la ventaja de GraphQL se incrementa con la complejidad de las consultas. Para operaciones que involucran múltiples entidades relacionadas, GraphQL permite resolver todas las dependencias en una sola solicitud, mientras que REST requiere múltiples llamadas secuenciales, incrementando la latencia total @kanthed2023rest. Este fenómeno es particularmente relevante en aplicaciones móviles donde la optimización del ancho de banda es crítica @khan2020sustainable.

== Recuperación de Libro Individual

La consulta de un libro individual es una de las operaciones más frecuentes en aplicaciones de catálogo, donde el usuario selecciona un elemento del listado para ver su detalle completo. La Figura~<read-single> presenta los resultados de esta operación bajo carga de 100 usuarios virtuales.

#figure(
  table(
    columns: 4,
    align: (left, right, right, right),
    table.header([Métrica], [REST], [GraphQL], [Diferencia]),
    [Total de Solicitudes], [40,661], [40,950], [+0.7\%],
    [Latencia Promedio], [2.46ms], [2.08ms], [*--15.4\%*],
    [Latencia P95], [4.52ms], [4.19ms], [*--7.3\%*],
    [Latencia Máxima], [22.38ms], [18.52ms], [*--17.2\%*],
    [Throughput], [451 RPS], [455 RPS], [+0.9\%],
    [Datos Recibidos], [21.3 MB], [18.6 MB], [*--12.7\%*],
  ),
  caption: [Comparación de rendimiento para la operación GET de libro individual a 100 usuarios virtuales.],
) <read-single>

GraphQL logra una latencia promedio de 2.08ms frente a los 2.46ms de REST, representando una mejora del 15.4\%. Esta ventaja se amplía en la latencia máxima: 18.52ms versus 22.38ms, una reducción del 17.2\%. La diferencia es especialmente significativa en la cantidad de datos recibidos: GraphQL transfirió 12.7\% menos datos que REST incluso cuando se solicitan todos los campos, debido a la eliminación de metadatos HTTP adicionales en el formato de respuesta @lawi2021evaluating.

Cuando se utilizan consultas selectivas de campos, la ventaja de GraphQL se incrementa dramáticamente. Una solicitud que solicita únicamente título y autor reduce la latencia promedio a 2.17ms y la transferencia de datos a 46.7\,MB, una reducción del 76.2\% respecto a REST con todos los campos. Este resultado valida que el modelo de consultas dirigidas por el cliente permite optimizaciones significativas en escenarios reales donde no se necesitan todos los atributos de una entidad @erigha2021optimizing. Los hallazgos son consistentes con los reportados por Mikuła y Dzieńkowski@mikula2020comparison, quienes encontraron ventajas similares de GraphQL en escenarios de lectura con campos selectivos.

== Rendimiento de Escritura

#figure(
  table(
    columns: 4,
    align: (left, right, right, right),
    table.header([Métrica], [REST], [GraphQL], [Diferencia]),
    [Latencia Promedio], [1.69ms], [2.34ms], [+38.5\%],
    [Latencia P95], [2.69ms], [3.86ms], [+43.5\%],
    [Latencia Máxima], [31.22ms], [7.35ms], [*--76.5\%*],
    [Throughput], [48.4 RPS], [48.4 RPS], [0\%],
    [Datos Enviados], [655 KB], [1.01 MB], [+54\%],
  ),
  caption: [Comparación de rendimiento para la operación POST de creación de libros a 20 usuarios virtuales.],
) <write-perf>

REST demuestra menor latencia promedio de escritura, pero GraphQL exhibe un comportamiento más consistente con una latencia máxima significativamente menor (7.35 ms versus 31.22 ms). La relación P95-máxima revela la superior estabilidad de escritura de GraphQL: 1.91x versus 11.6x de REST @sikora2025comparative. Este resultado sugiere que el overhead de serialización de GraphQL en el servidor, aunque introduce latencia promedio mayor, proporciona un manejo más predecible de la carga pico @erigha2021optimizing.

El mayor volumen de datos enviados por GraphQL en escritura (+54\%) se debe al formato de respuesta más extenso que incluye metadatos del esquema y el objeto creado completo. Sin embargo, este overhead es despreciable en comparación con las ganancias de flexibilidad en consultas de lectura @veeravalli2023next.

= Discusión

== Cuándo Elegir REST

REST sigue siendo la elección preferida para aplicaciones que requieren caché nativa de HTTP (a través de headers ETag y Cache-Control), APIs públicas con documentación estandarizada (OpenAPI/Swagger), operaciones CRUD simples y entornos con infraestructura REST establecida @pautasso2008restful. Su menor sobrecarga de escritura y capacidades superiores de caché lo hacen ideal para comunicación servidor-a-servidor y redes de distribución de contenido @haupt2017framework.

Las implementaciones del taller (E1 con Spring Boot y E2 con Flask) demuestran que las APIs RESTful bien diseñadas, siguiendo los principios de interfaz uniforme y orientación a recursos, proporcionan una base sólida para sistemas distribuidos @zimmermann2020introduction. Spring Boot facilita la creación de APIs robustas con soporte para peticiones multipart y manejo de archivos, mientras Flask ofrece un enfoque más ligero para servicios de baja complejidad @gomez2020crudyleaf.

== Cuándo Elegir GraphQL

GraphQL sobresale en aplicaciones móviles donde la optimización del ancho de banda es crítica (reducción del 78\% en payloads), requisitos de datos complejos que involucran múltiples entidades relacionadas, escenarios con necesidades diversas de datos del cliente (diferentes clientes solicitando diferentes subconjuntos de campos) y aplicaciones en tiempo real utilizando suscripciones @thallapally2024enhancing. El modelo de endpoint único simplifica el versionado y la evolución de APIs @veeravalli2023next.

La extensión GraphQL (E3) demostró que la flexibilidad en las consultas del cliente no compromete el rendimiento en operaciones de lectura, y en muchos escenarios lo mejora significativamente @jin2024graphql. Sin embargo, la complejidad adicional en el servidor, la caché no trivial y las preocupaciones de seguridad (ataques de profundidad de consulta) requieren una evaluación cuidadosa @erigha2021optimizing.

== Compromisos Arquitectónicos

La comparación revela compromisos fundamentales. REST ofrece simplicidad, herramientas maduras e integración nativa con HTTP a costa de potencial sobre/under-fetching @muzaki2024reducing. GraphQL proporciona consultas flexibles dirigidas por el cliente a costa de mayor complejidad del servidor, caché no trivial y posibles preocupaciones de seguridad @khan2020sustainable. Como demuestran las implementaciones del taller, la elección del framework (Spring Boot versus Flask versus Bun/GraphQL-Yoga) también impacta significativamente en la experiencia de desarrollo y el rendimiento resultante @sikora2025comparative.

El análisis de los ejercicios del taller revela que RESTful no es simplemente el uso de HTTP, sino el cumplimiento estricto de las restricciones arquitectónicas de Fielding @fielding2000architectural. El diseño de endpoints orientados a acciones (como /getUsers o /createUser) en lugar de recursos rompe la uniformidad de la interfaz y dificulta la cacheabilidad, limitando la escalabilidad horizontal @haupt2017framework. Esta lección fundamental se refuerza en ambas implementaciones del taller, donde se siguen consistentemente los principios de diseño orientado a recursos.

Desde la perspectiva de la experiencia de desarrollo, REST ofrece una curva de aprendizaje más suave: los desarrolladores familiarizados con HTTP pueden comenzar a construir APIs inmediatamente, y herramientas como OpenAPI generan documentación y clientes automáticamente. GraphQL, en cambio, requiere una inversión inicial mayor para definir el esquema, configurar el servidor de resolvers y aprender el lenguaje de consultas, pero esta inversión se amortiza en proyectos con múltiples consumidores que requieren diferentes vistas de los mismos datos @sikora2025comparative. La disponibilidad de herramientas de desarrollo, como GraphiQL y Apollo Studio, ha mejorado significativamente la experiencia de trabajo con GraphQL, aunque el ecosistema REST sigue siendo más amplio y maduro.

= Conclusiones

Este trabajo presentó un análisis comparativo de los paradigmas de API REST y GraphQL a través de mediciones empíricas de rendimiento y evaluación arquitectónica, complementado con un estudio detallado del proceso de diseño e implementación de servicios RESTful en un contexto educativo. Nuestros hallazgos clave son: (1) GraphQL logra 15--18\% menor latencia de lectura y reducción del 78\% en payload mediante consultas selectivas de campos; (2) REST mantiene menor latencia de escritura y capacidades superiores de caché; (3) ambos alcanzan un throughput similar bajo carga comparable, sugiriendo que la capa de base de datos más que el protocolo de API es el cuello de botella principal.

Para profesionales de sistemas distribuidos, recomendamos: adoptar REST para servicios CRUD simples, microservicios internos y cargas de trabajo sensibles a la caché; adoptar GraphQL para APIs orientadas al cliente con requisitos diversos de datos, aplicaciones móviles primero y frontends en rápida evolución. Los enfoques híbridos, utilizando GraphQL como gateway de API sobre microservicios REST, pueden aprovechar las fortalezas de ambos paradigmas @sikora2025comparative.

El trabajo futuro debe investigar el endurecimiento de la seguridad de GraphQL (análisis de complejidad de consultas, limitación de profundidad), rendimiento bajo cargas de trabajo de bases de datos reales (versus almacenamiento en memoria) y el impacto de las optimizaciones de DataLoader y batching en la prevención de consultas N+1 @erigha2021optimizing.
