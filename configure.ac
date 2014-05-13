dnl $Id$
dnl Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_COPYRIGHT([$Id$])
AC_INIT([WSPR], [4.0], [wsjt-devel@lists.sourceforge.net])
AC_CONFIG_AUX_DIR([build-aux])
AC_PREFIX_DEFAULT([$HOME/wspr])
AC_CANONICAL_HOST
_VER="4.0"
_PROG="WSPR"
FAIL="0"

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
AC_SUBST(VERSION, "${version}")
AC_MSG_CHECKING([OS])
AC_SUBST(OS, "${host_os}")


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
if test -d /usr/local/lib ; then
	LDFLAGS="-L/usr/local/lib ${LDFLAGS}"
fi

dnl test for lib locations
if test -d /lib ; then
		LDFLAGS="-L/lib ${LDFLAGS}"
fi

dnl test for lib locations
if test -d /usr/lib ; then
	LDFLAGS="-L/usr/lib ${LDFLAGS}"
fi

dnl added if aclocal.m4 finds them.
CPPFLAGS="-I/usr/include -I/usr/local/include ${CPPFLAGS}"
LIBS="${LIBS}"
LDFLAGS="${LDFLAGS} -lpthread"

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

dnl test python3
dnl ----------------------------------------------------------------------------
if test "${HAS_PYTHON3A}" -eq 1; then
	AC_SUBST(PYTHON, python)

elif test "${HAS_PYTHON3B}" -eq 1; then
	AC_SUBST(PYTHON, python3)

dnl We could not find Python3
else
	FAIL=1
	echo
	echo "Python v3.2+ is required to build $PACKAGE_NAME"
	echo
	echo "Standard locations were checked, and not found."
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: Python v3.2x"
	echo "[2] Add Python3 to your system paths"
	echo "[3] Confiure with Python3 non-standard paths:"
	echo
	echo './configure --with-python3=/path/to/samplerate.h'
	echo 
fi

dnl test f2py v2.0
dnl ----------------------------------------------------------------------------
if test "${HAS_F2PYA}" -eq 1; then
	AC_SUBST(F2PY, f2py)

elif test "${HAS_F2PYB}" -eq 1; then
	AC_SUBST(F2PY, f2py3)

dnl We could not find f2py
else
	FAIL=1
	echo
	echo "F2PY v2.0 (Numpy 1.8.1+) is required to build $PACKAGE_NAME"
	echo
	echo "Standard locations were checked, and not found."
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: Python3 Numpy 1.8.1+"
	echo "[2] Add F2PY v2.0 to your system paths"
	echo "[3] Build Numpy from source & add to your system paths"
	echo "[4] Confiure with F2PY v2.0 non-standard paths:"
	echo
	echo './configure --with-f2py3=/path/to/f2py3'
	echo 
fi


dnl test gfortran
dnl ----------------------------------------------------------------------------
if test "${HAS_GFORTRAN}" -eq 1; then
	AC_DEFINE([HAS_GFORTRAN], [1],)
	AC_DEFINE([HAS_GFORTRAN_LIB], [1],)

dnl We could not find Gfortran
else
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

dnl We could not find Samplerate, the libs failed or it's the wrong version
else
	FAIL=1
	echo
	echo "Samplerate-dev is required to build $PACKAGE_NAME"
	echo
	echo "Standard locations were checked, and not found."
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: samplerate-dev"
	echo "[2] Build samplerate from source, install to: /usr/local"
	echo "[3] Confiure with samplerate with non-standard paths:"
	echo
	echo './configure --with-samplerate-include-dir=/path/to/samplerate.h \'
	echo '--with-samplerate-lib-dir=/path/to/pa/libsamplerate.so'
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
	FAIL=1
	echo
	echo "FFTW3 Libs are required to build $PACKAGE_NAME"
	echo
	echo "Standard locations were checked, and not found."
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: libfftw3-dev"
	echo "[2] Build FFTW3 from source, install to: /usr/local"
	echo "[3] Confiure with FFTW with non-standard paths:"
	echo
	echo './configure --with-fftw3-lib-dir=/path/to/pa/libfftw3f.so'
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
	echo
	echo "Portaudio-v19 is required to build $PACKAGE_NAME"
	echo
	echo "Standard locations were checked, and not found."
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: portaudio19-dev"
	echo "[2] Build portaudio from source, install to: /usr/local"
	echo "[3] Confiure with portaudio non-standard paths:"
	echo
	echo './configure --with-portaudio-include-dir=/path/to/portaudio.h \'
	echo '--with-portaudio-lib-dir=/path/to/pa/libportaudio.so'
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
AC_SUBST(VERSION, "${_VER}")
AC_SUBST(PROGRAM, "${_PROG}")
AC_CONFIG_FILES(Makefile)
AC_OUTPUT

dnl do summary
dnl ----------------------------------------------------------------------------
echo
echo "-------------------------------------------"
echo " Configuration Summary"
echo "-------------------------------------------"
echo
if test "${FAIL}" != 0; then
echo "** Check ERRORS before running: make **"
echo
fi
echo " Package: ......... ${PROGRAM} ${VERSION}"
echo " Python3: ......... ${pylocation}"
echo " F2py v2.0: ....... ${f2pylocation}"
echo " Fcomplier: ....... ${FC}"
echo " Samplerate: ...... ${srstatus}"
echo " FFTW3: ........... ${ffstatus}"
echo " Portaudio: ....... ${pastatus}"
echo " Install Prefix: .. ${prefix}"
echo
