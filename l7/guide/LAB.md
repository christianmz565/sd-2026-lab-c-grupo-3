Aquí tienes la transcripción de tu laboratorio basada en los documentos proporcionados, siguiendo el formato solicitado y describiendo los elementos visuales presentes.

## RECURSOS A UTILIZAR:

**Entorno de desarrollo:** NetBeans (recomendado para servidores), Eclipse (recomendado para clientes), GlassFish Server, Java Development Kit (JDK 7 o superior).
**Lenguajes de Programación:** Java (JAX-WS para servicios SOAP).
**Herramientas adicionales:** SoapUI (para pruebas y simulación de servicios).

## DOCENTE(s):

- **Mg. Maribel Molina Barriga**.

## OBJETIVOS/TEMAS Y COMPETENCIAS

## OBJETIVOS:

- **Desarrollar y desplegar servicios web basados en el protocolo SOAP** utilizando entornos integrados como NetBeans y Eclipse.
- **Configurar y gestionar servidores de aplicaciones** (GlassFish) para la exposición de servicios distribuidos.
- **Generar y analizar contratos WSDL** para facilitar el consumo de servicios por parte de clientes externos.
- **Implementar operaciones CRUD** (Create, Read, Update, Delete) en un entorno de servicios web distribuidos.
- **Utilizar herramientas de terceros como SoapUI** para la validación y pruebas de endpoints SOAP.

## TEMAS:

- **Servicios Web SOAP (Simple Object Access Protocol)**.
- **WSDL (Web Services Description Language)**.
- **JAX-WS y anotaciones de Java para Web Services**.
- **Consumo de servicios mediante proxies y clientes Java**.

---

## I. SOLUCIÓN DE EJERCICIOS/PROBLEMAS RESUELTOS

### Consideraciones Iniciales:
Se emplean dos editores: **NetBeans** es ideal para levantar servidores por su facilidad con GlassFish y JDK 7, mientras que **Eclipse** se utiliza para la creación de clientes.

### 1. Creación del Servidor en NetBeans
Lo primero es crear una **Web Application** en NetBeans.

> **Descripción de Imagen:** Se observa la interfaz de NetBeans IDE 13 con el diálogo "New Web Application". El proyecto se denomina "WebApplication5" y se muestra la estructura de carpetas local del usuario.

### 2. Clase Modelo: User.java
Se crea la clase `User` que servirá como modelo para el servidor web.

> **Descripción de Imagen:** Captura del código fuente de `User.java`. Incluye una lista estática de usuarios predefinidos ("Rosa Marfil", "Pepito Grillo", "Manuela Río") y atributos de tipo String para `name` y `username`, con sus respectivos constructores.

### 3. Interfaz SOAPI.java
Esta interfaz define los métodos que el servidor expondrá.

> **Descripción de Imagen:** Código de la interfaz `SOAPI` anotada con `@WebService`. Define los métodos `@WebMethod public List<User> getUsers()` y `@WebMethod public void addUser(User user)`.

### 4. Implementación: Clase SOAPImpl.java
Esta clase contiene la lógica de las operaciones que consumirán los clientes.

> **Descripción de Imagen (Diálogo):** Ventana "New Web Service" donde se nombra al servicio y se selecciona la opción "Create Web Service from Scratch".
> **Descripción de Imagen (Código):** La clase `SOAPImpl` implementa `SOAPI` y utiliza la anotación `@WebService(endpointInterface = "es.rosamarfil.soap.SOAPI")`. Los métodos sobrescritos llaman a la lógica de la clase `User` para retornar o añadir elementos a la lista.

### 5. Despliegue en GlassFish
Se debe arrancar el servidor desde la pestaña **Services → Servers → GlassFish**. Posteriormente, se usa la opción **"Generate SOAP-over-HTTP wrapper"** para crear el punto de acceso WSDL.

> **Descripción de Imagen:** Consola de salida de GlassFish indicando que el Web Service ha sido desplegado exitosamente en una dirección URL específica (ej. `http://localhost:8080/WebServerSoap/SOAPImplService`).

### 6. Archivo WSDL
El WSDL contiene la información técnica para que el cliente consuma el servicio.

> **Descripción de Imagen:** Vista de un navegador mostrando el código XML del WSDL. Se aprecian las etiquetas `<types>`, `<message>`, `<portType>` y `<operation>`, detallando los métodos `addUser` y `getUsers`.

### 7. Creación del Cliente en Eclipse
En Eclipse, se crea un nuevo **Java Project** y se enlaza mediante un **Web Service Client**.

> **Descripción de Imagen:** Asistente de Eclipse para crear un proyecto Java ("ClientSOAP") y el diálogo "Web Services" donde se solicita la URL del WSDL (ej. `http://localhost:8080/.../SOAPImplService?wsdl`).

### 8. Clase UserClient.java (Main)
Se implementa una clase principal para consumir las operaciones del servicio.

> **Descripción de Imagen:** Código Java de `UserClient`. Utiliza `SOAPImplServiceLocator` para obtener el puerto del servicio, llama a `getUsers()` para mostrar la lista inicial, añade un nuevo usuario ("Pablo Ruiz") y vuelve a imprimir la lista para verificar el cambio.

---

## II. EJERCICIOS/PROBLEMAS PROPUESTOS

### A. Diseño de un Servicio SOAP para Ventas en Línea
Se desarrolló un servicio que implementa operaciones CRUD básicas:
- **CREATE:** Agregar nuevos productos al stock.
- **READ:** Obtener la lista de productos con cantidad y costo.
- **UPDATE:** Actualizar precio y cantidad de un producto específico.
- **DELETE:** Implementado como una eliminación lógica (reducir stock a 0).

#### Componentes del Sistema de Ventas:
1.  **Item.java:** Representa el producto. Contiene atributos como nombre, cantidad y costo.
2.  **SOAPI.java (Interfaz):** Define métodos como `getItems()`, `buyItem()`, `addItem()` y `setItem()`.
3.  **PublishService.java:** Clase encargada de publicar el endpoint en una URL local (ej. `http://localhost:1516/WS/Users`).

> **Descripción de Tabla de Resultados (Simulada desde capturas de consola):**
> 
> | Producto | Cantidad | Precio |
> | :--- | :--- | :--- |
> | Gaseosa | 15 | 5.2 |
> | Galletas | 10 | 1.6 |
> | Celular | 12 | 900.0 |
> 
> *Nota: Tras una operación de "Update", el stock de Galletas se muestra actualizado a 18 unidades con precio 2.4.*

### B. Investigación: Aplicación SoapUI
**SoapUI** es una herramienta para probar, simular y generar código de servicios web de forma ágil partiendo del WSDL.

#### Pasos para probar un servicio en SoapUI:
1.  **Nuevo Proyecto:** Se asigna un nombre y la URL del descriptor WSDL (ej. el servicio de clima "Global Weather").
2.  **Generación de Requests:** SoapUI crea automáticamente un esqueleto XML para cada operación (`GetCitiesByCountry`, `GetWeather`).
3.  **Análisis de Interfaces:** La herramienta separa las interfaces según la versión de SOAP utilizada (SOAP 1.1 o SOAP 1.2).

---

## CONCLUSIÓN
El desarrollo de servicios SOAP en Java es **directo y amigable**, permitiendo el despliegue local rápido. La separación modular de clases (Modelo, Interfaz e Implementación) facilita el mantenimiento y el consumo distribuido de los servicios.
