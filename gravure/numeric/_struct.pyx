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


cdef extern from *:
    ctypedef struct PyObject
    void Py_INCREF(PyObject *)
    void Py_DECREF(PyObject *)

cdef extern from "stdlib.h":
    void *malloc(size_t) nogil
    void free(void *) nogil
    void *memcpy(void *dest, void *src, size_t n) nogil

cdef extern from "Python.h":
    bint PyLong_Check(object p)
    # Return true if its argument is a PyLongObject or a subtype of PyLongObject.

    bint PyIndex_Check(object o)
    # Returns True if o is an index integer (has the nb_index slot of
    # the tp_as_number structure filled in).

    object PyNumber_Index(object o)
    # Returns the o converted to a Python int or long on success or
    # NULL with a TypeError exception raised on failure.

    double PyFloat_AsDouble(object pyfloat) except? -1
    # Return a C double representation of the contents of pyfloat.

    int _PyFloat_Pack4(double x, unsigned char *p, int le) except -1
    int _PyFloat_Pack8(double x, unsigned char *p, int le) except -1
    double _PyFloat_Unpack4(unsigned char *p, int le) except? -1.0
    double _PyFloat_Unpack8(unsigned char *p, int le) except? -1.0

    bint PyObject_IsTrue(object o) except -1
    # Returns 1 if the object o is considered to be true, and 0
    # otherwise. This is equivalent to the Python expression "not not
    # o". On failure, return -1.

    tuple PyTuple_New(Py_ssize_t len)
    # Return value: New reference.
    # Return a new tuple object of size len, or NULL on failure.

    void PyTuple_SET_ITEM(object  p, Py_ssize_t pos, object  o)
    # Like PyTuple_SetItem(), but does no error checking, and should
    # only be used to fill in brand new tuples. Note: This function
    # ``steals'' a reference to o.


DEF MAX_STRUCT_LENGTH = 50
DEF FORMATS = 11

cdef object get_pylong(object v):
    if v is None:
        raise TypeError("required argument should not be None")
    if not PyLong_Check(v):
        # Not an integer;
        # try to use __index__ to convert.
        if PyIndex_Check(v):
            v = PyNumber_Index(v)
            if not v:
                raise TypeError("required argument is not an integer")
        else:
            raise TypeError("required argument is not an integer")
    #else:
    #    Py_INCREF(v);
    assert(PyLong_Check(v))
    return v


#
# host endian routines.
#
cdef nu_bool(char *p):
    return <bint> p[0]

cdef nu_int8(char *p):
    return <int8> p[0]

cdef nu_uint8(char *p):
    return <uint8> p[0]

cdef nu_int16(char *p):
    cdef int16 iv
    memcpy(<char *> &iv, p, 2)
    return iv

cdef nu_uint16(char *p):
    cdef uint16 iv
    memcpy(<char *> &iv, p, 2)
    return iv

cdef nu_int32(char *p):
    cdef int32 iv
    memcpy(<char *> &iv, p, 4)
    return iv

cdef nu_uint32(char *p):
    cdef uint32 iv
    memcpy(<char *> &iv, p, 4)
    return iv

cdef nu_int64(char *p):
    cdef int64 iv
    memcpy(<char *> &iv, p, 8)
    return iv

cdef nu_uint64(char *p):
    cdef uint64 iv
    memcpy(<char *> &iv, p, 8)
    return iv

cdef nu_float32(char *p):
    cdef float32 iv
    memcpy(<char *> &iv, p, 4)
    return iv

cdef nu_float64(char *p):
    cdef float64 iv
    memcpy(<char *> &iv, p, 8)
    return iv

#FIXME:
#cdef nu_float128(char *p, formatdef *f):
#    cdef float128 iv
#    memcpy(<char *> &iv, p, sizeof(float128))
#    return iv

cdef np_bool(char *p, object v):
    cdef _bool y
    cdef bint bv
    bv = PyObject_IsTrue(v)
    y = bv
    memcpy(p, <char *> &y, 1)

