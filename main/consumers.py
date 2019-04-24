from asgiref.sync import async_to_sync
from channels.generic.websocket import WebsocketConsumer
import json


class PlaylistConsumer(WebsocketConsumer):
    def connect(self):
        self.playlist_id = self.scope['url_route']['kwargs']['playlist_id']
        self.group_name = f'playlist_{self.playlist_id}'

        # Join room group
        async_to_sync(self.channel_layer.group_add)(
            self.group_name,
            self.channel_name
        )

        self.accept()

    def disconnect(self, close_code):
        # Leave room group
        async_to_sync(self.channel_layer.group_discard)(
            self.group_name,
            self.channel_name
        )

    # todo возможно это нахуй не надо так как клиенты не пишут нихуя в сокеты, так що можно попробовать убрать
    # Receive message from WebSocket
    # def receive(self, text_data):
    #     text_data_json = json.loads(text_data)
    #     message = text_data_json['message']
    #
    #     # Send message to room group
    #     async_to_sync(self.channel_layer.group_send)(
    #         self.group_name,
    #         {
    #             'type': 'notification',
    #             'message': message
    #         }
    #     )

    # сюда я пишу из джанговых коллбэков
    # Receive message from room group
    def chat_message(self, event):
        message = event['message']

        # Send message to WebSocket
        self.send(text_data=json.dumps({
            'message': message
        }))
