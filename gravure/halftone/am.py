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
from fractions import Fraction
from decimal import *
import numeric.gmath as gm


#
# Rotation discrète bijective
#
# REPRODUCTION COULEUR PAR TRAMES
# IRREGULIERES ET SEMI-REGULIERES
# VICTOR OSTROMOUKHOV - THESE N0. 1330 (1994)
#
def irationalToRationalAngle(angle, precision=0.001):
    if precision == 0 :
        raise ValueError("precision could'not be absolut (precision==0)")
    # approximation d’un angle irrationnel A
    # par un angle rationnel Pythagoricien A' = arctan(b/a),
    # avec une précision P

    # pour un angle donné A calculer tan(A/2)
    gm.getcontext().angle = gm.ANGLE.DEGREE
    angle = Decimal(angle)
    tan = gm.tan(angle/2)

    # développer tan(A/2) en suite de fractions continues n/m
    frac = Fraction(tan)
    suite = []
    prev = None
    err = Decimal(100)
    i = 1

    # calculer les écarts entre A et arctan(b/a),
    # prendre la première approximation qui satisfait
    # le critère || A - arctan(bi/ai) ||  < E.
    # et calculer les triplets Pythagoriciens {ai; bi; ci}
    while err.copy_abs() > precision:
        tmp = frac.limit_denominator(i)
        if tmp != prev:
            # error precision
            err = angle - gm.atan(Decimal(tmp.numerator) / Decimal(tmp.denominator)) * 2

            # find pythagoricians triplet (a,b,c)
            a = tmp.denominator * tmp.denominator - tmp.numerator * tmp.numerator
            b = 2 * tmp.denominator * tmp.numerator
            c = tmp.denominator * tmp.denominator + tmp.numerator * tmp.numerator

            # reduce the triplet (a,b,c)
            gcd = pgcd(a, b, c)
            suite.append([tmp, (a//gcd, b//gcd, c//gcd), err])
        prev = tmp
        i += 1

    return suite


def pgcd(a, b, c):
    da = math.gcd(a, b)
    db = math.gcd(b, c)
    dc = math.gcd(a, c)
    if da==db and db==dc:
        return da
    else:
        return 1

def main():
    suite = irationalToRationalAngle(22.5, 0.01)
    for r in suite:
        print(r,  '\n')

if __name__ == '__main__':
    print()
    main()






