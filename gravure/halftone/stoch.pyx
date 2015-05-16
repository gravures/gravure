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
#           with coomon user paramater setting, common structure to
#           to use the same quality metric tools like fourrier transform, etc

import cython
cimport cython

from PIL import Image
import pyximport; pyximport.install()
import numeric.mdarray as md


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

DEF	MAX_ARRAY_WIDTH	= 512
DEF	MAX_ARRAY_HEIGHT	= 512
DEF BIG_FLOAT	= 999999999.0

cdef int array_width, array_height
cdef int resolution [2]
cdef int threshold_array [MAX_ARRAY_WIDTH][MAX_ARRAY_HEIGHT]

cdef double	values_array [MAX_ARRAY_WIDTH * MAX_ARRAY_HEIGHT]
cdef double min_value = 0.0
cdef double max_value = 0.0
cdef double value_range = 0.0

ctypedef struct order_t:
    int x
    int y

cdef order_t tos[MAX_ARRAY_WIDTH * MAX_ARRAY_HEIGHT]

# Definition of the minimum dot patterns
ctypedef struct dot_shape:
    int num_rows
    int left [3]
    int right [3]

cdef dot_shape min_dot_edges [20]
cdef dot_shape fill_dot_shape(int rows, object left, object right):
    cdef dot_shape ds
    ds.num_rows = rows
    for i in xrange(3):
        ds.left[i] = left[i]
        ds.right[i] = right[i]
    return ds

min_dot_edges[0] =  fill_dot_shape(rows=1, left=( 0, 0, 0 ), right=( 0, 0, 0 ))	# 0     x__
min_dot_edges[1] =  fill_dot_shape(rows=1, left=( 0, 0, 0 ), right=( 1, 0, 0 ))	# 1     xx_.
min_dot_edges[2] =  fill_dot_shape(rows=2, left=( 0, 0, 0 ), right=( 0, 0, 0 ))	# 2     x__
                                                                                                                    #        x__
min_dot_edges[3] =  fill_dot_shape(rows=2, left=( 0, 0, 0 ), right=( 1, 0, 0 ))	# 3:    xx_
                                                                                                                    #        x__
min_dot_edges[4] =  fill_dot_shape(rows= 2, left=( 0, 1, 0 ), right=( 0, 1, 0 ))	#4      x__
                                                                                                                    #        _x_
min_dot_edges[5] =  fill_dot_shape(rows= 2, left=( 0, 0, 0 ), right=( 1, 1, 0 ))	# 5     xx_
                                                                                                                    #        xx_
min_dot_edges[6] =  fill_dot_shape(rows=1, left=( 0, 0, 0 ), right=( 2, 0, 0 ))	# 6     xxx
min_dot_edges[7] =  fill_dot_shape(rows=2, left=( 0, 0, 0 ), right=( 2, 0, 0 ))	# 7     xxx
                                                                                                                    #        x__
min_dot_edges[8] =  fill_dot_shape(rows=2, left=( 0, 0, 0 ), right=( 2, 1, 0 ))	# 8     xxx
                                                                                                                    #        xx_
min_dot_edges[9] =  fill_dot_shape(rows=2, left=( 0, 0, 0 ), right=( 2, 2, 0 ))	#9      xxx
                                                                                                                        #        xxx
min_dot_edges[10] =  fill_dot_shape(rows=3, left=( 0, 0, 0 ), right=( 2, 0, 0 ))	#10    xxx
                                                                                                                        #        x__
                                                                                                                        #        x__
min_dot_edges[11] =  fill_dot_shape(rows=3, left=( 0, 0, 0 ), right=( 2, 1, 0 ))	#11    xxx
                                                                                                                        #        xx_
                                                                                                                        #        x__
min_dot_edges[12] =  fill_dot_shape(rows=3, left=( 0, 0, 0 ), right=( 2, 2, 0 ))	#12    xxx
                                                                                                                        #        xxx
                                                                                                                        #        x__
min_dot_edges[13] =  fill_dot_shape(rows=3, left=( 0, 0, 0 ), right=( 2, 2, 1 ))	#13    xxx
                                                                                                                        #        xxx
                                                                                                                        #        xx_
min_dot_edges[14] =  fill_dot_shape(rows=3, left=( 0, 0, 0 ), right=( 0, 0, 0 ))	#14    x__
                                                                                                                        #        x__
                                                                                                                        #        x__
min_dot_edges[15] =  fill_dot_shape(rows=3, left=( 0, 0, 0 ), right=( 1, 0, 0 ))	#15    xx_
                                                                                                                        #        x__
                                                                                                                        #        x__
min_dot_edges[16] =  fill_dot_shape(rows=3, left=( 0, 0, 0 ), right=( 1, 1, 0 ))	#16    xx_
                                                                                                                        #        xx_
                                                                                                                        #        x__
