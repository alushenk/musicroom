from django.urls import path, include
from .viewsets import UserViewSet, PlaylistViewSet, TrackViewSet, VoteViewSet
from rest_framework.routers import DefaultRouter
from django.conf.urls import url
from rest_framework.documentation import include_docs_urls
from rest_framework.schemas import get_schema_view
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)

router = DefaultRouter()
router.register('users', UserViewSet)
router.register('playlists', PlaylistViewSet)
router.register('tracks', TrackViewSet)
router.register('votes', VoteViewSet)

urlpatterns = [
    path('api/', include(router.urls)),
    url(r'^docs/', include_docs_urls(title='Music room')),
    url(r'^schema/$', get_schema_view(title='Music room')),
    url(r'^api/token/$', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    url(r'^api/token/refresh/$', TokenRefreshView.as_view(), name='token_refresh'),
]
