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

cimport cython

include "TYPE_DEF.pxi"

#
# Whatever TYPE_DEF.pxi define, we don't have yet routines for the types below.
#
DEF HAVE_INT128 = 0
DEF HAVE_INT256 = 0
DEF HAVE_UINT128 = 0
DEF HAVE_UINT256 = 0
DEF HAVE_FLOAT16 = 0
DEF HAVE_FLOAT80 = 0
DEF HAVE_FLOAT96 = 0
DEF HAVE_FLOAT128 = 0
DEF HAVE_FLOAT256 = 0
DEF HAVE_COMPLEX32 = 0
DEF HAVE_COMPLEX64 = 0
DEF HAVE_COMPLEX128 = 0
DEF HAVE_COMPLEX160 = 0
DEF HAVE_COMPLEX192 = 0
DEF HAVE_COMPLEX256 = 0
DEF HAVE_COMPLEX512 = 0

DEF MAX_STRUCT_LENGTH = 50
DEF BASE_FORMATS = 9
DEF FORMATS = BASE_FORMATS + HAVE_INT64 + HAVE_UINT64 + HAVE_INT128 + HAVE_UINT128 + \
              HAVE_INT256 + HAVE_UINT256 + HAVE_FLOAT16 + HAVE_FLOAT80 + HAVE_FLOAT96 + \
              HAVE_FLOAT128 + HAVE_FLOAT256 + HAVE_COMPLEX64 +HAVE_COMPLEX128 + \
              HAVE_COMPLEX160 + HAVE_COMPLEX192 + HAVE_COMPLEX256 + HAVE_COMPLEX512

cdef extern from *:
    ctypedef struct PyObject
    void Py_INCREF(object)
    void Py_DECREF(object)

cdef extern from "stdlib.h":
    void *malloc(size_t) nogil
    void free(void *) nogil
    void *memcpy(void *dest, void *src, size_t n) nogil

cdef extern from "Python.h":
    int _PyFloat_Pack4(double x, unsigned char *p, int le) except -1
    int _PyFloat_Pack8(double x, unsigned char *p, int le) except -1
    double _PyFloat_Unpack4(unsigned char *p, int le) except? -1.0
    double _PyFloat_Unpack8(unsigned char *p, int le) except? -1.0

#
# host endian routines.
#
cdef int nu_bool(char *p, cnumber *c)except -1:
    c.val.b = <bint> p[0]
    c.ctype = BOOL
    return 0

cdef int nu_int8(char *p, cnumber *c)except -1:
    c.val.i8 = <int8> p[0]
    c.ctype = INT8
    return 0

cdef int nu_uint8(char *p, cnumber *c)except -1:
    c.val.u8 = <uint8> p[0]
    c.ctype = UINT8
    return 0

cdef int nu_int16(char *p, cnumber *c)except -1:
    memcpy(<char *> &c.val.i16, p, 2)
    c.ctype = INT16
    return 0

cdef int nu_uint16(char *p, cnumber *c)except -1:
    memcpy(<char *> &c.val.u16, p, 2)
    c.ctype = UINT16
    return 0

cdef int nu_int32(char *p, cnumber *c)except -1:
    memcpy(<char *> &c.val.i32, p, 4)
    c.ctype = INT32
    return 0

cdef int nu_uint32(char *p, cnumber *c)except -1:
    memcpy(<char *> &c.val.u32, p, 4)
    c.ctype = UINT32
    return 0

IF HAVE_INT64:
    cdef int nu_int64(char *p, cnumber *c)except -1:
        memcpy(<char *> &c.val.i64, p, 8)
        c.ctype = INT64
        return 0

IF HAVE_UINT64:
    cdef int nu_uint64(char *p, cnumber *c)except -1:
        memcpy(<char *> &c.val.u64, p, 8)
        c.ctype = UINT64
        return 0

cdef int nu_float32(char *p, cnumber *c)except -1:
    memcpy(<char *> &c.val.f32, p, 4)
    c.ctype = FLOAT32
    return 0

cdef int nu_float64(char *p, cnumber *c)except -1:
    memcpy(<char *> &c.val.f64, p, 8)
    c.ctype = FLOAT64
    return 0

