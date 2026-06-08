#import "template.typ": project

#show: doc => project(
  title: [
    ANÁLISIS DISTRIBUIDO DE DATOS METEOROLÓGICOS MEDIANTE MPI
  ],
  authors: (
    "BEDREGAL PEREZ, DANIEL",
    "JARA MAMANI, MARIEL ALISSON",
    "MESTAS ZEGARRA, CHRISTIAN RAUL",
    "NOA CAMINO, YENARO JOEL",
    "SEQUEIROS CONDORI, LUIS GUSTAVO",
  ),
  course: "SISTEMAS DISTRIBUIDOS",
  group: "GRUPO 2",
  teacher: "MOLINA BARRIGA, MARIBEL",
  doc,
)

= Introducción
El procesamiento de grandes volúmenes de datos meteorológicos requiere infraestructuras capaces de manejar cargas computacionales intensivas de manera eficiente. La computación distribuida surge como una solución robusta, permitiendo el reparto de tareas entre múltiples nodos de procesamiento. En este proyecto, se implementa un sistema de análisis meteorológico utilizando el estándar MPI (Message Passing Interface) a través de la librería `mpi4py`. El sistema no solo realiza cálculos estadísticos básicos, sino que también integra modelos de regresión de Scikit-learn para predicciones meteorológicas, simulando un cluster de alto rendimiento (HPC) mediante contenedores Docker.

= Marco Teórico
La computación distribuida se basa en el uso de múltiples sistemas autónomos que se comunican a través de una red para alcanzar un objetivo común. MPI es el estándar de facto para la comunicación en sistemas de memoria distribuida, permitiendo la transferencia de datos entre procesos independientes @mpi4py_paper.

El modelo Maestro-Trabajador es un patrón de diseño donde un nodo central coordina la distribución de datos y la recolección de resultados, mientras que los nodos esclavos ejecutan las tareas computacionales. En el contexto de Python, `mpi4py` proporciona una interfaz que permite aprovechar las capacidades de MPI de manera idiomática, facilitando la paralelización de librerías científicas como Pandas y Scikit-learn.

= Arquitectura Propuesta
La arquitectura se basa en una red de contenedores Docker que simulan nodos físicos en un cluster. El nodo maestro orquesta la ejecución, mientras que los nodos trabajadores realizan el análisis de fragmentos de datos.

#figure(
  placement: auto,
  scope: "parent",
  image("img/architecture.png", width: 90%),
  caption: [Diagrama de Arquitectura en PlantUML (Simulación de Cluster Docker)],
)

La comunicación se realiza mediante operaciones colectivas de MPI:
- *Scatter*: Para distribuir fragmentos del dataset global desde el maestro hacia los trabajadores.
- *Gather*: Para recolectar las métricas y predicciones parciales calculadas por cada trabajador.

= Desarrollo de la Solución
La solución se compone de tres fases principales:

1. *Generación de Datos*: Un script en Python genera un dataset sintético con miles de registros meteorológicos, almacenándolos en un volumen compartido (`/data`).
2. *Procesamiento Distribuido*: Se utiliza `mpirun` para lanzar procesos en los contenedores. Cada proceso carga su fragmento de datos, aplica limpieza con Pandas y ejecuta un pipeline de Scikit-learn para predecir tendencias futuras.
3. *Visualización*: Un servidor Plotly Dash lee los resultados agregados (almacenados en JSON) y genera un dashboard interactivo que muestra promedios globales, estadísticas por estación y gráficos de predicción.

= Resultados
Se realizaron pruebas de rendimiento comparando una ejecución secuencial frente a una distribuida con 4 trabajadores.

#table(
  columns: (1fr, 1fr),
  table.header([*Estrategia*], [*Ejecución (s)*]),
  [Secuencial], [8.841],
  [MPI], [11.166],
)

Aunque el tiempo MPI es superior en este escenario específico, se justifica por dos factores:
1. *Docker y Red Virtual*: El uso de contenedores en una sola máquina física introduce una latencia de red virtual y sobrecarga de gestión de recursos que no existe en un entorno bare-metal @docker_mpi_mdpi.
2. *Eficiencia de Scikit-learn*: Las rutinas internas de Scikit-learn ya están altamente optimizadas mediante OpenMP y BLAS, lo que permite que la ejecución secuencial aproveche varios núcleos de manera eficiente sin la sobrecarga de paso de mensajes de MPI @sklearn_parallelism.

#figure(
  placement: auto,
  scope: "parent",
  image("img/benchmark.png", width: 100%),
  caption: [Resultados del Benchmark con Hyperfine],
)

#figure(
  image("img/dash_1.png"),
  caption: [Dashboard: Estadísticas Globales y de Estación],
)

#figure(
  image("img/dash_2.png"),
  caption: [Dashboard: Predicciones y Análisis de Tendencias],
)

= Discusión
La comparación de MPI frente a otras tecnologías revela distintos nichos de aplicación:

- *OpenMP*: Ideal para paralelismo de memoria compartida en un solo nodo. Es más simple de implementar pero no escala a múltiples máquinas, a diferencia de MPI @nvidia_forum.
- *CUDA*: Proporciona una aceleración masiva para tareas altamente paralelizables (SIMT) en GPUs. Sin embargo, requiere hardware especializado de NVIDIA y una reestructuración profunda del código @nvidia_forum.
- *Ray*: Un framework moderno que ofrece una latencia de tareas más baja y mayor flexibilidad que MPI para aplicaciones de Machine Learning, aunque con una madurez menor en entornos HPC tradicionales @ray_vs_spark @mpi_vs_ray.

= Conclusiones
El sistema implementado demuestra la viabilidad de utilizar MPI para el procesamiento distribuido de datos meteorológicos, integrando herramientas modernas de ciencia de datos. A pesar de la sobrecarga observada en entornos virtualizados pequeños, el modelo propuesto ofrece una escalabilidad horizontal superior para datasets que superen la capacidad de memoria de un solo nodo. Se recomienda la transición a un entorno HPC real para minimizar las latencias de comunicación y maximizar el aprovechamiento del paralelismo distribuido.

= Referencias
#set text(size: 10pt)
#bibliography("bibliography.bib", style: "apa", title: none)
