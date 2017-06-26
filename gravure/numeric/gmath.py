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

#TODO: add new functions in __notimplemented__ and __todo__
#TODO: here math functions don't take context as optional argument like in Decimal
#TODO: docstring du module et des fonctions
#TODO: unitest
#TODO: version c des fonctions (cython) ?

"""
This module provides the same mathematical functions defined by the math \
module but accept arguments of type : int, float, decimal and fractions.

This module provides mathematical functions for decimal numbers don't define
in the decimal module, like trigonometric functions (sin, cos, tang, ...).
Such functions don't map the C math function like the math module but make
internal computation with only Decimal Numbers.

For convenience functions in this module accept all real numbers (int, float,
fractions) as arguments. For int and float numbers this module provides
shortcut to the equivalent math module functions. By default, fractions
numbers when passed as argument are first converted to decimal numbers to the
current precision, eg : cos(Fraction(2,3)) == cos(Decimal(2) / Decimal(3)).
So the type of the value returns by functions depends on the type of
the given arguments. If arguments are decimal numbers return values will
be decimal, for int and float the math module almost returns float numbers.
Function without arguments like pi() returns always decimal number.

This module have Contexts defining environments for computations
and extending decimal.Context objects with few parameters. So you can use
directly the context from this module to set context for decimal arithmetic
operations. You can find the same module functions for context (getcontext(),
setcontext(), localcontext()) and the DefaultContext, BasicContext and
ExtendedContext facilities.

"""

import math as _math
import decimal as _decimal
from decimal import Decimal
from fractions import Fraction
from numbers import Number
from gravure import *


# not implemented functions present in math module
__notimplemented__= ['acosh', 'asinh', 'atanh', 'erf', 'erfc', 'expm1', 'fabs', 'factorial',
                     'fmod', 'frexp', 'fsum', 'gamma', 'gcd', 'inf', 'isclose', 'isfinite',
                     'isinf', 'isnan', 'ldexp', 'lgamma', 'log1p', 'log2', 'modf', 'nan', 'trunc']

# in decimal.Decimal and not implemented here
__todo__ = ['copy_abs', 'copy_negate', 'imag', 'ln', 'logb', 'max', 'min', 'normalize']

# already implemented in decimal.Decimal
__inDecimal__ = ['copy_sign', 'exp', 'log10', 'sqrt']

__all__ = [# Math functions
           'acos', 'asin', 'atan', 'atan2', 'ceil', 'copysign', 'cos', 'cosh',
           'degrees', 'e', 'exp', 'floor', 'hypot', 'log', 'log10',
           'pi', 'pow', 'radians', 'sign', 'sin', 'sinh', 'sqrt', 'tan', 'tanh',

           # Context
           'Context', 'BasicContext', 'DefaultContext', 'ExtendedContext',

           # Functions for manipulating contexts
           'localcontext', 'getcontext', 'setcontext']



