from django.test import TestCase
from rest_framework.test import APIRequestFactory
from rest_framework.test import RequestsClient
from rest_framework.test import APITestCase
from requests.auth import HTTPBasicAuth

from rest_framework import status
from main.models import *
import logging

logger = logging.getLogger('main')

DOMAIN = 'http://localhost:8000'


class RegistrationTestCase(APITestCase):

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_registration(self):
        # точно возвращает токен
        # перебрасывает на страничку логина?

        url = f'{DOMAIN}/auth/registration/'
        data = {
            "username": "pidor",
            "email": "pidor@gmail.com",
            "password1": "3.14door",
            "password2": "3.14door"
        }
        response = self.client.post(url, data, format='json')

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(User.objects.count(), 1)
        self.assertIsNotNone(response.data['token'])

        user = response.data['user']
        self.assertEqual(data['username'], user['username'])
        self.assertEqual(data['email'], user['email'])

        # todo хули блять здесь pk а дальше id?
        user_id = user['pk']
        token = response.data['token']

        response = self.client.get(f'{DOMAIN}/api/users/', format='json')
        self.assertEqual(len(response.json()), 1)

        # todo нахуя здесь возвращать password? и почему оно вообще возвращает мне юзера когда я не авторизован?
        #  походу надо поебаться с пермишенами,
        response = self.client.get(f'{DOMAIN}/api/users/{user_id}/', format='json')
        logger.error(response.json())

        # --------------------------------------------------------------------------------------------------------------
        # login
        # роут нужен для session authentication
        # если конечно юзера автоматом не логинит/перебрасывает на страничку логина после регистрации
        # токен возвращается сразу после регитрации

        url = f'{DOMAIN}/auth/login/'
        data = {
            "username": "pidor",
            "password": "3.14door"
        }
        response = self.client.post(url, data, format='json')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(
            response.data['user'],
            {
                "pk": user_id,
                "username": "pidor",
                "email": "pidor@gmail.com",
                "first_name": "",
                "last_name": ""
            }
        )

        token = response.data['token']
        self.assertIsNotNone(token)

    def test_permissions(self):
        # --------------------------------------------------------------------------------------------------------------
        # test permissions
        # user should'nt be able to perform api requests when he is'nt authenticated - no token or session

        response = self.client.get(f'{DOMAIN}/api/users/')
        # а если делать через .http файл то выдает HTTP_401_UNAUTHORIZED
        # если закоментить IsAuthenticated выдает HTTP_403_FORBIDDEN
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

        response = self.client.get(f'{DOMAIN}/api/playlists/')
        # а если делать через .http файл то выдает HTTP_401_UNAUTHORIZED
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

        response = self.client.get(f'{DOMAIN}/api/tracks/')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

        response = self.client.get(f'{DOMAIN}/api/votes/')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

        # authorized user ----------------------------------------------------------------------------------------------

        # self.client.session.auth = HTTPBasicAuth('pidor', '3.14door')
        # self.client.session.headers.update({'x-test': 'true'})

        url = f'{DOMAIN}/auth/registration/'
        data = {
            "username": "pidor",
            "email": "pidor@gmail.com",
            "password1": "3.14door",
            "password2": "3.14door"
        }
        response = self.client.post(url, data, format='json')

        # todo походу /auth/registration сразу авторизует так что эта хуйня не нужна
        # self.client.login(username='pidor', password='3.14door')

        # --------------------------------------------------------------------------------------------------------------

        response = self.client.get(f'{DOMAIN}/api/users/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        response = self.client.get(f'{DOMAIN}/api/playlists/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        response = self.client.get(f'{DOMAIN}/api/tracks/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        response = self.client.get(f'{DOMAIN}/api/votes/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
