#let AbbreviateByCaps(w) = {
  let chars = w.clusters()
  let caps = chars.filter(c => c == upper(c) and c != lower(c))
  caps.join("")
}

#let AbbreviateFullName(name) = {
  let parts = name.split(" ")
  parts.at(0)
  ", "
  parts.at(2)
}

#let genTime = datetime.today()

// any capital letter in the string will be part of the abbreviation
#let courseName = "Sistemas Distribuidos"
#let courseAbbv = AbbreviateByCaps(courseName)

// last names, first names
// just use spaces and at least 3 words or it won't work
// the abbreviation will be "third_word, first_word"
#let memberList = (
  "Bedregal Pérez Daniel",
  "Jara Mamani Mariel Alisson",
  "Mestas Zegarra Christian Raúl",
  "Noa Camino Yenaro Joel",
  "Sequeiros Condori Luis Gustavo",
)
#let memberAbbvList = memberList.map(n => AbbreviateFullName(n))

// title
#let labTitle = "Los Hilos (Threads)"

// lab number
#let labNumber = "01"

// instructor name
#let instructorName = "Mg. Maribel Molina Barriga"

// date stuff which doesn't need to be touched
#let year = { genTime.year() }
// could technically be A if month < 7 else B but that depends on uni not delaying classes (always happens)
#let semCode = "A"
#let presentationDate = genTime.display("[day]/[month]/[year]")
#let presentationHour = "11:59:00"


// layout constants
// sizes
#let tableBorderWidth = 0.5pt

#let tableRowMinHeight = 16pt
// colors
#let headerBorderColor = rgb("#808080")
#let tbHeaderBgColor = rgb("#C8310E")
#let codeBgColor = rgb("#F1F3F4")
// fonts
#set text(
  font: "Lato",
)

#let fontBuild(content, weight, size, alignTo, color) = [
  #set text(size: size, weight: weight, fill: color)
  #if alignTo != none [
    #align(alignTo)[#content]
  ] else [
    #content
  ]
]

#let headerBig(content, weight: "regular", alignTo: none, color: black) = fontBuild(
  content,
  weight,
  7.5pt,
  alignTo,
  color,
)
#let headerSmall(content, weight: "regular", alignTo: none, color: black) = fontBuild(
  content,
  weight,
  7pt,
  alignTo,
  color,
)
#let mainTitle(content) = fontBuild(content, "bold", 13pt, center, black)
#let tableTitle(content, weight: "regular", alignTo: none, color: black) = fontBuild(
  content,
  weight,
  11pt,
  alignTo,
  color,
)
#let tableContents(content, weight: "regular", alignTo: none, color: black) = fontBuild(
  content,
  weight,
  8.5pt,
  alignTo,
  color,
)

// technically components
#let ordList(items) = [
  #set list(
    indent: 1em,
    marker: "1.1.",
  )
  #for item in items [
    + #item
  ]
]
#let unordList(items) = [
  #set list(
    indent: 1em,
    marker: "-",
  )
  #for item in items [
    - #item
  ]
]