cdef np_int8(char *p, object v):
    cdef int8 iv
    cdef object py_l = get_pylong(v)
    if py_l < MIN_INT8 or v > MAX_INT8:
        raise OverflowError("int8 format requires %i <= number <= %i" % (MIN_INT8, MAX_INT8))
    iv = py_l  # conversion from PyObject to c type by cython
    p[0] = <char> iv

cdef np_uint8(char *p, object v):
    cdef uint8 iv
    cdef object py_l = get_pylong(v)
    if py_l < 0 or v > MAX_UINT8:
        raise OverflowError("uint8 format requires 0 <= number <= %i" % MAX_UINT8)
    iv = py_l  # conversion from PyObject to c type by cython
    p[0] = <char> iv

cdef np_int16(char *p, object v):
    cdef int16 iv
    cdef object py_l = get_pylong(v)
    if py_l < MIN_INT16 or v > MAX_INT16:
        raise OverflowError("int16 format requires %i <= number <= %i" % (MIN_INT16, MAX_INT16))
    iv = py_l
    memcpy(p, <char *> &iv, 2)

cdef np_uint16(char *p, object v):
    cdef uint16 iv
    cdef object py_l = get_pylong(v)
    if py_l < 0 or v > MAX_UINT16:
        raise OverflowError("uint16 format requires 0 <= number <= %i" % MAX_UINT16)
    iv = py_l
    memcpy(p, <char *> &iv, 2)

cdef np_int32(char *p, object v):
    cdef int32 iv
    cdef object py_l = get_pylong(v)
    if py_l < MIN_INT32 or v > MAX_INT32:
        raise OverflowError("int32 format requires %i <= number <= %i" % (MIN_INT32, MAX_INT32))
    iv = py_l
    memcpy(p, <char *> &iv, 4)

cdef np_uint32(char *p, object v):
    cdef uint32 iv
    cdef object py_l = get_pylong(v)
    if py_l < 0 or v > MAX_UINT32:
        raise OverflowError("uint32 format requires 0 <= number <= %i" % MAX_UINT32)
    iv = py_l
    memcpy(p, <char *> &iv, 4)

cdef np_int64(char *p, object v):
    cdef int64 iv
    cdef object py_l = get_pylong(v)
    if py_l < MIN_INT64 or v > MAX_INT64:
        raise OverflowError("int64 format requires %i <= number <= %i" % (MIN_INT64, MAX_INT64))
    iv = py_l
    memcpy(p, <char *> &iv, 8)

cdef np_uint64(char *p, object v):
    cdef uint64 iv
    cdef object py_l = get_pylong(v)
    if py_l < 0 or v > MAX_UINT64:
        raise OverflowError("uint64 format requires 0 <= number <= %i" % MAX_UINT64)
    iv = py_l
    memcpy(p, <char *> &iv, 8)

cdef np_float32(char *p, object v):
    cdef float32 fv
    fv = PyFloat_AsDouble(v)
    memcpy(p, <char *> &fv, 4)

cdef np_float64(char *p, object v):
    cdef float64 fv
    fv = PyFloat_AsDouble(v)
    memcpy(p, <char *> &fv, 8)

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
cdef lu_int16(char *p):
    cdef int16 iv = 0
    cdef Py_ssize_t i = 2
    cdef unsigned char *b = <unsigned char *> p
    while i > 0:
        i -= 1
        iv = (iv << 8) | b[i]
    # Extend the sign bit
    #iv |= -(iv & (1 << ((8 * sizeof(int16)) - 1)))
    return iv

cdef lu_uint16(char *p):
    cdef uint16 iv = 0
    cdef Py_ssize_t i = 2
    cdef unsigned char *b = <unsigned char *> p
    while i > 0:
        i -= 1
        iv = (iv << 8) | b[i]
    return iv

