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

#TODO: release python buffer where acquired

import cython
cimport cython

from enum import IntEnum as _IntEnum

from _struct cimport *
from bit_width_type cimport *
cimport bit_width_type as _b
from type_promotion cimport *

# SIZED TYPE DEFINITION
include "TYPE_DEF.pxi"

cdef extern from "Python.h":
    object PyLong_FromVoidPtr(void *)

    bint PyNumber_Check(object o)
    # Returns 1 if the object o provides numeric protocols, and false
    # otherwise. This function always succeeds.

    bint PyLong_Check(object p)
    # Return true if its argument is a PyLongObject or a subtype of PyLongObject.

    unsigned long PyLong_AsUnsignedLongMask(object io) except? -1
    # Return a C unsigned long from a Python long integer, without
    # checking for overflow.

    bint PyIndex_Check(object o)
    # Returns True if o is an index integer (has the nb_index slot of
    # the tp_as_number structure filled in).

    object PyNumber_Index(object o)
    # Returns the o converted to a Python int or long on success or
    # NULL with a TypeError exception raised on failure.

    double PyFloat_AsDouble(object pyfloat) except? -1
    # Return a C double representation of the contents of pyfloat.

    bint PyObject_IsTrue(object o) except -1
    # Returns 1 if the object o is considered to be true, and 0
    # otherwise. This is equivalent to the Python expression "not not
    # o". On failure, return -1.

    bint PyObject_CheckBuffer(object obj)
    # Return 1 if obj supports the buffer interface otherwise 0.

    int PyObject_GetBuffer(object obj, Py_buffer *view, int flags) except -1

    bint PyBuffer_IsContiguous(Py_buffer *view, char fort)
    # Return 1 if the memory defined by the view is C-style (fortran
    # is 'C') or Fortran-style (fortran is 'F') contiguous or either
    # one (fortran is 'A'). Return 0 otherwise.

    void PyBuffer_Release(Py_buffer *view)
    # Release the buffer view. This should be called when the buffer
    # is no longer being used as it may free memory from it.

cdef extern from "pyport.h":
    ctypedef Py_ssize_t Py_intptr_t

cdef extern from "pythread.h":
    ctypedef void *PyThread_type_lock
    PyThread_type_lock PyThread_allocate_lock()
    void PyThread_free_lock(PyThread_type_lock)
    int PyThread_acquire_lock(PyThread_type_lock, int mode) nogil
    void PyThread_release_lock(PyThread_type_lock) nogil

cdef extern from *:
    int __Pyx_GetBuffer(object, Py_buffer *, int) except -1
    void __Pyx_ReleaseBuffer(Py_buffer *)

    ctypedef struct PyObject
    void Py_INCREF(PyObject *)
    void Py_DECREF(PyObject *)

    ctypedef struct __pyx_buffer "Py_buffer":
        PyObject *obj

    PyObject *Py_None

    cdef enum:
        PyBUF_SIMPLE
        PyBUF_ND
        PyBUF_C_CONTIGUOUS,
        PyBUF_F_CONTIGUOUS,
        PyBUF_ANY_CONTIGUOUS
        PyBUF_FORMAT
        PyBUF_WRITABLE
        PyBUF_STRIDES
        PyBUF_INDIRECT
        PyBUF_RECORDS
        PyBUF_RECORDS_RO
        PyBUF_STRIDED
        PyBUF_STRIDED_RO
        PyBUF_FULL
        PyBUF_FULL_RO
        PyBUF_CONTIG
        PyBUF_CONTIG_RO

    cdef object capsule "__pyx_capsule_create" (void *p, char *sig)
    cdef int __pyx_array_getbuffer(PyObject *obj, Py_buffer view, int flags)
    cdef int __pyx_memoryview_getbuffer(PyObject *obj, Py_buffer view, int flags)

    tuple PyTuple_New(Py_ssize_t len)
    # Return value: New reference.
    # Return a new tuple object of size len, or NULL on failure.

    void PyTuple_SetItem(object  p, Py_ssize_t pos, object  o)
    # Like PyTuple_SetItem(), but does no error checking, and should
    # only be used to fill in brand new tuples. Note: This function
    # ``steals'' a reference to o.

cdef extern from "stdlib.h":
    void *malloc(size_t) nogil
    void free(void *) nogil
    void realloc(void *, size_t) nogil
    void *memcpy(void *dest, void *src, size_t n) nogil

cdef extern from "string.h" nogil:
    void *memset(void *BLOCK, int C, size_t SIZE)

#cdef void broadcast(array_view*, array_view*, bint*, int*)
#cdef void broadcast_leading(array_view*, int, int) nogil

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
# PYTHON EXPORT OF ENUMERATION
#

cdef class BitWidthType(_IntEnum):
    BOOL        = BitWidthType(_b.BOOL)
    INT8        = BitWidthType(_b.INT8)
    INT16       = BitWidthType(_b.INT16)
    INT32       = BitWidthType(_b.INT32)
    if HAVE_INT64:
        INT64 = BitWidthType(_b.INT64)
    if HAVE_INT128:
        INT128      = BitWidthType(_b.INT128)
    if HAVE_INT256:
        INT256      = BitWidthType(_b.INT256)
    UINT8       = BitWidthType(_b.UINT8)
    UINT16      = BitWidthType(_b.UINT16)
    UINT32      = BitWidthType(_b.UINT32)
    if HAVE_UINT64:
        UINT64      = BitWidthType(_b.UINT64)
    if HAVE_UINT128:
        UINT128     = BitWidthType(_b.UINT128)
    if HAVE_UINT256:
        UINT256     = BitWidthType(_b.UINT256)
    if HAVE_FLOAT16:
        FLOAT16     = BitWidthType(_b.FLOAT16)
    FLOAT32     = BitWidthType(_b.FLOAT32)
    FLOAT64     = BitWidthType(_b.FLOAT64)
    if HAVE_FLOAT80:
        FLOAT80     = BitWidthType(_b.FLOAT80)
    if HAVE_FLOAT96:
        FLOAT96     = BitWidthType(_b.FLOAT96)
    if HAVE_FLOAT128:
        FLOAT128    = BitWidthType(_b.FLOAT128)
    if HAVE_FLOAT256:
        FLOAT256     = BitWidthType(_b.FLOAT256)
    if HAVE_COMPLEX32:
        COPLEX32     = BitWidthType(_b.COMPLEX32)
    if HAVE_COMPLEX64:
        COMPLEX64   = BitWidthType(_b.COMPLEX64)
    if HAVE_COMPLEX128:
        COMPLEX128  = BitWidthType(_b.COMPLEX128)
    if HAVE_COMPLEX160:
        COMPLEX160  = BitWidthType(_b.COMPLEX160)
    if HAVE_COMPLEX192:
        COMPLEX192  = BitWidthType(_b.COMPLEX192)
    if HAVE_COMPLEX256:
        COMPLEX256  = BitWidthType(_b.COMPLEX256)
    if HAVE_COMPLEX512:
        COMPLEX512  = BitWidthType(_b.COMPLEX512)


cdef class MinMaxType(_IntEnum):
    MAX_INT8    = MinMaxType(_b.MAX_INT8)
    MIN_INT8    = MinMaxType(_b.MIN_INT8)
    MAX_UINT8   = MinMaxType(_b.MAX_UINT8)
    MAX_INT16   = MinMaxType(_b.MAX_INT16)
    MIN_INT16   = MinMaxType(_b.MIN_INT16)
    MAX_UINT16  = MinMaxType(_b.MAX_UINT16)
    MAX_INT32   = MinMaxType(_b.MAX_INT32)
    MIN_INT32   = MinMaxType(_b.MIN_INT32)
    MAX_UINT32  = MinMaxType(_b.MAX_UINT32)
    if HAVE_INT64:
        MAX_INT64   = MinMaxType(_b.MAX_INT64)
        MIN_INT64   = MinMaxType(_b.MIN_INT64)
    if HAVE_UINT64:
        MAX_UINT64  = MinMaxType(_b.MAX_UINT64)
    if HAVE_INT128:
        MAX_INT128  = MinMaxType(_b.MAX_INT128)
        MIN_INT128  = MinMaxType(_b.MIN_INT128)
    if HAVE_UINT128:
        MAX_UINT128 = MinMaxType(_b.MAX_UINT128)
    if HAVE_INT256:
        MAX_INT256  = MinMaxType(_b.MAX_INT256)
        MIN_INT256  = MinMaxType(_b.MIN_INT256)
    if HAVE_UINT256:
        MAX_UINT256 = MinMaxType(_b.MAX_UINT256)


