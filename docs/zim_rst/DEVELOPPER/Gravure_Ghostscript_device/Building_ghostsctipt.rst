================
Building ghostsctipt
================
Linux
^^^^^

| **dependenices on debian:**
| - libjpeg8-dev
| - liblcms2-dev
| - libfreetype6-dev
| - libpng-dev
| - libpaper-dev
| - libfontconfig-dev
| - libtiff4-dev

| Ghostscript now ships with a build system for unix-like operating systems based on GNU Autoconf. In general the following should work to configure and build Ghostscript:

::

	./configure
	make
| 	``sudo make install``
| or
| ``./configure``
| ``make so	``
| 	``sudo make install``
| or
| ``./configure``
| ``make debug install``
| ``make clean``

| for building ghostscript as a shared library. It is recommended to have the extra option --enable-dynamic in ./configure --enable-dynamic which returns an error message on platforms for which shared-library support is inadequate. 

| - If you build on Linux with X11 R6 or later, you may get link-time error messages about undefined references to various functions beginning with "SMC" and "ICE". If this happens, make sure that XLIBS in the makefile is set to "Xt SM ICE Xext X11" rather than "Xt Xext X11".

| - On very old systems (circa gcc version 2.6.3), you may encounter an incompatibility in object formats (a.out vs. ELF) with the XFree86 library. Typically, ld complains that some X library is not found, or that many Xlib or Xt functions are not found in the library (similar to the messages for omitting SM and ICE from XLIBS). Or you get a message when you start Ghostscript that the program or the shared library is an unrecognized format. If this happens, edit your top-level makefile to add the switches "-b i486-linuxaout" to both CFLAGS and LDFLAGS, then "make clean" followed by "make"). If this doesn't help, or if other strange things happen, contact your Linux supplier or support resource.

| - A few of Ghostscript's drivers are multi-threaded. None of them are in the default build. Currently the only ones are the "bmpa" series. These drivers require libc version 6 or higher. Most distributions include this, but it may be an issue on very old systems. 

| _______________________________________________________________________________________

TESTING PURPOSE CONFIGURE OPTIONS
"""""""""""""""""""""""""""""""""

| ``./configure --prefix='/opt' --exec-prefix='/opt' --without-pdftoraster  --with-drivers=PBM,PS,TIFF,ETS,devicen,spotcmyk,bit,bitcmyk,bitrgb,bitrgbtags,gravure  --with-x``

| - --with-local-cups       Force using the GS supplied cups code - only usefull for debugging

| _______________________________________________________________________________________

| With switching to freetype 2 as the default font renderer in April 2010, we added a new switch:-dDisableFAPI=true to revert to the older behavior, just in case serious regression happens that cannot be resolved in a timely manner.



