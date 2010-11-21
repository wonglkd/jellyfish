#!/usr/bin/env python
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

long_description = open('README.rst').read()

setup(name="jellyfish",
      version="0.2.0-dev",
      platforms=["any"],
      description=("a library for doing approximate and "
                   "phonetic matching of strings."),
      url="http://github.com/sunlightlabs/jellyfish",
      long_description=long_description,
      classifiers=["Development Status :: 4 - Beta",
                   "Intended Audience :: Developers",
                   "License :: OSI Approved :: BSD License",
                   "Natural Language :: English",
                   "Operating System :: OS Independent",
                   "Programming Language :: Python",
                   "Topic :: Text Processing :: Linguistic"],
      cmdclass={'build_ext': build_ext},
      ext_modules=[Extension("jellyfish", ['jellyfish.pyx', 'porter.c'])],
      install_requires=["cython"],
)