class Context(_decimal.Context):
    """Contains the context for a Decimal instance. Inherits from decimal.context.

        :param prec: precision (for use in rounding, division, square roots..)
        :param rounding: rounding type (how you round)
        :param traps: If traps[exception] = 1, then the exception is
                               raised when it is caused.  Otherwise, a value is
                               substituted in.
        :param flags: When an exception is caused, flags[exception] is set.
                              (Whether or not the trap_enabler is set)
                              Should be reset by user of Decimal instance.
        :param Emin: Minimum exponent
        :param Emax: Maximum exponent
        :param capitals: If 1, 1*10^1 is printed as 1E+1.
                                   If 0, printed as 1e1
        :param clamp: If 1, change exponents if too high (Default 0)
        :param angle: Define unit of mesurement for angle in trigonometric functions.
                                should be gravure.ANGLE.RADIAN or gravure.ANGLE.DEGREE, default use radian.
        :param Dfraction: if True express Fractions 'f' pass to gmath functions as
                                     Decimal(f.numerator) / Decimal(f.denominator), default to True.
        """
    def __init__(self, prec=None, rounding=None, Emin=None, Emax=None, \
                 capitals=None, clamp=None, flags=None, traps=None, \
                 angle=ANGLE.RADIAN, Dfraction=True):
        _decimal.Context.__init__(self, prec=prec, rounding=rounding, Emin=Emin, \
                                 Emax=Emax, capitals=capitals, clamp=clamp, \
                                 flags=flags, traps=traps)
        self.__property = {'angle' : None, 'Dfraction' : None}
        self.angle = angle
        self.Dfraction = Dfraction

    @property
    def angle(self):
        return self.__property['angle']

    @angle.setter
    def angle(self, a):
        self.__property['angle'] = a if a in [ANGLE.DEGREE,
                           ANGLE.RADIAN] else ANGLE.RADIAN

    @property
    def Dfraction(self):
        return self.__property['Dfraction']

    @Dfraction.setter
    def Dfraction(self, b):
        self.__property['Dfraction'] = bool(b)

    def _shallow_copy(self):
        """Returns a shallow copy from self."""
        nc = Context(self.prec, self.rounding,  self.Emin, self.Emax, \
                      self.capitals, self.clamp, self.flags, self.traps, \
                      self.angle, self.Dfraction)
        return nc

    def copy(self):
        """Returns a deep copy from self."""
        nc = Context(self.prec, self.rounding, self.Emin, self.Emax, \
                      self.capitals, self.clamp, self.flags.copy(), self.traps.copy(),\
                      self.angle, self.Dfraction)
        return nc
    __copy__ = copy

    def __repr__(self):
        """Show the current context."""
        s = []
        s.append('Context(prec=%(prec)d, rounding=%(rounding)s, '
                 'Emin=%(Emin)d, Emax=%(Emax)d, capitals=%(capitals)d, '
                 'clamp=%(clamp)d'
                 % {'prec':self.prec, 'rounding':self.rounding, 'Emin':self.Emin,\
                    'Emax':self.Emax, 'capitals':self.capitals, 'clamp':self.clamp})
        names = [f.__name__ for f, v in self.flags.items() if v]
        s.append('flags=[' + ', '.join(names) + ']')
        names = [t.__name__ for t, v in self.traps.items() if v]
        s.append('traps=[' + ', '.join(names) + ']')
        s.append('angle=%s' % ['gravure.ANGLE.RADIAN','gravure.ANGLE.DEGREE'][self.angle])
        s.append('Dfraction=%s' % (bool(self.Dfraction)))
        return ', '.join(s) + ')'

    def __str__(self):
        return self.__repr__()


def __to_GContext(c):
    return Context(c.prec, c.rounding, c.Emin, c.Emax, \
                    c.capitals, c.clamp, c.flags.copy(), c.traps.copy())


def getcontext():
    c = _decimal.getcontext()
    if not isinstance(c, Context):
        c = __to_GContext(c)
        _decimal.setcontext(c)
    return c


def localcontext(c=None):
    if c is None:
        c = getcontext()
    if not isinstance(c, Context):
        c = __to_GContext(c)
    return _ContextManager(c)


def setcontext(c):
    if not isinstance(c, Context):
        c = __to_GContext(c)
    _decimal.setcontext(c)


class _ContextManager(object):
    """Context manager class to support localcontext().

      Sets a copy of the supplied context in __enter__() and restores
      the previous decimal context in __exit__()
    """
    def __init__(self, new_context):
        self.new_context = new_context.copy()
    def __enter__(self):
        self.saved_context = getcontext()
        setcontext(self.new_context)
        return self.new_context
    def __exit__(self, t, v, tb):
        setcontext(self.saved_context)


BasicContext = __to_GContext(_decimal.BasicContext)
ExtendedContext = __to_GContext(_decimal.ExtendedContext)
DefaultContext = __to_GContext(_decimal.DefaultContext)
_decimal.DefaultContext = DefaultContext


def _cast_fractions(func):
    def cast_fractions(*args):
        if getcontext().Dfraction:
            rargs = []
            for e in args:
                if isinstance(e, Fraction):
                    e = Decimal(e.numerator) / Decimal(e.denominator)
                rargs.append(e)
            return func(*rargs)
        else:
            return func(*args)
    return cast_fractions


def _cast_angles_args(func):
    def cast_angles_args(*args):
        if getcontext().angle == ANGLE.DEGREE:
            rargs = []
            for e in args:
                if isinstance(e, Number):
                    e = radians(e)
                rargs.append(e)
            return func(*rargs)
        else:
            return func(*args)
    return cast_angles_args


def _cast_return_angles(func):
    def cast_return_angles(*args):
        if getcontext().angle == ANGLE.DEGREE:
            return degrees(func(*args))
        else:
            return func(*args)
    return cast_return_angles


