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

#TODO: multidimentional [] method pour acces aux données, a la numpy [tuple]
#TODO: doc du module
#TODO: doc de class __array_interface__
#TODO: regarde le module struct
#TODO: Adapter supplementaires
#TODO: Cython implementation...

__all__ = ['__array_interface__']

from abc import *
from functools import reduce

import pyximport; pyximport.install()
import narray

class __array_interface__(metaclass=ABCMeta):
    """ABC array interface.

    http://docs.scipy.org/doc/numpy/reference/arrays.interface.html#\
__array_interface__

    """

    class __ArrayInterface():
        """A dictionary of items (3 required and 5 optional).

        The optional keys in the dictionary have implied defaults if they are
        not provided.

        The keys are:

        shape (required)

        Tuple whose elements are the array size in each dimension.
        Each entry is an integer (a Python int or long). Note that these
        integers could be larger than the platform “int” or “long” could hold
        (a Python int is a C long). It is up to the code using this attribute
        to handle this appropriately; either by raising an error when
        overflow is possible, or by using Py_LONG_LONG as the C type
        for the shapes.


        typestr (required)

        A string providing the basic type of the homogenous array
        The basic string format consists of 3 parts: a character describing
        the byteorder of the data (<: little-endian, >: big-endian,
        |: not-relevant), a character code giving the basic type of
        the array, and an integer providing the number of bytes the type
        uses. The basic type character codes are:

        t	Bit field (following integer gives the number of bits
            in the bit field).
        b	Boolean (integer type where all values are only True or False)
        i	Integer
        u	Unsigned integer
        f	Floating point
        c	Complex floating point
        O	Object (i.e. the memory contains a pointer to PyObject)
        S	String (fixed-length sequence of char)
        U	Unicode (fixed-length sequence of Py_UNICODE)
        V	Other (void * – each item is a fixed-size chunk of memory)


        descr (optional)

        A list of tuples providing a more detailed description of the memory
        layout for each item in the homogeneous array. Each tuple in the list
        has two or three elements. Normally, this attribute would be used
        when typestr is V[0-9]+, but this is not a requirement.
        The only requirement is that the number of bytes represented in the
        typestr key is the same as the total number of bytes represented
        here. The idea is to support descriptions of C-like structs (records)
        that make up array elements. The elements of each tuple
        in the list are:

        1 A string providing a name associated with this portion of the
          record. This could also be a tuple of ('full name', 'basic_name')
          where basic name would be a valid Python variable name representing
          the full name of the field.
        2 Either a basic-type description string as in typestr or another
          list (for nested records).
        3 An optional shape tuple providing how many times this part of the
          record should be repeated. No repeats are assumed if this is not
          given. Very complicated structures can be described using this
          generic interface. Notice, however, that each element of the array
          is still of the same data-type. Some examples of using this
          interface are given below.

        Default: [('', typestr)]


        data (optional)

        A 2-tuple whose first argument is an integer (a long integer if
        necessary) that points to the data-area storing the array contents.
        This pointer must point to the first element of data (in other words
        any offset is always ignored in this case). The second entry in the
        tuple is a read-only flag (true means the data area is read-only).

        This attribute can also be an object exposing the buffer interface
        which will be used to share the data. If this key is not present
        (or returns None), then memory sharing will be done through the
        buffer interface of the object itself. In this case, the offset key
        can be used to indicate the start of the buffer. A reference to the
        object exposing the array interface must be stored by the new object
        if the memory area is to be secured.

        Default: None


        strides (optional)

        Either None to indicate a C-style contiguous array or a Tuple of
        strides which provides the number of bytes needed to jump to the next
        array element in the corresponding dimension. Each entry must be an
        integer (a Python int or long). As with shape, the values may be
        larger than can be represented by a C “int” or “long”; the calling
        code should handle this appropiately, either by raising an error,
        or by using Py_LONG_LONG in C. The default is None which implies
        a C-style contiguous memory buffer. In this model, the last dimension
        of the array varies the fastest. For example, the default strides
        tuple for an object whose array entries are 8 bytes long and whose
        shape is (10,20,30) would be (4800, 240, 8)

        Default: None (C-style contiguous)


        mask (optional)

        None or an object exposing the array interface. All elements of
        the mask array should be interpreted only as true or not true
        indicating which elements of this array are valid. The shape of this
        object should be “broadcastable” to the shape of the original array.

        Default: None (All array values are valid)


        offset (optional)

        An integer offset into the array data region. This can only be used
        when data is None or returns a buffer object.

        Default: 0.


        version (required)

        An integer showing the version of the interface (i.e. 3 for this
        version). Be careful not to use this to invalidate objects exposing
        future versions of the interface.

        """
        instance_dict = {}
        def __get__(self, instance, cls):
            if instance is not None:
                return self.__class__.instance_dict[id(instance)]
            else :
                return AttributeError()

    __array_interface__ = __ArrayInterface()

    def __new__(cls, *args, **kargs):
        self = super().__new__(cls)
        __array_interface__.__ArrayInterface.instance_dict[id(self)] =\
                        {'shape':NotImplemented,
                         'typestr':NotImplemented,
                         'version':3,
                         'descr':[('', 'typestr')],  #FIXME: typestr
                         'data':None,
                         'strides':None,
                         'mask':None,
                         'offset':0}
        return self

    #TODO: ecrire __del__() method

    @property
    def data(self):
        """Python buffer object pointing to the start of the array’s data.
        """
        return self.__array_interface__['data']

    @property
    def ndim(self):
        """Number of array dimensions.
        """
        return len(self.__array_interface__['shape'])

    @property
    def shape(self):
        """Tuple of integers whose elements are the array size\
in each dimension.
        """
        return self.__array_interface__['shape']

    @property
    def itemsize(self):
        """Length of one array element in bytes.
        """
        return int(self.__array_interface__['typestr'][-1:])

    @property
    def nbytes(self):
        """Total bytes consumed by the elements of the array.

        Does not include memory consumed by non-element attributes
        of the array object. For this use the __sizeof__() method.
        """
        return self.size * self.itemsize

    @property
    def strides(self):
        """Tuple of integers giving the size in bytes to step in each\
dimension when traversing an array.
        """
        return self.__array_interface__['strides']

    @property
    def size(self):
        """Number of elements in the array.
        """
        r = 1
        for e in self.shape:
            r *= e
        return r

    @abstractmethod
    def tolist(self):
        """Return the array as a (possibly nested) list.
        """
        raise NotImplementedError

    def __len__(self):
        return self.shape[0]

    def __str__(self):
        return super().__str__() + "\n" + self.__array_interface__.__str__()

    @abstractmethod
    def __getitem__(self, index):
        raise NotImplementedError

    def __setitem__(self, index, value):
        raise NotImplementedError

    def __delitem__(self, index):
        raise NotImplementedError

    @classmethod
    def __subclasshook__(cls, sbcls):
        if cls is __array_interface__:
            if hasattr(sbcls, '__array_interface__'):
                return True
            else:
                return False
        return NotImplemented


