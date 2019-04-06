from django.core.mail import send_mail
from django.conf import settings
from django.core.management.base import BaseCommand
from django.shortcuts import redirect


def test_email():
    subject = 'Thank you for registering to our site'
    message = ' it  means a world to us '
    email_from = settings.EMAIL_HOST_USER
    recipient_list = ['zadruser@gmail.com', ]
    send_mail(subject, message, email_from, recipient_list)
    # return redirect('redirect to a new page')


class Command(BaseCommand):
    def handle(self, *args, **options):
        test_email()