cdef lu_int32(char *p):
    cdef int32 iv = 0
    cdef Py_ssize_t i = 4
    cdef unsigned char *b = <unsigned char *> p
    while i > 0:
        i -= 1
        iv = (iv << 8) | b[i]
    # Extend the sign bit
    #iv |= -(iv & (1 << ((8 * sizeof(int16)) - 1)))
    return iv

cdef lu_uint32(char *p):
    cdef uint32 iv = 0
    cdef Py_ssize_t i = 4
    cdef unsigned char *b = <unsigned char *> p
    while i > 0:
        i -= 1
        iv = (iv << 8) | b[i]
    return iv

cdef lu_int64(char *p):
    cdef int64 iv = 0
    cdef Py_ssize_t i = 8
    cdef unsigned char *b = <unsigned char *> p
    while i > 0:
        i -= 1
        iv = (iv << 8) | b[i]
    # Extend the sign bit
    #iv |= -(iv & (1 << ((8 * sizeof(int16)) - 1)))
    return iv

cdef lu_uint64(char *p):
    cdef uint64 iv = 0
    cdef Py_ssize_t i = 8
    cdef unsigned char *b = <unsigned char *> p
    while i > 0:
        i -= 1
        iv = (iv << 8) | b[i]
    return iv

cdef lu_float32(char *p):
    cdef float32 fv
    fv = _PyFloat_Unpack4(<unsigned char *> p, 1)
    return fv

cdef lu_float64(char *p):
    cdef float64 fv
    fv = _PyFloat_Unpack8(<unsigned char *> p, 1)
    return fv

#FIXME:
#cdef lu_float128(char *p, formatdef *f):

cdef lp_int16(char *p, object v):
    cdef int16 iv
    cdef Py_ssize_t i = 2
    cdef object py_l = get_pylong(v)
    if py_l < MIN_INT16 or v > MAX_INT16:
        raise OverflowError("int16 format requires %i <= number <= %i" % (MIN_INT16, MAX_INT16))
    iv = py_l
    while i > 0:
        p[0] = <char> iv
        p += 1
        iv >>= 8
        i -= 1

cdef lp_uint16(char *p, object v):
    cdef uint16 iv
    cdef Py_ssize_t i = 2
    cdef object py_l = get_pylong(v)
    if py_l < 0 or v > MAX_UINT16:
        raise OverflowError("uint16 format requires 0 <= number <= %i" % MAX_UINT16)
    iv = py_l
    while i > 0:
        p[0] = <char> iv
        p += 1
        iv >>= 8
        i -= 1

cdef lp_int32(char *p, object v):
    cdef int32 iv
    cdef Py_ssize_t i = 4
    cdef object py_l = get_pylong(v)
    if py_l < MIN_INT32 or v > MAX_INT32:
        raise OverflowError("int32 format requires %i <= number <= %i" % (MIN_INT32, MAX_INT32))
    iv = py_l
    while i > 0:
        p[0] = <char> iv
        p += 1
        iv >>= 8
        i -= 1

cdef lp_uint32(char *p, object v):
    cdef uint32 iv
    cdef Py_ssize_t i = 4
    cdef object py_l = get_pylong(v)
    if py_l < 0 or v > MAX_UINT32:
        raise OverflowError("uint32 format requires 0 <= number <= %i" % MAX_UINT32)
    iv = py_l
    while i > 0:
        p[0] = <char> iv
        p += 1
        iv >>= 8
        i -= 1

cdef lp_int64(char *p, object v):
    cdef int64 iv
    cdef Py_ssize_t i = 8
    cdef object py_l = get_pylong(v)
    if py_l < MIN_INT64 or v > MAX_INT64:
        raise OverflowError("int64 format requires %i <= number <= %i" % (MIN_INT64, MAX_INT64))
    iv = py_l
    while i > 0:
        p[0] = <char> iv
        p += 1
        iv >>= 8
        i -= 1