class Adapter(__array_interface__):

    #WARNING: x, c, s, p : not sure it's correct
    _format = {'x':'t',
               'c':'i',
               'b':'i',
               'B':'u',
               '?':'b',
               'h':'i',
               'H':'u',
               'i':'i',
               'I':'u',
               'l':'i',
               'L':'u',
               'q':'i',
               'Q':'u',
               'f':'f',
               'd':'f',
               's':'S',
               'p':'S',
               'P':'V'}

    def __init__(self, o):
        __array_interface__.__init__(self)
        if isinstance(o, memoryview):
            self.__array_interface__['shape'] = o.shape
            typestr = '|' + Adapter._format[o.format] + str(o.itemsize)
            self.__array_interface__['typestr'] = typestr
            self.__array_interface__['strides'] = o.strides
            self.__array_interface__['data'] = o
            self.tolist = o.tolist
        else:
            raise NotImplementedError

    def from_memoryview(self, mem):
        raise NotImplementedError

    def from_list(self):
        raise NotImplementedError

    def tolist(self):
        return None

    def _tuple_to_flat(self, t):
        if isinstance(t, tuple):
            if len(t) <= self.ndim:
                s = self.shape
                return reduce(lambda x, y: x + y * s[t.index(x)], t)
            else:
                raise IndexError('slice with tuple index out of dimension.')
        return t

    def __getitem__(self, index):
        if isinstance(index, tuple):
            if len(index) <= self.ndim:
                index = self._tuple_to_flat(index)
            else:
                raise IndexError('tuple index out of dimension.')
        if isinstance(index, slice):
            index = slice(self._tuple_to_flat(index.start),
                          self._tuple_to_flat(index.stop),
                          self._tuple_to_flat(index.step))
        return self.data[index]



#TODO: nettoyer ça
if __name__ == '__main__':
    import numpy as np
    __array_interface__.register(np.ndarray)
    x = np.array([[1, 2, 3], [4, 5, 6]], np.int32)
    print('numpy ndarray have AI:', isinstance(x, __array_interface__))

    m = memoryview(b'abcd')
    print('memoryview have AI:', isinstance(m, __array_interface__))
    #help(__array_interface__)
    am = Adapter(m)
    print(am)
    print('Adapter have AI:', isinstance(am, __array_interface__))
    print(dir(am))
    print(am.__array_interface__)
    print('am.size:',  am.size)
    print('am.strides:',  am.strides)
    print('am.itemsize:',  am.itemsize)
    print('am.shape:',  am.shape)
    print('am.ndim:',  am.ndim)
    print('am.nbytes', am.nbytes)
    print('am.data', am.data)
    print('len(am)', len(am))
    print('am.tolist():',  am.tolist())
    print('str(am)', str(am))
    print('am[2]:', am[2])
    print('am[1:3]:', am[1:3].tolist())
    print('am[(3,)]:', am[(3,)])
    #tODO: test multidimension index
    #am = Adapter(range(10))
    #help(Adapter)

    # TEST 2D Arrays
    na = narray.n_array(shape=(10, 10))
