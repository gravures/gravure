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


#TODO: implement min_white_dot
#TODO: make user documentaion
#TODO: make tests
#TODO: define an interface for module that produce threshold array
#TODO: make module for quality metric tools like fourrier transform, etc
#TODO: make a screen designer UI with screenprint data
#TODO: work on dotshape
#TODO: implement dynamic parameters : threshold, bias, ...
#TODO: optimisation, parallelisme
#NOTE: what about inkjet overlap dot model


import cython
cimport cython
from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free

from PIL import Image

import pyximport; pyximport.install()
import numeric.mdarray as md
import spotfunctions
from core.property import *

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

    void *calloc (size_t, size_t) nogil
    void *malloc(size_t) nogil
    void free(void *) nogil
    void realloc(void *, size_t) nogil
    void *memcpy(void *dest, void *src, size_t n) nogil

cdef extern from"math.h" nogil:
    double c_pow "pow"(double x, double y)



DEF BIG_FLOAT = 999999999.0
DEF MAX_DOT = 64

ctypedef struct order_t:
    int x
    int y

cdef unsigned int* threshold_array
cdef order_t* tos
cdef int* mark_array
cdef double* values_array
cdef double min_value = 0.0
cdef double max_value = 0.0
cdef double value_range = 0.0
cdef bint data_is_ready = False
cdef int level
cdef double top_level
cdef int k_cells_count, w_cells_count

#TODO: change to dynamic alloc
cdef order_t dot_tos [MAX_DOT * MAX_DOT]
cdef int dotshape_array [MAX_DOT][MAX_DOT]
cdef order_t mark_dot[MAX_DOT * MAX_DOT]
cdef int resolution [2]
cdef int array_width = 0
cdef int array_height = 0
cdef bint fudge_diagonal = 0
cdef double fudge_factor = .50

#
# Application ProptyList
#
plist = PropertyList(name="Stochastic Screener", description=None)
plist.append(Property(name="dotsize",              datatype=inttype,    valuerange=(1,30),  value=8))
plist.append(Property(name="minblackdot",      datatype=inttype,    valuerange=(1,30), value=4))
plist.append(Property(name="minwhitedot",      datatype=inttype,    valuerange=(1,30),  value=2))
plist.append(Property(name="dotshape",           datatype=strlisttype, valueslist=spotfunctions.__all__[1:],  value=spotfunctions.__all__[1:][0]))
plist.addgroup(name="Dot specification", start=0, end=4)

plist.append(Property(name="threshold",         datatype=inttype,    valuerange=(0,100),  value=50))
plist.append(Property(name="bias",                  datatype=floattype, valuerange=(1,10),    value=1))
plist.append(Property(name="seed",                 datatype=inttype,    valuerange=(1,1000),value=5))
plist.append(Property(name="fudgediagonal",  datatype=booltype,  value=False))
plist.addgroup(name="Matrice", start=4, end=8)
#plist.dump()

import math

def run_screener():
    # output resolution
    res = (1440,1440)
    # lpi reference
    lpi = 80#70 #80
    # dot shape
    shape = spotfunctions.RoundDot
    # 120-34 mesh
    mesh_opening = 0.045#0.060    #0.045 #mm
    thread_diameter = 0.034 #mm
    # screen_size
    screen_size = 200   #800
    threshold = 75
    bias = 5
    seed = 5
    gamma = .33

    global fudge_diagonal, fudge_factor
    fudge_diagonal = 1
    fudge_factor = 75.0 / 100.0

    #
    #
    # raster dot size
    mindot = 25.4 / res[0] #mm
    # dotsize
    dotsize = math.ceil(25.4 / lpi / mindot)
    #Minimum Size of Highlight Dot Is : 1 Opening + 1.5 Threads
    min_black_dot = math.ceil((mesh_opening + 1.5 * thread_diameter) / mindot)
    #Minimum Size Of Shadow Dot Needs : 2 Openings + 1.5 Threads
    min_white_dot = math.ceil((mesh_opening * 2 + 1.5 * thread_diameter) / mindot)

    make_screen(res, min_black_dot, min_white_dot, dotsize, shape, screen_size,
                        threshold=threshold, bias=bias, seed=seed, gamma = gamma, quiet=True)

