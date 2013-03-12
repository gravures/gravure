#!/usr/bin/python
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
from gi.repository import Gtk
from matplotlib.figure import Figure
from matplotlib.backends.backend_gtk3cairo import FigureCanvasGTK3Cairo\
                                            as FigureGTKCanvas

from gravure.halftone import spotfunctions
from gravure.halftone.base import *


class MatPlotLibGTKWindow(Gtk.Window):

    def __init__(self, title="", application=None):
        Gtk.Window.__init__(self, application=application)

        # matplotlib
        self.figure = Figure()
        self.gtk_draw_area = FigureGTKCanvas(self.figure)
        self.add(self.gtk_draw_area)
        self.prepareFigure()

        # window config
        self.set_title(title)
        self.set_default_size(300, 200)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.show_all()

    def prepareFigure(self):
        f_axes = self.figure.gca(xlim=(-1.0,1.0), ylim=(-1.0,1.0))
        f_axes.spines['bottom'].set_position(('data',0))
        f_axes.spines['left'].set_position(('data',0))
        f_axes.spines['left'].set_color('black')
        f_axes.grid(True)
        #f_axes.box(on=True)

    def draw(self):
        self.figure.show()


class App(Gtk.Application):

    def __init__(self):
        Gtk.Application.__init__(self)

    def do_activate(self):
        self.topwin = MatPlotLibGTKWindow(application=self)
        self.topwin.show_all()

    def do_startup(self):
        Gtk.Application.do_startup(self)


def main():
    spot_f = spotfunctions.RoundDot()
    h_cell = Cell(8, 8)
    h_cell.setBuildOrder(BuildOrderSpotFunction(spot_f))
    h_cell.fill()
    print(spot_f)
    print(h_cell)
    #plotCell(h_cell)

    exit_code = App().run(sys.argv)
    sys.exit(exit_code)


if __name__ == '__main__':
    main()
