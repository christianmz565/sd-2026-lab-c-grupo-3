# Entorno gRPC (uv)

## Setup

```bash
uv sync
```

## Generar stubs

Desde la raiz del proyecto:

```bash
uv run python -m grpc_tools.protoc -I proto \
  --python_out=grpc/generated \
  --grpc_python_out=grpc/generated \
  proto/wordcount.proto
```
