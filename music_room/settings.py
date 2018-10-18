"""
Django settings for music_room project.

Generated by 'django-admin startproject' using Django 2.1.1.

For more information on this file, see
https://docs.djangoproject.com/en/2.1/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/2.1/ref/settings/
"""

import os

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/2.1/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = '#en_*w34c(tw__3!-_@n(_!fw#p&5a59r-#k-)@q*h8eg12oje'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

ALLOWED_HOSTS = ['localhost',
                 '127.0.0.1',
                 'ec2-54-93-227-166.eu-central-1.compute.amazonaws.com']

# Application definition

INSTALLED_APPS = [
    'django.contrib.admin',

    'django.contrib.auth',
    'django.contrib.messages',
    'django.contrib.sites',
    'django.contrib.contenttypes',
    # для авторизации в админке
    'django.contrib.sessions',
    'django.contrib.staticfiles',

    # pip install django-cors-headers
    # https://github.com/ottoyiu/django-cors-headers
    # чтобы при логине через сессию (который не нужен ибо делаем JWT)
    # не было ошибки "CSRF Failed: CSRF token missing or incorrect"
    # нужен для админки
    'corsheaders',

    'rest_framework',
    'rest_framework.authtoken',  # only if you use token authentication
    # 'social_django',  # django social auth
    # 'rest_social_auth',  # this package
    # 'knox',  # Only if you use django-rest-knox

    # 'oauth2_provider',
    # 'rest_framework_social_oauth2',

    'rest_auth',
    'rest_auth.registration',

    'allauth',
    'allauth.account',
    'allauth.socialaccount',
    'allauth.socialaccount.providers.facebook',
    'allauth.socialaccount.providers.google',

    'main',
]

SITE_ID = 1

# SOCIAL_AUTH_RAISE_EXCEPTIONS = True
# SOCIAL_AUTH_URL_NAMESPACE = 'social'
#
# SOCIAL_AUTH_GOOGLE_OAUTH2_KEY = '205782653310-fjjullvs7cklq6su4qp0o7e8def79vfg.apps.googleusercontent.com'
# SOCIAL_AUTH_GOOGLE_OAUTH2_SECRET = 'sMv5Xrje1aP_f__HS3g3Jt2B'
# SOCIAL_AUTH_GOOGLE_OAUTH2_FIELDS = ['email', 'username']  # optional
#
# SOCIAL_AUTH_FACEBOOK_KEY = 'your app client id'
# SOCIAL_AUTH_FACEBOOK_SECRET = 'your app client secret'

# CSRF_COOKIE_SECURE = True
# CORS_ORIGIN_ALLOW_ALL = True

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'music_room.urls'

TEMPLATES = [
    # {
    #     'BACKEND': 'django.template.backends.django.DjangoTemplates',
    #     'DIRS': [],
    #     'APP_DIRS': True,
    #     'OPTIONS': {
    #         'context_processors': [
    #             'django.template.context_processors.debug',
    #             'django.template.context_processors.request',
    #             'django.contrib.auth.context_processors.auth',
    #             'django.contrib.messages.context_processors.messages',
    #         ],
    #     },
    # },
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                # Already defined Django-related contexts here
                'django.contrib.auth.context_processors.auth',

                # `allauth` needs this from django
                'django.template.context_processors.request',
            ],
        },
    }
]

AUTHENTICATION_BACKENDS = (
    # 'social_core.backends.facebook.FacebookOAuth2',
    # 'social_core.backends.google.GoogleOAuth2',
    # 'rest_framework_social_oauth2.backends.DjangoOAuth2',
    # 'django.contrib.auth.backends.ModelBackend',

    # Needed to login by username in Django admin, regardless of `allauth`
    'django.contrib.auth.backends.ModelBackend',

    # `allauth` specific authentication methods, such as login by e-mail
    'allauth.account.auth_backends.AuthenticationBackend',
)

WSGI_APPLICATION = 'music_room.wsgi.application'

# Database
# https://docs.djangoproject.com/en/2.1/ref/settings/#databases

DATABASES = {
    'default': {'ENGINE': 'django.db.backends.postgresql',
                'NAME': 'postgres',
                'USER': 'postgres',
                'PASSWORD': None,
                'HOST': 'localhost',
                'PORT': '5432'}
}

# Password validation
# https://docs.djangoproject.com/en/2.1/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization
# https://docs.djangoproject.com/en/2.1/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True

# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/2.1/howto/static-files/

STATIC_URL = '/static/'

REST_FRAMEWORK = {
    # 'DEFAULT_AUTHENTICATION_CLASSES': (
    #     'rest_framework_simplejwt.authentication.JWTAuthentication',
    # ),
    # 'DEFAULT_AUTHENTICATION_CLASSES': ('knox.auth.TokenAuthentication',),
}

# from datetime import timedelta
#
# REST_KNOX = {
#     'SECURE_HASH_ALGORITHM': 'cryptography.hazmat.primitives.hashes.SHA512',
#     'AUTH_TOKEN_CHARACTER_LENGTH': 64,
#     'TOKEN_TTL': timedelta(hours=10),
#     # 'USER_SERIALIZER': 'knox.serializers.UserSerializer',
#     'USER_SERIALIZER': 'main.serializers.UserSerializer',
# }

# from datetime import timedelta
#
# SIMPLE_JWT = {
#     'ACCESS_TOKEN_LIFETIME': timedelta(days=365),
#     'REFRESH_TOKEN_LIFETIME': timedelta(days=1),
#     'ROTATE_REFRESH_TOKENS': True,
#     'BLACKLIST_AFTER_ROTATION': True,
#
#     'ALGORITHM': 'HS256',
#     'SIGNING_KEY': SECRET_KEY,
#     'VERIFYING_KEY': None,
#
#     'AUTH_HEADER_TYPES': ('Bearer',),
#     'USER_ID_FIELD': 'id',
#     'USER_ID_CLAIM': 'user_id',
#
#     'AUTH_TOKEN_CLASSES': ('rest_framework_simplejwt.tokens.AccessToken',),
#     'TOKEN_TYPE_CLAIM': 'token_type',
#
#     'SLIDING_TOKEN_REFRESH_EXP_CLAIM': 'refresh_exp',
#     'SLIDING_TOKEN_LIFETIME': timedelta(minutes=5),
#     'SLIDING_TOKEN_REFRESH_LIFETIME': timedelta(days=1),
# }

AUTH_USER_MODEL = 'main.User'

# GOOGLE_CLIENT_ID = '205782653310-fjjullvs7cklq6su4qp0o7e8def79vfg.apps.googleusercontent.com'
# GOOGLE_CLIENT_SECRET = 'sMv5Xrje1aP_f__HS3g3Jt2B'
