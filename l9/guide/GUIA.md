<!-- image -->

## UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA

Formato: Guía de Práctica de Laboratorio / Talleres / Centros de Simulación

Código: GUIA-PRLD-001

## GUÍA DE LABORATORIO

(formato docente)

| INFORMACIÓN BÁSICA     | INFORMACIÓN BÁSICA                                                    | INFORMACIÓN BÁSICA                                                    | INFORMACIÓN BÁSICA                                                    | INFORMACIÓN BÁSICA                                                    | INFORMACIÓN BÁSICA                                                    |
|------------------------|-----------------------------------------------------------------------|-----------------------------------------------------------------------|-----------------------------------------------------------------------|-----------------------------------------------------------------------|-----------------------------------------------------------------------|
| ASIGNATURA:            | SISTEMAS DISTRIBUIDOS                                                 | SISTEMAS DISTRIBUIDOS                                                 | SISTEMAS DISTRIBUIDOS                                                 | SISTEMAS DISTRIBUIDOS                                                 | SISTEMAS DISTRIBUIDOS                                                 |
| TÍTULO DE LA PRÁCTICA: | Software Quality y Software Testing aplicados a entornos distribuidos | Software Quality y Software Testing aplicados a entornos distribuidos | Software Quality y Software Testing aplicados a entornos distribuidos | Software Quality y Software Testing aplicados a entornos distribuidos | Software Quality y Software Testing aplicados a entornos distribuidos |
| NÚMERO DE PRÁCTICA:    | 9                                                                     | AÑO LECTIVO:                                                          | 2026                                                                  | NRO. SEMESTRE:                                                        | 2026A                                                                 |
| TIPO DE PRÁCTICA:      | INDIVIDUAL                                                            | INDIVIDUAL                                                            | INDIVIDUAL                                                            | INDIVIDUAL                                                            | INDIVIDUAL                                                            |
|                        | GRUPAL                                                                | X                                                                     | MÁXIMODEESTUDIANTES                                                   | MÁXIMODEESTUDIANTES                                                   | 5                                                                     |
| FECHA INICIO:          | 08/06/2026                                                            | FECHA FIN:                                                            | 12/06/2026                                                            | DURACIÓN:                                                             | 2 horas                                                               |

## RECURSOS A UTILIZAR:

Software requerido : Docker Desktop, Docker Compose, Visual Studio Code, Postman o Insomnia, JMeter o k6 para pruebas de carga, Node.js o Java (según la implementación del proyecto).

## DOCENTE(s):

- Mg. Maribel Molina Barriga

## OBJETIVOS/TEMAS Y COMPETENCIAS

Aprobación:  2022/03/01

## OBJETIVOS:

- Aplicar principios de calidad de software y estrategias de pruebas en un sistema distribuido, identificando defectos funcionales y no funcionales mediante el diseño y ejecución de casos de prueba sobre una arquitectura basada en microservicios.

## TEMAS:

- Concepto de calidad de software, Calidad en arquitecturas distribuidas.
- Verificación y validación, Pruebas funcionales, Pruebas de integración entre servicios, Pruebas de rendimiento.
- Manejo de fallos y tolerancia a errores, Automatización de pruebas, Evidencias y métricas de calidad.

## COMPETENCIA

- C.a. Aplica de forma transformadora conocimientos de matemática, computación e ingeniería como herramienta  para  evaluar,  sintetizar  y  mostrar  información  como  fundamento  de  sus  ideas  y perspectivas para la resolución de problemas.
- C.e. Identifica de forma reflexiva y responsable, necesidades a ser resueltas usando tecnologías de información  y/o  desarrollo  de  software  en  los  ámbitos  local,  nacional  o  internacional,  utilizando técnicas, herramientas, metodologías, estándares y principios de la ingeniería.
- C.q. Diseña soluciones informáticas apropiadas para uno o más dominios de aplicación utilizando los principios de ingeniería que integran consideraciones éticas, sociales, legales y  económicas entiendo las fortalezas y limitaciones del contexto.

## CONTENIDO DE LA GUÍA

## I.  MARCO CONCEPTUAL

1. Calidad de software en sistemas distribuidos

