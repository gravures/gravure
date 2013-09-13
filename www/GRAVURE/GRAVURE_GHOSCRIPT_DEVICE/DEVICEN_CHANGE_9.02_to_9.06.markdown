# DEVICEN CHANGE 9.02 to 9.06
Created samedi 06 octobre 2012

2012-08-02 20:34:26 -0700
Michael Vrhel <[michael.vrhel@artifex.com](mailto:michael.vrhel@artifex.com)>
588c2ee040526fbea470e36e7cbc8e87a503cab9

    Update documentation for tiffsep planar device

    Add in comments about the use of -dMaxSpots as well as the fact that the device,
    and psdcmyk are planar and limited to 64 colorants per page. Also add in a
    hint about using -dMaxSpots when we are processing a Postscript file and bump
    up to the default max limit of 10 colorants. Tested it and it worked nicely.
    Thanks Robin Watts.

    gs/base/gdevpsd.c
    gs/base/gdevtsep.c
    gs/doc/Devices.htm
________________________________________________________________________
2012-08-02 18:27:45 +0100
Robin Watts <[robin.watts@artifex.com](mailto:robin.watts@artifex.com)>
836a551b97dd4a8436608b6dcebe8f8fb8632bcd

    Add -dMaxSpots for tiffsep and psd devices.

    psd and tiffsep devices now run with GS_SOFT_MAX_SPOTS spots enabled
    by default (ten, unless predefined differently at build time). The
    user can change this value using -dMaxSpots=X (where
    0 <= X <= GS_CLIENT_COLOR_MAX_COMPONENTS-4).

    gs/base/gdevpsd.c
    gs/base/gdevtsep.c
    gs/base/gsccolor.h
_____________________________________________________________________
2012-07-31 17:53:58 +0100
Robin Watts <[robin.watts@artifex.com](mailto:robin.watts@artifex.com)>
c832985cab3b769d460a3f3e0ae894c2a84fa1ba

    Update tiffsep/tiffsep1 documentation w.r.t downscaler.

    Document 32 and 34 ratios. Add extra info to tiffsep1 to distinguish
    it from tiffsep in 1bpp mode.

    gs/doc/Devices.htm
___________________________________________________________________
2012-07-31 10:50:43 +0100
Robin Watts <[robin.watts@artifex.com](mailto:robin.watts@artifex.com)>
76722bee735462eedf4f4c6d9dfa552e3c1f7ebc

    Fix link warnings about bad memset in gdevtsep.c

    Due to a mistake on my part, the tiffsep device had a couple of
    memsets in that did nothing; these were intended to clear an array
    of pointers before use. Not clearing the array would only have been
    a problem if we'd hit an error condition in a very small region of
    code, but nonetheless, this is a fix.

    gs/base/gdevtsep.c
__________________________________________________________________
2012-07-30 19:05:08 +0100
Robin Watts <[robin.watts@artifex.com](mailto:robin.watts@artifex.com)>
443ad5a4885be7abf5a1e0777275eefbc5322cd2

    Up default GS_CLIENT_COLOR_MAX_COMPONENTS to 32.

    The planar changes have enabled us to increase the default maximum
    number of spot changes to 32. Tests show only a few differences
    due to roundings.

    Hopefully we can push it to 64 soon.

    gs/base/gsccolor.h
_______________________________________________________________
2012-07-25 23:58:40 -0700
Ray Johnston <[ray.johnston@artifex.com](mailto:ray.johnston@artifex.com)>
428869d288d87d95fbcb5dcf8a0563003ff26294

    Fix bug 693220. The pdf14 device used compressed encoding in clist mode.

    The pdf14 device clist mode did not respect the USE_COMPRESSED_ENCODING
    setting always using compressed encoding, and ended up writing pure
    colors with num_bytes == -3. This was undetected because tiffsep1 is not
    part of the regression testing, and because the tiffsep1 device did not
    use 'planar' mode as the tiffsep device did. Also fixed some blanks before
    line ends and tab indents.

    Also, since planar mode is more efficient and allows for > 8 colorants
    tiffsep1 was changed to use planar mode, getting rid of the need for
    compressed color encoding in this file (maybe the last one).

    gs/base/gdevp14.c
    gs/base/gdevtsep.c
