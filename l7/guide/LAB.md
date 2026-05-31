```
FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS
ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA
Formato: Guía de Práctica de Laboratorio / Talleres / Centros de Simulación
Aprobación: 2022/03/01 Código: GUIA-PRLD- 001 Página: 1
```
## (formato docente)

## INFORMACIÓN BÁSICA

## ASIGNATURA: SISTEMAS^ DISTRIBUIDOS^

## TÍTULO DE LA

## PRÁCTICA:

```
SOAP Web services
```
## NÚMERO DE

## PRÁCTICA: 07

## AÑO LECTIVO: 2026

## NRO.

## SEMESTRE:

### 2026 A

## TIPO DE

## PRÁCTICA:

## INDIVIDUAL^

## GRUPAL X MÁXIMO DE ESTUDIANTES 3

## FECHA INICIO: 25 / 05 /202 6 FECHA FIN: 29 / 05 /202 6 DURACIÓN: 2 horas

## RECURSOS A UTILIZAR:

## VSCode, Netbeans, Eclipse.

## Apache NetBeans IDE, Java JDK 17+, Apache Tomcat, Python, Postman, SOAP UI Open Source

## Librerías: JAX-WS, Zeep (Python SOAP Client)

## DOCENTE(s):

- Mg. Maribel Molina Barriga

## OBJETIVOS/TEMAS Y COMPETENCIAS

## OBJETIVOS:

- Identificar el SOAP Web Services
- Realizar aplicaciones con SOAP Web Services

## TEMAS:

- El SOAP Web Services
- Aplicar SOAP Web Services con Java

## COMPETENCIA C.e.^ Identifica^ de^ forma^ reflexiva^ y^ responsable,^ necesidades^ a^ ser^ resueltas^ usando^

```
tecnologías de información y/o desarrollo de software en los ámbitos local, nacional o
internacional, utilizando técnicas, herramientas, metodologías, estándares y principios de la
ingeniería
```
## CONTENIDO DE LA GUÍA

## I. MARCO CONCEPTUAL

### SOAP

Abreviación de Simple Object Access Protocol , es un protocolo de mensajería construido en XML que se usa para
codificar información de los requerimientos de los Web Services y para responder los mensajes “antes de
enviarlos por la red”.
SOAP es un protocolo estándar basado en XML para intercambiar información estructurada entre aplicaciones
distribuidas. Los mensajes SOAP son independientes de los sistemas operativos y pueden ser transportados por
los protocolos que funcionan en la Internet, como ser: SMTP, MIME y HTTP.

# GUÍA DE LABORATORIO


**FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS
ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA
Formato:** Guía de Práctica de Laboratorio / Talleres / Centros de Simulación
**Aprobación: 2022/03/01 Código: GUIA-PRLD- 001 Página:** 1
^
Características:

- Basado en XML
- Independiente de plataforma
- Comunicación vía HTTP, SMTP, TCP
- Altamente estructurado
- Usa WSDL para describir servicios

```
Componentes principales:
```
1. Envelope: Define inicio y fin del mensaje.
2. Header: Metadatos opcionales.
3. Body: Datos enviados.
4. Fault: Errores del servicio.

```
SOA y SOAP suelen ser términos que, a menudo, suelen generar bastante confusión (supongo que por la
semejanza de sus siglas). Parece que muchas veces no tenemos del todo claro dónde empieza y acaba cada cosa
aunque, en el fondo, sabemos que existe relación entre ambos términos. Incluso es común encontrar por ahí
algunos artículos donde se refieren a SOA cuando realmente quieren decir SOAP.
Con el desarrollo de servicios web basados en REST también puede ocurrir algo parecido.
Los "Web services" son aplicaciones distribuidas que se basan en una serie de protocolos y estándares para
intercambiar información.
También se definen como distintas aplicaciones de software desarrolladas en lenguajes de
programación diferente y ejecutada sobre cualquier plataforma puede utilizar los Web Services para interactuar
datos en redes de computadoras.
Los Cliente puede ser:
```
- Un aplicativo móvil(Androi, IOS)
- Un aplicativo de Escritorio
- Una aplicación web que esté en PHP
Los servicios SOAP o mejor conocimos simplemente como Web Services, son servicios que basan su comunicación
bajo el protocolo SOAP (Simple Object Access Protocol) el cual este definido por **_“protocolo estándar que define
cómo dos objetos en diferentes procesos pueden comunicarse por medio de intercambio de datos XML”_**. Por lo
tanto, queda claro que la comunicación se realiza mediante XML.

