# CHANGES IN PYTHON 3
Created samedi 09 mars 2013


#### STRING

* The type used to hold text is str, the type used to hold data is bytes.
* You can no longer use u"..." literals for Unicode text. However, you must use b"..." literals for binary data.
* Like str, the bytes type is immutable. There is a separate mutable type to hold buffered binary data, bytearray.
* The built-in basestring abstract type was removed. Use str instead. The str and bytes types don’t have functionality enough in common to warrant a shared base class. 
* The initial values of sys.stdin, sys.stdout and sys.stderr are now unicode-only text files (i.e., they are instances of io.TextIOBase). To read and write bytes data with these streams, you need to use their io.TextIOBase.buffer attribute.
* Filenames are passed to and returned from APIs as (Unicode) strings. 
* Some system APIs like os.environ and sys.argv can also present problems when the bytes made available by the system is not interpretable using the default encoding. Setting the LANG variable and rerunning the program is probably the best approach.
* The repr() of a string no longer escapes non-ASCII characters. 
* The default source encoding is now UTF-8.
* The StringIO and cStringIO modules are gone. Instead, import the io module and use io.StringIO or io.BytesIO for text and data respectively.
* Bytes literals are introduced with a leading b
* string.letters and its friends (string.lowercase and string.uppercase) are gone. Use string.ascii_letters etc. instead. (The reason for the removal is that string.letters and friends had locale-specific behavior, which is a bad idea for such attractively-named global “constants”.)
* The string.maketrans() function is deprecated and is replaced by new static methods, bytes.maketrans() and bytearray.maketrans().



#### PRINT

* print is a function
* use format() instead %
* The built-in format() function and the str.format() method use a mini-language that now includes a simple, non-locale aware way to format a number with a thousands separator.
* The fields in format() strings can now be automatically numbered:
* String formatting for format() and str.format() gained new capabilities for the format character #.
* There is also a new str.format_map() method that extends the capabilities of the existing str.format()



#### NUMBERS

* long renamed to int. That is, there is only one built-in integral type
* An expression like 1/2 returns a float. Use 1//2 to get the truncating behavior.
* All text is Unicode
* The round() function rounding strategy and return type have changed. Exact halfway cases are now rounded to the nearest even result instead of away from zero.
* round(x, n) now returns an integer if x is an integer. Previously it returned a float:
* The int() type gained a bit_length method that returns the number of bits necessary to represent its argument in binary:
* Python now uses David Gay’s algorithm for finding the shortest floating point representation that doesn’t change its value. This should help mitigate some of the confusion surrounding binary floating point numbers.
* The decimal module now supports methods for creating a decimal object from a binary float. The conversion is exact but can sometimes be surprising:
* The str() of a float or complex number is now the same as its repr()
* The math module has been updated with six new functions inspired by the C99 standard.
* Mark Dickinson crafted an elegant and efficient scheme for assuring that different numeric datatypes will have the same hash value whenever their actual values are equal. Some of the hashing details are exposed through a new attribute, sys.hash_info, which describes the bit width of the hash value, the prime modulus 
* The integer methods in the random module now do a better job of producing uniform distributions.



#### COMAPRAISON & ORDERING

* The ordering comparison operators (<, <=, >=, >) raise a TypeError exception
* builtin.sorted() and list.sort() no longer accept the cmp argument
* The cmp() function and __comp__() method should be treated as gone
* != now returns the opposite of ==, unless == returns NotImplemented.
* The __oct__() and __hex__() special methods are removed – oct() and hex() use __index__() now to convert the argument to an integer.
* __nonzero__() is now __bool__().
* To help write classes with rich comparison methods, a new decorator functools.total_ordering() will use a existing equality and inequality methods to fill in the remaining methods.
* To aid in porting programs from Python 2, the functools.cmp_to_key() function converts an old-style comparison function to modern key function:
* The collections.Counter class now has two forms of in-place subtraction, the existing -= operator for saturating subtraction and the new subtract() method for regular subtraction. The former is suitable for multisets which only have positive counts, and the latter is more suitable for use cases that allow negative counts:



#### VIEWS & ITERATORS

* Views And Iterators Instead Of Lists, Some well-known APIs no longer return lists
* range() now behaves like xrange()
* range objects now support index and count methods. This is part of an effort to make more objects fully implement the collections.Sequence abstract base class. As a result, the language will have a more uniform API. In addition, range objects now support slicing and negative indices, even with values larger than sys.maxsize. This makes range more interoperable with lists:



#### ITERABLE