La calidad de software se refiere al grado en que un sistema satisface los requisitos funcionales y no funcionales establecidos.  En  entornos  distribuidos,  la  calidad  depende  no  solo  del  comportamiento  individual  de  cada componente, sino también de la interacción entre servicios desplegados en diferentes nodos.

<!-- image -->

Página: 1

<!-- image -->

## UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA

Formato: Guía de Práctica de Laboratorio / Talleres / Centros de Simulación

Código: GUIA-PRLD-001

Aprobación:  2022/03/01

## Aspectos relevantes:

- Disponibilidad.
- Fiabilidad.
- Escalabilidad.
- Seguridad.
- Mantenibilidad.
- Interoperabilidad.
- Recuperación ante fallos.

## 2. Software Testing en sistemas distribuidos

Las  pruebas  permiten  verificar  que  cada  componente  y  la  solución  completa  funcionan  conforme  a  las especificaciones.

Entre las pruebas más relevantes se encuentran:

- Pruebas unitarias.
- Pruebas de integración.
- Pruebas de sistema.
- Pruebas de aceptación.
- Pruebas de regresión.
- Pruebas de carga.
- Pruebas de estrés.
- Pruebas de resiliencia.

## 3. Pirámide de pruebas

La pirámide de pruebas recomienda disponer de:

- Gran cantidad de pruebas unitarias.
- Un número moderado de pruebas de integración.
- Menor cantidad de pruebas end-to-end debido a su costo y complejidad.

En sistemas distribuidos resulta esencial fortalecer las pruebas de integración para validar la comunicación entre servicios.

## 4. Pruebas de rendimiento

Las pruebas de rendimiento evalúan el comportamiento del sistema bajo diferentes cargas de trabajo. Indicadores comunes:

- Tiempo promedio de respuesta.
- Throughput.
- Número de solicitudes por segundo.
- Utilización de CPU.
- Consumo de memoria.
- Tasa de errores.
- Disponibilidad del servicio

## III. EJERCICIOS/PROBLEMAS PROPUESTOS

Caso empresarial: LogiFresh S.A. es una empresa peruana dedicada a la distribución de alimentos refrigerados a supermercados nacionales. La compañía ha modernizado su plataforma utilizando una arquitectura distribuida basada en microservicios:

- Servicio de Pedidos.
- Servicio de Inventario.
- Servicio de Facturación.
- Servicio de Transporte.
- Servicio de Notificaciones.

Durante campañas de alta demanda, algunos clientes reportan:

- Pedidos registrados sin descuento aplicado.
- Inventario inconsistente.
- Facturas duplicadas.
- Retrasos en las confirmaciones por correo electrónico.
- Lentitud superior a 8 segundos al registrar pedidos.

<!-- image -->

Página: 2

<!-- image -->

## UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA

Formato: Guía de Práctica de Laboratorio / Talleres / Centros de Simulación

Código: GUIA-PRLD-001

Aprobación:  2022/03/01

<!-- image -->

Página: 3

La dirección solicita una evaluación integral de calidad y pruebas para identificar riesgos antes de una expansión nacional.

## Ejercicios y problemas:

Actividad 1. Identificación de riesgos

Elabore una matriz identificando al menos cinco riesgos de calidad asociados al sistema distribuido. Debe incluir:

- Riesgo.
- Servicio afectado.
- Impacto.
- Probabilidad.
- Acción de mitigación.

## Actividad 2. Diseño de casos de prueba funcionales

Diseñe diez casos de prueba considerando:

- Registro correcto de pedidos.
- Pedido con inventario insuficiente.
- Cancelación de pedido.
- Aplicación de promociones.
- Generación automática de factura.
- Envío de notificaciones.

## Cada caso deberá incluir:

- Identificador.
- Objetivo.
- Datos de entrada.
- Resultado esperado.
- Resultado obtenido.

## Actividad 3. Pruebas de integración

Analice la interacción entre:

- Pedido ↔ Inve ntario.
- Pedido ↔ Facturación.
- Pedido ↔ Transporte.

Describa posibles fallos derivados de desconexiones o respuestas tardías y proponga mecanismos de recuperación.

## Actividad 4. Prueba de rendimiento

## Utilizando JMeter o k6 :

