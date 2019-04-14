from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import csrf_exempt
from ..models import User, Playlist, Track, Vote
from .serializers import \
    UserSerializer, \
    PlaylistSerializer, \
    TrackDetailSerializer, \
    VoteSerializer, \
    PlaylistDetailSerializer, \
    PlaylistSmallSerializer, \
    PlaylistAddUsersSerializer, \
    TrackCreateSerializer
from custom_utils import MultiSerializerViewSetMixin
from collections import OrderedDict
from django.db.models import Max
from rest_framework.permissions import IsAuthenticated, AllowAny
from .permissions import PlaylistPermissions, TrackPermissions

from allauth.socialaccount.providers.facebook.views import FacebookOAuth2Adapter
from allauth.socialaccount.providers.google.views import GoogleOAuth2Adapter
from rest_auth.registration.views import SocialLoginView
from allauth.socialaccount.providers.oauth2.client import OAuth2Client
from rest_framework.decorators import api_view
from rest_framework.reverse import reverse
from django.http import JsonResponse, HttpResponse
from rest_framework.response import Response
from rest_framework.decorators import authentication_classes, permission_classes
from django.shortcuts import redirect
from datetime import datetime, timedelta
from sentry_sdk import capture_message
from sentry_sdk import capture_exception
from django.conf import settings
from django.core import management
from io import StringIO


@api_view(['GET'])
@permission_classes(permission_classes=(AllowAny,))
def channel(request, **kwargs):
    capture_message(settings.EMAIL_HOST_PASSWORD)
    capture_exception(settings.EMAIL_HOST_PASSWORD)

    cache_expire = 60 * 60 * 24 * 365
    expiry_time = datetime.utcnow() + timedelta(days=365)
    response = HttpResponse(
        '<script src="https://e-cdns-files.dzcdn.net/js/min/dz.js"></script>',
        # headers={'Expires': expiry_time.strftime("%a, %d %b %Y %H:%M:%S GMT"),
        #          'Cache-Control': 'maxage={}'.format(cache_expire),
        #          'Pragma': 'public'
        #          },
        content_type='text/html; charset=utf-8'
    )
    response['Expires'] = expiry_time.strftime("%a, %d %b %Y %H:%M:%S GMT")
    response['Cache-Control'] = 'maxage={}'.format(cache_expire)
    response['Pragma'] = 'public'
    # response.mimetype = "text/plain"
    return response


@api_view(['GET'])
@permission_classes(permission_classes=(AllowAny,))
def clear_data(request, **kwargs):
    out = StringIO()
    management.call_command(
        'flush',
        '--noinput',
        stdout=out
    )
    value = out.getvalue()
    return JsonResponse({'database-clear': 'OK', 'details': value})


@api_view(['GET'])
@permission_classes(permission_classes=(AllowAny,))
def fill_data(request, **kwargs):
    out = StringIO()
    management.call_command(
        'add_content',
        stdout=out
    )
    value = out.getvalue()
    return JsonResponse({'database-fill': 'OK', 'details': value})


@api_view(['GET'])
# @authentication_classes([])
# @permission_classes([])
def callback_url(request, **kwargs):
    print(request.data)
    print(kwargs)
    code = request.GET['code']
    # code = kwargs['code']
    return JsonResponse({'code': code})


import unicodedata


@api_view(['GET'])
def login_url(request, **kwargs):
    from requests_oauthlib import OAuth2Session

    client_id = '205782653310-fjjullvs7cklq6su4qp0o7e8def79vfg.apps.googleusercontent.com'
    redirect_uri = 'https://musicroom.ml/rest-auth/google/callback/'

    authorization_base_url = 'https://accounts.google.com/o/oauth2/v2/auth'
    scope = [
        "https://www.googleapis.com/auth/userinfo.email",
        "https://www.googleapis.com/auth/userinfo.profile"
    ]

    oauth = OAuth2Session(client_id, scope=scope, redirect_uri=redirect_uri)

    # redirect user to google for authorization
    authorization_url, state = oauth.authorization_url(authorization_base_url, access_type='offline',
                                                       prompt='select_account')
    # u = str(authorization_url).replace('&amp', ';')
    # print(u)
    # print('aaaaaaa', unicodedata.normalize('NFKC', authorization_url))
    print(authorization_url)
    # return JsonResponse(data={'google_url': authorization_url, 'huy': 'https://huy.morbax.com'})
    # return JsonResponse({'google_url': authorization_url, 'huy': 'https://huy.morbax.com'})
    return Response({"google_url": authorization_url})


class FacebookLogin(SocialLoginView):
    adapter_class = FacebookOAuth2Adapter


class GoogleLogin(SocialLoginView):
    adapter_class = GoogleOAuth2Adapter
    client_class = OAuth2Client
    # callback_url = 'https://test-bot.morbax.com/accounts/google/login/callback/'
    callback_url = 'https://test-bot.morbax.com/rest-auth/google/callback/'

    # @action(methods=['GET'], detail=True, url_name='oauth_callback', url_path='oauth_callback')
    # def callback_url(self, request):
    #     print(request.data)

    # @action(methods=['GET'], detail=False, url_name='/rest-auth/google/callback/',
    #         url_path='/rest-auth/google/callback/')
    # def callback_url(self, request, **kwargs):
    #     code = kwargs['code']
    #     return {'code': code}


class UserViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    permission_classes = (IsAuthenticated,)
    # authentication_classes =
    queryset = User.objects.all()
    serializer_class = UserSerializer
    serializer_action_classes = {'list': UserSerializer,
                                 'retrieve': UserSerializer}

    @action(methods=['GET'], detail=False, url_path='user_search', url_name='user_search')
    def user_search(self, request):
        """Needs a request like: http://localhost:8000/api/users/user_search/?name=abc"""
        queryset = User.objects.all().filter(username__icontains=request.query_params['username']).order_by('username')
        serializer = self.serializer_class(queryset, many=True)
        return Response(serializer.data)

    # эта штука нахуй не нужна так как все происходит через rest-auth ендпоинты
    def get_permissions(self):
        # allow non-authenticated user to create via POST
        # todo is authenticated nado sdelat
        return (AllowAny() if self.request.method == 'POST' else IsAuthenticated()),


def get_track_order(track):
    return track['order']


class PlaylistViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    queryset = Playlist.objects.all()
    permission_classes = (IsAuthenticated, PlaylistPermissions)
    serializer_class = PlaylistSerializer
    serializer_action_classes = {'list': PlaylistSmallSerializer,
                                 'retrieve': PlaylistDetailSerializer,
                                 'patch': PlaylistAddUsersSerializer}

    def retrieve(self, request, *args, **kwargs):
        data = OrderedDict()
        participant_list = list()
        track_list = list()

        playlist = Playlist.objects.get(pk=kwargs['pk'])

        for participant in playlist.participants.all():
            participant_list.append(participant)

        # TODO check why we've done this
        for track in playlist.tracks.all():
            track_info = dict()
            vote_counter = track.votes.all().count()
            track_info['id'] = track.id
            track_info['order'] = track.order
            track_info['votes_count'] = vote_counter
            track_info['playlist'] = track.playlist
            track_list.append(track_info)
        track_list = sorted(track_list, key=get_track_order)

        data['name'] = playlist.name
        data['is_public'] = playlist.is_public
        data['is_active'] = playlist.is_active
        data['place'] = playlist.place
        data['name'] = playlist.name
        data['time_to'] = playlist.time_to
        data['time_from'] = playlist.time_from
        data['owners'] = playlist.owners
        data['tracks'] = track_list
        data['participants'] = participant_list
        data['creator'] = playlist.creator

        serializer = self.serializer_action_classes['retrieve'](data)
        return Response(serializer.data)

    @action(methods=['PATCH'], detail=True, url_path='add_participant', url_name='add_participant')
    def add_participant(self, request, pk=None):
        playlist = self.queryset.get(pk=pk)
        self.check_object_permissions(request, playlist)
        playlist.participants.add(*request.data['participants'])
        serializer = PlaylistAddUsersSerializer(playlist)
        return Response(serializer.data)

    @action(methods=['PATCH'], detail=True, url_path='add_owner', url_name='add_owner')
    def add_owner(self, request, pk=None):
        playlist = self.queryset.get(pk=pk)
        self.check_object_permissions(request, playlist)
        playlist.owners.add(*request.data['owners'])
        serializer = PlaylistAddUsersSerializer(playlist)
        return Response(serializer.data)

    @action(methods=['GET'], detail=False, url_path='my_playlists', url_name='my_playlists')
    def get_my_playlist(self, request):
        """DOESN'T WORK AT THE MOMENT"""
        playlists = self.queryset.all()
        playlist_ids = list()
        for playlist in playlists:
            for owner in playlist.owners.all():
                if owner.id is request.user.id:
                    playlist_ids.append(playlist.id)
        playlists = playlists.filter(id__in=playlist_ids)
        serializer = self.serializer_class(playlists, many=True)
        return Response(serializer.data)

    @action(methods=['GET'], detail=False, url_path='available_playlists', url_name='available_playlists')
    def get_available_playlists(self, request):
        """DOESN'T WORK AT THE MOMENT"""
        playlists = self.queryset.all()
        playlist_ids = list()
        for playlist in playlists:
            for participant in playlist.participants.all():
                if participant.id is request.user.id:
                    playlist_ids.append(playlist.id)
        playlists = playlists.filter(id__in=playlist_ids)
        serializer = self.serializer_class(playlists, many=True)
        return Response(serializer.data)


class TrackViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    permission_classes = (IsAuthenticated, TrackPermissions)
    queryset = Track.objects.all()
    serializer_class = TrackCreateSerializer
    serializer_action_classes = {'list': TrackDetailSerializer,
                                 'retrieve': TrackDetailSerializer}

    def perform_create(self, serializer):
        if serializer.is_valid():
            if Track.objects.all().filter(playlist=self.request.data['playlist']).filter(data__id=self.request.data['data']['id']):
                data = {"response": "Track already exists"}
                serializer.save(**data)
                # return Response(data={'message': 'Track already exists'}, status=status.HTTP_400_BAD_REQUEST)
            else:
                data = dict()
                data['playlist'] = Playlist.objects.get(id=self.request.data['playlist'])
                data['creator'] = self.request.user
                self.check_object_permissions(self.request, data['playlist'])
                last_order = Track.objects.all().filter(playlist=data['playlist']).aggregate(Max('order'))
                if last_order['order__max']:
                    data['order'] = last_order['order__max'] + 1
                else:
                    data['order'] = 1
                serializer.save(**data)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def perform_destroy(self, instance):
        self.check_object_permissions(self.request, instance)
        instance.delete()


class VoteViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    permission_classes = (IsAuthenticated,)
    queryset = Vote.objects.all()
    serializer_class = VoteSerializer
    serializer_action_classes = {'list': VoteSerializer,
                                 'retrieve': VoteSerializer}

    def perform_create(self, serializer):
        data = dict()
        data['track'] = Track.objects.get(id=self.request.data['track'])
        try:
            serializer.save(track=data['track'], user=self.request.user)
        except:
            serializer.data['status'] = "Instace deleted"
            print(serializer.data)
