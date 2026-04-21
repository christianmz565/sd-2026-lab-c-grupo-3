#import "lib.typ": code-block, lab-report, lab-section, table-border-width

#let course-name = "Sistemas Distribuidos"
#let lab-title = "Algoritmos de Sincronización"
#let lab-number = "02"
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

    #link("https://github.com/christianmz565/sd-2026-lab-c-grupo-3/main/l2")

    = SOLUCIÓN DE EJERCICIOS PROPUESTOS

    == Lamport Clock

    `LamportClock.java` cumple el rol de demostrador base del modelo de reloj lógico de Lamport y concentra en una sola clase el estado de reloj compartido, la lógica de incremento local, la regla de ajuste por recepción de eventos y el orquestador concurrente de hilos

    El atributo `clock` representa el tiempo lógico común y su acceso se protege con sincronización de método para preservar consistencia cuando varios hilos invocan `tick()` y `update(int receivedTime)` de manera concurrente

    El método `tick()` incrementa una unidad por evento local y devuelve el nuevo valor para etiquetar causalmente cada acción interna de hilo, mientras que `update()` implementa la regla `max(local, recibido) + 1` para mantener monotonicidad y asegurar que la recepción de un evento remoto siempre avance la línea temporal del proceso

    El flujo de control inicia en `main(String[] args)` donde se crea una lista de hilos, se instancia un reloj compartido y se lanzan cinco tareas que ejecutan dos eventos por hilo con una pausa aleatoria intermedia para simular latencias de comunicación

    Cada hilo imprime su evento de creación con tiempo Lamport, luego genera un segundo evento de recepción y finalmente solicita actualización del reloj según la marca recibida para reforzar el orden parcial entre eventos concurrentes

    El ciclo final con `join()` garantiza que el hilo principal espere la terminación de todas las tareas antes de reportar `Final Lamport time`, con lo cual el valor final refleja la acumulación de incrementos y ajustes de todo el sistema

    #code-block("src/s1/LamportClock.java", lang: "java")

    A continuación, se muestra el resultado de compilar y ejecutar el programa:

    #image("img/lab02/lamport_clock.png")

    = SOLUCIÓN DE EJERCICIOS PROPUESTOS

    == Cristian Algorithm

    El archivo `src/e1/CristianAlgorithm.java` implementa un esquema cliente-servidor para sincronización física aproximada donde un servidor de tiempo responde lecturas y cada cliente estima el tiempo válido corrigiendo el retardo de red de ida y vuelta

    La clase interna `TimeServer` encapsula la referencia temporal del servidor con un desplazamiento configurable `serverOffsetMillis` y expone `getCurrentTimeMillis()` como punto de consulta sincronizado para evitar lecturas inconsistentes

    La clase `ClientNode` representa un nodo con reloj local desfasado y define estado esencial en `name`, `localOffsetMillis`, `server` y `random` para modelar identidad, deriva local, dependencia del servidor y variabilidad de latencia

    El método `localTimeMillis()` calcula tiempo local como sistema más desplazamiento y `adjustClock(long adjustmentMillis)` aplica corrección sobre el offset local para reflejar el ajuste en la escala del reloj del cliente

    La decisión algorítmica clave reside en `synchronizeClock()` donde se registran `requestTime` y `responseTime`, se calcula `roundTripTime`, se estima `estimatedServerTime = serverTime + RTT/2` y se deriva el ajuste como diferencia entre esa estimación y el tiempo local actual

    La salida por cliente expone cuatro magnitudes técnicas `Antes`, `RTT`, `Ajuste` y `Después` para verificar que el algoritmo reduce dispersión entre nodos sin requerir reloj global compartido

    El `main` define cuatro clientes con offsets iniciales heterogéneos `+1200`, `-900`, `+2000` y `-1500`, ejecuta cada sincronización en hilos independientes y usa `join()` para cerrar la corrida de forma determinista

    #code-block("src/e1/CristianAlgorithm.java", lang: "java")

    A continuación, se muestra el resultado de compilar y ejecutar el programa:

    #image("img/lab02/cristian_algorithm.png")

    == Berkeley Algorithm

    El archivo `src/e2/BerkeleyAlgorithm.java` implementa el modelo Berkeley donde un coordinador consulta relojes locales de un conjunto de nodos, calcula una desviación promedio y distribuye ajustes para alinear el grupo sin depender de una fuente UTC externa

    La clase `Node` encapsula nombre y desplazamiento local mediante `name` y `offsetMillis`, expone lectura de tiempo local y offset, y permite ajustes acumulativos con `adjustOffset(long adjustmentMillis)`

    La clase `Coordinator` concentra la lógica de sondeo y reconciliación temporal con tres componentes de estado que son `master` como referencia de ronda, `nodes` como conjunto participante y `random` para latencia sintética de red

    El flujo de `synchronize()` inicia con impresión de estado inicial para inspeccionar offsets de partida, luego toma un `masterTime` base y calcula para cada nodo la diferencia observada `nodeTime - masterTime` tras una demora simulada

    El algoritmo agrega todas las diferencias, obtiene `averageDifference`, y para cada nodo calcula `adjustment = averageDifference - nodeDiff` con el fin de mover cada reloj hacia la media del grupo y reducir dispersión global

    El estado final impreso permite contrastar offsets antes y después y verificar que las magnitudes convergen a una banda corta alrededor del promedio calculado por el coordinador

    El `main` define cinco nodos incluyendo maestro con offsets iniciales dispares `500`, `-1800`, `2200`, `900` y `-600`, instancia coordinador y ejecuta una ronda completa de sincronización

    #code-block("src/e2/BerkeleyAlgorithm.java", lang: "java")

    A continuación, se muestra el resultado de compilar y ejecutar el programa:

    #image("img/lab02/berkeley_algorithm.png")
  ]

  #lab-section("CUESTIONARIO")[
    #set par(justify: true)

    == ¿Por qué es conveniente el uso de relojes lógicos en lugar de relojes físicos?

    Los relojes lógicos son convenientes en sistemas distribuidos porque el problema principal en muchos protocolos no es conocer la hora absoluta sino preservar el orden causal entre eventos relacionados por comunicación.
    Un reloj físico puede contener deriva, desfase por latencia y errores de sincronización externa, mientras que un reloj lógico evita esas dependencias y permite razonar sobre consistencia de ejecución con reglas deterministas de incremento y actualización

    == ¿Cuál algoritmo entre Cristian y Berkeley resuelve mejor la sincronización?

    Cristian es más adecuado cuando existe un servidor de tiempo confiable y de baja latencia porque cada cliente realiza ajuste directo y rápido con una fórmula simple basada en `RTT`, mientras que Berkeley es más adecuado cuando se prioriza autonomía de cluster y no se dispone de fuente externa estricta.
    En esta práctica Cristian mostró convergencia puntual por cliente hacia la referencia del servidor, y Berkeley mostró convergencia grupal por promedio con reducción de dispersión global, por lo cual la elección correcta es contextual según topología, tolerancia a falla y objetivo operativo

    == Planificación de P1, P2 y P3 siguiendo "ocurre antes"

    Se propone la siguiente planificación con tres procesos y dos mensajes para ilustrar la relación ocurre antes entre eventos locales y remotos

    #table(
      align: center + horizon,
      stroke: table-border-width + black,
      columns: (1fr, 1fr, 1fr, 2fr),
      table.header(
        repeat: false,
        table.cell(fill: rgb("#808080"), align: center + horizon)[#text(weight: "bold", fill: white)[Proceso]],
        table.cell(fill: rgb("#808080"), align: center + horizon)[#text(weight: "bold", fill: white)[Evento]],
        table.cell(fill: rgb("#808080"), align: center + horizon)[#text(weight: "bold", fill: white)[Tiempo Lamport]],
        table.cell(fill: rgb("#808080"), align: center + horizon)[#text(
          weight: "bold",
          fill: white,
        )[Relación ocurre antes]],
      ),
      [P1], [a: evento local], [1], [Inicio de secuencia en P1],
      [P1], [b: envia m1 a P2], [2], [a -> b por orden local],
      [P2], [c: recibe m1], [3], [b -> c por regla de mensaje],
      [P2], [d: envia m2 a P3], [4], [c -> d por orden local],
      [P3], [e: recibe m2], [5], [d -> e por regla de mensaje],
      [P3], [f: evento local], [6], [e -> f por orden local],
    )

    La cadena resultante: `a -> b -> c -> d -> e -> f` representa una historia causal consistente y cualquier evento no conectado por estas relaciones se considera concurrente en el marco de Lamport
  ]

  #lab-section("CONCLUSIONES Y RECOMENDACIONES")[
    #show heading: set text(weight: "bold")
    #set par(justify: true)

    == CONCLUSIONES

    + La ejecución de `LamportClock` verificó que la marca temporal lógica mantiene orden causal entre eventos concurrentes mediante incremento local y ajuste por máximo recibido

    + La implementación de `CristianAlgorithm` mostró convergencia de relojes cliente hacia una referencia de servidor con compensación por retardo de ida y vuelta

    + La implementación de `BerkeleyAlgorithm` mostró reducción de dispersión temporal del conjunto al aplicar ajustes calculados desde la media de desfases observados

    == RECOMENDACIONES

    + Ejecutar varias rondas por algoritmo con semillas de retardo controladas para cuantificar error medio y varianza de convergencia en diferentes condiciones de red

    + Incorporar umbrales para excluir outliers temporales en Berkeley y evitar que nodos con deriva extrema distorsionen el promedio global

    + Extender los ejemplos con fallas de nodo y pérdida de mensajes para evaluar robustez de sincronización ante condiciones no ideales de sistema distribuido
  ]

  #lab-section("REFERENCIAS Y BIBLIOGRAFÍA")[
    [1] Tanenbaum, A.S. (2008). Sistemas distribuidos: principios y paradigmas. México. Pearson Educación.

    [2] Ceballos, F. J. (2006). Java 2, Curso de programación. México: Alfaomega, RaMa.

    [3] Deitel, H. M., & Deitel, P. J. (2004). Cómo programar en Java. México: Pearson Educación.

    [4] García Tomás, J., Ferrando, S., & Piattini, M. (2001). Redes para procesos distribuidos. México: Alfaomega Ra-Ma.

    [5] Orfali, R., & Harkey, D. (1998). Client/Server Programming with Java and CORBA. USA: Wiley.
  ]
]