#FIXME:
#cdef nu_float128(char *p, formatdef *f):
#    cdef float128 iv
#    memcpy(<char *> &iv, p, sizeof(float128))
#    return iv

cdef void np_bool(char *p, cnumber *c):
    memcpy(p, <char *> &c.val.b, 1)

cdef void np_int8(char *p, cnumber *c):
    p[0] = <char> c.val.i8

cdef void np_uint8(char *p, cnumber *c):
    p[0] = <char> c.val.u8

cdef void np_int16(char *p, cnumber *c):
    memcpy(p, <char *> &c.val.i16, 2)

cdef void np_uint16(char *p, cnumber *c):
    memcpy(p, <char *> &c.val.u16, 2)

cdef void np_int32(char *p, cnumber *c):
    memcpy(p, <char *> &c.val.i32, 4)

cdef void np_uint32(char *p, cnumber *c):
    memcpy(p, <char *> &c.val.u32, 4)

IF HAVE_INT64:
    cdef void np_int64(char *p, cnumber *c):
        memcpy(p, <char *> &c.val.i64, 8)

IF HAVE_UINT64:
    cdef void np_uint64(char *p, cnumber *c):
        memcpy(p, <char *> &c.val.u64, 8)

cdef void np_float32(char *p, cnumber *c):
    memcpy(p, <char *> &c.val.f32, 4)

cdef void np_float64(char *p, cnumber *c):
    memcpy(p, <char *> &c.val.f64, 8)

#FIXME:
#cdef np_float128(char *p, object v, formatdef *f):
#    cdef float128 fv
#    fv = <float128> PyFloat_AsDouble(v)
#    print "float128 :", fv
#    #if isinstance(v, float):
#    #    fv = v
#    #else:
#    #    raise TypeError("float128 format requires a Float value")
#    memcpy(p, <char *> &fv, sizeof(float128))

#
# Little-endian routines.
#
cdef int lu_int16(char *p, cnumber *c)except -1:
    cdef Py_ssize_t i = 2
    cdef unsigned char *b = <unsigned char *> p
    while i > 0:
        i -= 1
        c.val.i16 = (c.val.i16 << 8) | b[i]
    c.ctype = INT16
    # Extend the sign bit
    #iv |= -(iv & (1 << ((8 * sizeof(int16)) - 1)))
    return 0

cdef int lu_uint16(char *p, cnumber *c)except -1:
    cdef Py_ssize_t i = 2
    cdef unsigned char *b = <unsigned char *> p
    while i > 0:
        i -= 1
        c.val.u16 = (c.val.u16 << 8) | b[i]
    c.ctype = UINT16
    return 0

cdef int lu_int32(char *p, cnumber *c)except -1:
    cdef Py_ssize_t i = 4
    cdef unsigned char *b = <unsigned char *> p
    while i > 0:
        i -= 1
        c.val.i32 = (c.val.i32 << 8) | b[i]
    c.ctype = INT32
    # Extend the sign bit
    #iv |= -(iv & (1 << ((8 * sizeof(int16)) - 1)))
    return 0

cdef int lu_uint32(char *p, cnumber *c)except -1:
    cdef Py_ssize_t i = 4
    cdef unsigned char *b = <unsigned char *> p
    while i > 0:
        i -= 1
        c.val.u32 = (c.val.u32 << 8) | b[i]
    c.ctype = UINT32
    return 0

IF HAVE_INT64:
    cdef int lu_int64(char *p, cnumber *c)except -1:
        cdef Py_ssize_t i = 8
        cdef unsigned char *b = <unsigned char *> p
        while i > 0:
            i -= 1
            c.val.i64 = (c.val.i64 << 8) | b[i]
        c.ctype = INT64
        # Extend the sign bit
        #iv |= -(iv & (1 << ((8 * sizeof(int16)) - 1)))
        return 0

IF HAVE_UINT64:
    cdef int lu_uint64(char *p, cnumber *c)except -1:
        cdef Py_ssize_t i = 8
        cdef unsigned char *b = <unsigned char *> p
        while i > 0:
            i -= 1
            c.val.u64 = (c.val.u64 << 8) | b[i]
        c.ctype = UINT64
        return 0

