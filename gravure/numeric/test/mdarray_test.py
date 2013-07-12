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

from numbers import *
import psutil

import nose
from nose import *
from nose.tools import *
from nose.failure import *

#TODO: change to normal import in futur
import pyximport; pyximport.install()
import numeric.mdarray as md

TEST_COMPLEX_NUMBER = False

#---------------------------------------------------------------------------#
# TEST  numric.Enum                                                         #
#                                                                           #
def test_Enum():
    assert_is_instance(md.MinMaxType.__enum_values__, dict)
    ref_64 = pow(2, 64)-1
    ok_(md.MinMaxType.__enum_values__[ref_64] == 'MAX_UINT64')
    assert_is_instance(md.MinMaxType.MAX_UINT64, Integral)
    assert_is_instance(md.MinMaxType.MAX_UINT64, int)
    ok_(issubclass(md.MinMaxType.MAX_UINT64.__class__, int))
    eq_(md.MinMaxType.MAX_UINT64.real, ref_64)
    eq_(md.MinMaxType.MAX_UINT64.__index__(), ref_64)
    eq_(md.MinMaxType.MAX_UINT64 + 1, ref_64 +1)
    eq_(md.MinMaxType.MAX_UINT64 * 1, ref_64)
    eq_(1 * md.MinMaxType.MAX_UINT64, ref_64)
    eq_(1 + md.MinMaxType.MAX_UINT64, ref_64 + 1)
    eq_(md.MinMaxType.MAX_UINT64 / 1, ref_64 / 1)
    eq_(md.MinMaxType.MAX_UINT64 + md.MinMaxType.MAX_UINT64, ref_64 + ref_64)
    eq_(int(md.MinMaxType.MAX_UINT64), ref_64)
    eq_(float(md.MinMaxType.MAX_UINT64), float(ref_64))
    eq_(md.MinMaxType.MAX_UINT64.__int__(), ref_64)

    assert_raises(NotImplementedError, abs, md.MinMaxType.MAX_UINT64)

    eq_(md.MinMaxType.MAX_UINT64.numerator, ref_64)
    ok_(md.MinMaxType.MAX_UINT64 == 18446744073709551615)
    ok_(18446744073709551615 == md.MinMaxType.MAX_UINT64)
    ok_(not (md.MinMaxType.MAX_UINT64 > 18446744073709551615))
    ok_(md.MinMaxType.MAX_UINT64 > 1)
    ok_(1 < md.MinMaxType.MAX_UINT64)
    ok_(not (md.MinMaxType.MAX_UINT32 > md.MinMaxType.MAX_UINT64))

    #FIXME: freeze python
    #ar = range(int(md.MinMaxType.MAX_INT64), int(md.MinMaxType.MAX_UINT64)+100)
    #for i in ar:
    #    print (i)


shapes = [(10, ), (10, 10), (100, 1000), (6, 7, 9), (9, 8, 12, 3, 1, 11)]
formats_simple = [(b'b', 1), (b'i', 1), (b'i1', 1), (b'i2', 2),
                      (b'i4', 4), (b'i8', 8), (b'u1', 1), (b'u2', 2),
                      (b'u4', 4), (b'u8', 8), (b'f4', 4), (b'f8', 8),
                      (b'f4', 4), (b'f8', 8)]
if TEST_COMPLEX_NUMBER:
    formats_simple.append((b'c8', 8))
    formats_simple.append((b'c16', 16))
formats_complex = [(b'ii', 2, 2), (b'>i2i1i4', 7, 3), (b'fff', 12, 3),
                       (b'=u4f4f4', 12, 3), (b'<iiii1f4fff', 20, 8)]


#---------------------------------------------------------------------------#
# TESTS CONSTRUTOR                                                          #
#                                                                           #
def test_new():
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

def test_empty_shape():
    #                                                                       #
    # TEST EMPTY SHAPE                                                      #
    #                                                                       #
    assert_raises(ValueError, md.mdarray, shape=(10, 0, 5), format=b'i')
    assert_raises(ValueError, md.mdarray, shape=(), format=b'i')

def test_decimal():
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

def test_memory():
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


def test_mode():
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

def test_range_initializer():
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

