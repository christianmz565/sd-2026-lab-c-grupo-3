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

    = SOLUCIÓN DE EJERCICIOS RESUELTOS

    == Lamport Clock

    El estado compartido del reloj se concentra en `tick()`, `update(...)` y
    `getTime()` porque el algoritmo necesita que cada evento local aumente
    una marca monotónica y que cada recepción combine los datos remotos
    con los locales mediante `max(local, recibido) + 1`.

    #code-block(
      "snippets/s1/LamportClock.java",
      snippet: "clock-rules",
      lang: "java",
    )

    El cierre de ejecución usa `join()` sobre cada hilo para poder
    imprimir el sistema completo,
    ya que sin esa barrera el proceso principal podría terminar antes de que
    algunos eventos actualicen el reloj y el valor reportado podría ser incorrecto.

    #code-block(
      "snippets/s1/LamportClock.java",
      snippet: "join-and-final-time",
      lang: "java",
    )

    A continuación, se muestra el resultado de compilar y ejecutar el programa:

    #image("img/lab02/lamport_clock.png")

    = SOLUCIÓN DE EJERCICIOS PROPUESTOS

    == Cristian Algorithm

    El diseño cliente-servidor separa la autoridad temporal en `TimeServer` y la
    corrección en `ClientNode` para modelar el objetivo del
    algoritmo de Cristian, que no es compartir estado global entre nodos sino
    permitir que cada cliente ajuste su desviación respecto a una referencia
    común.

    #code-block(
      "snippets/e1/CristianAlgorithm.java",
      snippet: "server-and-client-model",
      lang: "java",
    )

    La fase de sincronización mide `requestTime` y `responseTime` para estimar
    `RTT` y calcula
    `adjustment = (serverTime + RTT/2) - localTime` porque decide
    compensar el costo de red antes de corregir el reloj y así reducir el sesgo externo.

    #code-block(
      "snippets/e1/CristianAlgorithm.java",
      snippet: "synchronization-formula",
      lang: "java",
    )

    El `main` crea clientes con offsets positivos y negativos y los ejecuta para
    provocar condiciones de desfase.

    #code-block(
      "snippets/e1/CristianAlgorithm.java",
      snippet: "parallel-launch",
      lang: "java",
    )

    A continuación, se muestra el resultado de compilar y ejecutar el programa:

    #image("img/lab02/cristian_algorithm.png")

    === Berkeley Algorithm

    El modelo divide `Node` y `Coordinator` ya que Berkeley
    asume que la sincronización puede resolverse por coordinación
    interna, donde cada nodo expone su desfase local y el coordinador centraliza
    la decisión de ajuste sin requerir una fuente externa de tiempo absoluto.

    #code-block(
      "snippets/e2/BerkeleyAlgorithm.java",
      snippet: "node-and-coordinator-model",
      lang: "java",
    )

    En la ronda de cálculo el coordinador compara cada reloj con el maestro,
    promedia las diferencias y asigna a cada nodo un ajuste
    `averageDifference - nodeDiff` porque el objetivo no es copiar un reloj
    único sino minimizar la dispersión.

    #code-block(
      "snippets/e2/BerkeleyAlgorithm.java",
      snippet: "average-and-adjustment-round",
      lang: "java",
    )

    En `main` se fija un conjunto con desfases amplios y se ejecuta una
    sola ronda que logra reducir el error relativo entre nodos antes de
    usar políticas adicionales como exclusión de extremos o rondas
    repetidas.

    #code-block(
      "snippets/e2/BerkeleyAlgorithm.java",
      snippet: "main-setup",
      lang: "java",
    )

    A continuación, se muestra el resultado de compilar y ejecutar el programa:

    #image("img/lab02/berkeley_algorithm.png")
  ]

  #lab-section("CUESTIONARIO")[
    #set par(justify: true)

    == ¿Por qué es conveniente el uso de relojes lógicos en lugar de relojes físicos?

    Los relojes lógicos son convenientes en sistemas distribuidos porque el
    problema principal en muchos protocolos no es conocer la hora absoluta sino
    preservar el orden causal entre eventos relacionados por comunicación. Un
    reloj físico puede contener deriva, desfase por latencia y errores de
    sincronización externa, mientras que un reloj lógico evita esas dependencias
    y permite razonar sobre consistencia de ejecución con reglas deterministas
    de incremento y actualización

    == Explique ¿Cuál algoritmo entre Cristian y Berkeley resuelve mejor la sincronización?

    Cristian es más adecuado cuando existe un servidor de tiempo confiable y de
    baja latencia porque cada cliente realiza ajuste directo y rápido con una
    fórmula simple basada en `RTT`, mientras que Berkeley es más adecuado cuando
    se prioriza autonomía de cluster y no se dispone de fuente externa estricta.
    En esta práctica Cristian mostró convergencia puntual por cliente hacia la
    referencia del servidor, y Berkeley mostró convergencia grupal por promedio
    con reducción de dispersión global, por lo cual la elección correcta es
    contextual según topología, tolerancia a falla y objetivo operativo

    == Dado tres procesos P1, P2 y P3, representa la planificación de los procesos siguiendo el algoritmo de “ocurre antes de”.

    Se propone la siguiente planificación con tres procesos y dos mensajes para
    ilustrar la relación ocurre antes entre eventos locales y remotos

    #table(
      align: center + horizon,
      stroke: table-border-width + black,
      columns: (1fr, 1fr, 1fr, 2fr),
      table.header(
        repeat: false,
        table.cell(fill: rgb("#808080"), align: center + horizon)[#text(
          weight: "bold",
          fill: white,
        )[Proceso]],
        table.cell(fill: rgb("#808080"), align: center + horizon)[#text(
          weight: "bold",
          fill: white,
        )[Evento]],
        table.cell(fill: rgb("#808080"), align: center + horizon)[#text(
          weight: "bold",
          fill: white,
        )[Tiempo Lamport]],
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

    La cadena resultante: `a -> b -> c -> d -> e -> f` representa una historia
    causal consistente y cualquier evento no conectado por estas relaciones se
    considera concurrente en el marco de Lamport
  ]

  #lab-section("CONCLUSIONES Y RECOMENDACIONES")[
    #show heading: set text(weight: "bold")
    #set par(justify: true)

    == CONCLUSIONES

    + La ejecución de `LamportClock` verificó que la marca temporal lógica
      mantiene orden causal entre eventos concurrentes mediante incremento local
      y ajuste por máximo recibido

    + La implementación de `CristianAlgorithm` mostró convergencia de relojes
      cliente hacia una referencia de servidor con compensación por retardo de
      ida y vuelta

    + La implementación de `BerkeleyAlgorithm` mostró reducción de dispersión
      temporal del conjunto al aplicar ajustes calculados desde la media de
      desfases observados

    == RECOMENDACIONES

    + Ejecutar varias rondas por algoritmo con semillas de retardo controladas
      para cuantificar error medio y varianza de convergencia en diferentes
      condiciones de red

    + Incorporar umbrales para excluir outliers temporales en Berkeley y evitar
      que nodos con deriva extrema distorsionen el promedio global

    + Extender los ejemplos con fallas de nodo y pérdida de mensajes para
      evaluar robustez de sincronización ante condiciones no ideales de sistema
      distribuido
  ]

  #lab-section("REFERENCIAS Y BIBLIOGRAFÍA")[
    [1] Tanenbaum, A.S. (2008). Sistemas distribuidos: principios y paradigmas.
    México. Pearson Educación.

    [2] Ceballos, F. J. (2006). Java 2, Curso de programación. México:
    Alfaomega, RaMa.

    [3] Deitel, H. M., & Deitel, P. J. (2004). Cómo programar en Java. México:
    Pearson Educación.

    [4] García Tomás, J., Ferrando, S., & Piattini, M. (2001). Redes para
    procesos distribuidos. México: Alfaomega Ra-Ma.

    [5] Orfali, R., & Harkey, D. (1998). Client/Server Programming with Java and
    CORBA. USA: Wiley.
  ]

  #lab-section("ANEXOS")[
    #set par(justify: true)

    == Código completo: Lamport Clock

    #code-block("src/s1/LamportClock.java", lang: "java")

    == Código completo: Cristian Algorithm

    #code-block("src/e1/CristianAlgorithm.java", lang: "java")

    == Código completo: Berkeley Algorithm

    #code-block("src/e2/BerkeleyAlgorithm.java", lang: "java")
  ]

  #lab-section("ANEXOS")[
    #set par(justify: true)

    == Código completo: Lamport Clock

    #code-block("src/s1/LamportClock.java", lang: "java")

    == Código completo: Cristian Algorithm

    #code-block("src/e1/CristianAlgorithm.java", lang: "java")

    == Código completo: Berkeley Algorithm

    #code-block("src/e2/BerkeleyAlgorithm.java", lang: "java")
  ]
]
