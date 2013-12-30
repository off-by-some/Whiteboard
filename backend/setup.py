from setuptools import setup, find_packages

setup(
    name='Whiteboard',
    description='An online collaborative drawing application',
    author='Pholey, Bla',

    packages=find_packages('.'),

    install_requires=[

        'alchemist[mysql] >= 0.3.0, < 0.4.0',

        'armet >= 0.4.0, < 0.5.0',

         'alchemist-armet >= 0.1.0',

         'anyjson',

         'shortuuid',

         'ws4py',
    ]
)
