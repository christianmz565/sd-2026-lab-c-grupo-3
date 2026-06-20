<!-- image -->

## UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA

Formato: Guía de Práctica de Laboratorio / Talleres / Centros de Simulación

Código: GUIA-PRLD-001

## GUÍA DE LABORATORIO

(formato docente)

| INFORMACIÓN BÁSICA     | INFORMACIÓN BÁSICA                              | INFORMACIÓN BÁSICA                              | INFORMACIÓN BÁSICA                              | INFORMACIÓN BÁSICA                              | INFORMACIÓN BÁSICA                              |
|------------------------|-------------------------------------------------|-------------------------------------------------|-------------------------------------------------|-------------------------------------------------|-------------------------------------------------|
| ASIGNATURA:            | SISTEMAS DISTRIBUIDOS                           | SISTEMAS DISTRIBUIDOS                           | SISTEMAS DISTRIBUIDOS                           | SISTEMAS DISTRIBUIDOS                           | SISTEMAS DISTRIBUIDOS                           |
| TÍTULO DE LA PRÁCTICA: | Replicaci ó n de datos en Sistemas Distribuidos | Replicaci ó n de datos en Sistemas Distribuidos | Replicaci ó n de datos en Sistemas Distribuidos | Replicaci ó n de datos en Sistemas Distribuidos | Replicaci ó n de datos en Sistemas Distribuidos |
| NÚMERO DE PRÁCTICA:    | 10                                              | AÑO LECTIVO:                                    | 2026                                            | NRO. SEMESTRE:                                  | 2026A                                           |
| TIPO DE                | INDIVIDUAL                                      | INDIVIDUAL                                      | INDIVIDUAL                                      | INDIVIDUAL                                      | INDIVIDUAL                                      |
| PRÁCTICA:              | GRUPAL                                          | X                                               | MÁXIMO DE ESTUDIANTES                           | MÁXIMO DE ESTUDIANTES                           | 5                                               |
| FECHA INICIO:          | 15/06/2026                                      | FECHA FIN:                                      | 19/06/2026                                      | DURACIÓN:                                       | 2 horas                                         |

## RECURSOS A UTILIZAR:

Software requerido : Docker Desktop, Docker Compose, PostgreSQL, MongoDB, Apache Cassandra, Redis MySQL Group Replication, Visual Studio Code, Postman, DBeaver o pgAdmin.

## DOCENTE(s):

- Mg. Maribel Molina Barriga

## OBJETIVOS/TEMAS Y COMPETENCIAS

Aprobación:  2022/03/01

## OBJETIVOS:

- Comprender los fundamentos de la replicación de datos en sistemas distribuidos.
- Analizar los beneficios y desafíos de implementar mecanismos de replicación en aplicaciones empresariales.
- Diferenciar estrategias de replicación síncrona y asíncrona, identificando sus ventajas y limitaciones.
- Diseñar una propuesta de arquitectura distribuida con replicación para garantizar disponibilidad y tolerancia a fallos.
- Evaluar el impacto de la consistencia, latencia y disponibilidad en escenarios empresariales reales

## TEMAS:

- La replicación en sistemas distribuidos
- Replicación maestro-esclavo (Primary-Replica). Replicación maestro-maestro (Multi-Master). Replicación síncrona y asíncrona.
- Replicación en bases de datos NoSQL.

## COMPETENCIA

C.a. Aplica de forma transformadora conocimientos de matemática, computación e ingeniería como herramienta  para  evaluar,  sintetizar  y  mostrar  información  como  fundamento  de  sus  ideas  y perspectivas para la resolución de problemas.

C.e. Identifica de forma reflexiva y responsable, necesidades a ser resueltas usando tecnologías de información  y/o  desarrollo  de  software  en  los  ámbitos  local,  nacional  o  internacional,  utilizando técnicas, herramientas, metodologías, estándares y principios de la ingeniería.

C.q. Diseña soluciones informáticas apropiadas para uno o más dominios de aplicación utilizando los principios de ingeniería que integran consideraciones éticas, sociales, legales y  económicas entiendo las fortalezas y limitaciones del contexto.

<!-- image -->

Página: 1

<!-- image -->

## UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA

Formato: Guía de Práctica de Laboratorio / Talleres / Centros de Simulación

