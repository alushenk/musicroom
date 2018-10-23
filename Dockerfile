#https://hub.docker.com/r/library/python/

FROM python:3.6

COPY requirements.txt ./

RUN apt update && apt -y upgrade
RUN apt -y install postgresql-client

RUN pip install --no-cache-dir -r requirements.txt

ADD . /code

WORKDIR /code

ENV DJANGO_SETTINGS_MODULE=music_room.settings
#RUN python manage.py collectstatic
ENTRYPOINT ["./docker-entrypoint.sh"]