- Simule 100 usuarios concurrentes.
- Ejecute solicitudes durante 5 minutos.
- Obtenga métricas de:
- o Tiempo promedio.
- o Tiempo máximo.
- o Errores.
- o Throughput. (rendimiento o tasa de transferencia efectiva, es la cantidad de datos, productos o tareas que un sistema procesa o entrega con éxito en un período de tiempo determinado)
- Interprete los resultados.

## Actividad 5. Estrategia de mejora

Proponga cinco acciones para mejorar la calidad del sistema considerando:

- Automatización de pruebas.
- Observabilidad.
- Balanceo de carga.
- Circuit Breaker.

<!-- image -->

## UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA

Formato:

Aprobación:  2022/03/01

- Monitoreo continuo.
- Integración continua.
1. Informe técnico en PDF. (máximo 10 hojas)
2. Matriz de riesgos.
3. Casos de prueba documentados.
4. Evidencias de ejecución (capturas de pantalla).
5. Resultados de pruebas de rendimiento.
6. Análisis crítico de hallazgos.
7. Repositorio Git con los archivos utilizados.
8. Conclusiones y recomendaciones.

## Entregables: Cada grupo deberá presentar:

## IV. CUESTIONARIO

1. En  una  arquitectura  distribuida,  ¿por  qué  aumentar  la  cobertura  de  pruebas  unitarias  no  garantiza necesariamente  la  calidad  global  del  sistema?  Analice  el  papel  de  las  interacciones  entre  servicios  y proponga mecanismos complementarios de aseguramiento de la calidad.
2. Si una organización dispone de recursos limitados para pruebas, ¿qué criterios utilizaría para priorizar las pruebas funcionales, de integración y de rendimiento? Justifique su decisión considerando el impacto en el negocio y el riesgo técnico.
3. Imagine  que  las  pruebas  muestran  un  excelente  desempeño  bajo  carga,  pero  los  usuarios  continúan reportando fallos intermitentes en producción. ¿Qué hipótesis investigaría y qué evidencias adicionales recopilaría para explicar esta discrepancia?

## V. REFERENCIAS Y BIBLIOGRÁFIA RECOMENDADAS:

- [1] Tanenbaum, A.S. (2008). Sistemas distribuidos: principios y paradigmas. México. Pearson Educación.
- [2] Ceballos, F. J. (2006). Java 2, Curso de programación. México: Alfaomega, RaMa.
- [3] [3]Deitel, H. M., &amp; Deitel, P. J. (2004). Cómo programar en Java. México: Pearson Educación.
- [4] García Tomás, J., Ferrando, S., &amp; Piattini, M. (2001). Redes para procesos distribuidos. México: Alfaomega Ra-Ma.
- [5] Orfali, R., &amp; Harkey, D. (1998). Client/Server Programming with Java and CORBA. USA: Wiley
- [6] International Organization for Standardization -Norma ISO/IEC 25010 sobre calidad de productos software.
- [7] ISTQB -Fundamentos de pruebas de software.
- [8] Designing DataIntensive Applications es un libro técnico escrito por Martin Kleppmann, publicado por O'Reilly Media en 2017.
- [9] Building  Microservices:  Designing  Fine-Grained  Systems  es  un  libro  técnico  de  Sam  Newman  publicado  por O'Reilly Media . Edición 2021.
- [10] Continuous  Delivery  es  un  libro  técnico  de  ingeniería  de  software  escrito  por  Jez  Humble  y  David  Farley, publicado en 2010 por Addison-Wesley.

## TÉCNICAS E INSTRUMENTOS DE EVALUACIÓN

## TÉCNICAS:

Problemas /Ejercicios propuestos

/ Preguntas formuladas /  Resolución de casos

INSTRUMENTOS:

Lista de cotejo

## CRITERIOS DE EVALUACIÓN

- Explica y aplica correctamente los conceptos en el contexto distribuido
- Diseño de casos de prueba
- Análisis de integración y riesgos
- Presenta resultados válidos y conclusiones bien sustentadas
- Argumenta con profundidad y plantea mejoras viables

Guía de Práctica de Laboratorio / Talleres / Centros de Simulación

Código: GUIA-PRLD-001

<!-- image -->

Página: 4

<!-- image -->

## UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA

Formato: Guía de Práctica de Laboratorio / Talleres / Centros de Simulación

Código: GUIA-PRLD-001

Aprobación:  2022/03/01

<!-- image -->

Página: 5