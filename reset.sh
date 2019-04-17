#!/usr/bin/env bash

PYTHON='venv/bin/python'

#PROJECT_NAME=musicroom
#DOMAIN=musicroom.ml
#AWS_ACCESS_KEY_ID="AKIAIPE7X2FFK5JJI3ZQ"
#AWS_SECRET_ACCESS_KEY="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"
#SECRET_KEY='#en_*w34c(tw__3!-_@n(_!fw#p&5a59r-#k-)@q*h8eg12oje'


psql -h localhost -p 5432 -U postgres -c "drop schema public cascade; create schema public;"

#${PYTHON} manage.py makemigrations

#${PYTHON} manage.py migrate # bot_main

#${PYTHON}  manage.py flush --noinput
#
#${PYTHON}  manage.py add_content