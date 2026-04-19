#import "lib.typ": code-block, lab-report, lab-section, table-border-width

#let course-name = "Sistemas Distribuidos"
#let lab-title = "Los Hilos (Threads)"
#let lab-number = "01"
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
)[
  #lab-section("RESULTADOS Y PRUEBAS", align-mode: left + top)[
    #show heading: set text(weight: "bold")
    #set par(justify: true)

    = SOLUCION DE EJERCICIOS PROPUESTOS

    == Ejercicio 1: Simulacion del proceso de cobro en un supermercado

    El primer caso practico aborda la simulacion de un supermercado y comienza con una version de ejecucion puramente secuencial. En esta fase, las clases `Cliente` y `Cajera` representan las entidades del sistema. El cliente mantiene un arreglo con los tiempos de espera de sus productos, mientras que la cajera procesa esos tiempos de forma iterativa y simula el retraso con la funcion `Thread.sleep()`.
    #code-block("src/e1/Cliente.java", lang: "java")
    #code-block("src/e1/Cajera.java", lang: "java")

    Luego, el programa principal `Main` ejecuta este proceso de manera lineal: primero se procesa por completo al cliente 1 y, cuando la primera cajera termina, recien se da paso al cliente 2. Esto implica que el tiempo total de ejecucion es la suma de los tiempos de cobro de todos los clientes.
    #code-block("src/e1/Main.java", lang: "java")

    A continuacion, se muestra el resultado de compilar y ejecutar el programa secuencial midiendo su tiempo total con la utilidad `time` de la terminal:
    #image("img/lab01/e1_main_time.png")

    El analisis del tiempo real reporta un aproximado de 26 segundos, lo cual se corresponde con la suma lineal de las demoras de todos los productos por procesar de ambos clientes ($15 + 11 = 26$ segundos).

    Para aprovechar la multitarea y realizar cobros paralelos, se introduce la clase `CajeraThread`, la cual hereda de la clase `Thread` de Java. En ella se sobreescribe el metodo `run()`, lo que permite que el procesamiento de la compra se realice en un hilo independiente. De este modo, cada cajera atiende a su cliente de forma simultanea.
    #code-block("src/e1/CajeraThread.java", lang: "java")

    El nuevo punto de entrada `MainThread` inicializa y lanza estos hilos empleando el metodo `start()`.
    #code-block("src/e1/MainThread.java", lang: "java")

    La ejecucion de esta version mediante hilos evidencia que las tareas de las cajeras se intercalan. El reporte del comando `time` muestra un tiempo total de ejecucion cercano a los 15 segundos. Esto representa un ahorro de casi 11 segundos (alrededor de 42% de mejora de rendimiento) respecto de la version secuencial. Al ejecutarse los procesos de forma concurrente, la duracion total del programa queda limitada por el cliente con la compra mas larga.
    #image("img/lab01/e1_thread_time.png")

    Otra alternativa para lograr el comportamiento concurrente sin depender de la herencia de `Thread` es usar la interfaz `Runnable`. En la clase `MainRunnable`, se implementa el metodo `run()` invocando directamente a la clase `Cajera` original y se encapsula esta tarea en nuevos hilos (`Thread`) pasando dicho `Runnable`.
    #code-block("src/e1/MainRunnable.java", lang: "java")

    El efecto resultante en el sistema es exactamente el mismo en comportamiento y tiempo (15 segundos) que en la version que extiende de `Thread`. Esto demuestra que separar la tarea en una interfaz `Runnable` es una forma eficaz y modular de organizar flujos paralelos sin comprometer el diseno de clases existente.
    #image("img/lab01/e1_runnable_time.png")

    == Ejercicio 2: Problema del Productor y Consumidor

    El segundo ejercicio analiza un escenario de interaccion controlada de hilos mediante el problema clasico del Productor y el Consumidor. Se utiliza un objeto compartido `CubbyHole` que almacena un entero. Esta clase gestiona el acceso concurrente empleando los monitores propios de Java (`synchronized`) y la comunicacion condicional (`wait()` y `notifyAll()`) para evitar que el productor sobreescriba datos o que el consumidor lea el mismo dato dos veces.
    #code-block("src/e2/CubbyHole.java", lang: "java")

    Las clases `Productor` y `Consumidor` extienden de `Thread` y acceden iterativamente a este objeto para insertar y obtener valores de 0 a 9. En particular, el hilo productor intercala un pequeno retraso pseudoaleatorio entre operaciones.
    #code-block("src/e2/Productor.java", lang: "java")
    #code-block("src/e2/Consumidor.java", lang: "java")

    El programa `Demo` orquesta la ejecucion conjunta, iniciando ambos hilos simultaneamente.
    #code-block("src/e2/Demo.java", lang: "java")

    En la salida del programa se aprecia claramente la coordinacion exitosa: el productor deposita un numero y el consumidor lo recoge sin errores de inconsistencia ni condiciones de carrera, garantizando un flujo constante pese a la concurrencia.
    #image("img/lab01/e2_demo_time.png")
  ]

  #lab-section("CUESTIONARIO")[
    #set par(justify: true)

    == Por que es importante el estudio de hilos y multihilos en un sistema distribuido?
    El estudio de hilos en sistemas distribuidos permite aprovechar mejor la CPU y la red al ejecutar tareas concurrentes por nodo, lo que reduce la latencia de respuesta y mejora el rendimiento global del servicio.

    == Describe como estan compuestos los hilos y cual es la diferencia entre hilos y procesos.
    Un hilo esta compuesto por contador de programa, pila, estado de ejecucion y registros dentro de un proceso, mientras que un proceso tiene espacio de memoria propio y recursos aislados. Por ello, los hilos son mas ligeros, pero comparten memoria y requieren sincronizacion.

    == Cuadro comparativo de ventajas y desventajas del uso de hilos
    #table(
      align: center + horizon,
      stroke: table-border-width + black,
      columns: (1fr, 1fr),
      table.header(
        repeat: false,
        table.cell(fill: rgb("#808080"), align: center + horizon)[#text(weight: "bold", fill: white)[Ventajas]],
        table.cell(fill: rgb("#808080"), align: center + horizon)[#text(weight: "bold", fill: white)[Desventajas]],
      ),
      [Mejor uso de CPU en tareas concurrentes], [Requieren control de carrera y exclusion mutua],
      [Menor costo de creacion que procesos], [Errores de sincronizacion son dificiles de rastrear],
      [Permiten respuesta mas rapida en servicios], [Un bloqueo puede afectar a todo el proceso],
      [Comparten datos con menor sobrecarga], [Dependen de buen diseno para evitar interbloqueo],
    )
    El cuadro resume el balance entre costo operativo bajo y mayor complejidad de coordinacion cuando varios hilos comparten recursos.
  ]

  #lab-section("CONCLUSIONES Y RECOMENDACIONES")[
    #show heading: set text(weight: "bold")
    #set par(justify: true)

    = CONCLUSIONES

    + El uso de hilos permite dividir procesos secuenciales largos en tareas que se ejecutan en paralelo, lo que, como se vio en el caso del supermercado, reduce sustancialmente el tiempo total cuando el procesamiento es independiente, mejorando notablemente el rendimiento general de una aplicacion concurrente.

    + La comunicacion y sincronizacion son componentes fundamentales para desarrollar sistemas multihilo estables. El uso de bloques `synchronized` junto con los metodos `wait()` y `notifyAll()` en Java, evidenciado en el patron de productor-consumidor, es esencial para prevenir interbloqueos (deadlocks) y problemas de condicion de carrera sobre recursos compartidos.

    = RECOMENDACIONES

    + Se recomienda preferir la implementacion de la interfaz `Runnable` sobre la herencia de la clase `Thread` en Java, ya que permite mayor flexibilidad en el diseno orientado a objetos al posibilitar heredar de otra clase distinta si fuera necesario para la logica de la aplicacion.

    + Se debe planificar cuidadosamente la arquitectura de los programas concurrentes identificando en la etapa de diseno cuales seran las zonas o secciones criticas que requeriran mecanismos explicitos de control de concurrencia y que tipo de exclusion mutua minimiza la congestion en el sistema sin comprometer su integridad.
  ]

  #lab-section("REFERENCIAS Y BIBLIOGRAFIA")[
    [1] Tanenbaum, A.S. (2008). Sistemas distribuidos: principios y paradigmas. Mexico. Pearson Educacion.

    [2] Ceballos, F. J. (2006). Java 2, Curso de programacion. Mexico: Alfaomega, RaMa.

    [3] Deitel, H. M., & Deitel, P. J. (2004). Como programar en Java. Mexico: Pearson Educacion.

    [4] Garcia Tomas, J., Ferrando, S., & Piattini, M. (2001). Redes para procesos distribuidos. Mexico: Alfaomega Ra-Ma.

    [5] Orfali, R., & Harkey, D. (1998). Client/Server Programming with Java and CORBA. USA: Wiley.

    [6] Programacion multihilo: #link("https://oscarmaestre.github.io/servicios/textos/tema2.html")[https://oscarmaestre.github.io/servicios/textos/tema2.html]

    [7] Threads en Java: #link("https://lc.fie.umich.mx/~rochoa/Materias/PROGRAMACION/PROGRAMACION_2/HILOS.pdf")[https://lc.fie.umich.mx/~rochoa/Materias/PROGRAMACION/PROGRAMACION_2/HILOS.pdf]

    [8] #link("https://biblus.us.es/bibing/proyectos/abreproy/11320/fichero/Capitulos%252F13.pdf")[https://biblus.us.es/bibing/proyectos/abreproy/11320/fichero/Capitulos%252F13.pdf]
  ]
]