def test_range_tuple_initializer():
    #                                                                       #
    # INITIALISER YELDING TUPLE FOR COMPLEX FORMATS                         #
    #                                                                       #
    class IterTuple:

        def __init__(self):
            self.x = 1
            self.y = 2
            self.z = 4

        def __next__(self):
            self.x += self.x
            self.y += self.y
            self.z += self.z
            if self.x >= 126 : self.x = 0
            if self.y >= 126 : self.y = 0
            if self.z >= 126 : self.z = 0
            return (self.x, self.y, self.z)

        def __iter__(self):
            return self

    formats_complex = [(b'iii', 3, 3), (b'fff', 12, 3), (b'>i2i1i4', 7, 3),
                       (b'u4f4f4', 12, 3)]

    for s in shapes:
        for f, i, n in formats_complex:
            yield _new_complex, s, f, i, n, IterTuple()

def _new_complex(shape, format, itemsize, tuplelen, init = None):
    mv = md.mdarray(shape, format, initializer = init, overflow=None)
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

    item = mv.__getitem__(tuple([0] * len(shape)))
    eq_(tuplelen, len(item))
    ok_(isinstance(item, tuple))

def test_list_initializer():
    #                                                                       #
    # TEST LIST INITIALIZER                                                 #
    #                                                                       #
    i = [10, 9, 3, 2, 4, 5, 8]
    mv = md.mdarray(shape=(10, 10, 10), format=b'i', order="C", initializer=i)
    assert_is_instance(mv, md.mdarray)

def test_buffer_initializer():
    #                                                                       #
    # TEST BUFFER INTERFACE INITIALIZER                                     #
    #                                                                       #
    # buffer.size * itemsize >= array.size * itemsize                       #
    from array import array
    ar = array('b', range(100))
    mv = md.mdarray(shape=(10, 10), format=b'i', initializer=ar)
    assert_is_instance(mv, md.mdarray)

    ar = array("h", range(100))
    mv = md.mdarray(shape=(10, 20), format=b'<i', initializer=ar)
    assert_is_instance(mv, md.mdarray)
    eq_(mv.base, ar)
    ar[1] = 9
    id_ar = id(ar)
    eq_(ar[1], mv[0, 2])
    ar = None
    eq_(id(mv.base), id_ar)
    eq_(9, mv[0, 2])

    ar = array('b', range(100))
    assert_raises(TypeError, md.mdarray, shape=(10, 20), format=b'i2',
                  initializer=ar)
    assert_raises(TypeError, md.mdarray, shape=(100, ), format=b'i',
                  initializer=ar, offset=50)

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
#TODO: ENDIANESS                                                                 #
#                                                                           #



