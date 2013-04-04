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
from struct import Struct

cdef extern from "Python.h":
    int PyIndex_Check(object)
    object PyLong_FromVoidPtr(void *)

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

cdef enum:
    MAX_DIMS = 50

ctypedef struct slice_cache:
    char *data
    Py_ssize_t shape[MAX_DIMS]
    Py_ssize_t strides[MAX_DIMS]
    Py_ssize_t suboffsets[MAX_DIMS]


cdef class mdarray

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


#TODO: DOCSTRING
#TODO: testing infrastructures
cdef class mdarray:
    """Multidimentional array of homogenus type.
    """
    cdef :
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
        bint free_data
        bint dtype_is_object
        PyThread_type_lock lock
        object formater
        _mdarray_iterator iterator

    def __init__(mdarray self, tuple shape, format not None,
                  mode=u"c", initializer=None, bint allocate_buffer=True, *args, **kwargs):
        """Multidimentional constructor.
        """
        pass

    def __cinit__(mdarray self, tuple shape, format not None,
                  mode=u"c", initializer=None, bint allocate_buffer=True, *args, **kwargs):
        cdef int idx
        cdef Py_ssize_t i
        cdef PyObject **p

        self.lock = PyThread_allocate_lock()
        if self.lock == NULL:
            raise MemoryError

        encode = getattr(format, 'encode', None)
        if encode:
            format = encode('ASCII')
        self._format = format
        self.format = self._format
        if format == b'O':
            self.dtype_is_object = True
            self.formater = None
            self.itemsize = sizeof(PyObject*)
        else:
            self.formater = Struct(self.format)
            self.itemsize = self.formater.size

        self.ndim = len(shape)
        if not self.ndim:
            raise ValueError("Empty shape tuple for cython.array")

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

        self.len = self.fill_contig_strides_array(self._shape, self._strides,
                                             self.itemsize, self.ndim, order)

        decode = getattr(mode, 'decode', None)
        if decode:
            mode = decode('ASCII')
        self.mode = mode

        self.free_data = allocate_buffer
        cdef Py_ssize_t it
        cdef char *ptr
        if allocate_buffer:
            self.data = <char *>malloc(self.len)
            if not self.data:
                raise MemoryError("unable to allocate array data.")

            if self.dtype_is_object:
                p = <PyObject **> self.data
                for i in range(self.len / self.itemsize):
                    p[i] = Py_None
                    Py_INCREF(Py_None)

            elif initializer is not None:
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
                        #print "Item ", str(i), " : ", str(item)
                        self.assign_item_from_object(ptr, item)
                        ptr += self.itemsize
                else:
                    raise TypeError("Initializer is not iterable.")


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

    def __dealloc__(mdarray self):
        if self.callback_free_data != NULL:
            self.callback_free_data(self.data)
        elif self.free_data:
            if self.dtype_is_object:
                self.refcount_objects_in_slice(self.data, self._shape,
                                          self._strides, self.ndim, False)
            free(self.data)
        free(self._strides)
        free(self._shape)
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
            return self.len * self.itemsize

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
                self.refcount_objects_in_slice(data, shape + 1, strides + 1, ndim - 1, inc)
            data += strides[0]

    cdef assign_item_from_object(mdarray self, char *itemp, object value):
        cdef char c
        cdef bytes bytesvalue
        cdef Py_ssize_t i
        if isinstance(value, tuple):
            bytesvalue = self.formater.pack(*value)
        else:
            bytesvalue = self.formater.pack(value)
        for i, c in enumerate(bytesvalue):
            itemp[i] = c

    cdef convert_item_to_object(mdarray self, char *itemp):
        cdef bytes bytesvalue
        #TODO: Do a manual and complete check here instead of this easy hack
        bytesvalue = itemp[:self.itemsize]
        result = self.formater.unpack(bytesvalue)
        if len(result) == 1:
            return result[0]
        return result

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
        raise NotImplementedError
        #have_slices, index = _unellipsify(index, self.ndim)
        #if have_slices:
        #    obj = self.is_slice(value)
        #    if obj:
        #        self.setitem_slice_assignment(self[index], obj)
        #    else:
        #        self.setitem_slice_assign_scalar(self[index], value)
        #else:
        #    self.setitem_indexed(index, value)

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

        print "have slices :", str(have_slices) + ", " + str(nslices)
        st = "tuple("
        for i in result:
            st += str(i) + ", "
        st += ")"
        print st
        return have_slices or nslices, tuple(result)

    cdef mdarray _slice(mdarray self, object indices):
        cdef :
            int new_ndim = 0
            int suboffset_dim = -1
            int dim
            bint negative_step
        cdef slice_cache src, dst
        cdef slice_cache *p_src
        cdef slice_cache *p_dest
        cdef Py_ssize_t start, stop, step
        cdef bint have_start, have_stop, have_step
        cdef int i

        assert self.ndim > 0

        src.data = self.data
        memcpy(src.shape, self._shape, self.ndim * sizeof(Py_ssize_t))
        memcpy(src.strides, self._strides, self.ndim * sizeof(Py_ssize_t))

        dst.data = self.data
        p_dst = &dst
        for i in range(self.ndim):
            src.suboffsets[i] = -1
            dst.suboffsets[i] = -1
        p_src = &src
        cdef int *p_suboffset_dim = &suboffset_dim

        for dim, index in enumerate(indices):
            if PyIndex_Check(index):
                self.do_slice(
                    p_dst, p_src.shape[dim], p_src.strides[dim], p_src.suboffsets[dim],
                    dim, new_ndim, p_suboffset_dim,
                    index, 0, 0, # start, stop, step
                    0, 0, 0, # have_{start,stop,step}
                    False)
            elif index is None:
                p_dst.shape[new_ndim] = 1
                p_dst.strides[new_ndim] = 0
                p_dst.suboffsets[new_ndim] = -1
                new_ndim += 1
            else: # index is a slice
                start = index.start or 0
                stop = index.stop or 0
                step = index.step or 0
                have_start = index.start is not None
                have_stop = index.stop is not None
                have_step = index.step is not None
                self.do_slice(
                    p_dst, p_src.shape[dim], p_src.strides[dim], p_src.suboffsets[dim],
                    dim, new_ndim, p_suboffset_dim,
                    start, stop, step,
                    have_start, have_stop, have_step,
                    True)
                new_ndim += 1


        print "\nNew Slice :"
        print "newdim : " + str(new_ndim)
        st = "shape : "
        for i in range(new_ndim):
            st += str(dst.shape[i]) + ", "
        print st
        st = "strides : "
        for i in range(new_ndim):
            st += str(dst.strides[i]) + ", "
        print st
        st = "suboffsets : "
        for i in range(new_ndim):
            st += str(dst.suboffsets[i]) + ", "
        print st
        print "-" * 10


        cdef mdarray sliced
        tpl = tuple([dst.shape[i] for i in xrange(new_ndim)])
        sliced = mdarray(tpl, self.format, self.mode, allocate_buffer=True)

        cdef char *ptr_dest
        cdef char *ptr_src
        cdef int loop = 1
        cdef int limit = sliced.size
        dim_countdown = [dst.shape[dim] - 1 for dim in xrange(new_ndim)]
        dim = new_ndim
        cdef int last_dim_len = dst.shape[new_ndim - 1]
        cdef int offset_src, offset_dst, pos = 0
        cdef Py_ssize_t sz = self.itemsize

        while loop <= limit:
            cursor = new_ndim - 1
            for pos in xrange(last_dim_len):
                offset_src = 0
                offset_dst = 0
                for i in xrange(new_ndim):
                    offset_dst += dim_countdown[i] * sliced._strides[i]
                    offset_src += dim_countdown[i] * dst.strides[i]
                ptr_src = p_dst.data + offset_src
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
            slice_cache *dst,
            Py_ssize_t shape, Py_ssize_t stride, Py_ssize_t suboffset,
            int dim, int new_ndim, int *suboffset_dim,
            Py_ssize_t start, Py_ssize_t stop, Py_ssize_t step,
            int have_start, int have_stop, int have_step,
            bint is_slice) nogil except -1:
        """
        Create a new slice dst given slice src.

        dim             - the current src dimension (indexing will make dimensions
                                                     disappear)
        new_dim         - the new dst dimension
        suboffset_dim   - pointer to a single int initialized to -1 to keep track of
                          where slicing offsets should be added
        """

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
