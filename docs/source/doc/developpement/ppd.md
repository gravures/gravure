PPD
===

## Cups ppd extensions

<http://www.cups.org/documentation.php/doc-1.6/spec-ppd.html#CONSTRAINTS>

#### Some Cups Supported Page Device Attributes

**cupsRenderingIntent**     String     Specifies the color rendering intent.     <</cupsRenderingIntent (AbsoluteColorimetric)>>setpagedevice

**cupsPreferredBitsPerColor**     Integer     Specifies the preferred number of bits per color, typically 8 or 16.     <</cupsPreferredBitsPerColor 16>>setpagedevice
**cupsCompression**     Integer     Specifies a driver compression type/mode.     <</cupsCompression 2>>setpagedevice
**Separations**     Boolean     Specifies whether to produce color separations.     <</Separations true>>setpagedevice
**MediaWeight**     Integer     Specifies the media weight in grams per meter2.     <</MediaWeight 100>>setpagedevice
**MirrorPrint**     Boolean     Specifies whether to flip the output image horizontally.     <</MirrorPrint true>>setpagedevice
**NegativePrint**     Boolean     Specifies whether to invert the output image.     <</NegativePrint true>>setpagedevice
**Orientation**     Integer     Specifies the orientation of the output: 0 = portrait, 1 = landscape rotated counter-clockwise, 2 = upside-down, 3 = landscape rotated clockwise.     <</Orientation 3>>setpagedevice

## cupsFilter

``*cupsFilter: "source/type cost program"``

This string keyword provides a conversion rule from the given source type to the printer's native format using the filter "program". If a printer supports the source type directly, the special filter program "-" may be specified.

**Examples**:

    *% Standard raster printer driver filter
    *cupsFilter: "application/vnd.cups-raster 100 rastertofoo"
    
    *% Plain text filter
    *cupsFilter: "text/plain 10 texttofoo"
    
    *% Pass-through filter for PostScript printers
    *cupsFilter: "application/vnd.cups-postscript 0 -"

## cupsFilter2

``*cupsFilter2: "source/type destination/type cost program"``

This string keyword provides a conversion rule from the given source type to the printer's native format using the filter "program". If a printer supports the source type directly, the special filter program "-" may be specified. The destination type is automatically created as needed and is passed to the filters and backend as the FINAL_CONTENT_TYPE value.

> __Note:__
> __    The presence of a single cupsFilter2 keyword in the PPD file will hide any cupsFilter keywords from the CUPS scheduler. When using cupsFilter2 to provide filters specific for CUPS 1.5 and later, provide a cupsFilter2 line for every filter and a cupsFilter line for each filter that is compatible with older versions of CUPS.__

**Examples**:

    *% Standard raster printer driver filter
    *cupsFilter2: "application/vnd.cups-raster application/vnd.foo 100 rastertofoo"
    
    *% Plain text filter
    *cupsFilter2: "text/plain application/vnd.foo 10 texttofoo"
    
    *% Pass-through filter for PostScript printers
    *cupsFilter2: "application/vnd.cups-postscript application/postscript 0 -"

## cupsPreFilter

``*cupsPreFilter: "source/type cost program"``

This string keyword provides a pre-filter rule. The pre-filter program will be inserted in the conversion chain immediately before the filter that accepts the given MIME type.

**Examples**:

    *% PDF pre-filter
    *cupsPreFilter: "application/pdf 100 mypdfprefilter"
    
    *% PNG pre-filter
    *cupsPreFilter: "image/png 0 mypngprefilter"

## cupsManualCopies

``*cupsManualCopies: boolean``

This boolean keyword notifies the RIP filters that the destination printer does not support copy generation in hardware. The default value is false.

**Example**:

    *% Tell the RIP filters to generate the copies for us
    *cupsManualCopies: true

## Extract from a xerox.ppd

*NonUIOrderDependency

*ColorDevice: True
*DefaultColorSpace: CMYK
*AccurateScreensSupport: True
*DefaultGuaranteedMaxSeparations: 4

*DefaultHalftoneType: 9
*ScreenFreq: "60.0"
*ScreenAngle: "45.0"
*DefaultScreenProc: Dot
*ScreenProc Dot: "{180 mul cos exch 180 mul cos add 2 div} bind"
*DefaultTransfer: Null
*Transfer Null: "{ }"
*Transfer Null.Inverse: "{1 exch sub} bind"

*DefaultColorSep: ProcessBlack.60lpi.600dpi/60 lpi / 600 dpi

## Adobe PPD specifications

### System management and local customisation ppd

One approach to system management is for a print manager to parse all of the
PPD files available on a host system and store the data into a database. The
print manager (or other utilities) can then query the user or the device or
watch for system changes and update the database dynamically to reflect
additional memory, fonts, available trays, and other changeable printer fea-
tures.
A less dynamic approach is provided in this specification by local customiza-
tion files, which contain only the changed or added items and a reference to
the primary PPD file. In a given computing environment, there is usually one
PPD file for each type or model of device in use. For example, there may be
seven Acme FunPrinters in the system, but there is usually only one Acme
FunPrinter PPD file, which is shared by or copied onto each host computer in
the system. However, if applications or users want to add to or modify the
contents of a PPD file, they can create a local customization file for a specific
instance of a device or for use by a particular application.

The local customization file should generally contain only entries only for
items that are changed or added. However, to be understood by applications
parsing PPD files, the local customization file must conform to the PPD spec-
ification, so in a sense, the local customization file is a minimal PPD file. The
minimal set of required keywords listed in section 3.8 must be included at the
beginning of the file, so print managers can recognize it as a PPD file. Other
keywords that are marked Required in this specification, such as *PageSize, are
not required in the local customization file, unless they are being customized.

