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
__date__ = "Mon Feb 11 18:34:36 2013"
__version__ = "$Revision: 0.1 $"
__credits__ = "Atelier Obscur : www.atelierobscur.org"

#TODO:  * copyright et licence
#       * docstring du module et des fonctions
#       * unitest

from decimal import Decimal
import gmath as gm


class SpotFunction(object):
    """ Consider a halftone cell to have its own coordinate system:
        the center of the cell is the origin and the corners are at
        coordinates ±1.0 horizontally and vertically. Each pixel in
        the cell is centered at horizontal and vertical coordinates
        that both lie in the range −1.0 to +1.0. For each pixel, the
        PostScript interpreter pushes the pixel’s coordinates on the
        operand stack and calls the spot function procedure.
        The procedure must return a single number in the range −1.0
        to +1.0 that defines the pixel’s position in the whitening
        order.
        The specific values the spot function returns are not
        significant; all that matters is the relative values returned
        for different pixels. As a cell’s gray level varies from
        black to white, the first pixel whitened is the one for which
        the spot function returns the lowest value, the next pixel
        is the one with the next higher spot function value, and so on.
        If two pixels have the same spot function value, their relative
        order is chosen arbitrarily.
    """

    @staticmethod
    def _checkBounds(func):
        def _checkBounds(self, x, y):
            if x < -1.0 or x > 1.0 or y < -1.0 or y > 1.0:
                raise ValueError("x and y function arguments \
                should lie in the range [-1.0, 1.0]")
            return func(self, x, y)
        return _checkBounds

    def _checkFloat(self, f, x, y):
        if isinstance(x, Decimal) or isinstance(y, Decimal):
            return Decimal(str(f))
        else:
            return f

    def __call__(self, x, y):
        raise NotImplementedError


class LineX(SpotFunction):

    @SpotFunction._checkBounds
    def __call__(self, x, y):
        return x


class LineY(SpotFunction):

    @SpotFunction._checkBounds
    def __call__(self, x, y):
        return y


class Line(SpotFunction):

    @SpotFunction._checkBounds
    def __call__(self, x, y):
        return - abs(y)


class SimpleDot(SpotFunction):

    @SpotFunction._checkBounds
    def __call__(self, x, y):
        y *= y
        x *= x
        return 1 - (x + y)

    def __str__(self):
        return 'Simple Dot Spot Function'


class CosineDot(SpotFunction):

    @SpotFunction._checkBounds
    def __call__(self, x, y):
        y = gm.cos(y * 180)
        x = gm.cos(x * 180)
        return (y + x) / 2


class RoundDot(SpotFunction):

    @SpotFunction._checkBounds
    def __call__(self, x, y):
        x = abs(x)
        y = abs(y)
        if x + y <= 1:
            x *= x
            y *= y
            z = 1 - (x + y)
        else:
            x -= 1
            x *= x
            y -= 1
            y *= y
            z = (x + y) - 1
        return z


class HillDot(SpotFunction):

    @SpotFunction._checkBounds
    def __call__(self, x, y):
        a = self._checkFloat(0.1, x, y)
        x *= x
        y *= y
        return 1 / ((x + y) * 20 + 1) - a


class Rhomboid(SpotFunction):

    @SpotFunction._checkBounds
    def __call__(self, x, y):
        a = self._checkFloat(0.9, x, y)
        x = abs(x) * a
        y = abs(y)
        return (x + y) / 2


class Square(SpotFunction):

    @SpotFunction._checkBounds
    def __call__(self, x, y):
        x = abs(x)
        y = abs(y)
        if (y < x):
            z = - x
        else:
            z = - y
        return z


class Cross(SpotFunction):

    @SpotFunction._checkBounds
    def __call__(self, x, y):
        x = abs(x)
        y = abs(y)
        if (y > x):
            z = - x
        else:
            z = - y
        return z
