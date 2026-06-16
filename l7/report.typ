#import "/lib.typ": code-block, code-block-config, lab-section, unsa-report, summarize-name

#show: unsa-report.with(
  course_name: "Sistemas Distribuidos",
  lab_title: "SOAP Web services",
  lab_number: "07",
  instructor_name: "Mg. Maribel Molina Barriga",
  members: (
    "Bedregal Perez Daniel",
    "Jara Mamani Mariel Alisson",
    "Mestas Zegarra Christian Raul",
    "Noa Camino Yenaro Joel",
    "Sequeiros Condori Luis Gustavo",
  ),
)

#code-block-config(lang: "java")

#set image(width: 78%)
#set list(indent: 2pt)
#show raw.where(block: false): it => box(
  inset: (x: 0.5pt),
)[#it]

#lab-section(title: "RESULTADOS Y PRUEBAS")[
  #show heading: set text(weight: "bold")
  #set par(justify: true)

  = ENLACE A GITHUB

  #link("https://github.com/christianmz565/sd-2026-lab-c-grupo-3/tree/main/l7")

  = EJERCICIOS RESUELTOS POR EL DOCENTE

  == Ejercicio Resuelto: Servicio SOAP de Suma

  Siguiendo las instrucciones de la guía, se implementó un servicio web SOAP básico en Java utilizando JAX-WS. El servicio define una operación `sumar` que recibe dos enteros y retorna su suma.

  Se definió primero una interfaz para el servicio, asegurando que el contrato sea claro y desacoplado de la implementación:

  #code-block(
    file: "l7/snippets/s1/CalculadoraAPI.java",
    snippet: "interface",
    prefix: "//",
  )

  La implementación de dicha interfaz se decoró con la anotación `@WebService`, especificando el espacio de nombres y los nombres de puerto y servicio para cumplir con los estándares WSDL:

  #code-block(
    file: "l7/snippets/s1/CalculadoraSOAP.java",
    snippet: "implementation",
    prefix: "//",
  )

  Para exponer el servicio en la red, se utilizó la clase `Endpoint.publish`, asignando el servicio a la dirección `http://localhost:8080/calculadora`:

  #code-block(
    file: "l7/snippets/s1/Publicador.java",
    snippet: "publisher",
    prefix: "//",
  )

  Finalmente, se desarrolló un cliente consumidor en Java que localiza el WSDL, crea un proxy dinámico del servicio y realiza una llamada remota de prueba:

  #code-block(
    file: "l7/snippets/s1/ClienteSOAP.java",
    snippet: "client",
    prefix: "//",
  )

  La validación del servicio se muestra en la siguiente captura, donde el cliente recibe correctamente el resultado de la operación remota:

  #figure(
    image("img/lab/s1/client.png"),
    caption: [Ejecución del cliente SOAP en Java para la operación de suma.],
  )

  = SOLUCIÓN DE EJERCICIOS PROPUESTOS

  == Ejercicio 1: Servicio SOAP de Conversión de Unidades

  Se desarrolló un servicio SOAP más robusto que permite realizar diversas conversiones de unidades: temperatura (Celsius/Fahrenheit), longitud (Metros/Pies) y masa (Kilogramos/Libras). La lógica de negocio se centralizó en la implementación del servicio:

  #code-block(
    file: "l7/snippets/e1/ConversorSOAP.java",
    snippet: "implementation",
    prefix: "//",
  )

  Para interactuar con este servicio, se implementó un cliente en Python utilizando la librería `zeep`. Este cliente ofrece un menú interactivo y maneja la comunicación SOAP de forma transparente:

  #code-block(
    file: "l7/snippets/e1/client.py",
    snippet: "python-client",
    lang: "python",
    prefix: "#",
  )

  A continuación se presentan las evidencias de la ejecución del cliente Python interactuando con el servidor SOAP en Java:

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    figure(image("img/lab/e1/menu.png", width: 100%), caption: [Menú interactivo del cliente Python.]),
    figure(
      image("img/lab/e1/conversion.png", width: 100%),
      caption: [Resultado de conversiones de temperatura y longitud.],
    ),
  )

  == Ejercicio 2: Servicio SOAP de Gestión de Tienda (CRUD)

  Se implementó un sistema de inventario avanzado mediante SOAP, permitiendo operaciones CRUD (Create, Read, Update, Delete) y una operación especial de compra que gestiona el stock de los productos.

  La arquitectura se basa en un contrato de servicio definido mediante la interfaz `SOAPI`, la cual expone las operaciones necesarias para la gestión de productos. Se hace uso de objetos `Item` que JAX-WS serializa automáticamente a XML:

  #code-block(
    file: "l7/snippets/e2/SOAPI.java",
    snippet: "interface",
    prefix: "//",
  )

  La implementación del servicio en Java (`SOAPImpl`) delega la lógica de persistencia y reglas de negocio (como la validación de stock insuficiente durante una compra) a la clase de modelo `Item`:

  #code-block(file: "l7/snippets/e2/SOAPImpl.java", snippet: "implementation", prefix: "//")

  La clase `Item` define los atributos de un producto (nombre, cantidad, costo) y implementa métodos para la gestión de inventario con código estándar de Java:
  #code-block(file: "l7/snippets/e2/Item.java", snippet: "logic", prefix: "//")

  Al igual que en el ejercicio anterior, se desarrolló un cliente CLI en Python para validar las operaciones administrativas. En las capturas se observa la creación, actualización y eliminación de productos, así como la persistencia en el servidor:

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    figure(image("img/lab/e2/cli_add_item.png", width: 100%), caption: [Agregando un nuevo producto via CLI.]),
    figure(
      image("img/lab/e2/cli_buy_item.png", width: 100%),
      caption: [Simulación de compra de un producto via CLI.],
    ),
  )
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    figure(
      image("img/lab/e2/cli_update_item.png", width: 100%),
      caption: [Actualizando stock y precio de un producto.],
    ),
    figure(
      image("img/lab/e2/cli_get_items.png", width: 100%),
      caption: [Listado de productos disponibles en el inventario.],
    ),
  )

  Para el consumo web, debido a las limitaciones del navegador para realizar peticiones SOAP directas (CORS, parsing XML complejo), se implementó un proxy en Node.js (Fastify) que traduce peticiones REST a llamadas SOAP internas:

  #code-block(
    file: "l7/snippets/e2/server.js",
    snippet: "proxy",
    lang: "javascript",
    prefix: "//",
  )

  Finalmente, se diseñó una interfaz web moderna que permite a los usuarios finales ver el catálogo y realizar compras de forma intuitiva, interactuando indirectamente con el servicio SOAP original:

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    figure(image("img/lab/e2/gui_list.png", width: 100%), caption: [Interfaz web del catálogo de productos.]),
    figure(
      image("img/lab/e2/gui_create_dialog.png", width: 100%),
      caption: [Formulario modal para agregar productos.],
    ),
  )
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    figure(
      image("img/lab/e2/gui_create_result.png", width: 100%),
      caption: [Resultado de la sincronización con el servidor.],
    ),
    figure(
      image("img/lab/e2/gui_delete_dialog.png", width: 100%),
      caption: [Confirmación de eliminación de recursos en la web.],
    ),
  )

]

