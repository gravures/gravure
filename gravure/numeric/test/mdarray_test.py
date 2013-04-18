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

import pyximport; pyximport.install()
import numeric.mdarray as md


#------------------------------------------------------------------------------
# Constructor

def test_onedim():
    mv = md.mdarray(shape=(10, ), format=b'i1')
    eq_(len(mv), 10)

def test_new():
    #
    # TEST SIMPLE FORMATS
    #
    shapes = [(10, ), (10, 10), (100, 1000), (6, 7, 9), (9, 8, 12, 3, 1, 11)]
    formats_simple = [(b'b', 1), (b'i', 1), (b'i1', 1), (b'i2', 2),
                      (b'i4', 4), (b'i8', 8), (b'u1', 1), (b'u2', 2),
                      (b'u4', 4), (b'u8', 8), (b'f4', 4), (b'f8', 8),
                      (b'f4', 4), (b'f8', 8), (b'c8', 8), (b'c16', 16)]
    for s in shapes:
        for f, i in formats_simple:
            yield _new, s, f, i

    #
    # TEST COMPLEX FORMATS
    #
    formats_complex = [(b'ii', 2, 2), (b'>i2i1i4', 7, 3), (b'fff', 12, 3),
                       (b'u4f4f4', 16, 3), (b'ii<i=i1<f4=fff', 20, 8)]
    for s in shapes:
        for f, i, n in formats_complex:
            yield _new_c, s, f, i, n

    #
    #TODO: TEST WRONG FORMATS
    # b'u4f4f48'

    #
    #TODO: TEST DECIMAL NUMBER b'D'
    #

    #
    # TEST BIG MEMORY USAGE
    # TODO: TEST MEMORY PLATEFORM TO KNOW WHERE IT COULD BREAKS
    #
    # 1Go
    mv = md.mdarray(shape=(1024, 1000, 1000), format=b'i1')
    #time.sleep(3)
    ok_(isinstance(mv, md.mdarray))
    eq_(mv.base, mv)

    # 2Go
    mv = md.mdarray(shape=(1024, 1000, 1000, 2), format=b'i1')
    #time.sleep(3)
    ok_(isinstance(mv, md.mdarray))
    eq_(mv.base, mv)

    # 4Go
    mv = md.mdarray(shape=(1024, 1000, 1000, 4), format=b'i1')
    #time.sleep(3)
    ok_(isinstance(mv, md.mdarray))
    eq_(mv.base, mv)

    #FIXME: Crash the OS, have to restart
    # 12Go
#    mv = md.mdarray(shape=(1024, 1000, 1000, 12), format=b'i1')
#    time.sleep(3)
#    ok_(isinstance(mv, md.mdarray))
#    eq_(mv.base, mv)

    #
    #TODO: TEST C AND F MODE
    #

    #
    #TEST INITIALIZER
    #
    formats_simple = formats_simple[1:] # remove b'b' for this test
    init=range(0, 800)
    for s in shapes:
        for f, i in formats_simple:
            yield _new, s, f, i, init

    init=range(0, 5)
    for s in shapes:
        for f, i in formats_simple:
            yield _new, s, f, i, init

    #TODO: INITIALISER YELDING TUPLE FOR COMPLEX FORMATS

def _new_c(shape, format, itemsize, tuplelen):
    mv = md.mdarray(shape, format)
    ok_(isinstance(mv, md.mdarray))
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

    ok_(isinstance(mv, md.mdarray))
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




#------------------------------------------------------------------------------
# Endiannes

#------------------------------------------------------------------------------
# Overflow

# with overflow

# without overflow

# with clamped overflow

#------------------------------------------------------------------------------



#------------------------------------------------------------------------------
# Main

if __name__ == '__main__':
    nose.main()

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