#
# ARRAY ITERATOR
#
cdef class _mdarray_iterator:
    cdef :
        char *data
        Py_ssize_t memory_step
        Py_ssize_t index
        Py_ssize_t stop_index
        mdarray md_array

    def __cinit__(_mdarray_iterator self, mdarray md_array):
        self.data = md_array._interface.data
        self.stop_index = md_array.size - 1
        #NOTE: ok if we're sure we stay contigous
        if md_array.mode == u'C':
            self.memory_step = md_array._interface.strides[md_array._interface.ndim - 1]
        else:
            self.memory_step = md_array._interface.strides[0]
        self.md_array = md_array

    def __init__(_mdarray_iterator self, mdarray md_array):
        self.index = 0

    def __next__(self):
        if self.index > self.stop_index:
            raise StopIteration
        cdef char *itemp
        itemp = self.data + self.index * self.memory_step
        self.index += 1
        return self.md_array.convert_item_to_object(itemp)

#
# CType to Python convertion routines
#
cdef inline object clamp_c(object v, wide mini, uwide maxi):
    cdef object num
    num = get_pylong(v)
    if v < mini:
        v = mini
    elif v > maxi:
        v = maxi
    return v

cdef int py_to_wide(cnumber *c, object v, bint clmp) except -1:
    cdef wide w
    cdef uwide uw
    cdef object num
    num = get_pylong(v)
    if num < 0:
        #w = <wide> num
        w = PyLong_AsUnsignedLongMask(num)
        memcpy(<char *> &c.val.w, <char *> &w, sizeof(w))
    else:
        #uw = <uwide> num
        uw = PyLong_AsUnsignedLongMask(num)
        memcpy(<char *> &c.val.uw, <char *> &uw, sizeof(uw))

cdef int py_to_b(cnumber *c, object v, bint clmp) except -1:
    c.val.b = PyObject_IsTrue(v)
    c.ctype = BOOL

cdef int py_to_i8(cnumber *c, object v, bint clmp) except -1:
    if clmp:
        c.val.i8 = clamp_c(v, <wide> MIN_INT8, <uwide> MAX_INT8)
    else:
        c.val.i8 = get_pylong(v)
    c.ctype = INT8

cdef int py_to_u8(cnumber *c, object v, bint clmp) except -1:
    if clmp:
        c.val.u8 = clamp_c(v, 0, <uwide> MAX_UINT8)
    else:
        c.val.u8 = get_pylong(v)
    c.ctype = UINT8

cdef int py_to_i16(cnumber *c, object v, bint clmp) except -1:
    if clmp:
        c.val.i16 = clamp_c(v, <wide> MIN_INT16, <uwide> MAX_INT16)
    else:
        c.val.i16 = get_pylong(v)
    c.ctype = INT16

cdef int py_to_u16(cnumber *c, object v, bint clmp) except -1:
    if clmp:
        c.val.u16 = clamp_c(v, 0, <uwide> MAX_UINT16)
    else:
        c.val.u16 = get_pylong(v)
    c.ctype = UINT16

cdef int py_to_i32(cnumber *c, object v, bint clmp) except -1:
    if clmp:
        c.val.i32 = clamp_c(v, <wide> MIN_INT32, <uwide> MAX_INT32)
    else:
        c.val.i32 = get_pylong(v)
    c.ctype = INT32

cdef int py_to_u32(cnumber *c, object v, bint clmp) except -1:
    if clmp:
        c.val.u32 = clamp_c(v, 0, <uwide> MAX_UINT32)
    else:
        c.val.u32 = get_pylong(v)
    c.ctype = UINT32

cdef int py_to_i64(cnumber *c, object v, bint clmp) except -1:
    if clmp:
        c.val.i64 = clamp_c(v, <wide> MIN_INT64, <uwide> MAX_INT64)
    else:
        c.val.i64 = get_pylong(v)
    c.ctype = INT64

cdef int py_to_u64(cnumber *c, object v, bint clmp) except -1:
    if clmp:
        c.val.u64 = clamp_c(v, 0, <uwide> MAX_UINT64)
    else:
        c.val.u64 = get_pylong(v)
    c.ctype = UINT64

#NOTE: overflow should occurs on float
cdef int py_to_f32(cnumber *c, object v, bint clmp) except -1:
    c.val.f32 = PyFloat_AsDouble(v)
    c.ctype = FLOAT32

cdef int py_to_f64(cnumber *c, object v, bint clmp) except -1:
    c.val.f64 = PyFloat_AsDouble(v)
    c.ctype = FLOAT64

# i128 i256 u128 u256 f16 f80 f96 f128 f256
#c32 c64 c128 c160 c192 c256 c512

ctypedef object (*co_ptr)(cnumber *)
ctypedef int (*oc_ptr) (cnumber *, object, bint) except -1

cdef oc_ptr py_to_c_functions [ALL_FORMATS]
py_to_c_functions[<Py_ssize_t> BOOL] = py_to_b

py_to_c_functions[<Py_ssize_t> INT8] = py_to_i8
py_to_c_functions[<Py_ssize_t> INT16] = py_to_i16
py_to_c_functions[<Py_ssize_t> INT32] = py_to_i32
py_to_c_functions[<Py_ssize_t> INT64] = py_to_i64

py_to_c_functions[<Py_ssize_t> UINT8] = py_to_u8
py_to_c_functions[<Py_ssize_t> UINT16] = py_to_u16
py_to_c_functions[<Py_ssize_t> UINT32] = py_to_u32
py_to_c_functions[<Py_ssize_t> UINT64] = py_to_u64

py_to_c_functions[<Py_ssize_t> FLOAT32] = py_to_f32
py_to_c_functions[<Py_ssize_t> FLOAT64] = py_to_f64

#
# CType to Python convertion routines
#
cdef b_to_py(cnumber *c):
    return c.val.b

cdef i8_to_py(cnumber *c):
    return c.val.i8

cdef u8_to_py(cnumber *c):
    return c.val.u8

cdef i16_to_py(cnumber *c):
    return c.val.i16

cdef u16_to_py(cnumber *c):
    return c.val.u16

cdef i32_to_py(cnumber *c):
    return c.val.i32

cdef u32_to_py(cnumber *c):
    return c.val.u32

cdef i64_to_py(cnumber *c):
    return c.val.i64

cdef u64_to_py(cnumber *c):
    return c.val.u64

cdef f32_to_py(cnumber *c):
    return c.val.f32

cdef f64_to_py(cnumber *c):
    return c.val.f64

cdef co_ptr c_to_py_functions [ALL_FORMATS]
c_to_py_functions[<Py_ssize_t> BOOL] = b_to_py

c_to_py_functions[<Py_ssize_t> INT8] = i8_to_py
c_to_py_functions[<Py_ssize_t> INT16] = i16_to_py
c_to_py_functions[<Py_ssize_t> INT32] = i32_to_py
c_to_py_functions[<Py_ssize_t> INT64] = i64_to_py

c_to_py_functions[<Py_ssize_t> UINT8] = u8_to_py
c_to_py_functions[<Py_ssize_t> UINT16] = u16_to_py
c_to_py_functions[<Py_ssize_t> UINT32] = u32_to_py
c_to_py_functions[<Py_ssize_t> UINT64] = u64_to_py

c_to_py_functions[<Py_ssize_t> FLOAT32] = f32_to_py
c_to_py_functions[<Py_ssize_t> FLOAT64] = f64_to_py

