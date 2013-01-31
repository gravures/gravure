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

__author__ = "Gilles Coissac <gilles@atelierobscur.org>"
__date__ = "Mon Jan 21 11:05:05 2013"
__version__ = "$Revision: 0.1 $"
__credits__ = "Atelier Obscur : www.atelierobscur.org"

class _PARAM():

    __class_dict = {}

    def __init__(self):
        self.__dict__ = self.__class_dict

    def __setattr__(self, name, val):
        # val should be int & name shouldn't exist
        if not type(val) is int:
            raise AttributeError, 'Value of Attribute %s should be an int'%(name,)
        elif name in self.__dict__:
            raise AttributeError, 'Attribute %s already exist'%(name,)
        else :
            self.__dict__[name] = val

    def __getattribute__(self,name):
        if not name in self.__dict__:
            raise AttributeError, "Attribute %s doesn't exist"%(name,)
        else :
            return self.__dict__[name]

import sys
sys.modules[__name__]=_PARAM()




