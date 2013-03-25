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

from cython.view cimport array
from cython cimport view


cdef class n_array

cdef class n_array:
    """N dimentional array class with __array_interface__.

    """
    cdef array _data
    cdef object __weakref__

    def __cinit__(self, shape, itemsize=sizeof(int), format="i",
                  mode="c", *args, **kwargs):
        self._data = array(shape=shape, itemsize=itemsize,
                           format=format, mode=mode, allocate_buffer=True)
        return self._data


    def get_mv(self):
        cdef int[:, :] mv = self._data
        return mv
