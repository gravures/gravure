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

#TODO:  * copyright et licence
#       * docstring pertinantes des fonctions
#       * unitest
#FIXME: help(spotfunction) raise IndexError: list index out of range

"""This is a python implementation of classical postscript spot functions.

Consider a halftone cell to have its own coordinate system:
the center of the cell is the origin and the corners are at
coordinates ±1.0 horizontally and vertically. Each pixel in
the cell is centered at horizontal and vertical coordinates
that both lie in the range −1.0 to +1.0. For each pixel, the
spotfunction is call with its x and y coordinate as arguments.
The function must return a single number in the range −1.0
to +1.0 that defines the pixel’s position in the whitening
order.
The specific values the spot function returns are not
significant ; all that matters is the relative values returned
for different pixels. As a cell’s gray level varies from
black to white, the first pixel whitened is the one for which
the spot function returns the lowest value, the next pixel
is the one with the next higher spot function value, and so on.
If two pixels have the same spot function value, their relative
order is chosen arbitrarily.
All functions in this module accept decimal number as arguments
and ensure in this case complete arithmetic with decimal module
and return a decimal type Number.
All callable object representing spot functions have a postscript()
method that returns a string containing an equivalent valid postscript code.
The postscript code begin with a name definition of the spot function
followed by the postscript procedure. ex :

>>>print(SimpleDot.postscript())
/SimpleDot
{
  dup mul
  exch dup
  mul add 1
  exch sub
}

"""


__all__ = ['SpotFunction', 'CosineDot', 'Cross', 'HillDot', 'Line',
           'LineX', 'LineY', 'Rhomboid', 'RoundDot', 'SimpleDot', 'Square']


from decimal import Decimal
import gravure.gmath as gm


class SpotFunction():
    """This is the abstract base class for all spot functions in this module.

    Real spot functions should implement a __call__ method that takes
    two arguments, x and y. They should return a single number in the range
    -1.0 to 1.0.
    Spot functions should check that both x and y parameters bind in the
    range -1.0 to 1.0. For this purpose this abstract class provide
    a decorator, @_checkBounds.
    __call__ method should ensure that computation could be done
    both in floating point and Decimal arithmetic depending on input type.
    Finally, spot functions should implements a postscript() class method
    that returns a string containing an equivalent valid postscript code.
    """

    _DOC_SIGN = ":param x: horizontal coordinate in the range −1.0 to +1.0\n\
    :param y: vertical coordinate in the range −1.0 to +1.0\n\
    :returns: number in the range −1.0 to +1.0\n\
    :rtype: float or decimal depending on input type.\n\
    :raises: ValueError\n"

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

    def postscript(cls):
        raise NotImplementedError

    def __repr__(self):
        return self.__name__ + "()"


class LineX(SpotFunction):
    """LineX spotFunction.
    """
    __doc__ += SpotFunction._DOC_SIGN
    __name__ = 'LineX'

    @SpotFunction._checkBounds
    def __call__(self, x, y):
        return x

    @classmethod
    def postscript(cls):
        ps = "/" + cls.__name__ + "\n{\n  pop\n}"
        return ps


class LineY(SpotFunction):
    """LineY spotFunction.
    """
    __doc__ += SpotFunction._DOC_SIGN
    __name__ = 'LineY'

    @SpotFunction._checkBounds
    def __call__(self, x, y):
        return y

    @classmethod
    def postscript(cls):
        ps = "/" + cls.__name__ + "\n{\n  exch pop\n}"
        return ps


class Line(SpotFunction):
    """Line spotFunction.
    """
    __doc__ += SpotFunction._DOC_SIGN
    __name__ = 'Line'

    @SpotFunction._checkBounds
    def __call__(self, x, y):
        return - abs(y)

    @classmethod
    def postscript(cls):
        body = """
{
  exch pop
  abs neg
}"""
        ps = "/" + cls.__name__ + body
        return ps


