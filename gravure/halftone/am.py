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
def irationalToRationalAngle(angle, precision=0.01):
    if precision == 0 :
        raise ValueError("precision could'not be absolut (precision==0)")
    # approximation d’un angle irrationnel A
    # par un angle rationnel Pythagoricien A' = arctan(b/a),
    # avec une précision P

    # (1) pour un angle donné A calculer tan(A/2)
    gm.getcontext().angle = gm.ANGLE.DEGREE
    tan = gm.tan(Decimal(angle)/2)

    # (2) développer tan(A/2) en suite de fractions continues Ni/Mi
    frac = Fraction(tan)
    suite = []
    prev = None
    err = Decimal(100)
    i = 1

    while err.copy_abs() > precision:
        tmp = frac.limit_denominator(i)
        if tmp != prev:
            err = angle - gm.atan(Decimal(tmp.numerator) / Decimal(tmp.denominator)) * 2
            suite.append((tmp, err))
        prev = tmp
        i += 1
    print(len(suite), suite)


    # (3) calculer les triplets Pythagoriciens {ai; bi; ci}
    # en appliquant les formules 5.6


    # (4) calculer les écarts entre A et arctan(bi/ai),
    #     prendre la première approximation qui satisfait
    # le critère || A - arctan(bi/ai) ||  < E.

def main():
    irationalToRationalAngle(30)


if __name__ == '__main__':
    print()
    main()






