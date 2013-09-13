# COLOR MANAGMENT
Created dimanche 08 avril 2012


### OPEN ICC
<http://www.freedesktop.org/wiki/OpenIcc>
<http://lists.freedesktop.org/archives/openicc/2012q1/004509.html>

#### Michael Sweet msweet at apple.com
Wed Jan 18 10:34:55 PST 2012

    Previous message: [Openicc] printer, driver, CUPS, PPD, printing GUI, ICC-profiles, colord, Oyranos, taxi....
    Next message: [Openicc] printer, driver, CUPS, PPD, printing GUI, ICC-profiles, colord, Oyranos, taxi....
    Messages sorted by: [ date ] [ thread ] [ subject ] [ author ]

On Jan 18, 2012, at 9:21 AM, Kai-Uwe Behrmann wrote:
> ...
> This is fine for selecting existing ICC profiles for well supported media. We want to create new ICC profiles for unsupported media, which likely need new driver calibration settings, as Robert and Edmund pointed out.

NOTE: IPP Everywhere DOES NOT DEFINE IMPLEMENTATION DETAILS SUCH AS "DRIVERS".  In fact, the whole goal is to eliminate drivers and have "smarter" printers.

So, if you have a new media you want the printer to advertise, you use Set-Printer-Attributes to register it with the printer, just like for profiles.

