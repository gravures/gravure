# -*- coding: utf-8 -*-

# Copyright (C) 2011 Atelier Obscur.
# Authors:
# Gilles Coissac <dev@atelierobscur.org>

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

from decimal import Decimal
import gravure.numeric.gmath as gm
from gravure.gravure import POLARITY


__all__ = ['CosineDot', 'Cross', 'Diamond', 'Double', 'DoubleDot', 'Ellipse', 'EllipseA', \
        'EllipseB', 'EllipseC','EllipseBlischke', 'HillDot', 'Line', 'LineX', 'LineY', \
        'Rhomboid', 'RoundDot', 'SimpleDot', 'SpotFunction', 'Square']

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

    def __init__(self, polarity=POLARITY.ADDITIVE):
        if not issubclass(POLARITY, type(polarity)):
            raise TypeError('Polarity should be a value of Enum POLARITY.')
        self.polarity = polarity

    @staticmethod
    def _checkBounds(func):
        def _checkBounds(*args, **kwargs):
            x = args[1]
            y = args[2]
            if x < -1.0 or x > 1.0 or y < -1.0 or y > 1.0:
                raise ValueError("x and y function arguments \
                should lie in the range [-1.0, 1.0]")
            return func(*args, **kwargs)
        return _checkBounds

    def _checkFloat(self, f, x, y):
        if isinstance(x, Decimal) or isinstance(y, Decimal):
            return Decimal(str(f))
        else:
            return f

    @staticmethod
    def _cast_polarity(func):
        def cast_polarity(*args, **kwargs):
            if args[0].polarity:
                return 1 - func(*args, **kwargs)
            else:
                return func(*args, **kwargs)
        return cast_polarity

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

    @SpotFunction._cast_polarity
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

    @SpotFunction._cast_polarity
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

    @SpotFunction._cast_polarity
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

    @SpotFunction._cast_polarity
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

    @SpotFunction._cast_polarity
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

    @SpotFunction._cast_polarity
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

    @SpotFunction._cast_polarity
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

    @SpotFunction._cast_polarity
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

    @SpotFunction._cast_polarity
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

    @SpotFunction._cast_polarity
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


class Diamond(SpotFunction):
    """Diamond spotFunction.
    """
    __doc__ += SpotFunction._DOC_SIGN
    __name__ = 'Diamond'

    @SpotFunction._cast_polarity
    @SpotFunction._checkBounds
    def __call__(self, x, y):
        raise NotImplementedError

    @classmethod
    def postscript(cls):
        body = """
{
  abs exch abs
  2 copy add
  .75 le
  {
  dup mul exch
  dup mul add
  1 exch sub
  }
  { 2 copy add
  1.23 le
  { .85 mul add
  1 exch sub
  }
  { 1 sub dup
  mul exch 1
  sub dup mul
  add 1 sub
  }
  ifelse
  }
  ifelse
}"""
        ps = "/" + cls.__name__ + body
        return ps


class Double(SpotFunction):
    """Double spotFunction.
    """
    __doc__ += SpotFunction._DOC_SIGN
    __name__ = 'Double'

    @SpotFunction._cast_polarity
    @SpotFunction._checkBounds
    def __call__(self, x, y):
        raise NotImplementedError

    @classmethod
    def postscript(cls):
        body = """
{
  exch 2 div
  exch 2
  {
  360 mul sin
  2 div exch
  }
  repeat add
}"""
        ps = "/" + cls.__name__ + body
        return ps


class DoubleDot(SpotFunction):
    """DoubleDot spotFunction.
    """
    __doc__ += SpotFunction._DOC_SIGN
    __name__ = 'DoubleDot'

    @SpotFunction._cast_polarity
    @SpotFunction._checkBounds
    def __call__(self, x, y):
        raise NotImplementedError

    @classmethod
    def postscript(cls):
        body = """
{
  2
  {
  360 mul sin
  2 div exch
  }
  repeat add
}"""
        ps = "/" + cls.__name__ + body
        return ps


