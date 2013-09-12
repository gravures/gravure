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

# SIZED TYPE DEFINITION
include "TYPE_DEF.pxi"

# look-up table for classification of types
#
cdef int types_class[ALL_FORMATS]
types_class[<int> BOOL]    = -1

types_class[<int> UINT8]    = 0
types_class[<int> UINT16]   = 0
types_class[<int> UINT32]   = 0
types_class[<int> UINT64]   = 0
types_class[<int> UINT128]  = 0
types_class[<int> UINT256]  = 0

types_class[<int> INT8]     = 1
types_class[<int> INT16]    = 1
types_class[<int> INT32]    = 1
types_class[<int> INT64]    = 1
types_class[<int> INT128]   = 1
types_class[<int> INT256]   = 1

types_class[<int> FLOAT16]  = 2
types_class[<int> FLOAT32]  = 2
types_class[<int> FLOAT64]  = 2
types_class[<int> FLOAT80]  = 2
types_class[<int> FLOAT96]  = 2
types_class[<int> FLOAT128] = 2
types_class[<int> FLOAT256] = 2

types_class[<int> COMPLEX32]  = 3
types_class[<int> COMPLEX64]  = 3
types_class[<int> COMPLEX128] = 3
types_class[<int> COMPLEX160] = 3
types_class[<int> COMPLEX192] = 3
types_class[<int> COMPLEX256] = 3
types_class[<int> COMPLEX512] = 3

# look-up table for availability of types
#
cdef int have_type[ALL_FORMATS]
have_type[<int> BOOL]     = HAVE_BOOL

have_type[<int> UINT8]    = HAVE_UINT8
have_type[<int> UINT16]   = HAVE_UINT16
have_type[<int> UINT32]   = HAVE_UINT32
have_type[<int> UINT64]   = HAVE_UINT64
have_type[<int> UINT128]  = HAVE_UINT128
have_type[<int> UINT256]  = HAVE_UINT256

have_type[<int> INT8]     = HAVE_INT8
have_type[<int> INT16]    = HAVE_INT16
have_type[<int> INT32]    = HAVE_INT32
have_type[<int> INT64]    = HAVE_INT64
have_type[<int> INT128]   = HAVE_INT128
have_type[<int> INT256]   = HAVE_INT256

have_type[<int> FLOAT16]  = HAVE_FLOAT16
have_type[<int> FLOAT32]  = HAVE_FLOAT32
have_type[<int> FLOAT64]  = HAVE_FLOAT64
have_type[<int> FLOAT80]  = HAVE_FLOAT80
have_type[<int> FLOAT96]  = HAVE_FLOAT96
have_type[<int> FLOAT128] = HAVE_FLOAT128
have_type[<int> FLOAT256] = HAVE_FLOAT256

have_type[<int> COMPLEX32]  = HAVE_COMPLEX32
have_type[<int> COMPLEX64]  = HAVE_COMPLEX64
have_type[<int> COMPLEX128] = HAVE_COMPLEX128
have_type[<int> COMPLEX160] = HAVE_COMPLEX160
have_type[<int> COMPLEX192] = HAVE_COMPLEX192
have_type[<int> COMPLEX256] = HAVE_COMPLEX256
have_type[<int> COMPLEX512] = HAVE_COMPLEX512

# look-up table for types promotions rules
#
cdef num_types types_promotion[ALL_FORMATS -7][4]
#########             NUM_TYPE         CLASS_1       CLASS_2       CLASS_3       CLASS_4    #
#########                              UINT(S)       INT(S)        FLOAT(S)      COMPLEX    #
types_promotion[<int> BOOL][:]       = [UINT8       , INT8        , FLOAT16     , COMPLEX32]

types_promotion[<int> UINT8][:]      = [UINT8       , INT16       , FLOAT16     , COMPLEX32]
types_promotion[<int> UINT16][:]     = [UINT16      , INT32       , FLOAT32     , COMPLEX32]
types_promotion[<int> UINT32][:]     = [UINT32      , INT64       , FLOAT64     , COMPLEX64]
types_promotion[<int> UINT64][:]     = [UINT64      , INT128      , FLOAT128    , COMPLEX128]
types_promotion[<int> UINT128][:]    = [UINT128     , INT256      , FLOAT256    , COMPLEX256]
types_promotion[<int> UINT256][:]    = [UINT256     , FLOAT256    , FLOAT256    , COMPLEX512]

types_promotion[<int> INT8][:]       = [INT8        , INT8        , FLOAT16     , COMPLEX32]
types_promotion[<int> INT16][:]      = [INT16       , INT16       , FLOAT32     , COMPLEX32]
types_promotion[<int> INT32][:]      = [INT32       , INT32       , FLOAT64     , COMPLEX64]
types_promotion[<int> INT64][:]      = [INT64       , INT64       , FLOAT128    , COMPLEX128]
types_promotion[<int> INT128][:]     = [INT128      , INT128      , FLOAT256    , COMPLEX256]
types_promotion[<int> INT256][:]     = [INT256      , INT256      , FLOAT256    , COMPLEX512]

types_promotion[<int> FLOAT16][:]    = [FLOAT16     , FLOAT16     , FLOAT16     , COMPLEX32]
types_promotion[<int> FLOAT32][:]    = [FLOAT32     , FLOAT32     , FLOAT32     , COMPLEX64]
types_promotion[<int> FLOAT64][:]    = [FLOAT64     , FLOAT64     , FLOAT64     , COMPLEX128]
types_promotion[<int> FLOAT80][:]    = [FLOAT80     , FLOAT80     , FLOAT80     , COMPLEX192]
types_promotion[<int> FLOAT96][:]    = [FLOAT96     , FLOAT96     , FLOAT96     , COMPLEX192]
types_promotion[<int> FLOAT128][:]   = [FLOAT128    , FLOAT128    , FLOAT128    , COMPLEX256]
types_promotion[<int> FLOAT256][:]   = [FLOAT256    , FLOAT256    , FLOAT256    , COMPLEX512]


# ALTER THE PROMOTION LOOK UP TABLE WITH AVAILABLE TYPE
cdef int i, j
cdef num_types latest
for j in xrange(4):
    for i in xrange(ALL_FORMATS - 7):
        if not have_type[<int> types_promotion[i][j]]:
            if j == 1:
                if have_type[<int> types_promotion[i][j+1]]:
                    types_promotion[i][j] = types_promotion[i][j+1]
                elif have_type[<int> types_promotion[i-1][j+1]]:
                    types_promotion[i][j] = types_promotion[i-1][j+1]
                else:
                    types_promotion[i][j] = types_promotion[i-1][j]
                latest = types_promotion[i][j]
                continue
            else:
                types_promotion[i][j] = latest
                latest = types_promotion[i][j]
            continue
        latest = types_promotion[i][j]

cdef void sort_types(num_types na, num_types nb, num_types* pa, num_types* pb) nogil:
    if na > nb :
        pa[0] = nb
        pb[0] = na


cdef num_types get_promotion(num_types na, num_types nb) nogil:
    cdef num_types promo
    with nogil:
        if na == nb:
            return na

        sort_types(na, nb, &na, &nb)
        if types_class[<int> na] == types_class[<int> nb]:
            return nb

        promo = types_promotion[<int> na][(types_class[<int> na] \
                if types_class[<int> na] > types_class[<int> nb] \
                else types_class[<int> nb])]
        if promo > nb:
            return promo
        else:
            return nb