cdef int lu_float32(char *p, cnumber *c) except -1:
    c.val.f32 = _PyFloat_Unpack4(<unsigned char *> p, 1)
    c.ctype = FLOAT32
    return 0

cdef int lu_float64(char *p, cnumber *c) except -1:
    c.val.f64 = _PyFloat_Unpack8(<unsigned char *> p, 1)
    c.ctype = FLOAT64
    return 0

#FIXME:
#cdef lu_float128(char *p, formatdef *f):

cdef void lp_int16(char *p, cnumber *c):
    cdef Py_ssize_t i = 2
    while i > 0:
        p[0] = <char> c.val.i16
        p += 1
        c.val.i16 >>= 8
        i -= 1

cdef void lp_uint16(char *p, cnumber *c):
    cdef Py_ssize_t i = 2
    while i > 0:
        p[0] = <char> c.val.u16
        p += 1
        c.val.u16 >>= 8
        i -= 1

cdef void lp_int32(char *p, cnumber *c):
    cdef Py_ssize_t i = 4
    while i > 0:
        p[0] = <char> c.val.i32
        p += 1
        c.val.i32 >>= 8
        i -= 1

cdef void lp_uint32(char *p, cnumber *c):
    cdef Py_ssize_t i = 4
    while i > 0:
        p[0] = <char> c.val.u32
        p += 1
        c.val.u32 >>= 8
        i -= 1

IF HAVE_INT64:
    cdef void lp_int64(char *p, cnumber *c):
        cdef Py_ssize_t i = 8
        while i > 0:
            p[0] = <char> c.val.i64
            p += 1
            c.val.i64 >>= 8
            i -= 1

IF HAVE_UINT64:
    cdef void lp_uint64(char *p, cnumber *c):
        cdef Py_ssize_t i = 8
        while i > 0:
            p[0] = <char> c.val.u64
            p += 1
            c.val.u64 >>= 8
            i -= 1

cdef void lp_float32(char *p, cnumber *c):
    _PyFloat_Pack4(c.val.f32, <unsigned char *> p, 1)

cdef void lp_float64(char *p, cnumber *c):
    _PyFloat_Pack8(c.val.f64, <unsigned char *> p, 1)

#FIXME:
#cdef lp_float128(char *p, object v, formatdef *f):
#    cdef float128 fv
#    fv = PyFloat_AsDouble(v)
#    #_PyFloat_Pack8(fv, <unsigned char *> p, 1)

#
# Big-endian routines.
#
cdef int bu_int16(char *p, cnumber *c)except -1:
    cdef Py_ssize_t i = 2
    cdef unsigned char *b = <unsigned char *> p
    while i > 0:
        i -= 1
        c.val.i16 = (c.val.i16 << 8) | b[0]
        b += 1
    c.ctype = INT16
    # Extend the sign bit
    #iv |= -(iv & (1 << ((8 * sizeof(int16)) - 1)))
    return 0

cdef int bu_uint16(char *p, cnumber *c)except -1:
    cdef Py_ssize_t i = 2
    cdef unsigned char *b = <unsigned char *> p
    while i > 0:
        i -= 1
        c.val.u16 = (c.val.u16 << 8) | b[0]
        b += 1
    c.ctype = UINT16
    return 0

cdef int bu_int32(char *p, cnumber *c)except -1:
    cdef Py_ssize_t i = 4
    cdef unsigned char *b = <unsigned char *> p
    while i > 0:
        i -= 1
        c.val.i32 = (c.val.i32 << 8) | b[0]
        b += 1
    c.ctype = INT32
    # Extend the sign bit
    #iv |= -(iv & (1 << ((8 * sizeof(int16)) - 1)))
    return 0

cdef int bu_uint32(char *p, cnumber *c)except -1:
    cdef Py_ssize_t i = 4
    cdef unsigned char *b = <unsigned char *> p
    while i > 0:
        i -= 1
        c.val.u32 = (c.val.u32 << 8) | b[0]
        b += 1
    c.ctype = UINT32
    return 0

