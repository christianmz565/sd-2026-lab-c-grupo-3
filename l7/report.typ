#import "/lib.typ": code-block, define, get-var, header-border-color, lab-report, lab-section, table-border-width
#import "/functions.typ": summarize-name
#import "@preview/elembic:1.1.1" as e

#show: e.set_(code-block, lang: "java")

#define("course_name", "Sistemas Distribuidos")
#define("lab_title", "Servicios Web SOAP: Implementacion y Consumo con JAX-WS")
#define("lab_number", "07")
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

    #link("https://github.com/christianmz565/sd-2026-lab-c-grupo-3/tree/main/l7")

    = REPLICACION DE EJERCICIOS RESUELTOS

    Antes de iniciar, se considero el entorno recomendado: NetBeans para el servidor SOAP con GlassFish y JDK 7+, y Eclipse para el cliente Java. Para pruebas adicionales se tiene disponible SoapUI.

    == Ejercicio Resuelto: Servicio SOAP de Usuarios

    Siguiendo las indicaciones del laboratorio, se implemento un servicio SOAP en Java con JAX-WS. El modelo `User` mantiene una lista estatica de usuarios, mientras que la interfaz `SOAPI` expone operaciones para listar y agregar.

    Pasos realizados en el ejercicio resuelto:
    1. Creacion de la aplicacion web en NetBeans para el servidor.
    2. Definicion del modelo `User` con datos iniciales.
    3. Exposicion de la interfaz `SOAPI` y la implementacion `SOAPImpl`.
    4. Despliegue del servicio y generacion del WSDL en `http://localhost:1516/WS/Users?wsdl`.
    5. Consumo del servicio desde un cliente Java.

    #code-block(
      "l7/src/e1/lab7/e1/User.java",
      snippet: "model",
      lang: "java",
    )

    La interfaz del servicio define los metodos `getUsers` y `addUser`, mientras que la clase `SOAPImpl` implementa la logica de negocio.

    #code-block(
      "l7/src/e1/lab7/e1/SOAPI.java",
      snippet: "interface",
      lang: "java",
    )

    #code-block(
      "l7/src/e1/lab7/e1/SOAPImpl.java",
      snippet: "impl",
      lang: "java",
    )

    El endpoint se publica localmente mediante `Endpoint.publish` para exponer el WSDL.

    #code-block(
      "l7/src/e1/lab7/e1/PublishService.java",
      snippet: "publish",
      lang: "java",
    )

    Para el consumo del servicio se utiliza un cliente Java que obtiene el proxy con `Service.create`, consulta la lista inicial, agrega un usuario y valida el cambio.

    #code-block(
      "l7/src/e1/lab7/e1/UserClient.java",
      snippet: "client",
      lang: "java",
    )

    = SOLUCION DE EJERCICIOS PROPUESTOS

    == Ejercicio Propuesto: Servicio SOAP de Ventas en Linea

    Se desarrollo un servicio SOAP con operaciones CRUD de productos (crear, leer, actualizar y eliminar logico mediante stock). La entidad `Item` contiene nombre, cantidad y costo, y mantiene un inventario inicial.

    #code-block(
      "l7/src/e2/lab7/e2/model/Item.java",
      snippet: "model",
      lang: "java",
    )

    La interfaz `SOAPI` expone operaciones de lectura, compra, registro, actualizacion y eliminacion logica de items, y `SOAPImpl` delega la logica al modelo.

    #code-block(
      "l7/src/e2/lab7/e2/soap/SOAPI.java",
      snippet: "interface",
      lang: "java",
    )

    #code-block(
      "l7/src/e2/lab7/e2/soap/SOAPImpl.java",
      snippet: "impl",
      lang: "java",
    )

    El servicio se publica en una URL local para pruebas.

    #code-block(
      "l7/src/e2/lab7/e2/demo/PublishService.java",
      snippet: "publish",
      lang: "java",
    )

    #table(
      columns: (1fr, 1fr, 1fr),
      stroke: table-border-width + header-border-color,
      table.cell(fill: header-border-color, align: center)[*Producto*],
      table.cell(fill: header-border-color, align: center)[*Cantidad*],
      table.cell(fill: header-border-color, align: center)[*Precio*],
      [Gaseosa], [15], [5.2],
      [Galletas], [10], [1.6],
      [Celular], [12], [900.0],
    )

    Luego de una operacion de actualizacion, el stock de Galletas queda en 18 unidades con precio 2.4, validando la funcion `setItem`.
  ]

  #lab-section("INVESTIGACION")[
    #set par(justify: true)

    == Aplicacion SoapUI

    SoapUI es una herramienta para probar, simular y generar codigo de servicios web de forma agil partiendo del WSDL. Permite crear suites de prueba para operaciones SOAP y validar el contrato del servicio sin escribir clientes manuales.

    == Pasos para probar un servicio en SoapUI

    1. Nuevo proyecto: asignar nombre e ingresar la URL del WSDL (por ejemplo el servicio Global Weather).
    2. Generacion de requests: se crean automaticamente plantillas XML para cada operacion disponible (GetCitiesByCountry, GetWeather).
    3. Analisis de interfaces: la herramienta separa interfaces SOAP 1.1 y SOAP 1.2 para evaluar compatibilidad.
  ]

  #lab-section("CONCLUSION")[
    #show heading: set text(weight: "bold")
    #set par(justify: true)

    El desarrollo de servicios SOAP en Java es directo y amigable, permitiendo el despliegue local rapido. La separacion modular de clases (modelo, interfaz e implementacion) facilita el mantenimiento y el consumo distribuido de los servicios.
  ]

  #lab-section("REFERENCIAS Y BIBLIOGRAFÍA")[
    [1] Ceballos, F. J. (2006). Java 2, Curso de programacion. Mexico: Alfaomega, Ra-Ma.

    [2] Deitel, H. M., & Deitel, P. J. (2004). Como programar en Java. Mexico: Pearson Educacion.

    [3] Oracle. (2024). JAX-WS Reference Implementation. https://eclipse-ee4j.github.io/metro-jax-ws/
  ]

  #lab-section("ANEXOS")[
    #set par(justify: true)

    == Ejercicio Resuelto: Servicio SOAP de Usuarios

    === Modelo User
    #code-block("l7/src/e1/lab7/e1/User.java", lang: "java")

    === Interfaz del Servicio
    #code-block("l7/src/e1/lab7/e1/SOAPI.java", lang: "java")

    === Implementacion del Servicio
    #code-block("l7/src/e1/lab7/e1/SOAPImpl.java", lang: "java")

    === Publicacion del Servicio
    #code-block("l7/src/e1/lab7/e1/PublishService.java", lang: "java")

    === Cliente de Pruebas
    #code-block("l7/src/e1/lab7/e1/UserClient.java", lang: "java")

    == Ejercicio Propuesto: Servicio SOAP de Ventas

    === Modelo Item
    #code-block("l7/src/e2/lab7/e2/model/Item.java", lang: "java")

    === Interfaz del Servicio
    #code-block("l7/src/e2/lab7/e2/soap/SOAPI.java", lang: "java")

    === Implementacion del Servicio
    #code-block("l7/src/e2/lab7/e2/soap/SOAPImpl.java", lang: "java")

    === Publicacion del Servicio
    #code-block("l7/src/e2/lab7/e2/demo/PublishService.java", lang: "java")
  ]
]