_________________________________________________________________
2012-07-25 22:02:00 -0700
Michael Vrhel <[michael.vrhel@artifex.com](mailto:michael.vrhel@artifex.com)>
c8fc89fe8d72ad87158569825ddf421887c47713

    Replace magic 32 number with MAX_COMPONENTS_IN_DEVN

    gs/base/gsccolor.h
    gs/psi/icremap.h
_________________________________________________

2012-07-24 21:40:05 -0700
Michael Vrhel <[michael.vrhel@artifex.com](mailto:michael.vrhel@artifex.com)>
e884e39691346b35ea8b87fe26d8d98857689397

    Change the remap_color_info structure so that we can support up to 32 colorants DeviceN

    AR supports up to 32 colorants in a DeviceN color space and this brings us in line with
    that product's limits. Note that if the number of colorants is greater than
    GS_CLIENT_COLOR_MAX_COMPONENTS then we end up using the alternate tint transform.
    Previously, the tint transform would fail if we encountered a color DeviceN color
    space with more that GS_CLIENT_COLOR_MAX_COMPONENTS colorants. This fixes bug 693185

    gs/psi/icremap.h

------------------------------------
2012-07-20 15:46:06 +0100
Robin Watts <[robin.watts@artifex.com](mailto:robin.watts@artifex.com)>
a06bb8cfd8791254655889d85a1d37f173f53597

    Rework colors_used to be a color_usage bitfield.

    Previously, the clist would collate the colors used in a band/page
    by ORing together any color indexs uses into a single gx_color_index.
    This relies on the gx_color_index being able to represent the whole
    depth.

    This is dodgy with compressed encoding, and fails entirely with the
    new planar based tiffsep/psdcmyk and high level color stuff, as the
    total depth can far exceed the number of bits available in a
    gx_color_index.

    The fix here is to change to using a bitfield (gx_color_usage_bits)
    for this record; this allows us to have up to 64 colorants with a
    standard build.

    The code here is still imperfect for all the reasons listed within
    the original code (only works for subtractive spaces, can falsely
    detect 'no colors used', etc), but it is at least consistently
    imperfect now.

    gs/base/gdevpbm.c
    gs/base/gdevprn.c
    gs/base/gdevprn.h
    gs/base/gxband.h
    gs/base/gxcldev.h
    gs/base/gxclimag.c
    gs/base/gxclist.c
    gs/base/gxclist.h
    gs/base/gxclpath.c
    gs/base/gxclpath.h
    gs/base/gxclread.c
    gs/base/gxclrect.c
____________________________________________________________________2012-06-01 14:05:03 -0700
Michael Vrhel <[michael.vrhel@artifex.com](mailto:michael.vrhel@artifex.com)>
3a5a524ea71a58cc0e9e0200bb98a2fc341ec033

    Fix for broken AA support for devices that support the devn color type

    This fix involved the addition of a copy_alpha_hl_color for passing along the devn color
    value when doing the copy_alpha procedure. This required support through the clist,
    special handing in the pdf14 device and a default procedure for the operation.
    The only devices that should be affected are tiffsep and psdcmyk. Support for 16bit psd
    devices may have issues and I will go back to check on this later as a customer is waiting
    for this for 8 bit tiffsep.

    gs/base/gdevabuf.c
    gs/base/gdevdbit.c
    gs/base/gdevdflt.c
    gs/base/gdevmem.c
    gs/base/gdevmem.h
    gs/base/gdevmpla.c
    gs/base/gdevnfwd.c
    gs/base/gdevp14.c
    gs/base/gsdcolor.h
    gs/base/gspaint.c
    gs/base/gxccman.c
    gs/base/gxcldev.h
    gs/base/gxclip.c
    gs/base/gxclip.h
    gs/base/gxclip2.c
    gs/base/gxclipm.c
    gs/base/gxclist.c
    gs/base/gxclpath.h
    gs/base/gxclrast.c
    gs/base/gxclrect.c
    gs/base/gxdevcli.h
    gs/base/gxdevice.h
    gs/base/gxdevmem.h
