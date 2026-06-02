<!-- image -->

## UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA

Formato: Guía de Práctica de Laboratorio / Talleres / Centros de Simulación

Código: GUIA-PRLD-001

## GUÍA DE LABORATORIO

## (formato docente)

| INFORMACIÓN BÁSICA     | INFORMACIÓN BÁSICA          | INFORMACIÓN BÁSICA          | INFORMACIÓN BÁSICA          | INFORMACIÓN BÁSICA          | INFORMACIÓN BÁSICA          |
|------------------------|-----------------------------|-----------------------------|-----------------------------|-----------------------------|-----------------------------|
| ASIGNATURA:            | SISTEMAS DISTRIBUIDOS       | SISTEMAS DISTRIBUIDOS       | SISTEMAS DISTRIBUIDOS       | SISTEMAS DISTRIBUIDOS       | SISTEMAS DISTRIBUIDOS       |
| TÍTULO DE LA PRÁCTICA: | Bases de datos distribuidas | Bases de datos distribuidas | Bases de datos distribuidas | Bases de datos distribuidas | Bases de datos distribuidas |
| NÚMERO DE PRÁCTICA:    | 8                           | AÑO LECTIVO:                | 2026                        | NRO. SEMESTRE:              | 2026A                       |
| TIPO DE PRÁCTICA:      | INDIVIDUAL                  | INDIVIDUAL                  | INDIVIDUAL                  | INDIVIDUAL                  | INDIVIDUAL                  |
|                        | GRUPAL                      | X                           | MÁXIMODEESTUDIANTES         | MÁXIMODEESTUDIANTES         | 5                           |
| FECHA INICIO:          | 01/06/2026                  | FECHA FIN:                  | 05/06/2026                  | DURACIÓN:                   | 2 horas                     |

## RECURSOS A UTILIZAR:

Software requerido : Sistema Operativo Windows o Linux, Docker Desktop, Docker Compose, PostgreSQL 16, pgAdmin 4, Python 3.12, Visual Studio Code, DBeaver Community Edition

## Librerías

pip install psycopg2-binary

pip install sqlalchemy

pip install flask

## DOCENTE(s):

- Mg. Maribel Molina Barriga

## OBJETIVOS/TEMAS Y COMPETENCIAS

Aprobación:  2022/03/01

## OBJETIVOS:

- Implementar y analizar mecanismos de gestión de transacciones en bases de datos distribuidas, garantizando las propiedades ACID, la consistencia de los datos y la tolerancia a fallos en entornos empresariales distribuidos.

## TEMAS:

- Bases de datos distribuidas. Transacciones distribuidas.
- Propiedades ACID. Consistencia de datos.
- Protocolos de confirmación distribuida. Two-Phase Commit (2PC).
- Control de concurrencia. Recuperación ante fallos.
- Replicación y sincronización de datos. Casos empresariales distribuidos.

## COMPETENCIA

- C.a.  Aplica  de  forma  transformadora  conocimientos  de  matemática,  computación  e ingeniería como  herramienta para evaluar, sintetizar y mostrar información  como fundamento de sus ideas y perspectivas para la resolución de problemas.
- C.e.  Identifica  de  forma  reflexiva  y  responsable,  necesidades  a  ser  resueltas  usando tecnologías  de  información  y/o  desarrollo  de  software  en  los  ámbitos  local,  nacional  o internacional, utilizando técnicas, herramientas, metodologías, estándares y principios de la ingeniería.
- C.q.  Diseña  soluciones  informáticas  apropiadas  para  uno  o  más  dominios  de  aplicación utilizando los principios de ingeniería que integran consideraciones éticas, sociales, legales y económicas entiendo las fortalezas y limitaciones del contexto.

<!-- image -->

Página: 1

<!-- image -->

## UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA

Formato: Guía de Práctica de Laboratorio / Talleres / Centros de Simulación

Código: GUIA-PRLD-001

## CONTENIDO DE LA GUÍA

Aprobación:  2022/03/01

## I.  MARCO CONCEPTUAL

## 1. Bases de Datos Distribuidas

Una base de datos distribuida es una colección de datos almacenados en múltiples nodos conectados mediante una red, pero administrados como un único sistema lógico.

## Características

- Transparencia de ubicación.
- Escalabilidad.
- Disponibilidad.
- Tolerancia a fallos.
- Consistencia de datos.
2. Arquitectura de una Base de Datos Distribuida