#----------------------------------------------------------------------------
# OVERFLOW                                                                  #
#                                                                           #
def test_overflow():
    #                                                                       #
    # with overflow                                                         #
    #                                                                       #
    ar = range(-200, 300)
    assert_raises(OverflowError, md.mdarray, shape=(10, 10), format=b'>i',
                  initializer=ar)
    ar = range(-600, 300)
    assert_raises(OverflowError, md.mdarray, shape=(10, 10), format=b'>i',
                  initializer=ar)
    ar = range(100, 300)
    assert_raises(OverflowError, md.mdarray, shape=(10, 10), format=b'>i',
                  initializer=ar)
    ar = range(-10, 300)
    assert_raises(OverflowError, md.mdarray, shape=(10, 10), format=b'>u',
                  initializer=ar)
    ar = range(18446744073709551615, 18446744073709551715)
    assert_raises(OverflowError, md.mdarray, shape=(10, 10), format=b'u8',
                  initializer=ar)
    ar = range(-10, 18446744073709551715)
    assert_raises(OverflowError, md.mdarray, shape=(10, 10), format=b'u8',
                  initializer=ar)

    #                                                                       #
    # without overflow                                                      #
    #                                                                       #
    ar = range(-200, 300)
    mv = md.mdarray(shape=(10, 10), format=b'>i', initializer=ar, overflow=False)
    eq_(mv[0, 0], 56)
    eq_(mv[9, 9], -101)
    ar = range(-600, 300)
    mv = md.mdarray(shape=(10, 10), format=b'>i', initializer=ar, overflow=False)
    eq_(mv[0, 0], -88)
    eq_(mv[9, 9], 11)
    ar = range(100, 300)
    mv = md.mdarray(shape=(10, 10), format=b'>i', initializer=ar, overflow=False)
    eq_(mv[0, 0], 100)
    eq_(mv[9, 9], -57)
    ar = range(-10, 300)
    mv = md.mdarray(shape=(10, 10), format=b'>u', initializer=ar, overflow=False)
    eq_(mv[0, 0], 246)
    eq_(mv[9, 9], 89)
    ar = range(18446744073709551615, 18446744073709551715)
    mv = md.mdarray(shape=(10, 10), format=b'u8', initializer=ar, overflow=False)
    eq_(mv[0, 0], 18446744073709551615)
    eq_(mv[9, 9], 98)
    ar = range(-10, 18446744073709551715)
    mv = md.mdarray(shape=(10, 10), format=b'u8', initializer=ar, overflow=False)
    eq_(mv[0, 0], 18446744073709551606)
    eq_(mv[9, 9], 89)

    #                                                                       #
    # with clamped overflow                                                 #
    #                                                                       #
    ar = range(-200, 300)
    mv = md.mdarray(shape=(10, 10), format=b'>i', initializer=ar, overflow=False,
                    clamp=True)
    eq_(mv[0, 0], -128)
    eq_(mv[1, 7], -128)
    eq_(mv[9, 9], -101)
    ar = range(-600, 300)
    mv = md.mdarray(shape=(10, 10), format=b'>i', initializer=ar, overflow=False,
                    clamp=True)
    eq_(mv[0, 0], -128)
    eq_(mv[1, 7], -128)
    eq_(mv[9, 9], -128)
    ar = range(100, 300)
    mv = md.mdarray(shape=(10, 10), format=b'>i', initializer=ar, overflow=False,
                    clamp=True)
    eq_(mv[0, 0], 100)
    eq_(mv[9, 3], 127)
    eq_(mv[9, 9], 127)
    ar = range(-10, 300)
    mv = md.mdarray(shape=(10, 10), format=b'>u', initializer=ar, overflow=False,
                    clamp=True)
    eq_(mv[0, 0], 0)
    eq_(mv[0, 9], 0)
    eq_(mv[9, 9], 89)
    ar = range(18446744073709551615, 18446744073709551715)
    mv = md.mdarray(shape=(10, 10), format=b'u8', initializer=ar, overflow=False,
                    clamp=True)
    eq_(mv[0, 0], 18446744073709551615)
    eq_(mv[9, 9], 18446744073709551615)
    ar = range(-10, 18446744073709551715)
    mv = md.mdarray(shape=(10, 10), format=b'u8', initializer=ar, overflow=False,
                    clamp=True)
    eq_(mv[0, 0], 0)
    eq_(mv[9, 9], 89)

#----------------------------------------------------------------------------
#TODO: ARRAY_INTERFACE                                                                 #
#                                                                           #
def test_array_interface():
    pass


#----------------------------------------------------------------------------
# BUFFER_PROTOCOL                                                           #
#                                                                           #
def test_buffer_protocol():
    ar = range(1, 101)
    mv = md.mdarray(shape=(100, ), format=b'<i1', initializer=ar)
    mem = memoryview(mv)

    eq_((100, ), mem.shape)
    eq_(1, mem.ndim)
    eq_(1, mem.itemsize)
    eq_((1, ), mem.strides)
    eq_(False, mem.readonly)
    eq_("<b", mem.format)
    eq_(b'\x08', mem[7])
    res = b"""\x01\x02\x03\x04\x05\x06\x07\x08\t\n\x0b\x0c\r\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcd"""
    eq_(mem.tobytes(), res)
    mem[0] = b'\x08'
    eq_(mv[0], 8)

    mv = md.mdarray(shape=(100, ), format=b'ii')
    mem = memoryview(mv)

#----------------------------------------------------------------------------
# CYTHON MEMORYVIEW                                                         #
#                                                                           #
#----------------------------------------------------------------------------
def test_memview():
    ar = range(0, 100)
    mv = md.mdarray(shape=(10, 10), format=b'<i1', initializer=ar)
    mem = mv.memview

    eq_(2, mem.ndim)
    eq_(1, mem.itemsize)
    eq_((10, 10), mem.shape)
    eq_((10, 1), mem.strides)
    eq_([-1, -1], mem.suboffsets)
    eq_(100, mem.nbytes)
    eq_(mv, mem.base)
    eq_((44, ), mem[4, 4])
    eq_((10, ), mem[4].shape)

    mv = md.mdarray(shape=(10, 10), format=b'iif')
    mem = mv.memview
    eq_((0, 0, 0.0), mem[4, 4])