_________________________________________________________________2012-06-26 15:34:44 +0100
Robin Watts <[robin.watts@artifex.com](mailto:robin.watts@artifex.com)>
526c580e272ee15c488b9fe4845482a30ce05eef

    Bug 693064: raise maximum possible GS_CLIENT_COLOR_MAX_COMPONENTS to 32

    By default we support a maximum of 14 components. Supposedly this can be
    increased by raising GS_CLIENT_COLOR_MAX_COMPONENTS to a larger number
    on startup, but this starts to cause problems in various places throughout
    the code.

    The first such place is in the bpc_to_depth function (found in gdevdevn
    and various other places), where the calculation goes wrong for anything
    above 31 components at 8 bpc. We fix that here.

    This allows us to get to 32 components. To raise it above 32 presents
    problems on most architectures as the code assumes elsewhere that we
    can use a bitmask to represent which components are present.

    We may be able to tweak the code to use a uint64_t instead, in which
    case we can probably get to 64 components; is that high enough?

    gs/base/gdevdevn.c
    gs/base/gdevrinkj.c
    gs/base/gdevxcf.c
    gs/base/gxclist.c
__________________________________________________________________
2012-06-18 16:51:30 +0100
Robin Watts <[robin.watts@artifex.com](mailto:robin.watts@artifex.com)>
7f98970a6c0e641e87eb202dc2087814249d0408

    Add 3:2 and 3:4 downscaling to tiffsep/psd/downscaler.

    Currently the downscaler can only downscale in integer increments. To
    accomodate a potential need to efficiently scale 1200 -> 800 and
    600 -> 800 dpi, we introduce new functionality to allow 3:2 and 3:4
    scaling modes.

    We shoehorn these into the existing scaler system by using DownScaleFactor
    settings of 32 and 34 respectively; any other DownScaleFactor > 8 will
    give a rangecheck error.

    This has required some changes within the downscaler code itself, and
    will require more changes in any device that wants to use these. Currently
    the cores are only provided in the planar modes; hence tiffsep and psd are
    the only devices that have been updated to work with this.

    gs/base/gdevpsd.c
    gs/base/gdevtifs.c
    gs/base/gdevtsep.c
    gs/base/gxdownscale.c
    gs/base/gxdownscale.h
_______________________________________
-2012-05-28 13:05:00 +0100
Robin Watts <[robin.watts@artifex.com](mailto:robin.watts@artifex.com)>
f30e8944b915936befffbadc036e1de16659914e

    Add 16bpp support to downscaler.

    Currently unused, but passes local tests with James Cloos' proposed
    psdcmyk16 and psdrgb16 devices.

    gs/base/gdevpsd.c
    gs/base/gdevtsep.c
    gs/base/gxdownscale.c
    gs/base/gxdownscale.h
____________________________________________________
2012-05-22 13:35:31 +0100
Robin Watts <[robin.watts@artifex.com](mailto:robin.watts@artifex.com)>
15cc33536ada0b4cb105110a48df0132539c54db

    Add downscaler functionality to tiffsep.

    Update tiffsep to call the downscaler. This means adding MinFeatureSize
    and DownScaleFactor to tiffsep. Also add BitsPerComponent to allow us to
    specify 8 (default) or 1 (monochrome). MinFeatureSize is ignored except
    in monochrome mode.

    This has meant slight reworking of the downscaler to cope with planar
    buffers, and its use of get_bits_rectangle rather than get_bits.

    Also updated docs, and fixed some leaks on memory allocation failures
    within tiffsep.

    gs/base/gdevtsep.c
    gs/base/gxdownscale.c
    gs/base/gxdownscale.h
    gs/base/lib.mak
    gs/doc/Devices.htm
