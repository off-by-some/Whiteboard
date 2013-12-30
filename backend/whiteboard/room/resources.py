from armet import resources, attributes
from .models import Room


class RoomResource(resources.ModelResource):

    class Meta:
        model = Room

    id = attributes.UUIDAttribute('id', write=False)

    name = attributes.TextAttribute('username', required=True)
