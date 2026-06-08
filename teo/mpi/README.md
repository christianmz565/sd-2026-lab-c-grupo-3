# MPI Analysis - Meteorological Data System

Este repositorio contiene un sistema distribuido para el análisis de datos meteorológicos utilizando MPI (Message Passing Interface) a través de la librería `mpi4py`. El proyecto está diseñado para demostrar cómo se puede realizar procesamiento en paralelo y distribuido en un entorno escalable.

## Descripción del Proyecto

El sistema procesa grandes volúmenes de datos meteorológicos (temperatura, humedad, velocidad del viento, etc.) recolectados de diversas estaciones. Utiliza un modelo Maestro Trabajador:

1.**Master:** Divide el conjunto de datos en fragmentos y los distribuye a los trabajadores.
2.**Workers:** Realizan cálculos estadísticos (promedios, máximos, mínimos, predicciones) sobre su fragmento de datos.
3.**Master:** Recolecta los resultados parciales, los agrega y genera un informe final.

---

## MPI sin un Cluster HPC

Tradicionalmente, MPI requiere un cluster de computación de alto rendimiento (HPC) con varios nodos físicos. En este repositorio, se simula un cluster HPC utilizando Docker:

* **Contenedores como Nodos:** Cada contenedor de Docker actúa como un nodo independiente dentro del cluster.
* **Red Virtual:** Los contenedores se comunican a través de una red interna de Docker.
* **Memoria Compartida:** Se utiliza un volumen que replica el funcionamiento de /dev/shm para compartir datos entre contenedores.
* **Orquestación con SSH:** `mpirun` utiliza SSH para lanzar procesos en nodos remotos.
* **Descubrimiento:** El script `run_mpi.sh` utiliza DNS dinámico para encontrar las IPs de todos los trabajadores activos.

---

## Instalación y Requisitos

### Requisitos Previos

Independientemente de tu sistema operativo, necesitas instalar:

1. **Docker:** [Descargar e instalar Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows/Mac) o Docker Engine (Linux).
2. **Docker Compose:** Generalmente incluido con Docker Desktop.

### Instalación de Herramientas

Si deseas trabajar en el desarrollo o ejecutar scripts locales:

* **uv:**
    ```bash
    # Linux
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Windows (PowerShell)
    irm https://astral.sh/uv/install.ps1 | iex
    ```
* **Dependencias de MPI:**
    ```bash
    # Linux
    sudo apt-get update && sudo apt-get install openmpi-bin libopenmpi-dev
    # Windows
    # Descarga e instala Microsoft MPI: https://www.microsoft.com/en-us/download/details.aspx?id=105289
    ```

---

## Instrucciones de Uso

### 1. Preparación de Datos
Genera un archivo de datos de prueba. 

```bash
python scripts/generate_data.py --rows 10000 --output data/input.csv
```

### 2. Levantar el Cluster
Inicia el entorno distribuido con Docker Compose. Esto creará un nodo maestro y varios nodos trabajadores.

```bash
docker compose up -d --scale worker=4
```

### 3. Ejecutar el Análisis Distribuido
Envía la tarea al nodo maestro para que inicie la ejecución distribuida.

```bash
# Ejecutar con 4 procesos (repartidos entre los contenedores disponibles)
docker compose exec master /app/scripts/run_mpi.sh 4
```

### 4. Ejecutar Comparación Secuencial
Para validar la mejora en el rendimiento, puedes ejecutar el análisis de forma secuencial:

```bash
docker compose exec master uv run scripts/run_sequential.py
```

### 5. Dashboard de Visualización
El sistema incluye un dashboard interactivo basado en Plotly Dash para visualizar los resultados y gestionar el pipeline. Este se encontrará en `http://localhost:8050` una vez que el contenedor maestro esté en funcionamiento.

---

## Benchmarking
El proyecto incluye soporte para `hyperfine` dentro del contenedor para realizar pruebas de rendimiento precisas.

```bash
docker compose exec master hyperfine --warmup 1 -r 3 \
  "uv run scripts/run_sequential.py" \
  "bash scripts/run_mpi.sh 4"
```
