from django.urls import path, include
from .viewsets import UserViewSet, PlaylistViewSet, TrackViewSet, VoteViewSet
from rest_framework.routers import DefaultRouter
from django.conf.urls import url
from rest_framework.documentation import include_docs_urls

router = DefaultRouter()
router.register('users', UserViewSet)
router.register('playlists', PlaylistViewSet)
router.register('tracks', TrackViewSet)
router.register('votes', VoteViewSet)

urlpatterns = [
    path('api/', include(router.urls)),
    url(r'api/docs/', include_docs_urls(title='Music room'))
]
