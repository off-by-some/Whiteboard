from wsgiref.simple_server import make_server
from ws4py.websocket import EchoWebSocket
from ws4py.server.wsgirefserver import WSGIServer, WebSocketWSGIRequestHandler
from ws4py.server.wsgiutils import WebSocketWSGIApplication

# TODO: Need to over-write the request handler


server = make_server('127.0.0.1', 9002, server_class=WSGIServer,
                     handler_class=WebSocketWSGIRequestHandler,
                     app=WebSocketWSGIApplication(handler_cls=EchoWebSocket))
server.initialize_websockets_manager()
print("Listening on localhost:9002")
server.serve_forever()
