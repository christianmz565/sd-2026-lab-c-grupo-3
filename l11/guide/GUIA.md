## **UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA** 

~~RC~~ **Aprobación: 2022/03/01** ~~a~~ 

**Formato:** Guía de Práctica de Laboratorio / Talleres / Centros de Simulación 

**Código: GUIA-PRLD-001** 

**Página:** 1 

# **GUÍA DE LABORATORIO** GUIA DE LABORATORIO 

**(formato docente)** 

## **INFORMACIÓN BÁSICA** 

|**ASIGNATURA:**|SISTEMAS DISTRIBUIDOS|SISTEMAS DISTRIBUIDOS|||||
|---|---|---|---|---|---|---|
|**TÍTULO DE LA**<br>**PRÁCTICA:**|**Seguridad Informática en Sistemas Distribuidos**||||||
|**NÚMERO DE**<br>**PRÁCTICA:**|**11**|**AÑO LECTIVO:**|2026|**NRO.**<br>**SEMESTRE:**|2026A||
|**TIPO DE**|**INDIVIDUAL**||||||
|**PRÁCTICA:**|**GRUPAL**|X|**MÁXIMO DE ESTUDIANTES**|||**3**|
|**FECHA INICIO:**|**22/06/2026**|**FECHA FIN:**|**26/06/2026**|**DURACIÓN: 2 horas**|**DURACIÓN: 2 horas**||



## **RECURSOS A UTILIZAR:** 

- **Herramientas obligatorias:** Sistema operativo Windows o Linux, Docker Desktop, Visual Studio Code, Python 3.x, Postman, OpenSSL, Wireshark, Navegador Web (Chrome o Firefox) 

- **Herramientas opcionales:** OWASP ZAP, Keycloak, Kubernetes (Minikube) 

## **DOCENTE(s):** 

- Mg. Maribel Molina Barriga 

## **OBJETIVOS/TEMAS Y COMPETENCIAS** 

## **OBJETIVOS:** 

- Explicar el funcionamiento del Grid Tool 

- • Realizar la propuesta aplicativa con una herramienta de Grid Tool 

## **TEMAS:** 

- Seguridad en sistemas distribuidos. 

- • Autenticación y autorización, Criptografía aplicada y Certificados digitales y SSL/TLS. • Control de acceso basado en roles (RBAC) y Gestión de identidades. • Ataques comunes en sistemas distribuidos. Seguridad en APIs y microservicios, Registro y auditoría de eventos. Buenas prácticas de ciberseguridad 

- **COMPETENCIA** C.q. Diseña soluciones informáticas apropiadas para uno o más dominios de aplicación utilizando los principios de ingeniería que integran consideraciones éticas, sociales, legales y económicas entiendo las fortalezas y limitaciones del contexto. 

## **CONTENIDO DE LA GUÍA** 

## **I. MARCO CONCEPTUAL** 

## **1. Seguridad en Sistemas Distribuidos** 

La seguridad en sistemas distribuidos busca proteger los recursos compartidos frente a accesos no autorizados, alteraciones de información y ataques externos. 

_**Figura 1. Principios fundamentales de SI**_ 

## **UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA** 

**Formato:** Guía de Práctica de Laboratorio / Talleres / Centros de Simulación **Aprobación: 2022/03/01 Código: GUIA-PRLD-001 Página:** 2 

**Referencia:** NIST Cybersecurity Framework 

## **2. Autenticación y Autorización** 

**Autenticación.** Proceso mediante el cual un usuario demuestra su identidad. Ejemplos: 

- Usuario y contraseña 

- Certificados digitales 

- Autenticación multifactor (MFA) 

**Autorización.** Define los permisos que posee un usuario autenticado. Ejemplos: 

- RBAC -Role-Based Access Control (Control de Acceso Basado en Roles) 

- ABAC - Attribute-Based Access Control (Control de Acceso Basado en Atributos) 

- ACL  - Access Control List (Lista de Control de Acceso) 

   - _**Figura 2. Autenticación y Autorización**_ 

**Referencia:** OWASP Authentication Cheat Sheet 

**3. Criptografía y SSL/TLS** (Secure Sockets Layer/ Transport Layer Security) La criptografía permite proteger la información transmitida entre nodos distribuidos. Criptografía Simétrica 

- AES  (Estándar de Cifrado Avanzado) 

- DES (Estándar de Cifrado de Datos) 

AES es el estándar moderno de cifrado simétrico y es ampliamente utilizado en sistemas distribuidos, aplicaciones web, servicios en la nube y comunicaciones seguras. DES fue un estándar importante históricamente, pero actualmente se considera inseguro debido al tamaño reducido de su clave y ha sido reemplazado por AES. 

