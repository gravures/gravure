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


import cython
cimport cython

from _struct cimport *
from enum cimport *
from bit_width_type cimport *
cimport bit_width_type as _b

cdef extern from "Python.h":
    object PyLong_FromVoidPtr(void *)

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

    bint PyObject_IsTrue(object o) except -1
    # Returns 1 if the object o is considered to be true, and 0
    # otherwise. This is equivalent to the Python expression "not not
    # o". On failure, return -1.

cdef extern from "pyport.h":
    ctypedef Py_ssize_t Py_intptr_t
    #TODO: Py_uintptr_t

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
        PyBUF_C_CONTIGUOUS,
        PyBUF_F_CONTIGUOUS,
        PyBUF_ANY_CONTIGUOUS
        PyBUF_FORMAT
        PyBUF_WRITABLE
        PyBUF_STRIDES
        PyBUF_INDIRECT
        PyBUF_RECORDS

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
    void *memcpy(void *dest, void *src, size_t n) nogil

cdef extern from "string.h" nogil:
    void *memset(void *BLOCK, int C, size_t SIZE)


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

cdef enum:
    MAX_DIMS = 50

#TODO: faire sans MAX_DIMS
ctypedef struct slice_view:
    char *data
    Py_ssize_t shape[MAX_DIMS]
    Py_ssize_t strides[MAX_DIMS]
    Py_ssize_t suboffsets[MAX_DIMS]
    Py_ssize_t ndim


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
include "TYPE_DEF.pxi"

cdef class BitWidthType(Enum):
    __enum_values__ = {}
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
    BitWidthType.register()


cdef class MinMaxType(Enum):
    __enum_values__ = {}
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
    MinMaxType.register()


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
        self.data = md_array.data
        self.stop_index = md_array.size - 1
        #FIXME: vraix pour mode = "C", pour "F" incorrect
        self.memory_step = md_array._strides[md_array.ndim - 1]
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
ctypedef object (*co_ptr)(cnumber *)
ctypedef int (*oc_ptr) (cnumber *, object) except -1

cdef int py_to_b(cnumber *c, object v) except -1:
    c.val.b = PyObject_IsTrue(v)
    c.ctype = BOOL

cdef int py_to_i8(cnumber *c, object v) except -1:
    c.val.i8 = get_pylong(v)
    c.ctype = INT8

cdef int py_to_u8(cnumber *c, object v) except -1:
    c.val.u8 = get_pylong(v)
    c.ctype = UINT8

cdef int py_to_i16(cnumber *c, object v) except -1:
    c.val.i16 = get_pylong(v)
    c.ctype = INT16

cdef int py_to_u16(cnumber *c, object v) except -1:
    c.val.u16 = get_pylong(v)
    c.ctype = UINT16

cdef int py_to_i32(cnumber *c, object v) except -1:
    c.val.i32 = get_pylong(v)
    c.ctype = INT32

cdef int py_to_u32(cnumber *c, object v) except -1:
    c.val.u32 = get_pylong(v)
    c.ctype = UINT32

cdef int py_to_i64(cnumber *c, object v) except -1:
    c.val.i64 = get_pylong(v)
    c.ctype = INT64

cdef int py_to_u64(cnumber *c, object v) except -1:
    c.val.u64 = get_pylong(v)
    c.ctype = UINT64

cdef int py_to_f32(cnumber *c, object v) except -1:
    c.val.f32 = PyFloat_AsDouble(v)
    c.ctype = FLOAT32

cdef int py_to_f64(cnumber *c, object v) except -1:
    c.val.f64 = PyFloat_AsDouble(v)
    c.ctype = FLOAT64

# i128 i256 u128 u256 f16 f80 f96 f128 f256
#c32 c64 c128 c160 c192 c256 c512

cdef oc_ptr py_to_c_functions [27]
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

cdef co_ptr c_to_py_functions [27]
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



