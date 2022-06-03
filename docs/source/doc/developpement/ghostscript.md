# Ghostscript

## grayscale levels problem in 16-bit rasters

<http://comments.gmane.org/gmane.comp.printing.ghostscript.devel/2584>

Here's how I'm setting up the gx_device:

pdev->color_info.depth = 16;
pdev->color_info.max_gray = 65535;
pdev->color_info.max_color = 65535;
pdev->color_info.dither_grays = 65536;
pdev->color_info.dither_colors = 65536;

Can someone please explain what I am doing wrong?

____________________________________________________________________

Close, but the 'depth' is the total number of bits, so it should be

64 for 4 16 bit channels.

Also you need to set num_components (4 for CMYK) and polarity (a
gx_color_polarity_t enum, GX_CM_POLARITY_SUBTRACTIVE for CMYK)

Your initialization looks plausible. Note that for gradients and so on
you need to set a smaller smoothness parameter than the default to get
meaningful 16 bit output. Compare with the png48 device.I am experimenting with Ghostscript trying to create 16-bit output for grayscale, RGB and CMYK. The number of discrete gray levels appears to 
be wrong.

____________________________________________________________________

 I looked through the code for png48 and didn't see anything resembling a smoothness parameter. Why is grayscale only affected? RGB look ok

____________________________________________________________________

> For 16 bit, I'd recommend a smaller [smoothness] value such as 0.0005

It's a bug that the png48 device doesn't set this. Ray, do you have
any suggestions how to override the default? Can the open_device
method just call gs_setsmoothness()?

## Halftoning

Created mercredi 11 septembre 2013

* Makes use of SSE2 128bit registers to operate on 16 pixels at a time.

* Current support in trunk is for monochrome output devices only.
  For release 9.03 we should have in place support for high speed
  halftoning for CMYK planar devices.

### Permutation (DeviceN color model) [in gs device doc]

With no additional parameters, the device named "permute" looks to Ghostscript like a standard CMYK contone device, and outputs a PPM file, using a simple CMYK->RGB transform. This should be the baseline for regression testing.

With the addition of -dPermute=1, the internal behavior changes somewhat, but in most cases the resulting rendered file should be the same. In this mode, the color model becomes "DeviceN" rather than "DeviceCMYK", the number of components goes to six, and the color model is considered to be the (yellow, cyan, cyan, magenta, 0, black) tuple. This is what's rendered into the memory buffer. Finally, on conversion to RGB for output, the colors are permuted back.

As such, this code should check that all imaging code paths are 64-bit clean. Additionally, it should find incorrect code that assumes that the color model is one of DeviceGray, DeviceRGB, or DeviceCMYK.

Currently, the code has the limitation of 8-bit continuous tone rendering only. An enhancement to do halftones is planned as well. Note, however, that when testing permuted halftones for consistency, it is important to permute the planes of the default halftone accordingly, and that any file which sets halftones explicitly will fail a consistency check. 

## Line thickness

Thre are three switches which can be used to control line smoothing, etc.

-dGraphicsAlpaBits=4
-dTextAlphaBits=4
-dDOINTERPOLATE

See doc/Use.htm for more info on these switches.

However use of these switches in not recommended with the tiffg4 device. The tiffg4 device produces monochrome images with only two levels (white and black). To produce shades of gray, it halftones. These switches will produce halftone dots along lines, text, etc. This is generally not desired.

## Making a pdf grayscale with ghostscript

```bash
gs -sOutputFile=grayscale.pdf -sDEVICE=pdfwrite \
-sColorConversionStrategy=Gray -dProcessColorModel=/DeviceGray \
-dCompatibilityLevel=1.4 -dNOPAUSE -dBATCH color.pdf
```

source : <http://handyfloss.net/2008.09/making-a-pdf-grayscale-with-ghostscript/>

## Raster object tagging

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

see : **gslibctx.h :**

    /* GS graphical object tags */
    
    typedef enum {
    
    
    GS_DEVICE_DOESNT_SUPPORT_TAGS = 0, /* default */
    GS_UNKNOWN_TAG = 0x1,
    GS_TEXT_TAG = 0x2,
    GS_IMAGE_TAG = 0x4,
    GS_PATH_TAG = 0x8,
    GS_UNTOUCHED_TAG = 0x10
    } gs_object_tag_type_t;
    
    typedef struct gs_lib_ctx_s {
    
    gs_memory_t *memory;  /* mem->gs_lib_ctx->memory == mem */
    ...
    /* Define the default value of AccurateScreens that affects setscreen 
    and setcolorscreen. */
    bool screen_accurate_screens;
    bool screen_use_wts;
    uint screen_min_screen_levels;
    /* tag stuff */
    
    gs_object_tag_type_t BITTAG;
     ...
    
    }
    
    
    gsutil.h
    
    :
    
    #include "gslibctx.h"
    
    /* accessors for object tags */
    gs_object_tag_type_t 
    
    gs_current_object_tag(gs_memory_t *);
    
    #include "gxstate.h"
    
    #ifndef gs_imager_state_DEFINED
    #  define gs_imager_state_DEFINED
    typedef struct gs_imager_state_s gs_imager_state;
    #endif
    
    void gs_set_object_tag(gs_imager_state * pis, const gs_object_tag_type_t tag);
    void gs_enable_object_tagging(gs_memory_t *);
