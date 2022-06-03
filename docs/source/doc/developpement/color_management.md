Color Management System
===

<http://www.openicc.info/>
<https://www.ppmag.com/reviews/200501_rodneycm.pdf>
<http://ninedegreesbelow.com/>

## littlecms

Little CMS intends to be an OPEN SOURCE small-footprint color management engine, with special focus on accuracy and performance. It uses the International Color Consortium standard (ICC), which is the modern standard when regarding to color management. The ICC specification is widely used and is referred to in many International and other de-facto standards. It was approved as an International Standard, ISO 15076-1, in 2005.

**provide**: liblcms2, pgicc, linkicc, psicctificc, transicc

## SampleICC

*The ICC Software License, Version 0.2* | newBSD

IccProfLib (originally IccLib, but that conflicted with the Argyll library of
the same name) is both an ICC profile I/O library and a reference CMM.

**provide**: libSampleICC, IccApplyNamedCmm, IccAppplyProfiles, IccDumpProfile, IccGamutMapGirdle, IccGetBPCinfo, IccProfLibTest, IccRoundTrip, IccStripUnknowTags, IccV4ToMPE

**contrib:**
libICC_utils
create_CLUT_profile 
create_CLUT_profile_from_probe
create_display_profile
create_pretransform_curve
create_probe 
flatten_AToB_tag
round_trip_PCS_LAB
reconstruct_measurements
generate_device_code

## IccXML

IccLibXML library acts as an extension of SampleICC's IccProfLib.
This extension provides Inherited classes for the classes in IccProfLib
that provide additional I/O routines to read and write the classes as
XML files.  As such, it provides the means of converting ICC profiles
into and out of an XML format

**provide**:
libiccXML
iccFromXml
iccToXml

## iccExamin

ICC Examin (unix name: iccexamin) is a viewer for the internals of a ICC profile, measurement data (CGATS), argylls gamut vrml visualisations and video card gamma tables. 

## ArgyllCms

## Oyranos

Oyranos is a Colour Management System (CMS) on operating system level. It allows to match predictably input device colours to output device colours across supporting applications. One goal is to make colour management useful for all users in a automated fashion and regardless of any technical knowledge.

## dcamprof

## Open ICC

<http://www.freedesktop.org/wiki/OpenIcc>
<http://lists.freedesktop.org/archives/openicc/2012q1/004509.html>

#### Michael Sweet msweet at apple.com

On Jan 18, 2012, at 9:21 AM, Kai-Uwe Behrmann wrote:

> ...
> This is fine for selecting existing ICC profiles for well supported media. We want to create new ICC profiles for unsupported media, which likely need new driver calibration settings, as Robert and Edmund pointed out.

NOTE: IPP Everywhere DOES NOT DEFINE IMPLEMENTATION DETAILS SUCH AS "DRIVERS".  In fact, the whole goal is to eliminate drivers and have "smarter" printers. So, if you have a new media you want the printer to advertise, you use Set-Printer-Attributes to register it with the printer, just like for profiles.

### Oyranos

<http://www.oyranos.org/2012/02/linux-printing/>
______________________________________________________________________--
On 01/29/2012 11:53 AM, edmund ronald wrote:

> Michael,
> 
>   *How* does CUPS on non-mac systems know about ICC profiles?
>   I have found your very clear and informative post here
> <http://lists.freedesktop.org/archives/openicc/2005q2/000208.html>
> which indicates that the *cupsiccprofile keyword in the PPD is the
> appropriate declaration on the Mac. Is this now generally supported?
>   Also, do non-mac distribs now have a filter called up by CUPS which
> then does the appropriate profile conversion?

AFAIK the only filter which does thid under Linux is gstoraster, a 
Ghostscript-based filter which turns PDF or PostScript into CUPS Raster. 
The filter is part of the Ghostscript package and to actually use it it 
must be taken care that its cost factors in the MIME conversion rules 
are lower than the factors of pdftoraster (Poppler-based filter). 
gstoraster reads out the *cupsiccprofile keywords in the PPD and makes 
Ghostscript applying the appropriate ICC profile if the profile is 
actually installed.

This naturally works only for CUPS-Rster based drivers, not for native 
PostScript printers or for foomatic-rip-based drivers for example.

______________________________________________________________________

[Openicc] Gutenprint mission ... Printer profiling workflow
Jan-Peter Homann homann at colormanagement.de
Tue May 15 01:30:12 PDT 2012

Previous message: [Openicc] Gutenprint mission as Linux moves towards color managed workflows
Next message: [Openicc] Gutenprint mission ... Printer profiling workflow
Messages sorted by: [ date ] [ thread ] [ subject ] [ author ]

Hello to all, some feedback from a non-developer:

The color transformation from the document space to printer colorspace 
can be done in several places:

- local application like e.g. gimp, scribus or other
- CUPS filter like e.g. GhostScript, Poppler
- Printer Driver like e.g. Turoprint

For working with printer profiles, it is necessary, that the whole chain 
application->CUPS-Filter->Driver is transparent to the enduser, and that 
the enduser can be shure, that there is no double or triple 
transformation of print data in the chain. Reaching such transparency is 
a very challinging tasks, which has not been solved till today in Mac OS 
X or Windows environments incl. Adobe applications and drivers of the 
main printer vendor.

Typical tasks for endusers are:

1) decide, where the printer profile should be used (application, 
   CUPS/Filter, Driver)

2) Configure the chain, to avoid double or triple color transformations

3) create or choose a printing queue / driver setting which relates to 
   the printer profile
   3a. Install a standard printer profile for this queue / setting 
   (This could be also a printer profile which have embedded driver settings)
   3b. Optionally print a testchart  for profiling
   
   From my experience of making printer profiles since 15 years, it makes 
   a lot of sense, that the tasks of:
- choosing the driver setting (optional with calibration / setup of inkl 
  limits, ...)
- printing the testchart
- measuring the testchart and calculating the printer profile
- connecting the printer profile and the driver settings

are done in very controlled environment. If possible I would prefer a 
solution which by passes CUPS and any filters and sends the testchart 
for profiling as bitmap data direct to the printer driver (e.g. 
Gutenprint).
(For shure it helps very much, if we have optional a controlled way to 
send profiling testcharts through the CUPS / Filter chain. If this is 
the case, I would recommend, that the printed testchart has an 
additional control slug / text line, which documents the color settings 
of the CUPS queue and all involved filters)

In a LINUX environment with ArgyllCMS and Gutenprint, I would prefer a 
special application, which guides the user through the differnt steps 
for profiling the printer and which has a direct connection to ArgyllCMS 
and Gutenprint.

A basic scenario for a first version of such applicazion could be:

- Choose a predefined Gutenprint setup (creating such setups and 
  calibration is a task for a future version)
- Choose your measurement instrument
- Choose the testchart
- Send the testchart as bitmap directly to Gutenprint
- Measure the testchart
- Calculate the printer profile automatically with ArgyllCMS
- Embedd the Gutenprint Settings as Metadata into the printer profile

Perfect would be, when the printer profile would be automatically 
configured in the printing enviroment. But this tasl is very dependend 
from the choosen printing environment. If Oyranos or colord is part of 
the printing enviroment and connected to the profiling application, the 
automatic configuration of the printer profile should be possible.

Best regards
Jan-Peter