class SimpleDot(SpotFunction):
    """SimpleDot spotFunction.
    """
    __doc__ += SpotFunction._DOC_SIGN
    __name__ = 'SimpleDot'

    @SpotFunction._checkBounds
    def __call__(self, x, y):
        y *= y
        x *= x
        return 1 - (x + y)

    @classmethod
    def postscript(cls):
        body = """
{
  dup mul
  exch dup
  mul add 1
  exch sub
}"""
        ps = "/" + cls.__name__ + body
        return ps


class CosineDot(SpotFunction):
    """CosineDot spotFunction.
    """
    __doc__ += SpotFunction._DOC_SIGN
    __name__ = 'CosineDot'

    @SpotFunction._checkBounds
    def __call__(self, x, y):
        y = gm.cos(y * 180)
        x = gm.cos(x * 180)
        return (y + x) / 2

    @classmethod
    def postscript(cls):
        body = """
{
  180 mul cos
  exch 180 mul
  cos add 2 div
}"""
        ps = "/" + cls.__name__ + body
        return ps


class RoundDot(SpotFunction):
    """RoundDot spotFunction.
    """
    __doc__ += SpotFunction._DOC_SIGN
    __name__ = 'RoundDot'

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

    @classmethod
    def postscript(cls):
        body = """
{
  abs exch
  abs 2 copy add
  1 le
  {
    dup mul
    exch dup
    mul add
    1 exch sub
  }
  {
    1 sub
    dup mul
    exch 1 sub
    dup mul add
    1 sub
  } ifelse
}"""
        ps = "/" + cls.__name__ + body
        return ps


class HillDot(SpotFunction):
    """HillDot spotFunction.
    """
    __doc__ += SpotFunction._DOC_SIGN
    __name__ = 'HillDot'

    @SpotFunction._checkBounds
    def __call__(self, x, y):
        a = self._checkFloat(0.1, x, y)
        x *= x
        y *= y
        return 1 / ((x + y) * 20 + 1) - a

    @classmethod
    def postscript(cls):
        body = """
{
  exch
  % y | x
  dup mul
  % y | x*x
  exch
  % x*x | y
  dup mul
  % x*x | y*y
  add 20 mul 1 add
  % ((x*x + y*y)*20)+1
  1 exch div
  0.1 sub
}"""
        ps = "/" + cls.__name__ + body
        return ps


class Rhomboid(SpotFunction):
    """Rhomboid spotFunction.
    """
    __doc__ += SpotFunction._DOC_SIGN
    __name__ = 'Rhomboid'

    @SpotFunction._checkBounds
    def __call__(self, x, y):
        a = self._checkFloat(0.9, x, y)
        x = abs(x) * a
        y = abs(y)
        return (x + y) / 2

    @classmethod
    def postscript(cls):
        body = """
{
  abs exch
  abs 0.9 mul
  add 2 div
}"""
        ps = "/" + cls.__name__ + body
        return ps


class Square(SpotFunction):
    """Square spotFunction.
    """
    __doc__ += SpotFunction._DOC_SIGN
    __name__ = 'Square'

    @SpotFunction._checkBounds
    def __call__(self, x, y):
        x = abs(x)
        y = abs(y)
        if (y < x):
            z = - x
        else:
            z = - y
        return z

    @classmethod
    def postscript(cls):
        body = """
{
  abs exch
  abs 2
  copy
  lt { exch } if
  pop neg
}"""
        ps = "/" + cls.__name__ + body
        return ps


class Cross(SpotFunction):
    """Cross spotFunction.
    """
    __doc__ += SpotFunction._DOC_SIGN
    __name__ = 'Cross'

    @SpotFunction._checkBounds
    def __call__(self, x, y):
        x = abs(x)
        y = abs(y)
        if (y > x):
            z = - x
        else:
            z = - y
        return z

    @classmethod
    def postscript(cls):
        body = """
{
  abs exch
  abs 2
  copy
  gt { exch } if
  pop neg
}"""
        ps = "/" + cls.__name__ + body
        return ps
