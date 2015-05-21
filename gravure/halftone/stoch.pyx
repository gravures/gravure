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

#TODO: make user documentaion
#TODO: make tests
#TODO: define an interface for module that produce threshold array
#TODO: make module for quality metric tools like fourrier transform, etc
#TODO: make a screen designer UI with screenprint data
#TODO: work on dotshape
#TODO: implement min_black_dot & min_white_dot
#TODO: implement gamma correction
#TODO: save as postscript
#TODO: implement dynamic parameters : threshold, bias, ...
#TODO: check bit depth output
#TODO: optimisation, release the gil when possible
#NOTE: what about inkjet overlap dot model


import cython
cimport cython

from PIL import Image
import pyximport; pyximport.install()
import numeric.mdarray as md
from spotfunctions import *

cdef extern from "stdlib.h" nogil:
    # 7.20.2 Pseudo-random sequence generation functions
    enum: RAND_MAX
    int rand ()
    void srand (unsigned int SEED)

    # 7.20.5 Searching and sorting utilities
    void qsort (void *ARRAY, size_t COUNT, size_t SIZE,
                int (*COMPARE)(const void *, const void *))

    # 7.20.6 Integer arithmetic functions
    int c_abs "abs" (int number)
    double c_floor "floor"(double x)

cdef extern from"math.h" nogil:
    double c_pow "pow"(double x, double y)


DEF	MAX_ARRAY_WIDTH = 512
DEF	MAX_ARRAY_HEIGHT = 512
DEF BIG_FLOAT = 999999999.0
DEF MAX_DOT = 16

cdef int threshold_array [MAX_ARRAY_WIDTH][MAX_ARRAY_HEIGHT]
cdef double	values_array [MAX_ARRAY_WIDTH * MAX_ARRAY_HEIGHT]
cdef double min_value = 0.0
cdef double max_value = 0.0
cdef double value_range = 0.0
cdef bint data_is_ready = False
cdef int level
cdef double top_level

ctypedef struct order_t:
    int x
    int y

cdef order_t tos[MAX_ARRAY_WIDTH * MAX_ARRAY_HEIGHT]
cdef order_t dot_tos [MAX_DOT * MAX_DOT]
cdef int dotshape_array [MAX_DOT][MAX_DOT]
cdef int mark_array [MAX_ARRAY_WIDTH][MAX_ARRAY_HEIGHT]

cdef int resolution [2]
cdef int array_width, array_height


#
# Python interface for the screening process
#TODO: make doc string
def make_screen(res=(720,720), min_black_dot=4, min_white_dot=2,
                                dot_size=8, spotfnc=RoundDot, level=256, threshold=80,
                                bias=1.0, seed=13, quiet=False):
    global resolution, top_level
    global tos, threshold_array, values_array
    global array_width, array_height, dotshape_array
    cdef double thresh
    cdef int width, height
    cdef unsigned int x, y, i, q_level
    cdef double arr_level, max_level, tmp

    #TODO: test params validity
    #TODO: set some params like array size from
    #some user need like minimum quantization level
    #or aspect quality, etc
    if res[0] > res[1]:
        resolution[0] = <int> (res[0] / res[1])
        resolution[1] = 1
    elif res[0] < res[1]:
        resolution[1] = <int> (res[1] / res[0])
        resolution[0] = 1
    else:
        resolution[0] = 1
        resolution[1] = 1

    thresh = threshold / 1000.0
    width = 150
    height = 150
    _make_dotshape(spotfnc, dot_size)
    max_level =  255
    arr_level = width * height
    top_level = arr_level - 1

    _make_screen(width=width, height=height, \
            value_thresh=thresh, bias_power=bias, \
            seed=seed, quiet=quiet, dot_size=dot_size)

    # OUTPUT IMAGE
    #normalize threshold array to 8 bit depth
    my_array = md.mdarray(shape=(array_width, array_height),format="=u1")

    for x in xrange(array_width):
        for y in xrange(array_height):
            tmp = ((<double> threshold_array[x][y]) / arr_level) * max_level
            if tmp<0 :
                print "dot bug placement"
                tmp = 0
            q_level = <unsigned int> (c_floor(tmp) )
            my_array[x, y] = q_level

    my_array.reshape((array_width * array_height))
    image_thresh = Image.frombuffer(mode='L',
                size=(array_width, array_height), data=my_array.memview)
    img_file = open("/home/gilles/TEST/thres_out.pgm", mode="wb", closefd=True)
    image_thresh.save(img_file)

