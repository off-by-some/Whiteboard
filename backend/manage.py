#!/usr/bin/env python
from alchemist.management import Manager
from app import application

if __name__ == '__main__':
    Manager(application).run()
