from django.core.management.base import BaseCommand
import channels.layers
from asgiref.sync import async_to_sync


class Command(BaseCommand):
    def handle(self, *args, **options):
        group_name = f'playlist_1'

        # message = {
        #     'job_id': instance.id,
        #     'title': instance.title,
        #     'status': instance.status,
        #     'modified': instance.modified.isoformat(),
        # }

        message = "test from django"

        channel_layer = channels.layers.get_channel_layer()

        async_to_sync(channel_layer.group_send)(
            group_name,
            {
                'type': 'chat_message',
                'message': message
            }
        )