#----------------------------------------------------------------------------
# __GET_ITEM__                                                              #
#                                                                           #
shapes = [(10, ), (10, 10), (100, 1000), (6, 7, 9), (9, 8, 12, 3, 1, 11)]

formats = [(b'b'), (b'i1'), (b'i2'), (b'i4'), (b'i8'), (b'u1'), (b'u2'),
                  (b'u4'), (b'u8'), (b'f4'), (b'f8'),(b'f4'), (b'f8')]
if TEST_COMPLEX_NUMBER:
    formats.append((b'c8'))
    formats.append((b'c16'))

def array_eq(a, b):
    r = False
    if a.shape == b.shape:
        d = []
        e = []
        for f in a:
            d.append(f)
        for f in b:
            e.append(f)
        r = d == e
    return r

def get_item_a(shape, format):
    mv = md.mdarray(shape, format, initializer=range(0, 127))
    # ellipsis
    ok_(array_eq(mv, mv[...]))
    ok_(array_eq(mv, mv[:]))

def test_get_item():
    for s in shapes:
        for f in formats:
            yield get_item_a, s, f

    mv = md.mdarray((10, 10), format='i1', initializer=range(0, 127))

    res = mv[0:4,1:4]
    l_res = [1, 2, 3, 11, 12, 13, 21, 22, 23, 31, 32, 33]
    eq_(res.ndim, 2)
    for i, e in enumerate(res):
        eq_(e, l_res[i])

    res = mv[...,2:6]
    l_res = [2, 3, 4, 5, 12, 13, 14, 15, 22, 23, 24, 25, 32, 33, 34, 35,
             42, 43, 44, 45, 52, 53, 54, 55, 62, 63, 64, 65, 72, 73, 74, 75,
             82, 83, 84, 85, 92, 93, 94, 95]
    eq_(res.ndim, 2)
    for i, e in enumerate(res):
        eq_(e, l_res[i])

    res = mv[0:4, 2]
    l_res = [2, 12, 22, 32]
    eq_(res.ndim, 1)
    for i, e in enumerate(res):
        eq_(e, l_res[i])

    res = mv[0:4, -7]
    l_res = [3, 13, 23, 33]
    eq_(res.ndim, 1)
    for i, e in enumerate(res):
        eq_(e, l_res[i])

    res = mv[8:2:-2,4:2:-1]
    l_res = [84, 83, 64, 63, 44, 43]
    eq_(res.ndim, 2)
    for i, e in enumerate(res):
        eq_(e, l_res[i])

    res = mv[2]
    l_res = [20, 21, 22, 23, 24, 25, 26, 27, 28, 29]
    eq_(res.ndim, 1)
    for i, e in enumerate(res):
        eq_(e, l_res[i])

    eq_(mv[4,4], 44)

#----------------------------------------------------------------------------
# __SET_ITEM__                                                              #
#                                                                           #
def test_set_item_by_index():
    mv = md.mdarray((10, 10 ), format=b'i1', initializer=range(0, 800))
    mv[4, 4] = 9
    res = [0,  1,  2,  3,  4,  5,  6,  7,  8,  9,
           10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
           20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
           30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
           40, 41, 42, 43, 9, 45, 46, 47, 48, 49,
           50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
           60, 61, 62, 63, 64, 65, 66, 67, 68, 69,
           70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
           80, 81, 82, 83, 84, 85, 86, 87, 88, 89,
           90, 91, 92, 93, 94, 95, 96, 97, 98, 99]
    for i, e in enumerate(mv):
        eq_(e, res[i])

