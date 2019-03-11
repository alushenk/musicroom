from rest_framework import filters


class OwnerFilterBackend(filters.BaseFilterBackend):
    """
    Filter that only allows users to see their own objects.
    """

    def filter_queryset(self, request, queryset, view):
        if request.user.is_staff:
            return queryset
        return queryset.filter(owner=request.user)


class TokenFilterBackend(filters.BaseFilterBackend):
    """
    Filter that only allows users to see their own objects.
    """

    def filter_queryset(self, request, queryset, view):
        if request.user.is_staff:
            return queryset
        return queryset.filter(bot_id__in=request.user.bots.all())
