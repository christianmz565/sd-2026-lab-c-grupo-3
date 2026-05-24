#import "/lib.typ": code-block

#let tab = 1cm
#let para-gap = 18pt
#let main-title = [Implementación del Patrón MapReduce para Conteo de Palabras Distribuido]

#set page(
  margin: (x: 1.91cm, y: 2.54cm),
)

#set text(
  font: "Liberation Serif",
  size: 12pt,
  hyphenate: false,
)

#set par(
  justify: true,
  first-line-indent: 0pt,
  spacing: 1em,
  leading: 1em,
)

#set figure(supplement: [Figura])
#show figure.caption: it => [
  #strong[#it.supplement #context it.counter.display(it.numbering).] #emph(it.body)
]

#set heading(numbering: "1.1.1.", outlined: true)
#show heading: set text(size: 12pt, weight: "bold")
#show heading: it => {
  block(inset: (y: 0.5em))[
    #align(left + horizon)[
      #if it.numbering == none { return it }
      #grid(
        columns: (tab, 1fr),
        counter(heading).display(it.numbering), it.body,
      )
    ]
  ]
}

#set page(
  footer: context [
    #set align(center)
    #if counter(page).get().first() > 1 [
      #counter(page).display("1")
    ]
  ],
  header: context [
    #if counter(page).get().first() > 1 [
      #set align(right)
      #main-title
      #context {
        let size = measure([#main-title])
        line(length: size.width + 1em)
      }
    ]
  ],
)

#let render-title-page() = {
  align(center)[
    #strong[UNIVERSIDAD NACIONAL DE SAN AGUSTÍN]\
    #strong[FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS]\
    #strong[ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMAS]\ \

    #image("images/image1.png", width: 5cm)\

    #strong[TRABAJO GRUPAL - PATRONES DE ARQUITECTURA]\
    IMPLEMENTACIÓN DEL PATRÓN MAPREDUCE EN SISTEMAS DISTRIBUIDOS\ \

    #strong[ASIGNATURA]\
    SISTEMAS DISTRIBUIDOS\
    GRUPO C\ \

    #strong[DOCENTE]\
    Mg. MARIBEL MOLINA BARRIGA\ \

    #strong[INTEGRANTES]\
    BEDREGAL PEREZ DANIEL\
    JARA MAMANI MARIEL ALISSON\
    MESTAS ZEGARRA CHRISTIAN RAUL\
    QUISPE CONDORI ALVARO RAUL\
    SEQUEIROS CONDORI LUIS GUSTAVO\ \

    #strong[AREQUIPA - PERÚ]\
    #strong[2026]
  ]
  pagebreak()
}

#let render-toc() = {
  show outline.entry.where(level: 1): set text(weight: "bold")
  show outline.entry: set block(above: 0.75em)
  outline(title: [Tabla de Contenido])
  pagebreak()
}

#let section(level, title, ..body) = {
  let body-content = if body.pos().len() > 0 { body.pos().at(0) } else { none }

  block(inset: (left: (level - 1) * tab))[
    #block(sticky: true)[
      #heading(level: level)[#title]
    ]
    #if body-content != none [
      #block(inset: (left: tab))[
        #set par(first-line-indent: (amount: tab))
        #body-content
      ]
    ]
  ]
}

#let report-figure(path, caption, w: 100%, h: 25%) = {
  layout(size => {
    let img = image(path)
    let img-size = measure(img)

    let max-w = if type(w) == ratio { size.width * w } else { w }
    let max-h = if type(h) == ratio { size.height * h } else { h }

    let ratio-w = max-w / img-size.width
    let ratio-h = max-h / img-size.height

    let scale-factor = calc.min(ratio-w, ratio-h)

    block(width: 100%, inset: 1em)[
      #align(center)[
        #figure(
          image(path, width: img-size.width * scale-factor),
          caption: caption,
        )
      ]
    ]
  })
}

#set enum(numbering: n => strong[#n.])
#render-title-page()
#render-toc()

#align(center)[
  #set text(size: 14pt, weight: "bold")
  #block(below: 2em)[
    #main-title
  ]
]

#section(1, [Definición del Patrón MapReduce])[
  MapReduce es un modelo de programación y una implementación asociada para procesar y generar grandes conjuntos de datos de forma paralela y distribuida en un clúster @dean2004mapreduce. El usuario especifica una función `Map` que procesa un par clave/valor para generar un conjunto de pares clave/valor intermedios, y una función `Reduce` que combina todos los valores intermedios asociados con la misma clave intermedia @dean2008mapreduce.
]

#section(2, [Ventajas del Patrón MapReduce])[
  - *Escalabilidad:*\ Permite procesar petabytes de datos utilizando hardware convencional al distribuir la carga @dean2004mapreduce.
  - *Tolerancia a fallos:*\ El sistema gestiona automáticamente los fallos de los nodos, reasignando tareas si un trabajador no responde.
  - *Abstracción:*\ El desarrollador solo debe preocuparse por la lógica de negocio (Map y Reduce), dejando la gestión de red y paralelismo al framework @dean2008mapreduce.
]