# print out threshold array
cdef _print_threshold():
    global array_width, array_height, threshold_array
    strout = ""
    for y in xrange(array_height):
        for x in xrange(array_width):
            strout += " %3d\t\t" % (threshold_array[x][y])
            if (x & 15) == 15:
                strout += "\n"
        if (x & 15) != 0:
            strout += "\n"
    print strout

cdef  _make_dotshape(spotfnc, dot_size):
    # TODO: make apect ratio implementation
    global dotshape_array, dot_tos, max_dot_size
    cdef int i, j, xp, yp
    cdef double z, w, x, y
    cdef object sp

    # Fill the cell with spot function
    sp = spotfnc()
    z = 2.0 / (dot_size - 1)
    for i in xrange(dot_size):
        x = -1.0 + z * i
        for j in xrange(dot_size):
            y = -1.0 + z * j
            w = sp(x,y)
            dotshape_array[i][j] = <int> ((w + 1) / 2.0 * dot_size * dot_size)
            dot_tos[i * dot_size + j].x = i
            dot_tos[i * dot_size + j].y = j

    # Build the whitening order
    qsort(<void *> dot_tos, dot_size * dot_size, sizeof(order_t), compare_tos)

    # update mindot coordinates relative to the center of the cell
    # center is the first mindot in the whitening order
    xp = dot_tos[0].x
    yp = dot_tos[0].y
    for i in xrange(dot_size * dot_size):
        dot_tos[i].x = dot_tos[i].x - xp
        dot_tos[i].y = dot_tos[i].y - yp

cdef int compare_tos(const void *vp, const void *vq) nogil:
    global dotshape_array
    cdef order_t *p = <order_t *> vp
    cdef order_t *q = <order_t *> vq
    cdef int pi, qi, retval = 0

    pi = dotshape_array[p.x] [p.y]
    qi = dotshape_array[q.x] [q.y]
    if pi < qi:
       retval = 1
    elif pi > qi:
       retval = -1
    return retval

cdef int image_value_map():
    global min_value, max_value, value_range, array_width
    global array_height, values_array, tos, level
    cdef unsigned int x, y, i, q_level
    cdef double arr_level, max_level, tmp

    #normalize array to 8 bit depth
    my_array = md.mdarray(shape=(array_width, array_height),format="=u1")
    max_level =  255
    arr_level = array_width * array_height

    for x in xrange(array_width):
        for y in xrange(array_height):
            tmp = values_array[y * array_width + x]
            if tmp == BIG_FLOAT :
                tmp = 0
            else:
                tmp = max_level - ((tmp / max_value) * max_level)
            q_level = <unsigned int> c_floor(tmp)
            my_array[x, y] = q_level

    my_array.reshape((array_width * array_height))
    image_thresh = Image.frombuffer(mode='L',
                size=(array_width, array_height), data=my_array.memview)
    img_file = open("/home/gilles/TEST/map/map_%d.pgm" % (level,), mode="wb", closefd=True)
    image_thresh.save(img_file)