def pi():
    """Compute the mathematical constant π to the current precision.

    :rtype: Decimal number.

    """
    getcontext().prec += 2
    lasts, t, s, n, na, d, da = 0, Decimal(3), 3, 1, 0, 0, 24
    while s != lasts:
        lasts = s
        n, na = n + na, na + 8
        d, da = d + da, da + 32
        t = (t * n) / d
        s += t
    getcontext().prec -= 2
    return +s
PI = pi()


@_cast_fractions
def exp(x):
    """Return e**x.

    :param x: Any real numbers or decimal number.
    :type x: int, float, fraction, decimal.
    :rtype: float or decimal depending on input type.

    """
    if isinstance(x, Decimal):
        getcontext().prec += 2
        i, lasts, s, fact, num = 0, 0, 1, 1, 1
        while s != lasts:
            lasts = s
            i += 1
            fact *= i
            num *= x
            s += num / fact
        getcontext().prec -= 2
        return +s
    else:
        return _math.exp(x)
e = exp(Decimal(1))


@_cast_angles_args
@_cast_fractions
def cos(x):
    """Return the cosine of x.

    Unit of measurement for angle x depends on the context.
    Default is to express x in radians. To set unit to degrees :
    getcontext().angle = gravure.ANGLE.DEGREE

    :param x: Angle express by any real numbers or decimal number.
    :type x: int, float, fraction, decimal.
    :rtype: float or decimal depending on input type.

    """
    if isinstance(x, Decimal):
        getcontext().prec += 2
        i, lasts, s, fact, num, sign = 0, 0, 1, 1, 1, 1
        while s != lasts:
            lasts = s
            i += 2
            fact *= i * (i - 1)
            num *= x * x
            sign *= -1
            s += num / fact * sign
        getcontext().prec -= 2
        return +s
    else:
        return _math.cos(x)


@_cast_angles_args
@_cast_fractions
def sin(x):
    """Return the sine of x.

    Unit of measurement for angle x depends on the context.
    Default is to express x in radians. To set unit to degrees :
    getcontext().angle = gravure.ANGLE.DEGREE

    :param x: Angle express by any real numbers or decimal number.
    :type x: int, float, fraction, decimal.
    :rtype: float or decimal depending on input type.

    """
    if isinstance(x, Decimal):
        getcontext().prec += 2
        i, lasts, s, fact, num, sign = 1, 0, x, 1, x, 1
        while s != lasts:
            lasts = s
            i += 2
            fact *= i * (i - 1)
            num *= x * x
            sign *= -1
            s += num / fact * sign
        getcontext().prec -= 2
        return +s
    else:
        return _math.sin(x)


@_cast_fractions
def cosh(x):
    """Return the hyperbolic cosine of x.
       Result type matches input type.
    """
    if isinstance(x, Decimal):
        if x == 0:
            return Decimal(1)
        getcontext().prec += 2
        i, lasts, s, fact, num = 0, 0, 1, 1, 1
        while s != lasts:
            lasts = s
            i += 2
            num *= x * x
            fact *= i * (i - 1)
            s += num / fact
        getcontext().prec -= 2
        return +s
    else:
        return _math.cosh(x)


@_cast_fractions
def sinh(x):
    """Return the hyperbolic sine of x.
       Result type matches input type.
    """
    if isinstance(x, Decimal):
        if x == 0:
            return Decimal(0)
        getcontext().prec += 2
        i, lasts, s, fact, num = 1, 0, x, 1, x
        while s != lasts:
            lasts = s
            i += 2
            num *= x * x
            fact *= i * (i - 1)
            s += num / fact
        getcontext().prec -= 2
        return +s
    else:
        return _math.sinh(x)


@_cast_return_angles
@_cast_fractions
def asin(x):
    """Return the arc sine (measured in radians) of x.
       Result type matches input type.
    """
    if isinstance(x, Decimal):
        if abs(x) > 1:
            raise ValueError("Domain error: asin accepts -1 <= x <= 1")

        if x == -1:
            return pi() / -2
        elif x == 0:
            return Decimal(0)
        elif x == 1:
            return pi() / 2

        getcontext().prec += 2
        one_half = Decimal('0.5')
        i, lasts, s, gamma, fact, num = Decimal(0), 0, x, 1, 1, x
        while s != lasts:
            lasts = s
            i += 1
            fact *= i
            num *= x * x
            gamma *= i - one_half
            coeff = gamma / ((2 * i + 1) * fact)
            s += coeff * num
        getcontext().prec -= 2
        return +s
    else:
        return _math.asin(x)


