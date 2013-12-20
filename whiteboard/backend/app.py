from flask import Flask
import alchemist
import alchemist_armet

application = Flask(__package__)

# Configure the application object.
alchemist.configure(application)
alchemist_armet.configure(application)


# @application.route('/')
# def index():
#     return 'text on the screen'
