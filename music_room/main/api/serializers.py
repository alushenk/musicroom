from rest_framework import serializers
from music_room.main.models import User, Playlist, Track, Vote


class UserSerializer(serializers.ModelSerializer):

    class Meta:
        model = User
        fields = '__all__'


class PlaylistSerializer(serializers.ModelSerializer):
    participants = UserSerializer(many=True, read_only=True)
    owners = UserSerializer(many=True, read_only=True)

    class Meta:
        model = Playlist
        fields = '__all__'
