# -*- coding: utf-8 -*-
#
# Copyright (C) 2011 Atelier Obscur.
# Authors:
# Gilles Coissac <gilles@atelierobscur.org>
#
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
#
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

cimport cython
from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free
from libc.stdlib cimport rand, srand, qsort, RAND_MAX
from libc.stdlib cimport abs as c_abs
from libc.math cimport floor as c_floor
from libc.math cimport pow as c_pow
from libc.math cimport sqrt as c_sqrt
from libc.math cimport cos, sin, acos, asin, tan, atan

from cython.parallel import prange

import cython
from cython cimport boundscheck,wraparound, nonecheck
from time import time
from PIL import Image
#TODO: replace by normal import
import pyximport; pyximport.install()
import numeric.mdarray as md
import spotfunctions
from core.property import *


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
cdef int dotshape_array [MAX_DOT][MAX_DOT]
cdef order_t dot_tos [MAX_DOT * MAX_DOT]
cdef order_t window[MAX_DOT * MAX_DOT]
cdef order_t mark_dot[50000]
cdef int resolution [2]
cdef int array_width = 0
cdef int array_height = 0
cdef bint fudge_diagonal = 0
cdef double fudge_factor = .50
cdef unsigned int fudge_radius = 128

#
# Application ProptyList
#
plist = PropertyList(name="Stochastic Screener", description=None)
plist.append(Property(name="dotsize",              dtype=inttype,    valuerange=(1,30),  value=8))
plist.append(Property(name="minblackdot",      dtype=inttype,    valuerange=(1,30), value=4))
plist.append(Property(name="minwhitedot",      dtype=inttype,    valuerange=(1,30),  value=2))
plist.append(Property(name="dotshape",           dtype=strlisttype, valueslist=spotfunctions.__all__[1:],  value=spotfunctions.__all__[1:][0]))
plist.addgroup(name="Dot specification", start=0, end=4)

plist.append(Property(name="threshold",         dtype=inttype,    valuerange=(0,100),  value=50))
plist.append(Property(name="bias",                  dtype=floattype, valuerange=(1,10),    value=1))
plist.append(Property(name="seed",                 dtype=inttype,    valuerange=(1,1000),value=5))
plist.append(Property(name="fudgediagonal",  dtype=booltype,  value=False))
plist.addgroup(name="Matrice", start=4, end=8)
#plist.dump()

import math

