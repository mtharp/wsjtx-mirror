dnl $Id$
dnl Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([PyFMT], [0.1.0], [wsjt-devel@lists.sourceforge.net],[],
[http://www.physics.princeton.edu/pulsar/K1JT/wspr.html])
PYFMT_COPYRIGHT="Copyright (C) 2001-2016 Joseph H Taylor, Jr, K1JT"

AC_SUBST([BUGS], ["$PACKAGE_BUGREPORT"])
AC_SUBST([PROGRAM], ["$PACKAGE_NAME"])
AC_SUBST([VERSION], ["$PACKAGE_VERSION"])
AC_SUBST([WEB], ["$PACKAGE_URL"])
AC_SUBST([COPYRIGHT], ["$PYFMT_COPYRIGHT"])

#------------------------------------------------------------------------------
#  canonical host and autotools locations
#------------------------------------------------------------------------------
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])
AC_CANONICAL_HOST
AC_CANONICAL_BUILD
AC_SUBST([OS], ["$host_os"])
AC_SUBST([CPU], ["$host_cpu"])

#------------------------------------------------------------------------------
#  set default install prefix if not specified
#------------------------------------------------------------------------------
AC_PREFIX_DEFAULT("/usr/local")
if test "$prefix" = "NONE"; then 
	prefix=${ac_default_prefix}
fi
AC_SUBST([PREFIX], ["$prefix"])

#------------------------------------------------------------------------------
#  system install folder locations
#------------------------------------------------------------------------------
BINDIR=${PREFIX}/bin
PYFMTLIB=${PREFIX}/lib/pyfmt
SHARED=${PREFIX}/share/pyfmt
MANDIR=${PREFIX}/share/man/man1
DOCDIR=${PREFIX}/share/doc/pyfmt
AC_SUBST([BINDIR], ["$BINDIR"])
AC_SUBST([SHARED], ["$SHARED"])
AC_SUBST([DOCDIR], ["$DOCDIR"])
AC_SUBST([PYFMTLIB], ["$PYFMTLIB"])
AC_SUBST([MANDIR], ["$MANDIR"])

#------------------------------------------------------------------------------
#  source - docs and manpage paths
#------------------------------------------------------------------------------
LOGNAME="$LOGNAME"
DOCSRC=$(exec pwd)/doc/user_guide
THEMEDIR=$(exec pwd)/doc/theme/pyfmt
DOCCONF=$(exec pwd)/doc/pyfmt.conf
DOCPATH=$(exec pwd)/doc/
MODIR==$(exec pwd)/modfmt
AC_SUBST([LOGNAME], ["$LOGNAME"])
AC_SUBST([DOCSRC], ["$DOCSRC"])
AC_SUBST([THEMEDIR], ["$THEMEDIR"])
AC_SUBST([DOCCONF], ["$DOCCONF"])
AC_SUBST([DOCPATH], ["$DOCPATH"])

#------------------------------------------------------------------------------
#  tool chain
#------------------------------------------------------------------------------
OCFLAGS="$CFLAGS"
AC_PROG_CC
AC_PROG_CXX
AC_PROG_FC
AC_PROG_MAKE_SET
AC_PROG_RANLIB
AC_PROG_GCC_TRADITIONAL
AC_USE_SYSTEM_EXTENSIONS
CFLAGS="$OCFLAGS"

#------------------------------------------------------------------------------
#  general tools
#------------------------------------------------------------------------------
AC_ISC_POSIX
AC_C_INLINE
AC_PROG_INSTALL
AC_PATH_PROG(AR, ar)
AC_PATH_PROG(AWK, awk)
AC_PATH_PROG(CHMOD, chmod)
AC_PATH_PROG(CHOWN, chown)
AC_PATH_PROG(CHOWN, chown)
AC_PATH_PROG(CP, cp)
AC_PATH_PROG(CUT, cut)
AC_PATH_PROG(ECHO, echo)
AC_PATH_PROG(HEAD, head)
AC_PATH_PROG(LD, ld)
AC_PATH_PROG(LN, ln)
AC_PATH_PROG(MKDIR, mkdir)
AC_PATH_PROG(MV, mv)
AC_PATH_PROG(PYTHON, python)
AC_PATH_PROG(RM, rm)
AC_PATH_PROG(SED, sed)
AC_PATH_PROG(SORT, sort)
AC_PATH_PROG(TEST, [test], [test])
AC_PATH_PROG(TAIL, tail)
AC_PATH_PROG(TR, tr)

