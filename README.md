




django-admin startproject <name> .
cd <name>
django-admin startapp <name>
cd ..


docker-compose.local.yml - для локального тестирования. сервис web запускается через ide
docker-compose.yml - для сервера, все сервисы внутри контейнеров

поднять базу в докере:
docker-compose -f docker-compose.local.yml up -d

остановить базу в докере:
docker-compose -f docker-compose.local.yml stop

документация: 
http://localhost:8000/docs/
https://musicroom.ml/docs/
https://musicroom.ml/swagger

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

---------------------------------------------------------------------------------------

to stop track file
git rm --cached <file>

---------------------------------------------------------------------------------------

ссыль на мокапы
https://drive.google.com/file/d/1WMtyw1-TQ5V_SPrCA2sCNQXfXzlYl-NN/view?usp=sharing

---------------------------------------------------------------------------------------

миша использует вместо свагера. оно умеет отображать документацию для вложенных объектов
https://github.com/axnsan12/drf-yasg

---------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------

/auth/registration
{
  "username": "pidor",
  "email": "pidor@gmail.com",
  "password1": "3.14door",
  "password2": "3.14door"
}
/auth/login
{
  "username": "pidor",
  "password": "3.14door"
}

---------------------------------------------------------------------------------------

Google OAUTH: The redirect URI in the request did not match a registered redirect URI
- просто поставить / в конце в настройках гугла (в браузере)

---------------------------------------------------------------------------------------

viewsets.login_url

    """
    /auth/google/url возвращает ссылку на нашу апку в гугле

    по ней должен перейти пользователь чтобы авторизоваться через гугол

    после авторизации пользователя редиректнет на

    /auth/google/callback который вернет некий code который потом надо пихнуть в

    /auth/google (поле access_token можно оставить пустым) который вернет JWT токен

    :param request:
    :param kwargs:
    :return:
    """
    
    
viewsets.TrackViewSet.perform_create

data['order'] = (last_order['order__max'] if last_order['order__max'] else 0) + 1

---------------------------------------------------------------------------------------

для плейлиста

owner:
- add participant
- add owner
- rename
- delete

participant:
- add track
- vote for track

creator:
- delete?