from django.core.management.base import BaseCommand
import channels.layers
from asgiref.sync import async_to_sync


class Command(BaseCommand):
    def handle(self, *args, **options):
        group_name = f'playlist_1'
        message = "test from django"
        channel_layer = channels.layers.get_channel_layer()

        async_to_sync(channel_layer.group_send)(
            group_name,
            {
                'type': 'chat_message',
                'message': message
            }
        )
