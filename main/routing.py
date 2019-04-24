from django.urls import path

from . import consumers

websocket_urlpatterns = [
    path('ws/user/<str:user_id>/', consumers.PlaylistConsumer),
    path('ws/playlist/<str:playlist_id>/', consumers.PlaylistConsumer),
    path('ws/track/<str:track_id>/', consumers.PlaylistConsumer),
]