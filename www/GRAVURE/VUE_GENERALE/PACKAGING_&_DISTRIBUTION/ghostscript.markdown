# ghostscript
Created samedi 12 janvier 2013

  comerr-dev d-shlibs dh-buildinfo freeglut3 freeglut3-dev krb5-multidev libcups2-dev libcupsimage2-dev libdbus-1-dev
  libexpat1-dev libfontconfig1-dev libfreetype6-dev libgcrypt11-dev libgl1-mesa-dev libglu1-mesa-dev libgnutls-dev
  libgnutls-openssl27 libgnutlsxx27 libgpg-error-dev libgssrpc4 libice-dev libidn11-dev libijs-dev libjasper-dev
  libjbig-dev libjbig2dec0-dev libjpeg8-dev libkadm5clnt-mit8 libkadm5srv-mit8 libkdb5-6 libkrb5-dev liblcms2-dev
  libp11-kit-dev libpaper-dev libpng12-dev libpthread-stubs0 libpthread-stubs0-dev libsm-dev libtasn1-3-dev
  libtiff4-dev libtiffxx0c2 libx11-dev libxau-dev libxcb1-dev libxdmcp-dev libxext-dev libxt-dev mesa-common-dev
  x11proto-core-dev x11proto-input-dev x11proto-kb-dev x11proto-xext-dev xorg-sgml-doctools xtrans-dev zlib1g-dev



Addition of capability for overprint simulation for CMYK colorants with RGB target device



To have an RGB device do this simulation of CMYK overprinting you should have the device set

its opmode in color info from GX_CINFO_OPMODE_UNKNOWN to GX_CINFO_OPMODE_RGB.  In addition,

to ensure consistent color in the document you should use the -dUseFastColor option since

simulated RGB overprinting uses unmanaged color transformations.



The fix required the addition of a compositor parameter which was a k value to be make use

when we had K overprinting occurring.



To port this fix to an earlier ghostscript release (pre-ICC) you will want to create a

gx_set_overprint_DeviceRGB procedure for the gs_color_space_type_DeviceRGB type.   This will

be similar to gx_set_overprint_DeviceCMYK except it will end up calling gx_set_overprint_rgb

instead of gx_set_overprint_cmyk.   See changes in gsicc.c.

