PyFMT is a Python wrapper for the FMT Suite by Joe Taylor (K1JT). The packages were originally contained in the `Python WSPR Package`_


Development Status
^^^^^^^^^^^^^^^^^^
All of the core elements are now functional. The :code:`ftmparams.py` scripts provided the following:

* Set station information (Call and Grid)
* Select the Input Audio Device (via `PyAudio`_)
* Setup Rig Control via `Hamlib Control Libraries`_
* Configure COM Ports settings ( via `PySerial`_
* Write out :code:`fmtparams.ini` and :code:`fmt.ini` files
* Widgets are drawn with a combination of `tKinter`_ and `Pmw`_.

Individual Program Functions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Each of the utility programs and shell scritp files in the FMT package performs a single function ( excerpts from `FMT User Guide`_ ):

**gocal** –Shell file, must be edited to your specific needs. Executes program fmtest for a number of specified frequency-calibration stations. Output will accumulate in file :code:`fmt.all`.

**fmtest** – Sets the dial frequency of a CAT-controlled radio and performs a sequence of measurements of the strongest resulting audio tone near a specified offset frequency. Input parameters are taken from the command line, and output goes to files :code:`fmt.out` and :code:`fmt.all`. The latter file is cumulative.

**fmtave** – Averages data found in a specified file having the format of fmt.all. Output goes to file :code:`fmtave.out`.

**fcal** – Calculates a best-fit straight line for a data saved in :code:`fmtave.out`. Results are saved in file :code:`fcal.out`.

**fmeasure** – Calculates the properly calibrated frequency of each test signal found in file :code:`fmtave.out`. Results are saved in file :code:`fmeasure.out`, and these are the numbers you should report if you are entering the Frequency Measuring Test.

Python Environment
^^^^^^^^^^^^^^^^^^
Both Python27 and Python35 have been tested. In addition to the base modules, install the following packages with pip:

**For Python2**

.. code-block:: bash

   pip install Pwm pyserial pyaudio

**For Python3**

.. code-block:: bash

   pip3 install Pwm pyserial pyaudio

System Packages
^^^^^^^^^^^^^^^
The following packages are required at the system level:

* GCC
* Gfortran
* automake
* autoconf
* Python2 / Python3
* portaudio19-dev
* libfftw3-3
* libsamplerate0-dev

Checkout and Compiling
^^^^^^^^^^^^^^^^^^^^^^
Check out the code from the `WSJT Sourceforge Project`_

.. code-block:: bash

   1. svn co https://svn.code.sf.net/p/wsjt/wsjt/branches/fmt
   2. ./fmt
   3. ./autogen.sh
   4. make && make install

.. NOTE:: At this time, unless DESTDIR is used, the install location will be created in the source tree under ./install

Uninstall
^^^^^^^^^
To uninstall, perform a distclean in the checkout root directory:

.. code-block:: bash

   make distclean
   
Usage and Testing
^^^^^^^^^^^^^^^^^
There is an `FMT USer Guide`_ available from the `WSJT`_ main site. 
Additionally, within the install directory you will find the :code:`gocal` 
file. Edit this as needed for your local stations.

Before running any of the **FMT Tools**, users should run :code:`fmtparams.py`
**Before** running :code:`gocal`.

.. code-block:: bash

   1. cd ./install
   2. python -O ./fmtparams.py
   3. Fill in CALL and GRID.
   4. Select Audio Device and Rig from the pulls down options
   5. Setup up yout CAT comport settings
   6. CLick Save

If the the rig selection and comprt settings are correct, you will be presented
with an info box stating so.

If the rig command fails, correct the entries and Re-Save.

.. NOTE:: The :code:`fmtparams.ini` and :code:`fmt.ini` willl not be written until a successful CAT connection can be made.

After successful rig control setup, follow the `FMT User Guide`_ to perform the calibration test.


.. _Python Wspr Package: http://physics.princeton.edu/pulsar/k1jt/wspr.html
.. _Hamlib COntrol Libraries: https://sourceforge.net/projects/hamlib/?source=directory
.. _PyAudio: https://people.csail.mit.edu/hubert/pyaudio/
.. _PySerial: http://pyserial.readthedocs.io/en/latest/pyserial_api.html
.. _Python: https://www.python.org/
.. _Portaudio: http://portaudio.com/
.. _tKinter: https://wiki.python.org/moin/TkInter
.. _Pmw: http://pmw.sourceforge.net/
.. _WSJT Sourceforge Project: https://sourceforge.net/p/wsjt/wsjt/HEAD/tree/branches/fmt/
.. _FMT User Guide: http://physics.princeton.edu/pulsar/k1jt/FMT_User.pdf
.. _WSJT: http://physics.princeton.edu/pulsar/k1jt/
