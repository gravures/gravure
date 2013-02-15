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
__date__ = "Tue Feb 12 18:23:45 2013"
__version__ = "$Revision: 0.1 $"
__credits__ = "Atelier Obscur : www.atelierobscur.org"


#TODO:  * copyright et licence
#       * docstring du module et des fonctions
#       * unitest
#       * version c des fonctions (cython) ?


import math
import decimal
from decimal import Decimal, getcontext


def pi():
    """Compute Pi to the current precision."""
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
pi = pi()


def exp(x):
    """Return e raised to the power of x.
    Result type matches input type.
    """
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
e = exp(Decimal(1))


def cos(x):
    """Return the cosine of x as measured in radians.
       Result type matches input type.
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
        return math.cos(x)


def sin(x):
    """Return the sine of x as measured in radians.
       Result type matches input type.
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
        return math.sin(x)


def cosh(x):
    """Return the hyperbolic cosine of Decimal x.
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
        return math.cosh(x)


def sinh(x):
    """Return the hyperbolic sine of Decimal x.
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
        return math.sinh(x)


def asin(x):
    """Return the arc sine (measured in radians) of Decimal x.
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
        return math.asin(x)


def acos(x):
    """Return the arc cosine (measured in radians) of Decimal x.
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
        return math.acos(x)


def tan(x):
    """Return the tangent of Decimal x (measured in radians).
       Result type matches input type.
    """
    if isinstance(x, Decimal):
        return +(sin(x) / cos(x))
    else:
        return math.tan(x)


def tanh(x):
    """Return the hyperbolic tangent of Decimal x.
       Result type matches input type.
    """
    if isinstance(x, Decimal):
        return +(sinh(x) / cosh(x))
    else:
        return math.tanh(x)


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
        return math.atan(x)


def sign(x):
    """Return -1 for negative numbers and 1 for positive numbers."""
    return 2 * Decimal(x >= 0) - 1


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
        return math.atan2(x, y)


def log(x, base=None):
    """log(x[, base]) -> the logarithm of Decimal x
    to the given Decimal base. If the base not specified,
    returns the natural logarithm (base e) of x.
    Result type matches input type.
    """
    if isinstance(x, Decimal) and isinstance(x, base):
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
            approx = math.log(x)
        else:
            log_base = log(base)
            approx = math.log(x, base)

        lasts, s = 0, Decimal(repr(approx))
        while lasts != s:
            lasts = s
            s = s - 1 + x / exp(s)
        s /= log_base
        getcontext().prec -= 2
        return +s
    else:
        return math.log(x, base)


def log10(x):
    """log10(x) -> the base 10 logarithm of Decimal x.
    Result type matches input type.
    """
    return log(x, Decimal(10))


def sqrt(x):
    """Return the square root of x.
    Result type matches input type.
    """
    if isinstance(x, Decimal):
        return Decimal.sqrt(x)
    else:
        return math.sqrt(x)


def pow(x, y):
    """Return x raised to the power y.
    Result type matches input type.
    """
    if isinstance(x, Decimal):
        raise NotImplementedError
    else:
        return math.pow(x, y)


def degrees(x):
    """degrees(x) -> converts Decimal angle x from radians to degrees
    Result type matches input type.
    """
    if isinstance(x, Decimal):
        return +(x * 180 / pi())
    else:
        return math.degrees(x)


def radians(x):
    """radians(x) -> converts Decimal angle x from degrees to radians
    Result type matches input type.
    """
    if isinstance(x, Decimal):
        return +(x * pi() / 180)
    else:
        return math.radians(x)


def ceil(x):
    """Return the smallest integral value >= x.
    Result type matches input type.
    """
    if isinstance(x, Decimal):
        return x.to_integral(rounding=decimal.ROUND_CEILING)
    else:
        return math.ceil(x)


def floor(x):
    """Return the largest integral value <= x.
    Result type matches input type.
    """
    if isinstance(x, Decimal):
        return x.to_integral(rounding=decimal.ROUND_FLOOR)
    else:
        return math.floor(x)


def hypot(x, y):
    """Return the Euclidean distance, sqrt(x*x + y*y)."""
    if isinstance(x, Decimal) and isinstance(y, Decimal):
        return sqrt(x * x + y * y)
    else:
        return math.hypot(x, y)


__all__ = ['acos', 'asin', 'atan', 'atan2', 'ceil', 'cos', 'cosh', 'degrees',
           'e', 'exp', 'floor', 'hypot', 'log', 'log10', 'pi',
           'pow', 'radians', 'sign', 'sin', 'sinh', 'sqrt', 'tan', 'tanh']