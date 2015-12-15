================
Gutenprint library
================
| Created dimanche 09 novembre 2014

Drop size selection
"""""""""""""""""""
| There are three new settings, Drop Size
| Small, Drop Size Medium, and Drop Size Large, that can be used to
| specify the relative sizes of the three drops.  The screening code
| assumes that the ratios specified relate to the number of drops of
| each size that will produce a constant darkness; sizes of 0.25,
| 0.5, and 1.0 mean that 4 small drops are treated as equivalent to 2
| medium drops or 1 large drop.

| - The largest drop size you want active should be set to 1.
|  Normally that means the large drop size.  However, if you don't
|  want to use the large drop size (at very high resolution), you
|  may set one of the smaller drops to 1.

| - A drop size of 0 is not used.  So if you set the large drop size
|  to 1, the small drop size to 0.25, and the medium drop size to 0,
|  only the small and large drops will be used.

| - Drop sizes should be specified in ascending order, other than
|  drops of 0 size.  For example, you should not set the small drop
|  size to 0.5 and the medium drop size to 0.25.  If you do, the
|  results are undefined.

Light ink value options
"""""""""""""""""""""""
| These options, which are available for
| whichever light inks are available on the particular printer, can
| be used to set the intensity relative to the dark ink.  "Intensity"
| means the inverse of the amount of ink required to achieve a
| particular darkness.  For example, a Light Cyan Value of 0.25 means
| that the driver will trade off 4 drops of light ink for 1 drop of
| dark ink.

Light ink transition options
""""""""""""""""""""""""""""
| These options, which are available
| for each channel with light inks, specify at what point the driver
| will start using dark ink.  This is expressed as a fraction of the
| intensity of the light ink.  For example, if Light Cyan Transition
| is set to 0.40, the driver will start using dark ink when the
| amount of light ink reaches 40%.  So and the Light Cyan Value is
| 0.25, the driver will start using dark ink at 0.1 (6554 on a raw
| scale of 0-65535).

Light ink scaling options
"""""""""""""""""""""""""
| These options replace the previous
| light ink transition options, which basically just adjusted the
| density of the light ink relative to the dark ink.  I expect that
| these will be the least useful of the new options, but I may be
| wrong.

Raw
"""
| if you want to adjust all the settings manually.  In Raw color
| correction mode, there will be no automatic correction of any
| kind, including density adjustment.  If you're not careful, you
| may find yourself using an excessive amount of ink with this
| setting.  You will need to adjust the Density control or the
| controls for the densities of the individual colors.  You may want
| to use this to establish custom densities and ink limits to
| achieve maximum gamut.

Density
"""""""
| if you want to use Gutenprint's choice of density, but
| otherwise have no automatic color correction applied.  This choice
| of setting should be safe (at least in RGB mode; in CMYK mode it's
| possible for too much ink to be applied).  This is useful if
| you're satisfied with Gutenprint's default ink limits, but want to
| adjust the linearization yourself.

Uncorrected
"""""""""""
| if you want to use Gutenprint's choice of
| linearization, but otherwise have no cross-channel correction
| applied.  If you're satisfied with Gutenprint's linearization and
| want to profile the driver, this may be a good selection.

devicen
"""""""
| And how to deal with multicolor printers? Do I understand
| correctly, that there is currently no print mode available, which
| accepts "DeviceN" input (i.e. one input channel for each ink)?

| Yes there is, actually -- see src/testpattern to see how to use it.
| If someone wants to do N-channel linearization and RGB->DeviceN or
| CMYK->DeviceN, it will work just fine with Gutenprint (if they have a
| way of talking to the driver).