___________________________________2012-05-03 12:13:06 -0700
Michael Vrhel <[michael.vrhel@artifex.com](mailto:michael.vrhel@artifex.com)>
7b81312d205a2f9b89f40da4b4f6b67bcacd8ef1

    Fix for issues in use of /SeparationOrder and /SeparationColorNames

    Several issues and quite a bit of confusion in the code with respect
    to this option. I believe this should clear some things up.
    Documentation still needs to be updated as to how this option functions
    and what devices it actually works with. Note that
    SeparationOrder and SeparationColorNames really only works for the
    tiffsep device. The psdcmyk device was never really set up for use
    with this option. Not sure if we want to add it. Also, I discovered
    that with the disabling of compressed color encoding, the tiffsep1
    device renders incorrectly. I had not converted this device to planar
    as I had thought that it performed halftoning during rendering. I
    did not realize it was rendering 8 bit data and then doing
    a thresholding operation. We may want to just move this to a planar
    based device. In that case, we could use the fast planar halftoning.

    Note that with this fix, the device will only create output for the
    colorants listed in /SeparationOrder. The psdcmyk device was not
    making use of the /SeparationOrder information properly. It is now
    which makes for some different renderings in the ps3cet/29-07*.ps test
    files which exercise /SeparationOrder changes. In such a case, the
    device will not output any missing colorants, which previously
    it was doing.

    gs/base/gdevdevn.c
    gs/base/gdevpsd.c
    gs/base/gdevtsep.c
________________________________
2012-04-30 15:27:30 +0100
Chris Liddell <[chris.liddell@artifex.com](mailto:chris.liddell@artifex.com)>
3cde6d6d3d24a0930d591df9914ddda194d13b37

    Bug 692459: stop tiffsep(1) overwriting pages already written

    The tiffsep and tiffsep1 devices both get closed and reopen when the separations
    change (communicated by put_params). Previously this caused the output files to
    be closed and reopened - not a problem when writing each page to its own set of
    files, but when writing multipage tiffs, it resulted in all pages up to that
    point to be overwritten.

    We now have tiffsep and tiffsep1 handle their own file "management", and prevent
    output files from being closed and reopened when the device is closed and
    reopened due to a put_params call.

    No cluster differences.

    gs/base/gdevtsep.c
___________________________________________________________________________
2012-04-27 18:46:27 +0100
Robin Watts <[robin.watts@artifex.com](mailto:robin.watts@artifex.com)>
60640aeb33b18f9a9fcd76fc6f1083d7c7635f24


* Change of the tiffsep and psdcmyk device to planar devices.


    This change in these devices was made to remove the 64 bit limitation of
    our existing color encoding which limits us to 8 colorants without
    compressed color encoding. The motivation for this work is that even
    with compressed color encoding we were starting
    to encounter files with transparency in particular that exceeded the
    capabilities of encoding, leading to dropped colors. With this fix, we
    encode through the clist the DeviceN color values. The buffers for the
    devices are maintained as planar buffers and fills occur with the high level
    device colors.

    Support was added to handle the devn color type through the shading code. The old
    code would have supported only 8 colorants in a shading.

    Support was also added to the transparency code to enable the use of the put_image
    procedure which for the planar device saves quite a bit of time since we can do the
    copy_planes proc directly from the pdf14 planar buffer to the planar memory device buffer.
    The pdf14 device also had to support fill_rectangle_hl_color.

    Changes were also made to the pattern tiling code so that we avoid any planar to chunky and
    back to planar conversions. These were being done to handle ROPs. Even when there were
    not any ROPs to perform we were going through strip_tile_rop operations since the
    gx_default_strip_tile_rectangle did not support planar to planar. That support is added
    with this commit.

    Support had to be added to the overprint compositor to support the new color type with
    fill_rectangle_hl_color.

    Support had to be added to the clist for fill_rectangle_hl_color. This required changes
    on both the writing and reading side. It is possible that the amount of data written
    for these commands could be reduced and that is commented in the code.

    Support also had to be added to the clip device and the mask_clip device as well
    for uncolored patterns. Also the tile clip device required support and the transparency device
    required support for copy_planes. This last function needs to be optimized.

    Both of the separation devices (tiffsep and psdcmyk) that we currently have are updated to
    support this method. There is an #if option in each device file to return the
    code back to the old chunky format.

    A new device procedure for handling strip tiling of masks with devn colors had
    to be added. Functionality was only required for the mem planar and clist devices.

    Also, it was found that the tiffsep and psdcmyk devices were maintaining separations
    (spot colors) across pages. That is if page 1 had a spot color, subsequent pages
    created a separation for that spot
    even if those pages did not contain it. This was fixed so that separations for a page
    are only created for the spots that occur on that page.

    A fix was also made to ensure that we had proper handling for the None colorants when
    they are part of the DeviceN color space.

    gs/base/devs.mak
    gs/base/gdevbbox.c
    gs/base/gdevdbit.c
    gs/base/gdevdevn.c
    gs/base/gdevdevn.h
    gs/base/gdevdflt.c
    gs/base/gdevdsha.c
    gs/base/gdevmem.c
    gs/base/gdevmem.h
    gs/base/gdevmpla.c
    gs/base/gdevmx.c
    gs/base/gdevnfwd.c
    gs/base/gdevp14.c
    gs/base/gdevpdfi.c
    gs/base/gdevppla.c
    gs/base/gdevprn.c
    gs/base/gdevpsd.c
    gs/base/gdevtsep.c
    gs/base/gscdevn.c
    gs/base/gscicach.c
    gs/base/gscms.h
    gs/base/gscsepr.c
    gs/base/gsdcolor.h
    gs/base/gsdps1.c
    gs/base/gsequivc.c
    gs/base/gsicc_manage.c
    gs/base/gsovrc.c
    gs/base/gsptype1.c
    gs/base/gxblend.h
    gs/base/gxblend1.c
    gs/base/gxcldev.h
    gs/base/gxclimag.c
    gs/base/gxclip.c
    gs/base/gxclip.h
    gs/base/gxclip2.c
    gs/base/gxclipm.c
    gs/base/gxclist.c
    gs/base/gxclpath.c
    gs/base/gxclpath.h
    gs/base/gxclrast.c
    gs/base/gxclrect.c
    gs/base/gxcmap.c
    gs/base/gxdcolor.c
    gs/base/gxdcolor.h
    gs/base/gxdevcli.h
    gs/base/gxdevice.h
    gs/base/gxdevsop.h
    gs/base/gxgetbit.h
    gs/base/gxht.c
    gs/base/gxicolor.c
    gs/base/gxp1fill.c
    gs/base/gxp1impl.h
    gs/base/gxpcmap.c
    gs/base/gxpcolor.h
    gs/base/gxshade6.c
    gs/base/lib.mak
