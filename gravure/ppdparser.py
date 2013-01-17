#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (C) 2011 Atelier Obscur.
# Authors:
# Gilles Coissac <gilles@atelierobscur.org>

# This program is free software; you can redistribute it and/or modify it under
# the terms of version 2 of the GNU General Public License as published by the
# Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.  See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License with
# the Debian GNU/Linux distribution in file /usr/share/common-licenses/GPL;
# if not, write to the Free Software Foundation, Inc., 51 Franklin St, 
# Fifth Floor, Boston, MA 02110-1301, USA.

__author__ = "Gilles Coissac <gilles@atelierobscur.org>"
__date__ = "Wed Jan 16 13:49:44 2013"
__version__ = "$Revision: 0.1 $"
__credits__ = "Atelier Obscur : www.atelierobscur.org"


def init_adobe_keywords:
    pass

def init_cups_keywords:
    pass

def init_gutenprint_keywords:
    pass


# cups-1.5.3/cups/ppd.c ; function ppdopen2(), l. 450

  static const char * const ui_keywords[] =
			{
#ifdef CUPS_USE_FULL_UI_KEYWORDS_LIST
 /*
  * Adobe defines some 41 keywords as "UI", meaning that they are
  * user interface elements and that they should be treated as such
  * even if the PPD creator doesn't use Open/CloseUI around them.
  *
  * Since this can cause previously invisible options to appear and
  * confuse users, the default is to only treat the PageSize and
  * PageRegion keywords this way.
  */
			  /* Boolean keywords */
			  "BlackSubstitution",
			  "Booklet",
			  "Collate",
			  "ManualFeed",
			  "MirrorPrint",
			  "NegativePrint",
			  "Sorter",
			  "TraySwitch",

			  /* PickOne keywords */
			  "AdvanceMedia",
			  "BindColor",
			  "BindEdge",
			  "BindType",
			  "BindWhen",
			  "BitsPerPixel",
			  "ColorModel",
			  "CutMedia",
			  "Duplex",
			  "FoldType",
			  "FoldWhen",
			  "InputSlot",
			  "JCLFrameBufferSize",
			  "JCLResolution",
			  "Jog",
			  "MediaColor",
			  "MediaType",
			  "MediaWeight",
			  "OutputBin",
			  "OutputMode",
			  "OutputOrder",
			  "PageRegion",
			  "PageSize",
			  "Resolution",
			  "Separations",
			  "Signature",
			  "Slipsheet",
			  "Smoothing",
			  "StapleLocation",
			  "StapleOrientation",
			  "StapleWhen",
			  "StapleX",
			  "StapleY"
#else /* !CUPS_USE_FULL_UI_KEYWORDS_LIST */
			  "PageRegion",
			  "PageSize"
#endif /* CUPS_USE_FULL_UI_KEYWORDS_LIST */
			};