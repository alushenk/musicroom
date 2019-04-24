from django.apps import AppConfig
from django.utils.translation import ugettext_lazy as _


class MainConfig(AppConfig):
    # name = 'channels_shit.chan'
    name = 'main'
    verbose_name = _('main')

    def ready(self):
        import main.callbacks