class EllipseA(SpotFunction):
    """EllipseA spotFunction.
    """
    __doc__ += SpotFunction._DOC_SIGN
    __name__ = 'EllipseA'

    def __init__(self, junction=65, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if junction<1 or junction>99:
            raise ValueError('junction value should be between 1 and 99')
        self.junction /= 100

    @SpotFunction._cast_polarity
    @SpotFunction._checkBounds
    def __call__(self, x, y):
        raise NotImplementedError

    @classmethod
    def postscript(cls):
        body = """
{
  dup mul .9
  mul exch dup
  mul add 1
  exch sub
}"""
        ps = "/" + cls.__name__ + body
        return ps

class EllipseB(SpotFunction):
    """EllipseB spotFunction.
    """
    __doc__ += SpotFunction._DOC_SIGN
    __name__ = 'EllipseB'

    def __init__(self, junction=65, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if junction<1 or junction>99:
            raise ValueError('junction value should be between 1 and 99')
        self.junction /= 100

    @SpotFunction._cast_polarity
    @SpotFunction._checkBounds
    def __call__(self, x, y):
        raise NotImplementedError

    @classmethod
    def postscript(cls):
        body = """
{
  dup 5 mul
  8 div mul
  exch dup mul
  exch add sqrt
  1 exch sub
}"""
        ps = "/" + cls.__name__ + body
        return ps


#FIXME: orifginal ps code buggy
class EllipseC(SpotFunction):
    """EllipseC spotFunction.
    """
    __doc__ += SpotFunction._DOC_SIGN
    __name__ = 'EllipseC'

    def __init__(self, junction=65, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if junction<1 or junction>99:
            raise ValueError('junction value should be between 1 and 99')
        self.junction /= 100

    @SpotFunction._cast_polarity
    @SpotFunction._checkBounds
    def __call__(self, x, y):
        raise NotImplementedError

    @classmethod
    def postscript(cls):
        body = """
{
  dup .5 gt
  { 1 exch sub } if
  dup .25 ge
  { .5 exch sub 4 mul dup mul 1 sub }
  { 4 mul dup mul 1 exch sub } ifelse
  exch dup .5 gt
  { 1 exch sub } if
  dup .25 ge
  { .5 exch sub 4 mul dup mul 1 sub }
  { 4 mul dup mul 1 exch sub } ifelse
  add -2 div
}"""
        ps = "/" + cls.__name__ + body
        return ps


class Ellipse(SpotFunction):
    """Ellipse spotFunction.
    """
    __doc__ += SpotFunction._DOC_SIGN
    __name__ = 'Ellipse'

    def __init__(self, junction=65, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if junction<1 or junction>99:
            raise ValueError('junction value should be between 1 and 99')
        self.junction /= 100

    @SpotFunction._cast_polarity
    @SpotFunction._checkBounds
    def __call__(self, x, y):
        raise NotImplementedError

    @classmethod
    def postscript(cls):
        body = """
{
  abs exch abs
  2 copy 3 mul
  exch 4 mul add
  3 sub dup 0 lt
  {
  pop dup mul
  exch .80 div
  dup mul add
  4 div
  1 exch sub
  }
  {
  dup 1 gt
  {
  pop 1 exch
  sub dup mul
  exch 1 exch sub
  .80 div dup mul add
  4 div 1 sub
  }
  {
  .5 exch sub
  exch pop exch pop
  } ifelse
  } ifelse
}"""
        ps = "/" + cls.__name__ + body
        return ps


class EllipseBlischke(SpotFunction):
    """Ellipse Blischke spotFunction.
    """
    __doc__ += SpotFunction._DOC_SIGN
    __name__ = 'EllipseBlischke'

    def __init__(self, junction=65, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if junction<1 or junction>99:
            raise ValueError('junction value should be between 1 and 99')
        self.junction /= 100

    @SpotFunction._cast_polarity
    @SpotFunction._checkBounds
    def __call__(self, x, y):
        raise NotImplementedError

    @classmethod
    def postscript(cls):
        body = """
{
  exch abs exch
  abs 2 copy 0.65 mul
  add 0.65 lt
  {
  exch 0.65 div
  dup dup mul
  exch 2 mul
  3 sub mul exch
  dup dup mul
  exch 2 mul 3
  sub mul add
  0.65 mul 1 add
  }
  { 2 copy 0.65
  mul add 1 gt
    {
    1 sub exch
    1 sub 0.65
    div dup dup
    mul exch 2
    mul 3 add mul
    exch dup dup
    mul exch 2 mul
    3 add mul add
    0.65 mul 1 sub
    }
    { 0.65 mul add
    2 mul neg 1
    add 0.65 add
    }
    ifelse
  }
  ifelse
}"""
        ps = "/" + cls.__name__ + body
        return ps


