from rest_framework import viewsets, status
from rest_framework.decorators import action
from custom_utils import MultiSerializerViewSetMixin
from django.db.models import Max
from rest_framework.generics import GenericAPIView

from rest_framework.permissions import IsAuthenticated, AllowAny
from allauth.socialaccount.providers.facebook.views import FacebookOAuth2Adapter
from allauth.socialaccount.providers.google.views import GoogleOAuth2Adapter
from rest_auth.registration.views import SocialLoginView
from allauth.socialaccount.providers.oauth2.client import OAuth2Client
from rest_framework.decorators import api_view
from django.http import HttpResponse
from datetime import datetime, timedelta
from sentry_sdk import capture_message
from sentry_sdk import capture_exception
from django.conf import settings
from django.core import management
from io import StringIO
from rest_framework.response import Response
from rest_framework.decorators import authentication_classes, permission_classes
from allauth.account.decorators import verified_email_required
from rest_framework.views import csrf_exempt
from rest_framework_jwt import authentication
from django.shortcuts import redirect
from rest_framework.reverse import reverse
from .. import models
from . import serializers
from . import permissions
from .filters import PlaylistFilter
from .exceptions import TrackExistsException
from django.contrib.auth import get_user_model
from requests import request as r
from django.shortcuts import get_object_or_404

User = get_user_model()


@api_view(['GET'])
@permission_classes(permission_classes=(AllowAny,))
def channel(request, **kwargs):
    # capture_message(settings.EMAIL_HOST_PASSWORD)
    # capture_exception(settings.EMAIL_HOST_PASSWORD)

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
def email_redirect(request, **kwargs):
    response = HttpResponse(
        'Your email has been verified. You can close this page now',
        content_type='text/html; charset=utf-8'
    )
    # response.mimetype = "text/plain"
    return response


@api_view(['GET'])
@permission_classes(permission_classes=(AllowAny,))
def password_reset_confirm(request, **kwargs):
    print(kwargs)
    h = {'uidb64': 'MQ', 'token': '55l-b632f36d63c3cc13c423'}
    return Response(kwargs)
    # data = """
    #         <form action="http://localhost:8000/auth/password/reset/confrm/" method="post">
    #             <label for="your_name">Your name: </label>
    #             <input id="uid64" type="text" name="your_name" value="{}">
    #             <input id="token" type="text" name="your_name" value="{}">
    #             <input id="new_password1" type="text" name="your_name">
    #             <input id="new_password2" type="text" name="your_name">
    #             <input type="submit" value="OK">
    #         </form>
    # """.format(kwargs['uidb64'], kwargs['token'])
    #
    # response = HttpResponse(
    #     data,
    #     content_type='text/html; charset=utf-8'
    # )
    # return response


@api_view(['GET'])
@permission_classes(permission_classes=(AllowAny,))
def email_verification_sent(request, **kwargs):
    return Response({'email-vefification-sent': 'OK'})


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
    return Response({'database-clear': 'OK', 'details': value})


@api_view(['GET'])
@permission_classes(permission_classes=(AllowAny,))
def fill_data(request, **kwargs):
    out = StringIO()
    management.call_command(
        'add_content',
        stdout=out
    )
    value = out.getvalue()
    return Response({'database-fill': 'OK', 'details': value})


@api_view(['GET'])
@permission_classes(permission_classes=(AllowAny,))
def google_callback(request, **kwargs):
    code = request.GET['code']
    # <костыль>
    # response = r('POST', 'http://localhost:8000/auth/google/', data={'code': code})
    response = r('POST', 'https://musicroom.ml/auth/google/', data={'code': code})
    # return redirect('/auth/google', data={'code': code})
    # </костыль>
    return Response(response.json())


@api_view(['GET'])
@permission_classes(permission_classes=(AllowAny,))
def google_url(request, **kwargs):
    from requests_oauthlib import OAuth2Session

    client_id = '205782653310-fjjullvs7cklq6su4qp0o7e8def79vfg.apps.googleusercontent.com'
    redirect_uri = 'https://musicroom.ml/auth/google/callback/'
    # redirect_uri = 'http://localhost:8000/auth/google/callback/'

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
    # callback_url = 'https://test-bot.morbax.com/rest-auth/google/callback/'
    # callback_url = 'http://localhost:8000/auth/google/callback/'
    callback_url = 'https://musicroom.ml/auth/google/callback/'

    # @action(methods=['GET'], detail=True, url_name='oauth_callback', url_path='oauth_callback')
    # def callback_url(self, request):
    #     print(request.data)

    # @action(methods=['GET'], detail=False, url_name='/rest-auth/google/callback/',
    #         url_path='/rest-auth/google/callback/')
    # def callback_url(self, request, **kwargs):
    #     code = kwargs['code']
    #     return {'code': code}


class UserViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = serializers.UserSerializer
    serializer_action_classes = {'list': serializers.UserSerializer,
                                 'retrieve': serializers.UserSerializer}

    @action(methods=['GET'], detail=False, url_path='user_search', url_name='user_search')
    def user_search(self, request):
        """Needs a request like: http://localhost:8000/api/users/user_search/?name=abc"""
        print(request.query_params['name'])
        queryset = User.objects.filter(username__icontains=request.query_params['name']).order_by('username').all()
        serializer = self.serializer_class(queryset, many=True)
        return Response(serializer.data)

    # эта штука нахуй не нужна так как все происходит через rest-auth ендпоинты
    # def get_permissions(self):
    #     # allow non-authenticated user to create via POST
    #     # todo is authenticated nado sdelat
    #     return (AllowAny() if self.request.method == 'POST' else IsAuthenticated()),


class PlaylistViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    queryset = models.Playlist.objects.all()
    permission_classes = (IsAuthenticated, permissions.PlaylistPermissions)
    serializer_class = serializers.PlaylistSerializer
    serializer_action_classes = {'list': serializers.PlaylistSmallSerializer,
                                 'retrieve': serializers.PlaylistDetailSerializer,
                                 'patch': serializers.PlaylistAddUsersSerializer,
                                 'add_participant': serializers.PlaylistAddUsersSerializer,
                                 'add_owner': serializers.PlaylistAddUsersSerializer,
                                 'my_playlists': serializers.PlaylistDetailSerializer}
    filter_class = PlaylistFilter

    def list(self, request, *args, **kwargs):
        """Returns the list of playlists where is_public=True. The endpoint for playlist search"""
        playlists = self.queryset.filter(is_public=True)
        serializer_class = self.get_serializer_class()
        serializer = serializer_class(playlists, many=True)
        return Response(serializer.data)

    def retrieve(self, request, *args, **kwargs):
        """Returns the playlist instance. If playlists "is_public=False" user has to be in playlist's
        Owners/Participants"""
        playlist = get_object_or_404(self.queryset, pk=kwargs['pk'])
        self.check_object_permissions(request, playlist)
        serializer_class = self.get_serializer_class()
        serializer = serializer_class(instance=playlist, context={'request': self.request})
        return Response(serializer.data)

    # @action(methods=['PATCH'], detail=True, url_path='add_participant', url_name='add_participant')
    # def add_participant(self, request, pk=None):
    #     playlist = get_object_or_404(self.queryset, pk=pk)
    #     self.check_object_permissions(request, playlist)
    #     playlist.participants.add(*request.data['participants'])
    #     serializer_class = self.get_serializer_class()
    #     serializer = serializer_class(playlist)
    #     return Response(serializer.data)
    #
    # @action(methods=['PATCH'], detail=True, url_path='add_owner', url_name='add_owner')
    # def add_owner(self, request, pk=None):
    #     playlist = self.queryset.filter(pk=pk)
    #     self.check_object_permissions(request, playlist)
    #     playlist.owners.add(*request.data['owners'])
    #     serializer_class = self.get_serializer_class()
    #     serializer = serializer_class(playlist)
    #     return Response(serializer.data)


class TrackViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    permission_classes = (IsAuthenticated, permissions.TrackPermissions)
    queryset = models.Track.objects.all()
    serializer_class = serializers.TrackCreateSerializer
    serializer_action_classes = {'list': serializers.TrackDetailSerializer,
                                 'retrieve': serializers.TrackDetailSerializer}

    def perform_create(self, serializer):
        if self.queryset.filter(playlist=self.request.data['playlist']).filter(data__id=self.
                request.data['data']['id']).exists():
            raise TrackExistsException
        else:
            data = dict()
            data['playlist'] = models.Playlist.objects.all().filter(id=self.request.data['playlist'])
            data['creator'] = self.request.user
            self.check_object_permissions(self.request, data['playlist'])
            last_order = self.queryset.filter(playlist=data['playlist']).aggregate(Max('order'))
            if last_order['order__max']:
                data['order'] = last_order['order__max'] + 1
            else:
                data['order'] = 1
            serializer.save(**data)

    def perform_destroy(self, instance):
        self.check_object_permissions(self.request, instance)
        instance.delete()


class VoteViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    permission_classes = (IsAuthenticated,)
    queryset = models.Vote.objects.all()
    serializer_class = serializers.VoteSerializer
    serializer_action_classes = {'list': serializers.VoteSerializer,
                                 'retrieve': serializers.VoteSerializer}

    def perform_create(self, serializer):
        """Creates a Vote instance. The endpoint for Like/Dislike action. The user can like track
        and by using this url again user can take his like of particular track"""
        data = dict()
        data['track'] = models.Track.objects.all().filter(id=self.request.data['track'])
        try:
            serializer.save(track=data['track'], user=self.request.user)
        except:
            serializer.data['status'] = "Instance deleted"
            print(serializer.data)


