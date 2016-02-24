# -*- coding: utf-8 -*-

# Copyright (C) 2011 Atelier Obscur.
# Authors:
# Gilles Coissac <gilles@atelierobscur.org>

# This program is free software; you can redistribute it and/or modify
# it under the terms of version 2 of the GNU General Public License
# as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License with
# the Debian GNU/Linux distribution in file /usr/share/common-licenses/GPL;
# if not, write to the Free Software Foundation, Inc., 51 Franklin St,
# Fifth Floor, Boston, MA 02110-1301, USA.

# Utility to convert a hald clut image file to an input icc profil.

import sys
import numpy as np
import mahotas
import pylab
from smc.freeimage import Image

TEST = '/home/gilles/GRAPHISME/PROFIL ICC ATELIER /PHOTO/clut/HaldCLUT/Hald_CLUT_Identity_12.tif'
TEST2 = '/home/gilles/GRAPHISME/PROFIL ICC ATELIER /PHOTO/clut/HaldCLUT/Black-and-White/Agfa/Agfa APX 25.png'

def main(args):
    print('hclut2icc utility')
    img = Image(TEST)
    print(img)

if __name__ == "__main__":
    sys.exit(main(sys.argv))

