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

import math
from decimal import *


__all__ = ['Point', 'DotCell', 'Cell', 'Tos', 'TosSpotFunction']


class Point():
    __slots__ = ['x', 'y']
    __hash__ = None

    def __init__(self, x=0, y=0):
        self.x = x
        self.y = y

    def __copy__(self):
        return self.__class__(self.x, self.y)

    def __repr__(self):
        return 'Point(%.2f, %.2f)' % (self.x, self.y)


    #
    # Equality Special Methods
    #
    def __eq__(self, other):
        if isinstance(other, Point):
            return self.x == other.x and self.y == other.y
        else:
            raise AttributeError(type(other))

    def __ne__(self, other):
        return not self.__eq__(other)


    #
    # Iteration Special Methods
    #
    def __iter__(self):
        return iter((self.x, self.y))

    #
    # Arithmetic Special Methods
    #
    def __nonzero__(self):
        return self.x != 0 or self.y != 0

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

    #
    # Math Methods
    #
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
        return 'DotCell(%i, %i, %i)' % (self.x, self.y, self.w)

    #
    # Comparaison Special Methods
    #
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

    #
    # Iteration Special Methods
    #
    def __iter__(self):
        return iter((self.x, self.y, self.w))


class Cell():
    """An halftone cell have its own coordinate system:
       the center of the cell is the origin and the corners are at
       coordinates ±1.0 horizontally and vertically. Each pixel in
       the cell is centered at horizontal and vertical coordinates
       that both lie in the range −1.0 to +1.0.
        """
    __slot__ = ['width',
                'height',
                'threshold',
                'coordinates',
                'whiteningOrder',
                ]
    __hash__ = None

    def __init__(self, width=2, height=2):
        area = width * height
        self.width = int(width)
        self.height = int(height)
        self.threshold = [None] * area
        self.coordinates = [None] * area
        self.whiteningOrder = [None] * area
        self._normalize()

    def _normalize(self):
        i = 0
        for h in range(self.height):
            y = (float(h) / (self.height - 1) * 2.0) - 1
            for w in range(self.width):
                x = (float(w) / (self.width - 1) * 2.0) - 1
                self.coordinates[i] = Point(x, y)
                self.whiteningOrder[i] = DotCell(w, h)
                i += 1

    def __str__(self):
        s = 'Halftone cell ' + str(self.width) + 'x' + str(self.height)
        s += '\n'
        for i in range(self.height):
            s += str(self.whiteningOrder[i*self.height:(i*self.height)+self.width]) + '\n'
        return s


class Tos():
    """Turn On Sequence Basic Class
        """
    def __init__(self):
        pass


class TosSpotFunction(Tos):
    """
        """
    __slot__ = ['spotFunc', 'quantize']

    def __init__(self, spotFunc, quantize=256):
        self.spotFunc = spotFunc
        self.quantize = quantize

    def fillCell(self, cell):
        for i, pt in enumerate(cell.coordinates):
            cell.whiteningOrder[i].w = self.spotFunc(pt.x, pt.y)

        #TODO: ici comme la spotfunction retourne plusieurs valeurs
        # identiques, devellopez des strategies d'odonnances final
        cell.whiteningOrder.sort()

        # quantize
        i = 0
        level = cell.width * cell.height
        for e in cell.whiteningOrder:
            i += 1
            e.w = i / level * self.quantize - 1



