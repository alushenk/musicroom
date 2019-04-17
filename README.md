




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

---------------------------------------------------------------------------------------

from sentry_sdk import capture_message
from sentry_sdk import capture_exception

capture_message(EMAIL_HOST_PASSWORD)
capture_exception(EMAIL_HOST_PASSWORD)
capture_exception('hello suka blyad')

---------------------------------------------------------------------------------------

вот так вот красиво и просто можно дописат ебучий GET в 
/Users/anton/Documents/unit/projects/music_room/venv/lib/python3.7/site-packages/rest_auth/registration/views.py

но ещё проще использовать allauth.account.views.ConfirmEmailView

class VerifyEmailView(APIView, ConfirmEmailView):
    permission_classes = (AllowAny,)
    allowed_methods = ('POST', 'OPTIONS', 'HEAD')

    def get_serializer(self, *args, **kwargs):
        return VerifyEmailSerializer(*args, **kwargs)

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.kwargs['key'] = serializer.validated_data['key']
        confirmation = self.get_object()
        confirmation.confirm(self.request)
        return Response({'detail': _('ok')}, status=status.HTTP_200_OK)

    def get(self, request, key):
        serializer = self.get_serializer(data={"key": key})
        serializer.is_valid(raise_exception=True)
        confirmation = self.get_object()
        confirmation.confirm(self.request)
        return Response({'detail': _('ok')}, status=status.HTTP_200_OK)