# Testing Documentation

This project has various quality assurance mechanisms setup which are described in this document.

## Linter Setup

We use [Ruff](https://docs.astral.sh/ruff/) for linting, import sorting and formatting. It replaces flake8, isort and black.
The configuration lives in the `[tool.ruff]` section of `pyproject.toml`.

### Linter (code style and import order)

Run `uv run ruff check .` to run the style checks (rules `E`, `W`, `F` and `I` for import order).
Use `uv run ruff check --fix .` to apply auto-fixable fixes.

### Formatter

Run `uv run ruff format --check .` to run the formatter in a check-only mode (which is used in CI).
Run `uv run ruff format .` to apply the formatting.

## CI Pipeline

This repository contains ci workflows in the `.github/workflows` directory for:

- [testing](../.github/workflows/test.yaml) which executes
  - a linting job
  - the django tests