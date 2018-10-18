from django.urls import path, include
from .viewsets import UserViewSet, PlaylistViewSet, TrackViewSet, VoteViewSet, FacebookLogin, GoogleLogin
from rest_framework.routers import DefaultRouter
from django.conf.urls import url
from rest_framework.documentation import include_docs_urls
from rest_framework.schemas import get_schema_view

# from rest_framework_simplejwt.views import (
#     TokenObtainPairView,
#     TokenRefreshView,
#     TokenVerifyView,
# )

router = DefaultRouter()
router.register('users', UserViewSet)
router.register('playlists', PlaylistViewSet)
router.register('tracks', TrackViewSet)
router.register('votes', VoteViewSet)

from rest_auth.registration.views import (
    SocialAccountListView, SocialAccountDisconnectView
)

urlpatterns = [
    path('api/', include(router.urls)),
    url(r'^docs/', include_docs_urls(title='Music room')),
    url(r'^schema/$', get_schema_view(title='Music room')),
    # url(r'^api/token/$', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    # url(r'^api/token/refresh/$', TokenRefreshView.as_view(), name='token_refresh'),

    # url(r'^api/login/', include('rest_social_auth.urls_token')),
    # url(r'^api/login/', include('rest_social_auth.urls_jwt'))
    # url(r'^api/login/', include('rest_social_auth.urls_knox')),

    url(r'^rest-auth/', include('rest_auth.urls')),
    url(r'^rest-auth/registration/', include('rest_auth.registration.urls')),
    url(r'^rest-auth/facebook/$', FacebookLogin.as_view(), name='fb_login'),
    url(r'^rest-auth/google/$', GoogleLogin.as_view(), name='gg_login'),
    url(
        r'^socialaccounts/$',
        SocialAccountListView.as_view(),
        name='social_account_list'
    ),
    url(
        r'^socialaccounts/(?P<pk>\d+)/disconnect/$',
        SocialAccountDisconnectView.as_view(),
        name='social_account_disconnect'
    )
]
