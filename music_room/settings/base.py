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
SECRET_KEY = os.getenv('SECRET_KEY')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

ALLOWED_HOSTS = ['localhost',
                 '127.0.0.1',
                 'ec2-54-93-227-166.eu-central-1.compute.amazonaws.com',
                 'musicroom.ml',
                 'localhost:8000',
                 '172.17.0.1',
                 'localhost:3000',
                 'http://localhost:3000', ]

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

    'main',

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

    # https://www.caktusgroup.com/blog/2014/11/10/Using-Amazon-S3-to-store-your-Django-sites-static-and-media-files/
    'storages',

    # https://django-rest-swagger.readthedocs.io/en/latest/
    'rest_framework_swagger',

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

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    # 'corsheaders.middleware.CorsPostCsrfMiddleware'
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    # 'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'main.disable_csrf.DisableCSRF',
]

CORS_ORIGIN_ALLOW_ALL = True

# CORS_ORIGIN_WHITELIST = (
#     'musicroom.ml',
#     'localhost:8000',
#     '127.0.0.1:8000'
# )

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
        # 'DIRS': [os.path.join(os.path.dirname(BASE_DIR), 'main/templates')],
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                # Already defined Django-related contexts here
                'django.contrib.auth.context_processors.auth',

                # `allauth` needs this from django
                'django.template.context_processors.request',

                # because of error:
                # 'django.contrib.messages.context_processors.messages' must be enabled in
                # DjangoTemplates (TEMPLATES) in order to use the admin application.
                'django.template.context_processors.debug',
                'django.contrib.messages.context_processors.messages',
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

REST_FRAMEWORK = {
    # если это оставить, то не будет пускать к докам так как я не авторизован
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',
    ),
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_jwt.authentication.JSONWebTokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework.authentication.BasicAuthentication',
    ),
    'TEST_REQUEST_DEFAULT_FORMAT': 'json',
}

REST_USE_JWT = True
REST_SESSION_LOGIN = True

JWT_AUTH = {
    'JWT_ENCODE_HANDLER':
        'rest_framework_jwt.utils.jwt_encode_handler',

    'JWT_DECODE_HANDLER':
        'rest_framework_jwt.utils.jwt_decode_handler',

    'JWT_PAYLOAD_HANDLER':
        'rest_framework_jwt.utils.jwt_payload_handler',

    'JWT_PAYLOAD_GET_USER_ID_HANDLER':
        'rest_framework_jwt.utils.jwt_get_user_id_from_payload_handler',

    'JWT_RESPONSE_PAYLOAD_HANDLER':
        'rest_framework_jwt.utils.jwt_response_payload_handler',

    'JWT_SECRET_KEY': SECRET_KEY,
    'JWT_GET_USER_SECRET_KEY': None,
    'JWT_PUBLIC_KEY': None,
    'JWT_PRIVATE_KEY': None,
    'JWT_ALGORITHM': 'HS256',
    'JWT_VERIFY': True,
    # turn off expiration; tokens will live forever)
    'JWT_VERIFY_EXPIRATION': False,
    # 'JWT_LEEWAY': 0,
    # 'JWT_EXPIRATION_DELTA': timedelta(days=1),
    # 'JWT_AUDIENCE': None,
    # 'JWT_ISSUER': None,
    # todo try it out
    # 'JWT_ALLOW_REFRESH': False,
    # 'JWT_REFRESH_EXPIRATION_DELTA': timedelta(days=7),

    'JWT_AUTH_HEADER_PREFIX': 'JWT',
    'JWT_AUTH_COOKIE': None,
}

LOGIN_REDIRECT_URL = '/rest-auth/login/'

# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/2.1/howto/static-files/

STATIC_URL = '/static/'
PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))
# STATIC_ROOT = '/home/django/django_project/django_project/static'
STATIC_ROOT = os.path.join(PROJECT_ROOT, 'static')

STATICFILES_DIRS = (
    os.path.join(BASE_DIR, 'static'),
)

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        #     'gelf': {
        #         'level': 'DEBUG',
        #         'class': 'graypy.GELFUDPHandler',
        #         'host': 'localhost',
        #         'port': 12201,
        #     },
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
        },
        # 'sentry': {
        #     'level': 'DEBUG',
        #     'class': 'sentry_sdk.integrations.logging.SentryHandler',
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

# SECURE_SSL_REDIRECT = True
# SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = False

# ------------------------------ S3 STATIC FILES -------------------------------- #
AWS_STORAGE_BUCKET_NAME = 'musicroom-bucket'
# AWS_S3_REGION_NAME = 'eu-central-1'  # e.g. us-east-2
AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')

# Tell django-storages the domain to use to refer to static files.
AWS_S3_CUSTOM_DOMAIN = '%s.s3.amazonaws.com' % AWS_STORAGE_BUCKET_NAME

# Tell the staticfiles app to use S3Boto3 storage when writing the collected static files (when
# you run `collectstatic`).
STATICFILES_LOCATION = 'static'
# STATICFILES_STORAGE = 'custom_storages.StaticStorage'
STATICFILES_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'

DOMAIN = 'musicroom.ml'

# to user token auth in swagger
SWAGGER_SETTINGS = {
    'USE_SESSION_AUTH': False,
    'SECURITY_DEFINITIONS': {
        'apiKey': {
            'type': 'apiKey',
            'description': 'Personal JWT Token',
            'name': 'Authorization',
            'in': 'header',
        }
    }
}

# Email configuration
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_USE_TLS = True
EMAIL_PORT = 587
EMAIL_HOST_USER = 'lush.antony@gmail.com'
DEFAULT_FROM_EMAIL = EMAIL_HOST_USER
EMAIL_HOST_PASSWORD = os.getenv('EMAIL_HOST_PASSWORD')

# rest_auth + allauth
EMAIL_REQUIRED = True
ACCOUNT_CONFIRM_EMAIL_ON_GET = True
ACCOUNT_AUTHENTICATED_LOGIN_REDIRECTS = False
ACCOUNT_EMAIL_CONFIRMATION_ANONYMOUS_REDIRECT_URL = 'https://musicroom.ml/management/email_redirect'
ACCOUNT_EMAIL_CONFIRMATION_AUTHENTICATED_REDIRECT_URL = ACCOUNT_EMAIL_CONFIRMATION_ANONYMOUS_REDIRECT_URL

ACCOUNT_USERNAME_REQUIRED = False
ACCOUNT_AUTHENTICATION_METHOD = 'email'
ACCOUNT_EMAIL_REQUIRED = True

# AUTH_USER_MODEL = 'auth.User'

# ACCOUNT_EMAIL_VERIFICATION = "none"
ACCOUNT_EMAIL_VERIFICATION = "mandatory"
