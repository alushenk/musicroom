from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_swagger.views import get_swagger_view
from rest_auth.registration.views import (
    SocialAccountListView,
    SocialAccountDisconnectView,
    RegisterView,
    LoginView
)
from rest_auth.views import (
    UserDetailsView,
    PasswordChangeView,
    PasswordResetView,
)
from allauth.account.views import ConfirmEmailView
from django.contrib.auth.views import PasswordResetConfirmView as ResCon
from . import viewsets

schema_view = get_swagger_view(title='MusicRoom API')

# In the latest DRF, you need to explicitly set base_name in your viewset url if you don't have queryset defined.
router = DefaultRouter()
router.register('users', viewsets.UserViewSet)
router.register('playlists', viewsets.PlaylistViewSet, base_name='Playlist')
router.register('tracks', viewsets.TrackViewSet, base_name='Track')

urlpatterns = [
    path('api/playlists/<int:pk>/users/<int:user_id>/', viewsets.UnfollowView.as_view(), name='del-user-from-playlist'),
    path('api/users/<int:user_id>/playlists/', viewsets.MyPlaylistsView.as_view(), name='get-my-playlists'),
    path('api/playlists/<int:pk>/participants/<int:user_id>/', viewsets.AddParticipantToPlaylistView.as_view(),
         name='add-participant-to-playlist'),
    path('api/playlists/<int:pk>/owners/<int:user_id>/', viewsets.AddOwnerToPlaylistView.as_view(),
         name='add-owner-to-playlist'),
    path('api/votes/<int:track_id>/', viewsets.VoteView.as_view(), name='vote'),

    path('management/channel.html', viewsets.channel),
    path('management/email_redirect', viewsets.email_redirect),
    path('management/clear-data', viewsets.clear_data),
    path('management/fill-data', viewsets.fill_data),
    path('management/test-socket', viewsets.test_socket),
    # path('management/search/<str:name>', viewsets.search),
    path('management/account-email-verification-sent', viewsets.email_verification_sent,
         name='account_email_verification_sent'),

    path('swagger/', schema_view),
    path('api/', include(router.urls)),

    # URLs that do not require a session or valid token
    path('auth/password/reset/', PasswordResetView.as_view(), name='password_reset'),
    path('auth/password-reset/confirm/<str:uidb64>/<str:token>/', ResCon.as_view(), name='password_reset_confirm'),
    path('auth/password-reset/complete/', viewsets.password_reset_complete, name='password_reset_complete'),

    # URLs that require a user to be logged in with a valid session / token.
    path('auth/user/', UserDetailsView.as_view(), name='user_details'),
    path('auth/password/change/', PasswordChangeView.as_view(), name='password_change'),

    # same as rest_auth.views, but with
    path('auth/registration/', RegisterView.as_view(), name='register'),
    path('auth/login/', LoginView.as_view(), name='login'),

    # This url is used by django-allauth and empty TemplateView is
    # defined just to allow reverse() call inside app, for example when email
    # with verification link is being sent, then it's required to render email
    # content.

    # account_confirm_email - You should override this view to handle it in
    # your API client somehow and then, send post to /verify-email/ endpoint
    # with proper key.
    # If you don't want to use API on that step, then just use ConfirmEmailView
    # view from:
    # django-allauth https://github.com/pennersr/django-allauth/blob/master/allauth/account/views.py
    path('auth/account-confirm-email/<str:key>/', ConfirmEmailView.as_view(), name='account_confirm_email'),
    path('auth/socialaccounts/', SocialAccountListView.as_view(), name='social_account_list'),
    path('auth/socialaccounts/<int:pk>/disconnect/', SocialAccountDisconnectView.as_view(),
         name='social_account_disconnect'),
    path('auth/google/', viewsets.GoogleLogin.as_view(), name='gg_login'),

    # my custom views. probably not working and is not used by clients
    path('auth/google/callback/', viewsets.google_callback),
    path('auth/google/url/', viewsets.google_url),
]
