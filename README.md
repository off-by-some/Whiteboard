Whiteboard
==========

Whiteboard is an online drawing application that allows users to draw in real time with other collaboraters


How to install:
---------------

currently, you should install any deps, for the front end, we only require LiveScript, and installing dependencies for the backend is quite simple.

First off, you will need an install of mySQL, make sure you have that before proceeding.

Then, navigate to the directory setup.py is and enter the following command:

```$ pip install -e . ```

You then have all the dependencies for Whiteboard's backend. Hooray.


Configuring the backend:
------------------------

You will need to edit settings.py in order to run your server, i included an example of what that may look like:

Here is an example configuration connecting to MariaDB's default port
```python

DATABASES = {'default': {
    'engine': 'mysql+oursql',
    'name': NAME,
    'username': 'root',
    'host': 'localhost',
#   'password': 'your password',
    'port': 3306
}}
```

Everything else is completely optional.

Running the backend:
--------------------

Currently, there are two things you need to run in order to get the backend fully functional:

```websockets.py``` and ```manage.py```

You may just run websockets.py as you would any other python script (Please note, this file is not compatable with Py3):

```$ python2 websockets.py```

On to ```manage.py```:

First off, we need to create a very special spot for whiteboard in mySQL:

```$ ./manage.py db init --database && ./manage.py db init```

then we simply run the backend:

```./manage.py run```


And thats it! Whiteboard is now functional!
