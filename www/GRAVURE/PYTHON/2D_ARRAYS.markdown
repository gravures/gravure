# 2D ARRAYS AND NUMBERS
Created mercredi 20 mars 2013


### CYTHON CEP
<http://wiki.cython.org/enhancements/array>
<http://docs.cython.org/src/userguide/memoryviews.html>

<https://groups.google.com/forum/?fromgroups=#!topic/cython-users/CwtU_jYADgM>
cython.view is a fake module. The cython array implementation and
other things can be found in Cython/Utility/MemoryView.pyx.

The reason it is slow is because no one ever cared to optimize it. It
allocates shape and strides independently on the heap. So it contains
at least 3 malloc calls, and a bunch of other code.

If you want to make it really fast, implement it with a free list,
only malloc the data and make sure the code in the constructor is
native where possible. No one is actively working on it, but it's just
Cython code, so patches would be appreciated and merged. 


### CARRAYS
<https://github.com/FrancescAlted/carray>
<https://pypi.python.org/pypi/carray/0.5.1>


### CDECIMAL
<http://www.bytereef.org/mpdecimal/index.html>

store decimal number as bytes in a c buffer.
value for decimal are store as four variable:

a python string **_int** = string of length context.prec (default = 28)	→  unsigned int with n bytes = int(d._int).bit_length() // 8
or a bytes of same length : a struct format = "n**c**"
a python int **_exp** = an signed int (-_int.__len__(), int.__len()) 		→ signed int 8 or 16 bits length (prec > 126)
a python int **_sign **= (0,1)								→ c bool
a python boolean **_is_special **= (True, Fale)					→ c bool 






