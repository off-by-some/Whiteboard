import socket
# import thread

# simple socket for testing


class StartSocket():

    def __init__(self):
        self.host = "127.0.0.1"
        self.port = 9002
        self.backlog = 5
        self.size = 1024
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    def start(self):
        self.socket.bind((self.host, self.port))
        self.socket.listen(self.backlog)
        while 1:
            client, address = self.socket.accept()
            data = client.recv(self.size)
            if data:
                client.sendall(data)
            client.close()

# We need to open a thread, so the backend may resume doing its thing

x = StartSocket()

print("Listening on %s:%s" % (x.host, str(x.port)))

x.start()

# thread.start_new_thread(x.start)