#------------------------------------------------------------------------------
#  try to find the right lib / include paths
#------------------------------------------------------------------------------
if test -d "/usr/lib64"; then LIBDIR="-L/usr/lib64 ${LIBDIR}"; fi
if test -d "/usr/local/lib"; then LIBDIR="-L/usr/local/lib ${LIBDIR}"; fi
if test -d "/usr/lib/x86_64-linux-gnu"; then LIBDIR="-L/usr/lib/x86_64-linux-gnu ${LIBDIR}"; fi
if test -d "/usr/lib/i386-linux-gnu"; then LIBDIR="-L/usr/lib/i386-linux-gnu ${LIBDIR}"; fi
if test -d "/usr/lib"; then LIBDIR="-L/usr/lib ${LIBDIR}"; fi
if test -d "/usr/lib/arm-linux-gnueabihf"; then LIBDIR="-L/usr/lib/arm-linux-gnueabihf ${LIBDIR}"; fi

#------------------------------------------------------------------------------
#  check headers
#------------------------------------------------------------------------------
AC_HEADER_STDC
AC_HEADER_DIRENT
AC_HEADER_TIME
AC_TYPE_INT16_T
AC_TYPE_INT32_T
AC_TYPE_INT64_T
AC_TYPE_INT8_T
AC_TYPE_PID_T
AC_TYPE_SIZE_T
AC_TYPE_UINT16_T
AC_TYPE_UINT32_T
AC_TYPE_UINT64_T
AC_TYPE_UINT8_T
AC_FUNC_MALLOC
AC_CHECK_FUNCS([gettimeofday strchr])
AC_CHECK_HEADERS([errno.h fcntl.h fcntl.h float.h fftw3.h inttypes.h libgen.h \
limits.h linux/ppdev.h dev/ppbus/ppi.h linux/parport.h portaudio.h \
samplerate.h stddef.h stdint.h stdint.h stdio.h stdlib.h string.h strings.h \
sys/ioctl.h sys/ioctl.h sys/param.h sys/resource.h sys/stat.h sys/syslog.h \
sys/time.h sys/wait.h termios.h unistd.h wait.h])

#------------------------------------------------------------------------------
#  user defined docdir
#-----------------------------------------------------------------------------
AC_ARG_WITH([docdir],
AC_HELP_STRING([--with-docdir=DIR], [Path to documentation]), [docdir=$with_docdir])
if test -n "$with_docdir"; then
	AC_SUBST([DOCDIR], ["$with_docdir"])
fi

#------------------------------------------------------------------------------
#  user defined mandir
#------------------------------------------------------------------------------
AC_ARG_WITH([mandir],
AC_HELP_STRING([--with-mandir=DIR], [Path to manpages]), [mandir=$with_mandir])
if test -n "$with_mandir"; then
	AC_SUBST([MANDIR], ["$with_mandir"])
fi

#------------------------------------------------------------------------------
#  enable - disable user guide, default is enabled
#------------------------------------------------------------------------------
AC_PYFMT_DOCS

#------------------------------------------------------------------------------
#  enable - disable manpages, default is enabled
#------------------------------------------------------------------------------
AC_PYFMT_MANPAGES

#------------------------------------------------------------------------------
#  check python ( whatever is the default Python install )
#------------------------------------------------------------------------------
AC_PYFMT_PYTHON

#------------------------------------------------------------------------------
#  check python modules - Pmw, PySerial, PyAudio
#------------------------------------------------------------------------------
AC_PYFMT_PYMOD(serial)
AC_PYFMT_PYMOD(pyaudio)

#------------------------------------------------------------------------------
#  check gfortran
#------------------------------------------------------------------------------
AC_PYFMT_GFORTRAN

#------------------------------------------------------------------------------
#  check fftw3
#------------------------------------------------------------------------------
AC_PYFMT_FFTW3

#------------------------------------------------------------------------------
#  check samplerate
#------------------------------------------------------------------------------
AC_PYFMT_SAMPLERATE

#------------------------------------------------------------------------------
#  check portaudio
#------------------------------------------------------------------------------
AC_PYFMT_PORTAUDIO

#------------------------------------------------------------------------------
#  consolidate flags - ( remove dupes and sort )
#------------------------------------------------------------------------------
AC_PYFMT_FLAGS

#------------------------------------------------------------------------------
#  check rigctl
#------------------------------------------------------------------------------
AC_PYFMT_RIGCTL

