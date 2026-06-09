# MapReduce

Este repositorio contiene un sistema distribuido para el conteo de frecuencia de palabras utilizando el modelo de programación MapReduce. El proyecto está diseñado para demostrar la coordinación de tareas distribuidas a través de gRPC y una arquitectura de Maestro-Trabajador.

## Descripción del Proyecto

El sistema procesa grandes volúmenes de texto para calcular la frecuencia de cada palabra. Utiliza un modelo Maestro-Trabajador:

1.  **Master (Maestro):**
    *   Actúa como servidor HTTP para recibir peticiones de clientes (CLI o Navegador).
    *   Divide el texto de entrada en fragmentos (chunks).
    *   Distribuye los fragmentos a los trabajadores disponibles.
    *   Recolecta los resultados parciales y realiza la fase de **Reduce** para consolidar el conteo final.
    *   Sirve una interfaz web interactiva.
2.  **Worker (Trabajador):**
    *   Expone un servicio gRPC para recibir tareas de mapeo.
    *   Realiza la fase de **Map**, contando las palabras en el fragmento de texto recibido.
    *   Se registra automáticamente con el Maestro al iniciar.

---

## Implementación con Docker y gRPC

Se simula un entorno distribuido utilizando contenedores:

*   **Contenedores como Nodos:** Cada trabajador se ejecuta en su propio contenedor Docker, simulando nodos independientes.
*   **gRPC para Computación:** Se utiliza gRPC para la comunicación de alto rendimiento entre el maestro y los trabajadores durante la fase de procesamiento.
*   **Registro Dinámico:** Los trabajadores notifican su presencia al maestro vía HTTP al iniciar, permitiendo escalar el número de trabajadores dinámicamente.
*   **Interfaz Web:** El maestro incluye un dashboard en HTML/JS para realizar análisis de forma visual.

---

## Instalación y Requisitos

### Requisitos Previos

1.  **Docker:** [Descargar e instalar Docker Desktop](https://www.docker.com/products/docker-desktop/).
2.  **Docker Compose:** Generalmente incluido con Docker.

### Instalación Local (Opcional para Desarrollo)

Si deseas ejecutar el cliente CLI o realizar cambios:

*   **uv:**
    ```bash
    curl -LsSf https://astral.sh/uv/install.sh | sh
    ```
*   **Dependencias:**
    ```bash
    cd mapreduce
    uv sync
    ```

---

## Instrucciones de Uso

### 1. Levantar el Cluster
Inicia el sistema distribuido con Docker Compose. Puedes escalar el número de trabajadores según necesites.

```bash
# Levantar el maestro y 3 trabajadores
docker compose up -d --scale worker=3
```

### 2. Utilizar la herramienta
Se pueden usar tanto la interfaz gráfica como la línea de comandos para interactuar con el sistema.

### 2.1. Interfaz Gráfica (GUI)

El sistema incluye una interfaz web moderna accesible en `http://localhost:9000`.

**Características de la GUI:**
*   **Modos de Entrada:** Permite pegar texto directamente o subir archivos `.txt`.
*   **Visualización en Tiempo Real:** Muestra el progreso del análisis a través de una barra de estado.
*   **Ranking Interactivo:** Presenta los resultados en una tabla ordenada con búsqueda y filtrado dinámico.
*   **Métricas:** Reporta el total de palabras procesadas, palabras únicas y tiempo de ejecución.

Para abrirla rápidamente:
```bash
python cli.py --open-ui
```

### 2.1. Herramienta de Línea de Comandos (CLI)

El script `cli.py` permite interactuar con el cluster sin salir de la terminal.

**Opciones principales:**
*   `-t, --text`: Analiza un fragmento de texto pasado como argumento.
*   `-f, --file`: Lee y analiza un archivo de texto local.
*   `-u, --url`: Especifica la URL del servidor maestro (por defecto `localhost:9000`).
*   `-o, --open-ui`: Abre la interfaz web en el navegador predeterminado.

Por ejemplo, para analizar un archivo:
```bash
python cli.py --file path/to/textfile.txt
```
