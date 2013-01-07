#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys, math

try:
	from scribus import *
except ImportError:
	print "This script only runs from within Scribus."
	sys.exit(1)

def main():
	setUnit(UNIT_MILLIMETERS)
	DrawH_Ruler()
	DrawV_Ruler()

def DrawV_Ruler():	
	(width,  height) = getPageSize()
	yEnd = int(math.ceil(height))
	xPos = int (width/2)
	h = 5
	cm=0
	    
	for ys in range(yEnd+1):
		if cm==0 : 
			h = 10 
		else : h = 5
		createLine(xPos, ys, xPos+h, ys)
		cm+=1
		if cm>9 : cm=0

def DrawH_Ruler():	
	(width,  height) = getPageSize()
	xEnd = int(math.ceil(width))
	yPos = int (height/2)
	h = 5
	cm=0
    
	for xs in range(xEnd+1):
		if cm==0 : 
			h = 10 
		else : h = 5
		createLine(xs, yPos, xs, yPos+h)
		cm+=1
		if cm>9 : cm=0

if __name__ == '__main__':
    if haveDoc():
        main()
    else:
        docerrmesg = "There must be an open document."
   
