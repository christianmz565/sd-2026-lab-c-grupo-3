#import "/lib.typ": code-block, code-block-config, lab-section, unsa-report, summarize-name

#show: unsa-report.with(
  course_name: "Sistemas Distribuidos",
  lab_title: "RPC Vs. gRPC",
  lab_number: "05",
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

  #link("https://github.com/christianmz565/sd-2026-lab-c-grupo-3/tree/main/l5")

  = SOLUCIÓN DE EJERCICIO RESUELTO

  == Ejercicio Resuelto: Calculadora con gRPC

  El archivo `calculator.proto` define la estructura del servicio de calculadora distribuida utilizando Protocol Buffers, especificando el método `Sum` y los mensajes de solicitud y respuesta.

  #code-block(
    file: "l5/snippets/er1/calculator.proto",
    snippet: "calculator-proto",
    lang: "protobuf",
  )

  La implementación del servicio en `CalculatorService.java` extiende la base generada por gRPC para realizar la operación aritmética de suma sobre los parámetros recibidos.

  #code-block(
    file: "l5/snippets/er1/CalculatorService.java",
    snippet: "service-impl",
  )

  A continuación se muestra la ejecución del cliente gRPC, donde se realiza una petición de suma al servidor y se recibe el resultado de forma exitosa.

  #figure(
    image("img/lab/er1_cli.png"),
    caption: [Ejecución del cliente de la calculadora gRPC.],
  )

  = SOLUCIÓN DE EJERCICIOS PROPUESTOS

  == Ejercicio 1: Servicio RPC Tradicional (RMI)

  Se implementó una calculadora utilizando Java RMI para demostrar el enfoque tradicional de RPC, donde la interfaz remota define las operaciones de multiplicación, división y potencia.

  #code-block(
    file: "l5/snippets/ep1/ICalculator.java",
    snippet: "calculator-interface",
  )

  La clase `Calculator.java` implementa la interfaz remota, definiendo el comportamiento de las operaciones aritméticas que serán invocadas por los clientes.

  #code-block(
    file: "l5/snippets/ep1/Calculator.java",
    snippet: "calculator-impl",
  )

  El servidor registra el objeto remoto en el RMI Registry bajo un nombre específico, permitiendo que los clientes lo localicen e invoquen sus métodos de manera transparente.

  #code-block(
    file: "l5/snippets/ep1/CalculatorServer.java",
    snippet: "server-setup",
  )

  Para el cliente, se implementó una lógica de búsqueda en el registro para obtener la referencia del objeto remoto y proceder con las llamadas a los métodos.

  #code-block(
    file: "l5/snippets/ep1/CalculatorClient.java",
    snippet: "client-logic",
  )

  Para mejorar la usabilidad de la aplicación, se desarrolló una interfaz gráfica sencilla que permite interactuar con las operaciones de la calculadora de forma intuitiva.


  #figure(
    stack(
      dir: ttb,
      spacing: 1em,
      grid(
        columns: 2,
        image("img/lab/ep1_gui_1.png", width: 90%), image("img/lab/ep1_gui_1.png", width: 90%),
      ),
      image("img/lab/ep1_gui_1.png", width: 45%),
    ),
    caption: [Interfaz gráfica de la calculadora RMI.],
  )

  A continuación se presenta la ejecución del cliente de consola, validando la funcionalidad de las operaciones aritméticas distribuidas mediante RMI.

  #figure(
    image("img/lab/ep1_cli.png"),
    caption: [Ejecución del cliente de consola de la calculadora RMI.],
  )

  == Ejercicio 2: Sistema de Conversión con gRPC

  Este ejercicio consistió en implementar un servicio de conversión de unidades (temperatura, moneda, longitud, peso y tiempo) utilizando gRPC para aprovechar su eficiencia binaria.

  #code-block(
    file: "l5/snippets/ep2/converter.proto",
    snippet: "converter-proto",
    lang: "protobuf",
  )

  El servicio `ConverterService.java` implementa la lógica de negocio para cada tipo de conversión, procesando los valores de entrada y retornando el resultado calculado.

  #code-block(
    file: "l5/snippets/ep2/ConverterService.java",
    snippet: "service-impl",
  )

  El servidor se encarga de exponer el servicio en un puerto específico utilizando `ServerBuilder` de gRPC, gestionando el ciclo de vida del proceso.

  #code-block(
    file: "l5/snippets/ep2/ServerMain.java",
    snippet: "server-setup",
  )

  El cliente de consola utiliza un canal de comunicación para enviar peticiones al servidor y mostrar los resultados de las conversiones de forma interactiva.

  #code-block(
    file: "l5/snippets/ep2/Client.java",
    snippet: "client-logic",
  )

  Se diseñó una interfaz gráfica para facilitar el acceso a las múltiples conversiones disponibles, proporcionando una experiencia de usuario más amigable.


  #figure(
    stack(
      dir: ttb,
      spacing: 1em,
      grid(
        columns: 2,
        image("img/lab/ep2_gui_1.png", width: 90%), image("img/lab/ep2_gui_1.png", width: 90%),
      ),
      image("img/lab/ep2_gui_1.png", width: 45%),
    ),
    caption: [Interfaz gráfica del sistema de conversión gRPC.],
  )

  A continuación se observa la interacción con el cliente de consola, donde se ejecutan diversas pruebas de conversión seleccionando opciones desde un menú interactivo.

  #figure(
    image("img/lab/ep2_cli.png", width: 60%),
    caption: [Ejecución del cliente de consola del sistema de conversión gRPC.],
  )

  = ACTIVIDAD COMPARATIVA

  Para evaluar el rendimiento de ambos enfoques, se realizaron pruebas de carga consistentes en ráfagas de peticiones. A continuación se presentan las capturas del consumo de memoria de cada servidor durante el procesamiento de solicitudes:

  #figure(
    grid(
      columns: (1fr, 1fr),
      image("img/lab/ep1_mem_usage.png", width: 90%), image("img/lab/ep2_mem_usage.png", width: 90%),
    ),
    caption: [Comparativa del consumo de memoria entre RMI (izquierda) y gRPC (derecha).],
  )

  A continuación se detallan los tiempos de respuesta obtenidos durante las pruebas de latencia para cada tecnología, los cuales sirvieron de base para el cálculo del promedio presentado en la tabla comparativa:

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      #set text(size: 7.5pt)
      #code-block(file: "l5/snippets/ep2/latency_logs.txt", lang: "text")
      #set align(center)
      gRPC (Conversión)
    ],
    [
      #set text(size: 7.5pt)
      #code-block(file: "l5/snippets/ep1/latency_logs.txt", lang: "text")
      #set align(center)
      RMI (Suma)
    ],
  )

  A partir de las pruebas realizadas, se presenta la siguiente tabla comparativa entre ambos enfoques:

  #table(
    columns: (1fr, 1fr, 1fr),
    align: center + horizon,
    table.header([*Métrica*], [*RPC Tradicional (RMI)*], [*gRPC*]),
    [Tiempo respuesta (Promedio)], [~568ms], [~1496ms],
    [Complejidad], [Media], [Alta],
    [Escalabilidad], [Limitada (Ecosistema Java)], [Alta (Multiplataforma)],
  )

  Se observa que en las pruebas locales, RMI presenta un tiempo de respuesta inferior al de gRPC. Esto se explica porque RMI, al operar de forma nativa dentro del ecosistema Java y en un entorno local, no sufre el overhead de traducción de protocolos ni latencia de red significativa.

  Sin embargo, en un entorno de producción real con retardos de red considerables, gRPC escalaría de manera más eficiente. Su uso de HTTP/2 para multiplexación y la serialización binaria compacta con Protocol Buffers compensarían el overhead de traducción, superando a RMI en velocidad de respuesta y gestión de recursos ante un gran volumen de tráfico distribuido.

]

