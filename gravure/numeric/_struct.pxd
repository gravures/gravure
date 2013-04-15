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

from bit_width_type cimport *

ctypedef enum endianess:
    LITTLE_ENDIAN
    BIG_ENDIAN

ctypedef struct formatdef:
    num_types format
    Py_ssize_t size
    Py_ssize_t alignment
    object unpack(char *p)
    object pack(char *p, object v)

ctypedef struct formatcode:
    formatdef *fmtdef
    Py_ssize_t offset
    Py_ssize_t size

ctypedef struct _struct:
    Py_ssize_t size
    Py_ssize_t length
    formatcode *codes
    object unpack(_struct *, char *)
    int pack(_struct *, char *, object) except -1

cdef int new_struct(_struct *, bytes) except*
cdef void del_struct(_struct *)




