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

# to make https requests from /docs & /swagger instead of http
# https://docs.djangoproject.com/en/1.11/ref/settings/#secure-proxy-ssl-header
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

# from sentry_sdk.integrations.django import DjangoIntegration
# from sentry_sdk.integrations.celery import CeleryIntegration
# from sentry_sdk.integrations.logging import SentryHandler

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
        },
        # 'sentry': {
        #     'level': 'DEBUG',
        #     'class': 'SentryHandler',
        # },
    },
    'loggers': {
        'main': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False
        },
    },
}

REDIS_HOST = 'redis'

CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels_redis.core.RedisChannelLayer',
        'CONFIG': {
            "hosts": [(REDIS_HOST, REDIS_PORT)],
        },
    },
}
