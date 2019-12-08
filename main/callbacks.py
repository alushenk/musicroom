from django.db.models.signals import post_save, post_delete, m2m_changed, pre_delete
from django.dispatch import receiver
import channels.layers
from asgiref.sync import async_to_sync
import main.models as models
from django.conf import settings


def send_user_signal(user_id, message):
    group_name = f'user_{user_id}'
    # settings.redis_connection.set('{}:{}'.format(group_name, message))

    channel_layer = channels.layers.get_channel_layer()

    async_to_sync(channel_layer.group_send)(
        group_name,
        {
            'type': 'chat_message',
            'message': message
        }
    )


def send_playlist_signal(playlist_id, message):
    group_name = f'playlist_{playlist_id}'

    channel_layer = channels.layers.get_channel_layer()

    async_to_sync(channel_layer.group_send)(
        group_name,
        {
            'type': 'chat_message',
            'message': message
        }
    )


def send_track_signal(track_id, message):
    group_name = f'track_{track_id}'

    channel_layer = channels.layers.get_channel_layer()

    async_to_sync(channel_layer.group_send)(
        group_name,
        {
            'type': 'chat_message',
            'message': message
        }
    )


@receiver(post_save, sender=models.Playlist)
def post_save_playlist(sender, **kwargs):
    instance = kwargs['instance']
    for participant in instance.participants.all():
        send_user_signal(participant.id, settings.SIGNAL_REFRESH)
    for owner in instance.owners.all():
        send_user_signal(owner.id, settings.SIGNAL_REFRESH)
    send_playlist_signal(instance.id, settings.SIGNAL_REFRESH)


@receiver(pre_delete, sender=models.Playlist)
def pre_delete_playlist(sender, **kwargs):
    instance = kwargs['instance']
    for participant in instance.participants.all():
        send_user_signal(participant.id, settings.SIGNAL_REFRESH)
    for owner in instance.owners.all():
        send_user_signal(owner.id, settings.SIGNAL_REFRESH)
    send_playlist_signal(instance.id, settings.SIGNAL_DELETE)


@receiver(post_save, sender=models.Track)
def post_save_track(sender, **kwargs):
    instance = kwargs['instance']
    # не обязательно рефрешить трек так как врятли его будут редактировать, сделал на всякий
    send_track_signal(instance.id, settings.SIGNAL_REFRESH)
    send_playlist_signal(instance.playlist_id, settings.SIGNAL_REFRESH)


@receiver(post_delete, sender=models.Track)
def post_delete_track(sender, **kwargs):
    instance = kwargs['instance']
    send_track_signal(instance.id, settings.SIGNAL_DELETE)
    send_playlist_signal(instance.playlist_id, settings.SIGNAL_REFRESH)


@receiver((post_save, pre_delete), sender=models.Vote)
def vote(sender, **kwargs):
    instance = kwargs['instance']
    track = instance.track
    send_track_signal(track.id, settings.SIGNAL_REFRESH)
    # это если в плейлисте будут отрисовываться лайки (вроде должны)
    send_playlist_signal(track.playlist_id, settings.SIGNAL_REFRESH)