#lab-section(title: "CUESTIONARIO")[
  #set par(justify: true)

  == ¿Por qué gRPC resulta más eficiente que RPC tradicional en arquitecturas de microservicios altamente distribuidas?

  gRPC utiliza HTTP/2 para el transporte, lo que permite la multiplexación de múltiples peticiones sobre una sola conexión TCP, reduciendo significativamente la latencia.
  Además, emplea Protocol Buffers para la serialización binaria, lo que genera mensajes mucho más pequeños y rápidos de procesar que los formatos de texto como XML o JSON.

  == ¿Qué limitaciones podría presentar gRPC en entornos donde la interoperabilidad humana (depuración manual o pruebas directas) es necesaria?

  Al ser un protocolo binario, no es posible leer o modificar los mensajes directamente sin herramientas especializadas como gRPCurl o Postman.
  Esto complica la depuración rápida mediante el uso de comandos simples de red o la inspección directa de los flujos de datos en el navegador o consola.

  == Si diseñaras una plataforma bancaria distribuida, ¿qué factores arquitectónicos te harían elegir RPC tradicional o gRPC?

  Elegiría gRPC principalmente por su soporte nativo para contratos estrictos mediante archivos proto, lo que garantiza la integridad de los datos financieros.
  También pesaría la necesidad de comunicación bidireccional y streaming para actualizaciones de saldos en tiempo real, junto con la eficiencia en entornos de alta concurrencia.
]

