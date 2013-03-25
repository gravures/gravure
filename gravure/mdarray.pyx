#!/usr/bin/python
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
    ctypedef Py_ssize_t Py_intptr_t
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


cdef extern from "stdlib.h":
    void *malloc(size_t) nogil
    void free(void *) nogil
    void *memcpy(void *dest, void *src, size_t n) nogil


cdef class mdarray:

    cdef:
        char *data
        Py_ssize_t len
        char *format
        int ndim
        Py_ssize_t *_shape
        Py_ssize_t *_strides
        Py_ssize_t itemsize
        unicode mode
        bytes _format
        void (*callback_free_data)(void *data)
        # cdef object _memview
        bint free_data
        bint dtype_is_object
        PyThread_type_lock lock


    def __cinit__(mdarray self, tuple shape, Py_ssize_t itemsize, format not None,
                  mode=u"c", bint allocate_buffer=True):
        cdef int idx
        cdef Py_ssize_t i
        cdef PyObject **p

        self.lock = PyThread_allocate_lock()
        if self.lock == NULL:
            raise MemoryError

        self.ndim = len(shape)
        self.itemsize = itemsize

        if not self.ndim:
            raise ValueError("Empty shape tuple for cython.array")
        if self.itemsize <= 0:
            raise ValueError("itemsize <= 0 for cython.array")

        encode = getattr(format, 'encode', None)
        if encode:
            format = encode('ASCII')
        self._format = format
        self.format = self._format

        self._shape = <Py_ssize_t *> malloc(sizeof(Py_ssize_t)*self.ndim)
        self._strides = <Py_ssize_t *> malloc(sizeof(Py_ssize_t)*self.ndim)
        if not self._shape or not self._strides:
            free(self._shape)
            free(self._strides)
            raise MemoryError("unable to allocate shape or strides.")

        idx = 0
        for idx, dim in enumerate(shape):
            if dim <= 0:
                raise ValueError("Invalid shape in axis %d: %d." % (idx, dim))
            self._shape[idx] = dim
            idx += 1

        if mode not in ("fortran", "c"):
            raise ValueError("Invalid mode, expected 'c' or 'fortran', got %s" % mode)

        cdef char order
        if mode == 'fortran':
            order = 'F'
        else:
            order = 'C'

        self.len = fill_contig_strides_array(self._shape, self._strides,
                                             itemsize, self.ndim, order)

        decode = getattr(mode, 'decode', None)
        if decode:
            mode = decode('ASCII')
        self.mode = mode

        self.free_data = allocate_buffer
        self.dtype_is_object = format == b'O'
        if allocate_buffer:
            self.data = <char *>malloc(self.len)
            if not self.data:
                raise MemoryError("unable to allocate array data.")

            if self.dtype_is_object:
                p = <PyObject **> self.data
                for i in range(self.len / itemsize):
                    p[i] = Py_None
                    Py_INCREF(Py_None)

    cdef Py_ssize_t fill_contig_strides_array(mdarray self,
                Py_ssize_t *shape, Py_ssize_t *strides, Py_ssize_t stride,
                int ndim, char order) nogil:
        """
        Fill the strides array for a slice with C or F contiguous strides.
        This is like PyBuffer_FillContiguousStrides, but compatible with py < 2.6
        """
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

    @cname('getbuffer')
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

    __pyx_getbuffer = capsule(<void *> &__pyx_array_getbuffer, "getbuffer(obj, view, flags)")

    def __dealloc__(mdarray self):
        if self.callback_free_data != NULL:
            self.callback_free_data(self.data)
        elif self.free_data:
            if self.dtype_is_object:
                refcount_objects_in_slice(self.data, self._shape,
                                          self._strides, self.ndim, False)
            free(self.data)
        free(self._strides)
        free(self._shape)
        if self.lock != NULL:
            PyThread_free_lock(self.lock)

    cdef void refcount_objects_in_slice(mdarray self, char *data, Py_ssize_t *shape,
                                    Py_ssize_t *strides, int ndim, bint inc):
        cdef Py_ssize_t i
        for i in range(shape[0]):
            if ndim == 1:
                if inc:
                    Py_INCREF((<PyObject **> data)[0])
                else:
                    Py_DECREF((<PyObject **> data)[0])
            else:
                refcount_objects_in_slice(data, shape + 1, strides + 1,
                                          ndim - 1, inc)
            data += strides[0]

    property memview:
        @cname('get_memview')
        def __get__(self):
            # Make this a property as 'self.data' may be set after instantiation
            flags =  PyBUF_ANY_CONTIGUOUS|PyBUF_FORMAT|PyBUF_WRITABLE
            return  memoryview(self, flags, self.dtype_is_object)

    property T:
        @cname('__pyx_memoryview_transpose')
        def __get__(self):
            cdef _memoryviewslice result = memoryview_copy(self)
            transpose_memslice(&result.from_slice)
            return result

    property base:
        @cname('__pyx_memoryview__get__base')
        def __get__(self):
            return self

    property shape:
        @cname('__pyx_memoryview_get_shape')
        def __get__(self):
            return tuple([self._shape[i] for i in xrange(self.ndim)])

    property strides:
        @cname('__pyx_memoryview_get_strides')
        def __get__(self):
            return tuple([self._strides[i] for i in xrange(self.ndim)])

    property suboffsets:
        @cname('__pyx_memoryview_get_suboffsets')
        def __get__(self):
            #if self.suboffsets == NULL:
            return [-1] * self.ndim
            #return tuple([self.suboffsets[i] for i in xrange(self.ndim)])

    property ndim:
        @cname('__pyx_memoryview_get_ndim')
        def __get__(self):
            return self.ndim

    property itemsize:
        @cname('__pyx_memoryview_get_itemsize')
        def __get__(self):
            return self.itemsize

    property nbytes:
        @cname('__pyx_memoryview_get_nbytes')
        def __get__(self):
            return self.len * self.itemsize

    property size:
        @cname('__pyx_memoryview_get_size')
        def __get__(self):
            return self.len

    def __len__(self):
        if self.ndim >= 1:
            return self._shape[0]
        return 0

    cdef char *get_item_pointer(mdarray self, object index) except NULL:
        cdef Py_ssize_t dim
        cdef char *itemp = <char *> self.data
        for dim, idx in enumerate(index):
            itemp = self.pybuffer_index(&self.data, itemp, idx, dim)
        return itemp

    cdef char *pybuffer_index(mdarray self, char *bufp, Py_ssize_t index,
                              int dim) except NULL:
        cdef Py_ssize_t shape, stride, suboffset = -1
        cdef Py_ssize_t itemsize = self.itemsize
        cdef char *resultp

        if view.ndim == 0:
            shape = self.len / itemsize
            stride = itemsize
        else:
            shape = self.shape[dim]
            stride = self.strides[dim]
            #if self.suboffsets != NULL:
            #    suboffset = self.suboffsets[dim]

        if index < 0:
            index += self.shape[dim]
            if index < 0:
                raise IndexError("Out of bounds on buffer access (axis %d)" % dim)
        if index >= shape:
            raise IndexError("Out of bounds on buffer access (axis %d)" % dim)

        resultp = bufp + index * stride
        #if suboffset >= 0:
        #    resultp = (<char **> resultp)[0] + suboffset
        return resultp

    def __getitem__(mdarray self, object index):
        if index is Ellipsis:
            return self  #FIXME: c'est ce qu'on veut ?
        have_slices, indices = _unellipsify(index, self.ndim)
        cdef char *itemp
        if have_slices:
            return memview_slice(self, indices)  #FIXME: c'est ce qu'on veut ?
        else:
            itemp = self.get_item_pointer(indices)
            return self.convert_item_to_object(itemp) #FIXME: c'est ce qu'on veut ?

    def __setitem__(mdarray self, object index, object value):
        have_slices, index = _unellipsify(index, self.ndim)
        if have_slices:
            obj = self.is_slice(value)
            if obj:
                self.setitem_slice_assignment(self[index], obj)
            else:
                self.setitem_slice_assign_scalar(self[index], value)
        else:
            self.setitem_indexed(index, value)