IF HAVE_INT64:
    cdef int bu_int64(char *p, cnumber *c)except -1:
        cdef Py_ssize_t i = 8
        cdef unsigned char *b = <unsigned char *> p
        while i > 0:
            i -= 1
            c.val.i64 = (c.val.i64 << 8) | b[0]
            b += 1
        c.ctype = INT64
        # Extend the sign bit
        #iv |= -(iv & (1 << ((8 * sizeof(int16)) - 1)))
        return 0

IF HAVE_UINT64:
    cdef int bu_uint64(char *p, cnumber *c)except -1:
        cdef Py_ssize_t i = 8
        cdef unsigned char *b = <unsigned char *> p
        while i > 0:
            i -= 1
            c.val.u64 = (c.val.u64 << 8) | b[0]
            b += 1
        c.ctype = UINT64
        return 0

cdef int bu_float32(char *p, cnumber *c)except -1:
    c.val.f32 = _PyFloat_Unpack4(<unsigned char *> p, 0)
    c.ctype = FLOAT32
    return 0

cdef int bu_float64(char *p, cnumber *c)except -1:
    c.val.f64 = _PyFloat_Unpack8(<unsigned char *> p, 0)
    c.ctype = FLOAT64
    return 0

#FIXME:
#cdef bu_float128(char *p, formatdef *f):

cdef void bp_int16(char *p, cnumber *c):
    cdef Py_ssize_t i = 2
    while i > 0:
        i -= 1
        p[i] = <char> c.val.i16
        c.val.i16 >>= 8

cdef void bp_uint16(char *p, cnumber *c):
    cdef Py_ssize_t i = 2
    while i > 0:
        i -= 1
        p[i] = <char> c.val.u16
        c.val.u16 >>= 8

cdef void bp_int32(char *p, cnumber *c):
    cdef Py_ssize_t i = 4
    while i > 0:
        i -= 1
        p[i] = <char> c.val.i32
        c.val.i32 >>= 8

cdef void bp_uint32(char *p, cnumber *c):
    cdef Py_ssize_t i = 4
    while i > 0:
        i -= 1
        p[i] = <char> c.val.u32
        c.val.u32 >>= 8

IF HAVE_INT64:
    cdef void bp_int64(char *p, cnumber *c):
        cdef Py_ssize_t i = 8
        while i > 0:
            i -= 1
            p[i] = <char> c.val.i64
            c.val.i64 >>= 8

IF HAVE_UINT64:
    cdef void bp_uint64(char *p, cnumber *c):
        cdef Py_ssize_t i = 8
        while i > 0:
            i -= 1
            p[i] = <char> c.val.u64
            c.val.u64 >>= 8

cdef void bp_float32(char *p, cnumber *c):
    _PyFloat_Pack4(c.val.f32, <unsigned char *> p, 0)

cdef void bp_float64(char *p, cnumber *c):
    _PyFloat_Pack8(c.val.f64, <unsigned char *> p, 0)

#FIXME:
#cdef bp_float128(char *p, object v, formatdef *f):
#    cdef float128 fv
#    fv = PyFloat_AsDouble(v)
#    #_PyFloat_Pack8(fv, <unsigned char *> p, b)


cdef I = 0
cdef formatdef host_endian_table [FORMATS]
host_endian_table[I]     = formatdef(format=BOOL,       size=1,  alignment=0,  unpack=nu_bool,       pack=np_bool)
I += 1
host_endian_table[I]     = formatdef(format=INT8,       size=1,  alignment=0,  unpack=nu_int8,       pack=np_int8)
I += 1
host_endian_table[I]     = formatdef(format=INT16,      size=2,  alignment=0,  unpack=nu_int16,      pack=np_int16)
I += 1
host_endian_table[I]     = formatdef(format=INT32,      size=4,  alignment=0,  unpack=nu_int32,      pack=np_int32)
I += 1
IF HAVE_INT64:
    host_endian_table[I] = formatdef(format=INT64,      size=8,  alignment=0,  unpack=nu_int64,      pack=np_int64)
    I += 1
IF HAVE_INT128:
    host_endian_table[I] = formatdef(format=INT128,     size=16, alignment=0,  unpack=nu_int128,     pack=np_int128)
    I += 1
