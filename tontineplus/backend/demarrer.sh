#!/bin/sh
# Démarrage du conteneur : migrations, fichiers statiques de l'admin, puis Gunicorn.
set -e
python manage.py migrate --noinput
python manage.py collectstatic --noinput -v0
exec gunicorn config.wsgi --bind 0.0.0.0:8000 --workers "${GUNICORN_WORKERS:-3}" --access-logfile -