#lab-section(title: "CUESTIONARIO")[
  #set par(justify: true)

  == 1. ¿Puedo utilizar un componente JavaBeans para implementar un servicio web utilizando la invocación de SOAP sobre JMS (Java Message Service)?

  Sí, es posible. JAX-WS permite utilizar JavaBeans como implementaciones de servicios web. Al integrar SOAP con JMS, el componente JavaBean actúa como el receptor de los mensajes que llegan a una cola o tópico. El contenedor de aplicaciones se encarga de extraer el cuerpo SOAP del mensaje JMS, deserializarlo e invocar el método correspondiente en el JavaBean, permitiendo una comunicación asíncrona y fiable.

  == 2. ¿Cómo funciona la mensajería bidireccional con la implementación de SOAP y JMS? ¿Da soporte a varios clientes realizando solicitudes simultáneas?

  La mensajería bidireccional (solicitud-respuesta) en SOAP sobre JMS se logra mediante el uso de colas de respuesta (`ReplyTo`). El cliente envía un mensaje a una cola de solicitudes e incluye un identificador de correlación y la dirección de su propia cola de respuesta. El servidor procesa la solicitud y envía la respuesta a la cola especificada con el mismo ID de correlación. Sí da soporte a múltiples clientes simultáneos, ya que JMS es inherentemente escalable y maneja la concurrencia a través de gestores de colas que pueden distribuir mensajes entre múltiples hilos o instancias de servidor.

  == 3. ¿Por qué SOAP sigue siendo utilizado en sistemas empresariales críticos pese al auge de REST?

  SOAP prevalece en entornos empresariales (especialmente banca y seguros) debido a su robustez y formalidad. Ofrece estándares estrictos como WS-Security para cifrado y firma digital a nivel de mensaje (no solo transporte), WS-AtomicTransaction para transacciones distribuidas complejas, y el contrato WSDL que garantiza una tipificación fuerte y generación automática de clientes, lo cual reduce errores de integración en sistemas legados y de gran escala.

  == 4. ¿Qué implicancias tiene el uso de XML en el rendimiento de sistemas distribuidos de alta concurrencia?

  XML es un formato verboso y basado en texto, lo que implica un mayor consumo de ancho de banda en comparación con formatos binarios o JSON. Además, el parseo de XML requiere más recursos de CPU y memoria (especialmente con DOM), lo que puede convertirse en un cuello de botella en sistemas de alta concurrencia. El uso de SAX o StAX mitiga esto, pero el overhead de serialización/deserialización sigue siendo superior al de alternativas más ligeras.

  == 5. ¿En qué escenarios arquitectónicos SOAP resulta más adecuado que REST? Justifique técnicamente.

  SOAP es superior en escenarios que requieren:
  - *Seguridad avanzada:* Cuando se necesita seguridad a nivel de mensaje (extremo a extremo) que persista a través de múltiples intermediarios.
  - *Transaccionalidad:* En flujos financieros que exigen cumplimiento de propiedades ACID en múltiples servicios distribuidos.
  - *Protocolos no-HTTP:* Cuando el servicio debe exponerse sobre SMTP, TCP o colas de mensajes (JMS) de forma transparente.
  - *Contratos estrictos:* En integraciones B2B complejas donde la validación estricta de esquemas es crítica para la integridad de los datos.
]