@_cast_return_angles
@_cast_fractions
def acos(x):
    """Return the arc cosine (measured in radians) of x.
       Result type matches input type.
    """
    if isinstance(x, Decimal):
        if abs(x) > 1:
            raise ValueError("Domain error: acos accepts -1 <= x <= 1")

        if x == -1:
            return pi()
        elif x == 0:
            return pi() / 2
        elif x == 1:
            return Decimal(0)

        getcontext().prec += 2
        one_half = Decimal('0.5')
        i, lasts, s, gamma, fact, num = Decimal(0), 0, pi() / 2 - x, 1, 1, x
        while s != lasts:
            lasts = s
            i += 1
            fact *= i
            num *= x * x
            gamma *= i - one_half
            coeff = gamma / ((2 * i + 1) * fact)
            s -= coeff * num
        getcontext().prec -= 2
        return +s
    else:
        return _math.acos(x)


@_cast_fractions
def tan(x):
    """Return the tangent of angle x.
       Result type matches input type.
    """
    if isinstance(x, Decimal):
        return +(sin(x) / cos(x))
    else:
        return _math_tan(x)

@_cast_angles_args
def _math_tan(x):
    return _math.tan(x)


@_cast_fractions
def tanh(x):
    """Return the hyperbolic tangent of x.
       Result type matches input type.
    """
    if isinstance(x, Decimal):
        return +(sinh(x) / cosh(x))
    else:
        return _math.tanh(x)


@_cast_return_angles
@_cast_fractions
def atan(x):
    """Return the arc tangent (measured in radians) of Decimal x.
       Result type matches input type.
    """
    if isinstance(x, Decimal):
        if x == Decimal('-Inf'):
            return pi() / -2
        elif x == 0:
            return Decimal(0)
        elif x == Decimal('Inf'):
            return pi() / 2

        if x < -1:
            c = pi() / -2
            x = 1 / x
        elif x > 1:
            c = pi() / 2
            x = 1 / x
        else:
            c = 0

        getcontext().prec += 2
        x_squared = x ** 2
        y = x_squared / (1 + x_squared)
        y_over_x = y / x
        i, lasts, s, coeff, num = Decimal(0), 0, y_over_x, 1, y_over_x
        while s != lasts:
            lasts = s
            i += 2
            coeff *= i / (i + 1)
            num *= y
            s += coeff * num
        if c:
            s = c - s
        getcontext().prec -= 2
        return +s
    else:
        return _math.atan(x)


@_cast_fractions
def sign(x):
    """Return -1 for negative numbers and 1 for positive numbers."""
    return 2 * Decimal(x >= 0) - 1


@_cast_return_angles
@_cast_fractions
def atan2(y, x):
    """Return the arc tangent (measured in radians) of y/x.
    Unlike atan(y/x), the signs of both x and y are considered.
    Result type matches input type.
    """
    if isinstance(y, Decimal) and isinstance(x, Decimal):
        abs_y = abs(y)
        abs_x = abs(x)
        y_is_real = abs_y != Decimal('Inf')

        if x:
            if y_is_real:
                a = y and atan(y / x) or Decimal(0)
                if x < 0:
                    a += sign(y) * pi()
                return a
            elif abs_y == abs_x:
                x = sign(x)
                y = sign(y)
                return pi() * (Decimal(2) * abs(x) - x) / (Decimal(4) * y)
        if y:
            return atan(sign(y) * Decimal('Inf'))
        elif x < 0:
            return sign(y) * pi()
        else:
            return Decimal(0)
    else:
        return _math.atan2(x, y)


@_cast_fractions
def log(x, base=None):
    """Return the logarithm of x to the given Decimal base.

    If the base is not specified, returns the natural logarithm (base e) of x.

    :param x: Any real numbers or decimal number.
    :type x: int, float, fraction, decimal.
    :param base: Optional base.
    :type base: int, float, fraction, decimal or None.
    :rtype: float or decimal depending on input type.

    """
    if isinstance(x, Decimal):
        if x < 0:
            return Decimal('NaN')
        elif base == 1:
            raise ValueError("Base was 1!")
        elif x == base:
            return Decimal(1)
        elif x == 0:
            return Decimal('-Inf')

        getcontext().prec += 2

        if base is None:
            log_base = 1
            approx = _math.log(x)
        else:
            log_base = log(base)
            approx = _math.log(x, base)

        lasts, s = 0, Decimal(repr(approx))
        while lasts != s:
            lasts = s
            s = s - 1 + x / exp(s)
        s /= log_base
        getcontext().prec -= 2
        return +s
    else:
        return _math.log(x, base)


