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

import sys
import time

import numpy as np
import array
import timeit

import nose
from nose import *
from nose.tools import *
from nose.failure import *

import psutil

import pyximport; pyximport.install()
import numeric.mdarray as md

shapes = [(10, ), (10, 10), (100, 1000), (6, 7, 9), (9, 8, 12, 3, 1, 11)]
formats_simple = [(b'b', 1), (b'i', 1), (b'i1', 1), (b'i2', 2),
                      (b'i4', 4), (b'i8', 8), (b'u1', 1), (b'u2', 2),
                      (b'u4', 4), (b'u8', 8), (b'f4', 4), (b'f8', 8),
                      (b'f4', 4), (b'f8', 8), (b'c8', 8), (b'c16', 16)]
formats_complex = [(b'ii', 2, 2), (b'>i2i1i4', 7, 3), (b'fff', 12, 3),
                       (b'u4f4f4', 16, 3), (b'ii<i=i1<f4=fff', 20, 8)]



#---------------------------------------------------------------------------#
# TESTS CONSTRUTOR                                                          #
#                                                                           #
def test_new_1():
    #                                                                       #
    # TEST SIMPLE FORMATS                                                   #
    #                                                                       #
    for s in shapes:
        for f, i in formats_simple:
            yield _new, s, f, i

    #                                                                       #
    # TEST COMPLEX FORMATS                                                  #
    #                                                                       #
    for s in shapes:
        for f, i, n in formats_complex:
            yield _new_complex, s, f, i, n

    #                                                                       #
    # TEST WRONG FORMATS                                                    #
    # b'u4f4f48'                                                            #
    assert_raises(ValueError, md.mdarray, shape=(10, 10), format=b'u4f4f48')
    assert_raises(ValueError, md.mdarray, shape=(10, 10), format=b'u4f4rf2')
    assert_raises(ValueError, md.mdarray, shape=(10, 10), format=b'i5')


def test_new_2():
    #                                                                       #
    # TEST EMPTY SHAPE                                                      #
    #                                                                       #
    assert_raises(ValueError, md.mdarray, shape=(10, 0, 5), format=b'i')
    assert_raises(ValueError, md.mdarray, shape=(), format=b'i')

    #                                                                       #
    # TEST DECIMAL NUMBER b'D'                                              #
    #                                                                       #
    mv = md.mdarray(shape=(50, 50), format=b'D')
    assert_is_instance(mv, md.mdarray)
    mv = md.mdarray(shape=(50, 50), format=b'fDf')
    assert_is_instance(mv, md.mdarray)
    mv = md.mdarray(shape=(50, 50), format=b'>D')
    assert_is_instance(mv, md.mdarray)
    assert_raises(ValueError, md.mdarray, shape=(10, 10), format=b'D4')

def test_new_3():
    #                                                                       #
    # TEST BIG MEMORY USAGE                                                 #
    #                                                                       #
    free_mo = psutil.virtual_memory().free / 1024 // 1000
    memory_test = [ int(free_mo * e) for e in [0.5, 0.75, .9, 2]]

#    # 50% of free mem
#    mv = md.mdarray(shape=(1024, 1000, memory_test[0]), format=b'i1')
#    time.sleep(.5)
#    assert_is_instance(mv, md.mdarray)
#
#    # 75% of free mem
#    mv = md.mdarray(shape=(1024, 1000, memory_test[1]), format=b'i1')
#    time.sleep(.5)
#    assert_is_instance(mv, md.mdarray)
#
#    # 90% of free mem
#    assert_warns(ResourceWarning, md.mdarray,
#                  shape=(1024, 1000, 1000, memory_test[2]), format=b'i1')
#    time.sleep(.5)
#    assert_is_instance(mv, md.mdarray)

    #FIXME: Crash the OS, have to restart
    # 200% of free mem
    #assert_raises(MemoryError, md.mdarray,
    #              shape=(1024, 1000, 1000, memory_test[3]), format=b'i1')
    time.sleep(.5)


