dnl $Id$
dnl Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([WSJT], [10.0], [wsjt-devel@lists.sourceforge.net],[],
[http://www.physics.princeton.edu/pulsar/K1JT/wspr.html])
WSJT_COPYRIGHT="Copyright (C) 2001-2016 Joseph H Taylor, Jr, K1JT"

AC_SUBST([BUGS], ["$PACKAGE_BUGREPORT"])
AC_SUBST([PROGRAM], ["$PACKAGE_NAME"])
AC_SUBST([VERSION], ["$PACKAGE_VERSION"])
AC_SUBST([WEB], ["$PACKAGE_URL"])
AC_SUBST([COPYRIGHT], ["$WSJT_COPYRIGHT"])


# ------------------------------------------------------------------------------
#  canonical host and autotools locations
# ------------------------------------------------------------------------------
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])
AC_CANONICAL_HOST
AC_CANONICAL_BUILD
AC_SUBST([OS], ["$host_os"])
AC_SUBST([CPU], ["$host_cpu"])


# ------------------------------------------------------------------------------
#  set default install prefix if not specified
# ------------------------------------------------------------------------------
AC_PREFIX_DEFAULT("/usr/local/wsjt")
if test "$prefix" = "NONE"; then 
	prefix=${ac_default_prefix}
fi
AC_SUBST([PREFIX], ["$prefix"])

# ------------------------------------------------------------------------------
#  system install folder locations
# ------------------------------------------------------------------------------
BINDIR=${PREFIX}/bin
SHARED=${PREFIX}/share/wsjt
DOCDIR=${PREFIX}/share/doc/wsjt
WSJTLIB=${PREFIX}/lib/wsjt
MANDIR=${PREFIX}/share/man/man1
AC_SUBST([BINDIR], ["$BINDIR"])
AC_SUBST([SHARED], ["$SHARED"])
AC_SUBST([DOCDIR], ["$DOCDIR"])
AC_SUBST([WSJTLIB], ["$WSJTLIB"])
AC_SUBST([MANDIR], ["$MANDIR"])


# ------------------------------------------------------------------------------
#  source - docs and manpage paths
# ------------------------------------------------------------------------------
LOGNAME="$LOGNAME"
DOCSRC=$(exec pwd)/doc/user_guide
THEMEDIR=$(exec pwd)/doc/theme/wsjt
DOCCONF=$(exec pwd)/doc/wsjt.conf
DOCPATH=$(exec pwd)/doc/
AC_SUBST([LOGNAME], ["$LOGNAME"])
AC_SUBST([DOCSRC], ["$DOCSRC"])
AC_SUBST([THEMEDIR], ["$THEMEDIR"])
AC_SUBST([DOCCONF], ["$DOCCONF"])
AC_SUBST([DOCPATH], ["$DOCPATH"])


# ------------------------------------------------------------------------------
#  tool chain
# ------------------------------------------------------------------------------
OCFLAGS="$CFLAGS"
AC_PROG_CC
AC_PROG_CXX
AC_PROG_FC
AC_PROG_MAKE_SET
AC_PROG_RANLIB
AC_PROG_GCC_TRADITIONAL
AC_USE_SYSTEM_EXTENSIONS
CFLAGS="$OCFLAGS"


# ------------------------------------------------------------------------------
#  general tools
# ------------------------------------------------------------------------------
AC_ISC_POSIX
AC_C_INLINE
AC_PROG_INSTALL
AC_PATH_PROG(AR, ar)
AC_PATH_PROG(AWK, awk)
AC_PATH_PROG(CHOWN, chown)
AC_PATH_PROG(CHMOD, chmod)
AC_PATH_PROG(CP, cp)
AC_PATH_PROG(CUT, cut)
AC_PATH_PROG(CHOWN, chown)
AC_PATH_PROG(CHMOD, chmod)
AC_PATH_PROG(HEAD, head)
AC_PATH_PROG(RM, rm)
AC_PATH_PROG(LD, ld)
AC_PATH_PROG(LN, ln)
AC_PATH_PROG(MV, mv)
AC_PATH_PROG(MKDIR, mkdir)
AC_PATH_PROG(SORT, sort)
AC_PATH_PROG(TR, tr)
AC_PATH_PROG(SED, sed)
AC_PATH_PROG(TEST, [test], [test])


