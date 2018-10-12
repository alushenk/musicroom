from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.views import csrf_exempt
from ..models import User, Playlist, Track, Vote
from .serializers import UserSerializer, PlaylistSerializer, TrackSerializer, VoteSerializer
from custom_utils import MultiSerializerViewSetMixin


class UserViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    serializer_action_classes = {'list': UserSerializer,
                                 'retrieve': UserSerializer}


class PlaylistViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    queryset = Playlist.objects.all()
    serializer_class = PlaylistSerializer
    serializer_action_classes = {'list': PlaylistSerializer,
                                 'retrieve': PlaylistSerializer}


class TrackViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    queryset = Track.objects.all()
    serializer_class = TrackSerializer
    serializer_action_classes = {'list': TrackSerializer,
                                 'retrieve': TrackSerializer}


class VoteViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    queryset = Vote.objects.all()
    serializer_class = VoteSerializer
    serializer_action_classes = {'list': VoteSerializer,
                                 'retrieve': VoteSerializer}