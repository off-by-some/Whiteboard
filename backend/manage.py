#!/usr/bin/env python
from alchemist.management import Manager
from whiteboard.app import application

if __name__ == '__main__':
    Manager(application).run()