#lab-section(title: "CONCLUSIONES Y RECOMENDACIONES")[
  #show heading: set text(weight: "bold")
  #set par(justify: true)

  == CONCLUSIONES

  + SOAP ofrece una arquitectura altamente estructurada y basada en contratos que facilita la interoperabilidad entre diferentes lenguajes (Java y Python en este laboratorio) mediante el uso de WSDL.

  + A pesar de su mayor overhead en comparación con REST, SOAP proporciona capacidades críticas para entornos empresariales, como la seguridad robusta y el soporte para diversos protocolos de transporte.

  + La implementación de servicios SOAP en Java se ha simplificado significativamente con el estándar JAX-WS, permitiendo convertir POJOs en servicios web mediante anotaciones simples.

  == RECOMENDACIONES

  + Se recomienda utilizar herramientas como SOAPUI o Postman para la inspección y depuración de los mensajes XML generados, facilitando la comprensión del flujo de datos.

  + Para aplicaciones web modernas, es aconsejable emplear un patrón de proxy (como se hizo con Node.js) para mediar entre el frontend y el servicio SOAP, evitando problemas de CORS y tipado complejo en el navegador.

  + Es fundamental definir correctamente los espacios de nombres (targetNamespace) en los contratos WSDL para evitar colisiones y asegurar que el servicio sea descubrible de forma estándar.
]

#lab-section(title: "REFERENCIAS Y BIBLIOGRAFÍA")[
  [1] Tanenbaum, A.S. (2008). Sistemas distribuidos: principios y paradigmas. México. Pearson Educación.

  [2] Ceballos, F. J. (2006). Java 2, Curso de programación. México: Alfaomega, RaMa.

  [3] Deitel, H. M., & Deitel, P. J. (2004). Cómo programar en Java. México: Pearson Educación.

  [4] García Tomás, J., Ferrando, S., & Piattini, M. (2001). Redes para procesos distribuidos. México: Alfaomega Ra-Ma.

  [5] Fielding, R. (2000). Architectural Styles and the Design of Network-based Software Architectures. Dissertation. University of California, Irvine.
]

#lab-section(title: "ANEXOS")[
  #set par(justify: true)

  == Ejercicio 1: Conversor de Unidades (Java)

  === Interfaz del Conversor (ConversorAPI.java)
  #code-block(file: "l7/src/main/java/e1/ConversorAPI.java")

  === Implementación del Conversor (ConversorSOAP.java)
  #code-block(file: "l7/src/main/java/e1/ConversorSOAP.java")

  === Script Cliente Python (client.py)
  #code-block(file: "l7/src/main/java/e1/cli/client.py", lang: "python")

  == Ejercicio 2: Gestión de Tienda (Java + Python + Node.js)

  === Interfaz de la Tienda (SOAPI.java)
  #code-block(file: "l7/src/main/java/e2/servicio/soap/SOAPI.java")

  === Implementación de la Tienda (SOAPImpl.java)
  #code-block(file: "l7/src/main/java/e2/servicio/soap/SOAPImpl.java")

  === Modelo de Datos (Item.java)
  #code-block(file: "l7/src/main/java/e2/servicio/model/Item.java")

  === Proxy Backend (server.js)
  #code-block(file: "l7/src/main/java/e2/web/back/server.js", lang: "javascript")

  === Script Cliente Python (client.py)
  #code-block(file: "l7/src/main/java/e2/cli/client.py", lang: "python")
]
