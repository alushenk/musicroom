from django.core.management.base import BaseCommand
from django.contrib.sites.models import Site
from allauth.socialaccount.models import SocialApp, SocialAccount
from django.contrib.sites.models import Site
from main.models import User
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
        User.objects.create_superuser('a@a.com', 'a', 'a')

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
