================
Python
================
| Created lundi 14 novembre 2011

Idiomatic Python
^^^^^^^^^^^^^^^^
| `http://python.net/~goodger/projects/pycon/2007/idiomatic/handout.html <http://python.net/~goodger/projects/pycon/2007/idiomatic/handout.html>`_

Packaging Tools
^^^^^^^^^^^^^^^
| cx_Freeze

Debian & Python
^^^^^^^^^^^^^^^
| `http://www.debian.org/doc/packaging-manuals/python-policy/ <http://www.debian.org/doc/packaging-manuals/python-policy/>`_

Testing Tools
^^^^^^^^^^^^^
| `https://nose.readthedocs.org/en/latest/ <https://nose.readthedocs.org/en/latest/>`_

Gtk3
^^^^
| → `http://python-gtk-3-tutorial.readthedocs.org/en/latest/index.html <http://python-gtk-3-tutorial.readthedocs.org/en/latest/index.html>`_
| → `http://developer.gnome.org/gnome-devel-demos/stable/ <http://developer.gnome.org/gnome-devel-demos/stable/>`_
| → `http://placidrage.bitbucket.org/0-computer/0-development/0-languages/0-python/1-gtk-python/index.html <http://placidrage.bitbucket.org/0-computer/0-development/0-languages/0-python/1-gtk-python/index.html>`_

| → `http://developer.gnome.org/gtk3/stable/ <http://developer.gnome.org/gtk3/stable/>`_
| `https://live.gnome.org/PyGObject <https://live.gnome.org/PyGObject>`_
| → `http://gnipsel.com/glade/index.html <http://gnipsel.com/glade/index.html>`_
| `http://pfrields.fedorapeople.org/presentations/OhioLF2011/PyGObject.pdf <http://pfrields.fedorapeople.org/presentations/OhioLF2011/PyGObject.pdf>`_
| `http://zetcode.com/gui/pygtk/ <http://zetcode.com/gui/pygtk/>`_
| → `http://learngtk.org/pygobject-tutorial/examples/ <http://learngtk.org/pygobject-tutorial/examples/>`_

Custom Widget with gtk3
^^^^^^^^^^^^^^^^^^^^^^^
| `http://zetcode.com/tutorials/gtktutorial/customwidget/ <http://zetcode.com/tutorials/gtktutorial/customwidget/>`_
| `http://developer.gnome.org/gtk3/stable/GtkDrawingArea.html <http://developer.gnome.org/gtk3/stable/GtkDrawingArea.html>`_
| `https://github.com/tliron/pygobject-example <https://github.com/tliron/pygobject-example>`_

Matplotlib gtk3
^^^^^^^^^^^^^^^
| `http://matplotlib.org/examples/user_interfaces/embedding_in_gtk3.html <http://matplotlib.org/examples/user_interfaces/embedding_in_gtk3.html>`_

Image Library
^^^^^^^^^^^^^

| - imageio 0.5.1
| - freeimage smc
| - opencv
| - vips
| - gegl


Pdf Library
^^^^^^^^^^^

| - PDF 1.0
| - pdfminer3K
| - pdfnup


2D Arrays & Numbers
^^^^^^^^^^^^^^^^^^^

CYTHON CEP
""""""""""
| `http://wiki.cython.org/enhancements/array <http://wiki.cython.org/enhancements/array>`_
| `http://docs.cython.org/src/userguide/memoryviews.html <http://docs.cython.org/src/userguide/memoryviews.html>`_

| `https://groups.google.com/forum/?fromgroups=#!topic/cython-users/CwtU_jYADgM <https://groups.google.com/forum/?fromgroups=#!topic/cython-users/CwtU_jYADgM>`_
| cython.view is a fake module. The cython array implementation and
| other things can be found in Cython/Utility/MemoryView.pyx.

| The reason it is slow is because no one ever cared to optimize it. It
| allocates shape and strides independently on the heap. So it contains
| at least 3 malloc calls, and a bunch of other code.

| If you want to make it really fast, implement it with a free list,
| only malloc the data and make sure the code in the constructor is
| native where possible. No one is actively working on it, but it's just
| Cython code, so patches would be appreciated and merged. 


Carrays
"""""""
| `https://github.com/FrancescAlted/carray <https://github.com/FrancescAlted/carray>`_
| `https://pypi.python.org/pypi/carray/0.5.1 <https://pypi.python.org/pypi/carray/0.5.1>`_


Cdecimal
""""""""
| `http://www.bytereef.org/mpdecimal/index.html <http://www.bytereef.org/mpdecimal/index.html>`_













