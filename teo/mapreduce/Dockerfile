FROM python:3.12-slim

WORKDIR /app

RUN pip install --no-cache-dir uv

COPY pyproject.toml README.md /app/
RUN uv sync --no-dev --no-cache

COPY proto /app/proto
COPY rpc /app/rpc
COPY mapreduce /app/mapreduce

ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

CMD ["python", "-m", "mapreduce.app"]
