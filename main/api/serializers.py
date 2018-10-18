from rest_framework import serializers
from main.models import User, Playlist, Track, Vote


class UserSerializer(serializers.ModelSerializer):

    class Meta:
        model = User
        fields = '__all__'
        # fields = ('email', 'password')

    # def create(self, validated_data):
    #     user = User(
    #         email=validated_data.get('email', None)
    #     )
    #     user.set_password(validated_data.get('password', None))
    #     user.save()
    #     return user


class VoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vote
        fields = "__all__"


class TrackDetailSerializer(serializers.ModelSerializer):
    votes_count = serializers.IntegerField(read_only=True)
    votes = VoteSerializer(many=True, read_only=True)

    class Meta:
        model = Track
        fields = ('id', 'playlist', 'link', 'order', 'votes_count', 'votes')


class PlaylistSmallSerializer(serializers.ModelSerializer):

    class Meta:
        model = Playlist
        fields = ('is_public', 'place', "time_from", "time_to", "is_active")


class PlaylistSerializer(serializers.ModelSerializer):

    class Meta:
        model = Playlist
        fields = '__all__'


class PlaylistDetailSerializer(serializers.ModelSerializer):
    participants = UserSerializer(many=True, read_only=True)
    owner = UserSerializer(read_only=True)
    tracks = TrackDetailSerializer(many=True, read_only=True)

    class Meta:
        model = Playlist
        fields = ('name', 'is_public', 'place', "time_from", "time_to", 'participants', 'owner', 'tracks')