def test_new_4():
    #                                                                       #
    # TEST C AND F MODE                                                     #
    #                                                                       #
    mv = md.mdarray(shape=(10, 10, 10), format=b'i', order="C")
    assert_is_instance(mv, md.mdarray)
    c_stride = [e for e in mv.strides]
    c_stride.reverse()
    mv = md.mdarray(shape=(10, 10, 10), format=b'i', order="F")
    assert_is_instance(mv, md.mdarray)
    f_stride = [e for e in mv.strides]
    eq_(c_stride, f_stride)

    assert_raises(ValueError, md.mdarray, shape=(10, 10), format=b'i', order='g')

    #                                                                       #
    # TEST RANGE INITIALIZER                                                #
    #                                                                       #
    formats_simpleb = formats_simple[1:] # remove b'b' for this test
    init=range(0, 126)
    for s in shapes:
        for f, i in formats_simpleb:
            yield _new, s, f, i, init

    init=range(0, 5)
    for s in shapes:
        for f, i in formats_simpleb:
            yield _new, s, f, i, init

    #                                                                       #
    # INITIALISER YELDING TUPLE FOR COMPLEX FORMATS                         #
    #                                                                       #
    x, y, z = 1, 2, 4
    def iter_tuple():
        x += x
        y += y
        z += z
        if x == 126 : x = 0
        if y == 126 : y = 0
        if z == 126 : z = 0
        yield (x, y, z)

    formats_complex = [(b'iii', 3, 3), (b'>i2i1i4', 7, 3), (b'fff', 12, 3),
                       (b'u4f4f4', 16, 3)]
    for s in shapes:
        for f, i, n in formats_complex:
            yield _new_complex, s, f, i, n, iter_tuple


    #                                                                       #
    # TEST LIST INITIALIZER                                                 #
    #                                                                       #
    i = [10, 9, 3, 2, 4, 5, 8]
    mv = md.mdarray(shape=(10, 10, 10), format=b'i', order="C", initializer=i)
    assert_is_instance(mv, md.mdarray)

    #                                                                       #
    # TEST BUFFER INTERFACE INITIALIZER                                     #
    #                                                                       #
    # buffer.size * itemsize >= array.size * itemsize                       #
    from array import array
    ar = array('b', range(100))
    mv = md.mdarray(shape=(10, 10), format=b'i', initializer=ar)
    assert_is_instance(mv, md.mdarray)

    ar = array('<h', range(100))
    mv = md.mdarray(shape=(10, 20), format=b'<i', initializer=ar)
    assert_is_instance(mv, md.mdarray)
    eq_(mv.base, ar)
    ar[1] = 9
    eq_(ar[1], mv[0, 2])
    ar = None
    eq_(mv.base, None)
    assert_raises(MemoryError, md.__getitem, (0, 2))

    ar = array('b', range(100))
    assert_raises(TypeError, md.mdarray, shape=(10, 20), format=b'i2',
                  initializer=ar)
    assert_raises(TypeError, md.mdarray, shape=(100, ), format=b'i',
                  initializer=ar, offset=50)


def _new_complex(shape, format, itemsize, tuplelen, init = None):
    mv = md.mdarray(shape, format, initializer = init)
    assert_is_instance(mv, md.mdarray)
    eq_(mv.base, mv)
    le = 1
    for d in shape:
        le *= d
    eq_(mv.size, le)
    eq_(mv.ndim, len(shape))
    eq_(mv.shape, shape)
    eq_(mv.itemsize, itemsize)
    eq_(mv.format, format)
    eq_(mv.nbytes, itemsize * mv.size)
    eq_(len(mv), shape[0])

    #FIXME: freeze code
    #ok_(isinstance(mv[0], tuple))

    #FIXME: freeze code
#    for e in mv:
#        eq_(e, 0)
#        i += 1
#    eq_(mv.size, i)

def _new(shape, format, itemsize, init=None):
    mv = md.mdarray(shape, format, initializer = init)
    assert_is_instance(mv, md.mdarray)
    eq_(mv.base, mv)
    le = 1
    for d in shape:
        le *= d
    eq_(mv.size, le)
    eq_(mv.ndim, len(shape))
    eq_(mv.shape, shape)
    eq_(mv.itemsize, itemsize)
    eq_(mv.format, format)
    eq_(mv.nbytes, itemsize * mv.size)
    eq_(len(mv), shape[0])

    if init is None:
        # Test zero value init
        i = 0
        for e in mv:
            eq_(e, 0)
            i += 1
        eq_(mv.size, i)
    else:
        stop = init[-1]
        i = 0
        for e in mv:
            eq_(e, i)
            i += 1
            if i > stop:
                i = 0