# width, height:
# size of threshold_array
#
#
# value_thresh
# sets the choice value threshold in 0.1% units (default 50 = 5%)
#
# bias_power:
# power for exponential bias of random choice. Default 1.0
#
# seed
# Initial seed for random number generation. Useful to generate
# decorrelated threshold arrays to be used with different colors.
#
# quiet:
# if quiet is false output some statistic
cdef int _make_screen(int width, int height, double value_thresh,
                                        double bias_power, int seed, bint quiet, int dot_size):
    global min_value, max_value, value_range, array_width
    global array_height, resolution, threshold_array
    global values_array, tos, top_level
    global level, dotshape_array, mark_array

    cdef int i, j, k, m, choice_range,x, y, ox, oy
    cdef int choice, choice_x, choice_y, mx, my
    cdef int sort_range, do_min_dot, order, dist
    cdef int row, dot, cx, cy, userow, dot_depth
    cdef double	value, rand_scaled, rx_sq, ry_sq
    cdef int err_code = 0, array_size

    # TODO: update when dealing with non square ratio
    dot_depth = dot_size * dot_size
    array_size = array_width * array_height

    # allows for horizontal / vertical resolution, e.g. -r2x1
    # values are used for aspect ratio -- actual values arbitrary
    rx_sq = resolution[0] * resolution[0]
    ry_sq = resolution[1] * resolution[1]

    #	Initialize master threshold array
    array_width = width
    array_height = height
    if array_size> MAX_ARRAY_WIDTH * MAX_ARRAY_HEIGHT:
        print "Array size is too large, max width = %d, max height = %d\n"  \
                % (MAX_ARRAY_WIDTH, MAX_ARRAY_HEIGHT)
        return 1

    # initialize the threshold_array to  -1
    # (an invalid value) for unfilled dots
    # Initialize the tos array
    for y in xrange(array_height):
        for x in xrange(array_width):
            tos[y * array_width + x].x = x
            tos[y * array_width + x].y = y
            values_array[y * array_width + x ] = 0.0
            threshold_array[x][y] = -1
            mark_array[x][y] = -1

    # Create an ordered list of values
    sort_range = array_width * array_height
    min_value = 0.0
    max_value = 0.0
    value_range = 1.0
    level = 0

    while level < (array_size):
        # We focus the processing on the first "SortRange" number of
        # elements to speed up the processing. The SortRange starts
        # at the full array size, then is reduced to a smaller value

        # sort the list of values in the tos

        # random seed
        seed += 1
        srand(seed)
        qsort(<void *> tos, sort_range, sizeof(order_t), compare_order)
        sort_range = array_size - level
        choice_range = 0

        for i in xrange(sort_range):
            value = values_array[tos[i].y * array_width + tos[i].x]
            value = (value - min_value) / value_range
            if value > value_thresh:
                break
            choice_range += 1

        # Now select the next pixel using a random number
        #
        # Limit the choice to the 1/10 of the total number
        # of points or those points less than "value_thresh"
        # whichever is smaller
        #TODO: put the divisor in user parameter
        if choice_range > array_size / 10:
            choice_range = array_size / 10

        # Choose from among the 'acceptable' points
        rand_scaled = <double> rand() / <double> RAND_MAX
        choice = <int> (<double> choice_range * c_pow(rand_scaled, bias_power))
        mx = choice_x = tos[choice].x
        my = choice_y = tos[choice].y

        # if minimum dot size is set, modify the choice
        # depending on the neighboring dots.
        # If the edge of the expanded dot is adajcent
        # to a dot aleady 'on', then increase the size
        # of that dot instead
        do_min_dot = 1
        #TODO: put the distance in user parameter
        distance = <long> (dot_depth * .50)
        ox = choice_x
        oy = choice_y
        order = dot_depth

        if <double> level / top_level > 0.50:   #value_thresh * 10:
            # take this point for a white dot center
            for dot in xrange(distance, 0, -1):
                cx = (ox + dot_tos[dot].x) % array_width
                cy = (oy + dot_tos[dot].y) % array_height
                # paint the first empty dot we find
                if threshold_array[cx][cy] == -1:
                    do_dot(cx, cy, level, 0)
                    level += 1
                    do_min_dot = 0
                    break
            if do_min_dot == 1:
                do_dot(choice_x, choice_y, level, 0)
                level += 1
            # NOTE: here we have to finish the loop with
            # a painted dot ?
        else:
            # look for surrounding dot
            for dot in xrange(0, distance):
                cx = (ox + dot_tos[dot].x) % array_width
                cy = (oy + dot_tos[dot].y) % array_height
                # if have several dots try to choose
                # the smaller to expand.
                if threshold_array[cx][cy] != -1:
                    if mark_array[cx][cy] < order:
                        order = mark_array[cx][cy]
                        choice_x = cx
                        choice_y = cy
                    do_min_dot = 0 # don't do the min_dot

            # no dot too near, initial choice is ok
            if do_min_dot == 1:
                do_dot(choice_x, choice_y, level, 0)
                # so we deal with the first mindot of a cell
                mark_array[choice_x][choice_y] = 0
                level += 1

            # we're near already painted dot(s)
            else:
                # check if this dot could be expand
                order = mark_array[choice_x][choice_y]
                if order < dot_depth - 1:
                    ox = choice_x - dot_tos[order].x
                    oy = choice_y - dot_tos[order].y
                    for dot in xrange(order+1, dot_depth):
                        cx = (ox + dot_tos[dot].x) % array_width
                        cy = (oy + dot_tos[dot].y) % array_height
                        # check if our new choice is not already painted
                        if threshold_array[cx][cy] == -1:
                            do_dot(cx, cy, level, 0)
                            mark_array[cx][cy] = dot
                            level += 1
                            do_min_dot = 1
                            break
                if do_min_dot == 0: # nothing's done yet
                    print "superposing dot at level ", level
                    do_dot(mx, my, level, 0)
                    # so we deal with the first mindot of a cell
                    mark_array[mx][my] = 0
                    level += 1

    err_code = 0  # normal return
    return err_code