Código: GUIA-PRLD-001

## CONTENIDO DE LA GUÍA

Aprobación:  2022/03/01

## I.  MARCO CONCEPTUAL

## 1. ¿Qué es la replicación?

La replicación consiste en mantener múltiples copias de la misma información en diferentes nodos de un sistema distribuido con el propósito de mejorar la disponibilidad, reducir tiempos de respuesta y aumentar la tolerancia a fallos.

## Conceptos clave:

- Copias redundantes de los datos.
- Sincronización entre nodos.
- Continuidad del servicio ante fallos.
- Balanceo de carga para consultas.

## 2. Replicación síncrona

En este modelo, una transacción solo se considera confirmada cuando todas las réplicas han almacenado correctamente la información.

## Ventajas

- Alta consistencia.
- Riesgo mínimo de pérdida de datos.

## Desventajas

- Mayor latencia.
- Dependencia de la disponibilidad de los nodos.

## 3. Replicación asíncrona

El nodo principal confirma la operación inmediatamente y las réplicas reciben posteriormente las actualizaciones.

## Ventajas

- Mayor rendimiento.
- Menor tiempo de respuesta.

## Desventajas

- Posible inconsistencia temporal.
- Riesgo de pérdida de datos recientes ante fallos inesperados.

## 4. Estrategias de replicación

| Estrategia           | Características                                                   | Aplicaciones                       |
|----------------------|-------------------------------------------------------------------|------------------------------------|
| Primary-Replica      | Un nodo principal realiza las escrituras y replica a secundarios. | Sistemas bancarios, ERP            |
| Multi-Master         | Múltiples nodos aceptan escrituras.                               | Aplicaciones colaborativas         |
| Peer-to-Peer         | Todos los nodos comparten responsabilidades.                      | Redes distribuidas geográficamente |
| Replicación parcial  | Solo ciertos datos son replicados.                                | Grandes volúmenes de información   |
| Replicación completa | Todos los nodos almacenan la totalidad de los datos.              | Sistemas críticos                  |

## 5. Beneficios empresariales

- Alta disponibilidad del servicio.
- Recuperación rápida ante desastres.
- Balanceo de consultas.
- Continuidad operativa.
- Escalabilidad geográfica.
- Reducción de tiempos de inactividad.

<!-- image -->

Página: 2

<!-- image -->

## UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA

Formato: Guía de Práctica de Laboratorio / Talleres / Centros de Simulación

Código: GUIA-PRLD-001

Aprobación:  2022/03/01

## III. EJERCICIOS/PROBLEMAS PROPUESTOS

Caso empresarial: FedEx Perú es una empresa internacional dedicada al transporte de productos perecibles. Cuenta con centros de distribución en Lima, Bogotá, Santiago y Ciudad de México.

Cada sede registra en tiempo real:

- Inventarios.
- Pedidos.
- Temperaturas de almacenamiento.
- Estado de los envíos.
- Ubicación de vehículos.

Durante los últimos meses se han presentado problemas críticos:

- La caída del servidor principal deja inoperativa una sede.
- Existen retrasos en la actualización del inventario entre países.
- Los reportes muestran información inconsistente.
- Los clientes reciben estados distintos según la sucursal consultada.

La gerencia decide implementar un esquema de replicación distribuida para garantizar continuidad del negocio y disponibilidad permanente de la información.

## Ejercicios y/o actividades propuestas:

## Actividad 1. Identificación de necesidades

Elabore una tabla que identifique:

- Datos críticos.
- Datos susceptibles de replicación.
- Riesgos actuales.
- Beneficios esperados de la replicación.

## Actividad 2. Diseño arquitectónico

Diseñe un diagrama que incluya:

- Nodo principal.
- Réplicas secundarias.
- Centros de distribución.
- Clientes.
- Flujo de sincronización.
- Estrategia de recuperación ante fallos.

Debe justificar por qué eligió dicha arquitectura.

## Actividad 3. Selección del tipo de replicación

Determine qué mecanismo resulta más adecuado para:

- Inventarios.
- Seguimiento de envíos.
- Historial de pedidos.
- Reportes ejecutivos.

Justifique cada decisión considerando consistencia, disponibilidad y rendimiento.

