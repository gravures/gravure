#!/usr/bin/env python3
#
# -*- coding: utf-8 -*-
#
#       Copyright (c) Gilles Coissac 2021 <gilles@ideographe.fr>
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 3 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.
#
from setuptools import setup, Extension


def get_extensions():
    return [
        Extension(
            'property',
            sources=['src/gravure/core/property.pyx'],
            include_dirs=[],
            libraries=[],
            runtime_library_dirs=[],
            extra_objects=[],
            extra_compile_args=[],
        ),
        Extension(
            'stoch',
            sources=['src/gravure/halftone/stoch.pyx'],
            include_dirs=[],
            libraries=[],
            runtime_library_dirs=[],
            extra_objects=[],
            extra_compile_args=['-fopenmp'],
            extra_link_args=['-fopenmp']
        ),
        # Extension(
        #     'mdarray',
        #     sources=[
        #         'src/gravure/numeric/bit_width_type.pxd',
        #         'src/gravure/numeric/max_const.pyx',
        #         'src/gravure/numeric/TYPE_DEF.pxi',
        #         'src/gravure/numeric/type_promotion.pyx',
        #         'src/gravure/numeric/_struct.pyx',
        #         'src/gravure/numeric/mdarray.pyx',
        #     ],
        #     include_dirs=['src/gravure/numeric/'],
        #     libraries=[],
        #     runtime_library_dirs=[],
        #     extra_objects=[],
        #     extra_compile_args=[],
        # )
    ]


setup(
    ext_modules=get_extensions(),
)
