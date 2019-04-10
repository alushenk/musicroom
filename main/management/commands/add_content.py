from django.core.management.base import BaseCommand
from django.contrib.sites.models import Site
from allauth.socialaccount.models import SocialApp, SocialAccount
from django.contrib.sites.models import Site
from main.models import *
from django.contrib.auth import get_user_model


class Command(BaseCommand):
    def handle(self, *args, **options):
        # add superuser
        # u = User(username='a', email='a@a.com')
        # u.set_password('a')
        # u.is_superuser = True
        # u.is_staff = True
        # u.save()

        User = get_user_model()
        user = User.objects.create_superuser(email='a@a.com', username='a', password='a')

        # add social app

        sapp = SocialApp(provider='google', name='google app',
                         client_id='205782653310-fjjullvs7cklq6su4qp0o7e8def79vfg.apps.googleusercontent.com',
                         secret='sMv5Xrje1aP_f__HS3g3Jt2B')

        site = Site.objects.get()
        site.domain = 'musicroom.ml'
        site.name = 'musicroom'
        site.save()

        sapp.save()
        sapp.sites.add(site)  # or your site id

        # add social account

        # sacc = SocialAccount(uid="<your facebook uid>", user=user, provider='facebook')
        # sacc.save()

        # ----------------------------------------------------------------------------------------------------

        user = User.objects.get(email='a@a.com')

        playlist = Playlist.objects.create(is_public=True, name='public playlist of user a', creator=user)
        playlist.owners.add(user)

        track_1 = Track.objects.create(playlist=playlist, order=1, creator=user)
        track_2 = Track.objects.create(playlist=playlist, order=2, creator=user)
        track_3 = Track.objects.create(playlist=playlist, order=3, creator=user)

        playlist = Playlist.objects.create(is_public=True, name='private playlist of user b', creator=user)
        playlist.owners.add(user)

        track_1 = Track.objects.create(playlist=playlist, order=1, creator=user)
        track_2 = Track.objects.create(playlist=playlist, order=2, creator=user)
        track_3 = Track.objects.create(playlist=playlist, order=3, creator=user)

        # ----------------------------------------------------------------------------------------------------

        user = User.objects.create(email='b@b.com', username='b', password='b')

        playlist = Playlist.objects.create(is_public=True, name='public playlist of user b', creator=user)
        playlist.owners.add(user)

        track_1 = Track.objects.create(playlist=playlist, order=1, creator=user)
        track_2 = Track.objects.create(playlist=playlist, order=2, creator=user)
        track_3 = Track.objects.create(playlist=playlist, order=3, creator=user)

        playlist = Playlist.objects.create(is_public=True, name='private playlist of user b', creator=user)
        playlist.owners.add(user)

        track_1 = Track.objects.create(playlist=playlist, order=1, creator=user)
        track_2 = Track.objects.create(playlist=playlist, order=2, creator=user)
        track_3 = Track.objects.create(playlist=playlist, order=3, creator=user)
