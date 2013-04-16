===============================
Numeric multi dimentional array
===============================

homogeneous array

(peut remplacer un numpy array)

peut servir a construire un ndarray

implemente __array_interface__

n'est pas dépendant du paquet numpy

implemente new buffer protocol



différence avec ndarray
-----------------------

slicing renvoie un array pas une view
None pas une valeur possible pour getitem
pas de shape null : md.shape[n] = 0
overflow error detection
basic numeric scalar type only


scalar array type
-----------------

TYPE RESTRICTED TO NUMBERS.

bytes width type:
bool, int8, uint8, int16, uint16, int32, uint32, int64,
uint64, float32, float64, (float128, complex64, complex128)

special type:
accepte Decimal comme type basic

bit width type:
int1, int2, int4, int12,
uint1, uint2, uint4, uint12


overflow
--------

parametric overflow treatement
raise overflow error

format specification
--------------------

=: Host-endian
<: little-endian,
>: big-endian,
|: not-relevant

+---+----------------------------------------------------------------+
| b | Boolean (integer type where all values are only True or False) |
| i | Integer                                                        |
| u | Unsigned integer                                               |
| f | Floating point                                                 |
| c | Complex floating point                                         |
+---+----------------------------------------------------------------+
|               SPECIAL TYPES                                        |
+---+----------------------------------------------------------------+
| D | Decimal Number                                                 |
| B | bit (following integer gives the number of bits)               |
+---+----------------------------------------------------------------+

Math & processing
-----------------


