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
import matplotlib.pyplot as plt


class Point(object):
    __slots__ = ['x', 'y']
    __hash__ = None

    def __init__(self, x=0, y=0):
        self.x = x
        self.y = y

    def __copy__(self):
        return self.__class__(self.x, self.y)

    def __repr__(self):
        return 'Point(%.2f, %.2f)' % (self.x, self.y)

    def __eq__(self, other):
        if isinstance(other, Point):
            return self.x == other.x and self.y == other.y
        else:
            raise AttributeError(type(other))

    def __ne__(self, other):
        return not self.__eq__(other)

    def __nonzero__(self):
        return self.x != 0 or self.y != 0

    def __iter__(self):
        return iter((self.x, self.y))

    def __add__(self, other):
        if isinstance(other, Point):
            return Point(self.x + other.x, self.y + other.y)
        else:
            raise AttributeError
    __radd__ = __add__

    def __iadd__(self, other):
        if isinstance(other, Point):
            self.x += other.x
            self.y += other.y
        else:
            raise AttributeError
        return self

    def __sub__(self, other):
        if isinstance(other, Point):
            return Point(self.x - other.x, self.y - other.y)
        else:
            raise AttributeError

    def __rsub__(self, other):
        if isinstance(other, Point):
            return Point(other.x - self.x, other.y - self.y)
        else:
            raise AttributeError

    def __mul__(self, other):
        assert type(other) in (int, long, float)
        return Point(self.x * other, self.y * other)
    __rmul__ = __mul__

    def __imul__(self, other):
        assert type(other) in (int, long, float)
        self.x *= other
        self.y *= other
        return self

    def __div__(self, other):
        assert type(other) in (int, long, float)
        return Point(operator.div(self.x, other), operator.div(self.y, other))

    def __rdiv__(self, other):
        assert type(other) in (int, long, float)
        return Point(operator.div(other, self.x), operator.div(other, self.y))

    def __floordiv__(self, other):
        assert type(other) in (int, long, float)
        return Point(operator.floordiv(self.x, other), operator.floordiv(self.y, other))

    def __rfloordiv__(self, other):
        assert type(other) in (int, long, float)
        return Point(operator.floordiv(other, self.x), operator.floordiv(other, self.y))

    def __truediv__(self, other):
        assert type(other) in (int, long, float)
        return Point(operator.truediv(self.x, other), operator.truediv(self.y, other))

    def __rtruediv__(self, other):
        assert type(other) in (int, long, float)
        return Point(operator.truediv(other, self.x), operator.truediv(other, self.y))

    def __neg__(self):
        return Point(-self.x, -self.y)

    __pos__ = __copy__

    def __abs__(self):
        return math.sqrt(self.x ** 2 + self.y ** 2)

    def normalize(self):
        d = abs(self)
        if d:
            self.x /= d
            self.y /= d
        return self

    def normalized(self):
        d = abs(self)
        if d:
            return Point(self.x / d, self.y / d)
        return self.copy()

    def dot(self, other):
        assert isinstance(other, Point)
        return self.x * other.x + self.y * other.y


class DotCell(Point):
    __slots__ = ['w']

    def __init__(self, x=0,  y=0, w=0):
        Point.__init__(self, int(x), int(y))
        self.w = w

    def __copy__(self):
        return self.__class__(self.x, self.y,  self.w)

    def __repr__(self):
        return 'DotCell(%i, %i, %.5f)' % (self.x, self.y, self.w)

    def __eq__(self, other):
        if isinstance(other, DotCell):
            return other.w == self.w
        else:
            return false

    def __ne__(self, other):
        if isinstance(other, DotCell):
            return other.w != self.w
        else:
            return false

    def __lt__(self, other):
        if isinstance(other, DotCell):
            return self.w < other.w
        else:
            return false

    def __le__(self, other):
        if isinstance(other, DotCell):
            return self.w <= other.w
        else:
            return false

    def __gt__(self, other):
        if isinstance(other, DotCell):
            return self.w > other.w
        else:
            return false

    def __ge__(self, other):
        if isinstance(other, DotCell):
            return self.w >= other.w
        else:
            return false

    def __nonzero__(self):
        return self.w != 0

    def __iter__(self):
        return iter((self.x, self.y, self.w))


class Cell(object):
    """An halftone cell have its own coordinate system:
       the center of the cell is the origin and the corners are at
       coordinates ±1.0 horizontally and vertically. Each pixel in
       the cell is centered at horizontal and vertical coordinates
       that both lie in the range −1.0 to +1.0.
    """
    __slot__ = ['width', 'height', 'data', 'normSpace', 'whiteningOrder', 'buildOrder']
    __hash__ = None

    def __init__(self, width=2, height=2):
        area = width * height
        self.width = int(width)
        self.height = int(height)

        self.data = [None] * area
        self.normSpace = [None] * area
        self.whiteningOrder = [None] * area

        self.buildOrder = None
        self._computeNormSpace()

    def _computeNormSpace(self):
        hc = self.height
        wc = self.width
        nm = self.normSpace
        wh = self.whiteningOrder
        i = 0
        for h in range(hc):
            y = (float(h) / (hc-1) * 2.0) - 1
            for w in range(wc):
                x = (float(w) / (wc-1) * 2.0) - 1
                nm[i] = Point(x, y)
                wh[i] = DotCell(w, h)
                i += 1

    def _checkWhtorder(self):
        for e in self.whiteningOrder:
            c = self.whiteningOrder.count(e)
            if(c > 1):
                print(c, 'X same value')

    def setBuildOrder(self, o):
        self.buildOrder = o

    def fill(self):
        self.buildOrder(self.normSpace, self.whiteningOrder)
        self._checkWhtorder()
        print (self.whiteningOrder)
        self.whiteningOrder.sort()
        print()
        print (self.whiteningOrder)
        wd = self.width
        for e in self.whiteningOrder:
            self.data[e.x + (wd * e.y)] = e.w

    def __str__(self):
        s = 'Halftone cell ' + str(self.width) + 'x' + str(self.height)
        s += '\n'
        for i in range(self.height):
            s += str(self.data[i:i + self.width]) + '\n'
        return s


class BuildOrder(object):
    """Turn On Sequence Basic Class
    """
    def __init__(self):
        pass


class BuildOrderSpotFunction(BuildOrder):
    """
    """
    __slot__ = ['spotFunc']

    def __init__(self, spotFunc):
        self.spotFunc = spotFunc

    def __call__(self, norm_space, whiteningOrder):
        for i, pt in enumerate(norm_space):
            whiteningOrder[i].w = self.spotFunc(pt.x, pt.y)


def plotCell(cell):
    plt.xlim(-1.0,1.0)
    plt.ylim(-1.0,1.0)
    plt.grid(True)
    plt.box(on=True)

    ax = plt.gca()
    ax.spines['bottom'].set_position(('data',0))
    ax.spines['left'].set_position(('data',0))
    ax.spines['left'].set_color('black')

    #plt.xticks([0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0])
    #plt.yticks([0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0])

    #plt.legend(['data', 'fitted f', 'tangent', '2. order'], loc='best')
    plt.show()


def test():
    spot_f = spotfunctions.RoundDot()
    h_cell = Cell(8, 8)
    h_cell.setBuildOrder(BuildOrderSpotFunction(spot_f))
    h_cell.fill()
    print(spot_f)
    print(h_cell)
    plotCell(h_cell)


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
