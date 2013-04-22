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
include "TYPE_DEF.pxi"

cdef :
    int8    MAX_INT8
    int8    MIN_INT8
    uint8   MAX_UINT8
    int16   MAX_INT16
    int16   MIN_INT16
    uint16  MAX_UINT16
    int32   MAX_INT32
    int32   MIN_INT32
    uint32  MAX_UINT32

IF HAVE_INT64:
    cdef :
        int64   MAX_INT64
        int64   MIN_INT64
IF HAVE_UINT64:
    cdef :
        uint64  MAX_UINT64

IF HAVE_INT128:
    cdef :
        int128  MAX_INT128
        int128  MIN_INT128

IF HAVE_UINT128:
    cdef :
        uint128 MAX_UINT128

IF HAVE_INT256:
    cdef :
        int256  MAX_INT256
        int256  MIN_INT256

IF HAVE_UINT256:
    cdef :
        uint256 MAX_UINT256