# PyArrayInterface
#
# The PyArrayInterface structure is defined so that NumPy and other
# extension modules can use the rapid array interface protocol.
# The __array_struct__ method of an object that supports the rapid
# array interface protocol should return a PyCObject that contains
# a pointer to a PyArrayInterface structure with the relevant details
# of the array. After the new array is created, the attribute
# should be DECREF‘d which will free the PyArrayInterface structure.
# Remember to INCREF the object (whose __array_struct__ attribute
# was retrieved) and point the base member of the new PyArrayObject
# to this same object. In this way the memory for the array will
# be managed correctly.

ctypedef struct PyArrayInterface:
  int two              # contains the integer 2 -- simple sanity check
  int nd               # number of dimensions
  char typekind        # kind in array --- character code of typestr
  int itemsize         # size of each element
  int flags            # flags indicating how the data should be interpreted */
                       #   must set ARR_HAS_DESCR bit to validate descr */
  Py_intptr_t *shape   # A length-nd array of shape information */
  Py_intptr_t *strides # A length-nd array of stride information */
  void *data           # A pointer to the first element of the array */
  PyObject *descr      # NULL or data-description (same as descr key
                       #       of __array_interface__) -- must set ARR_HAS_DESCR
                       #       flag or this will be ignored. */

DEF MAX_ARRAY_DIM = 50

ctypedef struct array_view:
    char *data
    int ndim
    int itemsize
    Py_ssize_t len
    Py_ssize_t shape [MAX_ARRAY_DIM]
    Py_ssize_t strides [MAX_ARRAY_DIM]
    Py_ssize_t suboffsets [MAX_ARRAY_DIM]