class UnfollowView(GenericAPIView):
    permission_classes = (IsAuthenticated, permissions.IsOwnerOrReadOnly)

    def delete(self, request, *args, **kwargs):
        """ Use to Unfollow the playlist. Deletes user both from Owners and  Participants.
        The endpoint for Unfollow action."""

        playlist_id = kwargs.get('pk')
        user_id = kwargs.get('user_id')
        queryset = models.Playlist.objects.all()
        user_to_remove = get_object_or_404(models.User.objects.all(), pk=user_id)
        playlist = get_object_or_404(queryset, pk=playlist_id)
        if user_to_remove in playlist.participants.all():
            if user_to_remove != request.user:
                self.check_object_permissions(request, playlist)
            playlist.participants.remove(user_to_remove)
        if user_to_remove in playlist.owners.all():
            playlist.owners.remove(user_to_remove)
        return Response(data={"User unfollowed the playlist (removed from participants/owners)"},
                        status=status.HTTP_204_NO_CONTENT)


class MyPlaylistsView(GenericAPIView):
    permission_classes = (IsAuthenticated, )

    def get(self, request, *args, **kwargs):
        """Returns playlists where current user is in Owners and/or Participants. The endpoint for My Playlists"""
        queryset = models.Playlist.objects.all()
        user_id = kwargs.get('user_id')
        playlist_ids = list()
        for playlist in queryset:
            for owner in playlist.owners.all():
                if owner.id is user_id:
                    playlist_ids.append(playlist.id)
            for participant in playlist.participants.all():
                if participant.id is user_id:
                    playlist_ids.append(playlist.id)
        playlists = queryset.filter(id__in=playlist_ids)
        serializer = serializers.PlaylistSmallSerializer(playlists, many=True, read_only=True)
        return Response(serializer.data)


class AddParticipantToPlaylistView(GenericAPIView):
    permission_classes = (IsAuthenticated, permissions.PlaylistViewPermissions)
    serializer_class = serializers.PlaylistDetailSerializer

    def patch(self, request, *args, **kwargs):
        """ Use to add user to the playlist's participants"""

        playlist_id = kwargs.get("pk")
        user_id = kwargs.get("user_id")
        queryset = models.Playlist.objects.all()
        playlist = get_object_or_404(queryset, pk=playlist_id)
        user_to_add = get_object_or_404(models.User.objects.all(), pk=user_id)
        self.check_object_permissions(request, playlist)
        playlist.participants.add(user_to_add)
        serializer_class = self.get_serializer_class()
        serializer = serializer_class(playlist, context={'request': self.request})
        return Response(serializer.data)

    def delete(self, request, *args, **kwargs):
        """ Use to delete participant from the playlist. Permissions: only owners can use"""

        playlist_id = kwargs.get('pk')
        user_id = kwargs.get('user_id')
        queryset = models.Playlist.objects.all()
        user_to_remove = get_object_or_404(models.User.objects.all(), pk=user_id)
        playlist = get_object_or_404(queryset, pk=playlist_id)
        self.check_object_permissions(request, playlist)
        if user_to_remove in playlist.participants.all():
            playlist.participants.remove(user_to_remove)
        return Response(data={"User deleted from the playlist's participants"}, status=status.HTTP_204_NO_CONTENT)


class AddOwnerToPlaylistView(GenericAPIView):
    permission_classes = (IsAuthenticated, permissions.IsOwnerOrReadOnly)
    serializer_class = serializers.PlaylistDetailSerializer

    def patch(self, request, *args, **kwargs):
        """ Use to add user to the playlist's owners"""
        playlist_id = kwargs.get("pk")
        user_id = kwargs.get("user_id")
        queryset = models.Playlist.objects.all()
        playlist = get_object_or_404(queryset, pk=playlist_id)
        user_to_add = get_object_or_404(models.User.objects.all(), pk=user_id)
        self.check_object_permissions(request, playlist)
        playlist.owners.add(user_to_add)
        serializer_class = self.get_serializer_class()
        serializer = serializer_class(playlist, context={'request': self.request})
        return Response(serializer.data)

    def delete(self, request, *args, **kwargs):
        """ Use to delete owner from the playlist. Permissions: only owners can use"""

        playlist_id = kwargs.get('pk')
        user_id = kwargs.get('user_id')
        queryset = models.Playlist.objects.all()
        user_to_remove = get_object_or_404(models.User.objects.all(), pk=user_id)
        playlist = get_object_or_404(queryset, pk=playlist_id)
        self.check_object_permissions(request, playlist)
        if user_to_remove in playlist.owners.all():
            playlist.owners.remove(user_to_remove)
        return Response(data={"User unfollowed the playlist (removed from participants/owners)"},
                        status=status.HTTP_204_NO_CONTENT)