_________________________________________________________________-
2012-03-27 19:29:56 -0700
Ray Johnston <[ray.johnston@artifex.com](mailto:ray.johnston@artifex.com)>
5b50a46f4ed3e54fec6727a1ad52258e5d32b0a9

    Add -sBandListStorage={file|memory} option and default to no bitmap compression if file clist.

    Also alphabetize the clist options and remove the arbitrary 10000 minimum for MaxBitmap
    (now -dMaxBitmap=0 is legal). The change to not compress bitmaps (using CCITT) when going
    to disk based clist improves performance.

    gs/base/gdevprn.c
    gs/base/gdevprn.h
    gs/base/gxclbits.c
    gs/base/gxclist.c
    gs/base/lib.mak
    gs/doc/Language.htm
__________________________________________________________
2012-03-13 22:45:00 -0700
Michael Vrhel <[michael.vrhel@artifex.com](mailto:michael.vrhel@artifex.com)>
0eae84aaf7a1c27f077d4aff3050ae48bb5a6aaa

    Fix for broken tiff devices due to use of huge signed number in overflow test

    0xFFFFFFFF is used in a calculation to see how close we are to the 4G limit in
    a tiff file. Problem was this was cast as a long which, in a 32 bit
    system ends up being -1.

    gs/base/gdevtsep.c
_________________________________________________
2012-03-09 13:53:55 -0800
Marcos H. Woehrmann <[marcos.woehrmann@artifex.com](mailto:marcos.woehrmann@artifex.com)>
dc98b15546522ce28edad3f129f1ae8e05300a34

    Change compression of the tiffsep device composite output to match the separations.

    Previous to this commit the tiffsep device would always write out
    an uncompressed composite file; the separation files were lzw
    compressed by default and this could be changed via the -sCompression=
    option. Now the compression of the composite file is the same as
    that of the separation files.

    Fixes Bug 692907.

    gs/base/gdevtsep.c
    gs/doc/Devices.htm
___________________________________________________________-
2012-03-06 09:06:55 -0800
Marcos H. Woehrmann <[marcos.woehrmann@artifex.com](mailto:marcos.woehrmann@artifex.com)>
23e37b6fc4d79741007cc18d770bb3e449e53014

    Fix the checks in gdevtsep.c missed by commit e954dd4683c35dbd66de3e045d979ebbf20c4d72

    Henry pointed out that my e954dd4683c35dbd66de3e045d979ebbf20c4d72
    fix was incomplete; this commit replaces the remaining max_long
    references with 2^32-1.

    gs/base/gdevtsep.c
