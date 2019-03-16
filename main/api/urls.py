from django.urls import path, include
from .viewsets import UserViewSet, PlaylistViewSet, TrackViewSet, VoteViewSet, FacebookLogin, GoogleLogin, callback_url, \
    login_url
from rest_framework.routers import DefaultRouter
from django.conf.urls import url
# from rest_framework.documentation import include_docs_urls
# from rest_framework.schemas import get_schema_view

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

from rest_framework_jwt.views import obtain_jwt_token
from rest_framework_jwt.views import refresh_jwt_token

# swagger docs
from rest_framework_swagger.views import get_swagger_view

schema_view = get_swagger_view(title='Pastebin API')

urlpatterns = [
    url(r'^$', schema_view),
    path('api/', include(router.urls)),

    # url(r'^docs/', include_docs_urls(title='Music room')),
    # https://www.django-rest-framework.org/api-guide/schemas/
    # url(r'^schema/$', get_schema_view(title='Music room')),

    # url(r'^api/token/$', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    # url(r'^api/token/refresh/$', TokenRefreshView.as_view(), name='token_refresh'),

    # url(r'^api/login/', include('rest_social_auth.urls_token')),
    # url(r'^api/login/', include('rest_social_auth.urls_jwt'))
    # url(r'^api/login/', include('rest_social_auth.urls_knox')),

    url(r'^auth/', include('rest_auth.urls')),
    url(r'^auth/registration/', include('rest_auth.registration.urls')),
    url(r'^auth/facebook/$', FacebookLogin.as_view(), name='fb_login'),
    url(r'^auth/google/$', GoogleLogin.as_view(), name='gg_login'),
    path('auth/google/callback/', callback_url),
    path('auth/google/url/', login_url),
    url(r'^auth/token/', obtain_jwt_token),
    url(r'^auth/token-refresh/', refresh_jwt_token),
    url(
        r'^auth/socialaccounts/$',
        SocialAccountListView.as_view(),
        name='social_account_list'
    ),
    url(
        r'^auth/socialaccounts/(?P<pk>\d+)/disconnect/$',
        SocialAccountDisconnectView.as_view(),
        name='social_account_disconnect'
    ),

    # url(r'^accounts/', include('allauth.urls')),
]
