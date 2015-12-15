================
Line thickness
================
| Created jeudi 10 décembre 2015


| Thre are three switches which can be used to control line smoothing, etc.

| -dGraphicsAlpaBits=4
| -dTextAlphaBits=4
| -dDOINTERPOLATE

| See doc/Use.htm for more info on these switches.

| However use of these switches in not recommended with the tiffg4 device. The tiffg4 device produces monochrome images with only two levels (white and black). To produce shades of gray, it halftones. These switches will produce halftone dots along lines, text, etc. This is generally not desired.

