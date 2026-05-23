# Grupo 2 - MapReduce

## Objetivo
Contador distribuido de frecuencia de palabras.

## Despliegue distribuido
Se ejecuta en contenedores dentro de Kubernetes. El rol se define con la variable
de entorno `MAPREDUCE_ROLE`:

- `master`: nodo coordinador.
- `worker`: nodo trabajador (por defecto).

## Fases

### MAP
Divide el texto y cuenta palabras.

### REDUCE
Consolida resultados parciales.

## Salida esperada
Ranking final de palabras frecuentes.