host_endian_table[I]     = formatdef(format=UINT8,      size=1,  alignment=0,  unpack=nu_uint8,      pack=np_uint8)
I += 1
host_endian_table[I]     = formatdef(format=UINT16,     size=2,  alignment=0,  unpack=nu_uint16,     pack=np_uint16)
I += 1
host_endian_table[I]     = formatdef(format=UINT32,     size=4,  alignment=0,  unpack=nu_uint32,     pack=np_uint32)
I += 1
IF HAVE_UINT64:
    host_endian_table[I] = formatdef(format=UINT64,     size=8,  alignment=0,  unpack=nu_uint64,     pack=np_uint64)
    I += 1
IF HAVE_UINT128:
    host_endian_table[I] = formatdef(format=UINT128,    size=16, alignment=0,  unpack=nu_uint128,    pack=np_uint128)
    I += 1
host_endian_table[I]     = formatdef(format=FLOAT32,    size=4,  alignment=0,  unpack=nu_float32,    pack=np_float32)
I += 1
host_endian_table[I]     = formatdef(format=FLOAT64,    size=8,  alignment=0,  unpack=nu_float64,    pack=np_float64)
I += 1
IF HAVE_FLOAT80:
    host_endian_table[I] = formatdef(format=FLOAT80,    size=10, alignment=0,  unpack=nu_float80,    pack=np_float80)
    I += 1
IF HAVE_INT128:
    host_endian_table[I] = formatdef(format=FLOAT128,   size=16, alignment=0,  unpack=nu_float128,   pack=np_float128)
    I += 1
IF HAVE_COMPLEX64:
    host_endian_table[I] = formatdef(format=COMPLEX64,  size=8,  alignment=0,  unpack=nu_complex64,  pack=np_complex64)
    I += 1
IF HAVE_COMPLEX128:
    host_endian_table[I] = formatdef(format=COMPLEX128, size=16, alignment=0,  unpack=nu_complex128, pack=np_complex128)

I = 0
cdef formatdef big_endian_table [FORMATS]
big_endian_table[I]     = formatdef(format=BOOL,       size=1,  alignment=0,  unpack=nu_bool,       pack=np_bool)
I += 1
big_endian_table[I]     = formatdef(format=INT8,       size=1,  alignment=0,  unpack=nu_int8,       pack=np_int8)
I += 1
big_endian_table[I]     = formatdef(format=INT16,      size=2,  alignment=0,  unpack=bu_int16,      pack=bp_int16)
I += 1
big_endian_table[I]     = formatdef(format=INT32,      size=4,  alignment=0,  unpack=bu_int32,      pack=bp_int32)
I += 1
IF HAVE_INT64:
    big_endian_table[I] = formatdef(format=INT64,      size=8,  alignment=0,  unpack=bu_int64,      pack=bp_int64)
    I += 1
IF HAVE_INT128:
    big_endian_table[I] = formatdef(format=INT128,     size=16, alignment=0,  unpack=bu_int128,     pack=bp_int128)
    I += 1
big_endian_table[I]     = formatdef(format=UINT8,      size=1,  alignment=0,  unpack=nu_uint8,      pack=np_uint8)
I += 1
big_endian_table[I]     = formatdef(format=UINT16,     size=2,  alignment=0,  unpack=bu_uint16,     pack=bp_uint16)
I += 1
big_endian_table[I]     = formatdef(format=UINT32,     size=4,  alignment=0,  unpack=bu_uint32,     pack=bp_uint32)
I += 1
IF HAVE_UINT64:
    big_endian_table[I] = formatdef(format=UINT64,     size=8,  alignment=0,  unpack=bu_uint64,     pack=bp_uint64)
    I += 1
IF HAVE_UINT128:
    big_endian_table[I] = formatdef(format=UINT128,    size=16, alignment=0,  unpack=bu_uint128,    pack=bp_uint128)
    I += 1
