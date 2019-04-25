from django.contrib import admin

# Register your models here.
from .models import Playlist, Track, Vote

admin.site.register(Playlist)
admin.site.register(Track)
admin.site.register(Vote)