def test_set_item_scalar_by_slice():
    mv = md.mdarray((10, 10), format='i1', initializer=range(0, 127))
    mv[...] = 4
    for e in mv:
        eq_(e, 4)

    mv = md.mdarray((10, 10), format='i1', initializer=range(0, 127))
    mv[:] = 4
    for e in mv:
        eq_(e, 4)

    mv = md.mdarray((10, 10 ), format=b'i1', initializer=range(0, 800))
    mv[0:4,1:4] = 4
    for e in range(4):
        for f in range(1, 4):
            eq_(mv[e, f], 4)

    mv = md.mdarray((10, 10 ), format=b'i1', initializer=range(0, 800))
    mv[...,2:6] = 4
    for e in range(10):
        for f in range(2, 6):
            eq_(mv[e, f], 4)

    mv = md.mdarray((10, 10 ), format=b'i1', initializer=range(0, 800))
    mv[0:4, 2] = 4
    res = [0, 1, 4, 3, 4, 5, 6, 7, 8, 9,
           10, 11, 4, 13, 14, 15, 16, 17, 18, 19,
           20, 21, 4, 23, 24, 25, 26, 27, 28, 29,
           30, 31, 4, 33, 34, 35, 36, 37, 38, 39,
           40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
           50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
           60, 61, 62, 63, 64, 65, 66, 67, 68, 69,
           70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
           80, 81, 82, 83, 84, 85, 86, 87, 88, 89,
           90, 91, 92, 93, 94, 95, 96, 97, 98, 99]
    for i, e in enumerate(mv):
        eq_(e, res[i])

    mv = md.mdarray((10, 10 ), format=b'i1', initializer=range(0, 800))
    mv[0:4, -5] = 4
    res = [0,  1,  2,  3,  4,  4,  6,  7,  8,  9,
           10, 11, 12, 13, 14, 4, 16, 17, 18, 19,
           20, 21, 22, 23, 24, 4, 26, 27, 28, 29,
           30, 31, 32, 33, 34, 4, 36, 37, 38, 39,
           40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
           50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
           60, 61, 62, 63, 64, 65, 66, 67, 68, 69,
           70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
           80, 81, 82, 83, 84, 85, 86, 87, 88, 89,
           90, 91, 92, 93, 94, 95, 96, 97, 98, 99]
    for i, e in enumerate(mv):
        eq_(e, res[i])

    mv = md.mdarray((10, 10 ), format=b'i1', initializer=range(0, 800))
    mv[8:2:-2,4:2:-1] = 4
    res = [0,  1,  2,  3,  4,  5,  6,  7,  8,  9,
           10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
           20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
           30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
           40, 41, 42, 4, 4, 45, 46, 47, 48, 49,
           50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
           60, 61, 62, 4, 4, 65, 66, 67, 68, 69,
           70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
           80, 81, 82, 4, 4, 85, 86, 87, 88, 89,
           90, 91, 92, 93, 94, 95, 96, 97, 98, 99]
    for i, e in enumerate(mv):
        eq_(e, res[i])

    mv = md.mdarray((10, 10 ), format=b'i1', initializer=range(0, 800))
    mv[2] = 4
    res = [0,  1,  2,  3,  4,  5,  6,  7,  8,  9,
           10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
           4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
           30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
           40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
           50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
           60, 61, 62, 63, 64, 65, 66, 67, 68, 69,
           70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
           80, 81, 82, 83, 84, 85, 86, 87, 88, 89,
           90, 91, 92, 93, 94, 95, 96, 97, 98, 99]
    for i, e in enumerate(mv):
        eq_(e, res[i])

class TupleRange:

    def __init__(self, count=1, starts=None, stops=None, steps=None, loop=True):
        self.count = count
        if starts==None:
            starts = [0] * count
        if stops==None:
            stops = [126] * count
        if steps==None:
            steps = [1] * count
        if len(starts)!=count or len(stops)!=count or len(steps)!=count:
            raise AttributeError("length of arrgs starts, stops, steps should be %i" %count)
        self._vars = self._starts = starts
        self._stops = stops
        self._steps = steps
        self.loop = loop

    def __next__(self):
        stop_iter = 0
        for i in range(self.count):
            if self._vars[i]==self._stops[i]:
                if self.loop:
                    self._vars[i] = self._starts[i]
                else:
                    stop_iter += 1
            else:
                self._vars[i] += self._steps[i]
        if stop_iter == self.count:
            raise StopIteration()
        return tuple(self._vars)

    def __iter__(self):
        return self


