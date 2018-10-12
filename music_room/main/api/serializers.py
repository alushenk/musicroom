from rest_framework import serializers
from music_room.main.models import User, Playlist, Track, Vote


class UserSerializer(serializers.ModelSerializer):

    class Meta:
        model = User
        fields = '__all__'


class VoteCountField(serializers.RelatedField):
    def to_representation(self, value):
        print(value)
        vote_count = Vote.objects.all().count()
        return vote_count


class VoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vote
        fields = "__all__"


class TrackSerializer(serializers.ModelSerializer):
    # votes = serializers.PrimaryKeyRelatedField(queryset=Vote.objects.get(track=).count())
    # votes = VoteSerializer(many=True, read_only=True)
    votes = VoteCountField(read_only=True,)

    class Meta:
        model = Track
        fields = ('playlist', 'link', 'order', 'votes')


class PlaylistSerializer(serializers.ModelSerializer):
    participants = UserSerializer(many=True, read_only=True)
    owner = UserSerializer(read_only=True)
    tracks = TrackSerializer(many=True, read_only=True)

    class Meta:
        model = Playlist
        fields = ('is_public', 'place', "time_from", "time_to", 'participants', 'owner', 'tracks')
