"""
A Here Maps API Python wrapper

See:
https://developer.here.com
https://github.com/CartoDB/geocoder-api
"""

from setuptools import setup, find_packages

setup(
    name='heremaps',

    version='0.0.1',

    description='A Here Maps API Python wrapper',

    url='https://github.com/CartoDB/geocoder-api',

    author='Data Services Team - CartoDB',
    author_email='dataservices@cartodb.com',

    license='MIT',

    classifiers=[
        'Development Status :: 5 - Production',
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
