from django.core.management.base import BaseCommand
from allauth.socialaccount.models import SocialApp, SocialAccount
from django.contrib.sites.models import Site
import main.models as models
from django.contrib.auth import get_user_model
from allauth.account.models import EmailAddress

p1 = {
    "name": "Latino Music",
    "is_public": True,
    "place": {
        "lat": 50.43145858562147,
        "lon": 30.422063110351587,
        "radius": 10000
    },
    "time_from": None,
    "time_to": None,
    "participants": [
        12
    ],
    "owners": [
        3
    ],
    "tracks": [
        {
            "id": 57,
            "playlist": 38,
            "order": 4,
            "votes": [],
            "data": {
                "id": 71985299,
                "link": "https://www.deezer.com/track/71985299",
                "rank": 359094,
                "type": "track",
                "album": {
                    "id": 7071150,
                    "type": "album",
                    "cover": "https://api.deezer.com/album/7071150/image",
                    "title": "Vivir Mi Vida - The Remixes",
                    "cover_xl": "https://e-cdns-images.dzcdn.net/images/cover/0a457e91ee57ba43b046c49b3ecad516/1000x1000-000000-80-0-0.jpg",
                    "cover_big": "https://e-cdns-images.dzcdn.net/images/cover/0a457e91ee57ba43b046c49b3ecad516/500x500-000000-80-0-0.jpg",
                    "tracklist": "https://api.deezer.com/album/7071150/tracks",
                    "cover_small": "https://e-cdns-images.dzcdn.net/images/cover/0a457e91ee57ba43b046c49b3ecad516/56x56-000000-80-0-0.jpg",
                    "cover_medium": "https://e-cdns-images.dzcdn.net/images/cover/0a457e91ee57ba43b046c49b3ecad516/250x250-000000-80-0-0.jpg"
                },
                "title": "Vivir Mi Vida (Versión Pop)",
                "artist": {
                    "id": 112,
                    "link": "https://www.deezer.com/artist/112",
                    "name": "Marc Anthony",
                    "type": "artist",
                    "picture": "https://api.deezer.com/artist/112/image",
                    "tracklist": "https://api.deezer.com/artist/112/top?limit=50",
                    "picture_xl": "https://e-cdns-images.dzcdn.net/images/artist/6463c867aca11fed7ab62af094fa8fc1/1000x1000-000000-80-0-0.jpg",
                    "picture_big": "https://e-cdns-images.dzcdn.net/images/artist/6463c867aca11fed7ab62af094fa8fc1/500x500-000000-80-0-0.jpg",
                    "picture_small": "https://e-cdns-images.dzcdn.net/images/artist/6463c867aca11fed7ab62af094fa8fc1/56x56-000000-80-0-0.jpg",
                    "picture_medium": "https://e-cdns-images.dzcdn.net/images/artist/6463c867aca11fed7ab62af094fa8fc1/250x250-000000-80-0-0.jpg"
                },
                "preview": "https://cdns-preview-2.dzcdn.net/stream/c-243b60c883ac3d44ad276c7980ec6584-1.mp3",
                "duration": 230,
                "readable": True,
                "title_short": "Vivir Mi Vida",
                "title_version": "(Versión Pop)",
                "explicit_lyrics": False,
                "explicit_content_cover": 0,
                "explicit_content_lyrics": 0
            }
        },
        {
            "id": 51,
            "playlist": 38,
            "order": 1,
            "votes": [],
            "data": {
                "id": 482193902,
                "link": "https://www.deezer.com/track/482193902",
                "rank": 168931,
                "type": "track",
                "album": {
                    "id": 60568772,
                    "type": "album",
                    "cover": "https://api.deezer.com/album/60568772/image",
                    "title": "X+ (Deluxe Edition)",
                    "cover_xl": "https://e-cdns-images.dzcdn.net/images/cover/c1d34cd1c9c1df51a0c5e36c70f8e5d3/1000x1000-000000-80-0-0.jpg",
                    "cover_big": "https://e-cdns-images.dzcdn.net/images/cover/c1d34cd1c9c1df51a0c5e36c70f8e5d3/500x500-000000-80-0-0.jpg",
                    "tracklist": "https://api.deezer.com/album/60568772/tracks",
                    "cover_small": "https://e-cdns-images.dzcdn.net/images/cover/c1d34cd1c9c1df51a0c5e36c70f8e5d3/56x56-000000-80-0-0.jpg",
                    "cover_medium": "https://e-cdns-images.dzcdn.net/images/cover/c1d34cd1c9c1df51a0c5e36c70f8e5d3/250x250-000000-80-0-0.jpg"
                },
                "title": "Cántalo Conmigo",
                "artist": {
                    "id": 981289,
                    "link": "https://www.deezer.com/artist/981289",
                    "name": "Los 4",
                    "type": "artist",
                    "picture": "https://api.deezer.com/artist/981289/image",
                    "tracklist": "https://api.deezer.com/artist/981289/top?limit=50",
                    "picture_xl": "https://e-cdns-images.dzcdn.net/images/artist//1000x1000-000000-80-0-0.jpg",
                    "picture_big": "https://e-cdns-images.dzcdn.net/images/artist//500x500-000000-80-0-0.jpg",
                    "picture_small": "https://e-cdns-images.dzcdn.net/images/artist//56x56-000000-80-0-0.jpg",
                    "picture_medium": "https://e-cdns-images.dzcdn.net/images/artist//250x250-000000-80-0-0.jpg"
                },
                "preview": "https://cdns-preview-6.dzcdn.net/stream/c-63483ad689387c31cb195874f96fa96d-2.mp3",
                "duration": 247,
                "readable": True,
                "title_short": "Cántalo Conmigo",
                "title_version": "",
                "explicit_lyrics": False,
                "explicit_content_cover": 2,
                "explicit_content_lyrics": 0
            }
        },
        {
            "id": 52,
            "playlist": 38,
            "order": 2,
            "votes": [],
            "data": {
                "id": 482193762,
                "link": "https://www.deezer.com/track/482193762",
                "rank": 159081,
                "type": "track",
                "album": {
                    "id": 60568772,
                    "type": "album",
                    "cover": "https://api.deezer.com/album/60568772/image",
                    "title": "X+ (Deluxe Edition)",
                    "cover_xl": "https://e-cdns-images.dzcdn.net/images/cover/c1d34cd1c9c1df51a0c5e36c70f8e5d3/1000x1000-000000-80-0-0.jpg",
                    "cover_big": "https://e-cdns-images.dzcdn.net/images/cover/c1d34cd1c9c1df51a0c5e36c70f8e5d3/500x500-000000-80-0-0.jpg",
                    "tracklist": "https://api.deezer.com/album/60568772/tracks",
                    "cover_small": "https://e-cdns-images.dzcdn.net/images/cover/c1d34cd1c9c1df51a0c5e36c70f8e5d3/56x56-000000-80-0-0.jpg",
                    "cover_medium": "https://e-cdns-images.dzcdn.net/images/cover/c1d34cd1c9c1df51a0c5e36c70f8e5d3/250x250-000000-80-0-0.jpg"
                },
                "title": "Coge los 4",
                "artist": {
                    "id": 981289,
                    "link": "https://www.deezer.com/artist/981289",
                    "name": "Los 4",
                    "type": "artist",
                    "picture": "https://api.deezer.com/artist/981289/image",
                    "tracklist": "https://api.deezer.com/artist/981289/top?limit=50",
                    "picture_xl": "https://e-cdns-images.dzcdn.net/images/artist//1000x1000-000000-80-0-0.jpg",
                    "picture_big": "https://e-cdns-images.dzcdn.net/images/artist//500x500-000000-80-0-0.jpg",
                    "picture_small": "https://e-cdns-images.dzcdn.net/images/artist//56x56-000000-80-0-0.jpg",
                    "picture_medium": "https://e-cdns-images.dzcdn.net/images/artist//250x250-000000-80-0-0.jpg"
                },
                "preview": "https://cdns-preview-1.dzcdn.net/stream/c-135441261d1076966a250658560dff54-3.mp3",
                "duration": 209,
                "readable": True,
                "title_short": "Coge los 4",
                "title_version": "",
                "explicit_lyrics": False,
                "explicit_content_cover": 2,
                "explicit_content_lyrics": 0
            }
        },
        {
            "id": 56,
            "playlist": 38,
            "order": 3,
            "votes": [],
            "data": {
                "id": 139122605,
                "link": "https://www.deezer.com/track/139122605",
                "rank": 343634,
                "type": "track",
                "album": {
                    "id": 14952237,
                    "type": "album",
                    "cover": "https://api.deezer.com/album/14952237/image",
                    "title": "Tú",
                    "cover_xl": "https://e-cdns-images.dzcdn.net/images/cover/df8b839b97c2f149b29961cd03a90bd6/1000x1000-000000-80-0-0.jpg",
                    "cover_big": "https://e-cdns-images.dzcdn.net/images/cover/df8b839b97c2f149b29961cd03a90bd6/500x500-000000-80-0-0.jpg",
                    "tracklist": "https://api.deezer.com/album/14952237/tracks",
                    "cover_small": "https://e-cdns-images.dzcdn.net/images/cover/df8b839b97c2f149b29961cd03a90bd6/56x56-000000-80-0-0.jpg",
                    "cover_medium": "https://e-cdns-images.dzcdn.net/images/cover/df8b839b97c2f149b29961cd03a90bd6/250x250-000000-80-0-0.jpg"
                },
                "title": "Tú",
                "artist": {
                    "id": 5198338,
                    "link": "https://www.deezer.com/artist/5198338",
                    "name": "Dustin Richie",
                    "type": "artist",
                    "picture": "https://api.deezer.com/artist/5198338/image",
                    "tracklist": "https://api.deezer.com/artist/5198338/top?limit=50",
                    "picture_xl": "https://e-cdns-images.dzcdn.net/images/artist//1000x1000-000000-80-0-0.jpg",
                    "picture_big": "https://e-cdns-images.dzcdn.net/images/artist//500x500-000000-80-0-0.jpg",
                    "picture_small": "https://e-cdns-images.dzcdn.net/images/artist//56x56-000000-80-0-0.jpg",
                    "picture_medium": "https://e-cdns-images.dzcdn.net/images/artist//250x250-000000-80-0-0.jpg"
                },
                "preview": "https://cdns-preview-b.dzcdn.net/stream/c-b142e198d7b192b4c760102681362a14-4.mp3",
                "duration": 201,
                "readable": True,
                "title_short": "Tú",
                "title_version": "",
                "explicit_lyrics": False,
                "explicit_content_cover": 2,
                "explicit_content_lyrics": 0
            }
        }
    ],
    "creator": 3,
    "actions": {
        "add_participant": False,
        "retrieve": True,
        "list": False,
        "unfollow": False,
        "update": False,
        "follow": True,
        "destroy": False,
        "add_owner": False,
        "partial_update": False
    }
}