def run_screener():
    # output resolution
    res = (1440, 1440)
    # lpi reference
    lpi = 80
    # dot shape
    shape = spotfunctions.RoundDot
    # 120-34 mesh
    mesh_opening = 0.045 #mm
    thread_diameter = 0.034 #mm
    # screen_size
    screen_size = 300  #800
    threshold =  150
    bias = 5
    seed = 5
    gamma = 1.0#.33

    global fudge_diagonal, fudge_factor, fudge_radius
    fudge_diagonal = 1
    fudge_factor = .7
    fudge_radius = 40

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
    #print min_black_dot, min_white_dot
    min_black_dot = 3#24
    min_white_dot = 5#32
    make_screen(res, min_black_dot, min_white_dot, dotsize, shape, screen_size,
                        threshold=threshold, bias=bias, seed=seed, gamma = gamma, quiet=0)

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
        dot_h = dot_w = dot_h * resolution[0]
        height = screensize // resolution[0]
        height = width = height * resolution[0]
    else:
        dot_w = max(dot_size // resolution[1], 2)
        dot_w = dot_h = dot_w * resolution[1]
        width = screensize // resolution[1]
        width = height = width * resolution[1]

    if max(dot_w, dot_h) > MAX_DOT:
        raise RuntimeError("dot size error")

    thresh = threshold / 1000.0
    #top_level = width * height - 1
    top_level = (width / resolution[1]) * (height / resolution[0]) - 1

    start_time = time()
    #_make_dotshape(spotfnc, dot_w, dot_h)
    screen_level = _make_screen(width, height, thresh, bias, \
            seed, quiet, dot_w, dot_h, \
            min_black_dot, min_white_dot)
    time_laps = time() - start_time
    saveasfile(level, screen_level, gamma)
    savepostscript(level, screen_level, gamma)

    # Release Memory Heap
    _free_memory()

    # Print Statistic
    print "STOCHASTIC GREEN NOISE STATISTICS"
    print "screen size : %i x %i" %(width, height)
    print "aspect ratio : %i/%i" %(resolution[0], resolution[1])
    print "total differents levels : %i" %(top_level + 1)
    print "minimum sizes dot - black : %i - dot(s) white : %i dot(s)" %(min_black_dot, min_white_dot)
    print "computation time : %f sec." %time_laps
    print "dot cells : ", k_cells_count, "K cells", w_cells_count, "W cells"

#TODO: verifiy this thing......!!!
cdef double gamma_corr(double pixel, double gamma):
    cdef double gamma_corrected
    gamma_corrected = ((math.exp(math.log1p(pixel) * gamma)) - 1) / ( (math.exp(math.log1p(1.0) * gamma)) - 1)
    return gamma_corrected

cdef object _get_qarray(int level, int array_level, double gamma):
    global array_width, array_height, mark_array, threshold_array
    global top_level, resolution
    cdef unsigned int x, y, i, q_level, width, height, error_dot = 0
    cdef double arr_level, max_level, tmp

    #TODO: verify this in futurd
    format = "=u1" if level <= 256 else "=u2"

    max_level =  level - 1
    width = array_width / resolution[1]
    height = array_height / resolution[0]

    # OUTPUT IMAGE : normalize threshold array to 8 bit depth
    q_array = md.mdarray(shape=(height, width), format=format)

    for x in range(0, array_width, resolution[1]):
        for y in range(0, array_height, resolution[0]):
            if values_array[y * array_width + x] != BIG_FLOAT :
                error_dot += 1
                tmp = 1
            else:
                tmp = gamma_corr( <double>  threshold_array[y * array_width + x] / array_level, gamma)
            q_level = <unsigned int> (c_floor(tmp * max_level))
            q_array[y / resolution[0], x / resolution[1]] = q_level

    if error_dot:
        print "UNVALUED DOT ERROR : %i / %i" % (error_dot, array_height * array_width)
    return q_array


cdef int image_value_map()except -1:
    global min_value, max_value, value_range, array_width
    global array_height, values_array, tos, level
    cdef unsigned int x, y, i
    cdef unsigned char q_level
    cdef double arr_level, max_level, tmp

    if max_value == 0:
        return 0
        max_value = 1.0

    #normalize array to 8 bit depth
    my_array = md.mdarray(shape=(array_height, array_width),format="=u1")
    max_level =  255
    arr_level = array_width * array_height

    for x in range(array_width):
        for y in range(array_height):
            tmp = values_array[y * array_width + x]
            if tmp == BIG_FLOAT :
                tmp = max_value
            else:
                tmp = ((tmp - min_value) / max_value) * max_level
                #tmp = min((tmp / max_value) * max_level, 255)
            q_level = <unsigned char> tmp
            my_array[y, x] = q_level

    my_array.reshape((array_width * array_height))
    image_thresh = Image.frombuffer(mode='L',
                size=(array_width, array_height), data=my_array.memview)
    img_file = open("/home/gilles/TEST/map/map_%d.pgm" % (level,), mode="wb", closefd=True)
    image_thresh.save(img_file)


cdef int savepostscript(int level, int array_level, double gamma)except -1:
    global array_width, array_height
    cdef int width, height
    #TODO: change this in futur
    level = 65536

    q_array = _get_qarray(level, array_level, gamma)
    width = q_array.shape[1]
    height = q_array.shape[0]

    data_str = "data_stoch.ps"
    fdata_path = "/home/gilles/TEST/" + data_str
    psdict_path = "/home/gilles/TEST/HT16_stoch.ps"
    fdata_file = open(fdata_path, 'w')
    fdata = ""
    for y in range(height):
        fdata += "\n"
        for x in range(width):
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
    psdict += "    /Width  %i \n" %width
    psdict += "    /Height %i \n" %height
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
    cdef width, height

    q_array = _get_qarray(level, array_level, gamma)
    width = q_array.shape[1]
    height = q_array.shape[0]
    q_array.reshape((width * height))

    image_thresh = Image.frombuffer(mode='L',
                size=(width, height), data=q_array.memview)
    img_file = open("/home/gilles/TEST/thres_out.pgm", mode="wb", closefd=True)
    image_thresh.save(img_file)

# print out threshold array
cdef int _print_threshold()except -1:
    global array_width, array_height, threshold_array
    strout = ""
    for y in range(array_height):
        for x in range(array_width):
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
    for y in range(dot_h):
        for x in range(dot_w):
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

    dot_w *= 2
    dot_h *= 2
    # Fill the cell with spot function
    sp = spotfnc()
    zx = 2.0 / (dot_w - 1)
    zy = 2.0 / (dot_h - 1)

    for i in range(dot_w):
        x = -1.0 + zx * i
        for j in range(dot_h):
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
    for i in range(dot_w * dot_h):
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

    threshold_array = <unsigned int*> PyMem_Malloc(sz * sizeof(unsigned int))
    if not threshold_array:
        raise MemoryError("Unable to allocate memory for threshold_array")

    #mark_array = <int*> PyMem_Malloc(sz * sizeof(int))
    #if not mark_array:
    #    raise MemoryError("Unable to allocate memory for mark_array")

    values_array = <double*> PyMem_Malloc(sz * sizeof(double))
    if not values_array:
        raise MemoryError("Unable to allocate memory for values_array")

    tos = <order_t*> PyMem_Malloc(sz * sizeof(order_t))
    if not tos:
        raise MemoryError("Unable to allocate memory for whitenig order array")


cdef int _free_memory():
    PyMem_Free(threshold_array)
    #PyMem_Free(mark_array)
    PyMem_Free(values_array)
    PyMem_Free(tos)

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
    global level, dotshape_array, mark_array, k_cells_count, w_cells_count, window

    cdef int choice_range, x, y, i
    cdef int choice, choice_x, choice_y, mx, my, ox, oy
    cdef int dot, cx, cy, dot_depth
    cdef int sort_range, do_min_dot, win_sort_range
    cdef double	value, rand_scaled, rx_sq, ry_sq
    cdef int loop_level, array_size, window_size
    #cdef int dx,dy, radius

    # Initialize master threshold array
    # initialize the mark_array to  -1
    # (an invalid value) for unfilled dots
    # Initialize the tos array
    dot_depth = dot_w * dot_h
    array_size = width * height
    array_width = width
    array_height = height
    rx_sq = resolution[0] * resolution[0]
    ry_sq = resolution[1] * resolution[1]
    _memory_allocation(width, height)

    radius = array_width / 8
    for y in range(array_height):
        for x in range(array_width):
            tos[y * array_width + x].x = x
            tos[y * array_width + x].y = y
            threshold_array[y * array_width + x] = 0
            #dx =  c_abs(x - (radius / 2) - ( (radius) * (x // radius) ))
            #dy =  c_abs(y - (radius / 2) - ( (radius) * (y // radius) ))
            #values_array[y * array_width + x ] =   (c_sqrt(<double>((dx * dx) + (dy * dy))) + 0.00001) / 10000.0
            values_array[y * array_width + x ] = 0
            #mark_array[y * array_width + x ] = -1
    #image_value_map()

    # Create an ordered list of values
    sort_range = array_width * array_height
    min_value = 0.0
    max_value = 0.0
    value_range = 1.0
    level = 0

    cdef int counter = 0
    cdef int next_level = 1
    cdef int wdot_thres
    window_size = <int> (<double> min_kdot / 1.5) + 1
    loop_level = (width / resolution[1]) * (height / resolution[0])
    dot_depth = <int> ((<double> min_kdot / 2) * (<double> min_kdot / 2) * 3.141592653589793)
    wdot_thres = <int> (<double> loop_level * 0.75)

    with nogil:
        while level < loop_level:
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

            for i in range(sort_range):
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
            #if choice_range > loop_level / 10:
            #    choice_range = loop_level / 10

            # Choose from among the 'acceptable' points
            rand_scaled = <double> rand() / <double> RAND_MAX
            choice = <int> (<double> choice_range * c_pow(rand_scaled, bias_power))
            mx = ox =choice_x = tos[choice].x
            my = oy = choice_y = tos[choice].y

            # Aspect ratio adjustment
            next_level = 0 if (oy % resolution[0]) > 0 else 1

            # if minimum dot size is set, modify the choice
            # depending on the neighboring dots.
            # If the edge of the expanded dot is adajcent
            # to a dot aleady 'on', then increase the size
            # of that dot instead
            do_min_dot = 0

            # look for surrounding dot(s)
            counter = 0
            for x in range(-1, 2 ,1):
                for y in range(-1, 2, 1):
                    if values_array[((my + y) % array_height) * array_height  + ((mx + x) % array_width)] == BIG_FLOAT:
                        counter += 1
            if counter > 0:
                do_min_dot = 1
                if counter == 8 and level > wdot_thres:
                    mark_dot[w_cells_count].x = mx
                    mark_dot[w_cells_count].y = my
                    w_cells_count += 1

            if do_min_dot == 1:
                do_dot(mx, my, level, min_wdot)
                level += 1 * next_level
            else:
            # no dot near so we deal with the first mindot of a new cell
                k_cells_count += 1
                i = 0
                level += dot_depth - 1
                while i < dot_depth:
                    if i > 0:
                        counter = 0
                        for x in range(-1, 2 ,1):
                            for y in range(-1, 2, 1):
                                if values_array[((my + y) % array_height) * array_height  + ((mx + x) % array_width)] == BIG_FLOAT:
                                    counter += 1
                        if counter > 0:
                            if values_array[my * array_height + mx] == BIG_FLOAT:
                                pass
                            else:
                                do_dot(mx, my, level, min_wdot)
                                i += 1
                    else :
                        do_dot(mx, my, level, min_wdot)
                        i += 1

                    # update the micro search window for our cell growing
                    dot = 0
                    for x in range(-window_size, window_size, 1):
                        for y in range(-window_size, window_size, 1):
                            window[dot].x = (ox + x) % array_width
                            window[dot].y = (oy + y) % array_height
                            dot += 1

                    # micro search through window
                    seed += 1
                    srand(seed)
                    win_sort_range = (((window_size * 2) * (window_size * 2)))
                    qsort(<void *> window, win_sort_range, sizeof(order_t), compare_order)
                    rand_scaled = <double> rand() / <double> RAND_MAX
                    win_sort_range = win_sort_range - i
                    choice = <int> (<double> win_sort_range * c_pow(rand_scaled, bias_power))
                    mx = window[choice].x
                    my = window[choice].y

                    # aspect  ratio testing
                    next_level = 0 if (my % resolution[0]) > 0 else 1

        apply_min_white_dot(min_kdot)
    return loop_level

@cython.wraparound(False)
@cython.boundscheck(False)
@cython.nonecheck(False)
cdef int apply_min_white_dot(int min_wdot)nogil:
    global w_cells_count, mark_dot, threshold_array, window
    global array_width, array_height
    cdef int dot, wdot, x, y, ox, oy, i, level, window_size

    dot_depth = <int> ((<double> min_wdot / 2) * (<double> min_wdot / 2) * 3.141592653589793)
    window_size = <int> (<double> min_wdot / 1.5) + 1
    win_sort_range = (window_size * 2) * (window_size * 2)

    with gil:
        print dot_depth, window_size, win_sort_range

    for wdot in range(w_cells_count):
        ox = mark_dot[wdot].x
        oy = mark_dot[wdot].y
        level = threshold_array[oy * array_width + ox]

        dot = 0
        for x in range(-window_size, window_size + 1, 1):
            for y in range(-window_size, window_size + 1, 1):
                window[dot].x = (ox + x) % array_width
                window[dot].y = (oy + y) % array_height
                dot += 1

        qsort(<void *> window, win_sort_range, sizeof(order_t), compare_threshold)
        for i in range(dot_depth):
            threshold_array[window[i].y * array_width + window[i].x] = level



# sort function for the turn on sequence array
@cython.wraparound(False)
@cython.boundscheck(False)
@cython.nonecheck(False)
cdef int compare_threshold(const void *vp, const void *vq) nogil:
    global array_height, array_width, threshold_array
    cdef order_t *p = <order_t *> vp
    cdef order_t *q = <order_t *> vq
    cdef int retval = 0

    if threshold_array[p.y * array_width + p.x] > threshold_array[q.y * array_width + q.x]:
       retval = -1
    elif threshold_array[p.y * array_width + p.x] < threshold_array[q.y * array_width + q.x]:
       retval = 1
    return retval

# This function determines the weighting of pixels.
# The density is determined as a result of this function.
#
# NOTE that if more involved "Val" functions are used to
# try to detect "lines" in the array and increase the value
# for points that would form lines, then it will probably
# be necessary to recalculate values for the entire array.
# (but maybe not even then -- just keep it in mind)
@cython.wraparound(False)
@cython.boundscheck(False)
@cython.nonecheck(False)
cdef double val_function(int this_x, int this_y, int ref_x, int ref_y, int min_wdot) nogil:
    global array_height, array_width, level
    global fudge_diagonal, fudge_factor, fudge_radius

    cdef int dx, dy
    cdef double distance, slope

    dx = c_abs(ref_x - this_x)
    if dx > array_width / 2:
        dx = array_width - dx

    dy = c_abs(ref_y - this_y)
    if dy > array_height / 2:
        dy = array_height - dy

    distance = c_sqrt(<double> ((dx * dx) + (dy * dy)))

    # slope vary between 0 and 1.0
    slope =  <double> min(dx, dy) / <double> max(dx, dy) if dx > 0 and dy > 0 else 0

    if distance < min_wdot / 2.0:
        distance = min_wdot #max((max_value), 0.01) #- (slope * 10)
        #distance = array_width / 10 / distance + min_wdot - slope
    # Now decrease the distance
    # increasing the value returned for
    # on-axis and diagonal positions.
    elif 0: #fudge_diagonal:
        if (dx == 0) or (dy == 0) or (dx == dy) or (dx+dy < fudge_radius):
            distance = distance * fudge_factor

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

@cython.wraparound(False)
@cython.boundscheck(False)
@cython.nonecheck(False)
cdef int do_dot(int choice_x, int choice_y, int level, int min_wdot) nogil:
    global min_value, max_value, value_range, array_width, array_height
    global threshold_array, values_array, dot_tos
    cdef int x, y, i, indice
    cdef double value, vtmp

    threshold_array[choice_y * array_width + choice_x] = level
    values_array[choice_y * array_width + choice_x] = BIG_FLOAT

    # accumulate the value contribution
    # of this new pixel. While we do, also recalculate
    # the min_value and max_value and value_range
    min_value = BIG_FLOAT
    max_value = 0.0

    cdef int core, size
    core = 6
    size = array_width / core

    for x in prange(array_width, schedule='static', chunksize=size, num_threads=core):
    #for x in range(array_width):
        for y in range(array_height):
            indice = y * array_width + x
            if values_array[indice] < BIG_FLOAT:
                vtmp = values_array[indice] + val_function(x, y, choice_x, choice_y, min_wdot)
                values_array[indice] = vtmp
                if vtmp < min_value:
                    min_value = vtmp
                if vtmp > max_value:
                    max_value = vtmp

    value_range = max_value - min_value
    if value_range == 0.0:
        value_range = 1.0

