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
    int8    MAX_INT8    = 127
    int8    MIN_INT8    = -128
    uint8   MAX_UINT8   = 255
    int16   MAX_INT16   = 32767
    int16   MIN_INT16   = -32768
    uint16  MAX_UINT16  = 65535
    int32   MAX_INT32   = 2147483647
    int32   MIN_INT32   = - MAX_INT32 - 1
    uint32  MAX_UINT32  = 4294967295#U

IF HAVE_INT64:
    cdef :
        int64   MAX_INT64   = 9223372036854775807#L
        int64   MIN_INT64   = - MAX_INT64 - 1#L
IF HAVE_UINT64:
    cdef :
        uint64  MAX_UINT64  = 18446744073709551615#UL

IF HAVE_INT128:
    cdef :
        int128  MAX_INT128  = 85070591730234615865843651857942052864#LL
        int128  MIN_INT128  = - MAX_INT128 - 1#LL

IF HAVE_UINT128:
    cdef :
        uint128 MAX_UINT128 = 170141183460469231731687303715884105728#ULL

IF HAVE_INT256:
    cdef :
        int256  MAX_INT256  = 57896044618658097711785492504343953926634992332820282019728792003956564819967
        int256  MIN_INT256  = - MAX_INT256 - 1

IF HAVE_UINT256:
    cdef :
        uint256 MAX_UINT256 = 115792089237316195423570985008687907853269984665640564039457584007913129639935

