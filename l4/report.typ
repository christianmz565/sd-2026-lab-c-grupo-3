#import "/lib.typ": code-block, get-var, header-border-color, lab-report, lab-section, table-border-width
#import "/functions.typ": summarize-name
#import "@preview/elembic:1.1.1" as e

#let doc_title = sys.inputs.at("title", default: "Informe de Laboratorio")
#show: e.set_(code-block, lang: "java")

#let define(name, value) = {
  [#metadata((name: name, value: value)) <var_export>]
}

#define("course_name", "Sistemas Distribuidos")
#define("lab_title", "Programación Distribuida en Java con RMI (Invocación Remota de Métodos)")
#define("lab_number", "04")
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

    #link("https://github.com/christianmz565/sd-2026-lab-c-grupo-3/tree/main/l4")

    = SOLUCIÓN DE EJERCICIO RESUELTO

    == Ejemplo de RMI en Java: Calculadora

    El archivo `Calculator.java` expone la interfaz remota del servicio de cálculo extendiendo la interfaz `java.rmi.Remote` y definiendo los métodos aritméticos fundamentales.

    El archivo `CalculatorImpl.java` proporciona la implementación concreta de la interfaz remota, heredando de la clase `UnicastRemoteObject` para permitir su exportación y el manejo transparente de la capa de referencia.

    El archivo `CalculatorServer.java` actúa como el programa anfitrión que inicializa un objeto de la calculadora y lo registra en el servicio RMI local mediante el método `Naming.rebind(...)`, poniéndolo a disposición de la red bajo el identificador respectivo.

    #code-block(
      "l4/snippets/s1/CalculatorServer.java",
      snippet: "server-bind",
      lang: "java",
    )

    El archivo `CalculatorClient.java` contiene la aplicación que se enlaza al registro de servicios para resolver y obtener una referencia al objeto remoto mediante el proceso de "lookup", invocando luego las rutinas de la calculadora y manejando cualquier excepción de conexión que pudiese surgir.

    #code-block(
      "l4/snippets/s1/CalculatorClient.java",
      snippet: "client-lookup",
      lang: "java",
    )

    A continuación, se muestra el proceso de compilación, levantamiento del registro RMI, ejecución del servidor y finalmente la prueba con múltiples clientes. Se observa que el cliente ejecuta las cuatro operaciones sobre los conjuntos de valores propuestos (7 y 1; 8 y 9).

    #image("img/lab/s1_1.png")
    #image("img/lab/s1_2.png")
    #image("img/lab/s1_3.png")
    #image("img/lab/s1_4.png")

    = SOLUCIÓN DE EJERCICIOS PROPUESTOS

    == Ejercicio 1: Sistema de Farmacia

    El archivo `MedicineInterface.java` define el contrato para los objetos medicina exportados a nivel de red, estableciendo la semántica para consultar el inventario, adquirir dosis de un producto y obtener detalles formateados como cadenas de texto.

    El archivo `Medicine.java` materializa esta interfaz proporcionando la lógica interna para administrar el estado del inventario de un fármaco, gestionando activamente las validaciones de suficiencia de existencias de modo que se arrojen instancias de `StockException` cuando un cliente solicita cantidades superiores al límite disponible.

    #code-block(
      "l4/snippets/e1/Medicine.java",
      snippet: "medicine-impl",
      lang: "java",
    )

    El archivo `StockInterface.java` y su implementación respectiva `Stock.java` estructuran el catálogo general de medicamentos utilizando un mapa `HashMap` que encapsula la base de datos de productos de salud para facilitar los procesos de búsqueda por nombres descriptivos a través del servicio en remoto.

    #code-block(
      "l4/snippets/e1/Stock.java",
      snippet: "stock-impl",
      lang: "java",
    )

    El archivo `ServerSide.java` define el proceso demonio que arranca la instancia de la farmacia e inserta un conjunto inicial de objetos de tipo medicina como Paracetamol o Amoxilina dentro del catálogo antes de exponerlo públicamente en el registro.

    #code-block(
      "l4/snippets/e1/ServerSide.java",
      snippet: "server-setup",
      lang: "java",
    )

    El archivo `ClienteSide.java` suministra la interfaz interactiva para el usuario final en la consola de comandos estándar, implementando un menú recursivo que recupera la colección del inventario para listar los ítems o bien ejecuta la orden directa de compra de insumos médicos restando stock de manera segura.

    #code-block(
      "l4/snippets/e1/ClienteSide.java",
      snippet: "client-menu",
      lang: "java",
    )

    A continuación, se muestra el proceso de compilación, generación de stubs y levantamiento del registro RMI. Posteriormente, el servidor administra el stock y los clientes interactúan mediante un menú listando los medicamentos disponibles y confirmando transacciones.

    #image("img/lab/e1_1.png")
    #image("img/lab/e1_2.png")
    #image("img/lab/e1_3.png")
    #image("img/lab/e1_4.png")

    == Ejercicio 2: Sistema de Tarjetas de Crédito

    El archivo `CreditCardInterface.java` expone de forma distribuida las primitivas financieras para validar compras, verificar saldo y mostrar el historial del plástico.

    El archivo `CreditCardImpl.java` almacena el saldo acumulado en la tarjeta de crédito y la identidad del cliente, asegurando de forma persistente durante las transacciones que la cantidad acumulada no exceda el límite máximo del monto acreditado mediante validaciones internas controladas.

    #code-block(
      "l4/snippets/e2/CreditCardImpl.java",
      snippet: "card-impl",
      lang: "java",
    )

    El archivo `CreditServer.java` implementa el nodo central para el procesador de tarjetas que consolida el registro de crédito del cliente "Juan Perez" e inicia su vinculación global al demonio RMI bajo la identificación `CREDITCARD` dentro del puerto `1099` de la máquina local.

    #code-block(
      "l4/snippets/e2/CreditServer.java",
      snippet: "card-server",
      lang: "java",
    )

    El archivo `CreditClient.java` constituye el agente externo interactivo responsable de establecer contacto con el servicio del gestor de pagos para autorizar transferencias o rechazar gastos no cubiertos informando el saldo posterior a cada operación.

    #code-block(
      "l4/snippets/e2/CreditClient.java",
      snippet: "card-client",
      lang: "java",
    )

    A continuación, se ilustran los comandos de preparación y lanzamiento de la arquitectura distribuida. Durante la evaluación interactiva, se autoriza la compra de 1500 unidades, pero el sistema rechaza exitosamente el siguiente cargo de 6000 debido a la rigurosa validación de límites.

    #image("img/lab/e2_1.png")
    #image("img/lab/e2_2.png")
    #image("img/lab/e2_3.png")
    #image("img/lab/e2_4.png")

    == Ejercicio 3: Servicio de Conversión de Moneda

    El archivo `CurrencyInterface.java` modela de forma abstracta las rutinas de cálculo financiero, proveyendo métodos específicos para la traslación de divisas como soles a euros o soles a dólares con retornos numéricos directos de doble precisión.

    El archivo `CurrencyImpl.java` desarrolla la aplicación del modelo matemático con tasas de cambio predefinidas y estáticas a manera de propiedades constantes, realizando la conversión matemática mediante simples operaciones de división encapsuladas.

    #code-block(
      "l4/snippets/e3/CurrencyImpl.java",
      snippet: "currency-impl",
      lang: "java",
    )

    El archivo `CurrencyServer.java` funciona como el proceso inicializador que aloja y activa el servicio remoto bajo el nombre genérico de `CURRENCY`, manteniéndolo suspendido y operando de fondo para atender concurrentemente diversas peticiones cambiarias.

    #code-block(
      "l4/snippets/e3/CurrencyServer.java",
      snippet: "currency-server",
      lang: "java",
    )

    El archivo `CurrencyClient.java` es el software interactivo que solicita el ingreso explícito de capital en soles desde el usuario y consulta al nodo principal RMI por la contraparte resultante en dólares o euros dependiendo del ítem del menú seleccionado.

    #code-block(
      "l4/snippets/e3/CurrencyClient.java",
      snippet: "currency-client",
      lang: "java",
    )

    A continuación, se presenta la etapa de compilación RMI junto a la inicialización del servidor. Se efectúan interacciones desde el cliente comprobando de esta manera que el programa logra calcular montos en dólares (con un tipo de cambio de 3.50) y montos en euros (tipo de cambio 4.10) a partir de las bases en soles ingresadas.

    #image("img/lab/e3_1.png")
    #image("img/lab/e3_2.png")
    #image("img/lab/e3_3.png")
    #image("img/lab/e3_4.png")
  ]

  #lab-section("CUESTIONARIO")[
    #set par(justify: true)

    == ¿Cómo funciona el registro RMI?

    El registro RMI funciona como un servicio de directorio a nivel de red que mapea identificadores de cadena (nombres lógicos) con las referencias a los objetos remotos correspondientes.

    Actúa como un intermediario fundamental donde el servidor inscribe sus objetos utilizando métodos como `Naming.rebind()`, permitiendo que las aplicaciones cliente consulten este registro mediante `Naming.lookup()` para obtener los stubs necesarios para realizar las invocaciones de red.

    == ¿Cuáles son las subclases para soportar carga dinámica de clases?

    Para soportar la carga dinámica de clases en RMI, el entorno de ejecución de Java confía en un componente especializado denominado `RMIClassLoader`, el cual es una subclase interna de soporte que interactúa con las políticas de seguridad del sistema.

    Este cargador permite descargar bajo demanda los bytes de las clases o stubs faltantes desde una URL específica provista por la propiedad `java.rmi.server.codebase`, facilitando la actualización distribuida sin requerir que los clientes tengan los archivos previamente compilados.

    == ¿Qué ventajas y desventajas presenta RMI frente a la comunicación con sockets?

    RMI abstrae la complejidad de la gestión explícita de los flujos de red y la serialización manual que requieren los sockets, permitiendo invocar métodos remotos con la misma semántica que los locales y reduciendo significativamente la longitud del código.

    No obstante, presenta desventajas como la dependencia estricta del ecosistema Java en ambos extremos (sin usar CORBA), un rendimiento potencialmente inferior debido a la sobrecarga de la reflexión y la serialización, y complicaciones operativas al atravesar firewalls por la naturaleza de los puertos dinámicos.

    == ¿Por qué RMI necesita que los objetos sean serializables y cómo se podría escalar este sistema a múltiples servidores RMI?

    RMI exige que los objetos sean serializables debido a que necesita convertir su estado interno a un flujo de bytes secuencial para que pueda ser transmitido a través de la capa de transporte de la red hacia la máquina virtual remota.

    Para escalar este sistema a múltiples servidores RMI, se puede implementar un balanceador de carga que distribuya las peticiones de registro, o utilizar tecnologías de clustering y un registro distribuido compartido como JNDI que gestione las referencias de múltiples nodos servidores.

    == ¿Qué medidas de seguridad se deberían considerar para invocaciones remotas en entornos reales?

    En entornos reales, las invocaciones remotas deben protegerse estableciendo túneles cifrados con RMI sobre SSL/TLS para prevenir la interceptación del tráfico en texto plano a nivel de infraestructura y conexiones vulnerables.

    Asimismo, se debe configurar un `SecurityManager` estricto con un archivo de políticas restrictivo que limite los permisos, implementar mecanismos de autenticación antes de permitir la ejecución de los métodos, y encapsular el registro detrás de firewalls corporativos.
  ]

  #lab-section("CONCLUSIONES Y RECOMENDACIONES")[
    #show heading: set text(weight: "bold")
    #set par(justify: true)

    == CONCLUSIONES

    + La implementación de servicios distribuidos mediante RMI comprobó que la arquitectura de Invocación Remota de Métodos agiliza considerablemente el ciclo de desarrollo al aislar la lógica de serialización, el establecimiento de conexiones TCP y la gestión de flujos de datos.

    + El ejercicio del sistema de farmacia demostró que RMI soporta el paso de objetos complejos como parámetros y valores de retorno, permitiendo mantener la integridad de la orientación a objetos a través de los límites de las máquinas virtuales interconectadas en el proyecto de simulación.

    + Se verificó que el uso del RMI Registry es fundamental para desacoplar el ciclo de vida del servidor de la configuración del cliente, estableciendo un repositorio de nombres confiable y estandarizado donde los servicios quedan completamente accesibles con identificadores únicos y consistentes.

    == RECOMENDACIONES

    + Utilizar enfoques modernos basados en microservicios, como gRPC o API REST sobre HTTP/2, si se requiere interoperabilidad estricta con componentes y clientes construidos en lenguajes distintos a la máquina virtual del sistema Java utilizado inicialmente.

    + Centralizar la configuración de la red (puertos, hosts y propiedades de seguridad) en archivos de propiedades externos para evitar tener que recompilar el código fuente cuando la infraestructura de despliegue se modifique y escale sobre la marcha.

    + Implementar rutinas de manejo exhaustivo de `RemoteException` en el lado del cliente con estrategias de retardo exponencial (exponential backoff) para asegurar la recuperación transparente frente a interrupciones ocasionales, reintentando automáticamente en caso de problemas técnicos.
  ]

  #lab-section("REFERENCIAS Y BIBLIOGRAFÍA")[
    [1] Tanenbaum, A.S. (2008). Sistemas distribuidos: principios y paradigmas. México. Pearson Educación.

    [2] Ceballos, F. J. (2006). Java 2, Curso de programación. México: Alfaomega, RaMa.

    [3] Deitel, H. M., & Deitel, P. J. (2004). Cómo programar en Java. México: Pearson Educación.

    [4] García Tomás, J., Ferrando, S., & Piattini, M. (2001). Redes para procesos distribuidos. México: Alfaomega Ra-Ma.

    [5] Orfali, R., & Harkey, D. (1998). Client/Server Programming with Java and CORBA. USA: Wiley.
  ]

  #lab-section("ANEXOS")[
    #set par(justify: true)

    == Ejercicio 1: Sistema de Farmacia

    === Interfaz de Medicina
    #code-block("l4/src/e1/MedicineInterface.java", lang: "java")

    === Implementación de Medicina
    #code-block("l4/src/e1/Medicine.java", lang: "java")

    === Interfaz de Stock
    #code-block("l4/src/e1/StockInterface.java", lang: "java")

    === Implementación de Stock
    #code-block("l4/src/e1/Stock.java", lang: "java")

    === Excepción de Stock
    #code-block("l4/src/e1/StockException.java", lang: "java")

    === Servidor de Farmacia
    #code-block("l4/src/e1/ServerSide.java", lang: "java")

    === Cliente de Farmacia
    #code-block("l4/src/e1/ClienteSide.java", lang: "java")

    == Ejercicio 2: Sistema de Tarjetas de Crédito

    === Interfaz de Tarjeta de Crédito
    #code-block("l4/src/e2/CreditCardInterface.java", lang: "java")

    === Implementación de Tarjeta de Crédito
    #code-block("l4/src/e2/CreditCardImpl.java", lang: "java")

    === Servidor de Tarjetas de Crédito
    #code-block("l4/src/e2/CreditServer.java", lang: "java")

    === Cliente de Tarjetas de Crédito
    #code-block("l4/src/e2/CreditClient.java", lang: "java")

    == Ejercicio 3: Servicio de Conversión de Moneda

    === Interfaz de Conversión de Moneda
    #code-block("l4/src/e3/CurrencyInterface.java", lang: "java")

    === Implementación de Conversión de Moneda
    #code-block("l4/src/e3/CurrencyImpl.java", lang: "java")

    === Servidor de Conversión de Moneda
    #code-block("l4/src/e3/CurrencyServer.java", lang: "java")

    === Cliente de Conversión de Moneda
    #code-block("l4/src/e3/CurrencyClient.java", lang: "java")

    == Ejemplo de RMI en Java: Calculadora

    === Interfaz de Calculadora
    #code-block("l4/src/s1/Calculator.java", lang: "java")

    === Implementación de Calculadora
    #code-block("l4/src/s1/CalculatorImpl.java", lang: "java")

    === Servidor de Calculadora
    #code-block("l4/src/s1/CalculatorServer.java", lang: "java")

    === Cliente de Calculadora
    #code-block("l4/src/s1/CalculatorClient.java", lang: "java")
  ]
]
