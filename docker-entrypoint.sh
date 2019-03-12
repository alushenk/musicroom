#!/usr/bin/env bash

psql -h db -p 5432 -U postgres -c "drop schema public cascade; create schema public;"

python manage.py makemigrations
python manage.py migrate                  # Apply database migrations
python manage.py add_content
python manage.py collectstatic --noinput  # Collect static files

# Prepare log files and start outputting logs to stdout
mkdir /srv/logs
touch /srv/logs/gunicorn.log
touch /srv/logs/access.log
tail -n 0 -f /srv/logs/*.log &

# Start Gunicorn processes
#echo Starting Gunicorn.
#exec gunicorn music_room.wsgi:application \
#    --name musicroom \
#    --bind 0.0.0.0:80 \
#    --workers 3 \
#    --log-level=info \
#    --log-file=/srv/logs/gunicorn.log \
#    --access-logfile=/srv/logs/access.log \
#    "$@"

#echo starting server
exec python manage.py runserver 0.0.0.0:8000
#
#exec "$@"