# TAGGING
Created samedi 06 octobre 2012

2011-06-23 11:55:14 -0700
Ray Johnston <[ray.johnston@artifex.com](mailto:ray.johnston@artifex.com)>
06df93f6babc540b8e29ae7cc1fcaed888142d52


    Rename object_tag to graphics_type_tag and move to the device for MT rendering.

    The memory->gs_lib_ctx->BITTAG hack was inherently NOT safe for use by multiple
    rendering threads. Devices that want to encode the tag info in the gx_color_index
    need the tag, so we have moved this to the device structure. Multiple rendering
    threads each have unique buffer devices, so this allows clist playback to set
    and use the appropriate tag as the bands are played back without thread
    interference.

    Rename the gs_object_tag_type_t to gs_graphics_type_t to make it more unique for
    grep based searching and prevent confusion with other uses of the term 'object'.
    Move the enum to gscms.h with the 'set' functions prototyped in gxdevcli.h.

    Just as for the device's cmm_dev_profile_t information, the tag needs to be
    forwarded by devices in the chain (clipper, compositor) so that these 'helper'
    filtering devices don't interfere with the setting of the tag. The tag value is
    maintained in all devices in the chain so a 'get_graphics_type_tag' dev_proc
    is not needed -- the dev->graphics_type_tag can be access directly.

    Previously, tags were not recorded except for devices that enabled tags.
    Now tags are tracked for all devices for use in selecting an ICC profile
    and a device can signal that it maintains tags by setting GS_DEVICE_ENCODES_TAGS
    for use by compositors that want to know whether or not to maintain a tag
    plane, such as the pdf14 device.

    Also replace the old 'get_object_type' that the anti-aliasing used with the
    single approach for consistency and to cure problems (not identifed) with using
    AA when other devices are interposed in the chain (clipper, compositor).

    EXPECTED_DIFFERENCES:

    Various 12-07D.PS PS LL3 CET files will show color differences on page 3 (GLOBINT)
    as described in Bug692334.

    gs/base/gdevabuf.c
    gs/base/gdevbit.c
    gs/base/gdevddrw.c
    gs/base/gdevdflt.c
    gs/base/gdevimdi.c
    gs/base/gdevmem.c
    gs/base/gdevnfwd.c
    gs/base/gdevp14.c
    gs/base/gdevprn.h
    gs/base/gdevpsd.c
    gs/base/gdevrinkj.c
    gs/base/gdevrops.c
    gs/base/gdevwts.c
    gs/base/gdevxcf.c
    gs/base/gscms.h
    gs/base/gscsepr.c
    gs/base/gsdevice.c
    gs/base/gsdps1.c
    gs/base/gsequivc.c
    gs/base/gsicc.c
    gs/base/gsicc_cache.c
    gs/base/gsicc_manage.c
    gs/base/gsicc_manage.h
    gs/base/gsimage.c
    gs/base/gslibctx.c
    gs/base/gslibctx.h
    gs/base/gsnamecl.c
    gs/base/gsncdummy.c
    gs/base/gspaint.c
    gs/base/gstext.c
    gs/base/gstrans.c
    gs/base/gsutil.c
    gs/base/gsutil.h
    gs/base/gxacpath.c
    gs/base/gxblend1.c
    gs/base/gxclip.c
    gs/base/gxclipm.c
    gs/base/gxclist.c
    gs/base/gxclrast.c
    gs/base/gxcmap.c
    gs/base/gxdevcli.h
    gs/base/gxdevice.h
    gs/base/gxi12bit.c
    gs/base/gxicolor.c
    gs/base/gximono.c
    gs/base/gxiscale.c
    gs/base/gxistate.h
    gs/base/gxpcmap.c
    gs/base/gxshade.c
    xps/xpsgradient.c


