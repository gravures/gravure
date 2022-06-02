# -*- coding: utf-8 -*-

# Copyright (C) 2011 Atelier Obscur.
# Authors:
# Gilles Coissac <dev@atelierobscur.org>

# This program is free software; you can redistribute it and/or modify
# it under the terms of version 2 of the GNU General Public License
# as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License with
# the Debian GNU/Linux distribution in file /usr/share/common-licenses/GPL;
# if not, write to the Free Software Foundation, Inc., 51 Franklin St,
# Fifth Floor, Boston, MA 02110-1301, USA.

import sys
import time
from threading import Thread,  Lock
from gi.repository import Gtk, Gio,  GLib, GObject

#TODO: change to normal import in futur
import cython
import pyximport; pyximport.install()
import halftone.stoch as stoch
from halftone import spotfunctions
from core.property import *

#
# Application ProptyList
#
plist = PropertyList(name="Stochastic Screener", description=None)
plist.append(Property(name="dotsize",              datatype=inttype,    valuerange=(1,30),  value=8))
plist.append(Property(name="minblackdot",      datatype=inttype,    valuerange=(1,30), value=4))
plist.append(Property(name="minwhitedot",      datatype=inttype,    valuerange=(1,30),  value=2))
plist.append(Property(name="dotshape",           datatype=strlisttype, valueslist=spotfunctions.__all__[1:],  value=spotfunctions.__all__[1:][0]))
plist.addgroup(name="Dot specification", start=0, end=4)
#
plist.append(Property(name="threshold",         datatype=inttype,    valuerange=(0,100),  value=50))
plist.append(Property(name="bias",                  datatype=floattype, valuerange=(1,10),    value=1))
plist.append(Property(name="seed",                 datatype=inttype,    valuerange=(1,1000),value=5))
plist.append(Property(name="fudgediagonal",  datatype=booltype,  value=False))
plist.addgroup(name="Matrice", start=4, end=8)
plist.dump()


class fmscreener(object):

    def __init__(self):
        self.screener = None

        # Main window
        window = Gtk.Window()
        window.set_title("FM Screener")
        window.set_default_size(500, 800)
        window.set_position(Gtk.WindowPosition.CENTER)
        window.connect("destroy", self.destroy)

        window.show_all()

    def destroy(self, window):
        if self.screener is not None:
            self.screener.stop()
        Gtk.main_quit()









def main(args):
    GObject.threads_init()
    app = fmscreener()
    Gtk.main()

if __name__ == "__main__":
    sys.exit(main(sys.argv))


