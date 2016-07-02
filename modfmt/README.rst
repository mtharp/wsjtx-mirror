PyFMT Development Notes
^^^^^^^^^^^^^^^^^^^^^^^
This process has already been performed for the `PyFMT Project`_. The `Pmw Generation Process`_ details how `Pmw`_ was added to the :code:`./fmt/modfmt` source folder.

Background
^^^^^^^^^^
Several `Major Linux Distributions`_ ( `Ubuntu`_ and `Debian`_ for example) do not include a `Python3`_ package for `Pmw`_. There are `Wheel Packages`_ available via `PyPi`_ ( typicalled installed via `Pip`_ ), but that would force the user to install `Pmw`_ outside the normal package management system, which is not not optimal.

Fortunately, the `Pmw Project`_ provides a simple method to include `Pmw`_ for any given project. A script called :code:`bundlepmw.py`, which resides in the :code:`../Pmw/Pmw-2.0.0/bin` directory, can be run which generateds a single Python script ( :code:`Pmw.py` ) that can be imported with minimal fuss.

Pmw Generation Process
^^^^^^^^^^^^^^^^^^^^^^
The process for generateing the latest version of `Pmw`_ is as follows:

1. Download the latest source tarball from the `Pmw Files Section`_
2. Extract the file and change directories to :code:`../Pmw/Pmw-2.0.0/bin`
3. Then run the bundler script, including the parent lib directory at invocation.

.. code-block:: bash

   cd ./Pmw/Pmw-2.0.0/bin
   python bundlepmw.py ../lib

Script Usage
^^^^^^^^^^^^
To import the `Pmw`_ module, copy the scripts :code:`Pmw.py, PmwColor.py and PmwBlt.py` to :code:`./fmt/modfmt` directory. For any module or script that needs `Pmw`_, import the main `Pmw`_ module.

.. code-block:: python

   import Pmw


Wherever the main script :code:`Pmw.py` resides, :code:`PmwColor.py and PmwBlt.py` must also be in the same directory. That should allow the use of any `Pmw`_ module throughout a given script.

.. _Pmw Project: https://sourceforge.net/projects/pmw/?source=navbar
.. _Pmw: https://sourceforge.net/projects/pmw/?source=navbar
.. _Pmw Files Section: https://sourceforge.net/projects/pmw/files/Pmw2
.. _Source tar.gz: https://sourceforge.net/projects/pmw/files/Pmw2/
.. _Python3: https://www.python.org/download/releases/3.0/
.. _Ubuntu: http://www.ubuntu.com/
.. _Debian: https://www.debian.org/
.. _PyPi: https://pypi.python.org/pypi
.. _Wheel Packages: https://pypi.python.org/pypi/Pmw/2.0.0
.. _PyFMT Project: https://sourceforge.net/p/wsjt/wsjt/HEAD/tree/branches/fmt/
.. _Pip: https://readthedocs.org/projects/pip/
.. _Major Linux Distributions: https://distrowatch.com/dwres.php?resource=major