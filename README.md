




django-admin startproject <name> .
cd <name>
django-admin startapp <name>
cd ..


полностью пересоздать базу:
./reset.sh

docker-compose.local.yml - для локального тестирования. сервис web запускается через ide
docker-compose.yml - для сервера, все сервисы внутри контейнеров

поднять базу в докере:
docker-compose -f docker-compose.local.yml up -d

остановить базу в докере:
docker-compose -f docker-compose.local.yml stop

документация: http://localhost:8000/docs/
надо поставить http://core-api.github.io/python-client/

JWT:
https://github.com/davesque/django-rest-framework-simplejwt