# ------------------------------------------------------------------------------
#  try to find the right lib / include paths
# ----------------------------------------------------------------------------
if test -d "/usr/lib64"; then LIBDIR="-L/usr/lib64 ${LIBDIR}"; fi
if test -d "/usr/local/lib"; then LIBDIR="-L/usr/local/lib ${LIBDIR}"; fi
if test -d "/usr/lib/x86_64-linux-gnu"; then LIBDIR="-L/usr/lib/x86_64-linux-gnu ${LIBDIR}"; fi
if test -d "/usr/lib/i386-linux-gnu"; then LIBDIR="-L/usr/lib/i386-linux-gnu ${LIBDIR}"; fi
if test -d "/usr/lib"; then LIBDIR="-L/usr/lib ${LIBDIR}"; fi
if test -d "/usr/lib/arm-linux-gnueabihf"; then LIBDIR="-L/usr/lib/arm-linux-gnueabihf ${LIBDIR}"; fi

# ------------------------------------------------------------------------------
#  standard header checks
# ------------------------------------------------------------------------------
AC_HEADER_STDC
AC_HEADER_TIME
AC_CHECK_HEADERS([fcntl.h float.h fftw3.h inttypes.h limits.h portaudio.h \
samplerate.h stdarg.h stddef.h stdint.h stdlib.h string.h sys/ioctl.h sys/param.h \
sys/time.h unistd.hinttypes.h stdint.h sys/resource.h sys/param.h errno.h \
sys/syslog.h stddef.h libgen.h sys/wait.h wait.h stdio.h termios.h \
sys/resource.h linux/ppdev.h dev/ppbus/ppi.h sys/stat.h fcntl.h sys/ioctl.h]
)

# ------------------------------------------------------------------------------
#  debug related
# ------------------------------------------------------------------------------
AC_WSJT_CLOBBER


# ------------------------------------------------------------------------------
#  enable - disable rsdtest tools, default is disabled
# ----------------------------------------------------------------------------
AC_WSJT_RSDTEST


# ------------------------------------------------------------------------------
#  enable - disable user guide, default is enabled
# ----------------------------------------------------------------------------
AC_WSJT_DOCS


# ------------------------------------------------------------------------------
#  enable - disable manpages, default is enabled
# ----------------------------------------------------------------------------
AC_WSJT_MANPAGES


# ------------------------------------------------------------------------------
#  python2 path
# ----------------------------------------------------------------------------
AC_WSJT_PYTHON2


# ------------------------------------------------------------------------------
#  Python3 path
# ------------------------------------------------------------------------------
AC_WSJT_PYTHON3


# ------------------------------------------------------------------------------
#  find f2py - ( must be built with Python3 )
# ------------------------------------------------------------------------------
AC_WSJT_F2PY


# ------------------------------------------------------------------------------
#  check gfortran
# ------------------------------------------------------------------------------
AC_WSJT_GFORTRAN


# ------------------------------------------------------------------------------
#  check fftw3
# ------------------------------------------------------------------------------
AC_WSJT_FFTW3


# ------------------------------------------------------------------------------
#  check samplerate
# ------------------------------------------------------------------------------
AC_WSJT_SAMPLERATE


# ------------------------------------------------------------------------------
#  check portaudio
# ------------------------------------------------------------------------------
AC_WSJT_PORTAUDIO

# ------------------------------------------------------------------------------
#  consolidate flags - ( remove dupes and sort )
# ------------------------------------------------------------------------------
AC_WSJT_FLAGS


# ------------------------------------------------------------------------------
#  substitute flag variables
# ------------------------------------------------------------------------------
AC_WSJT_FLAGS