#section(2, [Desventajas del Patrón MapReduce])[
  - *No es apto para tiempo real:*\ La sobrecarga de orquestación y el manejo de archivos intermedios introducen latencia @condie2010mapreduce.
  - *Iteraciones costosas:*\ Algoritmos que requieren múltiples pasadas sobre los mismos datos (como el entrenamiento de modelos de ML) son ineficientes debido a la escritura constante en disco o red entre fases @ekanayake2010twister.
]

#section(1, [Diseño de la Arquitectura])[
  Para abordar el problema del conteo de frecuencia de palabras, se ha diseñado una arquitectura basada en el modelo Maestro-Trabajador (Master-Worker), donde los componentes se comunican a través de gRPC.

  + *Master (Maestro):*
    - Expone un endpoint HTTP para recibir el texto a procesar.
    - Divide el texto en fragmentos manejables (chunks).
    - Mantiene un registro de los trabajadores (Workers) disponibles.
    - Orquesta la distribución de tareas y recolecta los resultados parciales para la reducción final.

  + *Worker (Trabajador):*
    - Se registra con el Maestro al iniciar su ejecución.
    - Implementa el servicio gRPC para realizar el conteo local de un fragmento de texto.
    - Retorna un diccionario de frecuencias al Maestro.

  + *Infraestructura:*
    - Se utiliza Docker Compose para desplegar un nodo maestro y múltiples nodos trabajadores en una red virtual.

  #report-figure("images/architecture.png", h: 60%)[Arquitectura del sistema de conteo distribuido]
]

#section(1, [Código Fuente de la Implementación])[
  En esta sección se detallan las partes fundamentales del código, utilizando el componente de bloques de código importado de la librería del curso.
]

#section(2, [Definición del Servicio gRPC])[
  El contrato de comunicación entre el maestro y los trabajadores se define mediante Protocol Buffers.

  #code-block("teo/mapreduce/report/snippets/wordcount.proto", snippet: "proto", lang: "proto", prefix: "//")
]

#section(2, [Fase de Mapeo (Worker)])[
  La lógica del trabajador se centra en la limpieza del texto y el conteo de palabras únicas en su fragmento asignado.

  #code-block("teo/mapreduce/report/snippets/map.py", snippet: "map", lang: "python", prefix: "#")
]

#section(2, [Fase de Reducción y Orquestación (Master)])[
  El maestro distribuye los fragmentos de forma concurrente y luego consolida los resultados en un solo diccionario.

  #code-block("teo/mapreduce/report/snippets/master_handler.py", snippet: "distribute", lang: "python", prefix: "#")

  La función de reducción une los conteos parciales:

  #code-block("teo/mapreduce/report/snippets/reduce.py", snippet: "reduce", lang: "python", prefix: "#")
]

#section(2, [Capturas de Ejecución])[
  A continuación se muestran las capturas que validan el correcto funcionamiento del sistema en sus diferentes interfaces.

  #report-figure("images/gui.png")[Interfaz Web para el análisis de texto]

  #report-figure("images/cli.png")[Ejecución y resultados vía Cliente CLI]

  #report-figure("images/docker.png", h: 40%)[Logs del sistema mostrando la distribución entre Master y Worker]
]

#section(1, [Conclusiones sobre la Implementación])[
  La implementación del patrón MapReduce resuelve eficazmente el problema del conteo de palabras al permitir que el procesamiento se realice de forma distribuida. Esto evita que un solo nodo se sature al intentar cargar archivos de texto extremadamente grandes en memoria, permitiendo que el sistema escale linealmente con el número de trabajadores.

  Sin embargo, el sistema podría fallar si el nodo Maestro deja de funcionar, ya que es el único orquestador de las tareas. Asimismo, una red lenta podría degradar el rendimiento si el tiempo de transferencia de los fragmentos de texto supera al tiempo de procesamiento local.
]

#section(2, [Comparativa con Otras Arquitecturas])[
  - *Pipeline:*\ Sería eficiente para transformaciones de datos en flujo, pero no maneja nativamente la agregación masiva necesaria para el conteo global de palabras @condie2010mapreduce.
  - *Pub/Sub:*\ Facilitaría la escalabilidad de trabajadores, pero la sincronización de la fase final (Reduce) sería compleja sin un coordinador central @kleppmann2017designing.
  - *Broker:*\ Centralizaría la comunicación, pero el overhead de mensajes podría ser mayor al flujo directo gRPC entre maestro y trabajadores @kleppmann2017designing.
  - *P2P (Peer-to-Peer):*\ Ofrecería una alta disponibilidad sin puntos de fallo únicos, pero la lógica para recolectar y reducir los datos de todos los pares requeriría un protocolo de consolidación mucho más complejo @marozzo2011p2p.
]

#section(1, [Bibliografía])[
  #bibliography("bibliography.bib", title: none, style: "apa")
]