## Descripción

Los clientes realizan solicitudes a diferentes nodos que almacenan fragmentos o réplicas de los datos. El sistema coordina las operaciones para mantener la consistencia global.

## 3. Transacciones Distribuidas

Una transacción distribuida involucra operaciones ejecutadas en dos o más nodos de una base de datos distribuida.

## Ejemplo:

- Debitar dinero en una cuenta ubicada en Lima.
- Acreditar dinero en una cuenta ubicada en Arequipa.

Ambas operaciones deben ejecutarse exitosamente o revertirse completamente.

## 4. Propiedades ACID

## Atomicidad

La transacción se ejecuta completamente o no se ejecuta.

## Consistencia

Los datos permanecen válidos antes y después de la transacción.

## Aislamiento

Las transacciones concurrentes no interfieren entre sí.

## Durabilidad

Una vez confirmados los cambios, permanecen almacenados.

## 5. Protocolo Two-Phase Commit (2PC)

Es el protocolo más utilizado para coordinar transacciones distribuidas.

## Fase 1: Preparación (Prepare)

El coordinador solicita a cada nodo participante si puede ejecutar la transacción.

## Fase 2: Confirmación (Commit)

Si todos responden afirmativamente:

COMMIT;

Caso contrario:

ROLLBACK;

## Diagrama del protocolo 2PC

## 6. Problemas de las Transacciones Distribuidas

- Latencia de red.
- Bloqueo de recursos.
- Fallos de comunicación.
- Pérdida de nodos.
- Deadlocks distribuidos.

## 7. Recuperación ante Fallos

Cuando ocurre un fallo durante una transacción:

- Se revisan los logs.

<!-- image -->

Página: 2

<!-- image -->

## UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA

Formato: Guía de Práctica de Laboratorio / Talleres / Centros de Simulación

Código: GUIA-PRLD-001

Aprobación:  2022/03/01

- Se determina el último estado consistente.
- Se realiza COMMIT o ROLLBACK.

## III. EJERCICIOS/PROBLEMAS PROPUESTOS

## Caso estudio: FarmaAndes S.A.

FarmaAndes S.A. es una cadena farmacéutica peruana con centros de distribución en: Arequipa, Lima, Cusco Cada sede posee una base de datos local para controlar su inventario.

Cuando una sucursal solicita medicamentos a otra sede, el sistema debe realizar una transacción distribuida para garantizar que:

1. El inventario se descuente del almacén origen.
2. El inventario se incremente en el almacén destino.
3. Ambas operaciones sean atómicas.

Si una operación falla, toda la transacción debe revertirse.

## Implementación:

## Crear dos bases de datos PostgreSQL

```
Nodo 1 CREATE DATABASE almacen_arequipa; Nodo 2 CREATE DATABASE almacen_lima; Crear tabla Inventario CREATE TABLE inventario( id SERIAL PRIMARY KEY, producto VARCHAR(100), stock INTEGER ); Datos Iniciales Arequipa INSERT INTO inventario(producto,stock) VALUES('Paracetamol',100); Lima INSERT INTO inventario(producto,stock) VALUES('Paracetamol',50);
```

## Ejercicio 1

Transferencia Exitosa. Transferir 20 unidades desde Arequipa hacia Lima.

## Actividades

1. Verificar stock disponible.
2. Iniciar transacción.
3. Actualizar inventario origen.
4. Actualizar inventario destino.
5. Confirmar cambios.

## Resultado esperado

## Ejercicio 2

Simulación de Fallo

Durante la transferencia:

| Nodo     |   Stock |
|----------|---------|
| Arequipa |      80 |
| Lima     |      70 |

<!-- image -->

Página: 3

<!-- image -->

## UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA

Formato: Guía de Práctica de Laboratorio / Talleres / Centros de Simulación

Aprobación:  2022/03/01

- El nodo Lima deja de responder.

## Actividades

1. Iniciar transacción.
2. Descontar stock en Arequipa.
3. Simular caída de Lima.
4. Ejecutar rollback.

## Resultado esperado

| Nodo     |   Stock |
|----------|---------|
| Arequipa |     100 |
| Lima     |      50 |

## Caso estudio: Sistema Nacional de Bancos Cooperativos