big_endian_table[I]     = formatdef(format=FLOAT32,    size=4,  alignment=0,  unpack=bu_float32,    pack=bp_float32)
I += 1
big_endian_table[I]     = formatdef(format=FLOAT64,    size=8,  alignment=0,  unpack=bu_float64,    pack=bp_float64)
I += 1
IF HAVE_FLOAT80:
    big_endian_table[I] = formatdef(format=FLOAT80,    size=10, alignment=0,  unpack=bu_float80,    pack=bp_float80)
    I += 1
IF HAVE_FLOAT128:
    big_endian_table[I] = formatdef(format=FLOAT128,   size=16, alignment=0,  unpack=bu_float128,   pack=bp_float128)
    I += 1
IF HAVE_COMPLEX64:
    big_endian_table[I] = formatdef(format=COMPLEX64,  size=8,  alignment=0,  unpack=bu_complex64,  pack=bp_complex64)
    I += 1
IF HAVE_INT128:
    big_endian_table[I] = formatdef(format=COMPLEX128, size=16, alignment=0,  unpack=bu_complex128, pack=bp_complex128)

I = 0
cdef formatdef little_endian_table [FORMATS]
little_endian_table[I] = formatdef(format=BOOL,       size=1,  alignment=0,  unpack=nu_bool,       pack=np_bool)
I += 1
little_endian_table[I] = formatdef(format=INT8,       size=1,  alignment=0,  unpack=nu_int8,       pack=np_int8)
I += 1
little_endian_table[I] = formatdef(format=INT16,      size=2,  alignment=0,  unpack=lu_int16,      pack=lp_int16)
I += 1
little_endian_table[I] = formatdef(format=INT32,      size=4,  alignment=0,  unpack=lu_int32,      pack=lp_int32)
I += 1
IF HAVE_INT64:
    little_endian_table[I] = formatdef(format=INT64,      size=8,  alignment=0,  unpack=lu_int64,      pack=lp_int64)
    I += 1
IF HAVE_INT128:
    little_endian_table[I] = formatdef(format=INT128,    size=16, alignment=0,  unpack=lu_int128,     pack=lp_int128)
    I += 1
little_endian_table[I] = formatdef(format=UINT8,      size=1,  alignment=0,  unpack=nu_uint8,      pack=np_uint8)
I += 1
little_endian_table[I] = formatdef(format=UINT16,     size=2,  alignment=0,  unpack=lu_uint16,     pack=lp_uint16)
I += 1
little_endian_table[I] = formatdef(format=UINT32,     size=4,  alignment=0,  unpack=lu_uint32,     pack=lp_uint32)
I += 1
IF HAVE_UINT64:
    little_endian_table[I] = formatdef(format=UINT64,     size=8,  alignment=0,  unpack=lu_uint64,     pack=lp_uint64)
    I += 1
IF HAVE_INT128:
    little_endian_table[I] = formatdef(format=UINT128,   size=16, alignment=0,  unpack=lu_uint128,    pack=lp_uint128)
    I += 1
little_endian_table[I] = formatdef(format=FLOAT32,    size=4,  alignment=0,  unpack=lu_float32,    pack=lp_float32)
I += 1
little_endian_table[I] = formatdef(format=FLOAT64,    size=8,  alignment=0,  unpack=lu_float64,    pack=lp_float64)
I += 1
IF HAVE_FLOAT80:
    little_endian_table[I] = formatdef(format=FLOAT80,   size=10, alignment=0,  unpack=lu_float80,    pack=lp_float80)
    I += 1
IF HAVE_INT128:
    little_endian_table[I] = formatdef(format=FLOAT128,  size=16, alignment=0,  unpack=lu_float128,   pack=lp_float128)
    I += 1
IF HAVE_COMPLEX64:
    little_endian_table[I] = formatdef(format=COMPLEX64, size=8,  alignment=0,  unpack=lu_complex64,  pack=lp_complex64)
    I += 1
IF HAVE_COMPLEX128:
    little_endian_table[I] = formatdef(format=COMPLEX128,size=16, alignment=0,  unpack=lu_complex128, pack=lp_complex128)
    I += 1


cdef inline endianess sys_endian() nogil:
    cdef int one = 1
    with nogil:
        if (<bint> (<unsigned char *> &one)[0]):
            return LITTLE_ENDIAN
        else:
            return BIG_ENDIAN