```
Los servicios SOAP funcionan por lo general por el protocolo HTTP que es lo más común cuando invocamos un
Web Services, sin embargo, SOAP no está limitado a este protocolo, si no que puede ser enviado por FTP, POP3,
TCP, Colas de mensajería (JMS, MQ, etc). Pero HTTP es el protocolo principal.
```
```
Característica SOAP REST
Formato XML JSON/XML
Contrato WSDL OpenAPI
Seguridad WS-Security HTTPS/OAuth
Rendimiento Menor Mayor
Formalidad empresarial Alta Media
```

```
FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS
ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA
Formato: Guía de Práctica de Laboratorio / Talleres / Centros de Simulación
Aprobación: 2022/03/01 Código: GUIA-PRLD- 001 Página: 1
```
(^)

## III. EJERCICIOS RESULETOS POR EL DOCENTE

## Programa Aplicativo: Servicio SOAP de Suma

## Paso 1: Crear Servicio SOAP (Java)

```
import javax.jws.WebMethod;
import javax.jws.WebService;
```
```
@WebService
public class CalculadoraSOAP {
```
```
@WebMethod
public int sumar(int a, int b){
return a+b;
}
}
```
## Paso 2: Publicar Servicio

```
import javax.xml.ws.Endpoint;
```
```
public class Publicador {
public static void main(String[] args){
Endpoint.publish(
"http://localhost:8080/calculadora",
new CalculadoraSOAP()
);
```
```
System.out.println("Servicio SOAP activo");
}
}
```
## Paso 3: Consumidor Java

```
import java.net.URL;
import javax.xml.namespace.QName;
import javax.xml.ws.Service;
```
```
public class ClienteSOAP {
public static void main(String[] args) throws Exception {
```
```
URL url = new URL(
"http://localhost:8080/calculadora?wsdl");
```
```
QName qname =
new QName(
"http://",
"CalculadoraSOAPService");
```
```
Service service =
Service.create(url,qname);
```
```
CalculadoraSOAP calc =
service.getPort(CalculadoraSOAP.class);
```
```
System.out.println(calc.sumar(10,20));
}
```
## }

## IV. EJERCICIOS/PROBLEMAS PROPUESTOS

## EJERCICIO 1

## Servicio SOAP: Conversor de Temperatura

## Desarrollar un servicio SOAP que convierta:


```
FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS
ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA
Formato: Guía de Práctica de Laboratorio / Talleres / Centros de Simulación
Aprobación: 2022/03/01 Código: GUIA-PRLD- 001 Página: 1
```
- Celsius → Fahrenheit
- Fahrenheit → Celsius

## Solución de referencia

```
@WebService
public class ConversorSOAP {
```
```
@WebMethod
public double cToF(double c){
return (c* 9 / 5 )+ 32 ;
}
```
```
@WebMethod
public double fToC(double f){
return (f- 32 )* 5 / 9 ;
}
}
```
## Consumidor:

```
System.out.println(calc.cToF( 30 ));
```
## Resultado:

```
86.
```
- Diseñe un servicio SOAP básico para las ventas de productos en línea.
- Investigue y analice una aplicación con SOAP services.

## EJERCICIO 2

## Cliente SOAP con Python

## Consumir un servicio SOAP existente usando Python.

## Instalar:

```
pip install zeep
```
## Código:

```
from zeep import Client
```
```
client = Client(
'http://www.dneonline.com/calculator.asmx?WSDL'
)
```
```
resultado = client.service.Add( 5 , 8 )
```
```
print(resultado)
```
## Resultado esperado: 13

