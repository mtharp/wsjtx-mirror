dnl $Id$
dnl Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_COPYRIGHT([$Id$])
AC_INIT([WSPR], [4.0], [wsjt-devel@lists.sourceforge.net],[],
[http://www.physics.princeton.edu/pulsar/K1JT/wspr.html])

AC_CONFIG_AUX_DIR([build-aux])
AC_PREFIX_DEFAULT([$HOME/wspr])
AC_CANONICAL_HOST

dnl checks for programs.
AC_PROG_CC
AC_LANG([C])
AC_PROG_CXX
AC_PROG_MAKE_SET
AC_PROG_INSTALL
AC_PROG_RANLIB
AC_USE_SYSTEM_EXTENSIONS

dnl standard m4 checks
AC_C_INLINE
AC_PROG_GCC_TRADITIONAL
AC_PROG_MAKE_SET
AC_PROG_INSTALL
AC_PATH_PROG(RM, rm)
AC_PATH_PROG(CP, cp)
AC_PATH_PROG(MKDIR, mkdir)
AC_PATH_PROG(MV, mv)
AC_PATH_PROG(LN, ln)
AC_PATH_PROG(AWK, awk)
AC_PATH_PROG(SED, sed)
AC_PATH_PROG(AR, ar)
AC_PATH_PROG(LD, ld)
AC_PATH_PROG(SHELL, bash)
AC_SUBST(OS, "${host_os}")
AC_SUBST(CPU, "${host_cpu}")

dnl Checks for header files.
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
AC_CHECK_HEADERS([errno.h fcntl.h fcntl.h float.h inttypes.h libgen.h \
limits.h linux/ppdev.h dev/ppbus/ppi.h linux/parport.h pthread.h stddef.h \
stdint.h stdint.h stdio.h stdlib.h string.h strings.h sys/ioctl.h sys/ioctl.h \
sys/param.h sys/resource.h sys/stat.h sys/syslog.h sys/time.h sys/wait.h \
termios.h unistd.h wait.h])


dnl test for lib locations
if test -d /usr/lib64 ; then
	LDFLAGS="-L/opt/lib ${LDFLAGS}"
fi

dnl test for lib locations
if test -d /usr/lib64 ; then
	LDFLAGS="-L/usr/lib64 ${LDFLAGS}"
fi

dnl test for lib locations
if test -d /lib ; then
		LDFLAGS="-L/lib ${LDFLAGS}"
fi

dnl test for lib locations
if test -d /usr/local/lib ; then
	LDFLAGS="-L/usr/local/lib ${LDFLAGS}"
fi

dnl test for lib locations
if test -d /usr/lib ; then
	LDFLAGS="-L/usr/lib ${LDFLAGS}"
fi

dnl functions add to flags if found
CPPFLAGS="-I/usr/include -I/usr/local/include ${CPPFLAGS}"
LIBS="-lpthread ${LIBS}"
LDFLAGS="${LDFLAGS}"

dnl Check Python Version - ( aclocal.m4 )
AX_CHECK_PYTHON

dnl Check F2PY - ( aclocal.m4 )
AX_CHECK_F2PY

dnl Check gortran - ( aclocal.m4 )
AX_CHECK_GFORTRAN

dnl check samplerate - ( aclocal.m4 )
AX_CHECK_SAMPLERATE

dnl check portaudio - ( aclocal.m4 )
AX_CHECK_FFTW3

dnl check portaudio - ( aclocal.m4 )
AX_CHECK_PORTAUDIO

dnl set failure flag for dependency tests
FAIL="0"

dnl test Python3
dnl ----------------------------------------------------------------------------
if test "${HAS_PYTHON3A}" -eq 1; then
	AC_SUBST(PYTHON, python)

elif test "${HAS_PYTHON3B}" -eq 1; then
	AC_SUBST(PYTHON, python3)

dnl We could not find Python3
else
	pylocation="FAILED!!"	
	FAIL=1
	echo
	echo "Python v3.2+ is required to build $PACKAGE_NAME"
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: Python v3.2x"
	echo "[2] Add Python3 to your system paths"
	echo "[3] Confiure with Python3 non-standard paths:"
	echo
	echo './configure --with-python3=<Path to Python3>'
	echo 
fi

dnl test f2py
dnl ----------------------------------------------------------------------------
if test "${HAS_F2PYA}" -eq 1; then
	AC_SUBST(F2PY, f2py)

elif test "${HAS_F2PYB}" -eq 1; then
	AC_SUBST(F2PY, f2py3)

dnl We could not find F2py
else
	f2pylocation="FAILED!!"
	FAIL=1
	echo
	echo "F2PY v2.0 (Numpy 1.8.1+) is required to build $PACKAGE_NAME"
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: Python3 Numpy 1.8.1+"
	echo "[2] Add F2PY v2.0 to your system paths"
	echo "[3] Build Numpy from source & add to your system paths"
	echo "[4] Confiure with F2PY v2.0 non-standard paths:"
	echo
	echo './configure --with-f2py3=<Path to F2py v2.0'
	echo 
fi

dnl test gfortran
dnl ----------------------------------------------------------------------------
if test "${HAS_GFORTRAN}" -eq 1; then
	AC_DEFINE([HAS_GFORTRAN], [1],)
	AC_DEFINE([HAS_GFORTRAN_LIB], [1],)

dnl We could not find Gfortran
else
	FC="FAILED!!"
	FAIL=1
	echo
	echo "Gfortran is required to build $PACKAGE_NAME"
	echo
	echo "Standard locations were checked, and not found."
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: gfortran"
	echo
fi

dnl test samplerate
dnl ----------------------------------------------------------------------------
if test "$HAS_SAMPLERATE" -eq 1; then
	AC_DEFINE([HAS_SAMPLERATE], [1],)
	AC_DEFINE([HAS_SAMPLERATE_H], [1],)
	AC_DEFINE([HAS_SAMPLERATE_LIB], [1],)
	srstatus="OK"

dnl We could not find Samplerate
else
	srstatus="FAILED!!"
	FAIL=1
	echo
	echo "Samplerate-dev is required to build $PACKAGE_NAME"
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: Samplerate-dev"
	echo "[2] Build samplerate from source, install to: /usr/local"
	echo "[3] Confiure Samplerate with non-standard paths:"
	echo
	echo './configure --with-samplerate-include-dir=<Path to Samplerate Includes> \'
	echo '--with-samplerate-lib-dir=<Path to Samplerate Libs>'
	echo
fi

dnl test fftw
dnl ----------------------------------------------------------------------------
if test "${HAS_FFTW3}" -eq 1; then
	AC_DEFINE([HAS_FFTW3], [1],)
	AC_DEFINE([HAS_FFTW3_LIB], [1],)
	ffstatus="OK"

dnl We couldn't find FFTW, the libs failed
else
	ffstatus="FAILED!!"
	FAIL=1
	echo
	echo "FFTW3 Libs were not found"
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: libfftw3-dev"
	echo "[2] Build FFTW3 from source, install to: /usr/local"
	echo "[3] Confiure FFTW with non-standard paths:"
	echo
	echo './configure --with-fftw3-lib-dir=<Path to FFTW Libs>'
	echo
fi

dnl test portaudio
dnl ----------------------------------------------------------------------------
if test "${HAS_PORTAUDIO}" -eq 1; then
	AC_DEFINE([HAS_PORTAUDIO], [1],)
	AC_DEFINE([HAS_PORTAUDIO_H], [1],)
	AC_DEFINE([HAS_PORTAUDIO_LIB], [1],)
	pastatus="OK"

dnl We couldn't find Portadio, the libs failed or it's the wrong version
else
	FAIL=1
	pastatus="FAILED!!"
	echo
	echo "Portaudio-v19 was not found"
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: portaudio19-dev"
	echo "[2] Build portaudio from source, install to: /usr/local"
	echo "[3] Confiure portaudio with non-standard paths:"
	echo
	echo './configure --with-portaudio-include-dir=<Path to Portaudio Include>'
	echo '--with-portaudio-lib-dir=<Path to Portaudio Libs>'
	echo
fi

dnl Subsitutions
dnl ----------------------------------------------------------------------------

dnl check install prefix
if test "$prefix" = "NONE"; then
   prefix=$ac_default_prefix
fi

AC_SUBST(CPPFLAGS, "${CPPFLAGS}")
AC_SUBST(LDFLAGS, "${LDFLAGS}")
AC_SUBST(LIBS, "${LIBS}")
AC_SUBST(PREFIX, "${prefix}")
AC_SUBST(PROGRAM, "${PACKAGE_NAME}")
AC_SUBST(VERSION, "${PACKAGE_VERSION}")
AC_SUBST(BUGS, "${PACKAGE_BUGREPORT}")
AC_SUBST(WEB, "${PACKAGE_URL}")
AC_CONFIG_FILES(Makefile)
AC_OUTPUT

if test "${FAIL}" != 0; then
	echo
	echo "** Configure failed! Check Errors **"
	echo
fi

dnl do summary
dnl ----------------------------------------------------------------------------
echo
echo "-------------------------------------------"
echo " Configuration Summary"
echo "-------------------------------------------"
echo
echo " Package: .........: ${PROGRAM} ${VERSION}"
echo " Python3: .........: ${pylocation}"
echo " F2py v2.0: .......: ${f2pylocation}"
echo " Fcomplier: .......: ${FC}"
echo " Samplerate: ......: ${srstatus}"
echo " FFTW3: ...........: ${ffstatus}"
echo " Portaudio: .......: ${pastatus}"
echo " Install Prefix: ..: ${prefix}"
echo
echo " Website ..........: ${WEB}"
echo " Report Bugs To ...: ${BUGS}"
echo
echo "Finished creating Makefile, To build $_PROGRAM, type:"
echo
echo " make"
echo