cdef lp_uint64(char *p, object v):
    cdef uint64 iv
    cdef Py_ssize_t i = 8
    cdef object py_l = get_pylong(v)
    if py_l < 0 or v > MAX_UINT64:
        raise OverflowError("uint64 format requires 0 <= number <= %i" % MAX_UINT64)
    iv = py_l
    while i > 0:
        p[0] = <char> iv
        p += 1
        iv >>= 8
        i -= 1

cdef lp_float32(char *p, object v):
    cdef float32 fv
    fv = PyFloat_AsDouble(v)
    _PyFloat_Pack4(fv, <unsigned char *> p, 1)

cdef lp_float64(char *p, object v):
    cdef float64 fv
    fv = PyFloat_AsDouble(v)
    _PyFloat_Pack8(fv, <unsigned char *> p, 1)

#FIXME:
#cdef lp_float128(char *p, object v, formatdef *f):
#    cdef float128 fv
#    fv = PyFloat_AsDouble(v)
#    #_PyFloat_Pack8(fv, <unsigned char *> p, 1)

#
# Big-endian routines.
#
cdef bu_int16(char *p):
    cdef int16 iv = 0
    cdef Py_ssize_t i = 2
    cdef unsigned char *b = <unsigned char *> p
    while i > 0:
        i -= 1
        iv = (iv << 8) | b[0]
        b += 1
    # Extend the sign bit
    #iv |= -(iv & (1 << ((8 * sizeof(int16)) - 1)))
    return iv

cdef bu_uint16(char *p):
    cdef uint16 iv = 0
    cdef Py_ssize_t i = 2
    cdef unsigned char *b = <unsigned char *> p
    while i > 0:
        i -= 1
        iv = (iv << 8) | b[0]
        b += 1
    return iv

cdef bu_int32(char *p):
    cdef int32 iv = 0
    cdef Py_ssize_t i = 4
    cdef unsigned char *b = <unsigned char *> p
    while i > 0:
        i -= 1
        iv = (iv << 8) | b[0]
        b += 1
    # Extend the sign bit
    #iv |= -(iv & (1 << ((8 * sizeof(int16)) - 1)))
    return iv

cdef bu_uint32(char *p):
    cdef uint32 iv = 0
    cdef Py_ssize_t i = 4
    cdef unsigned char *b = <unsigned char *> p
    while i > 0:
        i -= 1
        iv = (iv << 8) | b[0]
        b += 1
    return iv

cdef bu_int64(char *p):
    cdef int64 iv = 0
    cdef Py_ssize_t i = 8
    cdef unsigned char *b = <unsigned char *> p
    while i > 0:
        i -= 1
        iv = (iv << 8) | b[0]
        b += 1
    # Extend the sign bit
    #iv |= -(iv & (1 << ((8 * sizeof(int16)) - 1)))
    return iv

cdef bu_uint64(char *p):
    cdef uint64 iv = 0
    cdef Py_ssize_t i = 8
    cdef unsigned char *b = <unsigned char *> p
    while i > 0:
        i -= 1
        iv = (iv << 8) | b[0]
        b += 1
    return iv

cdef bu_float32(char *p):
    cdef float32 fv
    fv = _PyFloat_Unpack4(<unsigned char *> p, 0)
    return fv

cdef bu_float64(char *p):
    cdef float64 fv
    fv = _PyFloat_Unpack8(<unsigned char *> p, 0)
    return fv

#FIXME:
#cdef bu_float128(char *p, formatdef *f):

cdef bp_int16(char *p, object v):
    cdef int16 iv
    cdef Py_ssize_t i = 2
    cdef object py_l = get_pylong(v)
    if py_l < MIN_INT16 or v > MAX_INT16:
        raise OverflowError("int16 format requires %i <= number <= %i" % (MIN_INT16, MAX_INT16))
    iv = py_l
    while i > 0:
        i -= 1
        p[i] = <char> iv
        iv >>= 8

