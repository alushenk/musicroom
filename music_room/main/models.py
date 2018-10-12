from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from music_room import settings


class UserManager(BaseUserManager):
    def create_user(self, email, password=None):
        """
        Creates and saves a User with the given email
        """
        if not email:
            raise ValueError('Users must have an email address')

        user = self.model(
            email=self.normalize_email(email),
        )

        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password):
        """
        Creates and saves a superuser with the given email
        """
        user = self.create_user(
            email,
            password=password,
        )
        user.is_staff = True
        user.save(using=self._db)
        return user


class User(AbstractBaseUser):
    """
    (public) - чтобы его могли искать админы плэйлистов для добавления в participants
    - login
    - email
    - pass
    (restricted)
    - playlist
    (private)
    - playlist
    - friends
    """
    email = models.EmailField(
        verbose_name='email address',
        max_length=255,
        unique=True,
    )
    is_staff = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)

    objects = UserManager()

    USERNAME_FIELD = 'email'

    class Meta:
        managed = True
        db_table = 'user'


class Playlist(models.Model):
    """
    это точно модель в нашей базе

    возможно эта модель будет дополнять полями и
    функционалом плейлист реального Deezer юзера

    типа, создавая плейлист у нас он создается и в Deezer
    добавляя трек сюда он добавляется и в Deezer

    может там даже есть настройки видимости и прочая поебень

    но всё равно придётся создать свою модель плейлиста,
    так как привязка Deezer аккаунта к нашему приложению
    не обязательна
    """
    is_public = models.BooleanField(default=True)
    # хуй знает в каком виде его хранить GPS координаты
    place = None
    time_from = models.DateTimeField(blank=True, null=True)
    time_to = models.DateTimeField(blank=True, null=True)
    # те кто заинвайчен в плэйлист
    # могут:
    # найти плэйлист в поиске
    # голосовать за трек (перенести в трек)
    # добавлять треки
    # перетаскивать треки
    # нажимать кнопку play
    participants = models.ManyToManyField('User', db_table='playlist_participant', related_name='participate_playlists')
    # те кто создали плэйлист
    # могут:
    # удалять треки
    # удалить плейлист
    # переименовывать плейлист
    # выставлять время и место
    # инвайтить новых юзеров (participants)
    owner = models.ForeignKey('User', null=True, related_name='own_playlists', on_delete=models.SET_NULL)

    class Meta:
        managed = True
        db_table = 'playlist'

    def add_track(self, link):
        """
        добавить новый трек в конец плейлиста

        могут все юзеры если self.is_public == True
        :return:
        """
        available_tracks_count = len(self.tracks.all())
        track = Track(link=link, playlist=self, order=available_tracks_count)
        track.save()

    def play(self):
        """
        начинает проигрывать треки отсортированные по Votes
        :return:
        """
        pass


class Track(models.Model):
    """
    существует только в контексте плэйлиста
    можно ещё сделать страничку "мои треки" у юзера и добавлять их туда
    но не думаю что туда надо прикреплять всё что юзер советует в плэйлисты

    """
    playlist = models.ForeignKey(Playlist, on_delete=models.CASCADE, blank=True, null=True, related_name='tracks')
    # при перетягивании треков юзер будет отправлять одним махом сразу все order'ы
    # всех треков в плэйлисте
    order = models.SmallIntegerField()
    # ссылка на трек в deezer api
    # хуй знает в каком формате хранить
    # возможно домен и часть url будет браться из конфига, а здесь только id
    link = None
    # это поле будет инкрементиться или дикрементиться
    # юзер не может поставить больше одного лайка, поэтому надо где-то хранить лайкнутые треки
    # https://docs.djangoproject.com/en/2.0/ref/models/expressions/#f-expressions
    # from django.db.models import F
    # Statement.objects.filter(id__in=statements).update(vote=F('vote') + 1)
    # vote = models.IntegerField(blank=True, null=True)

    # все остальные поля можно сделать тупо геттерами, которые будут обращаться
    # к дизеру и брать от туда данные
    # можно прописать здесь или в сериализаторе логику которая разом достаёт все поля
    # или оставить эту работу клиентам

    class Meta:
        managed = True
        db_table = 'track'

    def to_vote(self, track):
        """
        добавить голос к определенному треку в плэйлисте

        могут все если self.playlist.is_public == True
        :return:
        """
        vote = Vote(track=track)
        vote.save()

    def remove(self):
        pass


class Vote(models.Model):
    """
    Влияет только на порядок проигрывания треков. Типа, на плейлисте
    есть кнопка Play(). Треки сортируются по лайкам и начинают играть, не зависимо от
    их порядка в плейлисте.
    """
    track = models.ForeignKey(Track, on_delete=models.CASCADE, blank=True, null=True, related_name='votes')
    user = models.ForeignKey(User, on_delete=models.CASCADE, blank=True, null=True, related_name='votes')

    class Meta:
        managed = True
        db_table = 'vote'
