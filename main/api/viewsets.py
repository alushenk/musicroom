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
from custom_utils import MultiSerializerViewSetMixin, get_track_order
from collections import OrderedDict
from django.db.models import Max


class UserViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    serializer_action_classes = {'list': UserSerializer,
                                 'retrieve': UserSerializer}

    @action(methods=['GET'], detail=False, url_path='user_search', url_name='user_search')
    def user_search(self, request):
        """Needs a request like: http://localhost:8000/api/users/user_search/?name=abc"""
        queryset = User.objects.all().filter(name__icontains=request.query_params['name']).order_by('name')
        serializer = self.serializer_class(queryset, many=True)
        return Response(serializer.data)


class PlaylistViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
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

    def perform_create(self, serializer):
        data = dict()
        data['playlist'] = Playlist.objects.get(id=self.request.data['playlist'])
        last_order = Track.objects.all().filter(playlist=data['playlist']).aggregate(Max('order'))
        data['order'] = last_order['order__max'] + 1
        serializer.save(**data)


class VoteViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    queryset = Vote.objects.all()
    serializer_class = VoteSerializer
    serializer_action_classes = {'list': VoteSerializer,
                                 'retrieve': VoteSerializer}

    def perform_create(self, serializer):
        data = dict()
        data['track'] = Track.objects.get(id=self.request.data['track'])
        data['user'] = User.objects.get(id=self.request.data['user'])
        try:
            serializer.save(track=data['track'], user=data['user'])
        except:
            serializer.data['status'] = "Instace deleted"
            print(serializer.data)