# This function determines the weighting of pixels.
# The density is determined as a result of this function.
#
# NOTE that if more involved "Val" functions are used to
# try to detect "lines" in the array and increase the value
# for points that would form lines, then it will probably
# be necessary to recalculate values for the entire array.
# (but maybe not even then -- just keep it in mind)
cdef double val_function(int this_x, int this_y, int ref_x, int ref_y, double rx_sq, double ry_sq) nogil:
    global array_height, array_width, level, top_level
    cdef int dx, dy
    cdef double distance, q
    q = 1.0

    dx = c_abs(ref_x - this_x)
    if dx > array_width / 2:
        dx = array_width - dx

    dy = c_abs(ref_y - this_y)
    if dy > array_height / 2:
        dy = array_height - dy

    distance = (<double> (dx * dx) / rx_sq) + (<double> (dy * dy) / ry_sq)

    # NOTE: OPTIONAL FUDGE_DIAG_ONAXIS
    # Now decrease the distance (increasing the value returned for	*/
    # on-axis and diagonal positions.				*/
    # TODO: put divisor in user paramater
    if (dx == 0) or (dy == 0) or (dx == dy)  or ((dx+dy) < 10):
        distance *= 0.7

    #if <double> level / top_level > 0.5:
    #    q = 1.0
    return q / distance

# sort function for the turn on sequence array
cdef int compare_order(const void *vp, const void *vq) nogil:
    global array_height, array_width, values_array
    cdef order_t *p = <order_t *> vp
    cdef order_t *q = <order_t *> vq
    cdef int retval = 0

    if values_array[p.y * array_width + p.x] < values_array[q.y * array_width + q.x]:
       retval = -1
    elif values_array[p.y * array_width + p.x] > values_array[q.y * array_width + q.x]:
       retval = 1
    return retval

cdef int do_dot(int choice_x, int choice_y, int level, int last):
    global min_value, max_value, value_range, array_width
    global array_height, resolution, threshold_array
    global values_array, tos

    cdef int err_code = 0
    cdef int x, y
    cdef double value, rx_sq, ry_sq, vtmp

    threshold_array[choice_x][choice_y] = level
    value = values_array[choice_y * array_width + choice_x]
    value = (value - min_value) / value_range

    #NOTE: print to file
    #fprintf(fp,"%d\t%d\n",choice_X,choice_Y);

    #NOTE: here optionaly update graphic view

    # BIG_FLOAT: value for dot already painted
    values_array[choice_y * array_width + choice_x] =  BIG_FLOAT

    # accumulate the value contribution
    # of this new pixel. While we do, also recalculate
    # the min_value and max_value and value_range
    min_value = BIG_FLOAT
    max_value = 0.0
    for y in xrange(array_height):
        for x in xrange(array_width):
            if threshold_array[x][y] == -1:
                rx_sq = resolution[0] * resolution[0]
                ry_sq = resolution[1] * resolution[1]
                vtmp = values_array[y * array_width + x] + val_function(x, y, choice_x, choice_y, rx_sq, ry_sq)
                values_array[y * array_width + x] = vtmp
                if vtmp < min_value:
                    min_value = vtmp
                if vtmp > max_value:
                    max_value = vtmp
        # end for X -- columns
    # end for Y -- rows

    value_range = max_value - min_value
    if value_range == 0.0:
        value_range = 1.0

    return err_code
