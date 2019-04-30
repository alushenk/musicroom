




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

---------------------------------------------------------------------------------------

from sentry_sdk import capture_message
from sentry_sdk import capture_exception

capture_message(EMAIL_HOST_PASSWORD)
capture_exception(EMAIL_HOST_PASSWORD)
capture_exception('hello suka blyad')

---------------------------------------------------------------------------------------

вот так вот красиво и просто можно дописат ебучий GET в 
/Users/anton/Documents/unit/projects/music_room/venv/lib/python3.7/site-packages/rest_auth/registration/views.py

но ещё проще использовать allauth.account.views.ConfirmEmailView (так и сделал)

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
        
---------------------------------------------------------------------------------------
СБРОС ПАРОЛЯ

POST /auth/password/reset
{
  "email": "wartoxy@gmail.com"
}

возвращает
{
  "detail": "Password reset e-mail has been sent."
}

и отправляет письмо со ссылкой на почту
ссылка ведет на
auth/password-reset/confirm/uidb64/token/

который сейчас возвращает 
{'uidb64': 'MQ', 'token': '55l-b632f36d63c3cc13c423'}

но по идее это должна быть страница 
(можно во вьюхе вернуть редирект на фронты, наверно можно сразу в конфиге указать куда после этого редиректить)
с формой которая шлет POST запрос на 
/auth/password/reset/confirm/

с такими данными 
{
  "new_password1": "asdfsa324",
  "new_password2": "asdfsa324",
  "uid": "MQ",
  "token": "55l-a5abac7edf49b4c7cca7"
}

uid и token берется из параметров реквеста

после успешной отправки формы/post запроса пароль ресетится
и нужно заново залогиниться (старый токен не работает)

---------------------------------------------------------------------------------------

ИЗМЕНЕНИЕ ПАРОЛЯ

POST /auth/password/change/

{
  "new_password1": "asdklfj984753",
  "new_password2": "asdklfj984753"
}

---------------------------------------------------------------------------------------

1. получить ссылку для авторизации через гугол можно по ссылке 
GET /auth/google/url
также можно захуярить ее в конфиг так как она сейчас статическая (может разве что сделаю разные домены для dev & prod)

2. перейти по ебучей ссылке (открывается в браузере)
3. выбрать свой гуголаккаунт
4. гугол редиректит на /auth/google/callback/
5. вернется json хуйня вида
{"code":"4/MAES8XCEF6i-bVDV0wF0TtBX92ePfQjwQHkakT1SrU5-vxkI1xqKsgF0r_eyfjHUf2Lu7O_RqmHbwAL4WdEy9Ig"}

6. пихнуть эту хуйню сюда
POST /auth/google/
{
  "code": "4/MAElD-DBrPdGbQblN9Pd0BZ3OQeN-iTGOajhvMRp6QUY6GWiD0P6pOdmP0WQmOmCSI7gEAswiD5pmqExApNgKOg"
}

возвращает
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozLCJ1c2VybmFtZSI6Imx1c2guYW50b255IiwiZXhwIjoxNTU1NjAyODc1LCJlbWFpbCI6Imx1c2guYW50b255QGdtYWlsLmNvbSJ9.ojanK0nJ-yNMIehbiWcQ1ZBwxFDZqdfPmTTyaHHYys4",
  "user": {
    "pk": 3,
    "username": "lush.antony",
    "email": "lush.antony@gmail.com",
    "first_name": "Антон",
    "last_name": "Люшенко"
  }
}

и юзер сразу с first_name & last_name и подтвержденным имейлом

---------------------------------------------------------------------------------------

https://docs.aws.amazon.com/cli/latest/userguide/cli-services-s3-commands.html

AWS CLI (S3) SHIT:
1. aws configure (paste stuff fron .env file)
2. aws s3 cp --recursive front/ s3://musicroom-bucket/front

---------------------------------------------------------------------------------------

{
    "Version": "2012-10-17",
    "Id": "Policy1552319312293",
    "Statement": [
        {
            "Sid": "Stmt1552319298545",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::musicroom-bucket/*"
        }
    ]
}

---------------------------------------------------------------------------------------

install npm in container

npm i      inside project

npm run build