from rest_framework import filters


class PlaylistFilter(filters.BaseFilterBackend):
    """
    Filter that only allowed users can see all objects. And all other users can see only is_public=True objects
    """

    def filter_queryset(self, request, queryset, view):
        return queryset.filter(is_public=True)
