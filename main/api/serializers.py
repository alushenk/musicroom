from rest_framework import serializers
from main.models import Playlist, Track, Vote
from django.contrib.auth import get_user_model
from django.db.models import Count

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name')

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
    votes = VoteSerializer(many=True, read_only=True)

    class Meta:
        model = Track
        fields = ('id', 'playlist', 'order', 'votes', 'data')


class PlaylistSmallSerializer(serializers.ModelSerializer):
    class Meta:
        model = Playlist
        fields = ('id', 'is_public', 'name', 'place', "time_from", "time_to", "is_active", 'creator',
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
        instance.save()
        instance.owners.set([request.user])
        return instance

    class Meta:
        model = Playlist
        fields = ('id', 'name', 'is_public', 'is_active', 'place', 'time_from', 'time_to')


class PlaylistDetailSerializer(serializers.ModelSerializer):
    tracks = serializers.SerializerMethodField()
    actions = serializers.SerializerMethodField()

    class Meta:

        model = Playlist
        fields = ('id', 'name', 'is_public', 'place', "time_from", "time_to", 'participants', 'owners', 'tracks',
                  'creator', 'actions')

    def get_actions(self, obj):
        actions_dict = dict.fromkeys(['add_participant', 'retrieve', 'list', 'unfollow', 'update', 'follow'
                                      'destroy', 'add_owner', 'partial_update'], False)
        request = self.context.get('request')
        if obj.is_public is True:
            actions_dict.update(dict.fromkeys(['follow'], True))
        if request.user in obj.participants.all():
            actions_dict.update(dict.fromkeys(['unfollow'], True))
        if request.user in obj.owners.all():
            actions_dict.update(dict.fromkeys(['add_participant', 'retrieve', 'list', 'unfollow', 'update',
                                               'destroy', 'add_owner', 'partial_update'], True))
        return actions_dict

    def get_tracks(self, instance):
        tracks = instance.tracks.annotate(votes_count=Count('votes')).order_by('-votes_count')
        return TrackDetailSerializer(tracks, many=True).data
