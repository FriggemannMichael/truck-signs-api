FROM python:3.12-slim

ARG APP_PORT=8020

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_PORT=${APP_PORT}

# netcat is needed by entrypoint.sh to wait for the database
RUN apt-get update \
    && apt-get install -y --no-install-recommends netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:0.12.9 /uv /bin/uv

WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev
ENV PATH="/app/.venv/bin:${PATH}"

COPY . /app
RUN chmod +x /app/entrypoint.sh

WORKDIR /app/src

EXPOSE ${APP_PORT}

ENTRYPOINT ["/app/entrypoint.sh"]
