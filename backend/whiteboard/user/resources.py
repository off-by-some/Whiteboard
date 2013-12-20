from armet import resources, attributes
from .models import Username


class UsernameResource(resources.ModelResource):

    class Meta:
        model = Username

    id = attributes.UUIDAttribute('id', write=False)

    username = attributes.TextAttribute('username', required=True)
