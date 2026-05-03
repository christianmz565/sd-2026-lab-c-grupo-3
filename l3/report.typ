#import "lib.typ": code-block, lab-report, lab-section, table-border-width

#let course-name = "Sistemas Distribuidos"
#let lab-title = "Sockets"
#let lab-number = "03"
#let instructor-name = "Mg. Maribel Molina Barriga"
#let member-list = (
  "Bedregal Perez Daniel",
  "Jara Mamani Mariel Alisson",
  "Mestas Zegarra Christian Raul",
  "Noa Camino Yenaro Joel",
  "Sequeiros Condori Luis Gustavo",
)

#lab-report(
  course-name: course-name,
  lab-title: lab-title,
  lab-number: lab-number,
  instructor-name: instructor-name,
  member-list: member-list,
  sem-code: "2026-A",
)[
  #lab-section("RESULTADOS Y PRUEBAS", align-mode: left + top)[
    #show heading: set text(weight: "bold")
    #set par(justify: true)

    = ENLACE A GITHUB

    #link("https://github.com/christianmz565/sd-2026-lab-c-grupo-3/tree/main/l3")

    = SOLUCIÓN DE EJERCICIOS RESUELTOS

    == Ejemplo de Sockets en Java: Programa Servidor

    El archivo `Servidor.java` define la clase principal que se encarga de escuchar peticiones en el puerto `5000` mediante un objeto de la clase `ServerSocket`.

    La lógica principal se encuentra en su constructor, donde entra en un bucle acotado a tres iteraciones para aceptar hasta tres conexiones de clientes utilizando la primitiva `accept()`.

    Para cada conexión establecida, el servidor recupera el flujo de salida a través de `getOutputStream()` y lo envuelve en un `DataOutputStream` para poder escribir cadenas de texto formateadas.

    Posteriormente, el servidor transmite un mensaje de saludo personalizado utilizando el método `writeUTF(...)` y cierra la conexión actual con `close()` para liberar los recursos del socket.

    #code-block(
      "snippets/e1/Servidor.java",
      snippet: "server-accept",
      lang: "java",
    )

    == Ejemplo de Sockets en Java: Programa Cliente

    El archivo `Cliente.java` define la aplicación cliente que busca conectarse al servidor especificado en la constante `HOST` (localhost) a través del puerto `5000`.

    En su ejecución, instancia un objeto `Socket` que intenta establecer la conexión de red de forma síncrona.

    Una vez conectado, el cliente obtiene el flujo de entrada con `getInputStream()` y lo envuelve en un `DataInputStream` para leer el flujo binario como una cadena de caracteres UTF-8.

    Finalmente, el mensaje recibido se imprime en la consola estándar del sistema y la conexión se termina explícitamente llamando al método `close()` del socket.

    #code-block(
      "snippets/e1/Cliente.java",
      snippet: "client-connect",
      lang: "java",
    )

    A continuación, se muestra el resultado de compilar y ejecutar el servidor y los clientes. 

    El servidor escucha el puerto y atiende secuencialmente a los clientes, los cuales imprimen el mensaje de saludo recibido.

    #image("img/lab03/e1_server.png")

    #image("img/lab03/e1_client.png")

    = SOLUCIÓN DE EJERCICIOS PROPUESTOS

    == Sistema de Chat en Java: Clases de Mensaje

    El archivo `ChatMessage.java` implementa la clase serializable que define la estructura y el contenido de los mensajes intercambiados entre los clientes y el servidor.

    Esta clase permite encapsular tanto el tipo de comando (como `WHOISIN`, `MESSAGE` o `LOGOUT`) como el contenido en texto plano.

    Al implementar la interfaz `Serializable`, los objetos de esta clase pueden ser transmitidos directamente a través de la red utilizando flujos de objetos, lo que evita la necesidad de realizar procesamiento y análisis manual de bytes en los extremos de la comunicación.

    #code-block(
      "snippets/e2/ChatMessage.java",
      snippet: "chat-message",
      lang: "java",
    )

    == Sistema de Chat en Java: Programa Servidor

    El archivo `Server.java` implementa el nodo central del sistema de chat, responsable de coordinar las conexiones y retransmitir los mensajes a los usuarios activos.

    En el método `start()`, el servidor inicializa un `ServerSocket` e ingresa en un ciclo continuo donde invoca `accept()` para recibir nuevas peticiones de conexión.

    Cada conexión nueva se delega a un hilo independiente mediante la clase interna `ClientThread`, lo que permite al servidor manejar múltiples clientes de forma concurrente sin bloquearse.

    #code-block(
      "snippets/e2/Server.java",
      snippet: "server-start",
      lang: "java",
    )

    La comunicación se gestiona mediante métodos sincronizados como `broadcast(...)`, el cual itera sobre la lista de clientes activos y utiliza `ObjectOutputStream` para transmitir los mensajes serializados, soportando además el envío de mensajes privados mediante la sintaxis `@usuario`.

    #code-block(
      "snippets/e2/Server.java",
      snippet: "server-broadcast",
      lang: "java",
    )

    == Sistema de Chat en Java: Programa Cliente

    El archivo `Client.java` contiene la lógica del cliente, el cual establece la conexión bidireccional y maneja la interacción con el usuario final.

    Durante su inicialización, el cliente solicita un nombre de usuario y se conecta al servidor, configurando inmediatamente los flujos de objetos `ObjectInputStream` y `ObjectOutputStream`.

    #code-block(
      "snippets/e2/Client.java",
      snippet: "client-start",
      lang: "java",
    )

    Para evitar bloquear la entrada del usuario mientras se esperan nuevos mensajes, el cliente lanza un hilo secundario `ListenFromServer` que lee continuamente del flujo de entrada y muestra los mensajes recibidos en pantalla.

    #code-block(
      "snippets/e2/Client.java",
      snippet: "client-listener",
      lang: "java",
    )

    Al mismo tiempo, el hilo principal procesa comandos y cadenas de texto ingresadas en la consola, construyendo objetos `ChatMessage` y enviándolos al servidor para su distribución.

    #code-block(
      "snippets/e2/Client.java",
      snippet: "client-main-loop",
      lang: "java",
    )

    A continuación, se muestra el resultado de compilar y ejecutar el sistema de chat propuesto. 
    
    El servidor administra las conexiones concurrentemente mientras que los clientes interactúan mediante comandos de sistema y mensajes públicos y privados.

    #image("img/lab03/e2_server.png")

    #image("img/lab03/e2_client_1.png")

    #image("img/lab03/e2_client_2.png")
  ]

  #lab-section("CUESTIONARIO")[
    #set par(justify: true)

    == ¿Por qué y en qué momento usar sockets TCP y sockets UDP?

    Los sockets TCP se utilizan cuando se requiere una comunicación confiable, en orden y sin pérdida de datos entre los extremos, ya que el protocolo implementa mecanismos de retransmisión y control de congestión.

    Se deben elegir en aplicaciones donde la integridad de la información es crítica, como en el caso de la transferencia de archivos (FTP), la web (HTTP) o servicios de acceso remoto (Telnet).

    Por otro lado, los sockets UDP se utilizan cuando la prioridad es la velocidad y el bajo costo computacional, a expensas de la confiabilidad, ya que los paquetes se envían de forma independiente y sin garantía de entrega.

    Su uso es adecuado en escenarios donde la pérdida ocasional de un datagrama es tolerable y preferible a un retraso acumulado, como en transmisiones de video en vivo, comunicaciones de voz sobre IP (VoIP) o juegos en línea de ritmo rápido.

    == En un socket TCP, ¿cuándo sabe el servidor que el cliente ha cerrado la conexión?

    El servidor detecta el cierre de la conexión de manera asíncrona cuando intenta interactuar con el flujo de datos asociado al socket del cliente.

    Si el cliente realiza un cierre ordenado (graceful shutdown), las operaciones de lectura en el servidor, como `read()` o `readObject()`, devolverán valores de terminación (como `-1` o `null`) o lanzarán una excepción de fin de archivo como `EOFException`.

    Si el cierre es abrupto, como en el caso de una pérdida de conexión de red o cierre forzado del proceso, el sistema operativo subyacente lo detectará durante los intentos de lectura o escritura y la máquina virtual de Java lanzará una excepción del tipo `SocketException` o `IOException`, indicando que la conexión ha sido reiniciada (connection reset).
  ]

  #lab-section("CONCLUSIONES Y RECOMENDACIONES")[
    #show heading: set text(weight: "bold")
    #set par(justify: true)

    == CONCLUSIONES

    + La ejecución de la prueba inicial verificó que la clase `ServerSocket` facilita la creación de servicios en red mediante primitivas bloqueantes que abstraen la complejidad subyacente del protocolo TCP.

    + La implementación del sistema de chat demostró que el uso de hilos independientes (como `ClientThread`) es esencial para manejar clientes concurrentes sin afectar el ciclo principal de aceptación de conexiones del servidor.

    + Se observó que el intercambio de objetos serializables en Java a través de `ObjectInputStream` y `ObjectOutputStream` simplifica significativamente la programación de protocolos de aplicación al eliminar la necesidad de parsear cadenas de bytes manualmente.

    == RECOMENDACIONES

    + Integrar mecanismos robustos de manejo de latidos (heartbeats) para identificar y desconectar proactivamente a clientes caídos sin depender únicamente de excepciones de entrada y salida.

    + Considerar la migración de la gestión de hilos a las abstracciones de concurrencia modernas de Java o utilizar el paquete NIO (Non-blocking I/O) para mejorar la escalabilidad frente a un alto volumen de clientes simultáneos.

    + Extender el sistema para incorporar validación de esquemas y cifrado de los objetos serializables en tránsito, previniendo posibles ataques de inyección y escuchas no autorizadas en redes públicas.
  ]

  #lab-section("REFERENCIAS Y BIBLIOGRAFÍA")[
    [1] Tanenbaum, A.S. (2008). Sistemas distribuidos: principios y paradigmas. México. Pearson Educación.

    [2] Ceballos, F. J. (2006). Java 2, Curso de programación. México: Alfaomega, RaMa.

    [3] Deitel, H. M., & Deitel, P. J. (2004). Cómo programar en Java. México: Pearson Educación.

    [4] García Tomás, J., Ferrando, S., & Piattini, M. (2001). Redes para procesos distribuidos. México: Alfaomega Ra-Ma.

    [5] Orfali, R., & Harkey, D. (1998). Client/Server Programming with Java and CORBA. USA: Wiley
  ]

  #lab-section("ANEXOS")[
    #set par(justify: true)

    == Código completo: Programa Servidor (básico)

    #code-block("src/e1/Servidor.java", lang: "java")

    == Código completo: Programa Cliente (básico)

    #code-block("src/e1/Cliente.java", lang: "java")

    == Código completo: ChatMessage

    #code-block("src/e2/ChatMessage.java", lang: "java")

    == Código completo: Sistema de Chat - Servidor

    #code-block("src/e2/Server.java", lang: "java")

    == Código completo: Sistema de Chat - Cliente

    #code-block("src/e2/Client.java", lang: "java")
  ]
]
