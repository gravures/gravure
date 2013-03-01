#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys, math

try:
    from scribus import *
except ImportError:
    print "This script only runs from within Scribus."
    sys.exit(1)

def main():
	NUM_PATCHES = 256
	PATCH_W = 12
	PATCH_H = 14
	MARGIN = 15

	setUnit(UNIT_MILLIMETERS)
	setMargins(MARGIN, MARGIN, MARGIN, MARGIN)
	(width,  height) = getPageSize()
	draw_W = width - MARGIN*2
	draw_H = height - MARGIN*2

	max_w_patches = int(math.floor(draw_W / PATCH_W))
	max_h_patches = int(math.floor(draw_H / PATCH_H))

	print max_w_patches, max_h_patches, max_w_patches*max_h_patches

	if (max_w_patches*max_h_patches)<NUM_PATCHES :
		print "Diminuer la taille des patches"
	else :
		drawPatches(NUM_PATCHES, max_w_patches, max_h_patches, PATCH_W, PATCH_H, MARGIN)


def drawPatches(n, mw, mh, pw, ph, m):
	incTab = range(n)
  	defineColor("white", 0, 0, 0, 0)

	#createCharStyle("cLabel", fontsize=7)
	for i in incTab:
		x = (pw*i)-(mw*pw*(i/mw))+m
		y = ph*int(i/mw)+m
		rect = createRect(x, y, pw, ph)
		defineColor("gray"+str(i), 0, 0, 0, i)
		setFillColor("gray"+str(i), rect)
		label = createText(x, y, pw, 3.5)
		setFillColor("white", label)
		setFont("DejaVu Sans ExtraLight", label)
		setFontSize(7, label)
		setLineSpacing(.1, label)
		#setStyle("cLabel", label)
		ps_value = round(1-((1.0/(n-1)*i)), 5)
		setText(str(ps_value), label)

if __name__ == '__main__':
    if haveDoc():
        main()
    else:
        docerrmesg = "There must be an open document."

