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
from pkg_resources import parse_version
from setuptools import Extension, setup


def create_c_files():
    """Cythonize source files."""
    Options.docstrings = True
    Options.annotate = False
    try:
        cythonize(
            [
                "src/gravure/core/property.pyx",
                # "src/gravure/halftone/stoch.pyx",
            ],
            include_path=[],
            nthreads=mp.cpu_count(),
            compiler_directives={
                "language_level": 3,
                "binding": False,
                "boundscheck": True,
                "wraparound": True,
                "overflowcheck": True,
                "initializedcheck": True,
                "nonecheck": False,
                "embedsignature": True,
                "optimize.use_switch": False,
                "optimize.unpack_method_calls": True,
                "warn.undeclared": False,
                "warn.unreachable": True,
                "warn.maybe_uninitialized": True,
                "warn.unused": True,
                "warn.unused_arg": True,
                "warn.unused_result": True,
                "warn.multiple_declarators": True,
            },
        )
    except Cython.Compiler.Errors.CompileError as e:
        print(
            f"Errors when generating c source files '{e}', look at '.errors_log'"
            " files in your project directory for details."
        )
        raise (e)


try:
    import Cython
except ImportError:
    print("Cython is not detected")
else:
    min_cython = "0.29.21"
    if parse_version(Cython.__version__) >= parse_version(min_cython):
        import multiprocessing as mp

        from Cython.Build import cythonize
        from Cython.Compiler import Options

        print(f"Cython version {Cython.__version__} found")
        print("Cythonyzing source files ...")
        create_c_files()
    else:
        print(
            f"Need cython version {min_cython} to generate c files, "
            f"found version {Cython.__version__}"
        )


def get_extensions():
    """Return setuptools Extensions list."""
    return [
        Extension(
            'property',
            sources=['src/gravure/core/property.c'],
            include_dirs=[],
            libraries=[],
            runtime_library_dirs=[],
            extra_objects=[],
            extra_compile_args=[],
        ),
        # Extension(
        #     'stoch',
        #     sources=['src/gravure/halftone/stoch.c'],
        #     include_dirs=[],
        #     libraries=[],
        #     runtime_library_dirs=[],
        #     extra_objects=[],
        #     extra_compile_args=['-fopenmp'],
        #     extra_link_args=['-fopenmp']
        # ),
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
    ext_package="gravure.core",
    ext_modules=get_extensions(),
)
