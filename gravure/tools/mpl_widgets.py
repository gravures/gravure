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

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
from matplotlib.figure import Figure
from matplotlib.backends.backend_gtk3cairo import FigureCanvasGTK3Cairo as FigureGTKCanvas
from matplotlib.backends.backend_gtk3 import NavigationToolbar2GTK3 as NavigationToolbar
from matplotlib.patches import Rectangle
import matplotlib.image as image
import numpy as np


class MatPlotLibGTKWindow(Gtk.Window):
    """An abstract base class for a matplotlib drawing widget.

    Extend Gtk.Window, and have a matplotlib.Figure attribute as an handle
    to the matplotlib API. This window have a Gtk.DrawingArea on wich
    a gtk3cairo Matplotlib backend make the plot.

    """

    def __init__(self, title="", application=None):
        Gtk.Window.__init__(self, application=application)

        # matplotlib figure and canvas
        self.figure = Figure(dpi=36)
        self.gtk_drawing_area = FigureGTKCanvas(self.figure)

        # container and layout
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.add(box)

        self.sw = Gtk.ScrolledWindow()
        self.sw.add_with_viewport(self.gtk_drawing_area)
        box.pack_start(self.sw, True, True, 0)

        toolbar = NavigationToolbar(self.gtk_drawing_area, self)
        box.pack_start(toolbar, False, True, 0)

        # window config
        self.set_title(title)
        self.set_default_size(600, 600)
        self.set_position(Gtk.WindowPosition.CENTER)

    def prepareFigure(self):
        raise NotImplementedError

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
        self.plotWhiteningOrder()
        #self.draw()
        self.show_all()

    def prepareFigure(self):
        """Draw axes, ticks, and pixels shape of the cell"""
        # axes
        f_axes = self.figure.gca(xlim=(-1.5,1.5), ylim=(-1.5,1.5))
        f_axes.spines['bottom'].set_position(('data',-1.5))
        f_axes.spines['left'].set_position(('data',-1.5))
        f_axes.spines['left'].set_color('black')

        # x-ticks
        cn = self.cell.coordinates
        xt = [p.x for p in cn[0:self.cell.width]]
        #f_axes.set_xticks(xt)

        # y-ticks
        yt = []
        for i in range(0, len(cn), self.cell.width):
            yt.append(cn[i].y)
        #f_axes.set_yticks(yt)

        f_axes.grid(True)

        # draw pixel limit
#        ix = (xt[1] - xt[0]) / 2
#        iy = (yt[1] - yt[0]) / 2
#        xt.append(xt[-1:][0] + (2 * ix))
#        f_axes.vlines([x - ix for x in xt], -1 - iy, 1 + iy)
#        yt.append(yt[-1:][0] + (2 * iy))
#        f_axes.hlines([y - iy for y in yt], -1 - ix, 1 + ix)

    def plotWhiteningOrder(self):
        arr = np.zeros((self.cell.width, self.cell.height), dtype=np.uint8)
        for p in self.cell.whiteningOrder:
            arr[p.x][p.y] = 1 - (p.w / 255)
        self.figure.figimage(arr)


#        f_axes = self.figure.gca()
#        cwo = self.cell.whiteningOrder
#        cn = self.cell.coordinates
#
#        dcw = cn[1].x - cn[0].x
#        dch = cn[self.cell.width].y - cn[0].y
#        ix = dcw / 2
#        iy = dch / 2
#
#        for d in cwo:
#            np = cn[d.x + self.cell.width * d.y]
#            col = str(1 - (d.w / 255))
#            r = Rectangle((np.x - ix, np.y - iy), dcw, dch, color=col)
#            f_axes.add_patch(r)

    def plotCellData(self):
        pass