# ------------------------------------------------------------------------------
#  report f2py
# ------------------------------------------------------------------------------
if test "$HAVE_F2PY" = "no"; then
	echo
	echo "F2PY v2.0 (Numpy 1.8.1+) is required to build $PACKAGE_NAME"
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: Python3 Numpy 1.8.1+"
	echo "[2] Add F2PY v2.0 to your system paths"
	echo "[3] Include F2PY:"
	echo
	echo 'Example:'
	echo './configure --with-f2py=/path/to/f2py3'
	echo 
	exit 1
fi


# ------------------------------------------------------------------------------
#  report Python2
# ------------------------------------------------------------------------------
if test "$HAVE_PY2" = "no"; then
	echo
	echo "Python v2.6+ is required to build $PACKAGE_NAME"
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: Python v2.6+"
	echo "[2] Add Python2.6+ to your system paths"
	echo "[3] Include Python2.6+:"
	echo
	echo 'Example:'
	echo './configure --with-python2="/path/to/python2/"'
	echo
	exit 1
fi


# ------------------------------------------------------------------------------
#  report Python3
# ------------------------------------------------------------------------------
if test "$HAVE_PY3" = "no"; then
	echo
	echo "Python v3.2+ is required to build $PACKAGE_NAME"
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: Python v3.2+"
	echo "[2] Add Python3.2+ to your system paths"
	echo "[3] Include Python3.2+:"
	echo
	echo 'Example:'
	echo './configure --with-python3="/path/to/python3/"'
	echo
	exit 1
fi

# ------------------------------------------------------------------------------
#  report samplerate
# ------------------------------------------------------------------------------

if test ${HAVE_SAMPLERATE} -eq 1; then
	srstatus="OK"
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

# ------------------------------------------------------------------------------
#  report fftw
# ------------------------------------------------------------------------------

if test ${HAVE_FFTW3_LIB} -eq 1; then
	ffstatus="OK"
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

# ------------------------------------------------------------------------------
#  report portaudio
# ------------------------------------------------------------------------------

if test ${HAVE_PORTAUDIO} -eq 1; then
	pastatus="OK"
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


AC_SUBST([CFLAGS], ["$CFLAGS"])
AC_SUBST([CPPFLAGS], ["$CPPFLAGS"])
AC_SUBST([FFLAGS], ["$FFLAGS"])
AC_SUBST([LDFLAGS], ["$LDFLAGS"])
AC_SUBST([FCOPT], ["$FCOPT"])
AC_SUBST([LIBDIR], ["$LIBDIR"])

# Generate the make file
AC_CONFIG_FILES(Makefile
wsjt
wsjt.desktop
doc/wsjt.conf
)
AC_OUTPUT

# ------------------------------------------------------------------------------
#  configure summary
# ------------------------------------------------------------------------------
echo ''
echo "-------------------------------------------"
echo " Configuration Summary"
echo "-------------------------------------------"
echo ''
echo " Install prefix .......: ${PREFIX}"
echo " Package ..............: ${PROGRAM} ${VERSION}"
if test "${BDOC}" = "Yes"; then
echo " Build Docs ...........: ${BDOC}"
fi
if test "${BMANP}" = "Yes"; then
echo " Build Manpages .......: ${BMANP}"
fi
if test "${RSDTEST}" = "Yes"; then
echo " Build RSD Test Tools .: ${RSDTEST}"
fi
echo " Python2 ..............: ${PYTHON2} ${PY2V}"
echo " Python3 ..............: ${PYTHON3} ${PY3V}"
echo " F2py .................: ${F2PY}"
echo " Fcompiler: ...........: ${FC}"
echo " FC Lib Path ..........: ${FC_LIB_PATH}"
echo " Samplerate ...........: ${srstatus}"
echo " FFTW3 ................: ${ffstatus}"
echo " Portaudio ............: ${pastatus}"
echo " Copyright.............: ${WSJT_COPYRIGHT}"
echo " Website ..............: ${WEB}"
echo " Report Bugs To .......: ${BUGS}"
echo ''
echo " Finished Configuration"
echo ''
echo " To build, type ...: make"
echo ''
