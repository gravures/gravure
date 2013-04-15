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


cdef :
    char MAX_INT8
    char MIN_INT8
    unsigned char MAX_UINT8
    short MAX_INT16
    short MIN_INT16
    unsigned short MAX_UINT16
    int MAX_INT32
    int MIN_INT32
    unsigned int MAX_UINT32
    long MAX_INT64
    long MIN_INT64
    unsigned long MAX_UINT64
    object MAX_INT128
    object MIN_INT128
    object MAX_UINT128
    #sunsigned long long MAX_UINT128 = 170141183460469231731687303715884105728ULL
    #MAX_INT256 = 57896044618658097711785492504343953926634992332820282019728792003956564819967
    #MIN_INT256 = - MAX_INT256 - 1
    #MAX_UINT256 = 115792089237316195423570985008687907853269984665640564039457584007913129639935
