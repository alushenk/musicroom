




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

документация: 
http://localhost:8000/docs/
https://musicroom.ml/docs/

надо поставить http://core-api.github.io/python-client/ (вроде для docs)

JWT:
https://github.com/davesque/django-rest-framework-simplejwt

psycopg2 не нужен потому что в джанге2 django.db.backends.postgresql


---------------------------------------------------------------------------------------
чтобы заработал блядский traefik:

touch acme.json
chmod 600 acme.json

---------------------------------------------------------------------------------------

http.js:124 Mixed Content: The page at 'https://musicroom.ml/docs/' was loaded over HTTPS, but requested an insecure resource 'http://musicroom.ml/api/playlists/'. This request has been blocked; the content must be served over HTTPS.