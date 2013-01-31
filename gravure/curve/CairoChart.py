# -*- coding: iso-8859-1 -*-
#
# Copyright (c) 2006 Martin Lesser <ml@bettercom.de>, All Rights Reserved
# Copyright (c) 2008 Tom Haddon <tom@greenleaftech.net>, All Rights Reserved
#
# This software is distributable under the terms of the GNU
# General Public License (GPL) v2 or later, the text of which can be found at
# http://www.gnu.org/copyleft/gpl.html. Installing, importing or otherwise
# using this module constitutes acceptance of the terms of this License.

from decimal import Decimal
import cairo
import locale
import math


def _hexcolor(s=''):
    """Return the rgb-values (float) for a html-like colorstring.

    :param s: An HTML-style color string. e.g. #FF0000.
    :return: A tuple of (r, g, b) where r, g and b are floats between 0.0 and
        1.0.
    """
    r, g, b = 0, 0, 0
    if s[0] == '#' and len(s) == 7:
        r, g, b = (int('0x%s' % s[1:3], 16),
                   int('0x%s' % s[3:5], 16),
                   int('0x%s' % s[5:7], 16))
    return float(r)/255, float(g)/255, float(b)/255

def float_range(begin, end, step):
    """Allows us to generate a range including non-integer values"""
    epsilon = 0.0000001
    cur = float(begin)
    frange = [cur]
    if begin > end:
        while cur-epsilon > end:
            if step > 0:
                cur -= float(step)
            else:
                cur += float(step)
            frange.append(cur)
    else:
        while cur+epsilon < end:
            if step > 0:
                cur += float(step)
            else:
                cur -= float(step)
            frange.append(cur)
    return frange

def _num2str(a, dec=0, t_sep=True, perc=False, slocal='de_DE',
             abbreviate_nums=False):
    """Format an int or float as 'pretty' string."""
    if isinstance(a, str):
        return a
    try:
        local = locale.getlocale(locale.LC_ALL)
    except:
        local = (None, None)
    if not local[0] or local[0] != slocal:
        for l in ('', '.utf8', '.iso8859-1'):
            try:
                locale.setlocale(locale.LC_ALL, '%s%s' % (slocal, l))
                break
            except:
                pass
    try:
        fstr = '%%.%df' % dec
        n = locale.format(fstr, a, t_sep)
        if perc:
            n = '%s %%' % n
    except:
        n = str(a)

    if local[0] and local[0] != slocal:
        # Reset to old locale
        locale.setlocale(locale.LC_ALL, local)
    elif not local[0]:
        locale.setlocale(locale.LC_ALL, 'C')

    # XXX: This needs some more work - ugly hack
    if abbreviate_nums:
        num_commas = n.count(",")
        comma_parts = n.split(",")
        decimal = "".join(comma_parts[1:]).rstrip('0')
        if not decimal:
            decimal = '0'
        if num_commas == 1:
            n = "%s.%sK" % (comma_parts[0], decimal)
        elif num_commas == 2:
            n = "%s.%sM" % (comma_parts[0], decimal)
        elif num_commas == 3:
            n = "%s.%sG" % (comma_parts[0], decimal)
        elif num_commas == 4:
            n = "%s.%sT" % (comma_parts[0], decimal)
    return n


def _rnd_y(y_min=0, y_max=0):
    """Calc a 'pretty' y_max and y_min and step value"""
    if y_min == 0 and y_max == 0: y_max = 1
    step = 10 ** int(math.ceil(math.log10(y_max)) - 2)
    max_value = math.ceil(float(y_max) / step) * step
    return max_value, 0, step
        