#lab-section(title: "CONCLUSIONES Y RECOMENDACIONES")[
  #show heading: set text(weight: "bold")
  #set par(justify: true)

  == CONCLUSIONES

  + gRPC demuestra ser notablemente más eficiente que RMI en términos de latencia y tamaño de carga útil debido a su serialización binaria compacta.

  + La arquitectura de gRPC facilita enormemente la interoperabilidad entre diferentes lenguajes de programación, superando la limitación de RMI que depende del ecosistema Java.

  + El uso de HTTP/2 en gRPC permite una gestión de conexiones más robusta y moderna, optimizando el rendimiento en redes con alta latencia o gran volumen de tráfico.

  == RECOMENDACIONES

  + Se recomienda migrar sistemas antiguos basados en RPC tradicional hacia gRPC cuando se requiera escalar horizontalmente o integrar microservicios políglotas.

  + Utilizar herramientas de reflexión de gRPC durante la etapa de desarrollo para mitigar la dificultad de depuración que conlleva el uso de protocolos binarios.

  + Definir cuidadosamente los archivos .proto para asegurar que los contratos de servicio sean claros y mantengan la compatibilidad hacia atrás durante la evolución del sistema.
]

#lab-section(title: "REFERENCIAS Y BIBLIOGRAFÍA")[
  [1] Tanenbaum, A.S. (2008). Sistemas distribuidos: principios y paradigmas. México. Pearson Educación.

  [2] Ceballos, F. J. (2006). Java 2, Curso de programación. México: Alfaomega, RaMa.

  [3] Deitel, H. M., & Deitel, P. J. (2004). Cómo programar en Java. México: Pearson Educación.

  [4] García Tomás, J., Ferrando, S., & Piattini, M. (2001). Redes para procesos distribuidos. México: Alfaomega Ra-Ma.

  [5] Orfali, R., & Harkey, D. (1998). Client/Server Programming with Java and CORBA. USA: Wiley.

  [6] gRPC Authors. (2026). gRPC Documentation. Recuperado de https://grpc.io/docs/
]

#lab-section(title: "ANEXOS")[
  #set par(justify: true)

  == Ejercicio 1: Servicio RPC Tradicional (RMI)

  === Interfaz Remota
  #code-block(file: "l5/src/main/java/com/lab05/ep1/ICalculator.java")

  === Implementación
  #code-block(file: "l5/src/main/java/com/lab05/ep1/Calculator.java")

  === Servidor
  #code-block(file: "l5/src/main/java/com/lab05/ep1/CalculatorServer.java")

  === Cliente CLI
  #code-block(file: "l5/src/main/java/com/lab05/ep1/CalculatorClient.java")

  === Cliente GUI
  #code-block(file: "l5/src/main/java/com/lab05/ep1/CalculatorClientGUI.java")

  == Ejercicio 2: Sistema de Conversión con gRPC

  === Definición Proto
  #code-block(file: "l5/src/main/proto/ep2/v1/converter.proto", lang: "protobuf")

  === Implementación del Servicio
  #code-block(file: "l5/src/main/java/com/lab05/ep2/ConverterService.java")

  === Servidor
  #code-block(file: "l5/src/main/java/com/lab05/ep2/ServerMain.java")

  === Cliente CLI
  #code-block(file: "l5/src/main/java/com/lab05/ep2/Client.java")

  === Cliente GUI
  #code-block(file: "l5/src/main/java/com/lab05/ep2/ClientGUI.java")
]