#----------------------------------------------------------------------------
# ENDIANESS                                                                 #
#                                                                           #

#----------------------------------------------------------------------------
# OVERFLOW                                                                  #
#test min max int, there should be trouble                                  #

#----------------------------------------------------------------------------
# OVERFLOW                                                                  #
#                                                                           #

    #                                                                       #
    # with overflow                                                         #
    #                                                                       #
from numbers import *
def pest():

#    print(md.BitWidthType.INT8)
#    print(md.MinMaxType.MAX_INT16)
    print(md.BitWidthType.__enum_values__)
    print(md.MinMaxType.__enum_values__)
    print()
    help(md.MinMaxType.MAX_UINT64)
    #                                                                       #
    # without overflow                                                      #
    #                                                                       #
#    ar = range(-200, 300)
#    mv = md.mdarray(shape=(10, 10), format=b'>i', initializer=ar, overflow=True)
#    print(mv)
    print(md.MinMaxType.MAX_UINT64)
    print(pow(2, 64)-1)

    print(isinstance(md.MinMaxType.MAX_UINT64, Integral))
    print(isinstance(md.MinMaxType.MAX_UINT64, int))
    print(issubclass(md.MinMaxType.MAX_UINT64.__class__, int))

    print(md.MinMaxType.MAX_UINT64)
    print("R", md.MinMaxType.MAX_UINT64.real)
    print("R", md.MinMaxType.MAX_UINT64.__index__())

    print("T", md.MinMaxType.MAX_UINT64 + 1)
    print("T", md.MinMaxType.MAX_UINT64 * 1)
    print("T", 1 * md.MinMaxType.MAX_UINT64)

    print("T", 1 + md.MinMaxType.MAX_UINT64)
    print("T", md.MinMaxType.MAX_UINT64 / 1)

    print("T", md.MinMaxType.MAX_UINT64 + md.MinMaxType.MAX_UINT64)
    print("T", md.MinMaxType.MAX_UINT64.__index__())
    print("E", int(md.MinMaxType.MAX_UINT64))
    print("E", float(md.MinMaxType.MAX_UINT64))
    print("T", md.MinMaxType.MAX_UINT64.__int__())
    print("T1", abs(md.MinMaxType.MAX_UINT64))

    print("T", md.MinMaxType.MAX_UINT64 == 18446744073709551615)
    print("T", 18446744073709551615 == md.MinMaxType.MAX_UINT64)
    print("W", md.MinMaxType.MAX_UINT64 > 18446744073709551615)
    print("W", md.MinMaxType.MAX_UINT64 > 1)
    print("W", 1 < md.MinMaxType.MAX_UINT64)
    print("W", md.MinMaxType.MAX_UINT32 > md.MinMaxType.MAX_UINT64)
    #help(md.MinMaxType)


    #ar = range(md.MinMaxType.MAX_INT64, md.MinMaxType.MAX_UINT64+100)
    #mv = md.mdarray(shape=(10, 10), format=b'u8', initializer=ar, overflow=False)
    #print(mv)
    #                                                                       #
    # with clamped overflow                                                 #
    #                                                                       #


#----------------------------------------------------------------------------



#------------------------------------------------------------------------------
# Main

if __name__ == '__main__':
    #nose.main()
    pest()