Una red financiera opera en tres ciudades: Arequipa, Cusco y Trujillo. Cada ciudad administra cuentas locales. Un cliente solicita transferir S/ 25 000 desde Arequipa hacia Cusco.

## Restricciones

- Debe aplicarse atomicidad.
- Debe garantizarse consistencia.
- Debe existir recuperación ante fallos.
- Debe documentarse el proceso mediante 2PC.

## Actividad 1

Diseñar el modelo distribuido.

## Actividad 2

## Identificar:

- Coordinador.
- Participantes.
- Recursos involucrados.

## Actividad 3

Elaborar el diagrama de secuencia del protocolo 2PC.

## Actividad 4

Implementar la simulación usando PostgreSQL.

## Actividad 5

## Simular:

- Falla de red.
- Caída de nodo.
- Recuperación posterior.

## Actividad 6

## Analizar:

- Impacto sobre consistencia.
- Impacto sobre disponibilidad.
- Estrategias de mejora.

## Entregables

Cada grupo deberá presentar:

## Documento Técnico (PDF)

Debe contener:

- Arquitectura propuesta.
- Capturas de pantalla.
- Scripts SQL utilizados.
- Resultados obtenidos.
- Análisis de fallos.
- Conclusiones.

Código: GUIA-PRLD-001

<!-- image -->

Página: 4

<!-- image -->

## UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA

Formato: Guía de Práctica de Laboratorio / Talleres / Centros de Simulación

Código: GUIA-PRLD-001

Aprobación:  2022/03/01

## Código Fuente

Repositorio estructurado con:

Laboratorio08/

- -scripts\_sql/
- -python/
- -capturas/
- -informe.pdf
-  README.md

## Exposición de Sustentación

Duración: Entre 5 y 7 minutos.

Debe mostrar: Configuración. Ejecución. Resultados. Explicación técnica.

## IV. CUESTIONARIO

1. Una empresa financiera prioriza la disponibilidad del servicio sobre la consistencia de los datos. ¿Qué riesgos podrían surgir y cómo afectarían a los clientes?
2. El protocolo Two-Phase Commit garantiza consistencia, pero puede reducir la disponibilidad del sistema. ¿Considera que este sacrificio es justificable en todos los contextos empresariales? Fundamente su respuesta.
3. Imagine que una organización global opera cientos de nodos distribuidos. ¿Qué alternativas al protocolo 2PC podrían mejorar el rendimiento sin comprometer significativamente la confiabilidad del sistema?

## V. REFERENCIAS Y BIBLIOGRÁFIA RECOMENDADAS:

- [1] Tanenbaum, A.S. (2008). Sistemas distribuidos: principios y paradigmas. México. Pearson Educación.
- [2] Ceballos, F. J. (2006). Java 2, Curso de programación. México: Alfaomega, RaMa.
- [3] [3]Deitel, H. M., &amp; Deitel, P. J. (2004). Cómo programar en Java. México: Pearson Educación.
- [4] García Tomás, J., Ferrando, S., &amp; Piattini, M. (2001). Redes para procesos distribuidos. México: Alfaomega Ra-Ma.
- [5] Orfali, R., &amp; Harkey, D. (1998). Client/Server Programming with Java and CORBA. USA: Wiley
- [6] Arquitectura  Java  -  JDBC,  Revisado:20/05/2022.  Recuperado  de:  https://www.arquitecturajava.com/jdbcdriver-un-concepto-clave/
- [7] Apuntes de JDBC , Revisado: 07/05/2022. Recuperado de: http://profesores.fib.unam.mx/sun/Downloads/Java/jdbc.pdf
- [8] Video de Uso de Transacciones en Base de Datos JDBC. Recuperado de:  https://www.youtube.com/watch?v=z1ULbXa\_jOM

<!-- image -->

Página: 5

<!-- image -->

## UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA

Formato: Guía de Práctica de Laboratorio / Talleres / Centros de Simulación

Código: GUIA-PRLD-001

## TÉCNICAS E INSTRUMENTOS DE EVALUACIÓN

## TÉCNICAS:

Problemas /Ejercicios propuestos / Preguntas formuladas / Resolución de casos

## INSTRUMENTOS:

Lista de cotejo

## CRITERIOS DE EVALUACIÓN

- Identifica el uso de las transacciones en bases de datos distribuidas
- Realiza aplicaciones de transacciones con Commit y Rollback

Aprobación:  2022/03/01

<!-- image -->

Página: 6