#TODO: DOCSTRING
cdef class mdarray:
    """Multidimentional array of homogenus type.
    """
    cdef :
        array_view _interface

        unicode mode
        bytes _format
        char *format

        #TODO : dont's sure we nedd it at all
        void (*callback_free_data)(void *data)
        bint free_data

        #TODO: check pythreadlocks
        PyThread_type_lock lock

        _struct formater
        _mdarray_iterator iterator

        # cache for data exchange between array and _struct
        cnumber *items_cache

        # Tables of routines conversion from ctype to python numbers
        co_ptr c_to_py [ALL_FORMATS]
        oc_ptr py_to_c [ALL_FORMATS]
        bint overflow
        bint clamp

        object obj
        bint readonly

    cdef object __weakref__
    cdef object __array_interface__
    #cdef PyCObject __array_struct__


    def __init__(mdarray self, tuple shape not None, format="=i1",
                  order=u"C", initializer=None,
                  int offset=0, overflow=True, clamp=False,
                  *args, **kwargs):
        """Multidimentional constructor.
        """
        pass

    def __cinit__(mdarray self, tuple shape not None, format="=i1",
                  order=u"C", initializer=None,
                  int offset=0, overflow=True, clamp=False,
                  *args, **kwargs):
        cdef int idx
        cdef Py_ssize_t i

        self.lock = PyThread_allocate_lock()
        if self.lock == NULL:
            raise MemoryError

        encode = getattr(format, 'encode', None)
        if encode:
            format = encode('ASCII')
        self._format = format
        self.format = self._format

        new_struct(&self.formater, self._format)
        self._interface.itemsize = self.formater.size
        self._interface.ndim = len(shape)
        if not self._interface.ndim:
            raise ValueError("Empty shape tuple for mdarray")
        elif self._interface.ndim > MAX_ARRAY_DIM:
            raise ValueError("Array is limited to %i dimensions:\
                              ask for %i dimension" %(MAX_ARRAY_DIM, self._interface.ndim))
        for i in xrange(self._interface.ndim):
            self._interface.suboffsets[i] = -1

        self.items_cache = <cnumber *> malloc(sizeof(cnumber) * self.formater.length)
        if not self.items_cache:
            free(self.items_cache)
            raise MemoryError("unable to allocate memory for items_cache")

        idx = 0
        for idx, dim in enumerate(shape):
            if dim <= 0:
                raise ValueError("Invalid shape in axis %d: %d." % (idx, dim))
            self._interface.shape[idx] = dim
            idx += 1

        if order not in ("f", "F", "c", "C"):
            raise ValueError("Invalid mode, expected 'c' or 'f', got %s" % order)
        if order == 'F' or order == 'f':
            self.mode = u'F'
        else:
            self.mode = u'C'
        self._interface.len = self.fill_contig_strides_array(self._interface.shape, self._interface.strides,
                                             self._interface.itemsize, self._interface.ndim)

        # convertion functions
        self.overflow = overflow
        self.clamp = clamp
        memcpy(self.c_to_py, c_to_py_functions, sizeof(co_ptr) * ALL_FORMATS)
        memcpy(self.py_to_c, py_to_c_functions, sizeof(co_ptr) * ALL_FORMATS)
        #FIXME; platform dependant code here
        if not overflow and not clamp:
            self.py_to_c[<Py_ssize_t> INT8] = py_to_wide
            self.py_to_c[<Py_ssize_t> UINT8] = py_to_wide
            self.py_to_c[<Py_ssize_t> INT16] = py_to_wide
            self.py_to_c[<Py_ssize_t> UINT16] = py_to_wide
            self.py_to_c[<Py_ssize_t> INT32] = py_to_wide
            self.py_to_c[<Py_ssize_t> UINT32] = py_to_wide
            self.py_to_c[<Py_ssize_t> INT64] = py_to_wide
            self.py_to_c[<Py_ssize_t> UINT64] = py_to_wide

        # buffer allocation
        cdef Py_ssize_t it
        cdef char *ptr
        cdef Py_buffer info
        self.free_data = not PyObject_CheckBuffer(initializer)

        if self.free_data:
            self._interface.data = <char *>malloc(self._interface.len)
            self.obj = self
            self.readonly = 0
            #TODO: CALLOC
            if not self._interface.data:
                free(self._interface.data)
                raise MemoryError("unable to allocate array data.")
            if initializer is not None:
                if hasattr(initializer, '__iter__'):
                    itr = initializer.__iter__()
                    item = None
                    ptr = self._interface.data
                    for i in xrange(self._interface.len / self._interface.itemsize):
                        try:
                            item = itr.__next__()
                        except StopIteration:
                            itr = initializer.__iter__()
                            item = itr.__next__()
                        self.assign_item_from_object(ptr, item)
                        ptr += self._interface.itemsize
                else:
                    raise TypeError("Initializer is not iterable.")
            else:
                memset(self._interface.data, 0, self._interface.len)
        else:
            # Test Buffer validity
            # shape could be different, format too
            # the rule is the array beeing created should
            # not emit memory access over the data buffer,
            # buffer.len - offset >= _interface.len
            PyObject_GetBuffer(initializer, &info, PyBUF_WRITABLE)
            if not PyBuffer_IsContiguous(&info, 'A'):
                raise TypeError("Buffer should have contiguous memory block.")

            if info.len - offset >= self._interface.len:
                self._interface.data = <char *> info.buf + offset
                self.obj = info.obj
                self.readonly = info.readonly
            else:
                raise TypeError("buffer is too small for requested array.")


    cdef Py_ssize_t fill_contig_strides_array(mdarray self,
                Py_ssize_t *shape, Py_ssize_t *strides, Py_ssize_t stride,
                int ndim)except -1:
        cdef char *order
        cdef int idx
        py_byte_string = self.mode.encode('UTF-8')
        order = py_byte_string
        with nogil:
            if order[0] == 'F':
                for idx in range(ndim):
                    strides[idx] = stride
                    stride = stride * shape[idx]
            else:
                for idx in range(ndim - 1, -1, -1):
                    strides[idx] = stride
                    stride = stride * shape[idx]
        return stride

    def __dealloc__(mdarray self):
        if self.callback_free_data != NULL:
            self.callback_free_data(self._interface.data)
        elif self.free_data:
            free(self._interface.data)
        free(self.items_cache)
        del_struct(&self.formater)
        if self.lock != NULL:
            PyThread_free_lock(self.lock)

    #
    # BUFFER INTERFACE [PEP 3118]
    #
    cdef char* _get_buffer_format(self):
        if self.formater.buffer_format == NULL:
            raise BufferError("Buffer value(s) cant't be expose.")
        else:
            return self.formater.buffer_format

    #@cname('getbuffer')
    def __getbuffer__(mdarray self, Py_buffer *info, int flags):
        info.buf = <void*> self._interface.data
        info.len = self._interface.len
        info.suboffsets = NULL  # we are always direct memory buffer
        info.readonly = 0
        info.obj = self.obj
        info.internal = NULL

        if flags & PyBUF_WRITABLE or not self.readonly:
            info.readonly = 0
        else:
            info.readonly = 1

        if flags & PyBUF_SIMPLE:
            # The format of data is assumed to be
            # raw unsigned bytes, without any particular structure,
            # interpreted as one dimentional array (strides=NULL)
            # The buffer exposes a read-only memory area.
            # Data is always contigous.
            info.ndim = 1
            info.shape = NULL
            info.strides = NULL
            info.format = NULL  # mean 'B', unsigned byte
            info.itemsize = self._interface.itemsize  # The 'itemsize' field may be wrong
            return

        info.ndim = self._interface.ndim
        info.shape = self._interface.shape
        info.strides = self._interface.strides
        info.itemsize = self._interface.itemsize

        if not (flags & PyBUF_ND):
            if self._interface.ndim > 1:
                raise BufferError("Buffer cant't be expose as one dimentional array.")
            else:
                info.shape = NULL

        if not (flags & PyBUF_STRIDES):
            if self._interface.ndim > 1 and self.mode == b"F":
                raise BufferError("Buffer cant't be expose without strides info.")
            else:
                info.strides = NULL

        cdef int bufmode = -1
        if self.mode == b"C":
            bufmode = PyBUF_C_CONTIGUOUS | PyBUF_ANY_CONTIGUOUS
        elif self.mode == b"F":
            bufmode = PyBUF_F_CONTIGUOUS | PyBUF_ANY_CONTIGUOUS
        if not (flags & bufmode):
            raise BufferError("Can only create a buffer that is contiguous in memory.")

        if flags & PyBUF_FORMAT:
            info.format = self._get_buffer_format()
        else:
            info.format = NULL

    #__pyx_getbuffer = capsule(<void *> &__pyx_array_getbuffer, "getbuffer(obj, view, flags)")
    #def __releasebuffer__(self):

    property memview:
        #@cname('get_memview')
        def __get__(self):
            # Make this a property as 'self.data' may be set after instantiation
            flags =  PyBUF_ANY_CONTIGUOUS|PyBUF_FORMAT|PyBUF_WRITABLE
            cdef cython.view.memoryview mv = cython.view.memoryview(self, flags, False)
            return mv

    #
    # MEMORY LAYOUT - NUMPY-LIKE INTERFACE
    #
    property base:
        #@cname('get_base')
        def __get__(self):
            return self.obj

    property format:
        #@cname('get__format')
        def __get__(self):
            return self.format

    property shape:
        #@cname('get_shape')
        def __get__(self):
            return tuple([self._interface.shape[i] for i in xrange(self._interface.ndim)])

    property strides:
        #@cname('get_strides')
        def __get__(self):
            return tuple([self._interface.strides[i] for i in xrange(self._interface.ndim)])

    property suboffsets:
        #@cname('get_suboffsets')
        def __get__(self):
            #if self.suboffsets == NULL:
            return [-1] * self._interface.ndim
            #return tuple([self.suboffsets[i] for i in xrange(self.ndim)])

    property ndim:
        #@cname('get_ndim')
        def __get__(self):
            return self._interface.ndim

    property itemsize:
        #@cname('get_itemsize')
        def __get__(self):
            return self._interface.itemsize

    property nbytes:
        #@cname('get_nbytes')
        def __get__(self):
            return self._interface.len

    property size:
        #@cname('get_size')
        def __get__(self):
            return self._interface.len / self._interface.itemsize

    #
    # __ARRAY_INTERFACE__
    #
    #TODO: __array_interface__

    #
    # MUTABLE SEQUENCE INTERFACE : SIZED + ITERABLE + CONTAINER
    #
    #
    # SIZED INTERFACE
    #
    def __len__(self):
        if self._interface.ndim >= 1:
            return self._interface.shape[0]
        return 0

    #
    # SEQUENCE INTERFACE : __getitem__(), __setitem__(), __delitem()__
    #
    cdef assign_item_from_object(mdarray self, char *itemp, object value):
        cdef char c
        cdef Py_ssize_t i
        cdef Py_ssize_t le

        #TODO: optimize type test on tuple, twice here
        if not isinstance(value, tuple):
            le = 1
        else :
            le = len(value)
        if le != self.formater.length:
            raise TypeError("Wrong number of arguments to pack : \
%i in place of %i" % (le, self.formater.length))

        if isinstance(value, tuple):
            for i in xrange(le):
                self.get_cnumber_from_PyVal(&self.items_cache[i], value[i], self.formater.formats[i])
        else:
            self.get_cnumber_from_PyVal(&self.items_cache[0], value, self.formater.formats[0])

        struct_pack(&self.formater, itemp, &self.items_cache)


    cdef object convert_item_to_object(mdarray self, char *itemp):
        cdef Py_ssize_t le = self.formater.length
        cdef object pytuple
        cdef Py_ssize_t i

        struct_unpack(&self.formater, itemp, &self.items_cache)
        if le == 1:
            return self.get_PyVal_from_cnumber(&self.items_cache[0])

        pytuple = PyTuple_New(le)
        for i in xrange(le):
            PyTuple_SetItem(pytuple, i, self.get_PyVal_from_cnumber(&self.items_cache[i]))
        return pytuple

    cdef object get_PyVal_from_cnumber(mdarray self, cnumber *c):
        return self.c_to_py[<Py_ssize_t> c.ctype](c)

    cdef int get_cnumber_from_PyVal(mdarray self, cnumber *c, object v, num_types n) except -1:
        return self.py_to_c[<Py_ssize_t> n](c, v, self.clamp)

    cdef char *get_item_pointer(mdarray self, object index) except NULL:
        cdef Py_ssize_t dim
        cdef char *itemp = self._interface.data
        for dim, idx in enumerate(index):
            itemp = self.pybuffer_index(itemp, idx, dim)
        return itemp

    cdef char *pybuffer_index(mdarray self, char *itemp, Py_ssize_t index,
                              int dim) except NULL:
        cdef char *result
        cdef int offset
        if index < 0:
            index += self._interface.shape[dim]
            if index < 0:
                raise IndexError("Index out of bounds (axis %d)" % dim)
        if index >= self._interface.shape[dim]:
            raise IndexError("Index out of bounds (axis %d)" % dim)
        offset = index * self._interface.strides[dim]
        result = itemp + offset
        return result

    def __getitem__(mdarray self, object index):
        if index is Ellipsis:
            return self.copy()
        have_slices, indices = self._unellipsify(index)
        cdef char *itemp
        if have_slices:
            return self.get_sliced_array(indices)
        else:
            itemp = self.get_item_pointer(indices)
            return self.convert_item_to_object(itemp)

    def __setitem__(mdarray self, object index, object value):
        if self.readonly:
            raise AttributeError("Memory buffer is readonly")
        have_slices, indices = self._unellipsify(index)
        if have_slices:
            obj = self.is_slice(value)
            if obj:
                self.setitem_slice_assignment(indices, obj)
            else:
                self.setitem_slice_assign_scalar(indices, value)
        else:
            self.setitem_indexed(indices, value)

    cdef is_slice(mdarray self, obj):
        cdef cython.view.memoryview mv
        try:
            flags = PyBUF_ANY_CONTIGUOUS|PyBUF_FORMAT
            mv = cython.view.memoryview(obj, flags, False)
            obj = mv
        except TypeError:
            return None
        return obj

    cdef setitem_indexed(mdarray self, index, value):
        cdef char *itemp = self.get_item_pointer(index)
        self.assign_item_from_object(itemp, value)

    cdef setitem_slice_assignment(mdarray self, object indices, cython.view.memoryview obj):
        cdef array_view src, dst
        cdef int ndim, i, dim
        cdef bint broadcasting

        self.get_slice_view_from_memview(obj, &src)
        # first slice me
        self.get_slice_view(indices, &self._interface, &dst)
        # compare ndim src & dst : broadcast or not
        broadcast(&src, &dst, &broadcasting, &ndim)

        #
        # go by assign_item_from_object()
        cdef int limit = 1
        cdef int loop = 1
        cdef int offset_dst = 0
        cdef int offset_src = 0
        cdef int pos = 0
        cdef int last_dim_len
        cdef char *ptr_dst
        cdef char *ptr_src
        cdef object value
        cdef int dim_countdown [MAX_ARRAY_DIM]
        cdef int src_indices [MAX_ARRAY_DIM]

        for i in xrange(ndim):
            limit *= dst.shape[i]
            dim_countdown[i] = dst.shape[i] - 1
            src_indices[i] = dim_countdown[i] % src.shape[i]
        last_dim_len = dst.shape[ndim - 1]

        while loop <= limit:
            cursor = ndim - 1
            for pos in xrange(last_dim_len):
                offset_dst = 0
                offset_src = 0
                for i in xrange(ndim):
                    offset_dst += dim_countdown[i] * dst.strides[i]
                    offset_src += src_indices[i] * src.strides[i]
                ptr_dst = dst.data + offset_dst
                ptr_src = src.data + offset_src

                #
                # assigneent
                value = obj.convert_item_to_object(ptr_src)
                self.assign_item_from_object(ptr_dst, value)
                dim_countdown[cursor] -= 1
                src_indices[cursor] = dim_countdown[cursor] % src.shape[cursor]

            while cursor > -1:
                if dim_countdown[cursor] > 0:
                    dim_countdown[cursor] -= 1
                    src_indices[cursor] = dim_countdown[cursor] % src.shape[cursor]
                    cursor = -1
                else:
                    dim_countdown[cursor] = dst.shape[cursor] - 1
                    src_indices[cursor] = dim_countdown[cursor] % src.shape[cursor]
                    cursor -= 1
            loop += last_dim_len


    cdef setitem_slice_assign_scalar(mdarray self, object indices, value):
        cdef array_view src, dst
        cdef char *ptr_src
        cdef int loop = 1
        cdef int limit, i
        cdef int last_dim_len
        cdef int offset_src, pos = 0
        cdef Py_ssize_t sz = self._interface.itemsize
        cdef Py_ssize_t cursor
        cdef int dim_countdown [MAX_ARRAY_DIM]

        self.get_slice_view(indices, &self._interface, &dst)

        limit = 1
        for i in xrange(dst.ndim):
            limit *= dst.shape[i]
            dim_countdown[i] = dst.shape[i] - 1
        dim = dst.ndim
        last_dim_len = dst.shape[dst.ndim - 1]

        while loop <= limit:
            cursor = dst.ndim - 1
            for pos in xrange(last_dim_len):
                offset_src = 0
                for i in xrange(dst.ndim):
                    offset_src += dim_countdown[i] * dst.strides[i]
                ptr_src = dst.data + offset_src
                self.assign_item_from_object(ptr_src, value)
                dim_countdown[cursor] -= 1

            while cursor > -1:
                if dim_countdown[cursor] > 0:
                    dim_countdown[cursor] -= 1
                    cursor = -1
                else:
                    dim_countdown[cursor] = dst.shape[cursor] - 1
                    cursor -= 1
            loop += last_dim_len

    cdef mdarray get_sliced_array(mdarray self, object indices):
        cdef int i, dim, new_ndim = 0
        cdef array_view src, dst
        cdef mdarray sliced
        cdef object tpl

        assert self._interface.ndim > 0

        self.get_slice_view(indices, &self._interface, &dst)
        tpl = tuple([dst.shape[i] for i in xrange(dst.ndim)])
        sliced = mdarray(tpl, self.format, self.mode,
                         overflow=self.overflow, clamp=self.clamp)

        cdef char *ptr_dest
        cdef char *ptr_src
        cdef int loop = 1
        cdef int limit = sliced.size
        cdef int last_dim_len = dst.shape[dst.ndim - 1]
        cdef int offset_src, offset_dst, pos = 0
        cdef Py_ssize_t sz = self._interface.itemsize
        cdef Py_ssize_t cursor
        cdef int dim_countdown [MAX_ARRAY_DIM]

        for i in xrange(dst.ndim):
            dim_countdown[i] = dst.shape[i] - 1
        dim = dst.ndim

        while loop <= limit:
            cursor = dst.ndim - 1
            for pos in xrange(last_dim_len):
                offset_src = 0
                offset_dst = 0
                for i in xrange(dst.ndim):
                    offset_dst += dim_countdown[i] * sliced._interface.strides[i]
                    offset_src += dim_countdown[i] * dst.strides[i]
                ptr_src = dst.data + offset_src
                ptr_dest = sliced._interface.data + offset_dst
                memcpy(ptr_dest, ptr_src, sz)
                dim_countdown[cursor] -= 1
            while cursor > -1:
                if dim_countdown[cursor] > 0:
                    dim_countdown[cursor] -= 1
                    cursor = -1
                else:
                    dim_countdown[cursor] = dst.shape[cursor] - 1
                    cursor -= 1
            loop += last_dim_len
        return sliced

    cdef tuple _unellipsify(mdarray self, object index):
        """
        Replace all ellipses with full slices and fill incomplete indices with
        full slices.
        """
        #TODO: code à optimiser? à tester.
        if not isinstance(index, tuple):
            tup = (index,)
        else:
            tup = index

        cdef int ndim = self.ndim
        result = []
        have_slices = False
        seen_ellipsis = False
        for idx, item in enumerate(tup):
            if item is Ellipsis:
                if not seen_ellipsis:
                    result.extend([slice(None)] * (ndim - len(tup) + 1))
                    seen_ellipsis = True
                else:
                    result.append(slice(None))
                have_slices = True
            else:
                if not isinstance(item, slice) and not PyIndex_Check(item):
                    raise TypeError("Cannot index with type '%s'" % type(item))
                have_slices = have_slices or isinstance(item, slice)
                result.append(item)

        nslices = ndim - len(result)
        if nslices:
            result.extend([slice(None)] * nslices)
        return have_slices or nslices, tuple(result)

    cdef int get_slice_view_from_memview(mdarray self, cython.view.memoryview obj, array_view *aview) except -1:
        cdef Py_buffer buf

        PyObject_GetBuffer(obj, &buf, PyBUF_INDIRECT| PyBUF_FORMAT)
        aview.data = <char *> buf.buf
        aview.ndim = buf.ndim
        aview.itemsize = buf.itemsize
        aview.len = buf.len
        for i in xrange(buf.ndim):
            aview.shape[i] = buf.shape[i]
            aview.strides[i] = buf.strides[i]
            #FIXME:
            aview.suboffsets[i] = -1#buf.suboffsets[i]


    cdef int get_slice_view_from_object(mdarray self, object obj, array_view *aview) except -1:
        cdef Py_buffer buf

        if isinstance(obj, mdarray):
            aview[0] = self._interface

        elif PyObject_CheckBuffer(obj):
            PyObject_GetBuffer(obj, &buf, PyBUF_INDIRECT| PyBUF_FORMAT)
            aview.data = <char *> buf.buf
            aview.ndim = buf.ndim
            aview.itemsize = buf.itemsize
            aview.len = buf.len
            for i in xrange(buf.ndim):
                aview.shape[i] = buf.shape[i]
                aview.strides[i] = buf.strides[i]
            if buf.suboffsets == NULL:
                for i in xrange(buf.ndim):
                    aview.suboffsets[i] = -1
            else:
                for i in xrange(buf.ndim):
                    aview.suboffsets[i] = buf.suboffsets[i]
        else:
            return -1


    cdef get_slice_view(mdarray self, object indices, array_view *s_view, array_view *d_view):
        cdef object index
        cdef int dim
        cdef int suboffset_dim = -1
        cdef Py_ssize_t start, stop, step
        cdef bint have_start, have_stop, have_step

        d_view.data = s_view.data
        d_view.ndim = 0

        for dim, index in enumerate(indices):
            if PyIndex_Check(index):
                self.do_slice(
                    d_view, s_view.shape[dim], s_view.strides[dim], s_view.suboffsets[dim],
                    dim, d_view.ndim, &suboffset_dim,
                    index, 0, 0, # start, stop, step
                    0, 0, 0, # have_{start,stop,step}
                    False)
            elif index is None:
                d_view.shape[d_view.ndim] = 1
                d_view.strides[d_view.ndim] = 0
                d_view.suboffsets[d_view.ndim] = -1
                d_view.ndim += 1
            else: # index is a slice
                start = index.start or 0
                stop = index.stop or 0
                step = index.step or 0
                have_start = index.start is not None
                have_stop = index.stop is not None
                have_step = index.step is not None
                self.do_slice(
                    d_view, s_view.shape[dim], s_view.strides[dim], s_view.suboffsets[dim],
                    dim, d_view.ndim, &suboffset_dim,
                    start, stop, step,
                    have_start, have_stop, have_step,
                    True)
                d_view.ndim += 1

    cdef int do_slice(mdarray self,
            array_view *dst,
            Py_ssize_t shape, Py_ssize_t stride, Py_ssize_t suboffset,
            int dim, int new_ndim, int *suboffset_dim,
            Py_ssize_t start, Py_ssize_t stop, Py_ssize_t step,
            int have_start, int have_stop, int have_step,
            bint is_slice) nogil except -1:
        cdef Py_ssize_t new_shape
        cdef bint negative_step

        if not is_slice:
            # index is a normal integer-like index
            if start < 0:
                start = shape + start
            if not 0 <= start < shape:
                raise_err_dim(IndexError, "Index out of bounds (axis %d)", dim)
        else:
            # index is a slice
            negative_step = have_step != 0 and step < 0
            if have_step and step == 0:
                raise_err_dim(ValueError, "Step may not be zero (axis %d)", dim)
            # check our bounds and set defaults
            if have_start:
                if start < 0:
                    start += shape
                    if start < 0:
                        start = 0
                elif start >= shape:
                    if negative_step:
                        start = shape - 1
                    else:
                        start = shape
            else:
                if negative_step:
                    start = shape - 1
                else:
                    start = 0
            if have_stop:
                if stop < 0:
                    stop += shape
                    if stop < 0:
                        stop = 0
                elif stop > shape:
                    stop = shape
            else:
                if negative_step:
                    stop = -1
                else:
                    stop = shape
            if not have_step:
                step = 1
            # len = ceil( (stop - start) / step )
            with cython.cdivision(True):
                new_shape = (stop - start) // step
                if (stop - start) % step:
                    new_shape += 1
            if new_shape < 0:
                new_shape = 0
            # shape/strides/suboffsets
            dst.strides[new_ndim] = stride * step
            dst.shape[new_ndim] = new_shape

        dst.data += start * stride
        return 0

    #
    # ITERABLE INTERFACE
    #
    #TODO: advanced iteration
    def __iter__(mdarray self):
        if not self.iterator:
            self.iterator = _mdarray_iterator(self)
        else:
            self.iterator.__init__(self)
        return self.iterator

    #
    # CONTAINER INTERFACE
    #
    def __contains__(mdarray self, object value):
        raise NotImplementedError

    def index(self):
        raise NotImplementedError

    def count(self):
        raise NotImplementedError

    def __reversed__(self):
        raise NotImplementedError

    #
    # ITEM SELECTION AND MANIPULATION
    #
    def sort(self):
        raise NotImplementedError

    def nonzero(self):
        raise NotImplementedError

    #
    # SHAPE MANIPULATION
    #
    def reshape(self, shape, order=u'A'):
        cdef int size = 1
        cdef int dim, newdim
        cdef Py_ssize_t i
        if not isinstance(shape, (tuple, int)):
            raise TypeError("new shape should be a tuple or an integer")

        if isinstance(shape, int):
            size = shape
            newdim = 1
            shape = (shape,)
        else:
            for e in shape:
                size *= e
            newdim = len(shape)
        if size != self.size:
            raise ValueError("total size of new array must be unchanged")
        if newdim > MAX_ARRAY_DIM:
            raise ValueError("Array is limited to %i dimensions:\
                              ask for %i dimension" %(MAX_ARRAY_DIM, newdim))
        for dim in shape:
            if dim <= 0:
                raise ValueError("Invalid shape dimension %d." % (dim,))

        if order not in ("f", "F", "c", "C", "a", "A"):
            raise ValueError("Invalid mode, expected 'c', 'f' or 'a', got %s" % order)
        if order == 'F' or order == 'f':
            self.mode = u'F'
        else:
            self.mode = u'C'

        self._interface.ndim = newdim
        for i in xrange(self._interface.ndim):
            self._interface.shape[i] = shape[i]
            self._interface.suboffsets[i] = -1
        self.fill_contig_strides_array(self._interface.shape, self._interface.strides,
                                       self._interface.itemsize, self._interface.ndim)

    def resize(self, shape):
        cdef int size = 1
        cdef int dim, newdim
        cdef Py_ssize_t i, new_len, old_len
        cdef char *new_ptr

        if self.obj != self:
            raise ValueError("Mdarray could not be reshape cause it don't own its buffer.")

        if not isinstance(shape, (tuple, int)):
            raise TypeError("new shape should be a tuple or an integer")

        if isinstance(shape, int):
            size = shape
            newdim = 1
            shape = (shape,)
        else:
            for e in shape:
                size *= e
            newdim = len(shape)

        for dim in shape:
            if dim <= 0:
                raise ValueError("Invalid shape dimension %d." % (dim,))

        if newdim > MAX_ARRAY_DIM:
            raise ValueError("Array is limited to %i dimensions:\
                              ask for %i dimension" %(MAX_ARRAY_DIM, newdim))

        new_len = size * self._interface.itemsize
        if new_len != self._interface.len:
            new_ptr = <char *> realloc(self._interface.data, new_len)
            if not new_ptr:
                raise RuntimeWarning("unable to reallocate array buffer.")
            self._interface.data = new_ptr

        old_len = self._interface.len
        self._interface.ndim = newdim

        for i in xrange(newdim):
            self._interface.shape[i] = shape[i]
            self._interface.suboffsets[i] = -1
        self._interface.len = self.fill_contig_strides_array(self._interface.shape, self._interface.strides,
                                                            self._interface.itemsize, self._interface.ndim)
        if self._interface.len > old_len:
            memset(self._interface.data + old_len, 0, self._interface.len - old_len)

    def transpose(self):
        cdef array_view src

        src = self._interface
        for i in xrange(src.ndim):
            if src.suboffsets[i] >= 0:
                raise ValueError("Cannot transpose array with indirect dimensions")
        for i in xrange(src.ndim):
            self._interface.shape[src.ndim - i - 1] = src.shape[i]
            self._interface.strides[src.ndim - i - 1] = src.strides[i]
        if self.mode == u'C':
            self.mode = u'F'
        else:
            self.mode = u'C'

    property T:
        #@cname('transpose')
        def __get__(self):
            self.transpose()

    def swapaxes(self, axis1, axis2):
        if not isinstance(axis1, int) or \
           not isinstance(axis2, int):
            raise ValueError("axes should be integer value.")
        if self._interface.ndim == 1:
            raise ValueError("Can't swap one dimensionnal array.")
        if axis1 < 0 or axis1 >= self._interface.ndim or \
           axis2 < 0 or axis2 >= self._interface.ndim:
            raise ValueError("Incorrect value for axe index.")
        cdef Py_ssize_t dim_save
        dim_save = self._interface.shape[axis1]
        self._interface.shape[axis1] = self._interface.shape[axis2]
        self._interface.shape[axis2] = dim_save
        dim_save = self._interface.strides[axis1]
        self._interface.strides[axis1] = self._interface.strides[axis2]
        self._interface.strides[axis2] = dim_save
        #FIXME: we can loose c or f contiguity

    def flatten(self, order=u'A'):
        self.reshape(self.size, order)

    #def squeeze(self):
    #    raise NotImplementedError

    #
    # COPY METHOD
    #
    def copy(mdarray self):
        cdef mdarray copy_a
        cdef char *tp
        copy_a = mdarray(self.shape, self.format, self.mode,
                         overflow=self.overflow, clamp=self.clamp)
        tp = <char*> memcpy(copy_a._interface.data, self._interface.data, self._interface.len)
        if not tp:
            raise MemoryError("Unable to copy data.")
        else:
            copy_a._interface.data = tp
        return copy_a

    def copy_fortran(self):
        raise NotImplementedError

    #
    # ARRAY CONVERSION
    #
    def fill(mdarray self, object value):
        raise NotImplementedError

    def byteswap(self):
        raise NotImplementedError

    def tolist(self):
        raise NotImplementedError

    def tobyte(self):
        raise NotImplementedError

    def tostring(self):
        raise NotImplementedError

    def tofile(self):
        raise NotImplementedError

    def tounicode(self):
        raise NotImplementedError

    #
    # STRING REPRESENTATIONS
    #
    def __repr__(self):
        return self.__str__()

    def __str__(mdarray self):
        cdef int max_len = 20
        cdef char *ptr_datum
        cdef int loop = 1
        cdef int limit = self.size
        cdef int ndim = self._interface.ndim
        cdef Py_ssize_t *shape = self._interface.shape
        cdef int dim_countdown [MAX_ARRAY_DIM]

        for i in xrange(ndim):
            dim_countdown[i] = shape[i] - 1

        cdef int last_dim_len = shape[ndim - 1]
        cdef int offset, pos = 0
        cdef Py_ssize_t sz = self._interface.itemsize
        cdef Py_ssize_t *strides = self._interface.strides
        cdef object value
        cdef unicode r_str = u""
        cdef int ident = ndim

        while loop <= limit:
            r_str += u" " * (ndim - ident) + "[" * ident
            cursor = ndim - 1
            ident = 0
            for pos in xrange(last_dim_len):
                offset = 0
                for i in xrange(ndim):
                    offset += (shape[i] - 1 - dim_countdown[i]) * strides[i]
                ptr_datum = self._interface.data + offset
                value = self.convert_item_to_object(ptr_datum)
                r_str += str(value) + u", "
                dim_countdown[cursor] -= 1
            r_str = r_str[0:-2]

            while cursor > -1:
                if dim_countdown[cursor] > 0:
                    dim_countdown[cursor] -= 1
                    cursor = -1
                else:
                    dim_countdown[cursor] = shape[cursor] - 1
                    cursor -= 1
                    ident += 1
            r_str += u"]" * ident + u", " + u"\n" * ident
            loop += last_dim_len
        r_str = r_str[0:-1 * ident -2]
        return r_str

    #
    # CALCULATIONS METHOD
    #
    # all, any, max, argmax, min, argmin, ptp, clip, sum, cumsum
    # mean, prod, comprod

    #
    # ARITHMETIC
    #
    def __add__(x, y):
        return _compute(x, y, 0)


    #
    # RICH COMPARAISON
    #

