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

__author__  = "Gilles Coissac <gilles@atelierobscur.org>"
__date__    = "2 March 2011"
__version__ = "$Revision: 0.1 $"
__credits__ = "Atelier Obscur : www.atelierobscur.org"

"""
Created on Wed Mar  2 10:27:44 2011

@author: Gilles Coissac
"""

from distribute_setup import use_setuptools
use_setuptools()
from setuptools import setup, find_packages

setup(
      name              = 'gravure',
      version           = '0.1.dev',
      description       = 'open source RIP(Raster Image Processing)Software for screenprinters',
      long_description  = open('README.txt').read(),
      license           = 'GNU GPL',
      keywords          = '',
      #platforms         = ["MacOS"], # the only one tested

      author            = 'Gilles Coissac',
      author_email      = 'gilles@atelierobscur.org',
      maintainer        = 'Gilles Coissac',
      maintainer_email  = 'gilles@atelierobscur.org',
      url               = 'http://www.atelierobscur.org/',
      #download_url     = 'http://www.atelierobscur.org/',

      classifiers       = [],
      #cmdclass         = {'build_ext' : build_ext},
      namespace_packages= ['gravure']
      #packages         = ['gravure'],
      #ext_package      = 'pygutenprint',
      #ext_modules      = ext_modules
)