cdef bp_uint16(char *p, object v):
    cdef uint16 iv
    cdef Py_ssize_t i = 2
    cdef object py_l = get_pylong(v)
    if py_l < 0 or v > MAX_UINT16:
        raise OverflowError("uint16 format requires 0 <= number <= %i" % MAX_UINT16)
    iv = py_l
    while i > 0:
        i -= 1
        p[i] = <char> iv
        iv >>= 8

cdef bp_int32(char *p, object v):
    cdef int32 iv
    cdef Py_ssize_t i = 4
    cdef object py_l = get_pylong(v)
    if py_l < MIN_INT32 or v > MAX_INT32:
        raise OverflowError("int32 format requires %i <= number <= %i" % (MIN_INT32, MAX_INT32))
    iv = py_l
    while i > 0:
        i -= 1
        p[i] = <char> iv
        iv >>= 8

cdef bp_uint32(char *p, object v):
    cdef uint32 iv
    cdef Py_ssize_t i = 4
    cdef object py_l = get_pylong(v)
    if py_l < 0 or v > MAX_UINT32:
        raise OverflowError("uint32 format requires 0 <= number <= %i" % MAX_UINT32)
    iv = py_l
    while i > 0:
        i -= 1
        p[i] = <char> iv
        iv >>= 8

cdef bp_int64(char *p, object v):
    cdef int64 iv
    cdef Py_ssize_t i = 8
    cdef object py_l = get_pylong(v)
    if py_l < MIN_INT64 or v > MAX_INT64:
        raise OverflowError("int64 format requires %i <= number <= %i" % (MIN_INT64, MAX_INT64))
    iv = py_l
    while i > 0:
        i -= 1
        p[i] = <char> iv
        iv >>= 8

cdef bp_uint64(char *p, object v):
    cdef uint64 iv
    cdef Py_ssize_t i = 8
    cdef object py_l = get_pylong(v)
    if py_l < 0 or v > MAX_UINT64:
        raise OverflowError("uint64 format requires 0 <= number <= %i" % MAX_UINT64)
    iv = py_l
    while i > 0:
        i -= 1
        p[i] = <char> iv
        iv >>= 8

cdef bp_float32(char *p, object v):
    cdef float32 fv
    fv = PyFloat_AsDouble(v)
    _PyFloat_Pack4(fv, <unsigned char *> p, 0)

cdef bp_float64(char *p, object v):
    cdef float64 fv
    fv = PyFloat_AsDouble(v)
    _PyFloat_Pack8(fv, <unsigned char *> p, 0)

#FIXME:
#cdef bp_float128(char *p, object v, formatdef *f):
#    cdef float128 fv
#    fv = PyFloat_AsDouble(v)
#    #_PyFloat_Pack8(fv, <unsigned char *> p, b)




cdef formatdef host_endian_table [FORMATS]
host_endian_table[:]  = [
    formatdef(format=BOOL,       size=1,  alignment=0,  unpack=nu_bool,       pack=np_bool),
    formatdef(format=INT8,       size=1,  alignment=0,  unpack=nu_int8,       pack=np_int8),
    formatdef(format=INT16,      size=2,  alignment=0,  unpack=nu_int16,      pack=np_int16),
    formatdef(format=INT32,      size=4,  alignment=0,  unpack=nu_int32,      pack=np_int32),
    formatdef(format=INT64,      size=8,  alignment=0,  unpack=nu_int64,      pack=np_int64),
    #formatdef(format=INT128,    size=16, alignment=0,  unpack=nu_int128,     pack=np_int128),
    formatdef(format=UINT8,      size=1,  alignment=0,  unpack=nu_uint8,      pack=np_uint8),
    formatdef(format=UINT16,     size=2,  alignment=0,  unpack=nu_uint16,     pack=np_uint16),
    formatdef(format=UINT32,     size=4,  alignment=0,  unpack=nu_uint32,     pack=np_uint32),
    formatdef(format=UINT64,     size=8,  alignment=0,  unpack=nu_uint64,     pack=np_uint64),
    #formatdef(format=UINT128,   size=16, alignment=0,  unpack=nu_uint128,    pack=np_uint128),
    formatdef(format=FLOAT32,    size=4,  alignment=0,  unpack=nu_float32,    pack=np_float32),
    formatdef(format=FLOAT64,    size=8,  alignment=0,  unpack=nu_float64,    pack=np_float64),
    #formatdef(format=FLOAT80,   size=10, alignment=0,  unpack=nu_float80,    pack=np_float80),
    #FIXME: float128
    #formatdef(format=FLOAT128,  size=16, alignment=0,  unpack=nu_float128,   pack=np_float128),
    #formatdef(format=COMPLEX64, size=8,  alignment=0,  unpack=nu_complex64,  pack=np_complex64),
    #formatdef(format=COMPLEX128,size=16, alignment=0,  unpack=nu_complex128, pack=np_complex128)
    ]

