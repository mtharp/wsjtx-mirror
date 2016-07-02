`PyFMT`_ is a Python wrapper for the `FMT Suite`_ by `Joe Taylor, (K1JT)`_. The program
suite was originally bundeled with the `WSPR Package`_. Its primary use if for Rig Calibration and the `ARRL Frequency Measurement Test`_


Development Status
^^^^^^^^^^^^^^^^^^
All of the core elements are now functional. The :code:`pyfmt` script provides the following:

* Set station information, Call and Grid
* Select Input Audio Device via `PyAudio`_
* Setup Rig Control via `Hamlib Control Libraries`_
* Configure COM Ports settings via `PySerial`_
* Write out :code:`pyfmt.ini` and :code:`fmt.ini` files
* Widgets are drawn with a combination of `tKinter`_ and `Pmw`_.

Individual Program Functions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Each of the utility programs and shell scritp files in the FMT package performs a single function ( excerpts from `FMT User Guide`_ ):

**gocal** Shell file, must be edited to your specific needs. Executes program fmtest for a number of specified frequency-calibration stations. Output will accumulate in file :code:`fmt.all`.

**fmtest**  Sets the dial frequency of a CAT-controlled radio and performs a sequence of measurements of the strongest resulting audio tone near a specified offset frequency. Input parameters are taken from the command line, and output goes to files :code:`fmt.out` and :code:`fmt.all`. The latter file is cumulative.

**fmtave**  Averages data found in a specified file having the format of fmt.all. Output goes to file :code:`fmtave.out`.

**fcal**  Calculates a best-fit straight line for a data saved in :code:`fmtave.out`. Results are saved in file :code:`fcal.out`.

**fmeasure**  Calculates the properly calibrated frequency of each test signal found in file :code:`fmtave.out`. Results are saved in file :code:`fmeasure.out`, and these are the numbers you should report if you are entering the Frequency Measuring Test.

Python Environment
^^^^^^^^^^^^^^^^^^
Both Python27 and Python35 have been tested. In addition to the base modules, install the following packages with pip:

**For Python2**

.. code-block:: bash

   pip install pyserial pyaudio

**For Python3**

.. code-block:: bash

   pip3 install pyserial pyaudio

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

Checkout and Compiling
^^^^^^^^^^^^^^^^^^^^^^
Check out the code from the `WSJT Sourceforge Project`_

.. code-block:: bash

   * svn co https://svn.code.sf.net/p/wsjt/wsjt/branches/fmt
   * cd ./fmt
   * ./autogen.sh
   * make
   * sudo make install


.. NOTE:: If your system does not have libhamlib-utiuls installed, you must pass a location of :code:`rigctl`, otherwise, the configure script will present an error message. The example below shows this method when compiled with `JTSDK for Nix`_.

.. code-block:: bash

   ./autogen.sh --with-rigctl="/home/$USER/jtsdk/hamlib3/bin/rigctl"

Uninstall
^^^^^^^^^
To uninstall **PyFMT**, ferform the following tasks in a terminal

.. code-block:: bash

   cd ./fmt               # location of the checkout
   sudo make uninstall    # run the invocation
   make distclean         # clean the source tree
   
Usage and Testing
^^^^^^^^^^^^^^^^^
There is an `FMT USer Guide`_ available from the `WSJT`_ main site. 
Additionally, within the install directory you will find the :code:`gocal` file. Edit this as needed for your local stations.

Before running any of the **FMT Tools**, users should run :code:`pyfmt` then select option (1) to configure Stations Parameters. there are two option you can pass to :code:`pyfmt`

.. code:: bash

   pyfmt -n NAME -p PATH
   
:code:`pyfmt -n NAME` specifics the profile to use in setting up Station Parameters. for example, using :code:`pyfmt -n ts2000` would create an instance for the Kenwood TS-2000, with all files and ini files being located in:

.. code:: bash

   /home/user-name/.local/share/ts2000

This configuratoin allows for running many different rig / port combinations, which allows running multiple radios at the same time. The contests of the folder, after a full run with **PyFMT** would look similar to:

.. code:: bash

   ├── fcal.out
   ├── fcal.plt
   ├── fmt.all
   ├── fmtave.out
   ├── fmt.ini
   ├── fmt.out
   ├── pyfmt.ini
   ├── gocal
   ├── hamlib_rig_numbers
   └── pyfmtrc.nix

.. NOTE:: If the the rig selection and comport settings are correct, you will be presented with an info box stating so. The :code:`pyfmt.ini` and :code:`fmt.ini` files are written after a successful CAT connection made by saving your paramerter.

After successful rig control setup, follow the `FMT User Guide`_ to perform the calibration test.

.. _WSPR Package: http://physics.princeton.edu/pulsar/k1jt/wspr.html
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
.. _JTSDK for Nix: https://sourceforge.net/projects/jtsdk/
.. _FMT Suite: http://physics.princeton.edu/pulsar/k1jt/FMT_User.pdf
.. _Joe Taylor, (K1JT): https://en.wikipedia.org/wiki/Joseph_Hooton_Taylor_Jr.
.. _PyFMT: https://sourceforge.net/p/wsjt/wsjt/HEAD/tree/branches/fmt/
.. _ARRL Frequency Measurement Test: http://www.arrl.org/frequency-measuring-test