## Actividad 4. Simulación de un fallo

Suponga que el centro de datos principal en Lima deja de funcionar durante 20 minutos. Explique:

- ¿Qué nodo debería asumir el servicio?
- ¿Cómo se garantizaría la continuidad operativa?
- ¿Qué información podría perderse si la replicación fuera asíncrona?
- ¿Cómo afectaría una replicación síncrona?

<!-- image -->

Página: 3

<!-- image -->

## UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA

Formato: Guía de Práctica de Laboratorio / Talleres / Centros de Simulación

Aprobación:  2022/03/01

## Actividad 5. Evaluación crítica

Código: GUIA-PRLD-001

<!-- image -->

Página: 4

Proponga tres mejoras tecnológicas adicionales para incrementar la resiliencia del sistema distribuido, considerando aspectos como monitoreo, balanceo de carga, automatización de recuperación o estrategias híbridas de replicación.

## Entregables: Cada equipo deberá presentar:

1. Informe técnico en formato PDF (máximo 10 hojas).
2. Diagrama de arquitectura distribuida elaborado con una herramienta de modelado (por ejemplo, Draw.io, Lucidchart o Visio).
3. Tabla comparativa de estrategias de replicación seleccionadas.
4. Respuestas argumentadas a todas las actividades propuestas.
5. Conclusiones individuales y grupales.
6. Bibliografía consultada con citas en formato APA (7.ª edición) o IEEE.

## IV. CUESTIONARIO

1. En una empresa multinacional con millones de transacciones diarias, ¿cómo equilibraría la necesidad de consistencia fuerte con los requisitos de disponibilidad y baja latencia? Sustente su respuesta con ejemplos.
2. ¿Es recomendable utilizar replicación síncrona para todos los sistemas empresariales? Analice los posibles impactos técnicos, económicos y operativos de esa decisión.
3. Si usted fuera el arquitecto de software de FedEx Perú ¿qué estrategia de replicación implementaría para garantizar continuidad del negocio ante desastres regionales y por qué?

## V.  REFERENCIAS Y BIBLIOGRÁFIA RECOMENDADAS:

- [1] Tanenbaum, A.S. (2008). Sistemas distribuidos: principios y paradigmas. México. Pearson Educación.
- [2] Ceballos, F. J. (2006). Java 2, Curso de programación. México: Alfaomega, RaMa.
- [3] [3]Deitel, H. M., &amp; Deitel, P. J. (2004). Cómo programar en Java. México: Pearson Educación.
- [4] García Tomás, J., Ferrando, S., &amp; Piattini, M. (2001). Redes para procesos distribuidos. México: Alfaomega Ra-Ma.
- [5] Orfali, R., &amp; Harkey, D. (1998). Client/Server Programming with Java and CORBA. USA: Wiley
- [6] International Organization for Standardization -Norma ISO/IEC 25010 sobre calidad de productos software.
- [7] ISTQB -Fundamentos de pruebas de software.
- [8] Building  Microservices:  Designing  Fine-Grained  Systems  es  un  libro  técnico  de  Sam  Newman  publicado  por O'Reilly Media. Edición 2021.
- [9] Continuous  Delivery  es  un  libro  técnico  de  ingeniería  de  software  escrito  por  Jez  Humble  y  David  Farley, publicado en 2010 por Addison-Wesley.
- [10] https://docs.docker.com/
- [11] https://www.postgresql.org/docs/current/high-availability.html
- [12] https://cassandra.apache.org/doc/latest/
- [13] https://www.mongodb.com/es/docs/manual/replication/
- [14] https://redis.io/docs/latest/

## TÉCNICAS E INSTRUMENTOS DE EVALUACIÓN

## TÉCNICAS:

Problemas /Ejercicios propuestos

/ Preguntas formuladas /  Resolución de casos

INSTRUMENTOS:

Lista de cotejo

## CRITERIOS DE EVALUACIÓN

- Comprensión de los conceptos de replicación de datos
- Diseño de la arquitectura distribuida
- Resolución de actividades y análisis del caso

<!-- image -->

## UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA

Formato: Guía de Práctica de Laboratorio / Talleres / Centros de Simulación

Código: GUIA-PRLD-001

Aprobación:  2022/03/01

<!-- image -->

Página: 5