#TODO: DOCSTRING
cdef class mdarray:
    """Multidimentional array of homogenus type.
    """
    cdef :
        char *format

        #TODO: put attributes below in a strucut array_view
        char *data
        Py_ssize_t len
        int ndim
        Py_ssize_t *_shape
        Py_ssize_t *_strides
        Py_ssize_t itemsize

        unicode mode
        bytes _format

        #TODO : dont's sure we nedd it ar all
        void (*callback_free_data)(void *data)
        bint free_data

        #TODO: check pythreadlocks
        PyThread_type_lock lock

        _struct formater
        _mdarray_iterator iterator

        # cache for data exchange between array and _struct
        cnumber *items_cache

        # Tables of routines conversion from ctype to python numbers
        co_ptr *c_to_py
        oc_ptr *py_to_c


    cdef object __array_interface__
    #cdef PyCObject __array_struct__


    def __init__(mdarray self, tuple shape, format not None,
                  mode=u"c", initializer=None, bint allocate_buffer=True, *args, **kwargs):
        """Multidimentional constructor.
        """
        pass

    #TODO: check again and fix constructor args

    #TODO: check weakref
    def __cinit__(mdarray self, tuple shape, format not None,
                  mode=u"c", initializer=None, bint allocate_buffer=True, *args, **kwargs):
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
        self.itemsize = self.formater.size
        self.ndim = len(shape)
        if not self.ndim:
            raise ValueError("Empty shape tuple for mdarray")

        self._shape = <Py_ssize_t *> malloc(sizeof(Py_ssize_t)*self.ndim)
        self._strides = <Py_ssize_t *> malloc(sizeof(Py_ssize_t)*self.ndim)
        if not self._shape or not self._strides:
            free(self._shape)
            free(self._strides)
            raise MemoryError("unable to allocate shape or strides.")

        self.items_cache = <cnumber *> malloc(sizeof(cnumber) * self.formater.length)
        if not self.items_cache:
            free(self.items_cache)
            raise MemoryError("unable to allocate memory for items_cache")

        idx = 0
        for idx, dim in enumerate(shape):
            if dim <= 0:
                raise ValueError("Invalid shape in axis %d: %d." % (idx, dim))
            self._shape[idx] = dim
            idx += 1

        #TODO: optimize all this conversion around mode
        if mode not in ("f", "F", "c", "C"):
            raise ValueError("Invalid mode, expected 'c' or 'f', got %s" % mode)
        cdef char order
        if mode == 'F' or mode == 'f':
            order = 'F'
        else:
            order = 'C'

        self.len = self.fill_contig_strides_array(self._shape, self._strides,
                                             self.itemsize, self.ndim, order)

        decode = getattr(mode, 'decode', None)
        if decode:
            mode = decode('ASCII')
        self.mode = mode

        self.c_to_py = c_to_py_functions
        self.py_to_c = py_to_c_functions

        self.free_data = allocate_buffer
        cdef Py_ssize_t it
        cdef char *ptr
        if allocate_buffer:
            self.data = <char *>malloc(self.len)
            #TODO: CALLOC
            if not self.data:
                free(self.data)
                raise MemoryError("unable to allocate array data.")

            if initializer is not None:
                if hasattr(initializer, '__iter__'):
                    itr = initializer.__iter__()
                    item = None
                    ptr = self.data
                    for i in xrange(self.len / self.itemsize):
                        try:
                            item = itr.__next__()
                        except StopIteration:
                            itr = initializer.__iter__()
                            item = itr.__next__()
                        self.assign_item_from_object(ptr, item)
                        ptr += self.itemsize
                else:
                    raise TypeError("Initializer is not iterable.")
            else:
                memset(self.data, 0, self.len)

    cdef Py_ssize_t fill_contig_strides_array(mdarray self,
                Py_ssize_t *shape, Py_ssize_t *strides, Py_ssize_t stride,
                int ndim, char order) nogil:
        cdef int idx
        if order == 'F':
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
            self.callback_free_data(self.data)
        elif self.free_data:
            free(self.data)
        free(self._strides)
        free(self._shape)
        free(self.items_cache)
        del_struct(&self.formater)
        if self.lock != NULL:
            PyThread_free_lock(self.lock)

    #
    # BUFFER INTERFACE [PEP 3118]
    #

    #@cname('getbuffer')
    def __getbuffer__(self, Py_buffer *info, int flags):
        cdef int bufmode = -1
        if self.mode == b"c":
            bufmode = PyBUF_C_CONTIGUOUS | PyBUF_ANY_CONTIGUOUS
        elif self.mode == b"fortran":
            bufmode = PyBUF_F_CONTIGUOUS | PyBUF_ANY_CONTIGUOUS
        if not (flags & bufmode):
            raise ValueError("Can only create a buffer that is contiguous in memory.")
        info.buf = self.data
        info.len = self.len
        info.ndim = self.ndim
        info.shape = self._shape
        info.strides = self._strides
        info.suboffsets = NULL
        info.itemsize = self.itemsize
        info.readonly = 0
        if flags & PyBUF_FORMAT:
            info.format = self.format
        else:
            info.format = NULL
        info.obj = self
    #__pyx_getbuffer = capsule(<void *> &__pyx_array_getbuffer, "getbuffer(obj, view, flags)")

    #def __releasebuffer__(self):


    property memview:
        #@cname('get_memview')
        def __get__(self):
            # Make this a property as 'self.data' may be set after instantiation
            flags =  PyBUF_ANY_CONTIGUOUS|PyBUF_FORMAT|PyBUF_WRITABLE
            return  memoryview(self, flags, self.dtype_is_object)

    #
    # MEMORY LAYOUT - NUMPY-LIKE INTERFACE
    #

    property base:
        #@cname('get_base')
        def __get__(self):
            return self

    property format:
        #@cname('get__format')
        def __get__(self):
            return self.format

    property shape:
        #@cname('get_shape')
        def __get__(self):
            return tuple([self._shape[i] for i in xrange(self.ndim)])

    property strides:
        #@cname('get_strides')
        def __get__(self):
            return tuple([self._strides[i] for i in xrange(self.ndim)])

    property suboffsets:
        #@cname('get_suboffsets')
        def __get__(self):
            #if self.suboffsets == NULL:
            return [-1] * self.ndim
            #return tuple([self.suboffsets[i] for i in xrange(self.ndim)])

    property ndim:
        #@cname('get_ndim')
        def __get__(self):
            return self.ndim

    property itemsize:
        #@cname('get_itemsize')
        def __get__(self):
            return self.itemsize

    property nbytes:
        #@cname('get_nbytes')
        def __get__(self):
            return self.len

    property size:
        #@cname('get_size')
        def __get__(self):
            return self.len / self.itemsize

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
        if self.ndim >= 1:
            return self._shape[0]
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
            %i in place of %i" % le, self.formater.length)

        if isinstance(value, tuple):
            for i in xrange(le):
                self.get_cnumber_from_PyVal(&self.items_cache[i], value[i], self.formater.formats[i])
        else:
            self.get_cnumber_from_PyVal(&self.items_cache[0], value, self.formater.formats[0])

        struct_pack(&self.formater, itemp, &self.items_cache)


    cdef convert_item_to_object(mdarray self, char *itemp):
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
        """
        if c.ctype == BOOL:
            return c.val.b
        elif c.ctype == INT8:
            return c.val.i8
        elif c.ctype == UINT8:
            return c.val.u8
        elif c.ctype == INT16:
            return c.val.i16
        elif c.ctype == UINT16:
            return c.val.u16
        elif c.ctype == INT32:
            return c.val.i32
        elif c.ctype == UINT32:
            return c.val.u32
        elif c.ctype == INT64:
            return c.val.i64
        elif c.ctype == UINT64:
            return c.val.u64
        elif c.ctype == FLOAT32:
            return c.val.f32
        elif c.ctype == FLOAT64:
            return c.val.f64
        """
        return self.c_to_py[<Py_ssize_t> c.ctype](c)

    #TODO: overflow options
    cdef int get_cnumber_from_PyVal(mdarray self, cnumber *c, object v, num_types n) except -1:
        """
        if n == BOOL:
            c.val.b = PyObject_IsTrue(v)
            c.ctype = BOOL
        elif n == INT8:
            c.val.i8 = get_pylong(v)
            c.ctype = INT8
        elif n == UINT8:
            c.val.u8 = get_pylong(v)
            c.ctype = UINT8
        elif n == INT16:
            c.val.i16 = get_pylong(v)
            c.ctype = INT16
        elif n == UINT16:
            c.val.u16 = get_pylong(v)
            c.ctype = INT16
        elif n == INT32:
            c.val.i32 = get_pylong(v)
            c.ctype = INT32
        elif n == UINT32:
            c.val.u32 = get_pylong(v)
            c.ctype = UINT32
        elif n == INT64:
            c.val.i64 = get_pylong(v)
            c.ctype = INT64
        elif n == UINT64:
            c.val.u64 = get_pylong(v)
            c.ctype = UINT64
        elif n == FLOAT32:
            c.val.f32 = PyFloat_AsDouble(v)
            c.ctype = FLOAT32
        elif n == FLOAT64:
            c.val.f64 = PyFloat_AsDouble(v)
            c.ctype = FLOAT64
        """
        return self.py_to_c[<Py_ssize_t> n](c, v)

    cdef char *get_item_pointer(mdarray self, object index) except NULL:
        cdef Py_ssize_t dim
        cdef char *itemp = self.data
        for dim, idx in enumerate(index):
            itemp = self.pybuffer_index(itemp, idx, dim)
        return itemp

    cdef char *pybuffer_index(mdarray self, char *itemp, Py_ssize_t index,
                              int dim) except NULL:
        cdef char *result
        cdef int offset
        if index < 0:
            index += self.shape[dim]
            if index < 0:
                raise IndexError("Index out of bounds (axis %d)" % dim)
        if index >= self.shape[dim]:
            raise IndexError("Index out of bounds (axis %d)" % dim)
        offset = index * self.strides[dim]
        result = itemp + offset
        return result

    def __getitem__(mdarray self, object index):
        if index is Ellipsis:
            return self.copy()
        have_slices, indices = self._unellipsify(index)
        cdef char *itemp
        if have_slices:
            return self._slice(indices)
        else:
            itemp = self.get_item_pointer(indices)
            return self.convert_item_to_object(itemp)

    def __setitem__(mdarray self, object index, object value):
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
        if not isinstance(obj, mdarray):
            return None
            #try:
            #    obj = memoryview(obj, self.flags|PyBUF_ANY_CONTIGUOUS, None)
            #except TypeError:
            #    return None
        return obj

    cdef setitem_indexed(mdarray self, index, value):
        cdef char *itemp = self.get_item_pointer(index)
        self.assign_item_from_object(itemp, value)

    cdef setitem_slice_assign_scalar(mdarray self, object indices, value):
        cdef slice_view src, dst
        cdef char *ptr_src
        cdef int loop = 1
        cdef int limit, i
        cdef int last_dim_len
        cdef int offset_src, pos = 0
        cdef Py_ssize_t sz = self.itemsize
        cdef Py_ssize_t cursor

        self._slice_view(&src)
        self.get_slice_view(indices, &src, &dst)

        limit = 1
        for i in xrange(dst.ndim):
            limit *= dst.shape[i]

        dim_countdown = [dst.shape[dim] - 1 for dim in xrange(dst.ndim)]
        dim = dst.ndim
        last_dim_len = dst.shape[dst.ndim - 1]

        while loop <= limit:
            cursor = dst.ndim - 1
            for pos in xrange(last_dim_len):
                offset_src = 0
                for i in xrange(dst.ndim):
                    offset_src += dim_countdown[i] * dst.strides[i]
                ptr_src = dst.data + offset_src
                #memcpy(ptr_dest, ptr_src, sz)
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

    cdef get_slice_view(mdarray self, object indices, slice_view *s_view, slice_view *d_view):
        cdef object index
        cdef int dim
        cdef int suboffset_dim = -1
        cdef Py_ssize_t start, stop, step
        cdef bint have_start, have_stop, have_step

        d_view.data = s_view.data
        d_view.ndim = 0
        for i in range(s_view.ndim):
            d_view.suboffsets[i] = -1

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

    cdef _slice_view(mdarray self, slice_view *src):
        src.ndim = self.ndim
        src.data = self.data
        memcpy(src.shape, self._shape, self.ndim * sizeof(Py_ssize_t))
        memcpy(src.strides, self._strides, self.ndim * sizeof(Py_ssize_t))
        for i in range(self.ndim):
            src.suboffsets[i] = -1

    cdef mdarray _slice(mdarray self, object indices):
        cdef int i, dim, new_ndim = 0
        cdef slice_view src, dst
        cdef mdarray sliced
        cdef object tpl

        assert self.ndim > 0

        self._slice_view(&src)
        self.get_slice_view(indices, &src, &dst)

        tpl = tuple([dst.shape[i] for i in xrange(dst.ndim)])
        sliced = mdarray(tpl, self.format, self.mode, allocate_buffer=True)

        cdef char *ptr_dest
        cdef char *ptr_src
        cdef int loop = 1
        cdef int limit = sliced.size
        cdef int last_dim_len = dst.shape[dst.ndim - 1]
        cdef int offset_src, offset_dst, pos = 0
        cdef Py_ssize_t sz = self.itemsize
        cdef Py_ssize_t cursor
        dim_countdown = [dst.shape[dim] - 1 for dim in xrange(dst.ndim)]
        dim = dst.ndim

        while loop <= limit:
            cursor = dst.ndim - 1
            for pos in xrange(last_dim_len):
                offset_src = 0
                offset_dst = 0
                for i in xrange(dst.ndim):
                    offset_dst += dim_countdown[i] * sliced._strides[i]
                    offset_src += dim_countdown[i] * dst.strides[i]
                ptr_src = dst.data + offset_src
                ptr_dest = sliced.data + offset_dst
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

    cdef int do_slice(mdarray self,
            slice_view *dst,
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
                _err_dim(IndexError, "Index out of bounds (axis %d)", dim)
        else:
            # index is a slice
            negative_step = have_step != 0 and step < 0
            if have_step and step == 0:
                _err_dim(ValueError, "Step may not be zero (axis %d)", dim)
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

    def reshape(self):
        raise NotImplementedError

    def resize(self):
        raise NotImplementedError

    def transpose(self):
        raise NotImplementedError

    property T:
        #@cname('transpose')
        def __get__(self):
            raise NotImplementedError
            #cdef _memoryviewslice result = memoryview_copy(self)
            #transpose_memslice(&result.from_slice)
            #return result

    #def swapaxes(self):
    #    raise NotImplementedError

    def flatten(self):
        raise NotImplementedError

    #def squeeze(self):
    #    raise NotImplementedError

    #
    # COPY METHOD
    #

    def copy(mdarray self):
        cdef mdarray copy_a
        cdef char *tp
        copy_a = mdarray(self.shape, self.format, allocate_buffer=True)
        tp = <char*> memcpy(copy_a.data, self.data, self.len)
        if not tp:
            raise MemoryError("Unable to copy data.")
        else:
            copy_a.data = tp
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
        cdef int ndim = self.ndim
        cdef Py_ssize_t *shape = self._shape
        dim_countdown = [shape[dim] - 1 for dim in xrange(ndim)]
        cdef int last_dim_len = shape[ndim - 1]
        cdef int offset, pos = 0
        cdef Py_ssize_t sz = self.itemsize
        cdef Py_ssize_t *strides = self._strides
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
                ptr_datum = self.data + offset
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




# Use 'with gil' functions and avoid 'with gil' blocks, as the code within the blocks
# has temporaries that need the GIL to clean up
#@cname('__pyx_memoryview_err_extents')
#cdef int _err_extents(int i, Py_ssize_t extent1,
#                             Py_ssize_t extent2) except -1 with gil:
#    raise ValueError("got differing extents in dimension %d (got %d and %d)" %
#                                                        (i, extent1, extent2))

#@cname('__pyx_memoryview_err_dim')
cdef int _err_dim(object error, char *msg, int dim) except -1 with gil:
    raise error(msg.decode('ascii') % dim)

#@cname('__pyx_memoryview_err')
#cdef int _err(object error, char *msg) except -1 with gil:
#    if msg != NULL:
#        raise error(msg.decode('ascii'))
#    else:
#        raise error