#
# GENERAL ARITHMETIC C ROUTINE
#
cdef object numtypes_to_format = [""] * ALL_FORMATS
numtypes_to_format[<int> BOOL]    = "b"
numtypes_to_format[<int> UINT8]    = "u1"
numtypes_to_format[<int> UINT16]   = "u2"
numtypes_to_format[<int> UINT32]   = "u4"
numtypes_to_format[<int> UINT64]   = "u8"
numtypes_to_format[<int> UINT128]  = "u16"
numtypes_to_format[<int> UINT256]  = "u32"
numtypes_to_format[<int> INT8]     = "i1"
numtypes_to_format[<int> INT16]    = "i2"
numtypes_to_format[<int> INT32]    = "i4"
numtypes_to_format[<int> INT64]    = "i8"
numtypes_to_format[<int> INT128]   = "i16"
numtypes_to_format[<int> INT256]   = "i32"
numtypes_to_format[<int> FLOAT16]  = "f2"
numtypes_to_format[<int> FLOAT32]  = "f4"
numtypes_to_format[<int> FLOAT64]  = "f8"
numtypes_to_format[<int> FLOAT80]  = "f10"
numtypes_to_format[<int> FLOAT96]  = "f12"
numtypes_to_format[<int> FLOAT128] = "f16"
numtypes_to_format[<int> FLOAT256] = "f32"
numtypes_to_format[<int> COMPLEX32]  = "c4"
numtypes_to_format[<int> COMPLEX64]  = "c8"
numtypes_to_format[<int> COMPLEX128] = "c16"
numtypes_to_format[<int> COMPLEX160] = "c20"
numtypes_to_format[<int> COMPLEX192] = "c24"
numtypes_to_format[<int> COMPLEX256] = "c32"
numtypes_to_format[<int> COMPLEX512] = "c64"


