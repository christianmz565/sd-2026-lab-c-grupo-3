#!/bin/bash

# Usage: ./run_mpi.sh <num_processes>
NP=$1
if [ -z "$NP" ]; then
  NP=4
fi

WORKER_IPS=$(dig +short worker)

HOSTS="localhost"
for IP in $WORKER_IPS; do
  if [ "$IP" != "" ]; then
    HOSTS="$HOSTS,$IP"
  fi
done

echo "Running MPI with $NP processes on hosts: $HOSTS"

mpirun --allow-run-as-root \
       -np $NP \
       --host $HOSTS \
       uv run src/mpi_analysis/distributed/entrypoint.py