* PEP 3132: Extended Iterable Unpacking. You can now write things like a, b, *rest = some_sequence.
* List comprehensions,  Use [... for var in (item1, item2, ...)]
* Set literals, e.g. {1, 2}.
* __getslice__(), __setslice__() and __delslice__() were killed.
* PEP 3114: the standard next() method has been renamed to __next__().
* A new built-in function next() was added to call the __next__() method on an object.
* Cleanup of the array.array type: the read() and write() methods are gone; use fromfile() and tofile() instead. Also, the 'c' typecode for array is gone – use either 'b' for bytes or 'u' for Unicode characters.
* Removed. dict.has_key() – use the in operator instead.
* a new collections.OrderedDict class has been introduced. The OrderedDict API is substantially the same as regular dictionaries but will iterate over keys and values in a guaranteed order depending on when a key was first inserted.
* The collections.OrderedDict class has a new method move_to_end() which takes an existing key and moves it to either the first or last position in the ordered sequence.
* Added a collections.Counter class to support convenient counting of unique items in a sequence or iterable:
* The itertools module grew two new functions. The itertools.combinations_with_replacement() function is one of four for generating combinatorics including permutations and Cartesian products. The itertools.compress() function mimics its namesake from APL. Also, the existing itertools.count() function now has an optional step argument and can accept any type of counting sequence including fractions.Fraction and decimal.Decimal:
* collections.namedtuple() now supports a keyword argument 
* The hasattr() function works by calling getattr() and detecting whether an exception is raised. This technique allows it to detect methods created dynamically by __getattr__() or __getattribute__() which would otherwise be absent from the class dictionary. Formerly,
* The itertools module has a new accumulate() function modeled on APL’s scan operator and Numpy’s accumulate function
* When writing a __repr__() method for a custom container, it is easy to forget to handle the case where a member refers back to the container itself. To help write such __repr__() methods, the reprlib module has a new decorator, recursive_repr(), for detecting recursive calls to __repr__() and substituting a placeholder string instead



#### CLASS

* Classic classes are gone.
* PEP 3115: New Metaclass Syntax.
* The concept of “unbound methods” has been removed from the language.
* Removed support for __members__ and __methods__.
* PEP 3135: New super(). You can now invoke super()
* The abc module now supports abstractclassmethod() and abstractstaticmethod().These tools make it possible to define an abstract base class that requires a particular classmethod() or staticmethod() to be implemented:



#### FUNCTION

* PEP 3107: Function argument and return value annotations.
* Keyword arguments are allowed after the list of base classes in a class definition.
* PEP 3104: nonlocal statement.
* Removed callable(). Instead of callable(f) you can use isinstance(f, collections.Callable). The operator.isCallable() function is also gone.
* Removed reduce(). Use functools.reduce() if you really need it; 
* The callable() builtin function from Py2.x was resurrected. It provides a concise, readable alternative to using an abstract base class in an expression like isinstance(x, collections.Callable).
* The functools module includes a new decorator for caching function calls. functools.lru_cache() can save repeated queries to an external resource whenever the results are expected to be the same.
* The functools.wraps() decorator now adds a __wrapped__ attribute pointing to the original callable function.



#### LANGUAGE

* Change from except exc, var to except exc as var. See PEP 3110.
* The ellipsis (...) can be used as an atomic expression anywhere.
* Removed keyword: exec() is no longer a keyword; it remains as a function.
* exec() no longer takes a stream argument; instead of exec(f) you can use exec(f.read()).
* Removed: apply(). Instead of apply(f, args) use f(*args).
* Removed coerce().
* The syntax of the with statement now allows multiple context managers in a single statement.
* PEP 3147: PYC Repository Directories
* PEP 3149: ABI Version Tagged .so Files
* The interpreter can now be started with a quiet option, -q,
* The internal structsequence tool now creates subclasses of tuple. This means that C structures like those returned by os.stat(), time.gmtime(), and sys.version_info now work like a named tuple and now work with functions and methods that expect a tuple as an argument.
* Warnings are now easier to control using the PYTHONWARNINGS environment variable as an alternative to using -W at the command line.
* A new warning category, ResourceWarning, has been added. It is emitted when potential issues with resource consumption or cleanup are detected. It is silenced by default in normal release builds but can be enabled through the means provided by the warnings module, or on the command line.



#### FILE

