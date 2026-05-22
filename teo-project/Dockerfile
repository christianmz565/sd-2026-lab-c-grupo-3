FROM python:3.12-slim

WORKDIR /app

RUN pip install --no-cache-dir uv

COPY pyproject.toml README.md /app/
RUN uv sync --no-dev --no-cache

COPY proto /app/proto
COPY grpc /app/grpc

CMD ["python", "mapreduce/app.py"]