________________________________________________________________
2012-03-05 19:21:53 -0800
Marcos H. Woehrmann <[marcos.woehrmann@artifex.com](mailto:marcos.woehrmann@artifex.com)>
e954dd4683c35dbd66de3e045d979ebbf20c4d72

    Fix detection of TIFF file size overflow in tiffsep.

    The TIFF spec limits files to 4 Gigs. The code to detect attempts
    to write files that were larger than this in gdevtsep.c was broken
    on systems were a long != 32 bit.

    Fixes Bug 692896.

    gs/base/gdevtsep.c
__________________________________________________________________
2012-02-16 18:16:16 +0000
Robin Watts <[robin.watts@artifex.com](mailto:robin.watts@artifex.com)>
21579b00e53b97cd655f164bb92c5280c586e365

    Output helpful debug warning when tif output would be too large.

    Currently we just raise a rangecheck, which can be very confusing.

    CLUSTER_UNTESTED.

    gs/base/gdevtsep.c
___________________________________________________________________


2012-02-15 19:03:56 +0000
Robin Watts <[robin.watts@artifex.com](mailto:robin.watts@artifex.com)>
43b14b24fcc13d816dd41ca335d52cd3074bd0d8

    Update garbage collection to cope with pdf14_compressed_color_list.

    A second list of compressed colors was recently added to the
    gdevn_params structure, but this wasn't added to the garbage
    collection routines. Fixed here.

    gs/base/gdevp14.c
    gs/base/gdevpsd.c
    gs/base/gdevtsep.c
_______________________________________________________________________-
2012-02-14 14:57:07 +0000
Robin Watts <[robin.watts@artifex.com](mailto:robin.watts@artifex.com)>
00a96d35b30d77f8dfbc8ae12326c81053fc50c9

    Fix Bug 692854; tweak gdev_prn color procs.

    A previous commit (cf37ea5) changed the prn device macros to
    duplicate map_color_rgb/map_rgb_color to encode/decode_color.
    I thought this was safe as the default color encoding/decoding
    functions were actually implemented as encode/decode, rather
    than map_ variants.

    Unfortunately, this falls down when other devices (such as the
    tiffscaled ones) provide genuine map_ functions rather than
    encode/decodes.

    So, a small tweak to the macros is required; we now duplicate
    to encode/decode only if specifically told to - and the macros
    that use the defaults specifically say to. Other devices should
    remain unchanged.

    gs/base/gdevprn.h
______________________________________________________-
2012-02-10 17:20:36 +0000
Robin Watts <[robin.watts@artifex.com](mailto:robin.watts@artifex.com)>
cf37ea5d017193c76341aafd60e35d3b1826046f

    Prn device changes to encode/decode_color.

    At the moment, prn devices do not implement encode_decode/color,
    choosing instead to provide map_rgb_color/map_color_rgb which
    just get called through a 'backwards compatibility' layer.

    In fact, they actually implement encode/decode_rgb rather than
    map_rgb_color/map_color_rgb, so we just copy the entries here.

    No changes expected in cluster.

    gs/base/gdevprn.h
___________________________________________________________________
2011-12-06 13:34:47 -0800
Marcos H. Woehrmann <[marcos.woehrmann@artifex.com](mailto:marcos.woehrmann@artifex.com)>
0b21c79855e8f50a218a478bf9fc9d10e20c4db4

    Partial fix for Bug 692434, removed some of the memcmp() of structures.

    No cluster differences expected.

    gs/base/gdevdevn.c
    gs/base/gdevpdfg.c
    gs/base/gdevpdti.c
    gs/base/gdevpdts.c
    gs/base/gdevprn.c
    gs/base/gsequivc.h
    gs/base/gsfont.c
    gs/base/gsmatrix.c
    gs/base/gsmatrix.h 