p2 = {
    "id": 8,
    "name": "Rock Music",
    "is_public": True,
    "place": {
        "lat": 50.44632763814926,
        "lon": 30.54033779907229,
        "radius": 125
    },
    "time_from": None,
    "time_to": None,
    "participants": [],
    "owners": [
        12,
        3
    ],
    "tracks": [
        {
            "id": 75,
            "playlist": 8,
            "order": 3,
            "votes": [],
            "data": {
                "id": 7419123,
                "link": "https://www.deezer.com/track/7419123",
                "rank": 718486,
                "type": "track",
                "album": {
                    "id": 684567,
                    "type": "album",
                    "cover": "https://api.deezer.com/album/684567/image",
                    "title": "Appeal To Reason",
                    "cover_xl": "https://e-cdns-images.dzcdn.net/images/cover/1a4488d4d2d378dcdcdd0dc900d867f4/1000x1000-000000-80-0-0.jpg",
                    "cover_big": "https://e-cdns-images.dzcdn.net/images/cover/1a4488d4d2d378dcdcdd0dc900d867f4/500x500-000000-80-0-0.jpg",
                    "tracklist": "https://api.deezer.com/album/684567/tracks",
                    "cover_small": "https://e-cdns-images.dzcdn.net/images/cover/1a4488d4d2d378dcdcdd0dc900d867f4/56x56-000000-80-0-0.jpg",
                    "cover_medium": "https://e-cdns-images.dzcdn.net/images/cover/1a4488d4d2d378dcdcdd0dc900d867f4/250x250-000000-80-0-0.jpg"
                },
                "title": "Savior",
                "artist": {
                    "id": 3566,
                    "link": "https://www.deezer.com/artist/3566",
                    "name": "Rise Against",
                    "type": "artist",
                    "picture": "https://api.deezer.com/artist/3566/image",
                    "tracklist": "https://api.deezer.com/artist/3566/top?limit=50",
                    "picture_xl": "https://e-cdns-images.dzcdn.net/images/artist/d8e36d7651a471afba588428e0feb021/1000x1000-000000-80-0-0.jpg",
                    "picture_big": "https://e-cdns-images.dzcdn.net/images/artist/d8e36d7651a471afba588428e0feb021/500x500-000000-80-0-0.jpg",
                    "picture_small": "https://e-cdns-images.dzcdn.net/images/artist/d8e36d7651a471afba588428e0feb021/56x56-000000-80-0-0.jpg",
                    "picture_medium": "https://e-cdns-images.dzcdn.net/images/artist/d8e36d7651a471afba588428e0feb021/250x250-000000-80-0-0.jpg"
                },
                "preview": "https://cdns-preview-5.dzcdn.net/stream/c-530d64ff1a55fa546e72368eef7f379e-4.mp3",
                "duration": 242,
                "readable": True,
                "title_short": "Savior",
                "title_version": "",
                "explicit_lyrics": False,
                "explicit_content_cover": 2,
                "explicit_content_lyrics": 0
            }
        },
        {
            "id": 76,
            "playlist": 8,
            "order": 4,
            "votes": [],
            "data": {
                "id": 1171879,
                "link": "https://www.deezer.com/track/1171879",
                "rank": 623650,
                "type": "track",
                "album": {
                    "id": 125431,
                    "type": "album",
                    "cover": "https://api.deezer.com/album/125431/image",
                    "title": "Underclass Hero",
                    "cover_xl": "https://cdns-images.dzcdn.net/images/cover/ff2c3adf0721f733460c1274fadb9cd4/1000x1000-000000-80-0-0.jpg",
                    "cover_big": "https://cdns-images.dzcdn.net/images/cover/ff2c3adf0721f733460c1274fadb9cd4/500x500-000000-80-0-0.jpg",
                    "tracklist": "https://api.deezer.com/album/125431/tracks",
                    "cover_small": "https://cdns-images.dzcdn.net/images/cover/ff2c3adf0721f733460c1274fadb9cd4/56x56-000000-80-0-0.jpg",
                    "cover_medium": "https://cdns-images.dzcdn.net/images/cover/ff2c3adf0721f733460c1274fadb9cd4/250x250-000000-80-0-0.jpg"
                },
                "title": "With Me",
                "artist": {
                    "id": 459,
                    "link": "https://www.deezer.com/artist/459",
                    "name": "Sum 41",
                    "type": "artist",
                    "picture": "https://api.deezer.com/artist/459/image",
                    "tracklist": "https://api.deezer.com/artist/459/top?limit=50",
                    "picture_xl": "https://cdns-images.dzcdn.net/images/artist/8f732ff3d26e22beb0eca2b528fd419d/1000x1000-000000-80-0-0.jpg",
                    "picture_big": "https://cdns-images.dzcdn.net/images/artist/8f732ff3d26e22beb0eca2b528fd419d/500x500-000000-80-0-0.jpg",
                    "picture_small": "https://cdns-images.dzcdn.net/images/artist/8f732ff3d26e22beb0eca2b528fd419d/56x56-000000-80-0-0.jpg",
                    "picture_medium": "https://cdns-images.dzcdn.net/images/artist/8f732ff3d26e22beb0eca2b528fd419d/250x250-000000-80-0-0.jpg"
                },
                "preview": "https://cdns-preview-f.dzcdn.net/stream/c-f10ebadea164ac737af0818fe71ab2db-5.mp3",
                "duration": 291,
                "readable": True,
                "title_short": "With Me",
                "title_version": "",
                "explicit_lyrics": False,
                "explicit_content_cover": 0,
                "explicit_content_lyrics": 0
            }
        },
        {
            "id": 77,
            "playlist": 8,
            "order": 5,
            "votes": [],
            "data": {
                "id": 9919786,
                "link": "https://www.deezer.com/track/9919786",
                "rank": 669483,
                "type": "track",
                "album": {
                    "id": 908993,
                    "type": "album",
                    "cover": "https://api.deezer.com/album/908993/image",
                    "title": "Endgame",
                    "cover_xl": "https://cdns-images.dzcdn.net/images/cover/58e7ce74258eb981c45ef34bb8a83a73/1000x1000-000000-80-0-0.jpg",
                    "cover_big": "https://cdns-images.dzcdn.net/images/cover/58e7ce74258eb981c45ef34bb8a83a73/500x500-000000-80-0-0.jpg",
                    "tracklist": "https://api.deezer.com/album/908993/tracks",
                    "cover_small": "https://cdns-images.dzcdn.net/images/cover/58e7ce74258eb981c45ef34bb8a83a73/56x56-000000-80-0-0.jpg",
                    "cover_medium": "https://cdns-images.dzcdn.net/images/cover/58e7ce74258eb981c45ef34bb8a83a73/250x250-000000-80-0-0.jpg"
                },
                "title": "Satellite",
                "artist": {
                    "id": 3566,
                    "link": "https://www.deezer.com/artist/3566",
                    "name": "Rise Against",
                    "type": "artist",
                    "picture": "https://api.deezer.com/artist/3566/image",
                    "tracklist": "https://api.deezer.com/artist/3566/top?limit=50",
                    "picture_xl": "https://cdns-images.dzcdn.net/images/artist/d8e36d7651a471afba588428e0feb021/1000x1000-000000-80-0-0.jpg",
                    "picture_big": "https://cdns-images.dzcdn.net/images/artist/d8e36d7651a471afba588428e0feb021/500x500-000000-80-0-0.jpg",
                    "picture_small": "https://cdns-images.dzcdn.net/images/artist/d8e36d7651a471afba588428e0feb021/56x56-000000-80-0-0.jpg",
                    "picture_medium": "https://cdns-images.dzcdn.net/images/artist/d8e36d7651a471afba588428e0feb021/250x250-000000-80-0-0.jpg"
                },
                "preview": "https://cdns-preview-e.dzcdn.net/stream/c-e3b5bc67769d864621ecdef7ff37db42-3.mp3",
                "duration": 238,
                "readable": True,
                "title_short": "Satellite",
                "title_version": "",
                "explicit_lyrics": False,
                "explicit_content_cover": 0,
                "explicit_content_lyrics": 0
            }
        },
        {
            "id": 74,
            "playlist": 8,
            "order": 2,
            "votes": [],
            "data": {
                "id": 103804228,
                "link": "https://www.deezer.com/track/103804228",
                "rank": 417623,
                "type": "track",
                "album": {
                    "id": 10797412,
                    "type": "album",
                    "cover": "https://api.deezer.com/album/10797412/image",
                    "title": "Getting Away With Murder (Expanded Edition)",
                    "cover_xl": "https://e-cdns-images.dzcdn.net/images/cover/69d4d8718d28d118f91f66c00c6e78b2/1000x1000-000000-80-0-0.jpg",
                    "cover_big": "https://e-cdns-images.dzcdn.net/images/cover/69d4d8718d28d118f91f66c00c6e78b2/500x500-000000-80-0-0.jpg",
                    "tracklist": "https://api.deezer.com/album/10797412/tracks",
                    "cover_small": "https://e-cdns-images.dzcdn.net/images/cover/69d4d8718d28d118f91f66c00c6e78b2/56x56-000000-80-0-0.jpg",
                    "cover_medium": "https://e-cdns-images.dzcdn.net/images/cover/69d4d8718d28d118f91f66c00c6e78b2/250x250-000000-80-0-0.jpg"
                },
                "title": "Take Me",
                "artist": {
                    "id": 89,
                    "link": "https://www.deezer.com/artist/89",
                    "name": "Papa Roach",
                    "type": "artist",
                    "picture": "https://api.deezer.com/artist/89/image",
                    "tracklist": "https://api.deezer.com/artist/89/top?limit=50",
                    "picture_xl": "https://e-cdns-images.dzcdn.net/images/artist/eb11a4d6945c8828e388935bcdf21313/1000x1000-000000-80-0-0.jpg",
                    "picture_big": "https://e-cdns-images.dzcdn.net/images/artist/eb11a4d6945c8828e388935bcdf21313/500x500-000000-80-0-0.jpg",
                    "picture_small": "https://e-cdns-images.dzcdn.net/images/artist/eb11a4d6945c8828e388935bcdf21313/56x56-000000-80-0-0.jpg",
                    "picture_medium": "https://e-cdns-images.dzcdn.net/images/artist/eb11a4d6945c8828e388935bcdf21313/250x250-000000-80-0-0.jpg"
                },
                "preview": "https://cdns-preview-9.dzcdn.net/stream/c-95da54927f2a78f0813ea8c5a5636a35-3.mp3",
                "duration": 206,
                "readable": True,
                "title_short": "Take Me",
                "title_version": "",
                "explicit_lyrics": False,
                "explicit_content_cover": 1,
                "explicit_content_lyrics": 0
            }
        },
        {
            "id": 73,
            "playlist": 8,
            "order": 1,
            "votes": [],
            "data": {
                "id": 623736392,
                "link": "https://www.deezer.com/track/623736392",
                "rank": 583533,
                "type": "track",
                "album": {
                    "id": 85609322,
                    "type": "album",
                    "cover": "https://api.deezer.com/album/85609322/image",
                    "title": "Chuck",
                    "cover_xl": "https://e-cdns-images.dzcdn.net/images/cover/c6a0130589841326372ac87c6924ed65/1000x1000-000000-80-0-0.jpg",
                    "cover_big": "https://e-cdns-images.dzcdn.net/images/cover/c6a0130589841326372ac87c6924ed65/500x500-000000-80-0-0.jpg",
                    "tracklist": "https://api.deezer.com/album/85609322/tracks",
                    "cover_small": "https://e-cdns-images.dzcdn.net/images/cover/c6a0130589841326372ac87c6924ed65/56x56-000000-80-0-0.jpg",
                    "cover_medium": "https://e-cdns-images.dzcdn.net/images/cover/c6a0130589841326372ac87c6924ed65/250x250-000000-80-0-0.jpg"
                },
                "title": "Some Say",
                "artist": {
                    "id": 459,
                    "link": "https://www.deezer.com/artist/459",
                    "name": "Sum 41",
                    "type": "artist",
                    "picture": "https://api.deezer.com/artist/459/image",
                    "tracklist": "https://api.deezer.com/artist/459/top?limit=50",
                    "picture_xl": "https://e-cdns-images.dzcdn.net/images/artist/8f732ff3d26e22beb0eca2b528fd419d/1000x1000-000000-80-0-0.jpg",
                    "picture_big": "https://e-cdns-images.dzcdn.net/images/artist/8f732ff3d26e22beb0eca2b528fd419d/500x500-000000-80-0-0.jpg",
                    "picture_small": "https://e-cdns-images.dzcdn.net/images/artist/8f732ff3d26e22beb0eca2b528fd419d/56x56-000000-80-0-0.jpg",
                    "picture_medium": "https://e-cdns-images.dzcdn.net/images/artist/8f732ff3d26e22beb0eca2b528fd419d/250x250-000000-80-0-0.jpg"
                },
                "preview": "https://cdns-preview-e.dzcdn.net/stream/c-eecebe7b7b43d2b3ffc04b053fa1f0b0-4.mp3",
                "duration": 205,
                "readable": True,
                "title_short": "Some Say",
                "title_version": "",
                "explicit_lyrics": False,
                "explicit_content_cover": 2,
                "explicit_content_lyrics": 0
            }
        }
    ],
    "creator": 3,
    "actions": {
        "add_participant": False,
        "retrieve": True,
        "list": False,
        "unfollow": False,
        "update": False,
        "follow": True,
        "destroy": False,
        "add_owner": False,
        "partial_update": False
    }
}