The customization file should be given a unique name that represents a par-
ticular device (for example, MyPrntr.PPD). The .PPD extension should be
preserved, with case irrelevant, in case applications or print managers are
searching for files with that extension. Application developers can also create
customization files with different extensions, which are read only by their
application.

The local customization file must contain a reference to the primary PPD file
in this format:

``*Include: "filename"``

Before creating a local customization file, a system administrator should
make sure that computing environment provides support for the concept.
Some print managers might not process the *Include statement, or the system
might not provide a way to install both the primary PPD file and the local
customization file.

When a primary PPD file is included by a local customization file, the pars-
ing details change somewhat. In particular, there might be several instances
of the same keyword in the “composite” file. In this case, the first instance
of a given keyword (or, if the keyword takes an option, of a keyword-
option pair) is correct. This enables a parser to ignore subsequent versions
of the same statement, possibly reducing the parsing time.

Because the first instance of a keyword is the correct instance, all keywords
in a local customization file should occur before the *Include statement that
references the primary PPD file.For example, assuming the primary PPD file
is called TIMICRO1.PPD, a local customization file might look like this

    *% Local Customization File for TI microLaser
    *FreeVM: "1907408"
    *Include: "TIMICRO1.PPD"
    *% end of local customization file

### default values

The defaults listed in the original PPD file reflect the state of the device when
it is shipped from the factory. If the system administrator wants to set up the
device differently, the new defaults should be included in the local customiza-
tion files. For example, if the device in the previous example was set up to
always feed from the manual feed slot, then the local customization file
should contain the entire *ManualFeed entry, copied from the original PPD file,
with the value of *DefaultManualFeed changed from False to True:

    *OpenUI *ManualFeed: Boolean
    *OrderDependency: 20 AnySetup *ManualFeed
    *DefaultManualFeed: True
    *ManualFeed True: “code”
    *ManualFeed False: “code”
    *?ManualFeed: “query code”
    *CloseUI: *ManualFeed

This allows the print manager to indicate in the user interface that manual
feeding of the media on this device is, by default, turned on.

### relationship between default keywords and keywords

Default keywords start with the prefix *Default, as in *DefaultPageSize. Where
applicable, there is a relationship between the three kinds of main keywords,
as in *PageSize, *DefaultPageSize, and *?PageSize. However, there is no require-
ment for a *Default keyword to have corresponding main and query keywords
in a PPD file. A *Default keyword may appear alone if it makes sense.
There is also a relationship between keywords that start with the prefix
*Param, as in *ParamCustomPageSize, and the associated root keyword
(*CustomPageSize, in this case). The prefix *Param signifies that this keyword
documents parameters needed by the root keyword. See *CustomPageSize and
*ParamCustomPageSize for more explanation.

### new main keywords

If a main keyword is not recognized, the entire statement (including multi-
line code segments) should be skipped. However, read section 5.2 and
keep in mind that the point of the *OpenUI/*CloseUI structures is to allow new
main keywords to appear without a print manager explicitly recognizing
them. The most functionality will be provided to the user if a print man-
ager handles all main keywords that occur within the *OpenUI/*CloseUI struc-
ture, displaying them and invoking their associated code to the best of its
ability. Unrecognized main keywords that occur outside of the *OpenUI/*Clo-
seUI structure should be skipped.

### options keywords

An option keyword is terminated by a colon or a slash if there is a translation
string (see section 3.5 for information on translation strings). There is no
escape mechanism for the forbidden characters listed above.
Option keywords can have extensions called qualifiers. Qualifiers are
appended to option keywords with the . (period) character (decimal
ASCII 46) as a separator. Any number of these qualifiers can be appended to
an option keyword, as appropriate. For example:
    *PageSize Letter
    *PageSize Letter.Transverse
    *PageSize Letter.2

In this example, qualifiers are used to differentiate between several instances
of a particular media type that differ only slightly. For example, the .Transverse
qualifier signifies that Letter differs from Letter.Transverse only in the direction
that the media is fed into the device.

### Type of options values

There are five basic types of values:

* InvocationValue
* QuotedValue
* SymbolValue
* StringValue
* NoValue

#### SymbolValue

A SymbolValue is used as pointer to a body of PostScript language code (an
InvocationValue). A SymbolValue can occur in a statement whether or not
there is an option keyword present.
A SymbolValue starts with a caret ^ (decimal 94)

### comments

Comments are supported in the PPD files using the main keyword ‘*%’. Any-
thing following this main keyword (through the end of the line on which it
appears) should be ignored by a parsing program. The * character is the same
introductory symbol used for all main keywords, and the % character is bor-
rowed from PostScript language syntax as its comment character. These com-
ments will begin only in column one, for simplicity.
There can also be comments in any PostScript language code, using the stan-
dard syntax of starting the comment with a %. Comments in code should be
kept to a minimum, however, to reduce transmission time.

### PostScript Language Sequences

The PostScript language sequences supplied for invoking device features are
usually represented as InvocationValues. Sometimes they are represented as
QuotedValues, for example, when they contain binary data.

For multiple-line InvocationValues or QuotedValues, the main keyword *End
is used as an extra delimiter to help line-extraction programs (such as grep or
awk in UNIX). The keyword *End also makes the PPD file more easily read-
able by humans, because the double quote delimiter is sometimes difficult to
see at the end of a long string of code.
*End is used only when the code requires more than one line in the PPD file.
In the following two examples, the *PageSize statement fits on one line and
does not require *End. The *?Smoothing statement is an “extended” code
sequence that does require *End:

    *PageSize Legal: "serverdict begin legaltray end"
    
    *?Smoothing: "save
    [(None)(Light)(Medium)(Dark)]
    statusdict /doret {get exec}
    stopped { pop pop (Unknown)} if
    = flush restore"
    *End
