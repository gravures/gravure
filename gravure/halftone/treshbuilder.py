#!/usr/bin/python
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

from __future__ import print_function

__author__ = "Gilles Coissac <gilles@atelierobscur.org>"
__date__ = "Tue Jan 22 21:40:55 2013"
__version__ = "$Revision: 0.1 $"
__credits__ = "Atelier Obscur : www.atelierobscur.org"

import math
from fractions import Fraction
from decimal import *
#import decimal.Decimal as Decimal

import decimalmath as dm
import spotfunctions


class Cell(object):
    """An halftone cell have its own coordinate system:
       the center of the cell is the origin and the corners are at
       coordinates ±1.0 horizontally and vertically. Each pixel in
       the cell is centered at horizontal and vertical coordinates
       that both lie in the range −1.0 to +1.0.
    """
    __slot__ = ['width', 'height', 'data', 'wht_order', '_fill']
    __hash__ = None

    def __init__(self, width=2, height=2):
        self.width = int(width)
        self.height = int(height)
        self.data = [None] * width * height
        self.wht_order = [None] * width * height
        self._fill = self._basicfill
        self._fill()

    def _basicfill(self):
        for i in range(len(self.data)):
            self.data[i] = 128

    def setFillFunction(self, func):
        self._fill = func

    def __str__(self):
        s = 'Halftone cell ' + str(self.width) + 'x' + str(self.height)
        s += '\n'
        for i in range(self.height):
          s += str(self.data[i:i + self.width]) + '\n'
        return s


def test():
    spot_f = spotfunctions.SimpleDot()
    h_cell = Cell(8, 8)
    print(h_cell)



if __name__ == '__main__':
    FREQUENCY = 90
    ANGLE = 30
    XDPI = 2880
    YDPI = 1440
    test()
    #findScreen(FREQUENCY, ANGLE, XDPI, YDPI)


def findScreen(lpi, angle, xdpi, ydpi):
    min_angle = angle -5
    max_angle = angle + 5
    min_lpi = lpi-10
    max_lpi = lpi+10

    r_dpi = Decimal(xdpi) / Decimal(ydpi)

    tan = math.tan(math.radians(angle))
    cell_width = Decimal(xdpi) / Decimal(lpi)
    x_slope = Decimal(math.sin(math.radians(angle))) * Decimal(cell_width)
    y_slope = Decimal(math.cos(math.radians(angle))) * Decimal(cell_width)

    rational_tan = Fraction(x_slope/y_slope).limit_denominator(10)
    delta_a = Decimal(tan) - (Decimal(rational_tan.numerator) / Decimal(rational_tan.denominator))

    r_x_slope = Decimal(round(x_slope))
    r_y_slope = Decimal(round(Decimal(round(y_slope / r_dpi))))
    hr_y_slope = r_y_slope * r_dpi

    delta_b = Decimal(tan) - (r_x_slope / hr_y_slope)

    rational_angle = getAngle(r_x_slope, hr_y_slope)
    result_cell_width = (r_x_slope * r_x_slope + hr_y_slope * hr_y_slope).sqrt()
    grey_levels = (r_x_slope * r_x_slope + r_y_slope * r_y_slope) + 1
    result_lpi = Decimal(xdpi) / result_cell_width

#    print ""
#    print "device resolution : %d/%d dpi" % (xdpi, ydpi)
#    print "request lpi :", lpi
#    print "request angle :", angle
#    print "tan :", tan
#    print "cell_width :", cell_width
#    print "x_slope :", x_slope
#    print "y_slope :", y_slope
#    print "best rational tan :", rational_tan
#    print "delta_a :", delta_a
#    print "delta_b :", delta_b
#    print "reverse angle :", getAngle(x_slope, y_slope)
#    print "-------------------------------------"
#    print "rational angle:", rational_angle
#    print "result lpi :", result_lpi
#    print "rational x_slope", r_x_slope
#    print "rational y_slope", r_y_slope
#    print "result cell width :", result_cell_width
#    print "grey levels number :", grey_levels


def getAngle(x, y):
    return math.degrees(math.atan(x/y))