* Removed the file type. Use open(). There are now several different kinds of streams that open can return in the io module.
* PEP 3111: raw_input() was renamed to input(). That is, the new input() function reads a line from sys.stdin and returns it with the trailing newline stripped. It raises EOFError if the input is terminated prematurely. To get the old behavior of input(), use eval(input()). 
* Removed execfile(). Instead of execfile(fn) use exec(open(fn).read()).
* The functions os.tmpnam(), os.tempnam() and os.tmpfile() have been removed in favor of the tempfile module.
* The os.popen() and subprocess.Popen() functions now support with statements for auto-closing of the file descriptors.
* The select module now exposes a new, constant attribute, PIPE_BUF, which gives the minimum number of bytes which are guaranteed not to block when select.select() says a pipe is ready for writing.
* gzip.GzipFile now implements the io.BufferedIOBase abstract base class (except for truncate()). It also has a peek() method and supports unseekable as well as zero-padded file objects.
* Different operating systems use various encodings for filenames and environment variables. The os module provides two new functions, fsencode() and fsdecode(), for encoding and decoding filenames. Some operating systems allow direct access to encoded bytes in the environment. If so, the os.supports_bytes_environ constant will be true. For direct access to encoded environment variables (if available), use the new os.getenvb() function or use os.environb which is a bytes version of os.environ.
* The shutil.copytree() function has two new options: ignore_dangling_symlinks, copy_function
* In addition, the shutil module now supports archiving operations for zipfiles, uncompressed tarfiles, gzipped tarfiles, and bzipped tarfiles. And there are functions for registering additional archiving file formats (such as xz compressed tarfiles or custom formats).
* The tempfile module has a new context manager, TemporaryDirectory which provides easy deterministic cleanup of temporary directories
* bytearray objects can no longer be used as filenames; instead, they should be converted to bytes.
* In subprocess.Popen, the default value for close_fds is now True under Unix; 



#### EXCEPTIONS

* PEP 0352: All exceptions must be derived (directly or indirectly) from BaseException.
* BaseException should only be used as a base class for exceptions that should only be handled at the top level, such as SystemExit or KeyboardInterrupt. The recommended idiom for handling all exceptions except for this latter category is to use except Exception.
* PEP 3109: Raising exceptions. You must now use raise Exception(args) instead of raise Exception, args. 
* PEP 3110: Catching exceptions. You must now use except SomeException as variable instead of except SomeException, variable. Moreover, the variable is explicitly deleted when the except block is left.
* PEP 3134: Exception chaining.
* PEP 3134: Exception objects now store their traceback as the __traceback__ attribute. 
* The io.BytesIO has a new method, getbuffer(), which provides functionality similar to memoryview().



#### MODULE

* Removed reload(). Use imp.reload().
* A new module, importlib was added. It provides a complete, portable, pure Python reference implementation of the import statement and its counterpart, the __import__() function.
* Renamed module __builtin__ to builtins (removing the underscores, adding an ‘s’). The __builtins__ variable found in most global namespaces is unchanged. To modify a builtin, you should use builtins, not __builtins__!
* Directories and zip archives containing a __main__.py file can now be executed directly by passing their name to the interpreter. 
* PEP 3118: Revised Buffer Protocol. The old builtin buffer() is now really gone; the new builtin memoryview() provides (mostly) similar functionality.
* A new module for command line parsing, argparse, was introduced to overcome the limitations of optparse which did not provide support for positional arguments (not just options)
* PEP 3148: The concurrent.futures module
* The runpy module which supports the -m command line switch now supports the execution of packages by looking for and executing a __main__ submodule when a package name is supplied.
* The xml.etree.ElementTree package and its xml.etree.cElementTree counterpart have been updated to version 1.3
* In addition to dictionary-based configuration described above, the logging package has many other improvements. The logging documentation has been augmented by a basic tutorial, an advanced tutorial, and a cookbook of logging recipes. These documents are the fastest way to learn about logging.
* The csv module now supports a new dialect, unix_dialect, which applies quoting for all fields and a traditional Unix style with '\n' as the line terminator. The registered dialect name is unix.
* There is a new and slightly mind-blowing tool ContextDecorator that is helpful for creating a context manager that does double duty as a function decorator.
* The hashlib module has two new constant attributes listing the hashing algorithms guaranteed to be present in all implementations and those available on the current implementation
* The sqlite3 module was updated to pysqlite version 2.6.0. It has two new capabilities.
* The unittest module has a number of improvements supporting test discovery for packages, easier experimentation at the interactive prompt, new testcase methods, improved diagnostic messages for test failures, and better method names
* The pydoc module now provides a much-improved Web server interface, as well as a new command-line option -b to automatically open a browser window to display that server:
* The site module has three new functions useful for reporting on the details of a given Python installation.

getsitepackages() lists all global site-packages directories.
getuserbase() reports on the user’s base directory where data can be stored.
getusersitepackages() reveals the user-specific site-packages directory path.

* The new sysconfig module makes it straightforward to discover installation paths and configuration variables that vary across platforms and installations.
* The configparser module was modified to improve usability and predictability of the default parser and its supported INI syntax.


### LINK
<http://wiki.python.org/moin/Python2orPython3>
<http://docs.python.org/3/whatsnew/3.0.html>
<http://wiki.python.org/moin/Python3PortingStatus>
<http://washort.twistedmatrix.com/2010/11/unicode-in-python-and-how-to-prevent-it.html>
<http://wiki.python.org/moin/PortingExtensionModulesToPy3k>



