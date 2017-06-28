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

import gravure.numeric.gmath as gm
from gravure.halftone.base import *
from gravure.halftone.spotfunctions import *

#TODO: change to normal import in futur
#import pyximport; pyximport.install()
#from numeric.mdarray import *
import numpy as np


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

    # test build of threshold matrix
    size = 32
    c = Cell(size, size)
    TosSpotFunction(RoundDot()).fillCell(c)
    tresh = np.zeros(shape=(size * 20, size * 20), dtype=np.uint8)
    print(tresh)



if __name__ == '__main__':
    print()
    main()



###########################################
###########################################
#def findScreen(lpi, angle, xdpi, ydpi):
#    min_angle = angle -5
#    max_angle = angle + 5
#    min_lpi = lpi-10
#    max_lpi = lpi+10
#
#    r_dpi = Decimal(xdpi) / Decimal(ydpi)
#
#    tan = math.tan(math.radians(angle))
#    cell_width = Decimal(xdpi) / Decimal(lpi)
#    x_slope = Decimal(math.sin(math.radians(angle))) * Decimal(cell_width)
#    y_slope = Decimal(math.cos(math.radians(angle))) * Decimal(cell_width)
#
#    rational_tan = Fraction(x_slope/y_slope).limit_denominator(10)
#    delta_a = Decimal(tan) - (Decimal(rational_tan.numerator) / Decimal(rational_tan.denominator))
#
#    r_x_slope = Decimal(round(x_slope))
#    r_y_slope = Decimal(round(Decimal(round(y_slope / r_dpi))))
#    hr_y_slope = r_y_slope * r_dpi
#
#    delta_b = Decimal(tan) - (r_x_slope / hr_y_slope)
#
#    rational_angle = getAngle(r_x_slope, hr_y_slope)
#    result_cell_width = (r_x_slope * r_x_slope + hr_y_slope * hr_y_slope).sqrt()
#    grey_levels = (r_x_slope * r_x_slope + r_y_slope * r_y_slope) + 1
#    result_lpi = Decimal(xdpi) / result_cell_width
#
##    print ""
##    print "device resolution : %d/%d dpi" % (xdpi, ydpi)
##    print "request lpi :", lpi
##    print "request angle :", angle
##    print "tan :", tan
##    print "cell_width :", cell_width
##    print "x_slope :", x_slope
##    print "y_slope :", y_slope
##    print "best rational tan :", rational_tan
##    print "delta_a :", delta_a
##    print "delta_b :", delta_b
##    print "reverse angle :", getAngle(x_slope, y_slope)
##    print "-------------------------------------"
##    print "rational angle:", rational_angle
##    print "result lpi :", result_lpi
##    print "rational x_slope", r_x_slope
##    print "rational y_slope", r_y_slope
##    print "result cell width :", result_cell_width
##    print "grey levels number :", grey_levels
#
#
#def getAngle(x, y):
#    return math.degrees(math.atan(x/y))
#
#