cdef inline int test_byte(char *t, Py_ssize_t *pi, int dflt):
    cdef Py_ssize_t i = pi[0]
    with nogil:
        i += 1
        if t[i] == '1':
            if t[i+1] == '6':
                pi[0] += 2
                return 16
            else:
                pi[0] += 1
                return 1
        elif t[i] == '2':
            pi[0] += 1
            return 2
        elif t[i] == '4':
            pi[0] += 1
            return 4
        elif t[i] == '8':
            pi[0] += 1
            return 8
    return dflt

cdef Py_ssize_t struct_from_formatcode(bytes fmt, formatcode **s_codes,
                                       Py_ssize_t *length, char **buffer_format) except -1:
    cdef Py_ssize_t blen, i, struct_len
    cdef int nb
    cdef endianess struct_endian, sys_end
    cdef num_types list_codes [MAX_STRUCT_LENGTH]
    cdef bytes buffer_fmt = b''
    cdef bint buffer_error = 0

    blen = len(fmt)
    cdef char *fmt_c
    fmt_c = <char *> malloc(sizeof(Py_ssize_t) * (blen + 1))
    if not fmt_c:
        free(fmt_c)
        raise MemoryError()
    fmt_c = fmt
    fmt_c[blen] = 0

    i = 0
    struct_len = 0
    sys_end = sys_endian()

    if fmt_c[i] == '>':
        i += 1
        buffer_fmt = b'>'
        struct_endian = BIG_ENDIAN
    elif fmt_c[i] == '<':
        i += 1
        buffer_fmt = b'<'
        struct_endian = LITTLE_ENDIAN
    else:
        struct_endian = sys_end
        if sys_end == LITTLE_ENDIAN:
            buffer_fmt = b'<'
        else:
            buffer_fmt = b'>'
        if fmt_c[i] == '=' or fmt_c[i] == '|':
            i += 1

    while i < blen:
        if fmt_c[i] == 'i':
            nb = test_byte(fmt_c, &i, 1)
            if nb == 1:
                list_codes[struct_len] = INT8
                buffer_fmt += b'b'
                struct_len += 1
            elif nb == 2:
                list_codes[struct_len] = INT16
                buffer_fmt += b'h'
                struct_len += 1
            elif nb == 4:
                list_codes[struct_len] = INT32
                buffer_fmt += b'i'
                struct_len += 1
            elif nb == 8 and HAVE_INT64:
                list_codes[struct_len] = INT64
                buffer_fmt += b'q'
                struct_len += 1
            else:
                raise AttributeError("NotImplemented byte width type : \'INT%i\'" % (nb * 8))

        elif fmt_c[i] == 'u':
            nb = test_byte(fmt_c, &i, 1)
            if nb == 1:
                list_codes[struct_len] = UINT8
                buffer_fmt += b'B'
                struct_len += 1
            elif nb == 2:
                list_codes[struct_len] = UINT16
                buffer_fmt += b'H'
                struct_len += 1
            elif nb == 4:
                list_codes[struct_len] = UINT32
                buffer_fmt += b'I'
                struct_len += 1
            elif nb == 8 and HAVE_UINT64:
                list_codes[struct_len] = UINT64
                buffer_fmt += b'Q'
                struct_len += 1
            else:
                raise AttributeError("NotImplemented byte width type : \'UINT%i\'" % (nb * 8))

        elif fmt_c[i] == 'f':
            nb = test_byte(fmt_c, &i, 4)
            if nb == 4:
                list_codes[struct_len] = FLOAT32
                buffer_fmt += b'f'
                struct_len += 1
            elif nb == 8:
                list_codes[struct_len] = FLOAT64
                buffer_fmt += b'd'
                struct_len += 1
            else:
                raise AttributeError("NotImplemented byte width type : \'FLOAT%i\'" % (nb * 8))

        elif fmt_c[i] == 'c':
            raise NotImplementedError("Complex type not yet implemented")
            #nb = test_byte(fmt_c, &i, 8)
            #if nb == 8:
            #    list_codes[struct_len] = COMPLEX64
            #    buffer_error = 1
            #    struct_len += 1
            #elif nb == 16:
            #    list_codes[struct_len] = COMPLEX128
            #    buffer_error = 1
            #    struct_len += 1
            #else:
            #    raise AttributeError("NotImplemented byte width type : \'COMPLEX%i\'" % (nb * 8))

        elif fmt_c[i] == 'b':
            nb = test_byte(fmt_c, &i, 1)
            if nb == 1:
                list_codes[struct_len] = BOOL
                buffer_fmt += b'?'
                struct_len += 1
            else:
                raise AttributeError("bool type is always 1 byte length")

        elif fmt_c[i] == 'D':
            #snb = test_byte(fmt, &i)
            raise NotImplementedError("Decimal type not yet implemented")
            #buffer_error = 1
            #struct_len += 1

        else:
            raise ValueError("Malformed string code, \'%c\' not a valid type code" % fmt[i])

        if struct_len > MAX_STRUCT_LENGTH:
            raise MemoryError("Format string code should have a maximum of %i elements" % MAX_STRUCT_LENGTH)
        i += 1

    s_codes[0] = <formatcode *> malloc(sizeof(formatcode) * struct_len)
    if not s_codes:
        free(s_codes)
        raise MemoryError("unable to allocate memory for structure enconding")

    cdef formatdef *f_ptr = NULL
    cdef formatdef *table
    cdef Py_ssize_t sz = 0
    if struct_endian == sys_end:
        table = host_endian_table
    elif struct_endian == LITTLE_ENDIAN:
        table = little_endian_table
    else:
        table = big_endian_table
    for i in xrange(struct_len):
        f_ptr = formatdef_from_code(list_codes[i], table)
        if not f_ptr:
            raise RuntimeError("Unrecoverable error in struct compilation")
        s_codes[0][i] = formatcode(fmtdef = f_ptr , offset = sz, size = f_ptr.size)
        sz += f_ptr.size

    length[0] = struct_len

    cdef Py_ssize_t buf_len
    if buffer_error:
        buffer_format[0] = NULL
    else:
        buf_len = struct_len * 2
        buffer_format[0] = <char *> malloc(buf_len + 1)
        if not buffer_format[0]:
            free(buffer_format[0])
            raise MemoryError("unable to allocate memory for buffer format code")
        memcpy(buffer_format[0], <char *> buffer_fmt, buf_len)
        buffer_format[0][buf_len] = 0
    return sz

