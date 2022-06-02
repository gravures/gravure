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
from gi.repository import Gio, Gtk
import numpy as np
from gravure import gravure
from gravure.halftone import spotfunctions
from gravure.halftone.base import *
from gravure.ui.widgets import *


__all__ = ['CellViewer', 'CellViewerApp']
__types__ = [np.uint8, np.uint16, np.uint32, np.uint64, np.float16, np.float32, np.float64]


class CellViewer(Gtk.Window):

    def __init__(self, cell, application=None):
        if not isinstance(cell, Cell):
            raise AttributeError("cell should be an halfone.base.Cell Type")
        Gtk.Window.__init__(self, title="Halftone Cell viewer",  application=application)


        # Matrix Viewer widget
        self.viewer = GtkMatrixView()

        # data initialisation
        self.cell = cell
        qtype = self.cell.whiteningOrder[0].w.dtype
        arr = np.zeros((self.cell.width, self.cell.height), dtype=qtype)
        for p in self.cell.whiteningOrder:
            arr[p.x][p.y] = p.w
        self.viewer.set_data(arr)

        # Layout
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.add(box)

        # Tools Box
        tools = Gtk.ActionBar()
        box.pack_start(tools, False, True, 0)

        zoomin = Gtk.Button(label="zoom in")
        zoomin.connect("clicked", self.on_zoomin)

        zoomout = Gtk.Button(label="zoom out")
        zoomout.connect("clicked", self.on_zoomout)

        show_numbers = Gtk.ToggleButton(label="show numbers")
        show_numbers.set_active(False)
        show_numbers.connect("toggled", self.on_show_numbers)

        self.slider_thresh = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, \
                        arr.min(), arr.max(), 1)
        self.slider_thresh.set_has_origin(True)
        self.slider_thresh.set_draw_value(True)
        self.slider_thresh.set_hexpand(True)
        self.slider_thresh.set_sensitive(False)
        self.slider_thresh.connect("value_changed", self.on_level_changed)

        thresh_toggle = Gtk.ToggleButton(label="thresh")
        thresh_toggle.set_active(False)
        thresh_toggle.connect("toggled", self.on_thresh_toggle)


        tools.pack_start(zoomin)
        tools.pack_start(zoomout)
        tools.pack_start(show_numbers)
        tools.pack_end(self.slider_thresh)
        tools.pack_end(thresh_toggle)

        # Viewport
        scroll_win = Gtk.ScrolledWindow()
        scroll_win.add(self.viewer)
        #scroll_win.set_overlay_scrolling(False)
        box.pack_start(scroll_win, True, True, 0)

         # Status Bar
        stbar = Gtk.Statusbar()
        box.pack_start(stbar, False, True, 0)
        mess = "%i x %i %s matrix | %i positions | %i levels | max : %i / min : %i | %.2f ko" \
                %(cell.width, cell.height, str(arr.dtype), cell.area, \
                  self.viewer._levels , arr.max(), arr.min(), arr.nbytes / 1024)
        stbar.push(0, mess)

        # window setting
        self.set_default_size(400, 400)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.show_all()


    def on_zoomout(self, button):
        self.viewer.zoom = max(self.viewer.zoom - 2, 1)

    def on_zoomin(self, button):
        self.viewer.zoom = min(self.viewer.zoom + 2, 100)

    def on_show_numbers(self, switch):
        self.viewer.show_numbers = switch.get_active()

    def on_thresh_toggle(self, toggle):
        self.viewer.thresh_view = toggle.get_active()
        self.slider_thresh.set_sensitive(toggle.get_active())

    def on_level_changed(self, slider):
        self.viewer.thresh_level = slider.get_value()



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

class CellViewerApp(Gtk.Application):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, application_id="org.example.myapp",
                         **kwargs)
        self.topwin = None


    def do_activate(self):
        # We only allow a single window and raise any existing ones
        if not self.topwin:
            # Windows are associated with the application
            # when the last one is closed the application shuts down
            size = 64
            spot_f = spotfunctions.Ellipse(polarity=gravure.POLARITY.SUBSTRACTIVE)
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
    exit_code = CellViewerApp().run(sys.argv)
    sys.exit(exit_code)


if __name__ == '__main__':
    main()
