#import "/lib.typ": code-block, define, get-var, header-border-color, lab-report, lab-section, table-border-width
#import "/functions.typ": summarize-name
#import "@preview/elembic:1.1.1" as e

#show: e.set_(code-block, lang: "java")

#define("course_name", "Sistemas Distribuidos")
#define("lab_title", "SOAP Web services")
#define("lab_number", "07")
#define("instructor_name", "Mg. Maribel Molina Barriga")
#define("members", (
  "Bedregal Perez Daniel",
  "Jara Mamani Mariel Alisson",
  "Mestas Zegarra Christian Raul",
  "Noa Camino Yenaro Joel",
  "Sequeiros Condori Luis Gustavo",
))

#context {
  define("members_abbr_list", get-var("members").map(name => summarize-name(name)).join(" - "))
}

#lab-report()[
  #set image(width: 78%)
  #set list(indent: 2pt)
  #show raw.where(block: false): it => box(
    inset: (x: 0.5pt),
  )[#it]

  #lab-section("RESULTADOS Y PRUEBAS")[
    #show heading: set text(weight: "bold")
    #set par(justify: true)

    = ENLACE A GITHUB

    #link("https://github.com/christianmz565/sd-2026-lab-c-grupo-3/tree/main/l7")

    = EJERCICIOS RESUELTOS POR EL DOCENTE

    Se replico el servicio SOAP de suma para validar publicacion y consumo mediante JAX-WS.

    == Servicio SOAP de Suma (Calculadora)

    #code-block("l7/snippets/docente/calculadora/CalculadoraSOAP.java", snippet: "service", lang: "java")

    #code-block("l7/snippets/docente/calculadora/Publicador.java", snippet: "publish", lang: "java")

    #code-block("l7/snippets/docente/calculadora/ClienteSOAP.java", snippet: "client", lang: "java")

    = EJERCICIOS/PROBLEMAS PROPUESTOS

    == Ejercicio 1: Conversor de Temperatura

    Se implemento el servicio SOAP con las operaciones `cToF` y `fToC`, junto con el publicador y el cliente Java.

    #code-block("l7/snippets/e1/conversor/ConversorAPI.java", snippet: "interface", lang: "java")

    #code-block("l7/snippets/e1/conversor/ConversorSOAP.java", snippet: "impl", lang: "java")

    #code-block("l7/snippets/e1/conversor/PublishService.java", snippet: "publish", lang: "java")

    #code-block("l7/snippets/e1/conversor/ConversorClient.java", snippet: "client", lang: "java")

    === Ejecucion del servicio

    ```bash
    cd l7/src/e1
    javac -d . $(find conversor -name "*.java")
    java -cp . lab7.e1.conversor.PublishService
    ```

    === Verificacion del WSDL

    ```text
    Ruta: http://localhost:8080/conversor?wsdl
    Resultado: se genero el contrato WSDL con operaciones cToF y fToC.
    ```

    ```xml
    <definitions name="ConversorSOAPService">
      <portType name="ConversorAPI">
        <operation name="cToF" />
        <operation name="fToC" />
      </portType>
      <service name="ConversorSOAPService">
        <port name="ConversorSOAPPort" />
      </service>
    </definitions>
    ```

    === Pruebas del endpoint (curl)

    ```text
    Ruta: http://localhost:8080/conversor
    Metodo: POST (SOAP 1.1)
    Operacion: cToF
    Entrada: 30
    Resultado: 86.0
    ```

    ```xml
    <S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
      <S:Body>
        <ns2:cToFResponse xmlns:ns2="http://lab7.e1.conversor/">
          <return>86.0</return>
        </ns2:cToFResponse>
      </S:Body>
    </S:Envelope>
    ```

    ```text
    Ruta: http://localhost:8080/conversor
    Metodo: POST (SOAP 1.1)
    Operacion: fToC
    Entrada: 86
    Resultado: 30.0
    ```

    ```xml
    <S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
      <S:Body>
        <ns2:fToCResponse xmlns:ns2="http://lab7.e1.conversor/">
          <return>30.0</return>
        </ns2:fToCResponse>
      </S:Body>
    </S:Envelope>
    ```

    == Ejercicio 1 (Adicional): Servicio SOAP de Ventas en Linea

    Se diseno un servicio basico de ventas con listado, compra, registro, actualizacion y eliminacion logica de productos.

    #code-block("l7/snippets/e1/store/model/Item.java", snippet: "model", lang: "java")

    #code-block("l7/snippets/e1/store/soap/SOAPI.java", snippet: "interface", lang: "java")

    #code-block("l7/snippets/e1/store/soap/SOAPImpl.java", snippet: "impl", lang: "java")

    #code-block("l7/snippets/e1/store/demo/PublishService.java", snippet: "publish", lang: "java")

    #code-block("l7/snippets/e1/store/client/StoreClient.java", snippet: "client", lang: "java")

    == Ejercicio 2: Cliente SOAP con Python

    Se implemento un cliente interactivo con `zeep` para consumir el servicio SOAP de ventas en linea.

    #code-block("l7/snippets/e2/client.py", lang: "python")
  ]

  #lab-section("INVESTIGACION")[
    #set par(justify: true)

    == Aplicacion con SOAP Services

    Se analizo el servicio publico "Calculator" de DNE Online. El WSDL define operaciones `Add`, `Subtract`,
    `Multiply` y `Divide` con tipos `xsd:int`, y expone bindings SOAP 1.1 y 1.2. Este contrato permite consumir
    el servicio desde herramientas como SoapUI, clientes JAX-WS y librerias como `zeep`.

    Aspectos observados:
    - Contrato formal con `wsdl:service`, `wsdl:port` y `wsdl:binding`.
    - Mensajes SOAP con estructura XML fija y `soapAction` por operacion.
    - Facil integracion para clientes multiplataforma mientras se respete el WSDL.
  ]

  #lab-section("CUESTIONARIO")[
    #set par(justify: true)

    1. *JavaBeans y SOAP sobre JMS:* Si, un JavaBean puede formar parte de la implementacion, pero requiere
    un stack que soporte SOAP sobre JMS y configuracion de colas, bindings y metadatos.
    2. *Mensajeria bidireccional:* Se usa un canal de solicitud y una cola de respuesta (o `JMSReplyTo`) con
    `correlationId` para mapear respuestas. Soporta multiples clientes segun la capacidad del broker y la
    configuracion de consumidores concurrentes.
    3. *Uso empresarial de SOAP:* Se mantiene por contratos WSDL, herramientas maduras y estandares WS- para
    seguridad, transacciones y confiabilidad, claves en entornos regulados.
    4. *Impacto de XML:* Incrementa el tamano de mensajes y el costo de parseo, elevando latencia y consumo de
    CPU/memoria en alta concurrencia. Se mitiga con compresion o streaming.
    5. *Escenarios donde SOAP es mejor:* Integracion B2B, procesos con contratos estrictos, auditoria y
    requerimientos WS-Security/WS-ReliableMessaging, donde REST no cubre dichas garantias.
  ]

  #lab-section("CONCLUSION")[
    #show heading: set text(weight: "bold")
    #set par(justify: true)

    Se implementaron servicios SOAP con JAX-WS y clientes en Java y Python, validando el flujo completo
    publicacion-consumo. El uso de WSDL y contratos formales facilita la integracion, aunque el consumo desde
    navegador presenta limitaciones practicas por CORS y ausencia de soporte nativo.
  ]

  #lab-section("REFERENCIAS Y BIBLIOGRAFIA")[
    [1] Tanenbaum, A. S. (2008). Sistemas distribuidos: principios y paradigmas. Mexico. Pearson Educacion.

    [2] Ceballos, F. J. (2006). Java 2, Curso de programacion. Mexico: Alfaomega, Ra-Ma.

    [3] Deitel, H. M., & Deitel, P. J. (2004). Como programar en Java. Mexico: Pearson Educacion.

    [4] DNE Online Calculator WSDL. https://www.dneonline.com/calculator.asmx?WSDL

    [5] Zeep Documentation. https://docs.python-zeep.org/
  ]

  #lab-section("ANEXOS")[
    #set par(justify: true)

    == Servicio SOAP de Suma (Docente)

    === Servicio
    #code-block("l7/snippets/docente/calculadora/CalculadoraSOAP.java", lang: "java")

    === Publicacion
    #code-block("l7/snippets/docente/calculadora/Publicador.java", lang: "java")

    === Cliente
    #code-block("l7/snippets/docente/calculadora/ClienteSOAP.java", lang: "java")

    == Ejercicio 1: Conversor de Temperatura

    === Interfaz
    #code-block("l7/snippets/e1/conversor/ConversorAPI.java", lang: "java")

    === Implementacion
    #code-block("l7/snippets/e1/conversor/ConversorSOAP.java", lang: "java")

    === Publicacion
    #code-block("l7/snippets/e1/conversor/PublishService.java", lang: "java")

    === Cliente
    #code-block("l7/snippets/e1/conversor/ConversorClient.java", lang: "java")

    == Ejercicio 1: Ventas en Linea

    === Modelo Item
    #code-block("l7/snippets/e1/store/model/Item.java", lang: "java")

    === Interfaz del Servicio
    #code-block("l7/snippets/e1/store/soap/SOAPI.java", lang: "java")

    === Implementacion del Servicio
    #code-block("l7/snippets/e1/store/soap/SOAPImpl.java", lang: "java")

    === Publicacion del Servicio
    #code-block("l7/snippets/e1/store/demo/PublishService.java", lang: "java")

    === Cliente de Pruebas
    #code-block("l7/snippets/e1/store/client/StoreClient.java", lang: "java")

    == Ejercicio 2: Cliente SOAP con Python

    === Script
    #code-block("l7/snippets/e2/client.py", lang: "python")

  ]
]