class Chart:

    def __init__(self, width=200, height=200, margin=5, linewidth=1,
                 type='bar', x0=0, border=True, suppress_0s=False,
                 colors=None, out='', locale='en_US', font=None,
                 custom_y_axis=None):
        self.width = width
        self.height = height
        # margin is used at several places for spacing and padding:
        # - distance between elements
        # - linespace etc.
        self.margin = margin
        # XXX: why float & int -- jml
        self.linewidth = float(int(linewidth))

        # Type of chart (bar or curve)
        self._type = type.lower()

        # Intersection of y and x-axis
        # (if -1 then the lowest data-value will be taken)
        self.x0 = x0

        # area contains x_min, y_min, x_max and y_max of the
        # grid where we may paint the graph
        self.area = [
            self.margin, self.margin, self.width - self.margin,
            self.height - self.margin]

        # The labels for the axis (x, y, [y2]):
        self.labels = {}
        # The data
        self.data = []

        # A list with columns to be stacked:
        self._stack = []
        # A list with columns for which a second y-axis at the
        # right side should be built (as transparent curve)
        # XXX: Should we stack them?
        self._y2 = []

        # Instantiate img and context of cairo-class
        self._set_up_cairo(out)

        # Defaultfont
        if font is None:
            font = {'name': 'Sans', 'size': 10, 'bold': False,
                    'italic': False}
        self.defaultfont = font
        self.font = {}
        self.set_font(**self.defaultfont)

        # The locale for formatting numbers
        self.locale = locale

        if colors is None:
            colors = {}
        self._set_up_colors(colors, border)

        # Set True if you Don't want to draw labels and data-values if val==0:
        self.suppress_0s = suppress_0s

        # Do we need these both really?
        self.x, self.y = 0, 0

        # Maximum, stepwidth and correction-factor of y-axis:
        # (first value in each list for the left axis,
        #  second value for right y-axis
        self.custom_y_axis = custom_y_axis
        if self.custom_y_axis:
            self.y_min, self.y_max, self.y_step = self.custom_y_axis
            if len(self.y_max) == 1: self.y_max.append(1)
            if len(self.y_min) == 1: self.y_min.append(0)
            if len(self.y_step) == 1: self.y_step.append(1)
            self.y_corr = [1, 1]
        else:
            self.y_max, self.y_min, self.y_step, self.y_corr = [1, 1], [0, 0], [1, 1], [1, 1]

        self.chart_kvs = {
            'width': width, 'height': height, 'margin': margin,
            'linewidth': linewidth, 'type': type, 'x0': x0, 'border': border,
            'suppress_0s': suppress_0s, 'colors': colors, 'out': out,
            'locale': locale, 'font': font,
            }

    def _set_up_colors(self, colors, border=False):
        # Some colors:
        # - The current color
        self.color = None
        # - a dict with all colors used
        self.colors = {}
        # - list with data-colors, will be filled in set_legend
        # TODO: Define some default-colors
        self.dcolors = []
        # Set background-color (white if none is given):
        self.set_color(colors.get('bg', '#FFFFFF'), alias='bg')
        # Fill Graph with background-color:
        self.rectangle(0, 0, self.width, self.height)
        # Set grid-color (light grey if none is given
        if 'grid' in colors and not colors.get('grid'):
            # grid-lines explicitly disabled
            pass
        else:
            self.set_color(colors.get('grid', '#aaaaaa'), alias='grid')
        # Set foreground-color (black if not given):
        self.set_color(colors.get('fg', '#000000'), alias='fg')
        # Draw border
        self.ctx.set_line_width(self.linewidth)
        if border:
            self.rectangle(0, 0, self.width, self.height, outline=True)
        else:
            # No border wanted
            pass

    def _set_up_cairo(self, out=''):
        """Instantiate surface and context depending on the filetype."""
        self.file = out
        if isinstance(out, str) and out.endswith('.pdf'):
            if not cairo.HAS_PDF_SURFACE:
                raise SystemExit('cairo was not compiled with PDF support')
            self._out_method = self._show_page
            self.img = cairo.PDFSurface(self.file, self.width, self.height)
            self.img.set_dpi(72.0, 72.0)
        elif isinstance(out, str) and out.endswith('.ps'):
            if not cairo.HAS_PS_SURFACE:
                raise SystemExit('cairo was not compiled with PS support')
            self._out_method  = self._show_page
            self.img = cairo.PSSurface(self.file, self.width, self.height)
            self.img.set_dpi(72.0, 72.0)
        elif isinstance(out, str) and out.endswith('.svg'):
            raise SystemExit('cairo was not compiled with SVG support')
        elif isinstance(out, (str, file)):
            self._out_method = self._write_to_png
            self.img = cairo.ImageSurface(
                cairo.FORMAT_ARGB32, self.width, self.height)
        else:
            raise SystemExit(
                'CairoChart needs a filename or -object to write to')
        self.ctx = cairo.Context(self.img)
        self.matrix = self.ctx.get_matrix()

    def set_color(self, _n='', values=None, alias=None, alpha=1):
        """Set color."""
        if values:
            (r, g, b, a) = self.color = values
            self.ctx.set_source_rgba(r, g, b, a)
            return
        if _n and self.colors.get(_n):
            r, g, b, a = self.colors.get(_n)
        elif _n:
            r, g, b = _hexcolor(_n)
            a = alpha
            if alias:
                self.colors[alias] = (r, g, b, a)
            self.colors[_n] = (r, g, b, a)
        else:
            r, g, b, a = 0, 0, 0, 1
        if alpha != a:
            a = alpha
        if (r, g, b, a) == self.color:
            return
        self.set_color(values=(r, g, b, a))

    def set_data(self, data=[], **kv):
        """Set data and calculate the area where data-values will be drawn.

        Also calc the heigth and width of x- and y- lines, grid and labels
        which will be drawn outside of this 'drawable'.
        """
        self._stack = kv.get('stack', [])
        self._y2 = kv.get('y2', [])
        self.set_font(**self.defaultfont)
        # The text-height of each x-label (which will become the width due to
        # rotating):
        lw = h = self.textsize(str(data[0][0])).get('max_h')
        # The x-labels will be turned by 90° so the height of each label
        # (before rotating) is the default width of each rectangle and the
        # width of the widest label (before rotating) becomes the height of
        # the x-labels. With colwidth we may define another distance between
        # the x-labels:
        if kv.get('colwidth', 0):
            h = kv.get('colwidth')
            if h < 0:
                h = lw

        # Set the 2 y-axes the same (if there are 2)
        y2_axis_same = kv.get('y2_axis_same', False)

        # Scale y-axis min value
        y_axis_scale_min = kv.get('y_axis_scale_min', False)

        # Do we want 1,000 = 1.0k, 1,000,000 = 1.0m in the y labels?
        self.abbreviate_nums = kv.get('abbreviate_nums', False)

        # _margin is the distance between the columns:
        margin = kv.get('margin', self.margin)
        # The maximum number of values (columns) to show
        # (before moving left and right y-axis):
        if h == 'auto':
            if (len(data) + ((len(data) - 1) * margin)
                > (self.area[2] - self.area[0])):
                max_x_vals = (
                    (self.area[2] - self.area[0])
                    + ((len(data) - 1) * margin))
            else:
                max_x_vals = len(data)
        else:
            max_x_vals = int((self.area[2] - self.area[0]) / (h + margin))
        # Set x-labels and move y-pos of x-axis up so the x-labels will fit
        # below
        self.area[3] -= (self.margin
                         + self._set_x_labels(data[-max_x_vals:]))

        # Set y-labels and move x-pos of y-axis to the right
        self.area[0] += (
            self.margin
            + self._set_y_labels(y2_axis_same=y2_axis_same,
                                 y_axis_scale_min=y_axis_scale_min))
        # If we have data2 we need a second y-axis
        # at the right site of the drawable and shrink the
        # drawable at the right side
        if self._y2:
            self.area[2] -= (
                self.margin
                + self._set_y_labels(right=True, y2_axis_same=y2_axis_same,
                                     y_axis_scale_min=y_axis_scale_min))
        # Finetune the width of one total column with 1 or more sub-columns:
        width = float(self.area[2] - self.area[0] -
                      margin * (max_x_vals - 1)) / max_x_vals
        if kv.get('align', 'l')[0].lower() == 'r':
            # Align drawing-area at the right side
            n = (self.area[2] - self.area[0] -
                 len(data) * width - (len(data)-1) * margin)
            n = max(0.0, n)
        else:
            n = 0.0
        # Now we can calculate x, y and width of the x-labels:
        for x in self.labels.get('x'):
            x[2] = self.area[0] + n
            x[3] = self.area[3] + self.margin + x[1]
            x[4] = width
            n += (width + margin)

        if kv.get('graph_area_absolute', False):
            # Re-create the graph object with newly adjusted area
            local_kvs = kv
            local_kvs['graph_area_absolute'] = False
            self.chart_kvs['width'] = int(self.area[0] + self.width)
            self.chart_kvs['height'] = int(
                (self.height - self.area[3]) + self.height)
            self.__init__(**self.chart_kvs)
            self.set_title(**self.title_kvs)
            self.set_legend(self.legend, **self.legend_kvs)
            self.set_data(data, **local_kvs)

    def set_font(self, name=None, bold=False, italic=False, size=None):
        """Set the font."""
        self.font['italic'] = italic
        self.font['bold'] = bold
        if name is None:
            name = self.font.get('name', 'Sans')
        self.font['name'] = name
        self.ctx.select_font_face(
            self.font.get('name'), self.font.get('italic'),
            self.font.get('bold'))
        if size and size != self.font.get('size'):
            self.ctx.set_font_size(size)
            self.font['size'] = size

    def set_legend(self, legend, font=None, barwidth=30):
        """Draw/write legend to bottom of chart."""
        if font is None:
            font = dict(size=12)
        self.set_font(**font)
        w = self.margin
        rows = 1
        row_h = self.textsize(str(legend[0][0])).get('max_h')
        for e in legend:
            # First calc the number of lines to print
            row_w = (self.textsize(str(e[0])).get('width')
                     + self.margin * 2 + barwidth)
            if row_w > (self.width - 2 * self.margin):
                rows += 1
                w = self.margin
            elif (w + row_w) > self.width or e[0][0] == '\n':
                rows += 1
                w =  self.margin + row_w
            else:
                w += row_w
        y_legend = int(self.area[3] - rows * (row_h + self.margin))
        self.area[3] -= (self.margin + rows * (row_h + self.margin))
        self.set_color('fg')
        self.line([(0, y_legend), (self.width, y_legend)])
        y_legend +=  self.margin
        x = self.margin
        for e in legend:
            row_w = self.textsize(str(e[0])).get('width')
            if ((x + barwidth + row_w + self.margin) > self.width
                or e[0][0] == '\n'):
                x = self.margin
                y_legend += (row_h + self.margin)
            if e[0][0] == '\n':
                t = e[0][1:]
            else:
                t = e[0]
            self.set_color(e[1])
            self.dcolors.append(e[1])
            self.rectangle(x, y_legend, barwidth, row_h)
            x += self.margin + barwidth
            self.set_color('fg')
            self.text(t, x, y_legend)
            x += (row_w + self.margin)

        self.legend_kvs = {'font': font, 'barwidth': barwidth}
        self.legend = legend

    def set_title(self, text, font=None, color=None, copyright=None):
        """Create the title-bar with 'text' as the title.

        The text will be centered with a bottom line below it.

        :param color: The color to use for the title bar. If not given, use
            the foreground color.
        :param font: The font to write the text in. If not given, use the
            default font, 'bold 18'.
        """
        if font is None:
            font = dict(bold=True, size=18)
        if color is None:
            color = 'fg'
        self.set_font(**font)
        self.set_color(color)
        h = self.textsize(str(text)).get('max_h')
        y = self.margin
        for t in str(text).split('\n'):
            self.text(t, self.width / 2, 0 + y, align='c')
            y += h
        y += self.margin
        self.line([(0, y), (self.width, y)])
        self.area[1] = y + self.margin
        self.set_font(**self.defaultfont)
        if copyright is not None:
            self.text(
                copyright, self.width - self.margin,
                (self.height - self.margin
                 - self.textsize(copyright).get('max_h')), align='r')
        self.title_kvs = {
            'text': text, 'font': font, 'color': color,
            'copyright': copyright}

    def draw_bars(self):
        """Draw the data as bar-chart."""
        col = 0
        for d in self.labels.get('x'):
            data = self.data[col]
            x = d[2]
            if not self._stack:
                c = 0
                # The width of one sub-column:
                s_width = d[4] / (len(data) - len(self._y2))
                for v in data:
                    if (c + 1) in self._y2:
                        continue
                    try:
                        self.set_color(self.dcolors[c])
                    except:
                        self.set_color('fg')
                    if v == None:
                        h = 0
                    else:
                        h = (v - self.y_min[0]) * self.y_corr[0]
                    y = self.area[3] - h
                    self.rectangle(x, y, s_width, h)
                    x += s_width
                    c += 1
            else:
                s_width = d[4] / len(self._stack)
                for s in self._stack:
                    y = self.area[3]
                    count = 0
                    for c in s:
                        try:
                            self.set_color(self.dcolors[c - 1])
                        except:
                            self.set_color('fg')
                        if c == 1 or count == 0:
                            if data[c - 1]:
                                h = ((data[c - 1] - self.y_min[0])
                                     * self.y_corr[0])
                            else:
                                h = 0
                        else:
                            if data[c - 1] == None:
                                h = 0
                            else:
                                h = data[c - 1] * self.y_corr[0]
                        y -= h
                        self.rectangle(x, y, s_width, h)
                        count += 1
                    x += s_width
            col += 1

    def draw_data(self, **kv):
        """Draw the data as rectangle or whatever else..."""
        if self._type == 'bar':
            self.draw_bars()
            if self._y2:
                self.draw_lines(**kv)
        elif self._type == 'line':
            self.draw_lines(**kv)

    def draw_dots(self, points, radius=None):
        """Draw dots with radius of self.linewidth at the given points."""
        if radius is None:
            radius = self.linewidth
        for x0, y0 in points:
            self.ctx.arc(x0, y0, radius, 0, math.radians(360))
            self.ctx.fill()

    def draw_grid(self, dont_suppress_labels=False, vertical_lines=False,
                  suppress_0s=None):
        """Draw both the axes, the labels of each axis and the grid.

        There are normally two axes, but there can be three.

        Note that suppress_0s is ignored.
        """
        label_h = self.textsize('X').get('max_h')
        n = 0
        y_max_len = max([x[1] for x in self.labels.get('y')])
        for l in self.labels.get('y'):
            # X-Pos for each y-label:
            l[1] = self.margin + y_max_len - l[1]
            # Y-Pos:
            l[2] = self.area[1] + n * self.y_step[0] - label_h / 2
            p = self.text(l[0], self.margin + y_max_len,
                          l[2], align='r')
            n += 1
            if n < len(self.labels.get('y')):
                if not self.colors.get('grid'):
                    continue
                self.set_color('grid')
                p = self.line([(self.area[0], l[2] + label_h / 2),
                               (self.area[2], l[2] + label_h / 2)],
                               dash=[3, 2])
                self.set_color('fg')
        if self.labels.get('y2'):
            y_max_len = max([x[1] for x in self.labels.get('y2')])
            n = 0
            # Change color here:
            self.set_color(self.dcolors[self._y2[0]-1])
            for l in self.labels.get('y2'):
                # X-Pos for each y-label:
                l[1] = self.width - self.margin - y_max_len
                # Y-Pos:
                l[2] = self.area[1] + n * self.y_step[1] - label_h / 2
                p = self.text(l[0], l[1], l[2], align='l')
                n += 1
            self.set_color('fg')
        self.line(
            [(self.area[0] - self.linewidth, self.area[1] - label_h / 2),
             (self.area[0] - self.linewidth, self.area[3]),
             (self.area[2] + self.linewidth, self.area[3]),
             (self.area[2] + self.linewidth, self.area[1] - label_h / 2)])
        # Adjust grid with linewidths of x/y axis:
        self.area[1] += self.linewidth
        
        self.y_corr[0] = ((self.area[3] - self.area[1])
                          / float(self.y_max[0] - self.y_min[0]))
        self.y_corr[1] = ((self.area[3] - self.area[1])
                          / float(self.y_max[1] - self.y_min[1]))
        for l in self.labels.get('x'):
            if (self.suppress_0s and l[6] == 0
                and dont_suppress_labels == False):
                # Don't draw x-label and rectangle if only zero-vals
                continue
            # Draw text (x-label), adjust x:
            self.set_color('fg')
            x = l[2] + (l[4] - label_h) / 2
            self.text(l[0] + ' ', x, l[3], rotate=270)
            if not self.colors.get('grid'):
                continue
            self.set_color('grid')
            if vertical_lines and l[0]:
                p = self.line(
                    [((x + (label_h / 2)), self.area[1]),
                     ((x + (label_h / 2)), self.area[3])],
                    dash=[3, 2])

    def draw_lines(self, linewidth=1, dots=False):
        """Draw data as line-chart."""
        for l in range(0, len(self.data[0])):
            col = 0
            if (l + 1) not in self._y2 and self._type != 'line':
                continue
            lp = []
            if (l + 1) in self._y2:
                axis = 1
            else:
                axis = 0
            for d in self.labels.get('x'):
                x = d[2] + d[4] / 2
                if self.data[col][l] == None:
                    try:
                        self.set_color(self.dcolors[l])
                    except:
                        self.set_color('fg') 
                    self.line(lp, dots=True, width=linewidth)
                    if len(lp) == 1: 
                        self.draw_dots(lp)
                    col += 1
                    lp = []
                else:
                    y = (
                        self.area[3] 
                        - ((self.data[col][l] - self.y_min[axis]) 
                           * self.y_corr[axis]) 
                        - self.linewidth)
                    if not col and not self.suppress_0s:
                        # Begin line at y0-axis
                        lp.append((d[2], y))
                    if not self.suppress_0s or self.data[col][l]:
                        lp.append((x, y))
                    col += 1
            if not self.suppress_0s:
                lp.append((x + d[4] / 2, y))
            try:
                self.set_color(self.dcolors[l])
            except:
                self.set_color('fg')
            self.line(lp, width=linewidth)
            if dots:
                self.draw_dots(lp)

    def _set_x_labels(self, data):
        """Set up the labels for the x-axis.

        Also, calculate the maximum-value for each entry. XXX What does this
        mean?

        :return: the width of the widest x-label in pixels.
        """
        # Each element in the x-labels-list is a list with 8 values: [text,
        # width of text, x-pos, y-pos, maximum width, maximum height, maximum
        # y-value, maximum y2-value]
        self.labels['x'] = [
            [str(x[0]), self.textsize(str(x[0])).get('width'), 0, 0, 0, 0]
            for x in data]
        self.data = [x[1:] for x in data]
        c, l = 0, len(self.data[0])
        for v in self.data:
            m0, m1 = 0, 0
            if not self._stack and not self._y2:
                m0 = max(v)
            elif not self._stack:
                for n in range(0, l):
                    if (n + 1) in self._y2:
                        m1 = max(m1, v[n])
                    else:
                        m0 = max(m0, v[n])
            else:
                s = 1
                m2 = [0] * len(self._stack)
                for e in v:
                    if s in self._y2:
                        if e != None:
                            m1 += e
                    else:
                        z = 0
                        for ze in self._stack:
                            if s in ze:
                                if e != None:
                                    m2[z] += e
                            z += 1
                        m0 = max(m2)
                    s += 1
            self.labels['x'][c].append(m0)
            self.labels['x'][c].append(m1)
            c += 1

        # Return text-width in pixels of the widest x-label:
        return max([x[1] for x in self.labels.get('x')])

    def _set_y_labels(self, right=False, y2_axis_same=False,
                      y_axis_scale_min=False):
        """Set up the stepwidth between y-labels.

        Calculate the greatest value on y-axis.

        :return: the width of the widest y-label in pixels.
        """
        if right:
            axis, label = 1, 'y2'
        else:
            axis, label = 0, 'y'
        if self.custom_y_axis == None:
            if y2_axis_same == True:
                y_max_1 = max([x[6] for x in self.labels.get('x')])
                y_max_2 = max([x[7] for x in self.labels.get('x')])
                y_max = max(y_max_1, y_max_2)
                y_list_index = self._y2[0] - 1
                if y_list_index == 0: y_list_index = 1
                if  y_axis_scale_min:
                    if self.suppress_0s:
                        if self._stack:
                            y_min = min(
                                [min(x[0], x[y_list_index]) 
                                for x in self.data 
                                    if min(x[0], x[y_list_index]) > 0])
                        else:
                            y_min = min(
                                [min(x) for x in self.data if min(x) > 0])
                    else:
                        if self._stack:
                            y_min = min(
                                [min(x[0], x[y_list_index]) for x in self.data])
                        else:
                            y_min = min([min(x) for x in self.data])
                        y_min = min([min(x) for x in self.data if min(x) > 0])
                else:
                    y_min = 0
            else:
                y_max = max([x[6 + axis] for x in self.labels.get('x')])
                if y_axis_scale_min:
                    try:
                        if self.suppress_0s:
                            if self._stack:
                                y_min = min([x[0] for x in self.data if x[0] > 0])
                            else:
                                y_min = min([min(x) for x in self.data if min(x) > 0])
                        else:
                            if self._stack:
                                y_min = min([x[0] for x in self.data])
                            else:
                                y_min = min([min(x) for x in self.data])
                    except ValueError:
                        y_min = 0
                else:
                    y_min = 0
            self.y_max[axis], self.y_min[axis], self.y_step[axis] = _rnd_y(
                y_min, y_max)
        # Height of y-label:
        self.set_font(**self.defaultfont)
        label_h = self.textsize(
            _num2str(
                self.y_max[axis], slocal=self.locale,
                abbreviate_nums=self.abbreviate_nums)).get('max_h')
        y_step = self.y_step[axis]
        while (((self.y_max[axis] - self.y_min[axis]) / y_step * label_h)
               > (self.area[3] - self.area[1])):
            # Enlarge step-size if y-labels would overlap
            y_step += self.y_step[axis]
        self.y_step[axis] = y_step
        # Recalc max. y-label so all steps have the same value:
        self.y_max[axis] = float(
            (math.ceil(float(self.y_max[axis] - self.y_min[axis]) / y_step)
             * y_step) + self.y_min[axis])
        if "." in str(self.y_step[axis]):
            decimals = len(str(self.y_step[axis]).split(".")[1:][0])
        else:
            decimals = 0
        if self.custom_y_axis:
            l_texts = [
                _num2str(_y, slocal=self.locale, 
                    abbreviate_nums=self.abbreviate_nums, dec=decimals)
                for _y in float_range(self.y_max[axis], self.y_min[axis],
                    self.y_step[axis])]
        else:
            l_texts = [
                _num2str(_y, slocal=self.locale,
                    abbreviate_nums=self.abbreviate_nums, dec=decimals)
                for _y in float_range(self.y_max[axis], self.y_min[axis],
                    - self.y_step[axis])]
        self.labels[label] = [[_y, self.textsize(_y).get('width'), 0]
                               for _y in l_texts]
        if not axis:
            self.area[1] += (label_h / 2 + self.linewidth)
        # The distance in pixels between the y-labels:
        self.y_step[axis] = ((self.area[3] - self.area[1]) /
                             (len(self.labels.get(label)) - 1))
        # Return width of the widest y-label:
        try:
            return max([x[1] for x in self.labels.get(label)])
        except:
            return 0

    def line(self, points, width=None, dash=None, linecap='b', linejoin='m',
             dots=None):
        """Draw a line through 'points'.

        Draws the line starting at the first (x, y)-tuple in points through
        all other (x, y)-tuples in points. Try to fix them before so no
        'smearing' will appear. Possible parameters are:

        :param width: If no width is given self.linewidth will be used.

        :param dash: A dash pattern is specified by dashes, a list of positive
            values. Each value provides the user-space length of alternate
            'on' and 'off' portions of the stroke.

        :param linecap: butt (default), round, square
        :param linejoin: miter (default), round, bevel

        Note that 'dots' is ignored.
        """
        if len(points) < 2:
            return
        if width is None:
            width = self.linewidth
        else:
            # XXX: Why float & int, why not just float?
            width = float(int(width))
        self.ctx.set_line_width(width)
        # Fix 'smearing'-problem:
        width = float(int(width) % 2) / 2
        if dash is not None:
            self.ctx.set_dash(dash, 1)
        else:
            self.ctx.set_dash([], 0)
        if linecap[0] == 'r':
            self.ctx.set_line_cap(cairo.LINE_CAP_ROUND)
        elif linecap[0] == 's':
            self.ctx.set_line_cap(cairo.LINE_CAP_SQUARE)
        else:
            self.ctx.set_line_cap(cairo.LINE_CAP_BUTT)
        if linejoin[0] == 'r':
            self.ctx.set_line_join(cairo.LINE_JOIN_ROUND)
        elif linejoin[0] == 'b':
            self.ctx.set_line_join(cairo.LINE_JOIN_BEVEL)
        else:
            self.ctx.set_line_join(cairo.LINE_JOIN_MITER)
        x0, y0 = points.pop(0)
        start = True
        for x1, y1 in points:
            _x0, _x1, _y0, _y1 = (float(int(x0)), float(int(x1)),
                                  float(int(y0)), float(int(y1)))
            if x0 == x1:
                # vertical line, fix _x0 and _x1 by linewidth / 2
                _x0 += width
                _x1 += width
                _y1 += width
            elif y0 == y1:
                # horizontal line, fix yx0 and yx1 by linewidth / 2
                _y0 += width
                _y1 += width
                _x1 += width
            if start:
                self.ctx.move_to(_x0, _y0)
                start = False
            self.ctx.line_to(_x1, _y1)
            x0, y0 = x1, y1
        self.ctx.stroke()

    def rectangle(self, x=0, y=0, width=0, height=0, outline=False,
                  dash=None):
        """Draw a rectangle at x, y with the given width and height.

        If outline is True, stroke() instead of fill() will be used and x, y
        etc. will be fixed so no 'smearing' appears.
        """
        if outline:
            x += self.linewidth / 2
            y += self.linewidth / 2
            width -= self.linewidth
            height -= self.linewidth
        self.ctx.rectangle(x, y, width, height)
        if outline:
            if dash:
                self.ctx.set_dash(dash, 1)
            else:
                self.ctx.set_dash([], 0)
            self.ctx.stroke()
        else:
            self.ctx.fill()

    def text(self, text='', x=0, y=0, font=None, color=None, rotate=0,
             align='l', valign='t', border=False):
        """Print text 'text' at (x, y).

        ctx.text_path() normally draws text above the baseline of the text and
        ctx.rectangle below y. So to get this in 'sync' we also draw text
        below (x, y) so x and y define the left upper corner of the bounding
        box and not (x, y) of the leftmost part of the baseline.

        :param rotate: the text will be rotated by x degrees.
        :param align: the text will be aligned (right, left, center).
        :param valign: vertical align (top [default], middle, bottom,
            baseline [cairo-default]).
        :param border: Print a surrounding border.
        """
        if font:
            self.set_font(**font)
        if color:
            self.set_color(**color)
        size = self.textsize(text)
        rotate = math.radians(rotate)
        if align.lower()[0] == 'r':
            horiz_offset = size.get('width')
        elif align.lower()[0] == 'c':
            horiz_offset = size.get('width') / 2
        else:
            horiz_offset = 0
        if valign.lower()[0] == 'l':
            # Keep cairo-behavior drawing from baseline.
            vert_offset = 0
        elif valign.lower()[0] == 'm':
            # Adjust x, y so the middle of the the text is center for
            # rotation.
            vert_offset = size.get('max_h') / 2 - size.get('max_d')
        elif valign.lower()[0] == 'b':
            # Move text to bottom-line of bounding-box.
            vert_offset = -size.get('max_d')
        else:
            # Our default is setting the top-left corner of bounding-box at
            # x, y.
            vert_offset = size.get('max_a')
        self.ctx.move_to(x, y)
        # Move x, y so the top-left corner of bounding-box is at x, y.
        self.ctx.rel_move_to(
            -math.sin(rotate) * vert_offset, math.cos(rotate) * vert_offset)
        self.ctx.rotate(rotate)
        self.ctx.rel_move_to(-horiz_offset, 0)
        bx, by = self.ctx.get_current_point()
        by -= size.get('max_a')
        self.ctx.text_path(text)
        self.ctx.fill()
        if border:
            self.rectangle(
                bx, by, size.get('width'), size.get('max_h'),
                outline=True)
        if rotate:
            self.ctx.set_matrix(self.matrix)

    def textsize(self, text='', font=None):
        """Calculate the width and height of a text.

        Read http://www.cairographics.org/manual/cairo-Scaled-Fonts.html#cairo-text-extents-t
        and http://www.cairographics.org/manual/cairo-Scaled-Fonts.html#cairo-font-extents-t
        as reference.
        """
        if font:
            self.set_font(font)
        l = self.ctx.text_extents(text + " ")
        f = self.ctx.font_extents()
        return {
            'width': l[4],  # Width of bounding box.
            'height': l[3], # Height of bounding box.
            'max_h': f[2],  # Total height of the font.
            'max_a': f[0],  # Ascent, max height of glyphs above baseline.
            'max_d': f[1]   # Descent of the font below the baseline.
            }

    def output(self):
        """Write image to 'self.file'.

        self.file may be a filename or a file-like object.
        """
        if not self.file:
            return False
        try:
            self._out_method()
        except:
            raise

    def _write_to_png(self):
        self.img.write_to_png(self.file)

    def _show_page(self):
        self.ctx.show_page()
        self.img.finish()
