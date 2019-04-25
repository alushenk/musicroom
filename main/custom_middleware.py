import channels.layers
from asgiref.sync import async_to_sync
from django.conf import settings


class DisableCSRF:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        setattr(request, '_dont_enforce_csrf_checks', True)

        response = self.get_response(request)

        return response


# class SendSignals:
#     def __init__(self, get_response):
#         self.get_response = get_response
#
#     def send_signal(self):
#         channel_layer = channels.layers.get_channel_layer()
#
#         async_to_sync(channel_layer.group_send)(
#             group_name,
#             {
#                 'type': 'chat_message',
#                 'message': message
#             }
#         )
#
#     def __call__(self, request):
#         settings.redis_connection.get('{}:{}'.format(user.id, working.id))
#
#         self.send_signal()
#
#         response = self.get_response(request)
#
#         return response
