# Pointer size
cdef extern from "pyport.h":
    ctypedef Py_ssize_t Py_intptr_t
    ctypedef size_t Py_uintptr_t

# Integer types <stdint.h>
cdef extern from "stdint.h" nogil:
    ctypedef   signed char  int8_t
    ctypedef   signed short int16_t
    ctypedef   signed int   int32_t
    ctypedef   signed long  int64_t
    ctypedef unsigned char  uint8_t
    ctypedef unsigned short uint16_t
    ctypedef unsigned int   uint32_t
    ctypedef unsigned long  uint64_t

# Numpy sized type
cdef extern from "numpy/npy_common.h":
    ctypedef signed char      npy_bool

    ctypedef signed char      npy_byte
    ctypedef signed short     npy_short
    ctypedef signed int       npy_int
    ctypedef signed long      npy_long
    ctypedef signed long long npy_longlong

    ctypedef unsigned char      npy_ubyte
    ctypedef unsigned short     npy_ushort
    ctypedef unsigned int       npy_uint
    ctypedef unsigned long      npy_ulong
    ctypedef unsigned long long npy_ulonglong

    ctypedef float        npy_float
    ctypedef double       npy_double
    ctypedef long double  npy_longdouble

    ctypedef signed char        npy_int8
    ctypedef signed short       npy_int16
    ctypedef signed int         npy_int32
    ctypedef signed long long   npy_int64
    ctypedef signed long long   npy_int96
    ctypedef signed long long   npy_int128

    ctypedef unsigned char      npy_uint8
    ctypedef unsigned short     npy_uint16
    ctypedef unsigned int       npy_uint32
    ctypedef unsigned long long npy_uint64
    ctypedef unsigned long long npy_uint96
    ctypedef unsigned long long npy_uint128

    ctypedef float        npy_float32
    ctypedef double       npy_float64
    ctypedef long double  npy_float80
    ctypedef long double  npy_float96
    ctypedef long double  npy_float128

cdef extern from "numpy/npy_common.h":
    cdef enum:
        NPY_INT8
        NPY_INT16
        NPY_INT32
        NPY_INT64
        NPY_INT128
        NPY_INT256
        NPY_UINT8
        NPY_UINT16
        NPY_UINT32
        NPY_UINT64
        NPY_UINT128
        NPY_UINT256
        NPY_FLOAT16
        NPY_FLOAT32
        NPY_FLOAT64
        NPY_FLOAT80
        NPY_FLOAT96
        NPY_FLOAT128
        NPY_FLOAT256
        NPY_COMPLEX32
        NPY_COMPLEX64
        NPY_COMPLEX128
        NPY_COMPLEX160
        NPY_COMPLEX192
        NPY_COMPLEX256
        NPY_COMPLEX512


# SIZED TYPE DEFINITION
ctypedef npy_bool       _bool

ctypedef npy_int8       int8
ctypedef npy_int16      int16
ctypedef npy_int32      int32
ctypedef npy_int64      int64
#IF NPY_INT128:
#   ctypedef npy_int128    int128
#   DEF HAVE_INT128 = 1
DEF HAVE_INT128 = 0

ctypedef npy_uint8      uint8
ctypedef npy_uint16     uint16
ctypedef npy_uint32     uint32
ctypedef npy_uint64     uint64
#IF NPY_UINT128:
#    ctypedef npy_uint128    uint128
#    DEF HAVE_UINT128 = 1
DEF HAVE_UINT128 = 0

ctypedef npy_float32    float32
ctypedef npy_float64    float64
#IF NPY_FLOAT80:
#    ctypedef npy_float80    float80
#    DEF HAVE_FLOAT80 = 1
DEF HAVE_FLOAT80 = 0
#IF NPY_FLOAT128:
ctypedef npy_float128   float128
#    DEF HAVE_FLOAT128 = 1
DEF HAVE_FLOAT128 = 0

ctypedef float complex  complex64
ctypedef double complex complex128

from max_const cimport *

ctypedef enum num_types:
    BOOL,
    INT8,
    INT16,
    INT32,
    INT64,
    INT128,
    UINT8,
    UINT16,
    UINT32,
    UINT64,
    UINT128,
    FLOAT32,
    FLOAT64,
    FLOAT80,
    FLOAT128,
    COMPLEX64,
    COMPLEX128

