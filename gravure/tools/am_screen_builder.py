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
from gi.repository import Gio, Gtk, Gdk, GObject, GdkPixbuf
import cairo
import numpy as np
from halftone import spotfunctions
from halftone.base import *


__all__ = ['GtkMatrixView', 'CellViewer']
__types__ = [np.uint8, np.uint16, np.uint32, np.uint64, np.float16, np.float32, np.float64]


class GtkMatrixView(Gtk.DrawingArea, Gtk.Scrollable):
    """A scrollable Gtk widget for making graphical representation\
        of 2D matrix (in sense of raster object).

        Extends Gtk.DrawingArea and implements Gtk.Scrollable.
        """

    __gtype_name__ = 'GtkMatrixView'

    def __init__(self, data=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.data = data
        self._pixbuf = None
        self.zoom = 20
        self.show_numbers=False
        self.connect('draw', self._on_draw_cb)


    #
    # zoom property
    #
    def get_zoom(self):
        return self._zoom

    def set_zoom(self, value):
        if value is None:
            return
        self._zoom = value
        self.queue_draw()

    zoom = property(fget=get_zoom, fset=set_zoom)

    #
    # show_numbers property
    #
    def get_show_numbers(self):
        return self._show_numbers

    def set_show_numbers(self, value):
        self._show_numbers = bool(value)
        self.queue_draw()

    show_numbers = property(fget=get_show_numbers, fset=set_show_numbers)

    #
    # data property
    #
    def get_data(self):
        return self._data

    def set_data(self, value):
        if value is None:
            return

        # Testing for buffer protocols
        try : memoryview(value)
        except :
            raise AttributeError("Data should implement the buffer protocol")
        else :
            if value.ndim < 2 :
                raise ValueError("Data should at least be 2 dimensional")
            self._data = value

    data = property(fget=get_data, fset=set_data)

    #
    # h & v scroll_policy property
    #
    hscroll_policy = GObject.property(type=Gtk.ScrollablePolicy,
                                      default=Gtk.ScrollablePolicy.MINIMUM,
                                      flags=GObject.PARAM_READWRITE)
    vscroll_policy = GObject.property(type=Gtk.ScrollablePolicy,
                                      default=Gtk.ScrollablePolicy.MINIMUM,
                                      flags=GObject.PARAM_READWRITE)

    #
    # hadjustment property
    #
    def set_hadjustment(self, value):
        setattr(GtkMatrixView.hadjustment, '_property_helper_hadjustment', value)
        self.hadjustment.set_page_increment(5)
        self.hadjustment.set_step_increment(1)
        self.hadjustment.connect('value-changed', self._on_hscroll)

    def get_hadjustment(self):
        return getattr(GtkMatrixView.hadjustment, '_property_helper_hadjustment')

    hadjustment = GObject.property(type=Gtk.Adjustment,
                                   default=None,
                                   setter=set_hadjustment,
                                   getter=get_hadjustment,
                                   flags=GObject.PARAM_READWRITE)

    #
    # vadjustment property
    #
    def set_vadjustment(self, value):
        setattr(GtkMatrixView.vadjustment, '_property_helper_vadjustment', value)
        self.vadjustment.set_page_increment(5)
        self.vadjustment.set_step_increment(1)
        self.vadjustment.connect('value-changed', self._on_vscroll)

    def get_vadjustment(self):
        return getattr(GtkMatrixView.vadjustment, '_property_helper_vadjustment')

    vadjustment = GObject.property(type=Gtk.Adjustment,
                                   default=None,
                                   setter=set_vadjustment,
                                   getter=get_vadjustment,
                                   flags=GObject.PARAM_READWRITE)

    def _on_hscroll(self, adjustment):
        pass
        #print("H scroll", adjustment.get_value())

    def _on_vscroll(self, adjustment):
        pass
        #sprint("V scroll", adjustment.get_value())

    #
    # size property
    #
    hsize = GObject.property(type=int,
                             flags=GObject.PARAM_READWRITE,
                             default=1,
                             minimum=1,
                             maximum=8000)

    vsize = GObject.property(type=int,
                             flags=GObject.PARAM_READWRITE,
                             default=1,
                             minimum=1,
                             maximum=8000)

    def set_size(self, h, v):
        self.hsize, self.vsize = h, v

    def get_size(self):
        return self.hsize, self.vsize


    #
    # scale property
    #
    scale = GObject.property(type=float,
                             flags=GObject.PARAM_READWRITE,
                             default=1.0,
                             minimum=1.0)


    #
    # drawing methods
    #
    def _on_draw_cb(self, widget, ctx):
        w = self.get_allocated_width()
        h = self.get_allocated_height()

        self.hadjustment.set_page_size(w)
        self.hadjustment.set_lower(-50)
        self.hadjustment.set_upper(self.data.shape[1] * self.get_zoom() + 50)

        self.vadjustment.set_page_size(h)
        self.vadjustment.set_lower(-50)
        self.vadjustment.set_upper(self.data.shape[0] * self.get_zoom() + 50)

        self._draw_background(ctx, w, h)
        self._draw_matrix(ctx, w, h, (- self.hadjustment.get_value(), \
                                      - self.vadjustment.get_value()))
        return True

    def _draw_background(self, ctx, w, h):
        ctx.rectangle(0, 0, w, h)
        ctx.set_source_rgb(1, 1, 1)
        ctx.fill()

    def _draw_bounding_box(self, ctx, w, h):
        ctx.rectangle(50, 50, 50, 50)
        ctx.set_source_rgb(0.5, 0.5, 0.5)
        ctx.fill()

    def _draw_matrix(self, ctx, w, h, origin=(0, 0)):
        ox = origin[0]
        oy = origin[1]
        scale = self.zoom

        # clip data
        dw = self.data.shape[1]
        dh = self.data.shape[0]
        dox = doy = 0
        if dw * scale > w :
            dw = w // scale + 3
            dox = int(- min(ox // scale, 0))
            ox = ox % scale - scale
        if dh * scale > h :
            dh = h // scale + 3
            doy = int(- min(oy // scale, 0))
            oy = oy % scale - scale
        view = self.data[doy:doy+dh, dox:dox+dw]
        dw = min(dw, view.shape[1])
        dh = min(dh, view.shape[0])

        if self.zoom >= 10:
            ctx.set_antialias(cairo.ANTIALIAS_NONE)
            for ih in range(dh-1):
                for iw in range(dw-1):
                    color = view[ih][iw] / np.iinfo(view.dtype).max
                    ctx.rectangle(ox + iw * scale, oy + ih * scale, scale, scale)
                    ctx.set_source_rgb(color, color, color)
                    ctx.fill()
                    if self.show_numbers and self.zoom>=20:
                        ctx.set_font_size(6 * self.zoom / 20)
                        color = .71 - color
                        ctx.set_source_rgb(color , color , color)
                        ctx.move_to(ox + iw * scale + scale // 4, \
                                    oy + ih * scale + scale // 2)
                        ctx.show_text(str(view[ih][iw]))
                        ctx.stroke()
        else:
            cs = GdkPixbuf.Colorspace.RGB
            data = view.repeat(3)
            data = (data / np.iinfo(view.dtype).max * 255).astype(np.uint8)
            self._pixbuf = GdkPixbuf.Pixbuf.new_from_data(data, cs, \
                           False, 8, dw, dh, dw*3, None, None)
            ctx.set_antialias(cairo.ANTIALIAS_NONE)
            ctx.scale(self.zoom, self.zoom)
            Gdk.cairo_set_source_pixbuf(ctx, self._pixbuf, 0, 0)
            ctx.paint()



class CellViewer(Gtk.Window):

    def __init__(self, cell, application=None):
        if not isinstance(cell, Cell):
            raise AttributeError("cell should be an halfone.base.Cell Type")
        Gtk.Window.__init__(self, title="Halftone Cell viewer",  application=application)

        # Layout
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.add(box)

        tools = Gtk.Toolbar()
        box.pack_start(tools, False, True, 0)
        zoomin = Gtk.ToolButton(label="zoom in")
        zoomin.connect("clicked", self.on_zoomin)
        zoomout = Gtk.ToolButton(label="zoom out")
        zoomout.connect("clicked", self.on_zoomout)
        #nb_label = Gtk.Label("show numbers")
        show_numbers = Gtk.ToggleToolButton(label="show numbers")
        show_numbers.set_active(False)
        show_numbers.connect("toggled", self.on_show_numbers)
        tools.insert(zoomin, 0)
        tools.insert(zoomout, 1)
        tools.insert(show_numbers, 2)

        scroll_win = Gtk.ScrolledWindow()
        self.viewer = GtkMatrixView()
        scroll_win.add(self.viewer)
        box.pack_start(scroll_win, True, True, 0)

        # window setting
        self.set_default_size(400, 400)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.show_all()

        # data initialisation
        self.cell = cell
        qtype = self.cell.whiteningOrder[0].w.dtype
        arr = np.zeros((self.cell.width, self.cell.height), dtype=qtype)
        for p in self.cell.whiteningOrder:
            arr[p.x][p.y] = p.w #1 - (p.w / 255)
        self.viewer.set_data(arr)

    def on_zoomout(self, button):
        self.viewer.zoom = max(self.viewer.zoom // 2, 1)

    def on_zoomin(self, button):
        self.viewer.zoom = min(self.viewer.zoom * 2, 100)

    def on_show_numbers(self, switch):
        self.viewer.show_numbers = switch.get_active()

# This would typically be its own file
MENU_XML="""
<?xml version="1.0" encoding="UTF-8"?>
<interface>
  <menu id="app-menu">
    <section>
      <attribute name="label" translatable="yes">Change label</attribute>
      <item>
        <attribute name="action">win.change_label</attribute>
        <attribute name="target">String 1</attribute>
        <attribute name="label" translatable="yes">String 1</attribute>
      </item>
      <item>
        <attribute name="action">win.change_label</attribute>
        <attribute name="target">String 2</attribute>
        <attribute name="label" translatable="yes">String 2</attribute>
      </item>
      <item>
        <attribute name="action">win.change_label</attribute>
        <attribute name="target">String 3</attribute>
        <attribute name="label" translatable="yes">String 3</attribute>
      </item>
    </section>
    <section>
      <item>
        <attribute name="action">win.maximize</attribute>
        <attribute name="label" translatable="yes">Maximize</attribute>
      </item>
    </section>
    <section>
      <item>
        <attribute name="action">app.about</attribute>
        <attribute name="label" translatable="yes">_About</attribute>
      </item>
      <item>
        <attribute name="action">app.quit</attribute>
        <attribute name="label" translatable="yes">_Quit</attribute>
        <attribute name="accel">&lt;Primary&gt;q</attribute>
    </item>
    </section>
  </menu>
</interface>
"""

class App(Gtk.Application):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, application_id="org.example.myapp",
                         **kwargs)
        self.topwin = None


    def do_activate(self):
        # We only allow a single window and raise any existing ones
        if not self.topwin:
            # Windows are associated with the application
            # when the last one is closed the application shuts down
            size = 16
            spot_f = spotfunctions.SimpleDot()
            self.h_cell = Cell(size, size)
            TosSpotFunction(spot_f, np.uint8).fillCell(self.h_cell)
            self.topwin = CellViewer(self.h_cell, application=self)

        self.topwin.present()

    def do_startup(self):
        Gtk.Application.do_startup(self)

        action = Gio.SimpleAction.new("about", None)
        action.connect("activate", self.on_about)
        self.add_action(action)

        action = Gio.SimpleAction.new("quit", None)
        action.connect("activate", self.on_quit)
        self.add_action(action)

        builder = Gtk.Builder.new_from_string(MENU_XML, -1)
        self.set_app_menu(builder.get_object("app-menu"))

    def on_about(self, action, param):
        about_dialog = Gtk.AboutDialog(transient_for=self.topwin, modal=True)
        about_dialog.present()

    def on_quit(self, action, param):
        self.quit()


def main():
    exit_code = App().run(sys.argv)
    sys.exit(exit_code)


if __name__ == '__main__':
    main()
