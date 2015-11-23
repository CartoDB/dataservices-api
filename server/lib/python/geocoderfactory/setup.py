"""
A python module to handle geocoder creation based on setup.

"""

from setuptools import setup, find_packages

setup(
    name='geocoderfactory',

    version='0.0.1',

    description='A python module to handle geocoder creation based on setup.',

    url='https://github.com/CartoDB/geocoder-api',

    author='Data Services Team - CartoDB',
    author_email='dataservices@cartodb.com',

    license='MIT',

    packages=find_packages(exclude=['contrib', 'docs', 'tests']),

    extras_require={
        'dev': ['unittest'],
        'test': ['unittest'],
    }
)