_____________________________________________________-
2011-11-16 10:32:30 -0800
Michael Vrhel <[michael.vrhel@artifex.com](mailto:michael.vrhel@artifex.com)>
6fbdd32889dfa9d318170e63245755057bb8b401

    Save ICC profile in TIFF and PNG device output.

    This addresses Bug 692183. The patch for the TIFF case was not
    quite sufficient due to changes in the device profile structure,
    issues regarding the separations from the tiffsep device, and
    how we handle the case when the output profile is CIELAB.

    gs/base/gdevpng.c
    gs/base/gdevtifs.c
    gs/base/gdevtsep.c 
_________________________________________________________
2011-11-10 20:11:03 +0000
Robin Watts <[robin.watts@artifex.com](mailto:robin.watts@artifex.com)>
d81dffe6142ead8245baacf12f3b2ae4fe20b206

    Squash warnings in MSVC build.

    All self evident, really. Lots of char's that should be bytes etc.

    gs/base/gdevclj.c
    gs/base/gdevpdtw.c
    gs/base/gdevtsep.c
    gs/base/gp_wgetv.c
    gs/base/gsicc_cache.c
    gs/base/gxicolor.c
    gs/base/gxipixel.c
    gs/base/sidscale.c
    pcl/pcht.c
    pcl/rtmisc.c
    pl/plchar.c
    pl/plfont.c
    xps/xpspath.c 
__________________________________________________________
2011-08-31 18:39:24 +0100
Robin Watts <[Robin.Watts@artifex.com](mailto:Robin.Watts@artifex.com)>
1da2a46ed9f6ae0b0afc5fd4417943a36e532171

    More work on bug 690538: introduce macros for color rounding.

    Introduce new macros to gxcvalue.h header file that defines helpful macros
    for colour depth changing.

    COLROUND macros do rounding (16->n bits), COLDUP macros do bit duplication
    (n->16 bits). Use these macros in various places throughout the code.

    Also tweak the gx_color_value_to_byte macro to round in the same way.

    Colors for devices that use these functions are now rounded in the same way
    that lcms does.

    Change as many encode_color routines as I can find to use this new code
    rather than simply truncating.

    gs/base/gdevbit.c
    gs/base/gdevcdj.c
    gs/base/gdevdevn.c
    gs/base/gdevdsp.c
    gs/base/gdevperm.c
    gs/base/gdevplan.c
    gs/base/gdevplib.c
    gs/base/gdevpsd.c
    gs/base/gdevrinkj.c
    gs/base/gdevtsep.c
    gs/base/gdevxcf.c
    gs/base/gxblend1.c
    gs/base/gxcmap.c
    gs/base/gxcvalue.h
_____________________________________________________________________
2011-10-20 22:11:00 -0700
Ray Johnston <[ray.johnston@artifex.com](mailto:ray.johnston@artifex.com)>
7ebbcae24116a37b2f32f52bc7330383752f903f

    Fix bug 692618. Clear pointers to compressed color structured in pdf14 device.

    After the devn compressed color structures were freed, the pointers were not reset to
    NULL so subsequent GC would trace into freed or re-used memory. -Z? showed errors and,
    depending on memory contents and usage could result in a seg fault. Also add 'mem'
    element to the compressed_color_list structure to be used when freeing to avoid
    confusion about the correct allocator.

    Issue with non-encodable colors is _not_ fixed by this, only the segfault.

    gs/base/gdevdevn.c
    gs/base/gdevdevn.h
    gs/base/gdevp14.c 
______________________________________________________________________
2011-09-23 23:23:02 -0700
Michael Vrhel <[michael.vrhel@artifex.com](mailto:michael.vrhel@artifex.com)>
545cd811c4a2c33c472f302088a10a807e98d9be

    Fix for Bug 692339

    Threshold creation code in the tiffsep1 code was not handled correctly when the dorder was a simple form
    that included a repeated shift.

    gs/base/gdevtsep.c 
_________________________________________________________________-
2011-08-10 10:27:03 +0100
Chris Liddell <[chris.liddell@artifex.com](mailto:chris.liddell@artifex.com)>
edd256d908da6ad77d3e595febffcc3717d5e900

    Bug 692367: add gs_memory_t arg to finalize method

    By adding a gs_memory_t argument to the object "finalize" method, we can
    dispense with the pointer-pun hackery that stores the memory context
    in an extra struct array element of the IO device table, so it's availabe
    in the finalize method.

    Although primarily addresses one hack, this commit touches a number of files
    because it affects every object with a "finalize" method.

    This also addresses an error condition cleanup of a partially create IO
    device table.

    No cluster differences.

    gs/base/gdevdevn.c 