Criptografía Asimétrica 

- RSA 

- ECC 

La diferencia de AES o DES, RSA utiliza dos claves: 

**UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA Formato:** Guía de Práctica de Laboratorio / Talleres / Centros de Simulación ~~pT~~ **Aprobación: 2022/03/01 Código: GUIA-PRLD-001 Página:** 3 ~~a~~ • Clave pública: puede compartirse con cualquier persona. • Clave privada: solo la conoce el propietario **SSL/TLS.** Protocolo utilizado para asegurar comunicaciones cliente-servidor. **Referencia:** OpenSSL Documentation 

## **4. Seguridad en APIs y Microservicios** 

Las APIs constituyen uno de los componentes más expuestos de un sistema distribuido. Riesgos comunes 

   - Inyección SQL (ocurre cuando un atacante introduce código SQL malicioso en campos de entrada de una aplicación para manipular las consultas enviadas a la base de datos.) 

   - Broken Authentication  (Se produce cuando los mecanismos de autenticación presentan debilidades que permiten a un atacante comprometer cuentas de usuarios.) 

   - • Broken Access Control  (Ocurre cuando un usuario puede realizar acciones o acceder a recursos para los cuales no tiene autorización.) 

   - • Exposición de datos sensibles (Se presenta cuando información confidencial es almacenada, transmitida o procesada sin la protección adecuada.) 

- Ataques DoS: (Un Ataque de Denegación de Servicio (DoS) busca hacer que un sistema, servicio o aplicación deje de estar disponible para los usuarios legítimos.). Cuando el ataque se realiza desde múltiples equipos comprometidos simultáneamente se denomina DDoS (Distributed Denial of Service). 

- Mecanismos de protección 

   - OAuth 2.0  (Open Authorization) es un protocolo de autorización que permite a una aplicación acceder a recursos protegidos de un usuario sin necesidad de conocer su contraseña.) 

- JWT ((JSON Web Token) es un estándar abierto utilizado para transmitir información de forma segura entre dos partes mediante un token firmado digitalmente. El token contiene información del usuario y sus permisos.) 

   - API Gateway : es un componente que actúa como punto único de entrada para todas las solicitudes dirigidas a los microservicios. En lugar de que los clientes accedan directamente a cada servicio, todas las peticiones pasan por el Gateway. Arquitectura: Rate Limiting 

- **Referencia:** OWASP API Security Project 

## **5. Registro y Auditoría** 

Permite identificar eventos de seguridad y facilitar investigaciones posteriores. 

Elementos auditables 

   - Intentos de acceso 

   - Operaciones críticas 

   - Errores de autenticación 

   - Cambios de configuración 

- Beneficios 

   - Cumplimiento normativo 

   - Trazabilidad 

   - Detección de incidentes 

## **II. EJERCICIOS/PROBLEMAS PROPUESTOS** 

Caso estudio. LogiMarket Perú S.A.C. es una empresa de logística y comercio electrónico que opera en varias ciudades del país. La organización ha migrado su plataforma tecnológica hacia una arquitectura basada en microservicios. 

Actualmente posee: 

- Servicio de autenticación 

- Servicio de inventario 

- Servicio de pagos 

- Servicio de logística 

- Portal web para clientes 

- Aplicación móvil 

**UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA Formato:** Guía de Práctica de Laboratorio / Talleres / Centros de Simulación ~~pT~~ **Aprobación: 2022/03/01 Código: GUIA-PRLD-001 Página:** 4 ~~a~~ Recientemente se detectaron los siguientes incidentes: 1. Accesos no autorizados a cuentas de clientes. 2. Interceptación de tráfico entre servicios. 3. Exposición accidental de datos personales. 4. Ausencia de mecanismos de auditoría. 

5. Uso de credenciales compartidas por empleados. 

La dirección de TI solicita una evaluación integral de seguridad. 

**Actividad 1: Identificación de amenazas** Utilizando el caso empresarial: Realizar 

   - Identificar activos críticos. 

   - Identificar amenazas potenciales. 

- Elaborar una matriz de riesgos. 

- Producto esperado. Tabla de riesgos con: 

   - Activo 

   - Amenaza 

   - Vulnerabilidad 

   - Impacto 

   - Nivel de riesgo 

## **Actividad 2: Diseño de autenticación segura** 

Diseñar una propuesta para: 

- MFA 

- Gestión de contraseñas 

- Gestión de identidades 

Producto esperado: Diagrama de arquitectura de autenticación.

## **Actividad 3: Seguridad de comunicaciones**

Implementar una demostración utilizando OpenSSL. Realizar 

   - Crear certificado autofirmado. 

   - Configurar canal HTTPS local. 

