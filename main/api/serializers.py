from rest_framework import serializers
from main.models import User, Playlist, Track, Vote


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = '__all__'

    def create(self, validated_data):
        user = User(
            email=validated_data.get('email', None)
        )
        user.set_password(validated_data.get('password', None))
        user.save()
        return user


class VoteListField(serializers.RelatedField):
    def to_representation(self, value):
        vote_count = Vote.objects.all().filter(track=self.queryset).count()
        return vote_count


class VoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vote
        fields = "__all__"


class TrackDetailSerializer(serializers.ModelSerializer):
    # votes = serializers.PrimaryKeyRelatedField(queryset=Vote.objects.get(track=).count())
    # votes = VoteSerializer(many=True, read_only=True)

    # votes = VoteListField(queryset=Track.objects.get(pk=1))

    class Meta:
        model = Track
        fields = ('playlist', 'link', 'order', 'votes')


# class TrackSerializer(serializers.Serializer):
#     votes_count =


class PlaylistSmallSerializer(serializers.ModelSerializer):
    class Meta:
        model = Playlist
        fields = ('is_public', 'place', "time_from", "time_to", "is_active")


class PlaylistSerializer(serializers.ModelSerializer):
    class Meta:
        model = Playlist
        fields = ('__all__')


class PlaylistDetailSerializer(serializers.ModelSerializer):
    participants = UserSerializer(many=True, read_only=True)
    owner = UserSerializer(read_only=True)
    tracks = TrackDetailSerializer(many=True, read_only=True)

    class Meta:
        model = Playlist
        fields = ('is_public', 'place', "time_from", "time_to", 'participants', 'owner', 'tracks')
