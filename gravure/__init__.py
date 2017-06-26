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

# this is a namespace package
import pkg_resources
pkg_resources.declare_namespace(__name__)

import enum as _enum

__all__ =['ANGLE']

@_enum.unique
class ANGLE(_enum.IntEnum):
    """Enumeration used to set unit measurement of angle.

        Valid values are : ANGLE.DEGREE and ANGLE.RADIAN.
        """
    DEGREE = 1
    RADIAN = 0
