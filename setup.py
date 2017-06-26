#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# -*- coding: utf-8 -*-

# Copyright (C) 2015 Atelier Obscur.
# Authors:
# Gilles Coissac <dev@atelierobscur.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of version 3 of the GNU General Public License
# as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.

import os
import sys
import ez_setup
ez_setup.use_setuptools()

import setuptools
from setuptools import setup
from setuptools.extension import Extension
from setuptools.command import build_ext


MIN_CYTHON_VERSION = '0.19'
MIN_PYTHON_VERSION = (3, 4)



sys.stderr = open('.errlog', 'w')


# Cython requierement
try:
    import Cython
    has_cython = True
except:
    has_cython = False
devtree = os.path.exists('DEVTREE')

# extensions compilation scheme
if devtree:
    # we are not in a source distribution tree
    # cython min version is an absolute requirement.
    try:
        setuptools.dist.Distribution(dict(setup_requires=['cython>=' + MIN_CYTHON_VERSION]))
    except:
        print("At least Cython %s is needed to generate c extensions files!" % (MIN_CYTHON_VERSION, ))
        sys.exit(1)
    else:
        use_cython = True
else:
    # we are in a source distribution
    # and pyx files extensions should be already cythonized.
    if has_cython and Cython.__version__ >= MIN_CYTHON_VERSION:
        # Cython is present and match minimum version
        # so we could use it.
        use_cython = True
    else:
        # let distribute or setuptools try to build against c files.
        use_cython = False

if use_cython:
    print("Cython %s is detected so generate c extensions files if needed." % (Cython.__version__, ))
    from Cython.Build import cythonize
    from Cython.Distutils import build_ext
    #TODO: make cython don't leave c generated files in the dev source tree
    def get_extensions(extensions, **_ignore):
        return cythonize(extensions, **{'cython-c-in-temp':1})
else:
    print("Cython %s is not present but try to continue without it..." % (MIN_CYTHON_VERSION, ))
    def get_extensions(extensions, **_ignore):
        for extension in extensions:
            sources = []
            for sfile in extension.sources:
                path, ext = os.path.splitext(sfile)
                if ext in ('.pyx', '.py'):
                    if extension.language == 'c++':
                        ext = '.cpp'
                    else:
                        ext = '.c'
                    sfile = path + ext
                sources.append(sfile)
            extension.sources[:] = sources
        return extensions

#
#=== Python version ===================
if sys.version_info[0] == MIN_PYTHON_VERSION[0]:
    if sys.version_info[1] < MIN_PYTHON_VERSION[1]:
        print("You need Python %i.%i or greater" %MIN_PYTHON_VERSION)
        sys.exit(1)
elif sys.version_info[0] < MIN_PYTHON_VERSION[0]:
    print("You need Python %i.%i or greater" %MIN_PYTHON_VERSION)
    sys.exit(1)

#
#=== gravure version ===================
version = open('VERSION').read().strip()
open('gravure/version.py', 'w').write('__version__ = "%s"\n' % version)

#
#=== Compilation paths =================

SRC_DIR = 'gravure/'
INCLUDE_DIRS = [SRC_DIR]
DYN_LIBRARY_DIRS = []
LIBRARIES = []
EXTRA_OBJECTS = []
COMPILE_ARGS =[]
X_LINK_ARGS = []

#
#=== Extensions list =================
extensions = [ \
    Extension(\
        'property', \
        sources = [os.path.join(SRC_DIR, 'core/property.pyx')], \
        include_dirs = INCLUDE_DIRS, \
        libraries = LIBRARIES, \
        runtime_library_dirs=DYN_LIBRARY_DIRS, \
        extra_objects = EXTRA_OBJECTS,  \
        extra_compile_args = COMPILE_ARGS
    ),  \
      Extension(\
        'stoch', \
        sources = [os.path.join(SRC_DIR, 'halftone/stoch.pyx')], \
        include_dirs = INCLUDE_DIRS, \
        libraries = LIBRARIES, \
        runtime_library_dirs=DYN_LIBRARY_DIRS, \
        extra_objects = EXTRA_OBJECTS,  \
        extra_compile_args = ['-fopenmp'], \
        extra_link_args=['-fopenmp']
    ),  \
    Extension(\
        'mdarray', \
        sources = [
                   os.path.join(SRC_DIR, 'numeric/bit_width_type.pxd'), \
                   os.path.join(SRC_DIR, 'numeric/max_const.pyx'), \
                   os.path.join(SRC_DIR, 'numeric/TYPE_DEF.pxi'), \
                   os.path.join(SRC_DIR, 'numeric/type_promotion.pyx'), \
                   os.path.join(SRC_DIR, 'numeric/_struct.pyx'), \
                   os.path.join(SRC_DIR, 'numeric/mdarray.pyx') \
                   ],  \
        include_dirs = [os.path.join(SRC_DIR, 'numeric/')], \
        libraries = LIBRARIES, \
        runtime_library_dirs=DYN_LIBRARY_DIRS, \
        extra_objects = EXTRA_OBJECTS,  \
        extra_compile_args = COMPILE_ARGS
    ),
]

#
#=== SETUP COMMAND ==============

setup(
    name              = 'gravure',
    version           = version,
    platforms         = ['any'],

    namespace_packages= ['gravure'],
    packages = ['gravure', \
                'gravure.core',  \
                'gravure.curve', \
                'gravure.halftone', \
                'gravure.halftone.test', \
                'gravure.numeric', \
                'gravure.numeric.test', \
                'gravure.rip', \
                'gravure..tools', \
                'gravure.ui' \
                ],

    package_data={ '': ['*.pxd'] },

    # 'setup.py build' will build either .py and .pyx
    cmdclass={'build_ext': build_ext},
    ext_package = '',
    ext_modules = extensions,

    #test_suite = '',
    #tests_require = 'nose'

    # Project uses reStructuredText,
    # and sphinx 1.1
    # install_requires = ['sphinx>=1.1'],

    author = 'Gilles Coissac',
    author_email = 'dev@atelierobscur.org',
    maintainer = 'Gilles Coissac',
    maintainer_email = 'dev@atelierobscur.org',
    description       = 'open source RIP(Raster Image Processing)',
    long_description  = open('README.txt').read(),
    license           = 'LGPL v3',
    keywords          = "graphic rip halfton print",
    url = 'http://www.atelierobscur.org/',
    download_url = 'http://www.atelierobscur.org/',

    classifiers=[
        "Environment :: X11 Applications :: Gnome",
        "Environment :: X11 Applications :: GTK",
        "Intended Audience :: End Users/Desktop",
        "Natural Language :: English",
        "Operating System :: POSIX :: Linux",
        "Programming Language :: C",
        "Programming Language :: Cython",
        "Programming Language :: Python",
        "Programming Language :: Python :: 3.4",
        "Topic :: Artistic Software",
        "Topic :: Desktop Environment :: Gnome",
        "Topic :: Printing",
        "Topic :: Software Development :: Libraries :: Python Modules"
    ]

)



