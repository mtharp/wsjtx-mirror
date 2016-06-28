PyFMT is a Python wrapper for the former FMT Suite by Joe Taylor (K1JT). The packages were originally contains in the `Python WSPR Package`_


Development Status
^^^^^^^^^^^^^^^^^^
At this time, only the FMT Paramaters Scritp is functional. It's
main purpose is to:

* Set station information (Call and Grid)
* Select the Input Audio Device (via `PyAudio`_)
* Setup Rig Control via `Hamlib Control Libraries`_
* Configure COM Ports settings ( via `PySerial`_
* Write out :code:`fmtparams.ini` and :code:`fmt.ini` files
* Widgets are drawn with a combination of `tKinter`_ and `Pmw`_.

Development Environment
^^^^^^^^^^^^^^^^^^^^^^^
The testing environment will be detailed in the documentation when complete.


Python Environment
^^^^^^^^^^^^^^^^^^
The Python environment is setup through `Anaconda`_ from `Continuum Analytics`_ and features a robust set of `Python`_ packages designed for Scientific Analysis. Detailed information about environment setup will be provided in the development documentaiton.


System Packages
^^^^^^^^^^^^^^^
At present, the only system level package requirement is `Portaudio`_. As the package progresses, GCC and Gfortran will be required in order to compile
the various Fortran applications.



.. _Python Wspr Package: http://physics.princeton.edu/pulsar/k1jt/wspr.html
.. _Hamlib COntrol Libraries: https://sourceforge.net/projects/hamlib/?source=directory
.. _PyAudio: https://people.csail.mit.edu/hubert/pyaudio/
.. _PySerial: http://pyserial.readthedocs.io/en/latest/pyserial_api.html
.. _Anaconda: https://www.continuum.io/downloads
.. _Continuum Analytics: https://www.continuum.io/
.. _Python: https://www.python.org/
.. _Portaudio: http://portaudio.com/
.. _tKinter: https://wiki.python.org/moin/TkInter
.. _Pmw: http://pmw.sourceforge.net/