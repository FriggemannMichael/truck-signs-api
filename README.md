<div align="center">

# Signs for Trucks

![Python version](https://img.shields.io/badge/Python-3.12-4c566a?logo=python&&longCache=true&logoColor=white&colorB=pink&style=flat-square&colorA=4c566a) ![Django version](https://img.shields.io/badge/Django-6.1.3-4c566a?logo=django&&longCache=truelogoColor=white&colorB=pink&style=flat-square&colorA=4c566a) ![Django-RestFramework](https://img.shields.io/badge/Django_Rest_Framework-3.18.2-red.svg?longCache=true&style=flat-square&logo=django&logoColor=white&colorA=4c566a&colorB=pink)

![Truck Signs](./src/screenshots/Truck_Signs_logo.png)

__Signs for Trucks__ is an online store to buy pre-designed vinyls with custom lines of letters (often call truck letterings).
The store also allows clients to upload their own designs and to customize them on the website as well.

</div>

## About this Repository

This repository contains the backend of **Signs for Trucks**: a Django REST API (Django 6.1, Django REST Framework) that serves the online store for pre-designed truck vinyls. It uses PostgreSQL as its database and gunicorn as the application server, and listens on port `8020`.

The project is packaged as a Docker image. With Docker Compose, the API and its database start together with one command. It was prepared as the *Truck Signs API v2* course project.

The most important parts of the repository:

- `src/`: the Django project (`tsa_app`) and the products app (`tsa_products`)
- `Dockerfile`: builds the application image
- `docker-compose.yml`: runs the API and the PostgreSQL database
- `entrypoint.sh`: waits for the database, runs migrations, creates the superuser and starts gunicorn
- `example.env`: template for the required environment variables

## Table of Contents

- [Signs for Trucks](#signs-for-trucks)
  - [About this Repository](#about-this-repository)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Quickstart](#quickstart)
    - [How to build the image](#how-to-build-the-image)
  - [Usage](#usage)
    - [Settings](#settings)
    - [Configuration](#configuration)
    - [Build the image](#build-the-image)
    - [Run with Docker Compose](#run-with-docker-compose)
    - [Run with docker run](#run-with-docker-run)
    - [Superuser](#superuser)
    - [Adapt the setup](#adapt-the-setup)
    - [Models](#models)
    - [Brief Explanation of the Views](#brief-explanation-of-the-views)
    - [Local development with uv](#local-development-with-uv)
  - [Repository Files](#repository-files)
  - [Screenshots of the Django Backend Admin Panel](#screenshots-of-the-django-backend-admin-panel)
    - [Mobile View](#mobile-view)
    - [Desktop View](#desktop-view)
  - [Additional Information](#additional-information)
    - [Postgresql Database](#postgresql-database)
    - [Docker](#docker)
    - [Django and DRF](#django-and-drf)
    - [Miscellaneous](#miscellaneous)

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) with Docker Compose
- [Git](https://git-scm.com/install/)

For local development without Docker you also need [uv](https://docs.astral.sh/uv/getting-started/installation/) and Python 3.12 or newer (see [Local development with uv](#local-development-with-uv)).

## Quickstart

1. Clone the repository:
   ```bash
   git clone https://github.com/FriggemannMichael/truck-signs-api.git
   cd truck-signs-api
   ```
2. Create your `.env` file from the template and fill in the required values (see [Configuration](#configuration)):
   ```bash
   cp example.env .env
   ```
3. Build the image and start the API together with the database:
   ```bash
   docker compose up -d --build
   ```
4. Open the admin login at [http://localhost:8020/admin/](http://localhost:8020/admin/).

Stop the stack with `docker compose down`. Your data is kept in Docker volumes; `docker compose down -v` deletes it.

### How to build the image

```bash
docker build -t truck-signs-api:latest .
```

More options are described in [Usage](#usage).

## Usage

### Settings

The `settings.py` folder inside the `src/tsa_app` folder contains the different settings configuration for the application.

The `example.env` file in the project root contains an overview about configuration values that can be set for the app.

### Configuration

All configuration is read from environment variables. Docker Compose loads them from a `.env` file in the project root. Create it from the template and keep it out of version control to avoid leaking secrets:

```bash
cp example.env .env
```

| Variable | Required | Description |
|---|---|---|
| `SECRET_KEY` | in production | Django secret key. In production mode the app refuses to start without it. |
| `DB_NAME` | in production | Name of the PostgreSQL database. Compose also uses it to create the database. |
| `DB_USER` | in production | PostgreSQL user. Compose also uses it to create the user. |
| `DB_PASSWORD` | in production | Password of the PostgreSQL user. Compose also uses it for the database container. |
| `ALLOWED_HOSTS` | recommended | Comma-separated list of host names or IPs the API is reached under. Default: `localhost,127.0.0.1`. |
| `DJANGO_SUPERUSER_USERNAME` | optional | Username of the superuser that is created at startup. |
| `DJANGO_SUPERUSER_EMAIL` | optional | Email of that superuser. |
| `DJANGO_SUPERUSER_PASSWORD` | optional | Password of that superuser. |
| `DB_HOST` | no | Database host. Default: `localhost`. Compose sets it to `db`. |
| `DB_PORT` | no | Database port. Default: `5432`. |
| `MODE` | no | `prod` (PostgreSQL) or `dev` (SQLite). Compose sets `prod`. |
| `DEBUG_ENABLED` | no | `True` or `False`. Compose sets `False`. |
| `CORS_ALLOWED_ORIGINS` | no | Comma-separated list of allowed origins. Default: `http://localhost:3000`. |
| `CLOUD_NAME`, `CLOUD_API_KEY`, `CLOUD_API_SECRET` | no | Cloudinary credentials. Media files are stored in Cloudinary when `CLOUD_NAME` is set. |
| `EMAIL_HOST_USER`, `EMAIL_HOST_PASSWORD` | no | SMTP credentials for order emails. |
| `LOG_LEVEL` | no | Log level in production mode. Default: `ERROR`. |

The `DJANGO_SUPERUSER_*` variables only work together: the superuser is created only if all three are set.

**Database switch via MODE**
- `MODE=prod` -> PostgreSQL, using `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT`. There are no default values for name, user and password, so the app stops with an error if they are missing.
- `MODE=dev` -> SQLite at `src/db.sqlite3`; no database variables and no `SECRET_KEY` needed (a random key is generated per start).
- `MODE` unset -> treated as `prod`.

Values set in the `environment` section of `docker-compose.yml` (`MODE`, `DEBUG_ENABLED`, `DB_HOST`, `DB_PORT`) take precedence over the `.env` file.

### Build the image

```bash
docker build -t truck-signs-api:latest .
```

The image is based on `python:3.12-slim`. Dependencies are installed with [uv](https://docs.astral.sh/uv/) from `pyproject.toml` and `uv.lock`. Use another name or tag by changing the `-t` value, for example `-t truck-signs-api:1.0.0`. If you do, adjust the `image` entry in `docker-compose.yml` too.

### Run with Docker Compose

Compose starts two services on one network: `db` (PostgreSQL, not published to the host) and `backend` (the API on port `8020`). The backend waits until the database is healthy. Both services restart automatically unless you stop them.

```bash
docker compose up -d --build   # build and start
docker compose logs -f backend # follow the application logs
docker compose down            # stop, data is kept
docker compose down -v         # stop and delete all data
```

Database files, static files and media files live in named Docker volumes, so they survive restarts and `docker compose down`.

### Run with docker run

The container needs a reachable PostgreSQL server. Replace every placeholder in angle brackets with your own value and never commit real secrets:

```bash
docker run -d \
  --name tsa_backend \
  --restart unless-stopped \
  -p 8020:8020 \
  -e MODE=prod \
  -e SECRET_KEY=<SECRET_KEY> \
  -e ALLOWED_HOSTS=<ALLOWED_HOSTS> \
  -e DB_NAME=<DB_NAME> \
  -e DB_USER=<DB_USER> \
  -e DB_PASSWORD=<DB_PASSWORD> \
  -e DB_HOST=<DB_HOST> \
  -e DB_PORT=5432 \
  -v tsa_static:/app/src/staticfiles \
  -v tsa_media:/app/src/media \
  truck-signs-api:latest
```

Instead of single `-e` options you can pass your `.env` file with `--env-file .env`. In PowerShell, write the command in one line or use a backtick at the end of each line instead of `\`.

The container waits for the database, runs the migrations, creates the superuser (if configured) and starts gunicorn on port `8020`.

### Superuser

If `DJANGO_SUPERUSER_USERNAME`, `DJANGO_SUPERUSER_EMAIL` and `DJANGO_SUPERUSER_PASSWORD` are set, the entrypoint creates the superuser on startup. If the user already exists, this step is skipped, so restarts are safe. To create a superuser by hand instead:

```bash
docker compose exec backend python manage.py createsuperuser
```

### Adapt the setup

- **Different port:** change the left side of `'8020:8020'` in `docker-compose.yml` to publish another host port. To change the port inside the container, also change `--bind` in `entrypoint.sh` and `EXPOSE` in the `Dockerfile`.
- **Different database credentials:** change `DB_NAME`, `DB_USER` and `DB_PASSWORD` in `.env`. PostgreSQL only creates the user and database on the first start, so for an existing volume run `docker compose down -v` first (this deletes the data).
- **Different PostgreSQL version:** change the image tag of the `db` service. Major version upgrades need a data migration or a fresh volume.
- **Production access:** add the host name or IP under which the API is reached to `ALLOWED_HOSTS` in `.env`. Never put IP addresses into files that are committed.

### Models

Most of the models do what can be inferred from their name. The following dots are notes about some of the models to make clearer their propose:
- __Category Model:__ The category of the vinyls in the store. It contains the title of the category as well as the basic properties shared among products that belong to a same category. For example, _Truck Logo_ is a category for all vinyls that has a logo of a truck plus some lines of letterings (note that the vinyls are instances of the model _Product_). Another category is _Fire Extinguisher_, that is for all vinyls that has a logo of a fire extinguisher.
- __Lettering Item Category:__ This is the category of the lettering, for example: _Company Name_, _VIM NUMBER_, ... Each has a different pricing.
- __Lettering Item Variations:__ This contains a foreign key to the __Lettering Item Category__ and the text added by the client.
- __Product Variation:__ This model has the original product as a foreign key, plus the lettering lines (instances of the __Lettering Item Variations__ model) added by the client.

### Brief Explanation of the Views

Most of the views are CBV imported from _rest_framework.generics_, and they allow the backend api to do the basic CRUD operations expected, and so they inherit from the _ListAPIView_, _CreateAPIView_, _RetrieveAPIView_, ..., and so on.

The behavior of some of the views had to be modified to address functionalities such as creation of order and payment, as in this case, for example, both functionalities are implemented in the same view, and so a _GenericAPIView_ was the view from which it inherits. Another example of this is the _UploadCustomerImage_ View that takes the vinyl template uploaded by the clients and creates a new product based on it.

### Local development with uv

This project uses [uv](https://docs.astral.sh/uv/) for dependency management instead of `pip` and a `requirements.txt`. The dependencies are declared in `pyproject.toml`, the exact versions are pinned in `uv.lock`. The Docker image installs the same locked versions with `uv sync --frozen --no-dev`. Code style, import order and formatting are checked with [Ruff](https://docs.astral.sh/ruff/), which replaces flake8, isort and black.

To run the app without Docker, in development mode with SQLite:

1. Install [uv](https://docs.astral.sh/uv/getting-started/installation/) and clone the repository:
    ```bash
    git clone https://github.com/FriggemannMichael/truck-signs-api.git
    cd truck-signs-api
    ```
1. Install the dependencies. This creates the virtual environment in `.venv`:
    ```bash
    uv sync
    ```
1. Create the `.env` file and switch to development mode. In this mode no database variables and no `SECRET_KEY` are needed:
    ```bash
    cp example.env .env
    ```
    Then set `MODE=dev` in the `.env` file (remove the `#` in front of the line).
1. Run the migrations:
    ```bash
    uv run python src/manage.py migrate
    ```
1. (Optional) Create a superuser:
    ```bash
    uv run python src/manage.py createsuperuser
    ```
1. Start the development server:
    ```bash
    uv run python src/manage.py runserver
    ```
    The app is now running on [localhost:8000](http://localhost:8000).

Useful commands for development:

```bash
uv add <package>                      # add a dependency and update uv.lock
uv sync                               # install the locked dependencies
uv run ruff check .                   # lint (includes import order)
uv run ruff format .                  # format the code
```

Run the tests from the `src` folder (with `MODE=dev` set in `.env`):

```bash
cd src
uv run python manage.py test
```

The code style rules are configured in the `[tool.ruff]` section of `pyproject.toml`. More details are in [docs/testing.md](docs/testing.md).

> [!NOTE]
> To create Truck vinyls with Truck logos in them, first create the __Category__ Truck Sign,
> and then the __Product__ (can have any name). This is to make sure the frontend retrieves
> the Truck vinyls for display in the Product Grid as it only fetches the products of the
> category Truck Sign.

---

## Repository Files

| File or folder | Purpose |
|---|---|
| `src/` | The Django project (`tsa_app`), the products app (`tsa_products`), templates and screenshots |
| `Dockerfile` | Builds the application image (Python 3.12, dependencies installed with uv) |
| `docker-compose.yml` | Runs the API and the PostgreSQL database with volumes, network and restart policies |
| `entrypoint.sh` | Container entrypoint: waits for the database, runs migrations, creates the superuser, starts gunicorn |
| `example.env` | Template for the `.env` file with all supported environment variables |
| `.dockerignore` | Keeps secrets (`.env`) and local files such as `.git` and `.venv` out of the image |
| `.gitignore` | Keeps local and generated files out of the repository |
| `pyproject.toml` | Project metadata, dependencies and the Ruff configuration |
| `uv.lock` | Locked dependency versions, used for reproducible builds |
| `Procfile` | Legacy process definition for Heroku-style platforms. It is not used by the Docker setup |
| `docs/` | Additional documentation, for example [testing](docs/testing.md) |
| `.github/workflows/` | CI: `test.yaml` runs Ruff and the Django tests, `build.yaml` builds and publishes the image on tags, `check-open-pr.yaml` checks that a pushed branch has an open pull request |

The `.env` file you create from `example.env` is not part of the repository.

## Screenshots of the Django Backend Admin Panel

### Mobile View

<div style="padding: 0 5rem; width: 100%;  display: flex; gap: 5rem; justify-content: center; flex-wrap: wrap;">

![alt text](./src/screenshots/Admin_Panel_View_Mobile.png)

![alt text](./src/screenshots/Admin_Panel_View_Mobile_2.png)

![alt text](./src/screenshots/Admin_Panel_View_Mobile_3.png)

</div>

### Desktop View


<div style="padding: 0 5rem; width: 100%; display: flex; flex-direction: column; gap: 2rem; align-items: center; justify-content: center;">

![alt text](./src/screenshots/Admin_Panel_View.png)

![alt text](./src/screenshots/Admin_Panel_View_2.png)

![alt text](./src/screenshots/Admin_Panel_View_3.png)

</div>

## Additional Information

### Postgresql Database

- Setup Database: [Digital Ocean Link for Django Deployment on VPS](https://www.digitalocean.com/community/tutorials/how-to-set-up-django-with-postgres-nginx-and-gunicorn-on-ubuntu-16-04)

### Docker

- [Docker Oficial Documentation](https://docs.docker.com/)
- Dockerizing Django, PostgreSQL, guinicorn, and Nginx:
    - Github repo of sunilale0: [Link](https://github.com/sunilale0/django-postgresql-gunicorn-nginx-dockerized/blob/master/README.md#nginx)
    - Michael Herman article on testdriven.io: [Link](https://testdriven.io/blog/dockerizing-django-with-postgres-gunicorn-and-nginx/)

### Django and DRF

- [Django Official Documentation](https://docs.djangoproject.com/en/6.1/)
- Generate a new secret key: [Stackoverflow Link](https://stackoverflow.com/questions/41298963/is-there-a-function-for-generating-settings-secret-key-in-django)
- Modify the Django Admin:
    - Small modifications (add searching, columns, ...): [Link](https://realpython.com/customize-django-admin-python/)
    - Modify Templates and css: [Link from Medium](https://medium.com/@brianmayrose/django-step-9-180d04a4152c)
- [Django Rest Framework Official Documentation](https://www.django-rest-framework.org/)
- More about Nested Serializers: [Stackoverflow Link](https://stackoverflow.com/questions/51182823/django-rest-framework-nested-serializers)
- More about GenericViews: [Testdriver.io Link](https://testdriven.io/blog/drf-views-part-2/)

### Miscellaneous

- Create Virual Environment with Virtualenv and Virtualenvwrapper: [Link](https://docs.python-guide.org/dev/virtualenvs/)
- [Configure CORS](https://www.stackhawk.com/blog/django-cors-guide/)
- [Setup Django with Cloudinary](https://cloudinary.com/documentation/django_integration)