"""
mv = mdarray.mdarray((10, 10 ), format=b'i1', initializer=range(0, 800))
#print(mv
#print(dir(mv))

print("base :", "\n" + str(mv.base))
print("ndim :", mv.ndim)
print("shape :", mv.shape)
print("suboffsets", mv.suboffsets)
print("strides:", mv.strides)
print("itemsize :", mv.itemsize)
print("format :", mv.format, type(mv.format))
print("size :", mv.size)
print("nbytes :", mv.nbytes)
print("len(): ",  len(mv))
print("sizeof :", mv.__sizeof__())
#print("memview :", mv.memview)


print("\n" + "GET_ITEM")
print("*" * 50)
print("[...] :\n", mv[...])

print("\n" + "*" * 50)
print("[:] :\n", mv[:])

print("\n" + "*" * 50)
print("[0:4,1:4] :\n", mv[0:4,1:4])

print("\n" + "*" * 50)
print("[...,2:6] :\n", mv[...,2:6])

print("\n" + "*" * 50)
print("[0:4,2] :\n", mv[0:4, 2])

print("\n" + "*" * 50)
print("[0:4,-5] :\n", mv[0:4, -7])

print("\n" + "*" * 50)
print("[2:8:2,2:10:-1] :\n", mv[8:2:-2,4:2:-1])

print("\n" + "*" * 50)
print("[2] :\n", mv[2])

print("\n" + "*" * 50)
print("[4,4] :\n", mv[4, 4])



print("\n" + "SET_ITEM")
print("*" * 50)
mv[...] = 4
print("[...] = 4 :\n", mv)

mv = mdarray.mdarray((10, 10 ), format=b'i1', initializer=range(0, 800))
print("\n" + "*" * 50)
mv[:] = 4
print("[:] = 4 :\n", mv)

mv = mdarray.mdarray((10, 10 ), format=b'i1', initializer=range(0, 800))
print("\n" + "*" * 50)
mv[0:4,1:4] = 4
print("[0:4,1:4] = 4 :\n", mv)

mv = mdarray.mdarray((10, 10 ), format=b'i1', initializer=range(0, 800))
print("\n" + "*" * 50)
mv[...,2:6] = 4
print("[...,2:6] = 4 :\n", mv)

mv = mdarray.mdarray((10, 10 ), format=b'i1', initializer=range(0, 800))
print("\n" + "*" * 50)
mv[0:4, 2] = 4
print("[0:4,2] = 4 :\n", mv)

mv = mdarray.mdarray((10, 10 ), format=b'i1', initializer=range(0, 800))
print("\n" + "*" * 50)
mv[0:4, -5] = 4
print("[0:4,-5] = 4:\n", mv)

mv = mdarray.mdarray((10, 10 ), format=b'i1', initializer=range(0, 800))
print("\n" + "*" * 50)
mv[8:2:-2,4:2:-1] = 4
print("[8:2:-2,4:2:-1] = 4 :\n", mv )

mv = mdarray.mdarray((10, 10 ), format=b'i1', initializer=range(0, 800))
print("\n" + "*" * 50)
mv[2] = 4
print("[2] = 4 :\n", mv)

mv = mdarray.mdarray((10, 10 ), format=b'i1', initializer=range(0, 800))
print("\n" + "*" * 50)
mv[4, 4] = 9
print("[4,4] = 9:\n", mv)

print("\n" + "*" * 50)
print("memoryview(mv):", memoryview(mv))
print("memoryview(mv).shape:", memoryview(mv).shape)
print("memoryview(mv).ndim:", memoryview(mv).ndim)
print("memoryview(mv).format:", memoryview(mv).format)

# buggy
#print("memoryview(mv)[22]:", memoryview(mv)[22])
#print("memoryview(mv).tolist():", memoryview(mv).tolist())

# None index
#print("\n" + "*" * 50)
#print("[0:4,10:50,None] :", mv[0:4,10:50,None])

# Iterator
print("\n" + "*" * 50)
print("for i in mv:\n")
for i, v in enumerate(mv):
    print (i, "#", v)



#print("\n" + "*" * 50)
#help(mv)


print("\n" + "*" * 50)
print("TIME IT TESTS")

def timearray():
    tests = [["np.ndarray(shape=(100, 100), dtype=np.int8, order='C')", "import numpy as np"],
             ["md.mdarray((100, 100), format=b'i1')", "import pyximport; pyximport.install()\nimport numeric.mdarray as md"],
             ["ar.array('b', li)", "import array as ar\nli = [0] * 10000"]]

    for t in tests:
        T = timeit.Timer(*t)
        print(T.timeit(100))
        print(T.timeit(1000))
        #print(T.timeit(10000))
        #print(T.timeit(100000))
        print("-" * 50)

timearray()

print("\n" + "*" * 50)
print("END OF TESTS")

#mv = mdarray.mdarray((10, 10 ), format=b'H2', initializer=range(400, 800))
#print (mv)

"""
