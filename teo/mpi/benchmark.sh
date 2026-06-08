#!/bin/bash

# Build and start the cluster
echo "Building and starting Docker cluster..."
docker compose build
docker compose up -d --scale worker=3

# Wait for containers to be ready
echo "Waiting for containers to start..."
sleep 5

# Generate large dataset
echo "Generating data..."
docker compose exec master uv run scripts/generate_data.py --output /data/input.csv --rows 50000

# Run performance evaluation with hyperfine
echo "Running performance evaluation..."
docker compose exec master hyperfine --warmup 1 -r 3 \
  "uv run scripts/run_sequential.py" \
  "bash scripts/run_mpi.sh 4"

# Show results
echo "Sequential Results:"
docker compose exec master cat /data/output/results_sequential.json | head -n 20
echo "..."
echo "MPI Results:"
docker compose exec master cat /data/output/results.json | head -n 20
echo "..."

# Stop cluster
# docker compose down
