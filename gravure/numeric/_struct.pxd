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

ctypedef union unumber:
    _bool       b
    int8        i8
    int16       i16
    int32       i32
    int64       i64
    int128      i128
    int256      i256
    uint8       u8
    uint16      u16
    uint32      u32
    uint64      u64
    uint128     u128
    uint256     u256
    float16     f16
    float32     f32
    float64     f64
    float80     f80
    float96     f96
    float128    f128
    float256    f256
    complex32   c32
    complex64   c64
    complex128  c128
    complex160  c160
    complex192  c192
    complex256  c256
    complex512  c512
    wide        w
    uwide       uw

ctypedef struct cnumber:
    num_types ctype
    unumber val

ctypedef struct formatdef:
    num_types format
    Py_ssize_t size
    Py_ssize_t alignment
    int unpack(char *p, cnumber *)except -1
    void pack(char *p, cnumber *c)

ctypedef struct formatcode:
    formatdef *fmtdef
    Py_ssize_t offset
    Py_ssize_t size

ctypedef struct _struct:
    Py_ssize_t size
    Py_ssize_t length
    formatcode *codes
    num_types *formats
    char *buffer_format

cdef int new_struct(_struct *, bytes) except*
cdef void del_struct(_struct *)
cdef int struct_unpack(_struct *, char *, cnumber **)except -1
cdef int struct_pack(_struct *, char *, cnumber **)




