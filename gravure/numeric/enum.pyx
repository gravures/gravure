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
def fill_enum_dict_2(cls):
    for vi in cls.__dict__.items():
        k, v = vi
        if isinstance(v, Enum):
            cls.__enum_values__[v.__index__()] = k


cdef class Enum(int):
    register = fill_enum_dict_2

    def __repr__(self):
        name = "\'" + self.__class__.__name__ + "\'"
        return "<enum %s of type %s>" % (self._get_name_from_val(self.__index__()), name)

    def __str__(self):
        return self.__repr__()

    cdef _get_name_from_val(self, val):
        for vi in self.__class__.__dict__.items():
            k, v = vi
            if isinstance(v, Enum):
                if v.__index__() == val:
                    return k
