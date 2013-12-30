from alchemist import db
from sqlalchemy_utils import UUIDType
import sqlalchemy as sa
import uuid


class Room(db.Model):

    id = sa.Column(UUIDType, primary_key=True, default=uuid.uuid4)

    name = sa.Column(
        sa.Unicode(200),
        nullable=False,
        doc="The name of the room")
