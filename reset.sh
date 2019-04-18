#!/usr/bin/env bash

PYTHON='../../musicroom/bin/python'

${PYTHON} manage.py flush --noinput

${PYTHON}  manage.py add_content