## Actividad adicional (HTML + JS)

## Consumir SOAP desde navegador

```
<!DOCTYPE html>
<html>
<body>
```

```
FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS
ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA
Formato: Guía de Práctica de Laboratorio / Talleres / Centros de Simulación
Aprobación: 2022/03/01 Código: GUIA-PRLD- 001 Página: 1
```
```
<button onclick="consumir()">
Consultar
</button>
```
```
<script>
function consumir(){
```
```
fetch("http://localhost:8080/calculadora")
.then(r=>console.log(r));
```
```
}
</script>
```
```
</body>
</html>
```
## Analizar por qué SOAP presenta limitaciones en consumo directo desde navegador.

## IV. CUESTIONARIO

```
Resolver las siguientes preguntas:
```
1. ¿Puedo utilizar un componente JavaBeans para implementar un servicio web utilizando la invocación de
    SOAP sobre JMS (Java Message Service)?
2. ¿Cómo funciona la mensajería bidireccional con la implementación de SOAP y JMS? ¿Da soporte a varios
    clientes realizando solicitudes simultáneas?
3. ¿Por qué SOAP sigue siendo utilizado en sistemas empresariales críticos pese al auge de REST?
4. ¿Qué implicancias tiene el uso de XML en el rendimiento de sistemas distribuidos de alta concurrencia?
5. 3. ¿En qué escenarios arquitectónicos SOAP resulta más adecuado que REST? Justifique técnicamente.

## V. REFERENCIAS Y BIBLIOGRÁFIA RECOMENDADAS:

```
[1] Tanenbaum, A.S. (2008). Sistemas distribuidos: principios y paradigmas. México. Pearson Educación.
[2] Ceballos, F. J. (2006). Java 2, Curso de programación. México: Alfaomega, RaMa.
[3]Deitel, H. M., & Deitel, P. J. (2004). Cómo programar en Java. México: Pearson Educación.
[4] García Tomás, J., Ferrando, S., & Piattini, M. (2001). Redes para procesos distribuidos. México: Alfaomega
Ra-Ma.
[5] Orfali, R., & Harkey, D. (1998). Client/Server Programming with Java and CORBA. USA: Wiley
[6] WebSphere Application Server, Revisado:20/05/2022. Recuperado de: https://www.ibm.com/docs/es/was-
zos/8.5.5?topic=services-overview-online-garden-retailer-web-scenarios
[7] Notas de la versión de Sun Java System Web Server , Revisado: 07/05/2022. Recuperado de:
https://docs.oracle.com/cd/E19146-01/820-1828/geryf/index.html
[8] SOA vs. SOAP y REST. Revisado: 20/05/2022. Recuperado de:
https://www.adictosaltrabajo.com/2014/01/10/soavs-soap-rest/
```
```
Revisar también:
https://www.programacion.com.py/web/java-web/web-service-soap-con-java-ee
http://gcoronelc.blogspot.com/2017/08/web-service-soap-ejemplo-1.html
https://www.youtube.com/watch?v=2ToEge_xybI
```
## TÉCNICAS E INSTRUMENTOS DE EVALUACIÓN

## TÉCNICAS:

```
Problemas /Ejercicios propuestos
```
## INSTRUMENTOS:

```
Lista de cotejo
```

```
FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS
ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA
Formato: Guía de Práctica de Laboratorio / Talleres / Centros de Simulación
Aprobación: 2022/03/01 Código: GUIA-PRLD- 001 Página: 1
```
(^) _/ Preguntas formuladas / Resolución de casos_

## CRITERIOS DE EVALUACIÓN

- Identifica el proceso de SOAP Web Services
- Realiza aplicaciones con SOAP Web Services


**FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS
ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA
Formato:** Guía de Práctica de Laboratorio / Talleres / Centros de Simulación
**Aprobación: 2022/03/01 Código: GUIA-PRLD- 001 Página:** 1


