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
        # logger.error(response.json())

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

    def test_track(self):
        # registration
        url = f'{DOMAIN}/auth/registration/'
        data = {
            "username": "pidor",
            "email": "pidor@gmail.com",
            "password1": "3.14door",
            "password2": "3.14door"
        }
        response = self.client.post(url, data, format='json')

        # create playlist
        url = f'{DOMAIN}/api/playlists/'
        data = {
            "name": "zalupa",
            "is_public": True,
            "is_active": True
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        playlist_id = response.data['id']
        logger.error(response.data)

        # get playlist by id

        response = self.client.get(f'{DOMAIN}/api/playlists/{playlist_id}')
        logger.error(response.json())
        self.assertEqual(response.status_code, status.HTTP_301_MOVED_PERMANENTLY)

        # --------------------------------------------------------------------------------------------------------------

        # create one track
        url = f'{DOMAIN}/api/tracks/'
        deezer_data = {
            "id": 623736392,
            "readable": True,
            "title": "Some Say",
            "title_short": "Some Say",
            "title_version": "",
            "link": "https://www.deezer.com/track/623736392",
            "duration": 205,
            "rank": 549485,
            "explicit_lyrics": False,
            "explicit_content_lyrics": 0,
            "explicit_content_cover": 2,
            "preview": "https://cdns-preview-e.dzcdn.net/stream/c-eecebe7b7b43d2b3ffc04b053fa1f0b0-4.mp3",
            "artist": {
                "id": 459,
                "name": "Sum 41",
                "link": "https://www.deezer.com/artist/459",
                "picture": "https://api.deezer.com/artist/459/image",
                "picture_small": "https://e-cdns-images.dzcdn.net/images/artist/8f732ff3d26e22beb0eca2b528fd419d/56x56-000000-80-0-0.jpg",
                "picture_medium": "https://e-cdns-images.dzcdn.net/images/artist/8f732ff3d26e22beb0eca2b528fd419d/250x250-000000-80-0-0.jpg",
                "picture_big": "https://e-cdns-images.dzcdn.net/images/artist/8f732ff3d26e22beb0eca2b528fd419d/500x500-000000-80-0-0.jpg",
                "picture_xl": "https://e-cdns-images.dzcdn.net/images/artist/8f732ff3d26e22beb0eca2b528fd419d/1000x1000-000000-80-0-0.jpg",
                "tracklist": "https://api.deezer.com/artist/459/top?limit=50",
                "type": "artist"
            },
            "album": {
                "id": 85609322,
                "title": "Chuck",
                "cover": "https://api.deezer.com/album/85609322/image",
                "cover_small": "https://e-cdns-images.dzcdn.net/images/cover/c6a0130589841326372ac87c6924ed65/56x56-000000-80-0-0.jpg",
                "cover_medium": "https://e-cdns-images.dzcdn.net/images/cover/c6a0130589841326372ac87c6924ed65/250x250-000000-80-0-0.jpg",
                "cover_big": "https://e-cdns-images.dzcdn.net/images/cover/c6a0130589841326372ac87c6924ed65/500x500-000000-80-0-0.jpg",
                "cover_xl": "https://e-cdns-images.dzcdn.net/images/cover/c6a0130589841326372ac87c6924ed65/1000x1000-000000-80-0-0.jpg",
                "tracklist": "https://api.deezer.com/album/85609322/tracks",
                "type": "album"
            },
            "type": "track"
        }

        data = {
            "playlist": playlist_id,
            "data": deezer_data
        }

        response = self.client.post(url, data, format='json')

        logger.error(response.data)

        self.assertEqual(response.data['data'], deezer_data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        # get playlist by id

        response = self.client.get(f'{DOMAIN}/api/playlists/{playlist_id}')
        logger.error(response.json())
        self.assertEqual(response.status_code, status.HTTP_301_MOVED_PERMANENTLY)

        # --------------------------------------------------------------------------------------------------------------

        # create the same track
        url = f'{DOMAIN}/api/tracks/'
        response = self.client.post(url, data, format='json')

        # response = self.client.get(f'{DOMAIN}/api/users/')

        logger.error(response.data)

        self.assertEqual(response.data['data'], 'text')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
