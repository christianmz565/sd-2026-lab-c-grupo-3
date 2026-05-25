#import "/lib.typ": code-block, define, get-var, header-border-color, lab-report, lab-section, table-border-width
#import "/functions.typ": summarize-name
#import "@preview/elembic:1.1.1" as e

#show: e.set_(code-block, lang: "java")

#define("course_name", "Sistemas Distribuidos")
#define("lab_title", "REST vs. RESTful: Diseño e Implementación de Servicios Distribuidos")
#define("lab_number", "06")
#define("instructor_name", "Mg. Maribel Molina Barriga")
#define("members", (
  "Bedregal Perez Daniel",
  "Jara Mamani Mariel Alisson",
  "Mestas Zegarra Christian Raul",
  "Noa Camino Yenaro Joel",
  "Sequeiros Condori Luis Gustavo",
))

#context {
  define("members_abbr_list", get-var("members").map(name => summarize-name(name)).join(" - "))
}

#lab-report()[
  #set image(width: 78%)
  #set list(indent: 2pt)
  #show raw.where(block: false): it => box(
    inset: (x: 0.5pt),
  )[#it]

  #lab-section("RESULTADOS Y PRUEBAS")[
    #show heading: set text(weight: "bold")
    #set par(justify: true)

    = ENLACE A GITHUB

    #link("https://github.com/christianmz565/sd-2026-lab-c-grupo-3/tree/main/l6")

    = REPLICACIÓN DE EJERCICIOS RESUELTOS

    == Ejercicio Resuelto: API RESTful de Gestión de Productos

    Siguiendo las indicaciones del docente, se implementó una API RESTful básica utilizando Python y el framework Flask. El backend gestiona un recurso de "productos" permitiendo operaciones GET, POST y DELETE.

    #code-block(
      "l6/snippets/s1/app.py",
      snippet: "backend",
      lang: "python",
      prefix: "#",
    )

    Para el consumo de la API, se desarrolló un cliente HTML minimalista que emplea la Fetch API de JavaScript para realizar peticiones asíncronas al servidor y renderizar la lista de productos dinámicamente.

    #code-block(
      "l6/snippets/s1/index.html",
      snippet: "fetch",
      lang: "javascript",
      prefix: "//",
    )

    A continuación se muestra la validación de los endpoints mediante comandos `curl`, donde se observa la creación y eliminación exitosa de recursos, así como la persistencia temporal en memoria.

    #figure(
      image("img/lab/s1_api_test.png"),
      caption: [Validación de la API de Productos mediante CURL.],
    )

    = SOLUCIÓN DE EJERCICIOS PROPUESTOS

    == Ejercicio 1: API RESTful Biblioteca (Java + Spring Boot)

    Se implementó un sistema de gestión bibliotecaria profesional utilizando Spring Boot. El controlador de la API expone endpoints para la gestión integral de libros, soportando la subida de imágenes de portada y almacenamiento en una base de datos SQLite.

    #code-block(
      "l6/snippets/e1/BookApiController.java",
      snippet: "controller",
      lang: "java",
      prefix: "//",
    )

    El modelo de datos se definió utilizando JPA, asegurando que cada libro posea atributos obligatorios como título, autor e ISBN único, además de una descripción opcional y una URL para la imagen de portada.

    #code-block(
      "l6/snippets/e1/Book.java",
      lang: "java",
    )

    La validación de la API se realizó mediante pruebas de carga de datos, verificando que las restricciones de unicidad del ISBN y el manejo de archivos multipart funcionen correctamente según los principios RESTful.

    #figure(
      image("img/lab/e1_curl.png"),
      caption: [Pruebas de la API de Biblioteca mediante CURL.],
    )

    Se desarrolló una interfaz web moderna y responsiva para interactuar con la biblioteca de forma intuitiva, permitiendo el registro y edición de libros mediante formularios dinámicos.

    #figure(
      grid(
        columns: (1fr, 1fr),
        gutter: 1em,
        image("img/lab/e1_gui_create_form.png", width: 100%),
        image("img/lab/e1_gui_create_result.png", width: 100%),
      ),
      caption: [Interfaz gráfica de la biblioteca: Formulario de registro y vista de colección.],
    )

    == Ejercicio 2: API RESTful Estudiantes (Python)

    Este ejercicio consistió en la creación de un sistema de registro estudiantil avanzado empleando Flask y SQLAlchemy. Se implementaron rutas para el registro, consulta, actualización y eliminación de perfiles académicos.

    #code-block(
      "l6/snippets/e2/routes.py",
      snippet: "routes",
      lang: "python",
      prefix: "#",
    )

    La persistencia de datos se gestiona a través de un modelo ORM que mapea la entidad `Estudiante` a una tabla en SQLite, incluyendo campos para métricas académicas y estados de matriculación.

    #code-block(
      "l6/snippets/e2/models.py",
      lang: "python",
    )

    A continuación se presenta la ejecución del cliente consumidor, el cual automatiza una serie de peticiones HTTP para validar el ciclo de vida completo de un recurso estudiantil en el servidor.

    #figure(
      image("img/lab/e2_curl.png"),
      caption: [Ejecución del cliente de pruebas para la API de Estudiantes.],
    )

    Finalmente, se diseñó un panel administrativo (Dashboard) que ofrece visualizaciones estadísticas sobre el alumnado y herramientas de filtrado avanzado para la gestión de registros.

    #figure(
      grid(
        columns: (1fr, 1fr),
        gutter: 1em,
        image("img/lab/e2_gui_create_form.png", width: 100%),
        image("img/lab/e2_gui_create_result.png", width: 100%),
      ),
      caption: [Panel de gestión estudiantil: Registro de alumnos y visualización del listado.],
    )

  ]

  #lab-section("CUESTIONARIO")[
    #set par(justify: true)

    == ¿Por qué una API que utiliza HTTP no necesariamente puede considerarse RESTful?

    Porque RESTful no se define simplemente por el uso del protocolo HTTP, sino por el cumplimiento estricto de las restricciones arquitectónicas de REST (Representational State Transfer). Muchas APIs utilizan HTTP solo como un túnel para RPC (Remote Procedure Call), donde los endpoints se nombran según acciones (`/crearUsuario`, `/obtenerDatos`) en lugar de recursos, y no respetan la semántica de los verbos HTTP ni la naturaleza sin estado o la interfaz uniforme (HATEOAS).

    == ¿Qué consecuencias tendría diseñar endpoints orientados a acciones y no a recursos en sistemas distribuidos escalables?

    Diseñar endpoints orientados a acciones (`GET /deleteUser?id=5`) rompe la uniformidad de la interfaz y dificulta la cacheabilidad. En sistemas distribuidos, esto genera una explosión de URIs difíciles de documentar y mantener. Además, impide que intermediarios (como proxies o balanceadores) optimicen las peticiones basándose en la semántica estándar de HTTP, limitando la escalabilidad horizontal y aumentando el acoplamiento entre cliente y servidor.

    == Compare RESTful frente a RPC y explique en qué escenarios empresariales RESTful podría ser una mala elección.

    RESTful se centra en recursos y estado (escalable, desacoplado), mientras que RPC (como gRPC o RMI) se centra en procedimientos (eficiente, contrato fuerte). RESTful podría ser una mala elección en escenarios de baja latencia extrema (comunicación entre microservicios de alto rendimiento), donde el overhead de JSON y las cabeceras HTTP es excesivo. También es inadecuado para sistemas con flujos de datos complejos y multidireccionales que se benefician más de un contrato binario estricto y streaming.
  ]

  #lab-section("CONCLUSIONES Y RECOMENDACIONES")[
    #show heading: set text(weight: "bold")
    #set par(justify: true)

    == CONCLUSIONES

    + La arquitectura RESTful proporciona un estándar claro para la interoperabilidad en sistemas distribuidos, permitiendo que clientes heterogéneos consuman servicios mediante una interfaz uniforme.

    + La distinción entre REST (modelo teórico) y RESTful (implementación práctica) es fundamental para desarrollar APIs que realmente aprovechen las capacidades de optimización del protocolo HTTP.

    + El uso de frameworks modernos como Spring Boot y Flask simplifica enormemente la aplicación de principios RESTful, facilitando la gestión de estados y la serialización de datos.

    == RECOMENDACIONES

    + Se recomienda priorizar siempre el diseño orientado a recursos sobre el orientado a verbos para asegurar que la API sea intuitiva, documentable y compatible con estándares de industria.

    + Es fundamental utilizar correctamente los códigos de estado HTTP (200, 201, 404, 500, etc.) para que el cliente pueda manejar los errores y respuestas de forma semántica y predecible.

    + Para APIs destinadas a producción, se aconseja implementar mecanismos de autenticación (JWT) y limitación de tasa (rate limiting) para proteger los recursos expuestos.
  ]

  #lab-section("REFERENCIAS Y BIBLIOGRAFÍA")[
    [1] Tanenbaum, A.S. (2008). Sistemas distribuidos: principios y paradigmas. México. Pearson Educación.

    [2] Ceballos, F. J. (2006). Java 2, Curso de programación. México: Alfaomega, RaMa.

    [3] Deitel, H. M., & Deitel, P. J. (2004). Cómo programar en Java. México: Pearson Educación.

    [4] García Tomás, J., Ferrando, S., & Piattini, M. (2001). Redes para procesos distribuidos. México: Alfaomega Ra-Ma.

    [5] Fielding, R. (2000). Architectural Styles and the Design of Network-based Software Architectures. Dissertation. University of California, Irvine.

    [6] Pautasso, O., Zimmermann, O., & Leymann, F. (2008). RESTful Web Services vs. "Big" Web Services: Making the Right Architectural Decision. WWW '08.
  ]
]
