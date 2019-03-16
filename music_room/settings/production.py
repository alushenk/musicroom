from .base import *

# ------------------------------ REDIS -------------------------------------------- #
REDIS_HOST = 'redis'
REDIS_PORT = '6379'
CELERY_BROKER_URL = 'redis://' + REDIS_HOST + ':' + REDIS_PORT

# ---------------------- SENTRY - ERRORS NOTIFICATION ----------------------------- #
import sentry_sdk
from sentry_sdk.integrations.django import DjangoIntegration
from sentry_sdk.integrations.celery import CeleryIntegration

sentry_sdk.init(
    dsn="https://082365428e214c5597cab503c380586c@sentry.io/1412660",
    integrations=[DjangoIntegration(), CeleryIntegration()]
)

# -------------------------------- DATABASE --------------------------------------- #
# https://docs.djangoproject.com/en/2.1/ref/settings/#databases

DATABASES = {
    'default': {'ENGINE': 'django.db.backends.postgresql',
                'NAME': 'postgres',
                'USER': 'postgres',
                'PASSWORD': None,
                'HOST': 'db',
                'PORT': '5432'}
}
