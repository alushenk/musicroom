from rest_framework import serializers
from main.models import Playlist, Track, Vote
from django.contrib.auth import get_user_model
from django.db.models import Count

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name')


class VoteDeleteSerializer(serializers.Serializer):
    def create(self, validated_data):
        vote = validated_data['vote']
        vote.delete()
        instance = {"detail": "Vote deleted"}
        return instance


class VoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vote
        fields = ('id', 'track', 'user')


class TrackCreateSerializer(serializers.ModelSerializer):
    votes = VoteSerializer(many=True, read_only=True)

    class Meta:
        model = Track
        fields = ('id', 'playlist', 'data', 'creator', 'votes')


class TrackDetailSerializer(serializers.ModelSerializer):
    votes = VoteSerializer(many=True, read_only=True)

    class Meta:
        model = Track
        fields = ('id', 'playlist', 'order', 'votes', 'data', 'creator')


class PlaylistSmallSerializer(serializers.ModelSerializer):
    class Meta:
        model = Playlist
        fields = ('id', 'is_public', 'name', 'place', "time_from", "time_to", 'creator',
                  'owners', 'participants')


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
        instance.owners.set([request.user])
        instance.save()
        return instance

    class Meta:
        model = Playlist
        fields = ('id', 'name', 'is_public', 'place', 'time_from', 'time_to')


class PlaylistDetailSerializer(serializers.ModelSerializer):
    tracks = serializers.SerializerMethodField()
    actions = serializers.SerializerMethodField()

    class Meta:

        model = Playlist
        fields = ('id', 'name', 'is_public', 'place', "time_from", "time_to", 'participants', 'owners', 'tracks',
                  'creator', 'actions')

    def get_actions(self, obj):
        actions_dict = dict.fromkeys(['add_participant', 'retrieve', 'list', 'unfollow', 'update', 'follow',
                                      'destroy', 'add_owner', 'partial_update'], False)
        request = self.context.get('request')
        if obj.is_public is True:
            actions_dict.update(dict.fromkeys(['follow', 'retrieve'], True))
        if request.user in obj.participants.all():
            actions_dict.update(dict.fromkeys(['unfollow'], True))
        if request.user in obj.owners.all():
            actions_dict.update(dict.fromkeys(['add_participant', 'retrieve', 'list', 'unfollow', 'update',
                                               'destroy', 'add_owner', 'partial_update'], True))
        return actions_dict

    def get_tracks(self, instance):
        tracks = instance.tracks.annotate(votes_count=Count('votes')).order_by('-votes_count')
        return TrackDetailSerializer(tracks, many=True).data
