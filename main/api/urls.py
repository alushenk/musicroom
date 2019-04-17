from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_jwt.views import obtain_jwt_token
from rest_framework_swagger.views import get_swagger_view
from django.views.generic import TemplateView
from rest_auth.registration.views import (
    SocialAccountListView,
    SocialAccountDisconnectView,
    RegisterView,
    VerifyEmailView
)
from rest_auth.views import (
    UserDetailsView,
    PasswordChangeView,
    PasswordResetView,
    PasswordResetConfirmView
)
from . import viewsets

from allauth.account.views import ConfirmEmailView

schema_view = get_swagger_view(title='MusicRoom API')

# In the latest DRF, you need to explicitly set base_name in your viewset url if you don't have queryset defined.
router = DefaultRouter()
# router.register('users', viewsets.UserViewSet, base_name='User')
router.register('users', viewsets.UserViewSet)
router.register('playlists', viewsets.PlaylistViewSet, base_name='Playlist')
router.register('tracks', viewsets.TrackViewSet, base_name='Track')
router.register('votes', viewsets.VoteViewSet, base_name='Vote')

urlpatterns = [
    path('management/channel.html', viewsets.channel),
    path('management/email_redirect', viewsets.email_redirect),
    path('management/clear-data', viewsets.clear_data),
    path('management/fill-data', viewsets.fill_data),

    path('swagger/', schema_view),
    path('api/', include(router.urls)),

    # URLs that do not require a session or valid token
    # instead of importing all from url(r'^auth/', include('rest_auth.urls')) I added it manually
    path('auth/password/reset/', PasswordResetView.as_view(), name='rest_password_reset'),
    path('auth/password/reset/confirm/', PasswordResetConfirmView.as_view(), name='rest_password_reset_confirm'),

    # URLs that require a user to be logged in with a valid session / token.
    path('auth/user/', UserDetailsView.as_view(), name='rest_user_details'),
    path('auth/password/change/', PasswordChangeView.as_view(), name='rest_password_change'),

    # same shit as rest_auth.views, but with
    path('auth/registration/', RegisterView.as_view(), name='rest_register'),

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
    # todo как я понял это стандартная вьюха для имейла из джанги которую можно переопределить
    path('auth/account-confirm-email/<str:key>/', ConfirmEmailView.as_view(), name='account_confirm_email'),

    # используется на случай если потеряли токен
    path('auth/token/', obtain_jwt_token),

    path('auth/socialaccounts/', SocialAccountListView.as_view(), name='social_account_list'),
    path('auth/socialaccounts/<int:pk>/disconnect/', SocialAccountDisconnectView.as_view(),
         name='social_account_disconnect'),

    path('auth/facebook/', viewsets.FacebookLogin.as_view(), name='fb_login'),
    path('auth/google/', viewsets.GoogleLogin.as_view(), name='gg_login'),

    # todo вот это вот моя дичь которую надо потестить и допилить
    path('auth/google/callback/', viewsets.callback_url),
    path('auth/google/url/', viewsets.login_url),

    # todo проверить эту хуйню и добавить если надо
    #  если /auth/socialaccounts/ не делает то же самое или даже больше
    #  я думаю оно использует эту хуйню под капотом так что ее не надо импортить
    # url(r'^accounts/', include('allauth.urls')),
]
