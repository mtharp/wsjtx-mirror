dnl $Id$
dnl Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_COPYRIGHT([$Id$])
AC_INIT([WSPR], [4.0], [wsjt-devel@lists.sourceforge.net])
fail=0

AC_CONFIG_AUX_DIR([build-aux])
AC_PREFIX_DEFAULT(/usr/local/)
AC_CANONICAL_HOST

dnl checks for programs.
AC_PROG_CC
AC_LANG([C])
AC_PROG_CXX
AC_PROG_INSTALL
AC_PROG_RANLIB
AC_USE_SYSTEM_EXTENSIONS

dnl test for Darwin compilers
if test "$ac_cv_c_compiler_gnu" = yes; then
	AC_MSG_CHECKING([if $CC is Apple GCC])
	
	if expr "`$CC -v 2>&1 | tail -1`" : ".*Apple" >/dev/null; then
		AppleGCC=yes
	else
		AppleGCC=no
	fi

	AC_MSG_RESULT($AppleGCC)

	CFLAGS="$CFLAGS -Wall -O0"
fi

dnl If we support -g, use it!
if test "$ac_cv_prog_cc_g" = yes; then
		CFLAGS="-Wall -O0 -g"
fi

dnl jdc -- If CFLAGS is defined, best use it everywhere...
dnl NOTE: jv says it must be added to the *END*, because things like
dnl "gcc -O9 -O2" will result in -O2 getting preference.  How stupid.
if test ! -z "$CFLAGS"; then
	CFLAGS="$CFLAGS"
fi

dnl standard m4 checkes
AC_C_INLINE
AC_PROG_GCC_TRADITIONAL
AC_PROG_MAKE_SET
AC_PROG_INSTALL
AC_PATH_PROG(RM, rm)
AC_PATH_PROG(CP, cp)
AC_PATH_PROG(MKDIR, mkdir)
AC_PATH_PROG(MV, mv)
AC_PATH_PROG(LN, ln)
AC_PATH_PROG(SED, sed)
AC_PATH_PROG(AR, ar)
AC_PATH_PROG(LD, ld)
AC_PATH_PROG(TEST, [test], [test])
AC_PATH_PROG(PYTHON, python3)
AC_PATH_PROG(F2PY, f2py3)
AC_SUBST(VERSION, "${version}")
AC_MSG_CHECKING([OS])
dnl OS=`uname`
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

AC_CHECK_HEADERS([errno.h fcntl.h fcntl.h float.h inttypes.h libgen.h limits.h \
ppdev.h ppi.h stddef.h stddef.h stdint.h stdint.h stdio.h stdlib.h string.h \
sys/ioctl.h sys/ioctl.h sys/param.h sys/param.h sys/resource.h sys/resource.h \
sys/stat.h sys/syslog.h sys/time.h sys/wait.h termios.h unistd.h wait.h])

# Checks for libraries and functions.
AC_FUNC_MALLOC
AC_CHECK_FUNCS([gettimeofday strchr])

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

dnl Check which fortran - ( aclocal.m4 )
AX_CHECK_GFORTRAN

dnl check samplerate - ( aclocal.m4 )
AX_CHECK_SAMPLERATE

dnl check portaudio - ( aclocal.m4 )
AX_CHECK_FFTW3

dnl check portaudio - ( aclocal.m4 )
AX_CHECK_PORTAUDIO

dnl added is aclocal.m4 finds them.
CFLAGS="-Wall -O0"
CPPFLAGS="-I/usr/include -I/usr/local/include ${CPPFLAGS}"
LIBS="-lpthread ${LIBS}"
LDFLAGS="${LDFLAGS}"


dnl Debug-related options
dnl =====================

