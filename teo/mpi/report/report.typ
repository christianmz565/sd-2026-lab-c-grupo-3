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

= Enlace a GitHub
https://github.com/christianmz565/sd-2026-lab-c-grupo-3/tree/main/teo/mpi

= Introducción
El procesamiento de grandes volúmenes de datos meteorológicos requiere infraestructuras capaces de manejar cargas computacionales intensivas de manera eficiente. La computación distribuida surge como una solución robusta, permitiendo el reparto de tareas entre múltiples nodos de procesamiento. En este proyecto, se implementa un sistema de análisis meteorológico utilizando el estándar MPI (Message Passing Interface) a través de la librería `mpi4py`. El enfoque principal reside en la orquestación de un cluster virtualizado y la eficiencia de la comunicación inter-proceso para el procesamiento paralelo de datos masivos.

= Marco Teórico
La computación distribuida se basa en el uso de múltiples sistemas autónomos que se comunican a través de una red para alcanzar un objetivo común. Los modelos de programación paralela han evolucionado para abordar diferentes jerarquías de hardware @czarnul2020survey.

MPI es el estándar de facto para la comunicación en sistemas de memoria distribuida, permitiendo la transferencia de datos entre procesos independientes mediante el paso explícito de mensajes @mpi4py_paper. A diferencia de los modelos de memoria compartida, MPI requiere que el programador gestione manualmente la distribución de los datos y la sincronización, lo que ofrece un control granular y una escalabilidad casi lineal en infraestructuras de gran tamaño @ashraf2016empirical.

El modelo Maestro-Trabajador es un patrón de diseño donde un nodo central coordina la distribución de datos y la recolección de resultados, mientras que los nodos esclavos ejecutan las tareas computacionales. En el contexto de Python, `mpi4py` proporciona una interfaz idiomática que permite aprovechar las capacidades de MPI integrándose con el ecosistema de ciencia de datos (Pandas, Scikit-learn).

= Arquitectura Propuesta
La arquitectura se basa en una red de contenedores Docker que emulan un cluster de alto rendimiento (HPC). Esta configuración permite simular nodos físicos independientes con entornos de ejecución aislados, como se detalla en la @fig-architecture.

#figure(
  placement: auto,
  scope: "parent",
  image("img/architecture.png", width: 90%),
  caption: [Diagrama de Arquitectura],
) <fig-architecture>

== Infraestructura de Contenedores
El cluster se despliega mediante Docker Compose, definiendo tres tipos de servicios: `master`, `worker` (escalable) y `dashboard`. La robustez de la arquitectura reside en los siguientes pilares técnicos:

1. *Comunicación entre nodos vía SSH*: Cada contenedor ejecuta un servidor OpenSSH, así `mpirun` puede lanzar procesos de forma remota entre los contenedores de la red interna.
2. *Descubrimiento Dinámico*: El nodo maestro utiliza herramientas de red como `dig` para identificar las direcciones IP de los trabajadores a través del DNS interno de Docker.
3. *Almacenamiento*:
  - *Volúmenes Locales*: Se utilizan para persistir el dataset de entrada.
  - *Memoria Compartida (tmpfs)*: Se monta un volumen de alto rendimiento basado en RAM (`shm_data`) para el intercambio rápido de resultados JSON y archivos temporales, minimizando la latencia de I/O de disco durante la agregación final.

== Operaciones Colectivas MPI
La comunicación se hace mediante el uso de operaciones colectivas:
- *Scatter*: Distribuye equitativamente fragmentos del dataset global desde la memoria del maestro hacia los trabajadores.
- *Gather*: Recolecta y consolida los objetos de resultados calculados de forma independiente.

= Desarrollo de la Solución
La solución integra la generación de datos, el procesamiento distribuido y la visualización final.

== Generación de Datos
Se utiliza un modelo basado en funciones sinusoidales para generar un millón de registros que incluyen variables de temperatura, humedad y viento, incorporando estacionalidad y sesgos geográficos para simular condiciones meteorológicas reales.

