Gravure Ghostscript device
==========================

### spécifications

* implement deviceN features for access to spot colors
* inherit from gdev_prn device
* implement Cups Raster Interface
* 16-bit grey output
* a 4-bit object-map raster channel

#### optional behaviors

* 1-bit halftoned output + object-map raster channel
* a kind of screen-cell map output for post-filtering GS halftone
* more than 1 separation per pass
* trapping capabilities

> bases    →  gdevprn.c, gdevprn.h, gdevbit.c, *doc for* [gs_device](http://svn.ghostscript.com/ghostscript/tags/ghostscript-9.02/doc/Drivers.htm)
> deviceN    →  gdevdevn.c, gdevdevn.h, gdevtsep
> cups    →  gdevcups.c (, gdevijs.c)
> obj-map    →  gdevbit(bitrgbtags device), gdevijs.c (krgb mode), gdevtxtw.c, gdevtrac.c 
> screen    →  gdevwts.c

## Building ghostsctipt

**dependenices on debian:**

* libjpeg8-dev
* liblcms2-dev
* libfreetype6-dev
* libpng-dev
* libpaper-dev
* libfontconfig-dev
* libtiff4-dev

Ghostscript now ships with a build system for unix-like operating systems based on GNU Autoconf. In general the following should work to configure and build Ghostscript:

```bash
./configure
make
sudo make install
```

or

```bash
./configure
make so
sudo make install
```

or 

```bash
./configure
make debug install
make clean
```

for building ghostscript as a shared library. It is recommended to have the extra option --enable-dynamic in ./configure --enable-dynamic which returns an error message on platforms for which shared-library support is inadequate. 

* If you build on Linux with X11 R6 or later, you may get link-time error messages about undefined references to various functions beginning with "SMC" and "ICE". If this happens, make sure that XLIBS in the makefile is set to "Xt SM ICE Xext X11" rather than "Xt Xext X11".

* On very old systems (circa gcc version 2.6.3), you may encounter an incompatibility in object formats (a.out vs. ELF) with the XFree86 library. Typically, ld complains that some X library is not found, or that many Xlib or Xt functions are not found in the library (similar to the messages for omitting SM and ICE from XLIBS). Or you get a message when you start Ghostscript that the program or the shared library is an unrecognized format. If this happens, edit your top-level makefile to add the switches "-b i486-linuxaout" to both CFLAGS and LDFLAGS, then "make clean" followed by "make"). If this doesn't help, or if other strange things happen, contact your Linux supplier or support resource.

* __A few of Ghostscript's drivers are multi-threaded__. None of them are in the default build. Currently the only ones are the "bmpa" series. These drivers require libc version 6 or higher. Most distributions include this, but it may be an issue on very old systems. 

## Testing purpose configure options

```bash
./configure --prefix='/opt' --exec-prefix='/opt' --without-pdftoraster \
--with-drivers=PBM,PS,TIFF,ETS,devicen,spotcmyk,bit,bitcmyk,bitrgb,bitrgbtags,gravure \
--with-x
```

* --with-local-cups: Force using the GS supplied cups code - only usefull for debugging

With switching to freetype 2 as the default font renderer in April 2010, we added a new switch:-dDisableFAPI=true to revert to the older behavior, just in case serious regression happens that cannot be resolved in a timely manner.

## Notes

Étudier le driver epsontoraster de cups, 
est-ce-qu'il attend la fin du stream venue de gs pour ensuite
envoyer le raster à l'imprimante ?
les driver peuvent-il écrire des fichiers sur le systeme ?
etudier le filtre pdftoraster version ghoscript

#### Devices interessant

gdevbit, gdevtrac, gdevtsep, gdevwts, gdevtxtw, gdevdevn.c/h, gdevcups, gdevprn.c/.h, gdevijs (regarder le krgb mode !!!)

Fichier de déclarations : devs.mak, contrib.mak, cups.mak

#### device de separation (uniquement raster) :

- tiffsep1 > 1 bit

- tiiffsep > 8 bits

- **tiff64nc » 16 bit**

- devicen > 8 bits

- spotcmyk > 8 bits

- bmpsep1

- bmpsep8

- pksm

#### deviceN spot colors :

- devicen > 8 bits

- spotcmyk > 8 bits

- tiffsep1 > 1 bit

- tiiffsep > 8 bits

- psd >

- xcf

> Comme le format d'entier le + long est sur 64bit dans gs, et que tous les deviceN driver estime devoir fournir les plaques cmyk avec les tons direct, ils se sont limités à des sortie 8 bits par plaque. Une première entreprise peut etre pas trop compliqué serait de développer un device qui sort une plaque à la fois, et en plus accompagné d'un pixmap/Object pour la séparation. La sélection de la plaque se ferait par un setPageDevice.

#### petit calcul de raster

pour un format F4+ : 95 X 132 cm à 1440x1440 dpi
1 inch=2.54 cm -> 37.4 X 51 .9
37.4*1440 * 51 .9*1440 = 4'024'982'016 pixel
16 bit/pixel -> 64399712256 bits = 7861293 Ko = 7.8 Go

> Question : qu'est ce qu'il arrive actuellement si j'envoie une impression
> de cette taille à gutenprint en demandant du 16 bits (par exemple une
> photo 16bit à 120dpi pleine page dans un pdf) ?

________________________________________________________________________________

#### Unique scénario de séparation postscript

ps_comp (level <=3) -> GS : ps_comp_level_1.5 -> aurora.ps : sep_N_ps_level_1

pdf_comp (>=1.4) -> pdftops : ps_separable_(level <=3) -> GS : ps__level_1.5 

   -> aurora.ps : sep_N_ps_level_1

pdftops = poppler (xpdf)

> **aurora n'est pas gpl!**

________________________________________________________________________________

#### Pdf 2 Ps issues

Both PostScript 3 and PDF 1.3 & later support a mechanism called smooth shading which offers higher-quality monochrome or color gradient fills. Older versions of PostScript as well as the EPS file format don’t support smooth shading. This means that gradients are transformed when converting from PDF to EPS or PostScript level 2. This may lead to banding or thin white lines in the gradient.

I have never encountered PDF files with 16-bit images in them besides the ones that I created myself when playing around with that feature. Those 16 bits won’t survive refrying. A refried PDF always contains 8-bit data because that is all that PostScript can handle. 

(<http://www.prepressure.com/pdf/basics/refrying>)

PostScript as a page description language has never been limited to 256 gray levels. Admittedly Adobe's own Level 1 RIPs did have this limitation, but the language itself does not impose any limits. (Improvements to the language incorporated in PostScript Level 2 included the ability to move data with 12 bits per channel directly to the "image" operator.)

<http://www.ledet.com/margulis/ACT_postings/ColorCorrection/ACT-16bit-histogram.htm>

Le PostScript 3, selon Buanic, p. 43, accepte 4096 niveaux par couleur de séparation au lieu de 256, pour le niveau 2. 

#### CUPS

<http://www.cups.org/documentation.php/doc-1.2/spec-ppd.html>
Separations : Boolean <</Separations true>>setpagedevice