#let pageHeader = block(
  width: 100%,
  inset: (bottom: 1em),
)[
  #table(
    align: center + horizon,
    stroke: tableBorderWidth + headerBorderColor,
    columns: (1fr, 2fr, 1fr),
    align(horizon)[#image("img/fixed/epis.png", width: 95%)],
    headerBig(weight: "bold")[
      UNIVERSIDAD NACIONAL DE SAN AGUSTÍN \
      FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS \
      ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMAS
    ],
    align(horizon)[#image("img/fixed/abet.png", width: 97%)],
    table.cell(colspan: 3)[
      #headerSmall(weight: "bold")[Formato: ]
      #headerSmall[Guía de Práctica de Laboratorio / Talleres / Centros de Simulación]
    ],
    headerSmall(weight: "bold")[Aprobación: 2022/03/01],
    headerSmall(weight: "bold")[Código: GUIA-PRLE-001],
    context headerSmall(weight: "bold", alignTo: right)[Página: #counter(page).display("1")],
  )
]

#set page(
  paper: "a4",
  margin: (
    top: 6cm,
    bottom: 2.54cm,
    left: 1.9cm,
    right: 1.9cm,
  ),
  header: pageHeader,
  header-ascent: 5%,
)

#set document(
  title: upper[#courseAbbv - Laboratorio #labNumber - #memberAbbvList.join(" - ")],
)

#align(center)[#mainTitle[INFORME DE LABORATORIO]]

#table(
  align: left + horizon,
  stroke: black + 1pt,
  inset: 0.5em,
  columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  table.cell(
    colspan: 6,
    fill: tbHeaderBgColor,
    tableTitle(weight: "bold", alignTo: center, color: white)[INFORMACIÓN BÁSICA],
  ),
  tableContents(weight: "bold")[ASIGNATURA:],
  table.cell(
    colspan: 5,
    tableContents[#courseName],
  ),
  tableContents(weight: "bold")[TÍTULO DE LA PRÁCTICA:],
  table.cell(
    colspan: 5,
    tableContents[#labTitle],
  ),
  tableContents(weight: "bold")[NÚMERO DE LA PRÁCTICA:],
  tableContents[#labNumber],
  tableContents(weight: "bold")[AÑO LECTIVO:],
  tableContents[#year],
  tableContents(weight: "bold")[NRO. SEMESTRE:],
  tableContents[#semCode],
  tableContents(weight: "bold")[FECHA DE PRESENTACIÓN:],
  tableContents[#presentationDate],
  tableContents(weight: "bold")[HORA DE PRESENTACIÓN:],
  table.cell(
    colspan: 3,
    tableContents[#presentationHour],
  ),
  table.cell(
    colspan: 4,
    [
      #tableContents(weight: "bold")[INTEGRANTE(s):] \
      #tableContents[#unordList(memberList)]

    ],
  ),
  tableContents(weight: "bold")[NOTA (0 - 20):],
  tableContents[Nota colocada por el docente],
  table.cell(
    colspan: 6,
    [
      #tableContents(weight: "bold")[DOCENTE: ] \
      #tableContents[#instructorName]
    ],
  ),
)

#let codeBlock(file, lang: "text") = block(
  fill: codeBgColor,
  breakable: true,
  width: 100%,
  inset: 1em,
  radius: 8pt,
)[
  #set text(size: 7pt)
  #raw(read(file), lang: lang)
]

#let cliBlock(command) = block(
  fill: codeBgColor,
  breakable: true,
  width: 100%,
  inset: 1em,
  radius: 8pt,
)[
  #raw(command, lang: "bash")
]

#show heading.where(level: 1): set text(size: 10pt)
#show heading.where(level: 2): set text(size: 9pt)

#grid(
  align: left + horizon,
  stroke: black + 1pt,
  inset: 0.5em,
  columns: 1fr,
  grid.cell(
    fill: tbHeaderBgColor,
    tableTitle(weight: "bold", alignTo: center, color: white)[RESULTADOS Y PRUEBAS],
  ),
  tableContents[
    #show heading: set text(weight: "bold")
    #set heading(numbering: "1.")
    #set par(justify: true)

    = SOLUCIÓN DE EJERCICIOS PROPUESTOS

    == Ejercicio 1: Simulación del proceso de cobro en un supermercado

    El primer caso práctico aborda la simulación de un supermercado, empezando con una versión de ejecución puramente secuencial. En esta fase, las clases `Cliente` y `Cajera` definen a las entidades. El cliente mantiene un arreglo con los tiempos de espera de sus productos, mientras que la cajera procesa esos tiempos de forma iterativa, simulando el retraso con la función `Thread.sleep()`.
    #codeBlock("src/e1/Cliente.java", lang: "java")
    #codeBlock("src/e1/Cajera.java", lang: "java")

    Luego, el programa principal `Main` ejecuta este proceso de manera lineal: se procesa al cliente 1 por completo, y cuando la primera cajera termina, se da paso al cliente 2. Esto implica que el tiempo total de ejecución es la suma del tiempo de cobro de todos los clientes.
    #codeBlock("src/e1/Main.java", lang: "java")
    A continuación, se muestra el resultado de compilar y ejecutar el programa secuencial midiendo su tiempo total con la utilidad `time` de la terminal:
    #image("img/lab01/e1_main_time.png", width: 100%)

    El análisis del tiempo real reporta un aproximado de 26 segundos, lo cual se corresponde con la suma lineal de las demoras de todos los productos por procesar de ambos clientes ($15\\text{s} + 11\\text{s}$).

    Para aprovechar la multitarea y realizar cobros paralelos, se introduce la clase `CajeraThread`, la cual hereda de la clase `Thread` de Java. En ella se sobreescribe el método `run()`, permitiendo que el procesamiento de la compra se realice en un hilo independiente, de modo que cada cajera procesa su cliente simultáneamente.
    #codeBlock("src/e1/CajeraThread.java", lang: "java")
    El nuevo punto de entrada `MainThread` inicializa y lanza estos hilos empleando el método `start()`.
    #codeBlock("src/e1/MainThread.java", lang: "java")
    La ejecución de esta versión mediante hilos evidencia que las tareas de las cajeras se intercalan. El reporte del comando `time` demuestra un tiempo de ejecución total en torno a los 15 segundos. Esto significa un ahorro de tiempo de casi 11 segundos (alrededor de 42% de ganancia de rendimiento) respecto a la versión secuencial. Al ejecutarse los procesos concurrentemente, la demora total del programa queda limitada únicamente al tiempo del cliente con la compra más larga.
    #image("img/lab01/e1_thread_time.png", width: 100%)

    Otra alternativa para lograr el comportamiento concurrente sin utilizar herencia múltiple en Java es la interfaz `Runnable`. En la clase `MainRunnable`, se implementa el método `run()` invocando directamente a la clase `Cajera` original, y se envuelve en nuevos hilos (`Thread`) pasando este `Runnable`.
    #codeBlock("src/e1/MainRunnable.java", lang: "java")
    El efecto resultante en el sistema es exactamente el mismo en orden y tiempo ($15\\text{s}$) que la versión que extiende de `Thread`, demostrando que separar la tarea en una interfaz `Runnable` es una forma eficaz y modular de organizar flujos paralelos sin comprometer el diseño de clases existente.
    #image("img/lab01/e1_runnable_time.png", width: 100%)

    == Ejercicio 2: Problema del Productor y Consumidor

    El segundo ejercicio analiza un escenario de interacción controlada de hilos mediante el problema clásico del Productor y el Consumidor. Se utiliza un objeto compartido `CubbyHole` que almacena un entero. Esta clase gestiona el acceso concurrente empleando los monitores propios de Java (`synchronized`) y comunicación condicional (`wait()` y `notifyAll()`) para evitar que el Productor sobreescriba datos o que el Consumidor lea el mismo dato dos veces.
    #codeBlock("src/e2/CubbyHole.java", lang: "java")

    Las clases `Productor` y `Consumidor` extienden de `Thread` y acceden iterativamente a este objeto para poner y obtener valores de 0 a 9. En particular, el hilo Productor intercala un pequeño retraso pseudoaleatorio entre operaciones.
    #codeBlock("src/e2/Productor.java", lang: "java")
    #codeBlock("src/e2/Consumidor.java", lang: "java")

    El programa `Demo` orquesta la ejecución conjunta, iniciando ambos hilos simultáneamente.
    #codeBlock("src/e2/Demo.java", lang: "java")
    En la salida del programa se aprecia claramente la coordinación exitosa: el Productor deposita un número y el Consumidor lo recoge sin errores de inconsistencia, ni condiciones de carrera, garantizando un flujo constante pese a la concurrencia.
    #image("img/lab01/e2_demo_time.png", width: 100%)
  ]
)

#grid(
  align: left + horizon,
  stroke: black + 1pt,
  inset: 0.5em,
  columns: 1fr,
  grid.cell(
    fill: tbHeaderBgColor,
    tableTitle(weight: "bold", alignTo: center, color: white)[CUESTIONARIO],
  ),
  tableContents[
    #set enum(numbering: "1.")
    #set par(justify: true)

    + ¿Por qué es importante el estudio de hilos y multihilos en un sistema distribuido? \
      El estudio de hilos en sistemas distribuidos permite aprovechar mejor CPU y red al ejecutar tareas concurrentes por nodo, lo que reduce latencia de respuesta y mejora el rendimiento global del servicio.

    + Describe cómo están compuestos los hilos y cuál es la diferencia entre hilos y procesos \
      Un hilo está compuesto por contador de programa, pila, estado de ejecución y registros dentro de un proceso, mientras un proceso tiene espacio de memoria propio y recursos aislados, por lo que los hilos son más ligeros pero comparten memoria y requieren sincronización.

    + Cuadro comparativo de ventajas y desventajas del uso de hilos \
      #table(
        align: center + horizon,
        stroke: tableBorderWidth + black,
        columns: (1fr, 1fr),
        table.cell(fill: rgb("#808080"), tableContents(weight: "bold", alignTo: center, color: white)[Ventajas]),
        table.cell(fill: rgb("#808080"), tableContents(weight: "bold", alignTo: center, color: white)[Desventajas]),
        tableContents[Mejor uso de CPU en tareas concurrentes],
        tableContents[Requieren control de carrera y exclusión mutua],
        tableContents[Menor costo de creación que procesos],
        tableContents[Errores de sincronización son difíciles de rastrear],
        tableContents[Permiten respuesta más rápida en servicios],
        tableContents[Un bloqueo puede afectar a todo el proceso],
        tableContents[Comparten datos con menor sobrecarga],
        tableContents[Dependen de buen diseño para evitar interbloqueo],
      )
      El cuadro resume el balance entre costo operativo bajo y mayor complejidad de coordinación cuando varios hilos comparten recursos.
  ]
)

#grid(
  align: left + horizon,
  stroke: black + 1pt,
  inset: 0.5em,
  columns: 1fr,
  grid.cell(
    fill: tbHeaderBgColor,
    tableTitle(weight: "bold", alignTo: center, color: white)[CONCLUSIONES Y RECOMENDACIONES],
  ),
  tableContents[
    #show heading: set text(weight: "bold")
    #set heading(numbering: "1.")
    #set par(justify: true)

    = CONCLUSIONES

    + El uso de hilos permite dividir procesos secuenciales largos en tareas que se ejecutan en paralelo, lo que, como se vio en el caso del supermercado, reduce sustancialmente el tiempo total cuando el procesamiento es independiente, mejorando notablemente el rendimiento general de una aplicación concurrente.

    + La comunicación y sincronización son componentes fundamentales para desarrollar sistemas multihilo estables. El uso de bloques `synchronized` junto con los métodos `wait()` y `notifyAll()` en Java, evidenciado en el patrón de productor-consumidor, es esencial para prevenir interbloqueos (deadlocks) y problemas de condición de carrera sobre recursos compartidos.

    = RECOMENDACIONES

    + Se recomienda preferir la implementación de la interfaz `Runnable` sobre la herencia de la clase `Thread` en Java, ya que permite mayor flexibilidad en el diseño orientado a objetos al posibilitar heredar de otra clase distinta si fuera necesario para la lógica de la aplicación.

    + Se debe planificar cuidadosamente la arquitectura de los programas concurrentes identificando en la etapa de diseño cuáles serán las zonas o secciones críticas que requerirán mecanismos explícitos de control de concurrencia y qué tipo de exclusión mutua minimiza la congestión en el sistema sin comprometer su integridad.
  ]
)

#grid(
  align: left + horizon,
  stroke: black + 1pt,
  inset: 0.5em,
  columns: 1fr,
  grid.cell(
    fill: tbHeaderBgColor,
    tableTitle(weight: "bold", alignTo: center, color: white)[REFERENCIAS Y BIBLIOGRAFÍA],
  ),
  tableContents[
    [1] Tanenbaum, A.S. (2008). Sistemas distribuidos: principios y paradigmas. México. Pearson Educación.

    [2] Ceballos, F. J. (2006). Java 2, Curso de programación. México: Alfaomega, RaMa.

    [3] Deitel, H. M., & Deitel, P. J. (2004). Cómo programar en Java. México: Pearson Educación.

    [4] García Tomás, J., Ferrando, S., & Piattini, M. (2001). Redes para procesos distribuidos. México: Alfaomega Ra-Ma.

    [5] Orfali, R., & Harkey, D. (1998). Client/Server Programming with Java and CORBA. USA: Wiley.

    [6] Programación multihilo: #link("https://oscarmaestre.github.io/servicios/textos/tema2.html")[https://oscarmaestre.github.io/servicios/textos/tema2.html]

    [7] Threads en Java: #link("https://lc.fie.umich.mx/~rochoa/Materias/PROGRAMACION/PROGRAMACION_2/HILOS.pdf")[https://lc.fie.umich.mx/~rochoa/Materias/PROGRAMACION/PROGRAMACION_2/HILOS.pdf]

    [8] #link("https://biblus.us.es/bibing/proyectos/abreproy/11320/fichero/Capitulos%252F13.pdf")[https://biblus.us.es/bibing/proyectos/abreproy/11320/fichero/Capitulos%252F13.pdf]
  ]
)