cdef formatdef big_endian_table [FORMATS]
big_endian_table[:]  = [
    formatdef(format=BOOL,       size=1,  alignment=0,  unpack=nu_bool,       pack=np_bool),
    formatdef(format=INT8,       size=1,  alignment=0,  unpack=nu_int8,       pack=np_int8),
    formatdef(format=INT16,      size=2,  alignment=0,  unpack=bu_int16,      pack=bp_int16),
    formatdef(format=INT32,      size=4,  alignment=0,  unpack=bu_int32,      pack=bp_int32),
    formatdef(format=INT64,      size=8,  alignment=0,  unpack=bu_int64,      pack=bp_int64),
    #formatdef(format=INT128,    size=16, alignment=0,  unpack=bu_int128,     pack=bp_int128),
    formatdef(format=UINT8,      size=1,  alignment=0,  unpack=nu_uint8,      pack=np_uint8),
    formatdef(format=UINT16,     size=2,  alignment=0,  unpack=bu_uint16,     pack=bp_uint16),
    formatdef(format=UINT32,     size=4,  alignment=0,  unpack=bu_uint32,     pack=bp_uint32),
    formatdef(format=UINT64,     size=8,  alignment=0,  unpack=bu_uint64,     pack=bp_uint64),
    #formatdef(format=UINT128,   size=16, alignment=0,  unpack=bu_uint128,    pack=bp_uint128),
    formatdef(format=FLOAT32,    size=4,  alignment=0,  unpack=bu_float32,    pack=bp_float32),
    formatdef(format=FLOAT64,    size=8,  alignment=0,  unpack=bu_float64,    pack=bp_float64),
    #formatdef(format=FLOAT80,   size=10, alignment=0,  unpack=bu_float80,    pack=bp_float80),
    #FIXME: float128
    #formatdef(format=FLOAT128,  size=16, alignment=0,  unpack=bu_float128,   pack=bp_float128),
    #formatdef(format=COMPLEX64, size=8,  alignment=0,  unpack=bu_complex64,  pack=bp_complex64),
    #formatdef(format=COMPLEX128,size=16, alignment=0,  unpack=bu_complex128, pack=bp_complex128)
    ]