#------------------------------------------------------------------------------
#  report Python
#------------------------------------------------------------------------------
if test "$HAVE_PY" = "no"; then
	echo
	echo "Python v2.6++ is required to build $PACKAGE_NAME"
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: Python v2.6+"
	echo "[2] Add Python2.6+ to your system paths"
	echo "[3] Include Python2.6+:"
	echo
	echo 'Example:'
	echo './configure --with-python="/path/to/python/"'
	echo
	exit 1
fi

#------------------------------------------------------------------------------
#  report rigctl
#------------------------------------------------------------------------------
if test ${HAVE_RGC} = "no"; then
	echo "CONFIGURATION ERROR"
	echo
	echo "Hamlib Rig Control to run $PACKAGE_NAME"
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: libhamlib-utils"
	echo "[2] configure --with-rigctl=[Path]"
	echo
	echo 'Example:'
	echo "./autogen.sh --with-rigctl=/home/$USER/jtsdk/hamlib3/bin/rigctl"
	echo
	exit 1
fi

#------------------------------------------------------------------------------
#  report samplerate
#------------------------------------------------------------------------------

if test ${HAVE_SAMPLERATE} -eq 1; then
	sr_status="OK"
else
	echo "CONFIGURATION ERROR"
	echo
	echo "Samplerate-dev is required to build $PACKAGE_NAME"
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: Saplerate - Libs & Headers"
	echo "[2] Confiure Samplerate with non-standard paths:"
	echo
	echo 'Example:'
	echo './configure CPPFLAGS="-I/path/to/samplerate/include" \'
	echo 'LIBDIR="/path/to/samplerate/lib"'
	echo
	exit 1
fi

#------------------------------------------------------------------------------
#  report fftw
#------------------------------------------------------------------------------

if test ${HAVE_FFTW3_LIB} -eq 1; then
	ff_status="OK"
else
	echo "CONFIGURATION ERROR"
	echo
	echo "FFTW3 Libs were not found"
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: libfftw3-dev"
	echo "[2] Confiure FFTW with non-standard paths:"
	echo
	echo './configure LIBDIR="/path/to/fftw3/lib"'
	echo
	exit 1
fi

#------------------------------------------------------------------------------
#  report portaudio
#------------------------------------------------------------------------------

if test ${HAVE_PORTAUDIO} -eq 1; then
	pa_status="OK"
else
	echo "CONFIGURATION ERROR"
	echo
	echo "Portaudio-v19 was not found"
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: portaudio19-dev"
	echo "[2] Confiure portaudio with non-standard paths:"
	echo
	echo './configure CPPFLAGS="-I/path/to/portaudio/include" \'
	echo 'LIBDIR="/path/to/portaudio/lib"'
	echo
	exit 1
fi

#------------------------------------------------------------------------------
#  subs and parameter expansion
#------------------------------------------------------------------------------
AC_SUBST([CFLAGS], ["$CFLAGS"])
AC_SUBST([CPPFLAGS], ["$CPPFLAGS"])
AC_SUBST([FFLAGS], ["$FFLAGS"])
AC_SUBST([LDFLAGS], ["$LDFLAGS"])
AC_SUBST([FCOPT], ["$FCOPT"])
AC_SUBST([LIBDIR], ["$LIBDIR"])
AC_CONFIG_FILES([Makefile
pyfmt
data/pyfmt.desktop
doc/pyfmt.conf
manpages/fcal.1.txt
manpages/fmeasure.1.txt
manpages/fmtave.1.txt
manpages/fmtest.1.txt
])
AC_OUTPUT

#------------------------------------------------------------------------------
#  configure summary
#------------------------------------------------------------------------------
echo ''
echo "-------------------------------------------"
echo " Configuration Summary"
echo "-------------------------------------------"
echo ''
echo " Package .........: ${PROGRAM} ${VERSION}"
echo " Install prefix ..: ${PREFIX}"
echo " Rig Control......: ${RIGCTL}"
echo " Use Pmw v2 ......: ${PMW3}"
echo " Fcompiler: ......: ${FC}"
echo " FC Lib Path .....: ${FC_LIB_PATH}"
echo " FFTW3 ...........: ${ff_status}"
echo " Portaudio .......: ${pa_status}"
echo " Build Docs ......: ${BDOC}"
echo " Build Manpages ..: ${BMANP}"
echo " Copyright........: ${COPYRIGHT}"
echo " Website .........: ${WEB}"
echo " Report Bugs To ..: ${BUGS}"
echo ''
echo " Finished Configuration"
echo ''
echo " To build, type ..: make"
echo ''
