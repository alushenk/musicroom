from rest_framework.exceptions import APIException


class TrackExistsException(APIException):
    status_code = 302
    default_detail = "Track already exists"
    default_code = "track_exists"
