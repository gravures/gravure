================
Halftoning
================
| Created mercredi 11 septembre 2013


| - Recent inclusion of high speed halftoning with an 8 bit threshold array.
| - Makes use of SSE2 128bit registers to operate on 16 pixels at a time.
| - Current support in trunk is for monochrome output devices only.
|    For release 9.03 we should have in place support for high speed
|    halftoning for CMYK planar devices.

Permutation (DeviceN color model) [in gs device doc]
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

| With no additional parameters, the device named "permute" looks to Ghostscript like a standard CMYK contone device, and outputs a PPM file, using a simple CMYK->RGB transform. This should be the baseline for regression testing.

| With the addition of -dPermute=1, the internal behavior changes somewhat, but in most cases the resulting rendered file should be the same. In this mode, the color model becomes "DeviceN" rather than "DeviceCMYK", the number of components goes to six, and the color model is considered to be the (yellow, cyan, cyan, magenta, 0, black) tuple. This is what's rendered into the memory buffer. Finally, on conversion to RGB for output, the colors are permuted back.

| As such, this code should check that all imaging code paths are 64-bit clean. Additionally, it should find incorrect code that assumes that the color model is one of DeviceGray, DeviceRGB, or DeviceCMYK.

| Currently, the code has the limitation of 8-bit continuous tone rendering only. An enhancement to do halftones is planned as well. Note, however, that when testing permuted halftones for consistency, it is important to permute the planes of the default halftone accordingly, and that any file which sets halftones explicitly will fail a consistency check. 







