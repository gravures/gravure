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
from matplotlib.backends.backend_gtk3cairo import FigureCanvasGTK3Cairo as FigureGTKCanvas

from halftone import spotfunctions
from halftone.base import *


class MatPlotLibGTKWindow(Gtk.Window):
    """An abstract base class for a matplotlib drawing widget.

    Extend Gtk.Window, and have a matplotlib.Figure attribute as an handle
    to the matplotlib API. This window have a Gtk.DrawingArea on wich
    a gtk3cairo Matplotlib backend make the plot.

    """

    def __init__(self, title="", application=None):
        Gtk.Window.__init__(self, application=application)

        # matplotlib
        self.figure = Figure()
        self.gtk_drawing_area = FigureGTKCanvas(self.figure)
        self.add(self.gtk_drawing_area)

        # window config
        self.set_title(title)
        self.set_default_size(600, 600)
        self.set_position(Gtk.WindowPosition.CENTER)

    def prepareFigure(self):
        raise notImplementedError

    def draw(self):
        pass
        #self.figure.show()


class CellViewer(MatPlotLibGTKWindow):
    """A Gtk Window to view an halftone cell."""

    def __init__(self, cell, application=None):
        if cell is None :
            raise AttributeError("cell should not be None")
        MatPlotLibGTKWindow.__init__(self, title="Cell view", application=application)
        self.cell = cell
        self.prepareFigure()
        self.draw()
        self.show_all()

    def prepareFigure(self):
        """Draw axes, ticks, and pixels shape of the cell"""
        # axes
        f_axes = self.figure.gca(xlim=(-1.5,1.5), ylim=(-1.5,1.5))
        f_axes.spines['bottom'].set_position(('data',-1.5))
        f_axes.spines['left'].set_position(('data',-1.5))
        f_axes.spines['left'].set_color('black')

        # x-ticks
        cn = self.cell.normSpace
        xt = [p.x for p in cn[0:self.cell.width]]
        f_axes.set_xticks(xt)

        # y-ticks
        yt = []
        for i in range(0, len(cn), self.cell.width):
            yt.append(cn[i].y)
        f_axes.set_yticks(yt)

        f_axes.grid(True)
        #f_axes.box(on=True)

        # draw pixel limit
        ix = (xt[1] - xt[0]) / 2
        iy = (yt[1] - yt[0]) / 2
        xt.append(xt[-1:][0] + (2 * ix))
        f_axes.vlines([x - ix for x in xt], -1 - iy, 1 + iy)
        yt.append(yt[-1:][0] + (2 * iy))
        f_axes.hlines([y - iy for y in yt], -1 - ix, 1 + ix)

    def plotWhiteningOrder(self):
        pass

    def plotCellData(self):
        pass


class App(Gtk.Application):

    def __init__(self):
        Gtk.Application.__init__(self)
        self.test()

    def test(self):
        spot_f = spotfunctions.RoundDot()
        self.h_cell = Cell(8, 8)
        self.h_cell.setBuildOrder(BuildOrderSpotFunction(spot_f))
        self.h_cell.fill()
        print(spot_f)
        print(self.h_cell)

    def do_activate(self):
        self.topwin = CellViewer(self.h_cell, application=self)
        self.topwin.show_all()

    def do_startup(self):
        Gtk.Application.do_startup(self)


def main():
    exit_code = App().run(sys.argv)
    sys.exit(exit_code)


if __name__ == '__main__':
    main()
