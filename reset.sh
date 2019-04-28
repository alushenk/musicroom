#!/usr/bin/env bash

PYTHON='../../musicroom/bin/python'

CONTAINER_NAME=music_room_web_1

docker exec -t ${CONTAINER_NAME} psql -h db -p 5432 -U postgres -c "drop schema public cascade; create schema public;"
#docker exec -d ${CONTAINER_NAME} manage.py flush --noinput
docker exec -d ${CONTAINER_NAME} redis-cli flushdb
docker exec -t ${CONTAINER_NAME} /code/manage.py migrate
docker exec -t ${CONTAINER_NAME} /code/manage.py add_content
#docker exec -dt ${CONTAINER_NAME} echo huy