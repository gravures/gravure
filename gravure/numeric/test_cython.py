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
import numeric.mdarray as mdarray

mv = mdarray.mdarray((10, 10 ), format=b'>f8', initializer=range(0, 800))
#print(mv
#print(dir(mv))

print("base :", "\n" + str(mv.base))
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
print("[...] :\n", mv[...])

print("\n" + "*" * 50)
print("[:] :\n", mv[:])

print("\n" + "*" * 50)
print("[0:4,1:4] :\n", mv[0:4,1:4])

print("\n" + "*" * 50)
print("[...,2:6] :\n", mv[...,2:6])

print("\n" + "*" * 50)
print("[0:4,2] :\n", mv[0:4, 2])

print("\n" + "*" * 50)
print("[0:4,-5] :\n", mv[0:4, -7])

print("\n" + "*" * 50)
print("[2:8:2,2:10:-1] :\n", mv[8:2:-2,4:2:-1])

print("\n" + "*" * 50)
print("[2] :\n", mv[2])

print("\n" + "*" * 50)
print("[4,4] :\n", mv[4, 4])

print("\n" + "*" * 50)
print("memoryview(mv):", memoryview(mv))
print("memoryview(mv).shape:", memoryview(mv).shape)
print("memoryview(mv).ndim:", memoryview(mv).ndim)
print("memoryview(mv).format:", memoryview(mv).format)

# buggy
#print("memoryview(mv)[22]:", memoryview(mv)[22])
#print("memoryview(mv).tolist():", memoryview(mv).tolist())

# None index
#print("\n" + "*" * 50)
#print("[0:4,10:50,None] :", mv[0:4,10:50,None])

# Iterator
print("\n" + "*" * 50)
print("for i in mv:\n")
for i, v in enumerate(mv):
    print (i, "#", v)



#print("\n" + "*" * 50)
#help(mv)


print("\n" + "*" * 50)
print("TIME IT TESTS")

def timearray():
    tests = [["np.ndarray(shape=(100, 100), dtype=np.float64, order='C')", "import numpy as np"],
             ["md.mdarray((100, 100), format=b'f8')", "import pyximport; pyximport.install()\nimport numeric.mdarray as md"],
             ["ar.array('b', li)", "import array as ar\nli = [0] * 10000"]]

    for t in tests:
        T = timeit.Timer(*t)
        print(T.timeit(100))
        print(T.timeit(1000))
        #print(T.timeit(10000))
        #print(T.timeit(100000))
        print("-" * 50)

timearray()

print("\n" + "*" * 50)
print("END OF TESTS")

#mv = mdarray.mdarray((10, 10 ), format=b'H2', initializer=range(400, 800))
#print (mv)