AC_ARG_ENABLE(clobber,
AC_HELP_STRING([--enable-clobber], [Don't preserve old binaries on make install]),
[clobber="${enableval}"], [clobber=no])

if test "${clobber}" = yes; then
	AC_SUBST(CLOBBER, yes)
fi

AC_ARG_ENABLE(assert,
AC_HELP_STRING([--enable-assert],[Enable assert().]),
[assert=$enableval], [assert=no])

if test "${assert}" = no; then
	AC_DEFINE(NDEBUG, 1, [Define this to disable debugging support.])
fi

if test "${prefix}" = "NONE"; then 
	prefix="${ac_default_prefix}"
else

dnl remove trainling slash if present "/"
prefix=`echo ${prefix%/}`
AC_DEFINE_UNQUOTED(PREFIX, "${prefix}", [Prefix where WSPR will be installed.])
	
fi

dnl sanity tests.
dnl =============

if test -z "${FC}"; then
	fail=1
	echo "You need gfortran to compile this program!"
fi

dnl test samplerate
if test $HAS_SAMPLERATE -eq 1; then
	AC_DEFINE(HAS_SAMPLERATE, 1,)
	AC_DEFINE(HAS_SAMPLERATE_H, 1,)
	AC_DEFINE(HAS_SAMPLERATE_LIB, 1,)
	srstatus="OK"

dnl We couldn't find sample, the libs failed or it's the wrong version
else
	fail=1
	echo
	echo "Samplerate-dev is required by $PACKAGE_NAME $"
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

dnl test samplerate
if test "${HAS_FFTW3}" -eq 1; then
	AC_DEFINE(HAS_FFTW3, 1,)
	AC_DEFINE(HAS_FFTW3_LIB, 1,)
	ffstatus="OK"

dnl We couldn't find FFTW, the libs failed
else
	fail=1
	echo
	echo "FFTW3 Libs are required by $PACKAGE_NAME"
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

dnl test portsudio
if test "${HAS_PORTAUDIO}" -eq 1; then
	AC_DEFINE(HAS_PORTAUDIO, 1,)
	AC_DEFINE(HAS_PORTAUDIO_H, 1,)
	AC_DEFINE(HAS_PORTAUDIO_LIB, 1,)
	pastatus="OK"

dnl We couldn't find portadio, the libs failed or it's the wrong version
else
	fail=1
	echo
	echo "Portaudio-v19 is required by $PACKAGE_NAME $"
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

dnl This needs work, how to select python3, pyhton27 f2py or f2py3??
dnl Need m4 module to sort all this out.
dnl For now, should specify:
dnl F2PY=/path/to/f2py3
dnl or add f2py3 to svn
dnl Python Version:
dnl python -c 'import sys; print(".".join(map(str, sys.version_info[:3])))'
dnl 
if test "$F2PY" = ""; then
	echo "You are missing f2py3, trying local copy."
	F2PY="f2py3"
fi

dnl 
AC_SUBST(PREFIX, "${prefix}")
AC_SUBST(CPPFLAGS, "${CPPFLAGS}")
AC_SUBST(LDFLAGS, "${LDFLAGS}")
AC_SUBST(LIBS, "${LIBS}")
AC_SUBST(CFLAGS)
AC_SUBST(FFLAGS)
AC_CONFIG_FILES(Makefile)
AC_OUTPUT

dnl do summary
dnl
dnl If fail a pre-requisite then fail
dnl
if test "${fail}" -eq 1; then
	AC_MSG_ERROR([Please check error messages and install missing packages.])
fi

dnl do summary
echo
echo "-------------------------------------------"
echo "Configuration Summary"
echo "-------------------------------------------"
echo
echo " Package: ......... WSPR 4.0"
echo " Fcomplier: ....... ${fcname}"
echo " Samplerate: ...... ${srstatus}"
echo " FFTW3: ........... ${srstatus}"
echo " Portaudio: ....... ${pastatus}"
echo " Portaudio Libs: .. ${portaudio_lib_dir}"
echo " Portaudio Inc: ... ${portaudio_include_di}r"
echo " Install Prefix: .. ${prefix}"
echo