ctypedef fused_number_1 (*c_arithmetic)(fused_number_1, fused_number_1) nogil
cdef fused_number_1 fuse_add(fused_number_1 x, fused_number_1 y) nogil:
    return x + y

"""
cdef void cnum_op(cnumber *x, cnumber *y, cnumber *r, int op) nogil:
    with nogil:
        r.val.w = <wide> op_tab[op] \
            (<wide>    (x.val.b if x.ctype == BOOL else \
            (x.val.i8 if x.ctype == INT8 else \
            (x.val.i16 if x.ctype == INT16 else \
            (x.val.i32 if x.ctype == INT32 else \
            (x.val.i64 if x.ctype == INT64 else \
            (x.val.i128 if x.ctype == INT128 else \
            (x.val.i256 if x.ctype == INT256 else \
            (x.val.u8 if x.ctype == UINT8 else \
            (x.val.u16 if x.ctype == UINT16 else \
            (x.val.u32 if x.ctype == UINT32 else \
            (x.val.u64 if x.ctype == UINT64 else \
            (x.val.u128 if x.ctype == UINT128 else \
            (x.val.u256 if x.ctype == UINT256 else \
            (x.val.f16 if x.ctype == FLOAT16 else \
            (x.val.f32 if x.ctype == FLOAT32 else \
            (x.val.f64 if x.ctype == FLOAT64 else \
            (x.val.f80 if x.ctype == FLOAT80 else \
            (x.val.f96 if x.ctype == FLOAT96 else \
            (x.val.f128 if x.ctype == FLOAT128 else \
            (x.val.f256 if x.ctype == FLOAT256 else \
            (x.val.c32 if x.ctype == COMPLEX32 else \
            (x.val.c64 if x.ctype == COMPLEX64 else \
            (x.val.c128 if x.ctype == COMPLEX128 else \
            (x.val.c160 if x.ctype == COMPLEX160 else \
            (x.val.c192 if x.ctype == COMPLEX192 else \
            (x.val.c256 if x.ctype == COMPLEX256 else x.val.c512)))))))))))))))))))))))))), \

            <wide> (y.val.b if y.ctype == BOOL else \
            (y.val.i8 if y.ctype == INT8 else \
            (y.val.i16 if y.ctype == INT16 else \
            (y.val.i32 if y.ctype == INT32 else \
            (y.val.i64 if y.ctype == INT64 else \
            (y.val.i128 if y.ctype == INT128 else \
            (y.val.i256 if y.ctype == INT256 else \
            (y.val.u8 if y.ctype == UINT8 else \
            (y.val.u16 if y.ctype == UINT16 else \
            (y.val.u32 if y.ctype == UINT32 else \
            (y.val.u64 if y.ctype == UINT64 else \
            (y.val.u128 if y.ctype == UINT128 else \
            (y.val.u256 if y.ctype == UINT256 else \
            (y.val.f16 if y.ctype == FLOAT16 else \
            (y.val.f32 if y.ctype == FLOAT32 else \
            (y.val.f64 if y.ctype == FLOAT64 else \
            (y.val.f80 if y.ctype == FLOAT80 else \
            (y.val.f96 if y.ctype == FLOAT96 else \
            (y.val.f128 if y.ctype == FLOAT128 else \
            (y.val.f256 if y.ctype == FLOAT256 else \
            (y.val.c32 if y.ctype == COMPLEX32 else \
            (y.val.c64 if y.ctype == COMPLEX64 else \
            (y.val.c128 if y.ctype == COMPLEX128 else \
            (y.val.c160 if y.ctype == COMPLEX160 else \
            (y.val.c192 if y.ctype == COMPLEX192 else \
            (y.val.c256 if y.ctype == COMPLEX256 else y.val.c512)))))))))))))))))))))))))) \
            )
"""
DEF CHUNK_NBYTES = 1024


