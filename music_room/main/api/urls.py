from django.urls import path, include
from .viewsets import UserViewSet, PlaylistViewSet, TrackViewSet, VoteViewSet
from rest_framework.routers import DefaultRouter

router = DefaultRouter()
router.register('users', UserViewSet)
router.register('playlists', PlaylistViewSet)
router.register('tracks', TrackViewSet)
router.register('votes', VoteViewSet)

urlpatterns = [
    path('api/', include(router.urls)),
]
