# WTS & GEN ORDERED
Created jeudi 18 octobre 2012


suppression de WTS et créations des trames en externe 
<http://bugs.ghostscript.com/show_bug.cgi?id=691883>


**2011-11-15 11:26:36 -0800**
Michael Vrhel <[michael.vrhel@artifex.com](mailto:michael.vrhel@artifex.com)>
[27806596e3c2820064788bba903cc569ce89f1e7](http://git.ghostscript.com/?p=ghostpdl.git;a=commitdiff;h=27806596e3c2820064788bba903cc569ce89f1e7)
    __Removal of WTS from code.__
    Plan is to suggest the use of screens generated with gs\toolbin\halftone\gen_ordered
-----------------------------------------------------------------------------------------------------------------------------------------
**2011-11-14 22:37:28 -0800**
Michael Vrhel <[michael.vrhel@artifex.com](mailto:michael.vrhel@artifex.com)>
[f0b1c2aefaed5ba17fea69848c0b5489b541c4cf](http://git.ghostscript.com/?p=ghostpdl.git;a=commitdiff;h=f0b1c2aefaed5ba17fea69848c0b5489b541c4cf)
    Clarification of the gen_ordered settings and README.
    The current default value for -s (size of the super cell) is 1
    which indicates that them smallest possible size should be used.
    This occurs regardless of the requested quantization levels.
    This is clarified in the README and a message is displayed
    during the creation of the screen providing a minimum suggested
    value for -s to achieve the number of requested levels.
    gs/toolbin/halftone/gen_ordered/README
    gs/toolbin/halftone/gen_ordered/gen_ordered.c 
-----------------------------------------------------------------------------------------------------------------------------------------
**2011-11-10 11:08:56 -0800**
Ray Johnston <[ray.johnston@artifex.com](mailto:ray.johnston@artifex.com)>
[108bf3d9fd2770c1b97a4eabcd4f09dd13c7fe18](http://git.ghostscript.com/?p=ghostpdl.git;a=commitdiff;h=108bf3d9fd2770c1b97a4eabcd4f09dd13c7fe18)
    Fix several problems with the 16-bit PS output from gen_ordered.
    CLUSTER_UNTESTED
    gs/toolbin/halftone/gen_ordered/gen_ordered.c 
-----------------------------------------------------------------------------------------------------------------------------------------
**2011-11-10 10:35:57 -0800**
Ray Johnston <[ray.johnston@artifex.com](mailto:ray.johnston@artifex.com)>
[73770f28c263a514a318aa91af24b26814062bd1](http://git.ghostscript.com/?p=ghostpdl.git;a=commitdiff;h=cde0561c8ffc71c231a0aeff399852c43ab7a9e8)
    Change options and README for gen_ordered.c and fix 16-bit PS output.
    Also add check for missing value for an option (get_arg returning NULL) and add specific 'format' for
    16-bit .raw (raw16) (reserving the -b option for number of bits 1, 2, 4) for multi-level threshold
    arrays.
    CLUSTER_UNTESTED
    gs/toolbin/halftone/gen_ordered/README
    gs/toolbin/halftone/gen_ordered/gen_ordered.c 
-----------------------------------------------------------------------------------------------------------------------------------------
**2011-11-10 09:01:28 -0800**
Ray Johnston <[ray.johnston@artifex.com](mailto:ray.johnston@artifex.com)>
[cde0561c8ffc71c231a0aeff399852c43ab7a9e8](http://git.ghostscript.com/?p=ghostpdl.git;a=commitdiff;h=cde0561c8ffc71c231a0aeff399852c43ab7a9e8)
    Move the ordered dither screen creation tool to toolbin/halftone/gen_ordered.
    Previously this was buried under the toolbin/color directory. Also by putting it into gen_ordered, we
    prepare for the addition of gen_stochastic and threshold_remap tools related halftone tools. Michael
    Vrhel as agreed with this change.
    CLUSTER_UNTESTED 
-----------------------------------------------------------------------------------------------------------------------------------------
**2011-10-18 22:12:24 -0700**
Michael Vrhel <[michael.vrhel@artifex.com](mailto:michael.vrhel@artifex.com)>
[357009d7fc55166a6e8f9da539e1f785d05e9b6c](http://git.ghostscript.com/?p=ghostpdl.git;a=commitdiff;h=357009d7fc55166a6e8f9da539e1f785d05e9b6c)
    Maintain 16bit precision in threshold array creation.
    Also add option to output either 8bit or 16bit data
    including a type 16 halftone dictionary
    gs/toolbin/color/halftone/halfttoning/halftone.c 
-----------------------------------------------------------------------------------------------------------------------------------------
**2011-10-17 20:48:26 -0700**
Michael Vrhel <[michael.vrhel@artifex.com](mailto:michael.vrhel@artifex.com)>
[bcfc1a94c76d84511cec09673e220b8bf15823e9](http://git.ghostscript.com/?p=ghostpdl.git;a=commitdiff;h=bcfc1a94c76d84511cec09673e220b8bf15823e9)
    Make it possible to output turn on sequence for ordered dithered screens
    This enables us to use the linearize_threshold program that Ray wrote to apply a TRC
    to our screen.
    gs/toolbin/color/halftone/halfttoning/halftone.c 
-----------------------------------------------------------------------------------------------------------------------------------------
**2011-10-17 15:57:50 -0700**
Michael Vrhel <[michael.vrhel@artifex.com](mailto:michael.vrhel@artifex.com)>
[253285f2a4cb681d601817185d6dba083d8b117e](http://git.ghostscript.com/?p=ghostpdl.git;a=commitdiff;h=253285f2a4cb681d601817185d6dba083d8b117e)
    Addition of support for different vertical and horizontal resolution in ordered dithered screen creation.
    The support for this was already in place in the code. It was only was a matter of getting the parameters set.
    gs/toolbin/color/halftone/halfttoning/halftone.c 
-----------------------------------------------------------------------------------------------------------------------------------------
**2011-10-14 23:00:03 -0700**
Michael Vrhel <[michael.vrhel@artifex.com](mailto:michael.vrhel@artifex.com)>
[2e92d2916a189d19213d830956a2e02f7cfb6872](http://git.ghostscript.com/?p=ghostpdl.git;a=commitdiff;h=2e92d2916a189d19213d830956a2e02f7cfb6872)
    Addition of dot shape specification in ordered dither screen threshold array creation.
    This provides a number of example dot shapes including, circles, diamonds, lines and
    inverted circles. Also cleaned up the code a bit.
    gs/toolbin/color/halftone/halfttoning/halftone.c 
-----------------------------------------------------------------------------------------------------------------------------------------
**2011-10-11 10:02:48 -0700**
Michael Vrhel <[michael.vrhel@artifex.com](mailto:michael.vrhel@artifex.com)>
[e96836194b0eb6085f59d41feb445d60f946dda9](http://git.ghostscript.com/?p=ghostpdl.git;a=commitdiff;h=e96836194b0eb6085f59d41feb445d60f946dda9)
    Fix of bugs in halftone ordered screen creation code
    This fixes several bugs. Including fixes for issues with modulo operation on negative numbers,
    integer division, faulty logic that prevented maximum lpi screens and non-dithered ordered screens.
    gs/toolbin/color/halftone/halfttoning/halftone.c 
-----------------------------------------------------------------------------------------------------------------------------------------
**2011-03-11T04:15:39.316030Z Michael Vrhel**
    A reorganization of the halftone code in preparation of doing thresholding of color images.  This basically pulls out some code pieces that will be shared in all the image thresholding cases.  No differences expected (or seen in the cluster push).
    [base/gxht_thresh.h base/lib.mak base/gximono.c base/gxicolor.c base/gxht_thresh.c]
-----------------------------------------------------------------------------------------------------------------------------------------
**2011-03-03T17:51:48.590954Z Michael Vrhel**
    Enabling of thresholding code as default image rendering of monochrome/indexed images for monochrome devices.  This will result in about 2432 differences reported.  I stepped through them in a bmpcmp to check for serious issues.  The minor halftone differences were due to the fact that we step in the device space for pixel replication in the threshold code but step in source space for the rect fill code.  Enabling this code now will make it easier to track issues as we expand the use of the thresholding code.
    [base/gximono.c]
-----------------------------------------------------------------------------------------------------------------------------------------
**2011-03-02T18:51:23.645025Z Michael Vrhel**
    Introduction of a member variable in gs_image1_t, which will let us know the original source type of the image.  For example if, the parent source were type3 this spawns two type1 images.  One for the mask and one for the image data.  The mask is rendered using image render simple.  If the image is monochrome or indexed, it is rendered with the renderer in gximono.c .   If we are going to a halftone monochrome device, we end up using the fast threshold based renderer which has its interpolation stepping in device space as opposed to source space.  This causes very minor differences between the mask and the image data.  To avoid this, we use the old rect_fill code for the image type3 data to ensure a more exact spatial match.
    [base/gximono.c base/gximage1.c base/gximage2.c base/gximage3.c base/gximage4.c base/gximage.h base/gximag3x.c base/gsiparam.h]
-----------------------------------------------------------------------------------------------------------------------------------------
**2011-02-28T05:23:46.157854Z Michael Vrhel**
    Fix for mis-scale on decode for render mono cache.  Fixes improper rendering of 148-11.ps with new halftone code.
    [base/gxipixel.c]
-----------------------------------------------------------------------------------------------------------------------------------------
**2011-02-27T23:26:10.406657Z Michael Vrhel**
    Removal (or inactivation) of code to include inverse of transfer function in the threshold values.  Also minor fix for scaling issue in halftone code in portrait mode.  Code is inactive so no regression diffs expected.
    [base/gximono.c base/gsht.c]
-----------------------------------------------------------------------------------------------------------------------------------------
**2011-02-22T19:52:43.275685Z Michael Vrhel**
    Merge of halftone branch into the trunk.  The new rendering code is actually disabled with this commit.  As such, there should not be any testing differences.
    [base/gxipixel.c base/lib.mak base/Makefile.in base/gxcie.h /trunk/gs base/gsht.c base/gxcmap.c psi/msvc.mak ghostscript.vcproj base/gximono.c base/gzht.h base/gxidata.c base/configure.ac base/gxdht.h base/gxcmap.h base/gxicolor.c base/gximage.h base/gsciemap.c]
-----------------------------------------------------------------------------------------------------------------------------------------
**2011-01-11T21:33:54.972732Z Michael Vrhel**
    Fix for a number of issues found by Ray with the halftone creation tool.  
    These include a crash for a divide by zero in the gcd function (caused failure at 0 degree screen generation)
    Fix so that the Holladay screen is no longer created as an output option.
    Fix in  ppm output header.
    Fix in how the lpi is selected.
    Fix for when we have a screen that has essentially one dot (also caused a crash).
    Addition of a ReadMe.

    A lot more testing is needed, in particular, the dithering of the dots in the macro-screens needs additional testing and the relationship between the desired number of quantization levels and the size of the screen needs to be properly computed.  There is a list of features that need to be added described in the ReadMe.  
    [toolbin/color/halftone/halfttoning/halfttoning.vcproj toolbin/color/halftone/README toolbin/color/halftone/halfttoning/halftone.c]
-----------------------------------------------------------------------------------------------------------------------------------------
**2011-01-11T01:17:59.815496Z Ray Johnston**
    Add output modes for PostScript HalftoneType 3 threshold arrays (-ps) and
    PPM files (-ppm) that have the width in the file rather than only encoded
    in the filename. The -ppm mode is untested and marginally useful.
    The -ps mode was tested (on Windoze) with:
    toolbin/color/halftone/Debug/halfttoning.exe -ps -r 300 -l 23 -a 45
    gswin32c -r300 -dDisplayFormat=16#20102 -c "(Screen_Holladay_Shift10_20x10.ps) \
     run sethalftone (examples/tiger.eps) run"
    The result doesn't look very good, but at least it runs and we can examine
    the problems.
    [toolbin/color/halftone/halfttoning/halftone.c]
-----------------------------------------------------------------------------------------------------------------------------------------
**2010-12-22T18:48:13.456231Z Michael Vrhel**
    Initial commit of code for creating halftone screens.  This code needs additional debugging, especially in the case of edge parameters.  It will currently create threshold arrays based upon desired lpi, angle, quantization levels, and device resolution.  The method is restricted to angles that are the arctangent of rational numbers. Every attempt is made to achieve the requested lpi by using the rational angle that achieves an lpi over the requested value.  Since there is a trade off between lpi and quantization levels, the requested quantization levels are obtained through dithering of the dot cells within the supercell.  Essentially, the dots within the supercell do not all take on the same values and can grow at different rates in a visually pleasing manner.  There is still a bit of work to do still on this dithering as well as controlling the rate of growth for the dots.
    [toolbin/color/halftone toolbin/color/halftone/halfttoning.sln toolbin/color/halftone/halfttoning/halfttoning.vcproj toolbin/color/halftone/halfttoning toolbin/color/halftone/halfttoning/halftone.c]
-----------------------------------------------------------------------------------------------------------------------------------------
**2010-07-18T05:30:08.091459Z Alex Cherepanov**
    Implement halftones type 6, 10, 16 in PDF interpreter.
    Use default halftone when the halftone type is incorrect.
    [Resource/Init/pdf_draw.ps]