class Command(BaseCommand):
    def handle(self, *args, **options):
        # add superuser
        # u = User(username='a', email='a@a.com')
        # u.set_password('a')
        # u.is_superuser = True
        # u.is_staff = True
        # u.save()

        User = get_user_model()
        user = User.objects.create_superuser(email='a@a.com', username='a', password='aaaaaaaa')
        EmailAddress.objects.create(user=user, email=user.email, verified=True, primary=True)

        # add social app

        sapp = SocialApp(provider='google', name='google app',
                         client_id='205782653310-fjjullvs7cklq6su4qp0o7e8def79vfg.apps.googleusercontent.com',
                         secret='sMv5Xrje1aP_f__HS3g3Jt2B')

        site = Site.objects.get()
        site.domain = 'musicroom.ml'
        site.name = 'musicroom'
        site.save()

        sapp.save()
        sapp.sites.add(site)  # or your site id

        # add social account

        # sacc = SocialAccount(uid="<your facebook uid>", user=user, provider='facebook')
        # sacc.save()

        # ----------------------------------------------------------------------------------------------------

        user = User.objects.get(email='a@a.com')

        p = p1

        playlist = models.Playlist.objects.create(
            is_public=p['is_public'],
            name=p['name'],
            creator=user,
            place=p['place']
        )
        playlist.owners.add(user)

        for track in p['tracks']:
            models.Track.objects.create(
                playlist=playlist,
                order=track['order'],
                creator=user,
                data=track['data']
            )

        playlist = models.Playlist.objects.create(is_public=True, name='private playlist of user b', creator=user)
        playlist.owners.add(user)

        p = p2

        playlist = models.Playlist.objects.create(
            is_public=p['is_public'],
            name=p['name'],
            creator=user,
            place=p['place']
        )
        playlist.owners.add(user)

        for track in p['tracks']:
            models.Track.objects.create(
                playlist=playlist,
                order=track['order'],
                creator=user,
                data=track['data']
            )

        # ----------------------------------------------------------------------------------------------------

        user = User.objects.create(email='b@b.com', username='b', password='bbbbbbbb')
        EmailAddress.objects.create(user=user, email=user.email, verified=True, primary=True)

        playlist = models.Playlist.objects.create(is_public=True, name='public playlist of user b', creator=user)
        playlist.owners.add(user)

        track_1 = models.Track.objects.create(playlist=playlist, order=1, creator=user)
        track_2 = models.Track.objects.create(playlist=playlist, order=2, creator=user)
        track_3 = models.Track.objects.create(playlist=playlist, order=3, creator=user)

        playlist = models.Playlist.objects.create(is_public=True, name='private playlist of user b', creator=user)
        playlist.owners.add(user)

        track_1 = models.Track.objects.create(playlist=playlist, order=1, creator=user)
        track_2 = models.Track.objects.create(playlist=playlist, order=2, creator=user)
        track_3 = models.Track.objects.create(playlist=playlist, order=3, creator=user)