def log10(x):
    """Return the base 10 logarithm of Decimal x.

    :param x: Any real numbers or decimal number.
    :type x: int, float, fraction, decimal.
    :rtype: float or decimal depending on input type.

    """
    return log(x, Decimal(10))


@_cast_fractions
def sqrt(x):
    """Return the square root of x.

    :param x: Any real numbers or decimal number.
    :type x: int, float, fraction, decimal.
    :rtype: float or decimal depending on input type.

    """
    if isinstance(x, Decimal):
        return Decimal.sqrt(x)
    else:
        return _math.sqrt(x)


@_cast_fractions
def pow(x, y):
    """Return x raised to the power y.

    :param x: Any real numbers or decimal number.
    :type x: int, float, fraction, decimal.
    :param y: Any real numbers or decimal number.
    :type y: int, float, fraction, decimal.
    :rtype: float or decimal depending on input type.

    """
    if isinstance(x, Decimal) or isinstance(y, Decimal):
        raise x ** y
    else:
        return _math.pow(x, y)


@_cast_fractions
def degrees(x):
    """degrees(x) -> converts Decimal angle x from radians to degrees
    Result type matches input type.
    """
    if isinstance(x, Decimal):
        return +(x * 180 / pi())
    else:
        return _math.degrees(x)


@_cast_fractions
def radians(x):
    """radians(x) -> converts Decimal angle x from degrees to radians
    Result type matches input type.
    """
    if isinstance(x, Decimal):
        return +(x * pi() / 180)
    else:
        return _math.radians(x)


@_cast_fractions
def ceil(x):
    """Return the smallest integral value >= x.

    :param x: Any real numbers or decimal number.
    :type x: int, float, fraction, decimal.
    :rtype: int or decimal depending on input type.

    """
    if isinstance(x, Decimal):
        return x.to_integral(rounding=_decimal.ROUND_CEILING)
    else:
        return _math.ceil(x)


@_cast_fractions
def floor(x):
    """Return the largest integral value <= x.

    :param x: Any real numbers or decimal number.
    :type x: int, float, fraction, decimal.
    :rtype: int or decimal depending on input type.

    """
    if isinstance(x, Decimal):
        return x.to_integral(rounding=_decimal.ROUND_FLOOR)
    else:
        return _math.floor(x)


@_cast_fractions
def hypot(x, y):
    """Return the Euclidean distance, sqrt(x*x + y*y)."""
    if isinstance(x, Decimal) and isinstance(y, Decimal):
        return sqrt(x * x + y * y)
    else:
        return _math.hypot(x, y)


@_cast_fractions
def copysign(x, y):
    """Return x with the sign of y.

    :param x: Any real numbers or decimal number.
    :type x: int, float, fraction, decimal.
    :param y: Any real numbers or decimal number.
    :type y: int, float, fraction, decimal.
    :rtype: int, float or decimal depending on input type.

    """
    if isinstance(x, Decimal):
        return x.copy_sign(y)
    else:
        return _math.copysign(x, y)


def main():

    a = _math.cos(_math.radians(45))
    print("math.cos(math.radians(45))  ", a)

    b = cos(_math.radians(45))
    print("cos(math.radians(45))       ", b)

    c = cos(radians(Decimal(45)))
    print("cos(radians(Decimal(45)))   ", c)

    print("Context angle", ['radian', 'degree'][getcontext().angle])

    c = cos(Decimal(45))
    print("cos(Decimal(45))            ", c)

    getcontext().angle = ANGLE.DEGREE
    print("Context angle", ['radian', 'degree'][getcontext().angle])

    c = cos(Decimal(45))
    print("cos(Decimal(45))            ", c)

    with localcontext() as lc:
        lc.angle = ANGLE.RADIAN
        c = cos(Decimal(45))
        print("cos(Decimal(45))            ", c)

    d = cos(Fraction(2, 3))
    print("cos(Fraction(2,3))          ", d)

    d = cos(Decimal(2) / Decimal(3))
    print("cos(Decimal(2) / Decimal(3))", d)

    d = cos(2/3)
    print("cos(2/3)                    ", d)

if __name__ == "__main__":
    main()
