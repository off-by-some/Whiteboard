from alchemist.conf import defer


# Name of the project; declared for reference.
NAME = 'whiteboard'

# Debugging configuration.
DEBUG = True

# Default server configuration.
SERVER_HOST = 'localhost'
SERVER_PORT = 8001
SERVER_THREADED = True

# Database configuration.
DATABASES = {'default': {
    'engine': 'mysql+oursql',
    'name': NAME,
}}

# List of registered components.
COMPONENTS = [
    'alchemist',
    NAME,
]

# Armet (REST server) configuration.
ARMET_TRAILING_SLASH = False
ARMET_DEBUG = defer('DEBUG')
