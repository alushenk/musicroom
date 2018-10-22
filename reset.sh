#!/usr/bin/env bash

PYTHON='venv/bin/python'

psql -h localhost -p 5432 -U postgres -c "drop schema public cascade; create schema public;"

${PYTHON} manage.py makemigrations

${PYTHON} manage.py migrate # bot_main

${PYTHON}  manage.py add_content