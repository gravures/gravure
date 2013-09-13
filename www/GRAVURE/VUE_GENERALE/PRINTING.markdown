# PRINTING
Created mercredi 26 décembre 2012

[~/FOSSILS/gravure/docs/global_2.html](../../../global_2.html)



openprinting/cups-filters
ghostscript/cups
system-config-printer

cups is in severe need for a dedicated Debian maintainer.
<http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=532097>

<http://packages.qa.debian.org/c/cups.html>
<http://qa.debian.org/developer.php?login=debian-printing@lists.debian.org>

Set "FileDevice Yes" in cupsd.conf (see man
cupsd.conf), and as a device name use something like
[file:///tmp/cups.out](../../../../../../../../tmp/cups.out); I haven't tried that for a while, but back then
it worked fine. For postscript output you can of course use the result
right away. For raster data there's a nice viewer out there [1], but
it's not packaged.

