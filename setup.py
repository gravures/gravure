#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import with_statement

# metadata
"open source RIP(Raster Image Processing)"
__version__ = "0"
__license__ = "LGPL v3"
__author__ = "G"
__email__ = "g"
__url__ = "http://www.atelierobscur.org/'"
__date__ = "2017-06-26T11:27:14"
__prj__ = "Gravure"


from setuptools import setup, find_packages


def get_long_description():
    descr = []
    for fname in ["README.txt"]:
        with open(fname) as f:
            descr.append(f.read())
    return "\n\n".join(descr)


setup(
    name="Gravure",
    version="0",
    description="open source RIP(Raster Image Processing)",
    long_description=get_long_description(),
    author="G",
    author_email="g",
    maintainer="Gilles Coissac",
    maintainer_email="dev@atelierobscur.org",
    url="http://www.atelierobscur.org/'",
    download_url="http://www.atelierobscur.org/'",
    license="LGPL v3",
    platforms=[
        "any"
    ],
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
    ],
    keywords="graphic rip halfton print",
    packages=find_packages(
        "/home/gilles/FOSSILS/gravure/gravure"
    ),
    include_package_data = True,
)
# -*- coding: utf-8 -*-
#
# SETUP install python file
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Provided as-is; use at your own risk; no warranty; no promises; enjoy!
#
#

__author__  = "Gilles Coissac <dev@atelierobscur.org>"
__date__    = "2 March 2011"
__version__ = "$Revision: 0.1 $"
__credits__ = "Atelier Obscur : www.atelierobscur.org"

"""
Created on Wed Mar  2 10:27:44 2011

@author: Gilles Coissac
"""
import os
import sys

import ez_setup
ez_setup.use_setuptools()

import setuptools
from setuptools import setup, find_packages
from setuptools.extension import Extension
from setuptools.command import build_ext

# Cython requierement
min_cython_version = '0.19'
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
        setuptools.dist.Distribution(dict(setup_requires=['cython>=' + min_cython_version]))
    except:
        print("At least Cython %s is needed to generate c extensions files!" % (min_cython_version, ))
        sys.exit(1)
    else:
        use_cython = True
else:
    # we are in a source distribution
    # and pyx files extensions should be already cythonized.
    if has_cython and Cython.__version__ >= min_cython_version:
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
    print("Cython %s is not present but try to continue without it..." % (min_cython_version, ))
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
if sys.version_info[0] == 3:
    if sys.version_info[1] < 4:
        print("You need Python 3.4 or greater")
        sys.exit(1)
elif sys.version_info[0] < 3:
    print("You need Python 3.4 or greater")
    sys.exit(1)

#
#=== version ========================
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
        'enum', \
        sources = [os.path.join(SRC_DIR, 'numeric/enum.pyx')], \
        include_dirs = INCLUDE_DIRS, \
        libraries = LIBRARIES, \
        runtime_library_dirs=DYN_LIBRARY_DIRS, \
        extra_objects = EXTRA_OBJECTS,  \
        extra_compile_args = COMPILE_ARGS
    ),  \
        Extension(\
        'mdarray', \
        sources = [os.path.join(SRC_DIR, 'numeric/mdarray.pyx')], \
        include_dirs = INCLUDE_DIRS, \
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
    version           = '0.1.dev',
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
    keywords          = '',

    url = 'http://www.atelierobscur.org/',
    download_url = 'http://www.atelierobscur.org/',

    #classifiers       = []

)

