from django.core.management.base import BaseCommand
from main.models import *
from django.contrib.auth import get_user_model


class Command(BaseCommand):
    def handle(self, *args, **options):
        User = get_user_model()

        user = User.objects.create(email='oneemail', username='onename')

        playlist = Playlist.objects.create(name='testplaylist')
        playlist.owners.add(user)

        user = User.objects.create(email='twoemail', username='twoname')

        track_1 = Track.objects.create(playlist=playlist, order=1, creator=user)
        track_2 = Track.objects.create(playlist=playlist, order=2, creator=user)
        track_3 = Track.objects.create(playlist=playlist, order=3, creator=user)
