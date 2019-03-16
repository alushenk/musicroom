from .base import *

# ------------------------------ REDIS -------------------------------------------- #
REDIS_HOST = 'localhost'
REDIS_PORT = '6379'
CELERY_BROKER_URL = 'redis://' + REDIS_HOST + ':' + REDIS_PORT

# -------------------------------- DATABASE --------------------------------------- #
# https://docs.djangoproject.com/en/2.1/ref/settings/#databases

DATABASES = {
    'default': {'ENGINE': 'django.db.backends.postgresql',
                'NAME': 'postgres',
                'USER': 'postgres',
                'PASSWORD': None,
                'HOST': 'localhost',
                'PORT': '5432'}
}