== Procesamiento y Modelado
Cada proceso trabajador recibe un fragmento de datos y realiza un análisis estadístico exhaustivo. Además, se emplea un modelo de regresión lineal de Scikit-learn para proyectar tendencias futuras a partir de los datos procesados localmente. El enfoque aquí no es la precisión del modelo, sino la capacidad del sistema para distribuir la carga de entrenamiento y predicción entre múltiples nodos.

== Visualización
Los resultados agregados se visualizan en un dashboard interactivo desarrollado en Plotly Dash, que consume los datos procesados almacenados en el volumen de memoria compartida para garantizar una respuesta fluida de la interfaz (ver @figs-dash-1 y @figs-dash-2)

#figure(
  image("img/dash_1.png"),
  caption: [Dashboard: Sección superior],
) <figs-dash-1>

#figure(
  image("img/dash_2.png"),
  caption: [Dashboard: Sección inferior],
) <figs-dash-2>

= Resultados
Se realizaron pruebas de rendimiento comparando una ejecución secuencial frente a una distribuida con 4 trabajadores (ver @fig-benchmark).

#table(
  columns: (1fr, 1fr),
  table.header([*Estrategia*], [*Ejecución (s)*]),
  [Secuencial], [8.841],
  [MPI], [11.166],
)

#figure(
  placement: auto,
  scope: "parent",
  image("img/benchmark.png", width: 100%),
  caption: [Resultados del Benchmark con Hyperfine],
) <fig-benchmark>

Aunque el tiempo MPI es superior en este entorno virtualizado, este comportamiento se justifica por dos factores técnicos críticos:

1. *Docker y Red Virtual*: El uso de contenedores en una sola máquina física introduce una latencia de red virtual y sobrecarga de gestión de recursos que no existe en un entorno bare-metal @docker_mpi_mdpi. En un entorno de producción HPC, la interconexión de baja latencia (como InfiniBand) permitiría que el paralelismo supere rápidamente los retrasos en comunicación.
2. *Eficiencia de Scikit-learn*: Las rutinas internas de Scikit-learn ya están altamente optimizadas mediante OpenMP y BLAS, lo que permite que la ejecución secuencial aproveche varios núcleos de manera eficiente sin la sobrecarga de paso de mensajes de MPI @sklearn_parallelism.

No obstante, la arquitectura demuestra su capacidad para manejar volúmenes de datos que excederían la memoria de un solo nodo, justificando su uso por la escalabilidad horizontal y la resiliencia en el manejo de grandes conjuntos de datos.

= Discusión
La elección de MPI frente a otras tecnologías se fundamenta en sus características específicas para HPC y sistemas distribuidos:

- *MPI vs OpenMP*: OpenMP es excelente para paralelismo en memoria compartida, pero está limitado a una única máquina física. MPI, aunque conlleva una mayor complejidad por el paso de mensajes explícito, permite escalar a miles de nodos interconectados @nvidia_forum.
- *MPI vs CUDA*: CUDA permite una aceleración masiva en GPUs para tareas masivamente paralelas (SIMD). Sin embargo, requiere hardware propietario y sufre de cuellos de botella en la transferencia de datos entre CPU y GPU. MPI es agnóstico al hardware y es preferible para tareas que requieren gran capacidad de memoria distribuida @ashraf2016empirical.
- *MPI vs Ray*: Ray es un framework moderno diseñado para aplicaciones de IA con escalado dinámico. Aunque es más flexible y maneja fallos de forma automática, MPI ofrece un rendimiento superior y menor latencia en aplicaciones científicas con patrones de comunicación estáticos y predecibles @ray_vs_spark.

= Conclusiones
El sistema implementado demuestra que la combinación de MPI y Docker proporciona una plataforma robusta para el procesamiento distribuido. La arquitectura de comunicación basada en SSH y el uso de volúmenes en memoria optimizan el rendimiento en entornos virtualizados. Aunque la virtualización introduce latencias, la capacidad de escalabilidad horizontal posiciona a esta solución como una base sólida para aplicaciones de procesamiento de datos meteorológicos a gran escala en infraestructuras de nube.

= Referencias
#set text(size: 11pt)
#bibliography("bibliography.bib", style: "apa", title: none)
