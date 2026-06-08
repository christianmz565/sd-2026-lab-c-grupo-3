#!/usr/bin/env bash

echo "Setup..."
docker compose build
docker compose up -d --scale worker=4
sleep 5

echo "Generating data..."
docker compose exec master uv run scripts/generate_data.py --output /data/input.csv --rows 1000000

echo "Benchmark..."
docker compose exec master hyperfine --warmup 1 -r 3 \
  "uv run scripts/run_sequential.py" \
  "bash scripts/run_mpi.sh 4"

docker compose down
