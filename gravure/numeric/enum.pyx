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

@classmethod
def fill_enum_dict(cls):
    cdef Enum e
    for vi in cls.__dict__.items():
        k, v = vi
        if isinstance(v, Enum):
            e = <Enum> v
            cls.__enum_values__[e.real] = k

#NOTE:  BUG quand le type est initialisé avec un int de 64bit
#       la valeur du type devient alors imprevisible !!!
#       et toujours bcp plus grandes, env. 100 millions de X plus.
#       To fix this, making encapsulation of python int value.
cdef class Enum(int):
    register = fill_enum_dict

    def __cinit__(Enum self, v, base=10, *a, **k):
        self.real = v

    def __getattribute__(self, name):
        if name in ('real', '__class__', '__str__', '__repr__', '_notimp', '_get_name_from_val', '__hash__'):
            return object.__getattribute__(self, name)
        else:
            return object.__getattribute__(self.real, name)

    def __add__(x, y):
        if isinstance(x, Enum):
            return x.real.__add__(y.real)
        elif isinstance(y, Enum):
            return y.real.__add__(x.real)

    def __sub__(x, y):
        if isinstance(x, Enum):
            return x.real.__sub__(y.real)
        elif isinstance(y, Enum):
            return y.real.__sub__(x.real)

    def __mul__(x, y):
        if isinstance(x, Enum):
            return x.real.__mul__(y.real)
        elif isinstance(y, Enum):
            return y.real.__mul__(x.real)

    def __div__(x, y):
        if isinstance(x, Enum):
            return x.real.__div__(y.real)
        elif isinstance(y, Enum):
            return y.real.__div__(x.real)

    def __floordiv__(x, y):
        if isinstance(x, Enum):
            return x.real.__floordiv__(y.real)
        elif isinstance(y, Enum):
            return y.real.__floordiv__(x.real)

    def __truediv__(x, y):
        if isinstance(x, Enum):
            return x.real.__truediv__(y.real)
        elif isinstance(y, Enum):
            return y.real.__truediv__(x.real)

    def __mod__(x, y):
        if isinstance(x, Enum):
            return x.real.__mod__(y.real)
        elif isinstance(y, Enum):
            return y.real.__mod__(x.real)

    def __divmod__(x, y):
        if isinstance(x, Enum):
            return x.real.__divmod__(y.real)
        elif isinstance(y, Enum):
            return y.real.__divmod__(x.real)

    def __pow__(x, y, z):
        if isinstance(x, Enum):
            return x.real.__pow__(y.real, z)
        elif isinstance(y, Enum):
            return y.real.__pow__(x.real, z)

    def __neg__(self):
        return self.real.__neg__()

    def __pos__(self):
        return self.real.__pos__()

    def __nonzero__(self):
        return self.real.__nonzero__()

    def __invert__(self):
        return self.real.__nonzero__()

    def __lshift__(x, y):
        if isinstance(x, Enum):
            return x.real.__lshift__(y.real)
        elif isinstance(y, Enum):
            return y.real.__lshift__(x.real)

    def __rshift__(x, y):
        if isinstance(x, Enum):
            return x.real.__rshift__(y.real)
        elif isinstance(y, Enum):
            return y.real.__rshift__(x.real)

    def __and__(x, y):
        if isinstance(x, Enum):
            return x.real.__and__(y.real)
        elif isinstance(y, Enum):
            return y.real.__and__(x.real)

    def __or__(x, y):
        if isinstance(x, Enum):
            return x.real.__or__(y.real)
        elif isinstance(y, Enum):
            return y.real.__or__(x.real)

    def __xor__(x, y):
        if isinstance(x, Enum):
            return x.real.__xor__(y.real)
        elif isinstance(y, Enum):
            return y.real.__xor__(x.real)

    def _notimp(self, *a, **k):
        raise NotImplementedError("Enumeration do not support in place arithmetic.")

    __iadd__ 	    = _notimp
    __isub__ 	    = _notimp
    __imul__ 	    = _notimp
    __idiv__ 	    = _notimp
    __ifloordiv__ = _notimp
    __itruediv__ 	= _notimp
    __imod__ 	    = _notimp
    __ipow__ 	    = _notimp
    __ilshift__ 	 = _notimp
    __irshift__ 	 = _notimp
    __iand__ 	    = _notimp
    __ior__ 	    = _notimp
    __ixor__     = _notimp

    def __richcmp__(x, y, op):
        if op == 0: # x < y
            if isinstance(x, Enum):
                return x.real < y.real
            elif isinstance(y, Enum):
                return y.real > x
        elif op == 2: # x == y
            if isinstance(x, Enum):
                return x.real == y.real
            elif isinstance(y, Enum):
                return y.real == x
        elif op == 4: # x > y
            if isinstance(x, Enum):
                return x.real > y.real
            elif isinstance(y, Enum):
                return y.real < x
        elif op == 1: # x <= y
            if isinstance(x, Enum):
                return x.real <= y.real
            elif isinstance(y, Enum):
                return y.real >= x
        elif op == 3: # x != y
            if isinstance(x, Enum):
                return x.real != y.real
            elif isinstance(y, Enum):
                return y.real != x
        elif op == 5: # x >= y
            if isinstance(x, Enum):
                return x.real >= y.real
            elif isinstance(y, Enum):
                return y.real <= x

    def __int__(self):
        return self.real

    def __long__(self):
        return self.real.__long__()

    def __index__(self):
        return self.real.__index__()

    def __oct__(self):
        return oct(self.real)

    def __hex__(self):
        return hex(self.real)

    def __float__(self):
        return float(self.real)

    def __hash__(self):
        return self.real.__hash__()

    def __repr__(self):
        name = "\'" + self.__class__.__name__ + "\'"
        return "<enum %s of type %s: %i>" % (self._get_name_from_val(self.real), name, self.real)

    def __str__(self):
        return self.__repr__()

    cdef _get_name_from_val(Enum self, val):
        for vi in self.__class__.__enum_values__.items():
            k, v = vi
            if k == val:
                return v
