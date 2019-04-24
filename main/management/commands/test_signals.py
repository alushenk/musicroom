from django.core.management.base import BaseCommand
from django.contrib.sites.models import Site
from allauth.socialaccount.models import SocialApp, SocialAccount
from django.contrib.sites.models import Site
from main.models import *
from django.contrib.auth import get_user_model


class Command(BaseCommand):
    def handle(self, *args, **options):
        User = get_user_model()

        # user = User.objects.get(email='a@a.com')
        user = User.objects.create(email='suka', username='suka')

        playlist = Playlist.objects.create(name='zalupa')
        playlist.owners.add(user)

        user = User.objects.create(email='blyad', username='blyad')

        track_1 = Track.objects.create(playlist=playlist, order=1, creator=user)
        track_2 = Track.objects.create(playlist=playlist, order=2, creator=user)
        track_3 = Track.objects.create(playlist=playlist, order=3, creator=user)