cdef formatdef little_endian_table [FORMATS]
little_endian_table[:]  = [
    formatdef(format=BOOL,       size=1,  alignment=0,  unpack=nu_bool,       pack=np_bool),
    formatdef(format=INT8,       size=1,  alignment=0,  unpack=nu_int8,       pack=np_int8),
    formatdef(format=INT16,      size=2,  alignment=0,  unpack=lu_int16,      pack=lp_int16),
    formatdef(format=INT32,      size=4,  alignment=0,  unpack=lu_int32,      pack=lp_int32),
    formatdef(format=INT64,      size=8,  alignment=0,  unpack=lu_int64,      pack=lp_int64),
    #formatdef(format=INT128,    size=16, alignment=0,  unpack=lu_int128,     pack=lp_int128),
    formatdef(format=UINT8,      size=1,  alignment=0,  unpack=nu_uint8,      pack=np_uint8),
    formatdef(format=UINT16,     size=2,  alignment=0,  unpack=lu_uint16,     pack=lp_uint16),
    formatdef(format=UINT32,     size=4,  alignment=0,  unpack=lu_uint32,     pack=lp_uint32),
    formatdef(format=UINT64,     size=8,  alignment=0,  unpack=lu_uint64,     pack=lp_uint64),
    #formatdef(format=UINT128,   size=16, alignment=0,  unpack=lu_uint128,    pack=lp_uint128),
    formatdef(format=FLOAT32,    size=4,  alignment=0,  unpack=lu_float32,    pack=lp_float32),
    formatdef(format=FLOAT64,    size=8,  alignment=0,  unpack=lu_float64,    pack=lp_float64)
    #formatdef(format=FLOAT80,   size=10, alignment=0,  unpack=lu_float80,    pack=lp_float80),
    #FIXME: float128
    #formatdef(format=FLOAT128,  size=16, alignment=0,  unpack=lu_float128,   pack=lp_float128),
    #formatdef(format=COMPLEX64, size=8,  alignment=0,  unpack=lu_complex64,  pack=lp_complex64),
    #formatdef(format=COMPLEX128,size=16, alignment=0,  unpack=lu_complex128, pack=lp_complex128)
    ]

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

