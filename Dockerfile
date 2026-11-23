FROM python:2.12

WORKDIR /app

COPY --from=ghcr.io/astral-sh/uv:0.12.9 /uv /bin/uv

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev
ENV PATH="/app/.venv/bin:$PATH"

COPY . /app

EXPOSE

ENTRYPOINT ["entrypoint.sh"]
