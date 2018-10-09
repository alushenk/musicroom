from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.views import csrf_exempt
from ..models import User, Playlist, Track, Vote
from .serializers import UserSerializer, PlaylistSerializer
from custom_utils import MultiSerializerViewSetMixin


class UserViewSet(MultiSerializerViewSetMixin, viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    serializer_action_classes = {'list': UserSerializer,
                                 'retrieve': UserSerializer}