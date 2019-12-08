from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

from django.contrib.postgres.fields import JSONField


class Playlist(models.Model):
    is_public = models.BooleanField(default=True)
    is_active = models.BooleanField(default=False)
    place = JSONField(blank=True, null=True)
    name = models.CharField(max_length=200, blank=False, null=False)
    time_from = models.DateTimeField(blank=True, null=True)
    time_to = models.DateTimeField(blank=True, null=True)
    participants = models.ManyToManyField(User, blank=True, db_table='playlist_participant',
                                          related_name='participant_playlists')
    owners = models.ManyToManyField(User, blank=True, related_name='playlists')
    creator = models.ForeignKey(User, null=True, blank=True, on_delete=models.CASCADE,
                                related_name='playlist_creator')

    class Meta:
        managed = True
        db_table = 'playlist'

    def __str__(self):
        return self.name


class Track(models.Model):
    playlist = models.ForeignKey(Playlist, on_delete=models.CASCADE, blank=True, null=True, related_name='tracks')
    order = models.IntegerField(default=1)
    # track data from deezer api
    data = JSONField(blank=True, null=True)
    creator = models.ForeignKey(User, null=True, blank=True, on_delete=models.CASCADE, related_name='track_creator')

    class Meta:
        managed = True
        db_table = 'track'

    def __str__(self):
        return f'name: None - order: {self.order}'


class Vote(models.Model):
    track = models.ForeignKey(Track, on_delete=models.CASCADE, blank=True, null=True, related_name='votes')
    user = models.ForeignKey(User, on_delete=models.CASCADE, blank=True, null=True,
                             related_name='votes')

    class Meta:
        managed = True
        db_table = 'vote'
