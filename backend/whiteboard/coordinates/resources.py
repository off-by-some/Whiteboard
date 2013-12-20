from armet import resources, attributes
from .models import Coordinate


class CoordinateResource(resources.ModelResource):

    class Meta:
        model = Coordinate
        allowed_operations = ('read', 'destroy', 'create', 'update')

    id = attributes.UUIDAttribute('id', write=False)

    coordinates = attributes.Attribute('coordinates', required=True)
