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

__all__ = ['MatrixView', 'CellViewer']


import sys
from gi.repository import Gtk
from gi.repository import GObject

from halftone import spotfunctions
from halftone.base import *


class MatrixView(Gtk.DrawingArea, Gtk.Scrollable):
    """A scrollable Gtk widget for making graphical representation\
    of 2D matrix (in sense of raster object).

    Extends Gtk.DrawingArea and implements Gtk.Scrollable.
    """

    #hadjustment = GObject.property(type=Gtk.Adjustment,
    #                                flags=GObject.PARAM_READWRITE)
    #vadjustment = GObject.property(type=Gtk.Adjustment,
    #                                flags=GObject.PARAM_READWRITE)
    vscroll_policy = GObject.property(type=Gtk.ScrollablePolicy,
                     default=Gtk.ScrollablePolicy.MINIMUM,
                     flags=GObject.PARAM_READWRITE)
    hscroll_policy = GObject.property(type=Gtk.ScrollablePolicy,
                     default=Gtk.ScrollablePolicy.MINIMUM,
                     flags=GObject.PARAM_READWRITE)

    def __init__(self):
        Gtk.DrawingArea.__init__(self)
        #self.connect('notify::hadjustment', self._on_set_hadjustment)
        #self.connect('notify::vadjustment', self._on_set_vadjustment)
        self.connect('draw', self._on_draw_cb)
        self._hsize = None
        self._vsize = None
        self._scale = 1.0

    @GObject.property(type=Gtk.Adjustment, flags=GObject.PARAM_READWRITE)
    def hadjustment(self):
        return self._hadjustment

    @hadjustment.setter
    def hadjustment(self, value):
        self._hadjustment = value
        self._hadjustment.set_page_increment(5)
        self._hadjustment.set_step_increment(1)
        self._hadjustment.connect('value-changed',
                                         self._on_h_value_changed)

    @GObject.property(type=Gtk.Adjustment, flags=GObject.PARAM_READWRITE)
    def vadjustment(self):
        return self._vadjustment

    @vadjustment.setter
    def vadjustment(self, value):
        self._vadjustment = value
        self._vadjustment.set_page_increment(5)
        self._vadjustment.set_step_increment(1)
        self._vadjustment.connect('value-changed',
                                         self._on_v_value_changed)

    @property
    def hsize(self):
        return self._hsize

    @hsize.setter
    def hsize(self, h):
        if not isinstance(h, int):
            raise TypeError('size should be an int')
        if h < 1:
            h = 1
        self._hsize = h

    @property
    def vsize(self):
        return self._vsize

    @vsize.setter
    def hsize(self, v):
        if not isinstance(v, int):
            raise TypeError('size should be an int')
        if v < 1:
            v = 1
        self._vsize = v

    def set_size(self, h, v):
        self.hsize, self.vsize = h, v

    def get_size(self):
        return self._hsize, self._vsize

    @property
    def scale(self):
        return self._scale

    @scale.setter
    def scale(self, s):
        if not isinstance(v, (int, float)):
            raise TypeError('scale should be an int or float')
        if s < 1:
            s = 1
        self._scale = s

#    def _on_set_hadjustment(self, _self, gparamstring):
#        self.hadjustment.set_page_increment(5)
#        self.hadjustment.set_step_increment(1)
#        self.hadjustment.connect('value-changed',
#                                         self._on_h_value_changed)
#
#    def _on_set_vadjustment(self, _self, gparamstring):
#        self.vadjustment.set_page_increment(5)
#        self.vadjustment.set_step_increment(1)
#        self.vadjustment.connect('value-changed',
#                                         self._on_v_value_changed)

    def _on_h_value_changed(self, adjustment):
        print("H scroll", adjustment.get_value())

    def _on_v_value_changed(self, adjustment):
        print("V scroll", adjustment.get_value())

    def _on_draw_cb(self, widget, ctx):
        w = self.get_allocated_width()
        h = self.get_allocated_height()

        self.hadjustment.set_page_size(w)

        self.hadjustment.set_lower(1)
        self.hadjustment.set_upper(1000)

        self.vadjustment.set_page_size(h)

        self.vadjustment.set_lower(1)
        self.vadjustment.set_upper(1000)

        print('h_page_size', self.hadjustment.get_page_size())
        print('h_value', self.hadjustment.get_value())
        print('h_upper', self.hadjustment.get_upper())
        print('h_step', self.hadjustment.get_step_increment())

        self._draw_background(ctx, w, h)
        self._draw_bounding_box(ctx, w, h)

        print('w,h: ', w, h)

        return True

    def _draw_background(self, ctx, w, h):
        ctx.rectangle(0, 0, w, h)
        ctx.set_source_rgba (0, 0, 0.5)
        ctx.fill()

    def _draw_bounding_box(self, ctx, w, h):
        ctx.rectangle(50, 50, 100, 100)
        ctx.set_source_rgba (0.5, 0.5, 0.5)
        ctx.fill()


class CellViewer(Gtk.Window):

    def __init__(self, cell, title="Cell view", application=None):
        if not isinstance(cell, Cell) :
            raise AttributeError("cell should be an halfone.base.Cell Type")
        Gtk.Window.__init__(self, application=application)

        # Attributes
        self.cell = cell
        scroll_win = Gtk.ScrolledWindow()
        self.add(scroll_win)
        self.draw_area = MatrixView()
        scroll_win.add(self.draw_area)

        # window setting
        self.set_title(title)
        self.set_default_size(400, 400)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.show_all()


class App(Gtk.Application):

    def __init__(self):
        Gtk.Application.__init__(self)
        self.test()

    def test(self):
        spot_f = spotfunctions.Rhomboid()
        self.h_cell = Cell(93, 93)
        self.topwin = CellViewer(self.h_cell, application=self)
        self.h_cell.setBuildOrder(BuildOrderSpotFunction(spot_f))
        self.h_cell.fill()

        print(spot_f)
        print(self.h_cell)
        #self.topwin.plotWhiteningOrder()

    def do_activate(self):
        self.topwin.show_all()

    def do_startup(self):
        Gtk.Application.do_startup(self)


def main():
    exit_code = App().run(sys.argv)
    sys.exit(exit_code)


if __name__ == '__main__':
    main()
