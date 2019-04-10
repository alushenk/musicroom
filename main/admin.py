from django.contrib import admin

# Register your models here.
from .models import Playlist, Track, User

admin.site.register(Playlist)
admin.site.register(Track)
admin.site.register(User)
