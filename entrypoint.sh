#!/usr/bin/env bash
set -e

echo "Waiting for postgres to connect ..."

# Wait for the database to be up and ready, if not ready, then sleep for 5 seconds
while ! nc -z "${DB_HOST:-db}" "${DB_PORT:-5432}"; do
  echo "Postgres is not ready yet, retrying in 5 seconds ..."
  sleep 5
done

echo "PostgreSQL is active"

python manage.py collectstatic --noinput

python manage.py migrate --noinput
echo "Postgresql migrations finished"

# Create a superuser if the credentials are provided and the user does not exist yet
if [ -n "${DJANGO_SUPERUSER_USERNAME}" ] && [ -n "${DJANGO_SUPERUSER_EMAIL}" ] && [ -n "${DJANGO_SUPERUSER_PASSWORD}" ]; then
  if python manage.py shell -c "import os, sys; from django.contrib.auth import get_user_model; sys.exit(0 if get_user_model().objects.filter(username=os.environ['DJANGO_SUPERUSER_USERNAME']).exists() else 1)"; then
    echo "Superuser already exists, skipping"
  else
    python manage.py createsuperuser --noinput
    echo "Superuser created"
  fi
else
  echo "Superuser variables not set, skipping superuser creation"
fi

exec gunicorn tsa_app.wsgi:application --bind 0.0.0.0:8020