def test_set_item_slice_by_slice():
    mva = md.mdarray((10, 10), format=b'i1', initializer=[0])
    mvb = md.mdarray((10, 10), format=b'i1', initializer=range(0, 100))
    mva[:] = mvb
    res = [50, 51, 52, 53, 54, 55, 56, 57, 58, 59]
    cmp = mva[5, :]
    for i in range(10):
        eq_(res[i], cmp[i])

    mva = md.mdarray((10, 10), format=b'i1', initializer=[0])
    mvb = md.mdarray((1, 10), format=b'i1', initializer=range(0, 100))
    mva[:] = mvb
    res = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    cmp = mva[0, :]
    for i in range(10):
        eq_(res[i], cmp[i])
    cmp = mva[5, :]
    for i in range(10):
        eq_(res[i], cmp[i])

    mva = md.mdarray((10, 10), format=b'ii')
    mvb = md.mdarray((1, 10), format='i2i2', initializer=TupleRange(2))
    mva[:] = mvb[:]
    res = [(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7), (8, 8), (9, 9), (10, 10)]
    cmp = mva[0, :]
    for i in range(10):
        eq_(res[i], cmp[i])
    cmp = mva[6, :]
    for i in range(10):
        eq_(res[i], cmp[i])

    mva = md.mdarray((3, 3, 3), format=b'i1', initializer=[0])
    mvb = md.mdarray((1, 3), format=b'i1', initializer=range(0, 100))
    mva[:] = mvb
    res = [0, 1, 2]
    cmp = mva[0, 0, :]
    for i in range(3):
        eq_(res[i], cmp[i])
    cmp = mva[2, 2, :]
    for i in range(3):
        eq_(res[i], cmp[i])

    mva = md.mdarray((3, 3, 3), format=b'i1', initializer=[0])
    mvb = md.mdarray((1, 6), format=b'i1', initializer=range(0, 100))
    mva[:] = mvb[0,::2]
    res = [0, 2, 4]
    cmp = mva[0, 0, :]
    for i in range(3):
        eq_(res[i], cmp[i])
    cmp = mva[2, 2, :]
    for i in range(3):
        eq_(res[i], cmp[i])

    mva = md.mdarray((3, 3, 6), format=b'i1', initializer=[1])
    mvb = md.mdarray((1, 6), format=b'i1', initializer=range(0, 100))
    mva[..., ::2] = mvb[0,::2]
    res = [0, 1, 2, 1, 4, 1]
    cmp = mva[0, 0, :]
    for i in range(6):
        eq_(res[i], cmp[i])
    cmp = mva[2, 2, :]
    for i in range(6):
        eq_(res[i], cmp[i])

    mva = md.mdarray((3, 3, 6), format=b'i1', initializer=[1])
    mvb = md.mdarray((1, 6), format=b'i1', initializer=range(0, 100))
    mva[..., ::-1] = mvb[:]
    res = [5, 4, 3, 2, 1, 0]
    cmp = mva[0, 0, :]
    for i in range(6):
        eq_(res[i], cmp[i])

    #TODO: numpy

#----------------------------------------------------------------------------
# TRANSPOSE                                                                 #
#                                                                           #
def test_transpose():
    mva = md.mdarray((10, 5), format=b'i', order='c', initializer=range(100))
    shape = list(mva.shape)
    shape.reverse()
    strides = list(mva.strides)
    strides.reverse()
    a = mva[1, 4]
    mva.transpose()
    eq_(shape, list(mva.shape))
    eq_(strides, list(mva.strides))
    eq_(a, mva[4, 1])

#----------------------------------------------------------------------------
# RESHAPE                                                                   #
#                                                                           #
def test_reshape():
    mva = md.mdarray((10, 5), format=b'i', order='c', initializer=range(100))
    mva.reshape((50, ))
    eq_(1, mva.ndim)
    eq_((50, ), mva.shape)
    mva.reshape((1, 5, 10))
    eq_(3, mva.ndim)
    eq_((1, 5, 10), mva.shape)

#----------------------------------------------------------------------------
# FLATTEN                                                                   #
#                                                                           #
def test_flatten():
    mva = md.mdarray((10, 5), format=b'i', order='c', initializer=range(100))
    mva.flatten()
    eq_(1, mva.ndim)
    eq_((50, ), mva.shape)

#----------------------------------------------------------------------------
#TODO: __STR__                                                                 #
#                                                                           #
def test_str():
    mva = md.mdarray((10, 10), format=b'i', initializer=range(100))
    print(mva, '\n')

    mva = md.mdarray((10, 10), format=b'ii', initializer=TupleRange(2))
    print(mva, '\n')

#----------------------------------------------------------------------------
#TODO: ITERATOR                                                                 #
#                                                                           #
def iterator():
    # Iterator
    print("\n" + "*" * 50)
    print("for i in mv:\n")
    for i, v in enumerate(mv):
        print (i, "#", v)



#------------------------------------------------------------------------------
# Main
from nose.plugins.testid import TestId
from nose.config import Config

if __name__ == '__main__':
    nose.run()




#----------------------------------------------------------------------------
# BENCHMARK                                                                 #
#                                                                           #
#----------------------------------------------------------------------------
def benchmark():
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