cdef inline formatdef* formatdef_from_code(num_types nt, formatdef *table):
    cdef int i = 0
    while i < FORMATS:
        if table[i].format == nt:
            return &table[i]
        i += 1
    return NULL

#TODO: make a chache of structs with refcount
#      and compile only once struct for a same format
#      this will be optimize time creation of multiple mdarray
#      of same type.
cdef int new_struct(_struct *self, bytes fmt) except*:
    cdef Py_ssize_t sz = 0
    cdef Py_ssize_t length = 0

    sz = struct_from_formatcode(fmt, &self.codes, &length, &self.buffer_format)
    self.size = sz
    self.length = length
    self.formats = <num_types *> malloc(sizeof(num_types) * length)
    if not self.formats:
        free(self.formats)
        raise MemoryError("Allocation failed in struct compilation")
    for sz in range(length):
        self.formats[sz] = self.codes[sz].fmtdef.format
    return 0

cdef void del_struct(_struct *_self):
    if _self.codes != NULL:
        free(_self.codes)
        free(_self.formats)

cdef int struct_unpack(_struct *_self, char *c, cnumber **cnums)except -1:
    cdef Py_ssize_t i = 0
    cdef char* ptr_c
    for i in xrange(_self.length):
        ptr_c = c + _self.codes[i].offset
        _self.codes[i].fmtdef.unpack(ptr_c, &cnums[0][i])
    return 0

cdef int struct_pack(_struct *_self, char *c, cnumber **cnums):
    cdef Py_ssize_t i
    cdef char* ptr_c
    for i in xrange(_self.length):
        ptr_c = c + _self.codes[i].offset
        _self.codes[i].fmtdef.pack(ptr_c, &cnums[0][i])




