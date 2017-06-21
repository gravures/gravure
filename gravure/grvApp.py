# -*- coding: utf-8 -*-

# Copyright (C) 2011 Atelier Obscur.
# Authors:
# Gilles Coissac <gilles@atelierobscur.org>

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
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk


class GrvApp(Gtk.Application):

    def __init__(self):
        Gtk.Application.__init__(self)

    def do_activate(self):
        self.topwin = Gtk.ApplicationWindow(application=self)
        #self.win1 = Gtk.Window()
        #self.win2 = Gtk.Window()
        self.topwin.show_all()
        #self.win1.show_all()
        #self.win2.show_all()

    def do_startup(self):
        Gtk.Application.do_startup(self)


def main():
    app = GrvApp()
    exit_code = app.run(sys.argv)
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
