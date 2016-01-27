"""
A Google Maps wrapper for the CartoDB geocoder server PostgreSQL extension

See:
https://github.com/CartoDB/geocoder-api
"""

from setuptools import setup, find_packages

setup(
    name='google-geocoder',

    version='0.0.1',

    description='A Google Maps wrapper for the CartoDB geocoder server PostgreSQL extension',

    url='https://github.com/CartoDB/geocoder-api',

    author='Data Services Team - CartoDB',
    author_email='dataservices@cartodb.com',

    license='MIT',

    classifiers=[
        'Development Status :: 2 - Beta',
        'Intended Audience :: Mapping comunity',
        'Topic :: Maps :: Mapping Tools',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python :: 2.7',
    ],

    keywords='maps api mapping tools',

    packages=find_packages(exclude=['contrib', 'docs', 'tests']),

    extras_require={
        'dev': ['unittest'],
        'test': ['unittest'],
    }
)

