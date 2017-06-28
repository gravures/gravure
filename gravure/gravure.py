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



import enum as _enum

__all__ =['ANGLE','PARAM']


@_enum.unique
class ANGLE(_enum.IntEnum):
    """Enumeration used to set unit measurement of angle.

        Valid values are : ANGLE.DEGREE and ANGLE.RADIAN.
        """
    DEGREE = 1
    RADIAN = 0


@_enum.unique
class PARAM(_enum.IntEnum):
    SYSTEM_SERVER                 = 10
    SYSTEM_LIMITS                 = 11
    SYSTEM_FILTERS                = 12
    SYSTEM_FONTS                  = 13
    SYSTEM_COLOR                  = 14

    DEVICE_INSTALLABLE            = 20
    DEVICE_FILTERS                = 21
    DEVICE_STATE                  = 22
    DEVICE_BEHAVIOR               = 23
    DEVICE_ACCES                  = 24

    LINE_PRINT_MODE               = 30
    LINE_PRINT_RASTER             = 31
    LINE_COLOR_CALIBRATION        = 32
    LINE_GEOMETRY_CALIBRATION     = 33

    JOB_SOURCE_COLOR_HANDLING     = 40
    JOB_DEST_COLOR_HANDLING       = 41
    JOB_MEDIA_SELECTION           = 42
    JOB_IMPOSITION                = 43
    JOB_FINISHING                 = 44
    JOB_COLOR_ADJUSTEMENT         = 45
    JOB_GEOMETRY_ADJUSTEMENT      = 46