- Verificar tráfico cifrado. 

- Evidencias 

   - Capturas de pantalla. 

   - Certificados generados. 

   - Resultados obtenidos. 

## **Actividad 4: Protección de APIs** 

Diseñar una arquitectura segura para APIs empresariales. Incluir 

- JWT 

- OAuth 2.0 

- API Gateway 

- Rate Limiting 

Producto esperado: Diagrama técnico con explicación. 

## **Actividad 5: Sistema de auditoría** 

Diseñar un esquema de monitoreo y auditoría. Considerar 

- Eventos registrados. 

- Alertas. 

- Almacenamiento de logs. 

- Políticas de retención. 

Producto esperado: Diagrama de flujo y descripción técnica. 

**UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA** 

**Formato:** Guía de Práctica de Laboratorio / Talleres / Centros de Simulación ~~pT~~ **Aprobación: 2022/03/01 Código: GUIA-PRLD-001 Página:** 5 ~~a~~ **Entregables:** Los grupos deberán presentar: Informe Técnico en el formato entregado. Contenido: 

   1. Desarrollo de actividades. 

   2. Diagramas elaborados. 

   3. Evidencias de implementación. 4. Análisis de resultados. 

   5. Conclusiones. 

6. Referencias bibliográficas. 

Archivos Complementarios: • Diagramas en formato PNG o JPG. • Capturas de pantalla. 

   - Scripts utilizados en Git hub. 

- Configuraciones realizadas. 

- **III. CUESTIONARIO** 

1. Una empresa implementa autenticación multifactor, pero continúa sufriendo accesos no autorizados. Analice críticamente qué otros factores organizacionales, tecnológicos y humanos podrían estar influyendo en la ocurrencia de estos incidentes y proponga soluciones integrales. 

2. La dirección de una empresa considera que implementar mecanismos avanzados de cifrado reducirá significativamente el rendimiento de sus sistemas distribuidos. Evalúe esta afirmación y argumente cómo puede lograrse un equilibrio entre seguridad y desempeño. 

3. Si una organización posee recursos limitados para invertir en ciberseguridad, ¿qué controles de seguridad priorizaría para proteger una arquitectura basada en microservicios? Justifique técnicamente su respuesta considerando riesgos, impacto y costo-beneficio. 

## **IV. REFERENCIAS Y BIBLIOGRÁFIA RECOMENDADAS:** 

- Tanenbaum, A.S. (2008). Sistemas distribuidos: principios y paradigmas. México. Pearson Educación. 

- Ceballos, F. J. (2006). Java 2, Curso de programación. México: Alfaomega, RaMa. 

- Coulouris, G., Dollimore, J., Kindberg, T., & Blair, G. (2012). 

- Deitel, H. M., & Deitel, P. J. (2004). Cómo programar en Java. México: Pearson Educación. 

- García Tomás, J., Ferrando, S., & Piattini, M. (2001). Redes para procesos distribuidos. México: Alfaomega Ra-Ma. 

## **Recurso web:** 

- OWASP Foundation   https://owasp.org/ 

- NIST Cybersecurity Framework   https://www.nist.gov/cyberframework 

- OpenSSL Documentation https://docs.openssl.org/master/ 

- MITRE ATT&CK Framework   https://attack.mitre.org/ 

- • CISA Cybersecurity Resources   https://www.cisa.gov/topics/cybersecurity-best-practices 

|**TÉCNICAS E INSTRUMENTOS DE EVALUACIÓN**|**TÉCNICAS E INSTRUMENTOS DE EVALUACIÓN**|
|---|---|
|**TÉCNICAS:**|**INSTRUMENTOS:**|
|_Problemas /Ejercicios propuestos_|_Lista de cotejo_|
|_/ Preguntas formuladas /_||
|_Resolución de casos_||
|**CRITERIOS DE EVALUACIÓN**||
|•<br>Identificación de amenazas y riesgos||
|•<br>Diseño de mecanismos de seguridad||



- Implementación práctica 

- Diagramas y documentación técnica 

- Análisis crítico y conclusiones 

**UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA** ~~mm~~ **Formato:** Guía de Práctica de Laboratorio / Talleres / Centros de Simulación ~~pT~~ **Aprobación: 2022/03/01 Código: GUIA-PRLD-001 Página:** 6 ~~ee~~ • Presentación y formato del informe 

**UNIVERSIDAD NACIONAL DE SAN AGUSTIN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA** 

**Formato:** Guía de Práctica de Laboratorio / Talleres / Centros de Simulación 

**Página:** 7 

~~a~~ **Aprobación: 2022/03/01 Código: GUIA-PRLD-001**
