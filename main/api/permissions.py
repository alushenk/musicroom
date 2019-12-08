from rest_framework import permissions


class IsOwnerOrReadOnlyUser(permissions.BasePermission):

    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return request.user.is_staff or obj == request.user


class IsStaffOrTargetUser(permissions.BasePermission):
    def has_permission(self, request, view):
        # allow user to list all users if logged in user is staff
        return view.action == 'retrieve' or request.user.is_staff

    def has_object_permission(self, request, view, obj):
        return request.user.is_staff or obj == request.user


class IsParticipantOrReadOnly(permissions.BasePermission):
    message = "You should be the playlist owner or participant to do this"

    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return request.user in obj.participants


class IsOwnerOrReadOnly(permissions.BasePermission):
    message = "You should be the playlist owner to do this"

    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return request.user in obj.owners.all()


class PlaylistPermissions(permissions.BasePermission):

    def has_object_permission(self, request, view, obj=None):
        if obj.is_public is True:
            if view.action in ['add_participant', 'retrieve', 'list']:
                return True
            elif view.action in ['update', 'add_owner', 'partial_update']:
                return request.user in obj.owners.all()
            elif view.action is 'destroy':
                return request.user.id is obj.creator.id
        else:
            if view.action in ['retrieve', 'update', 'add_owner', 'partial_update', 'add_participant']:
                return request.user in obj.owners.all()
            if view.action == "unfollow":
                return request.user in obj.participants.all() or request.user in obj.owners.all()
            if view.action is 'destroy':
                return request.user.id is obj.creator.id


class PlaylistViewPermissions(permissions.BasePermission):

    def has_object_permission(self, request, view, obj=None):
        if obj.is_public is True:
            if request.method in ['PATCH']:
                return True
            elif request.method in ['DELETE']:
                return request.user in obj.owners.all()
        else:
            if request.method in ['PATCH', 'DELETE']:
                return request.user in obj.owners.all()


class TrackPermissions(permissions.BasePermission):

    def has_object_permission(self, request, view, obj=None):
        if view.action is 'create':
            if obj.is_public is True:
                return True
            return request.user in obj.owners.all() or request.user in obj.participants.all()
        elif view.action is 'destroy':
            return obj.creator.id is request.user.id or request.user in obj.owners.all()
        return True