#
# Python interface for the screening process
#TODO: make doc string
def make_screen(res=(1440,720), min_black_dot=5, min_white_dot=2,
                                dot_size=12, spotfnc=spotfunctions.RoundDot,
                                screensize=100, level=256, threshold=80,
                                bias=1.0, seed=13, gamma=1.0, quiet=True):
    global resolution, top_level
    global tos, threshold_array, values_array
    global array_width, array_height, dotshape_array
    cdef double thresh
    cdef int width, height, indice
    cdef int dot_w, dot_h

    if screensize > math.sqrt(math.pow(2, sizeof(int) * 8)):
        raise ValueError("screensize error")

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

    # compute final dot size
    # and screen size relative to aspect ratio
    if resolution[0] == resolution[1]:
        dot_w = dot_h = dot_size
        width = height = screensize
    elif resolution[0] > resolution[1]:
        dot_h = max(dot_size // resolution[0], 2)
        dot_w = dot_h * resolution[0]
        height = screensize // resolution[0]
        width = height * resolution[0]
    else:
        dot_w = max(dot_size // resolution[1], 2)
        dot_h = dot_w * resolution[1]
        width = screensize // resolution[1]
        height = width * resolution[1]

    if max(dot_w, dot_h) > MAX_DOT:
        raise RuntimeError("dot size error")

    thresh = threshold / 1000.0
    top_level = width * height - 1

    _make_dotshape(spotfnc, dot_w, dot_h)
    _print_dotshape(dot_w, dot_h)
    screen_level = _make_screen(width, height, thresh, bias, \
            seed, quiet, dot_w, dot_h, \
            min_black_dot, min_white_dot)
    saveasfile(level, screen_level, gamma)
    savepostscript(level, screen_level, gamma)

    # Release Memory Heap
    _free_memory()

#TODO: verifiy this thing......!!!
cdef double gamma_corr(double pixel, double gamma):
    cdef double gamma_corrected
    gamma_corrected = ((math.exp(math.log1p(pixel) * gamma)) - 1) / ( (math.exp(math.log1p(1.0) * gamma)) - 1)
    return gamma_corrected

cdef object _get_qarray(int level, int array_level, double gamma):
    global array_width, array_height, mark_array, threshold_array
    global top_level, resolution
    cdef unsigned int x, y, i, q_level
    cdef double arr_level, max_level, tmp

    max_level =  level - 1

    #TODO: verify this in futur
    format = "=u1" if level <= 256 else "=u2"

    # OUTPUT IMAGE : normalize threshold array to 8 bit depth
    q_array = md.mdarray(shape=(array_height, array_width), format=format)

    for x in xrange(array_width):
        for y in xrange(array_height):
            if mark_array[y * array_width + x] == -1 :
                raise RuntimeError  ("dot bug placement")
                tmp = 0
            else:
                tmp = gamma_corr( <double>  threshold_array[y * array_width + x] / array_level, gamma)
                #tmp = ((<double> threshold_array[y * array_width + x]) / array_level) * max_level
            q_level = <unsigned int> (c_floor(tmp * max_level))
            #q_level = <unsigned int> (c_floor(tmp) )
            q_array[y, x] = q_level

    return q_array

cdef int image_value_map()except -1:
    global min_value, max_value, value_range, array_width
    global array_height, values_array, tos, level
    cdef unsigned int x, y, i
    cdef unsigned char q_level
    cdef double arr_level, max_level, tmp

    if max_value == 0:
        return 0

    #normalize array to 8 bit depth
    my_array = md.mdarray(shape=(array_height, array_width),format="=u1")
    max_level =  255
    arr_level = array_width * array_height

    for x in xrange(array_width):
        for y in xrange(array_height):
            tmp = values_array[y * array_width + x]
            if tmp == BIG_FLOAT :
                tmp = 255
            else:
                tmp = min((tmp / max_value) * max_level, 255)
            q_level = <unsigned char> tmp
            my_array[y, x] = q_level

    my_array.reshape((array_width * array_height))
    image_thresh = Image.frombuffer(mode='L',
                size=(array_width, array_height), data=my_array.memview)
    img_file = open("/home/gilles/TEST/map/map_%d.pgm" % (level,), mode="wb", closefd=True)
    image_thresh.save(img_file)


cdef int savepostscript(int level, int array_level, double gamma)except -1:
    global array_width, array_height

    #TODO: change this in futur
    level = 65536

    q_array = _get_qarray(level, array_level, gamma)
    data_str = "data_stoch.ps"
    fdata_path = "/home/gilles/TEST/" + data_str
    psdict_path = "/home/gilles/TEST/HT16_stoch.ps"
    fdata_file = open(fdata_path, 'w')
    fdata = ""
    for y in range(array_height):
        fdata += "\n"
        for x in range(array_width):
            h = hex(level -1 - q_array[y,x])[2:] # strip 'ox' in hex string
            h = '0000' [:-len(h)] + h
            fdata += h
    fdata += "\n"
    fdata += ">"
    fdata_file.write(fdata)
    fdata_file.close()

    psdict_file = open(psdict_path, 'w')
    psdict = "% gravure data - Halftone Type 16 postscript dictionnary \n"
    psdict += "% Nasty tricks here \n"
    psdict += "% trying to redine the Default halftone \n"
    psdict += "% resource with type 16 cause invalidAccesError. \n"
    psdict += "% So we redefine the gs operator .setdefaulthalftone  \n"
    psdict += "% to a null procedure.  \n"
    psdict += "/Default /Halftone undefineresource  \n"
    psdict += "/.setdefaulthalftone {} obind def  \n"
    psdict += "\n"
    psdict += "% TOFIXE: HalfoneType 16 doesn't support TransferFunction? \n"
    psdict += "/grv_transfer load settransfer\n"
    psdict += "\n"
    psdict += "<< \n"
    psdict += "    /HalftoneType 16 \n"
    psdict += "    /HalftoneName /ThreshHalftone \n"
    psdict += "    /Thresholds (procset/%s) (r) file /ASCIIHexDecode filter <</AsyncRead true /Intent 2>> \n" %data_str
    psdict += "        /ReusableStreamDecode filter  % file object for the 16-bit data \n"
    psdict += "    /Width  %i \n" %array_width
    psdict += "    /Height %i \n" %array_height
    psdict += "    %/TransferFunction /grv_transfer load \n"
    psdict += ">> \n"
    psdict += "\n"
    psdict += "% define the /Default halftone resource \n"
    psdict += "% /Default exch /Halftone defineresource \n"
    psdict += "\n"
    psdict += "% Use the halftone \n"
    psdict += "sethalftone \n"
    psdict += "\n"
    psdict += "% make the halftone be \"sticky\" \n"
    psdict += "<< /HalftoneMode 1 >> setuserparams \n"
    psdict += "\n"
    psdict_file.write(psdict)
    psdict_file.close()

cdef int saveasfile(int level, int array_level, double gamma)except -1:
    global array_width, array_height
    q_array = _get_qarray(level, array_level, gamma)
    q_array.reshape((array_width * array_height))

    image_thresh = Image.frombuffer(mode='L',
                size=(array_width, array_height), data=q_array.memview)
    img_file = open("/home/gilles/TEST/thres_out.pgm", mode="wb", closefd=True)
    image_thresh.save(img_file)

# print out threshold array
cdef int _print_threshold()except -1:
    global array_width, array_height, threshold_array
    strout = ""
    for y in xrange(array_height):
        for x in xrange(array_width):
            #strout += " %3d\t\t" % (threshold_array[x][y])
            strout += " %3d\t\t" % (threshold_array[y * array_width + x])
            if (x & 15) == 15:
                strout += "\n"
        if (x & 15) != 0:
            strout += "\n"
    print strout

cdef int _print_dotshape(dot_w, dot_h)except -1:
    global  dotshape_array
    strout = ""
    for y in xrange(dot_h):
        for x in xrange(dot_w):
            strout += " %3d\t\t" % (dotshape_array[y][x])
            if (x & 15) == 15:
                strout += "\n"
        if (x & 15) != 0:
            strout += "\n"
    print strout

cdef int _make_dotshape(spotfnc, dot_w, dot_h)except -1:
    global dotshape_array, dot_tos, resolution
    cdef int i, j, xp, yp
    cdef double z, w, x, y
    cdef object sp

    # Fill the cell with spot function
    sp = spotfnc()
    zx = 2.0 / (dot_w - 1)
    zy = 2.0 / (dot_h - 1)

    for i in xrange(dot_w):
        x = -1.0 + zx * i
        for j in xrange(dot_h):
            y = -1.0 + zy * j
            w = sp(x,y)
            dotshape_array[j][i] = <int> ((w + 1) / 2.0 * dot_w * dot_h)
            dot_tos[j * dot_w + i].x = i
            dot_tos[j * dot_w + i].y = j

    # Build the whitening order
    qsort(<void *> dot_tos, dot_w * dot_h, sizeof(order_t), compare_tos)

    # update mindot coordinates relative to the center of the cell
    # center is the first mindot in the whitening order
    xp = dot_tos[0].x
    yp = dot_tos[0].y
    for i in xrange(dot_w * dot_h):
        dot_tos[i].x = dot_tos[i].x - xp
        dot_tos[i].y = dot_tos[i].y - yp

cdef int compare_tos(const void *vp, const void *vq) nogil:
    global dotshape_array
    cdef order_t *p = <order_t *> vp
    cdef order_t *q = <order_t *> vq
    cdef int pi, qi, retval = 0

    pi = dotshape_array[p.y] [p.x]
    qi = dotshape_array[q.y] [q.x]
    if pi < qi:
       retval = 1
    elif pi > qi:
       retval = -1
    return retval

def  _memory_allocation(int aw, int ah):
    global threshold_array, mark_array, values_array, tos
    cdef size_t sz = aw * ah

    threshold_array = <unsigned int*> calloc(sz, sizeof(unsigned int))
    if not threshold_array:
        raise MemoryError("Unable to allocate memory for threshold_array")

    mark_array = <int*> calloc(sz, sizeof(int))
    if not mark_array:
        raise MemoryError("Unable to allocate memory for mark_array")

    values_array = <double*> calloc(sz, sizeof(double))
    if not mark_array:
        raise MemoryError("Unable to allocate memory for value_array")

    tos = <order_t*> calloc(sz, sizeof(order_t))
    if not mark_array:
        raise MemoryError("Unable to allocate memory for whitenig order array")


cdef int _free_memory():
    free(threshold_array)

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
            double bias_power, int seed, bint quiet, int dot_w, int dot_h,
            int min_kdot, int min_wdot)except *:
    global min_value, max_value, value_range, array_width
    global array_height, resolution, threshold_array
    global values_array, tos, top_level
    global level, dotshape_array, mark_array, k_cells_count, w_cells_count

    cdef int i, j, k, m, choice_range, x, y, ox, oy
    cdef int choice, choice_x, choice_y, mx, my
    cdef int sort_range, do_min_dot, order, dist
    cdef int row, dot, cx, cy, userow, dot_depth
    cdef double	value, rand_scaled, rx_sq, ry_sq
    cdef int loop_level, array_size, err_code = 0

    # Initialize master threshold array
    # initialize the mark_array to  -1
    # (an invalid value) for unfilled dots
    # Initialize the tos array
    dot_depth = dot_w * dot_h
    array_size = width * height
    array_width = width
    array_height = height
    _memory_allocation(width, height)

    cdef int step_debug
    step_debug = array_size // 40

    for y in xrange(array_height):
        for x in xrange(array_width):
            tos[y * array_width + x].x = x
            tos[y * array_width + x].y = y
            values_array[y * array_width + x ] = 0.0
            threshold_array[y * array_width + x] = 0
            mark_array[y * array_width + x ] = -1

    # Create an ordered list of values
    sort_range = array_width * array_height
    min_value = 0.0
    max_value = 0.0
    value_range = 1.0
    level = 0

    # convert initial min_kdot value to a level
    # in dot_tos (same as distance below
    #TODO: make a function to do this precisely
    if min_kdot > 1:
        if dot_w > dot_h:
            for dot in xrange(0,dot_depth):
                if dot_tos[dot].x == min_kdot / 2:
                    break
        else:
            for dot in xrange(0,dot_depth):
                if dot_tos[dot].y == min_kdot / 2:
                    break
        min_kdot = dot

    cdef int counter = 0
    cdef bint added = 0, dot_done = 0
    cdef int tx, ty
    cdef int distance, neg_dist, dot_radius
    cdef double var_thresh, white_thresh
    white_thresh = .50
    loop_level = array_size

    with nogil:
        while level < loop_level:
            # We focus the processing on the first "SortRange" number of
            # elements to speed up the processing. The SortRange starts
            # at the full array size, then is reduced to a smaller value

            #debug output
            if not quiet:
                if level % step_debug == 0:
                    with gil:
                        image_value_map()

            var_thresh = <double> level / (loop_level - 1)

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
            dot_done = 0

            #TODO: put the distance in user parameter
            distance = <int> (dot_depth * .40) # dots density
            dot_radius = <int> (dot_depth * .30) # max dot size
            neg_dist = <int> (dot_depth * .50) # white dot size
            ox = choice_x
            oy = choice_y
            order = dot_radius

            # look for surrounding dot(s)
            counter = 0
            for dot in xrange(0, distance):
                cx = (ox + dot_tos[dot].x) % array_width
                cy = (oy + dot_tos[dot].y) % array_height
                # if have several dots try to choose
                # the smaller to expand.
                indice = cy * array_width + cx
                added = 0
                if mark_array[indice] > -1: # we've find a dot
                    tx = cx - dot_tos[mark_array[indice]].x # center of the cell
                    ty = cy - dot_tos[mark_array[indice]].y
                    for dot in xrange(0, counter):
                        if tx == mark_dot[dot].x and ty == mark_dot[dot].y:
                            added = 1
                            break
                    if not added:
                        mark_dot[counter].x = tx
                        mark_dot[counter].y = ty
                        mark_dot[100 + counter].x = cx
                        mark_dot[100 + counter].y = cy
                        counter += 1

            if counter:
            # we have neighbouring dot(s)
            # so choose the less expanded
                for dot in xrange(0, counter):
                    tx = mark_dot[dot + 100].x
                    ty = mark_dot[dot + 100].y
                    if mark_array[ty * array_width + tx] < order:
                        order = mark_array[ty * array_width + tx]
                        choice_x = tx
                        choice_y = ty
                        do_min_dot = 0

                if do_min_dot == 0:
                # we have a dot to expand
                    ox = choice_x - dot_tos[order].x
                    oy = choice_y - dot_tos[order].y
                    for dot in xrange(order+1, dot_radius):
                        cx = (ox + dot_tos[dot].x) % array_width
                        cy = (oy + dot_tos[dot].y) % array_height
                        # check if our new choice is not already painted
                        indice = cy * array_width + cx
                        if mark_array[indice] <= -1:
                            loop_level = do_dot(cx, cy, level, loop_level, 0, min_kdot, dot, var_thresh, white_thresh)
                            level += 1
                            dot_done = 1
                            break
                    if dot_done:
                        continue

            #else: # counter == 0
            # no dot too near so initial choice is ok
            # and we deal with the first mindot of a new cell
            loop_level = do_dot(mx, my, level, loop_level, 1, min_kdot, 0, var_thresh, white_thresh)
            level += 1
            k_cells_count += 1

            if False:
                # WHITE DOT
                #elif var_thresh > white_thresh:
                # No dot to expand
                for dot in xrange(0, neg_dist,):
                    cx = (mx + dot_tos[dot].x) % array_width
                    cy = (my + dot_tos[dot].y) % array_height
                    # look for white dot center
                    if mark_array[cy * array_width + cx] == -2:
                        choice_x = cx
                        choice_y = cy
                        break
                else:
                    # take the first point for a new white dot center
                    choice_x = mx
                    choice_y = my
                    mark_array[my * array_width + mx] = -2
                    w_cells_count += 1

                for dot in xrange(neg_dist, 0, -1):
                    cx = (choice_x + dot_tos[dot].x) % array_width
                    cy = (choice_y + dot_tos[dot].y) % array_height
                    # paint the first empty dot we find
                    if mark_array[cy * array_width + cx] < 0:
                        loop_level = do_dot(cx, cy, level, loop_level, 0, min_kdot, 0, var_thresh, white_thresh)
                        level += 1
                        dot_done = 1
                        break
                if dot_done:
                    continue
                else:
                    with gil:
                        print "white", var_thresh
                    loop_level = do_dot(mx, my, level, loop_level, 1, min_kdot, 0, var_thresh, white_thresh)
                    level += 1



    print k_cells_count, "K cells", w_cells_count, "W cells"
    return loop_level



# This function determines the weighting of pixels.
# The density is determined as a result of this function.
#
# NOTE that if more involved "Val" functions are used to
# try to detect "lines" in the array and increase the value
# for points that would form lines, then it will probably
# be necessary to recalculate values for the entire array.
# (but maybe not even then -- just keep it in mind)
cdef double val_function(int this_x, int this_y, int ref_x, int ref_y, double rx_sq, double ry_sq) nogil:
    global array_height, array_width, level, top_level, fudge_diagonal, fudge_factor
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
    if fudge_diagonal:
        if (dx == 0) or (dy == 0) or (dx == dy)  or ((dx+dy) < 10):
            distance *= fudge_factor

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

cdef bint thresh_switch = False

cdef int switch_values()nogil:
    global values_array, array_width, array_height, mark_array
    global min_value, max_value, value_range, thresh_switch
    cdef int x, y

    for y in xrange(array_height):
        for x in xrange(array_width):
            if mark_array[y * array_width + x] == -1:
                values_array[y * array_width + x] = max_value - values_array[y * array_width + x]

    thresh_switch = True


cdef int do_dot(int choice_x, int choice_y, int level,
        int depth, bint do_mindot, int min_kdot, int mindot_level, double thresh, double white_thresh) nogil:

    global min_value, max_value, value_range, array_width
    global array_height, resolution, threshold_array
    global values_array, tos, mark_array, dot_tos, mark_dot, thresh_switch
    cdef int x, y, cx, cy, dot, marked_dot, i
    cdef double value, rx_sq, ry_sq, vtmp

    marked_dot = 0
    if do_mindot:
        # so we deal with the first mindot of a cell
        # do we have to draw a minimum sized dot
        if min_kdot > 1:
            for dot in xrange(0, min_kdot):
                cx = (choice_x + dot_tos[dot].x) % array_width
                cy = (choice_y + dot_tos[dot].y) % array_height
                if mark_array[cx + cy * array_width] <= -1:
                    mark_dot[marked_dot].x = cx
                    mark_dot[marked_dot].y = cy
                    mark_array[cx + cy * array_width] = dot
                    marked_dot += 1
            depth -= marked_dot - 1

    if marked_dot == 0:
        mark_dot[0].x = choice_x
        mark_dot[0].y = choice_y
        mark_array[choice_x + choice_y * array_width] = mindot_level
        marked_dot = 1

    for i in xrange(0, marked_dot):
        threshold_array[mark_dot[i].y * array_width + mark_dot[i].x] = level

    # BIG_FLOAT: value for dot already painted
    for i in xrange(0, marked_dot):
        values_array[mark_dot[i].y * array_width + mark_dot[i].x] = BIG_FLOAT

    # accumulate the value contribution
    # of this new pixel. While we do, also recalculate
    # the min_value and max_value and value_range
    min_value = BIG_FLOAT
    max_value = 0.0
    rx_sq = resolution[0] * resolution[0]
    ry_sq = resolution[1] * resolution[1]

    for y in xrange(array_height):
        for x in xrange(array_width):
            if mark_array[y * array_width + x] <= -1:
                if thresh < white_thresh:
                    for i in xrange(0, marked_dot):
                        choice_x = mark_dot[i].x
                        choice_y = mark_dot[i].y
                        vtmp = values_array[y * array_width + x] + val_function(x, y, choice_x, choice_y, rx_sq, ry_sq)
                        values_array[y * array_width + x] = vtmp
                else:
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

    return depth