cdef object _compute(object x, object y, int operator):
    cdef bint reverse_op = 0
    cdef bint have_arr = 0
    cdef bint broadcasting
    cdef mdarray cx, cy, arr_res = None
    cdef int format_len, ndim
    cdef object scalar = None
    cdef array_view src_x, src_y, dst

    # OPERAND VALIDITY TEST
    if isinstance(x, mdarray):
        cx = <mdarray> x
        have_arr = 1
        src_x = cx._interface
    else:
        scalar = x
        reverse_op = 1
    if isinstance(y, mdarray):
        cy = <mdarray> y
        src_y = cy._interface
    else:
        if not have_arr:
            return NotImplemented
        scalar = y

    # SCALAR VALIDITY TEST
    # we have one scalar and a array
    if scalar is not None:
        if scalar == x:
            format_len = cy.formater.length
            ndim = src_y.ndim
        else:
            format_len = cx.formater.length
            ndim = src_x.ndim
        if format_len == 1:
            if not PyNumber_Check(scalar):
                return NotImplemented
        else:
            return NotImplemented

    # BROADCASTING TEST
    # we have 2 arrays
    else:
        if cx.formater.length != cy.formater.length:
            return NotImplemented
        if cx.formater.length > 1:
            return NotImplemented
        broadcast(&src_y, &src_x, &broadcasting, &ndim)

    #
    # CHECK OPERAND ORDER
    #
    if reverse_op:  # so, we have 1 scalar
        cx = cy
        cy = None
        src_x = src_y

    # COOK RETURN ARRAY
    #FIXME: format endianess should be compute.
    # shape, mode, overflow and clamp inherited
    cdef object promo_fmt
    cdef object shape
    cdef num_types math_type
    math_type = get_promotion(cx.formater.formats[0], \
                cy.formater.formats[0])
    promo_fmt = numtypes_to_format[<int> math_type]
    shape = tuple([src_x.shape[i] for i in xrange(ndim)])
    arr_res = mdarray(shape, promo_fmt, cx.mode, \
              overflow=cx.overflow, clamp=cx.clamp)
    dst = arr_res._interface

    # USING CHUNKS FOR THE MATH
    cdef chunk chunk_x, chunk_y
    init_chunk(&chunk_x, CHUNK_NBYTES, math_type)
    init_chunk(&chunk_y, CHUNK_NBYTES, math_type)

    for i in xrange(chunk_x.size):
        pass


    # ITERATION LOOP
    cdef int limit = 1, loop = 1
    cdef int offset_src_y = 0, offset_src_x = 0, offset_dst=0, pos = 0
    cdef int last_dim_len, cursor
    cdef char *ptr_src_x, *ptr_src_y, *ptr_dst
    cdef int src_x_indices [MAX_ARRAY_DIM]
    cdef int src_y_indices [MAX_ARRAY_DIM]
    cdef object val_x, val_y, val_dst

    for i in xrange(ndim):
        limit *= src_x.shape[i]
        src_x_indices[i] = src_x.shape[i] - 1
        if scalar is None:
            src_y_indices[i] = src_x_indices[i] % src_y.shape[i]
    last_dim_len = src_x.shape[ndim - 1]

    while loop <= limit:
        cursor = ndim - 1
        for pos in xrange(last_dim_len):
            offset_src_x = 0
            offset_dst = 0
            offset_src_y = 0
            for i in xrange(ndim):
                offset_src_x += src_x_indices[i] * src_x.strides[i]
                offset_dst += src_x_indices[i] * dst.strides[i]
                offset_src_y += src_y_indices[i] * src_y.strides[i]
            ptr_src_x = src_x.data + offset_src_x
            ptr_dst = dst.data + offset_dst
            ptr_src_y = src_y.data + offset_src_y

            struct_unpack(&cx.formater, ptr_src_x, &cx.items_cache)
            struct_unpack(&cy.formater, ptr_src_y, &cy.items_cache)

            #cnum_op(&cx.items_cache[0], &cy.items_cache[0], &arr_res.items_cache[0], operator)
            struct_pack(&arr_res.formater, ptr_dst, &arr_res.items_cache)


            src_x_indices[cursor] -= 1
            src_y_indices[cursor] = src_x_indices[cursor] % src_y.shape[cursor]

        while cursor > -1:
            if src_x_indices[cursor] > 0:
                src_x_indices[cursor] -= 1
                src_y_indices[cursor] = src_x_indices[cursor] % src_y.shape[cursor]
                cursor = -1
            else:
                src_x_indices[cursor] = src_x.shape[cursor] - 1
                src_y_indices[cursor] = src_x_indices[cursor] % src_x.shape[cursor]
                cursor -= 1
        loop += last_dim_len

    return arr_res


