from alchemist import db
from sqlalchemy_utils import UUIDType, JSONType
import sqlalchemy as sa
import uuid


class Coordinate(db.Model):

    id = sa.Column(UUIDType, primary_key=True, default=uuid.uuid4)

    coordinates = sa.Column(JSONType, doc="""Drawing coordinates for undo""")