min_dot_edges[17] =  fill_dot_shape(rows=3, left=( 0, 0, 0 ), right=( 1, 1, 1 ))	#17    xx_
                                                                                                                        #        xx_
                                                                                                                        #        xx_
min_dot_edges[18] =  fill_dot_shape(rows=3, left=( 0, 0, 0 ), right=( 2, 1, 1 ))	#18:   xxx
                                                                                                                        #        xx_
                                                                                                                        #        xx_
min_dot_edges[19] =  fill_dot_shape(rows=3, left=( 0, 0, 0 ), right=( 2, 2, 1 ))	#19:   xxx
                                                                                                                        #        xxx
                                                                                                                        #        xxx


cdef bint data_is_ready = False
cdef int level

#
# Python interface for the screening process
#TODO: make doc string
def make_screen(res=(720,720), min_dot=14, level=256,
                                threshold = 50, bias=1.0, seed=13, quiet=False):
    cdef double thresh
    cdef int min_dot_index
    cdef int width, height
    global resolution

    cdef unsigned int x, y, i, q_level
    cdef double arr_level, max_level, tmp
    global tos, threshold_array, values_array, array_width, array_height
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

    min_dot_index = 19
    thresh = threshold / 1000.0
    width = 50
    height = 50

    _make_screen(width=width, height=height, min_dot_pattern=min_dot_index, \
                        value_thresh=thresh, bias_power=bias, seed=seed, quiet=quiet)

    #TODO:
    # print out final threshold array
    strout = ""
    for y in xrange(array_height):
        for x in xrange(array_width):
            strout += " %3d\t\t" % (threshold_array[x][y])
            if (x & 15) == 15:
                strout += "\n"
        if (x & 15) != 0:
            strout += "\n"
    print strout

    #strout = ""
    #for i in xrange(array_width * array_height):
    #    strout += "(%d, %d) = %6d\t\t" % (tos[i].x, tos[i].y, values_array[i])
    #    if (i+1) % 10 == 0 :
    #        strout += "\n"
    #print strout

    #
    # OUTPUT IMAGE
    #normalize threshold array to 8 bit depth
    my_array = md.mdarray(shape=(array_width, array_height),format="=u1")
    max_level =  255
    arr_level = array_width * array_height

    for x in xrange(array_width):
        for y in xrange(array_height):
            tmp = ((<double> threshold_array[x][y]) / arr_level) * max_level
            #FIXME negative value
            if tmp<0 :
                print "dot bug placement"
                tmp = 0
            q_level = <unsigned int> (max_level - c_floor(tmp) - 1)
            my_array[x, y] = q_level
    print my_array

    my_array.reshape((array_width * array_height))
    image_thresh = Image.frombuffer(mode='L',
                size=(array_width, array_height), data=my_array.memview)
    img_file = open("/home/gilles/TEST/thres_out.pgm", mode="wb", closefd=True)
    image_thresh.save(img_file)

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
# min_dot_pattern:
# set the minimum dot size/shape pattern.
# This is an index to a specific size/shape table
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
cdef int _make_screen(int width, int height,
                                        int min_dot_pattern, double value_thresh,
                                        double bias_power, int seed, bint quiet):
    global min_value, max_value, value_range, array_width
    global array_height, resolution, threshold_array
    global values_array, tos, min_dot_edges
    global level

    cdef int i, j, k, m
    cdef int x, y, choice_range, choice, choice_x, choice_y
    cdef int sort_range
    cdef int do_min_dot
    cdef int row, dot, cx, cy, userow
    cdef double	value
    cdef int err_code = 0
    cdef double rand_scaled

    # allows for horizontal / vertical resolution, e.g. -r2x1
    # values are used for aspect ratio -- actual values arbitrary
    cdef double rx_sq
    cdef double ry_sq
    rx_sq = resolution[0] * resolution[0]
    ry_sq = resolution[1] * resolution[1]

    #	Initialize master threshold array
    array_width = width
    array_height = height
    if array_width * array_height > MAX_ARRAY_WIDTH * MAX_ARRAY_HEIGHT:
        print "Array size is too large, max width = %d, max height = %d\n"  \
                % (MAX_ARRAY_WIDTH, MAX_ARRAY_HEIGHT)
        return 1

    #NOTE: open the output file from the next required parameter

    # initialize the threshold_array to -1
    # (an invalid value) for unfilled dots
    # Initialize the tos array
    for y in xrange(array_height):
        for x in xrange(array_width):
            tos[y * array_width + x].x = x
            tos[y * array_width + x].y = y
            values_array[y * array_width + x ] = 0.0
            threshold_array[x][y] = -1

    #
    # Create an ordered list of values
    #
    sort_range = array_width * array_height
    min_value = 0.0
    max_value = 0.0
    value_range = 1.0

    cdef bint dot_done = False
    level = 0
    #for level in xrange(array_width * array_height):
    while level < (array_width * array_height):
        # We focus the processing on the first "SortRange" number of
        # elements to speed up the processing. The SortRange starts
        # at the full array size, then is reduced to a smaller value

        # sort the list of values in the tos
        #random seed
        seed += 1
        srand(seed)
        qsort(<void *> tos, sort_range, sizeof(order_t), compare_order)
        sort_range = array_width * array_height - level

        #TODO:
        # display an array of values in pseudo color
        if not quiet:
            image_value_map()

        if not quiet:
            print "min_value = %f, min_x = %d, min_y = %d\n" \
                        % (min_value, tos[0].x, tos[0].y)

        choice_range = 0
        for i in xrange(sort_range):
            value = values_array[tos[i].y * array_width + tos[i].x]
            value = (value - min_value) / value_range
            if value > value_thresh:
                break
            choice_range += 1

        # Print some statistics on the ordered array
        if not quiet:
            print "Number of points less than %5.3f = %d " % (value_thresh, choice_range)
            print "min_value = %f, max_value = %f,, value_range = %f\n " % (min_value, max_value, value_range)

        # Now select the next pixel using a random number
        #
        # Limit the choice to the 1/10 of the total number
        # of points or those points less than "value_thresh"
        # whichever is smaller
        if choice_range > array_width * array_height / 10:
            choice_range = array_width * array_height / 10

        # Choose from among the 'acceptable' points
        rand_scaled = <double> rand() / <double> RAND_MAX
        choice = <int> (<double> choice_range * c_pow(rand_scaled, bias_power))
        choice_x = tos[choice].x
        choice_y = tos[choice].y

        # if minimum dot size is set, modify the choice
        # depending on the neighboring dots.
        # If the edge of the expanded dot is adajcent
        # to a dot aleady 'on', then increase the size
        # of that dot instead
        do_min_dot = min_dot_pattern
        if min_dot_pattern != 0:
            # If a nearby dot it 'on', choose the 'best'
            # one instead of the 'min_dot'. This insures
            # that each min_dot will have at least
            # a one dot 'white' area around it
            for row in xrange(-1, min_dot_edges[min_dot_pattern].num_rows + 1):
                userow = 0 if row < 0 else (row - 1 \
                    if row == min_dot_edges [min_dot_pattern].num_rows else row)
                cy = (choice_y + row) % array_height

                for dot in xrange(min_dot_edges[min_dot_pattern].left[userow] - 1,
                                                min_dot_edges[min_dot_pattern].right[userow] + 1):
                    cx = (choice_x + dot) % array_width
                    if threshold_array[cx][cy] != -1:
                        if not quiet:
                            print "min_dot suppressed due \
                                to neighbor dot at: [%d, %d]\n" % (cx, cy)
                        # Choose a white dot adjacent to this dot
                        #choice_x = cx
                        #choice_y = cy
                        do_min_dot = 0  # don't do the min_dot expansion
                        break
                if do_min_dot == 0:  # did we bail out of the 'dot' loop ?
                    break
            #  end of row loop
        # end of if min_dot_pattern != 0

        # Print some statistics on the ordered array
        if not quiet:
            print "choice: %d, choice_range: %d, \
            do_min_dot: %d\n" % (choice, choice_range, do_min_dot)
            print "Threshold Level %4d is depth %d, \
              val = %5.3f at (%4d, %4d)\n" % (level, \
                choice, values_array[choice_y * array_width + \
                choice_x], choice_x, choice_y)

        if do_min_dot != 0: #original != 0
            for row in xrange(min_dot_edges[min_dot_pattern].num_rows):
                cy = (choice_y + row) % array_height
                for dot in xrange(min_dot_edges[min_dot_pattern].left[row], \
                                min_dot_edges[min_dot_pattern].right[row] + 1):
                    cx = (choice_x + dot) % array_width
                    if row > 0 or dot > 0:
                        # The 'choice' dot will be done
                        # outside this block as the 'last'
                        if threshold_array[cx][cy] == -1:
                            do_dot(cx, cy, level, 0)
                            level += 1

        # end of  if do_min_dot

        # last dot in group
        if threshold_array[choice_x][choice_y] == -1:
            do_dot(choice_x, choice_y, level, 1)
            level += 1

    # end for level...

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
    global array_height, array_width
    cdef int dx, dy
    cdef double distance

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
    #if (dx == 0) or (dy == 0) or (dx == dy)  or ((dx+dy) < 10):
    #    distance *= 0.7

    return 1.0 / distance

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
