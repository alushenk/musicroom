from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import csrf_exempt
# from ..models import User, Playlist, Track, Vote
from ..models import User, Playlist, Track, Vote
from .serializers import \
    UserSerializer, \
    PlaylistSerializer, \
    TrackDetailSerializer, \
    VoteSerializer, \
    PlaylistDetailSerializer, \
    PlaylistSmallSerializer
from custom_utils import MultiSerializerViewSetMixin
from collections import OrderedDict
from rest_framework.permissions import IsAuthenticated

from rest_framework.permissions import AllowAny
from .permissions import IsStaffOrTargetUser

from allauth.socialaccount.providers.facebook.views import FacebookOAuth2Adapter
from allauth.socialaccount.providers.google.views import GoogleOAuth2Adapter
from rest_auth.registration.views import SocialLoginView
from allauth.socialaccount.providers.oauth2.client import OAuth2Client


class FacebookLogin(SocialLoginView):
    adapter_class = FacebookOAuth2Adapter


class GoogleLogin(SocialLoginView):
    adapter_class = GoogleOAuth2Adapter
    client_class = OAuth2Client
    callback_url = 'https://test-bot.morbax.com/'

    # @action(methods=['GET'], detail=True, url_name='oauth_callback', url_path='oauth_callback')
    # def callback_url(self, request):
    #     print(request.data)


class UserViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    # permission_classes = (IsAuthenticated,)
    queryset = User.objects.all()
    serializer_class = UserSerializer
    serializer_action_classes = {'list': UserSerializer,
                                 'retrieve': UserSerializer}

    def get_permissions(self):
        # allow non-authenticated user to create via POST
        return (AllowAny() if self.request.method == 'POST' else IsStaffOrTargetUser()),


def get_track_order(track):
    return track['order']


class PlaylistViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    permission_classes = (IsAuthenticated,)
    queryset = Playlist.objects.all()
    serializer_class = PlaylistSerializer
    serializer_action_classes = {'list': PlaylistSmallSerializer,
                                 'retrieve': PlaylistDetailSerializer}

    def retrieve(self, request, *args, **kwargs):
        data = OrderedDict()
        participant_list = list()
        track_list = list()

        playlist = Playlist.objects.get(pk=kwargs['pk'])

        for participant in playlist.participants.all():
            participant_list.append(participant)

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
        data['owner'] = playlist.owner
        data['tracks'] = track_list
        data['participants'] = participant_list

        serializer = self.serializer_action_classes['retrieve'](data)
        return Response(serializer.data)

    @action(methods=['PATCH'], detail=True, url_path='add_participant', url_name='add_participant')
    def add_participant(self, request, pk=None):
        playlist = self.queryset.get(pk=pk)
        serializer = self.serializer_class(playlist, data={'participants': request.data['participants']}, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


class TrackViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    queryset = Track.objects.all()
    serializer_class = TrackDetailSerializer
    serializer_action_classes = {'list': TrackDetailSerializer,
                                 'retrieve': TrackDetailSerializer}


class VoteViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    queryset = Vote.objects.all()
    serializer_class = VoteSerializer
    serializer_action_classes = {'list': VoteSerializer,
                                 'retrieve': VoteSerializer}