__________________________________________________________________
Michael Vrhel <[michael.vrhel@artifex.com](mailto:michael.vrhel@artifex.com)>
d3302b1176683dc9e4cb5cb8ed9f42bffa0888ee


    Fix for bug 692204. This forces DeviceGray to K only for CMYK devices.

    This is performed by default now. To return to a composite type mapping
    that makes use of the true DeviceProfile, use the option -dDeviceGrayToK=false.
    This commit includes a fix to rename the device member variable
    icc_array to icc_struct to reduce confusion in reading the code.

    gs/Resource/Init/gs_lev2.ps
    gs/base/gdevp14.c
    gs/base/gdevpdfk.c
    gs/base/gdevtfnx.c
    gs/base/gdevtsep.c
    gs/base/gdevvec.c 
__________________________________________________________________-
2011-07-06 13:30:23 +0100
Chris Liddell <[chris.liddell@artifex.com](mailto:chris.liddell@artifex.com)>
e5a37634a8e15a945e7f5ea4aca68ab8e1e34d3a

    Bug 692318: Ensure that compiler flags are used for the "aux" files.

    For a normal host build, the build tools (genarch, genconf etc) should be
    built with the same compiler flags as Ghostscript/Ghost*. In this case
    the integer type used for encoded color values was not getting used
    when compiling genarch.

    Also, add a warning when tiffsep does have to skip one or more plates, with
    a pointer to the relevant documentation. Lastly, update the doc to reflect
    that the contone preview output may not be as expected if the job uses
    overprint.

    No cluster differences expected.

    common/ugcc_top.mak
    gs/base/gdevtsep.c
    gs/base/msvccmd.mak
    gs/base/msvctail.mak
    gs/base/unix-aux.mak
    gs/doc/Devices.htm 
______________________________________________________________________
2011-06-06 22:13:07 -0400
Alex Cherepanov <[alex.cherepanov@artifex.com](mailto:alex.cherepanov@artifex.com)>
8b90a80fe86364c0b6c1cad12cfb241c66943c24


    Bug 688064: Add AdjustWidth=WIDTH

    Extend AdjustWidth option to support adjustment to any width. This option
    now accepts the following values;
    0 - no adjustment, the same as before
    1 - low res fax adjustments, the same as before
    >1 - adjust to the given width, regardless of the document width.

    gs/base/gdevfax.c
    gs/base/gdevpng.c
    gs/base/gdevtifs.c
    gs/base/gdevtifs.h
    gs/base/gxdownscale.c
    gs/base/gxdownscale.h
    gs/base/minftrsz.c
    gs/base/minftrsz.h
    gs/doc/Devices.htm 
_____________________________________________________-
2011-04-22 18:08:10 +0100
Robin Watts <[Robin.Watts@artifex.com](mailto:Robin.Watts@artifex.com)>
1b3908faa01c7ef6197374a27b1a5861f0a383fe


    Extend downscaling to png devices too (from tiffscaled).

    Extract the code to do downscaling/min feature size from tiffscaled{,8,24}
    into a new gx_downscaler class. Make tiffscaled{,8,24} call this new class
    with no change in functionality.

    Make png devices call this new code. Only png16m and pnggray are actually
    affected by downscaling though. Add a new pngmonod device to do grayscale
    rendering internally and to downscale/min_feature_size/error diffuse to
    monochrome.
__________________________________________________________
2011-04-22 18:08:10 +0100
Robin Watts <[Robin.Watts@artifex.com](mailto:Robin.Watts@artifex.com)>
1b3908faa01c7ef6197374a27b1a5861f0a383fe


    Extend downscaling to png devices too (from tiffscaled).

    Extract the code to do downscaling/min feature size from tiffscaled{,8,24}
    into a new gx_downscaler class. Make tiffscaled{,8,24} call this new class
    with no change in functionality.

    Make png devices call this new code. Only png16m and pnggray are actually
    affected by downscaling though. Add a new pngmonod device to do grayscale
    rendering internally and to downscale/min_feature_size/error diffuse to
    monochrome.


