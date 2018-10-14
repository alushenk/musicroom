from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import csrf_exempt
from ..models import User, Playlist, Track, Vote
from .serializers import UserSerializer,\
                            PlaylistSerializer, \
                            TrackDetailSerializer, \
                            VoteSerializer,\
                            PlaylistDetailSerializer,\
                            PlaylistSmallSerializer
from custom_utils import MultiSerializerViewSetMixin
from collections import OrderedDict


class UserViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    serializer_action_classes = {'list': UserSerializer,
                                 'retrieve': UserSerializer}


class PlaylistViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    queryset = Playlist.objects.all()
    serializer_class = PlaylistSerializer
    serializer_action_classes = {'list': PlaylistSmallSerializer,
                                 'retrieve': PlaylistDetailSerializer}

    def retrieve(self, request, *args, **kwargs):
        data = OrderedDict()
        participant_list = list()
        track_info = dict()
        track_list = list()

        playlist = Playlist.objects.get(pk=kwargs['pk'])

        for participant in playlist.participants.all():
            participant_list.append(participant)

        for track in playlist.tracks.all():
            vote_counter = track.votes.all().count()
            track_info['id'] = track.id
            track_info['order'] = track.order
            track_info['votes_count'] = vote_counter
            track_list.append(track_info)

        data['is_public'] = playlist.is_public
        data['is_active'] = playlist.is_active
        data['place'] = playlist.place
        data['name'] = playlist.name
        data['time_to'] = playlist.time_to
        data['time_from'] = playlist.time_from
        data['owner'] = playlist.owner
        data['tracks'] = track_list

    @action(methods=['PATCH'], detail=True, url_path='add_participant', url_name='add_participant')
    def add_participant(self, request, pk=None):
        playlist = self.queryset.get(pk=pk)
        users_to_add = [User.objects.get(pk=id) for id in request.data['participants']]
        print(users_to_add)
        for user in users_to_add:
            playlist.participants.set(user)
            playlist.save()
        return Response(status=status.HTTP_200_OK)


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