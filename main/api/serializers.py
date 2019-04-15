from rest_framework import serializers
from main.models import User, Playlist, Track, Vote
from rest_framework.response import Response


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = '__all__'

    # def create(self, validated_data):
    #     user = User(
    #         email=validated_data.get('email', None)
    #     )
    #     user.set_password(validated_data.get('password', None))
    #     user.save()
    #     return user


class VoteSerializer(serializers.ModelSerializer):
    status = serializers.CharField(max_length=150, required=False)

    class Meta:
        model = Vote
        fields = ("id", "track", "user", "status")

    def create(self, validated_data):
        try:
            vote = Vote.objects.get(track_id=validated_data['track'].id, user_id=validated_data['user'].id)
            vote.delete()
            return None
        except:
            return Vote.objects.create(**validated_data)


class TrackCreateSerializer(serializers.ModelSerializer):

    class Meta:
        model = Track
        fields = ('id', 'playlist', 'data')


class TrackDetailSerializer(serializers.ModelSerializer):
    votes_count = serializers.IntegerField(read_only=True)
    votes = VoteSerializer(many=True, read_only=True)

    class Meta:
        model = Track
        fields = ('id', 'playlist', 'order', 'votes_count', 'votes', 'data')


class PlaylistSmallSerializer(serializers.ModelSerializer):
    class Meta:
        model = Playlist
        fields = ('id', 'is_public', 'name', 'place', "time_from", "time_to", "is_active", 'creator', "owners", "participants")


class PlaylistAddUsersSerializer(serializers.ModelSerializer):
    class Meta:
        model = Playlist
        fields = ('participants', 'owners')


class PlaylistSerializer(serializers.ModelSerializer):
    def create(self, validated_data):
        ModelClass = self.Meta.model
        instance = ModelClass.objects.create(**validated_data)
        request = self.context.get('request')

        instance.creator = request.user
        instance.save()
        instance.owners.set([request.user])
        return instance

    class Meta:
        model = Playlist
        fields = ('id', 'name', 'is_public', 'is_active', 'place', 'time_from', 'time_to')


class PlaylistDetailSerializer(serializers.ModelSerializer):
    tracks = TrackDetailSerializer(many=True, read_only=True)

    class Meta:
        model = Playlist
        fields = ('id', 'name', 'is_public', 'place', "time_from", "time_to", 'participants', 'owners', 'tracks',
                  'creator')
