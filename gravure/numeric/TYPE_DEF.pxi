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

# BASE FORMATS AVAILABLE
DEF HAVE_BOOL       = 1
DEF HAVE_UINT8      = 1
DEF HAVE_UINT16     = 1
DEF HAVE_UINT32     = 1
DEF HAVE_INT8       = 1
DEF HAVE_INT16      = 1
DEF HAVE_INT32      = 1
DEF HAVE_FLOAT32    = 1
DEF HAVE_FLOAT64    = 1

# PLATFORM DEPENDANT
DEF HAVE_INT64      = 1
DEF HAVE_INT128     = 0
DEF HAVE_INT256     = 0
DEF HAVE_UINT64     = 1
DEF HAVE_UINT128    = 0
DEF HAVE_UINT256    = 0
DEF HAVE_FLOAT16    = 0
DEF HAVE_FLOAT80    = 0
DEF HAVE_FLOAT96    = 0
DEF HAVE_FLOAT128   = 0
DEF HAVE_FLOAT256   = 0
DEF HAVE_COMPLEX32  = 0
DEF HAVE_COMPLEX64  = 0
DEF HAVE_COMPLEX128 = 0
DEF HAVE_COMPLEX160 = 0
DEF HAVE_COMPLEX192 = 0
DEF HAVE_COMPLEX256 = 0
DEF HAVE_COMPLEX512 = 0

#
DEF BASE_FORMATS      = HAVE_BOOL + HAVE_UINT8 + HAVE_UINT16 + HAVE_UINT32 + HAVE_INT8 + \
                        HAVE_INT16 + HAVE_INT32 + HAVE_FLOAT32 + HAVE_FLOAT64

DEF SUPPORTED_FORMATS = BASE_FORMATS + HAVE_INT64 + HAVE_UINT64 + HAVE_INT128 + HAVE_UINT128 + \
                        HAVE_INT256 + HAVE_UINT256 + HAVE_FLOAT16 + HAVE_FLOAT80 + HAVE_FLOAT96 + \
                        HAVE_FLOAT128 + HAVE_FLOAT256 + HAVE_COMPLEX64 +HAVE_COMPLEX128 + \
                        HAVE_COMPLEX160 + HAVE_COMPLEX192 + HAVE_COMPLEX256 + HAVE_COMPLEX512

DEF ALL_FORMATS       = BASE_FORMATS + 18