cdef int broadcast(array_view *src, array_view *dst, bint *broadcasting, int *ndim) except -1:
    with nogil:
        # compare ndim src & dst : broadcast or not
        ndim[0] = src.ndim
        if src.ndim < dst.ndim:
            broadcast_lead(src, src.ndim, dst.ndim)
            ndim[0] = dst.ndim
        elif dst.ndim < src.ndim:
            broadcast_lead(dst, dst.ndim, src.ndim)

        for i in range(ndim[0]):
            if src.shape[i] != dst.shape[i]:
                if src.shape[i] == 1:
                    broadcasting[0] = True
                    src.strides[i] = 0
                else:
                    raise_err_extents(i, dst.shape[i], src.shape[i])
                    #raise ValueError("got differing extents in dimension %d (got %d and %d)" %
                    #                                        (i, dst.shape[i], src.shape[i]))
            if src.suboffsets[i] >= 0:
                raise_err_dim(ValueError, "Dimension %d is not direct", i)
                #raise ValueError("Dimension %d is not direct", i)

cdef void broadcast_lead(array_view *aview, int ndim, int ndim_other) nogil:
    cdef int i
    cdef int offset = ndim_other - ndim

    for i in range(ndim - 1, -1, -1):
        aview.shape[i + offset] = aview.shape[i]
        aview.strides[i + offset] = aview.strides[i]
        aview.suboffsets[i + offset] = aview.suboffsets[i]

    for i in range(offset):
        aview.shape[i] = 1
        aview.strides[i] = aview.strides[0]
        aview.suboffsets[i] = -1


# Use 'with gil' functions and avoid 'with gil' blocks, as the code within the blocks
# has temporaries that need the GIL to clean up
#
#@cname('__pyx_memoryview_err_extents')
cdef int raise_err_extents(int i, Py_ssize_t extent1,
                             Py_ssize_t extent2) except -1 with gil:
    raise ValueError("got differing extents in dimension %d (got %d and %d)" %
                                                        (i, extent1, extent2))

#@cname('__pyx_memoryview_err_dim')
cdef int raise_err_dim(object error, char *msg, int dim) except -1 with gil:
    raise error(msg.decode('ascii') % dim)



#@cname('__pyx_memoryview_err')
#cdef int _err(object error, char *msg) except -1 with gil:
#    if msg != NULL:
#        raise error(msg.decode('ascii'))
#    else:
#        raise error
