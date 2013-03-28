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

import numpy as np
import array
import timeit

import pyximport; pyximport.install()
import mdarray

mv = mdarray.mdarray((6, 6, 15), 2, b'b', )
print(mv)
print(dir(mv))

print("base :", mv.base)
print("ndim :", mv.ndim)
print("shape :", mv.shape)
print("suboffsets", mv.suboffsets)
print("strides:", mv.strides)
print("itemsize :", mv.itemsize)
print("format :", mv.format, type(mv.format))
print("size :", mv.size)
print("nbytes :", mv.nbytes)
print("len(): ",  len(mv))
print("sizeof :", mv.__sizeof__())
#print("memview :", mv.memview)

print("\n" + "*" * 50)
print("[...] :", mv[...])

print("\n" + "*" * 50)
print("[:] :", mv[:])

print("\n" + "*" * 50)
print("[0:4,1:4] :", mv[0:4,1:4])

print("\n" + "*" * 50)
print("[...,2:6] :", mv[...,2:6])

print("\n" + "*" * 50)
print("[0:4,2] :", mv[0:4, 2])

#print("\n" + "*" * 50)
#print("[0:4,2:18:2,2:10:-1] :", mv[0:4,2:18:-3,2:10:-1])



# None index
#print("\n" + "*" * 50)
#print("[0:4,10:50,None] :", mv[0:4,10:50,None])

print("\n" + "*" * 50)
print("END OF TESTS")



def timearray():
    tests = [["np.ndarray(shape=(100, 100), dtype=np.int8, order='C')", "import numpy as np"],
             ["md.mdarray((100, 100), 1, 'i')", "import pyximport; pyximport.install()\nimport mdarray as md"],
             ["ar.array('b', li)", "import array as ar\nli = [0] * 10000"]]

    for t in tests:
        T = timeit.Timer(*t)
        print(T.timeit(100))
        print(T.timeit(1000))
        print(T.timeit(10000))
        #print(T.timeit(100000))
        print("-" * 50)

#timearray()




