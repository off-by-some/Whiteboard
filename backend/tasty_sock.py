from gevent import monkey
import gevent
monkey.patch_all()

from flask import Flask
from flask_sockets import Sockets
from geventwebsocket.handler import WebSocketHandler
from gevent.pywsgi import WSGIServer


app = Flask(__name__)
sockets = Sockets(app)

listeners = set()

@sockets.route('/broadcast')
def broadcast_socket(ws):
    try:
        listeners.add(ws)
        while True:
            message = ws.receive()
            print "Recieved a message: %s" % message

            if message is None:
                break

            for sock in listeners:
                gevent.spawn(sock.send, message)
    finally:
        listeners.remove(ws)


@app.route('/')
def hello():
    return 'Hello World!'


if __name__ == '__main__':
    # Launch a gevent powered server so we can handle simultaneous requests.
    server = WSGIServer(('0.0.0.0', 9002), app, handler_class=WebSocketHandler)
    server.serve_forever()