cdef Py_ssize_t struct_from_formatcode(bytes fmt, formatcode **s_codes, Py_ssize_t *length) except -1:
    cdef Py_ssize_t blen, i, struct_len
    cdef int nb
    cdef endianess local_end, sys_end
    cdef num_types list_codes [MAX_STRUCT_LENGTH]
    cdef endianess list_endian [MAX_STRUCT_LENGTH]

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
    local_end = sys_end

    while i < blen:
        if fmt_c[i] == '>':
            i += 1
            local_endian = BIG_ENDIAN
        elif fmt_c[i] == '<':
            i += 1
            local_endian = LITTLE_ENDIAN
        elif fmt_c[i] == '=' or fmt_c[i] == '|':
            i += 1
            local_endian = sys_end

        if fmt_c[i] == 'i':
            nb = test_byte(fmt_c, &i, 1)
            if nb == 1:
                list_endian[struct_len] = local_end
                list_codes[struct_len] = INT8
                struct_len += 1
            elif nb == 2:
                list_endian[struct_len] = local_end
                list_codes[struct_len] = INT16
                struct_len += 1
            elif nb == 4:
                list_endian[struct_len] = local_end
                list_codes[struct_len] = INT32
                struct_len += 1
            elif nb == 8:
                list_endian[struct_len] = local_end
                list_codes[struct_len] = INT64
                struct_len += 1
            else:
                raise AttributeError("NotImplemented byte width type : \'INT%i\'" % (nb * 8))

        elif fmt_c[i] == 'u':
            nb = test_byte(fmt_c, &i, 1)
            if nb == 1:
                list_endian[struct_len] = local_end
                list_codes[struct_len] = UINT8
                struct_len += 1
            elif nb == 2:
                list_endian[struct_len] = local_end
                list_codes[struct_len] = UINT16
                struct_len += 1
            elif nb == 4:
                list_endian[struct_len] = local_end
                list_codes[struct_len] = UINT32
                struct_len += 1
            elif nb == 8:
                list_endian[struct_len] = local_end
                list_codes[struct_len] = UINT64
                struct_len += 1
            else:
                raise AttributeError("NotImplemented byte width type : \'UINT%i\'" % (nb * 8))

        elif fmt_c[i] == 'f':
            nb = test_byte(fmt_c, &i, 4)
            if nb == 4:
                list_endian[struct_len] = local_end
                list_codes[struct_len] = FLOAT32
                struct_len += 1
            elif nb == 8:
                list_endian[struct_len] = local_end
                list_codes[struct_len] = FLOAT64
                struct_len += 1
            else:
                raise AttributeError("NotImplemented byte width type : \'FLOAT%i\'" % (nb * 8))

        elif fmt_c[i] == 'c':
            raise NotImplementedError("Complex type not yet implemented")
            #nb = test_byte(fmt_c, &i, 8)
            #if nb == 8:
            #    list_endian[struct_len] = local_end
            #    list_codes[struct_len] = COMPLEX64
            #    struct_len += 1
            #elif nb == 16:
            #    list_endian[struct_len] = local_end
            #    list_codes[struct_len] = COMPLEX128
            #    struct_len += 1
            #else:
            #    raise AttributeError("NotImplemented byte width type : \'COMPLEX%i\'" % (nb * 8))

        elif fmt_c[i] == 'b':
            nb = test_byte(fmt_c, &i, 1)
            if nb == 1:
                list_endian[struct_len] = local_end
                list_codes[struct_len] = BOOL
                struct_len += 1
            else:
                raise AttributeError("bool type is always 1 byte length")

        elif fmt_c[i] == 'D':
            #snb = test_byte(fmt, &i)
            raise NotImplementedError("Decimal type not yet implemented")
            #struct_len += 1

        else:
            raise AttributeError("Malformed string code, \'%c\' not a valid type code" % fmt[i])

        if struct_len > MAX_STRUCT_LENGTH:
            raise MemoryError("Format string code should have a maximum of %i elements" % MAX_STRUCT_LENGTH)
        i += 1

    s_codes[0] = <formatcode *> malloc(sizeof(formatcode) * struct_len)
    if not s_codes:
        free(s_codes)
        raise MemoryError("unable to allocate memory for structure enconding")

    cdef formatdef *f_ptr = NULL
    cdef Py_ssize_t sz = 0
    for i in xrange(struct_len):
        if list_endian[i] == sys_end:
            f_ptr = formatdef_from_code(list_codes[i], host_endian_table)
        elif list_endian[i] == LITTLE_ENDIAN:
            f_ptr = formatdef_from_code(list_codes[i], little_endian_table)
        elif list_endian[i] == BIG_ENDIAN:
            f_ptr = formatdef_from_code(list_codes[i], big_endian_table)
        if not f_ptr:
            raise RuntimeError("Unrecoverable error in struct compilation")
        s_codes[0][i] = formatcode(fmtdef = f_ptr , offset = sz, size = f_ptr.size)
        sz += f_ptr.size

    length[0] = struct_len
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

    sz = struct_from_formatcode(fmt, &self.codes, &length)
    self.size = sz
    self.length = length
    self.unpack = struct_unpack_data
    self.pack = struct_pack_data
    return 0

cdef void del_struct(_struct *self):
    if self.codes != NULL:
        free(self.codes)

cdef object struct_unpack_data(_struct *self, char *c):
    cdef object v, tmp
    cdef Py_ssize_t i = 0
    cdef char* ptr_c
    v = PyTuple_New(self.length)
    for i in xrange(self.length):
        ptr_c = c + self.codes[i].offset
        tmp = self.codes[i].fmtdef.unpack(ptr_c)
        PyTuple_SET_ITEM(v, i, tmp)
    return v

cdef int struct_pack_data(_struct *self, char *c, object args) except -1:
    if not isinstance(args, tuple):
        raise TypeError("Element(s) to pack should be pass in tuple")
    if len(args) != self.length:
        raise TypeError("Wrong number of arguments to pack : \
        %i in place of %i" % len(args), self.length)
    cdef object v
    cdef Py_ssize_t i = 0
    cdef char* ptr_c
    for v in args:
        ptr_c = c + self.codes[i].offset
        self.codes[i].fmtdef.pack(ptr_c, v)
        i += 1
