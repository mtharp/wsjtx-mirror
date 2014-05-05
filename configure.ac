dnl $Id$
dnl Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_COPYRIGHT([$Id$])
AC_INIT([WSPR], [4.0], [wsjt-devel@lists.sourceforge.net])
fail=0

AC_CONFIG_AUX_DIR([build-aux])
AC_PREFIX_DEFAULT(/usr/local/)

# Checks for programs.
AC_PROG_CC
AC_LANG([C])
AC_PROG_CXX
AC_PROG_INSTALL
AC_PROG_RANLIB
AC_USE_SYSTEM_EXTENSIONS
AC_CANONICAL_HOST

dnl Updated aclocal.m4 to find search alternative locations. Libs are only
dnl added is aclocal.m4 finds them.
CFLAGS="-Wall -O0"
CPPFLAGS="-I/usr/include -I/usr/local/include ${CPPFLAGS}"
LDFLAGS="-L/usr/lib ${LDFLAGS}"
LIBS="-lpthread ${LIBS}"

dnl Check which fortran - macro from aclocal.m4
AX_CHECK_GFORTRAN

# Checks for library functions.
AC_FUNC_MALLOC
AC_CHECK_FUNCS([gettimeofday strchr])

dnl find portaudio libs and include directories - macro from aclocal.m4
AX_CHECK_PORTAUDIO

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


dnl this macro is missing or at least I can't find it.
AC_ISC_POSIX

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
OS=`uname`
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

AC_CHECK_HEADERS([samplerate.h], [HAS_SAMPLERATE_H=1], [HAS_SAMPLERATE_H=0])
AC_CHECK_LIB([samplerate], [src_simple], [HAS_SAMPLERATE_L=1], [HAS_SAMPLERATE_L=0])

AC_CHECK_HEADERS([fftw3.h], [HAS_FFTW3_H=1], [HAS_FFTW3_H=0])
AC_CHECK_LIB([fftw3f], [sfftw_destroy_plan_], [HAS_FFTW3_L=1], [HAS_FFTW3_L=0])

dnl Debug-related options
dnl =====================

AC_ARG_ENABLE(clobber,
AC_HELP_STRING([--enable-clobber], [Don't preserve old binaries on make install]),
[clobber=$enableval], [clobber=no])

if test "$clobber" = yes; then
	AC_SUBST(CLOBBER, yes)
fi

AC_ARG_ENABLE(assert,
AC_HELP_STRING([--enable-assert],[Enable assert().]),
[assert=$enableval], [assert=no])

if test "$assert" = no; then
	AC_DEFINE(NDEBUG, 1, [Define this to disable debugging support.])
fi

if test "$prefix" = "NONE"; then 
	prefix=${ac_default_prefix}
else

dnl Don't get bitten by Cygwin's stupidity if the user specified
dnl a custom prefix with a trailing slash

	prefix=`echo $prefix | sed 's/\/$//'`
	AC_DEFINE_UNQUOTED(PREFIX, "$prefix", [Prefix where wsjt is installed.])
	
fi

dnl sanity tests.
dnl =============

if test -z $FC ; then
	fail=1
	echo "You need g95 or gfortran to compile this program!"
fi

dnl test smaplerate
if test $HAS_SAMPLERATE_H -eq 0; then
	echo 
	echo "Samplerate Headers are required by $PACKAGE_NAME $"
	echo
	echo "Check your distribution, and install the appropriate"
	echo "development packkage"
	echo
elif test $HAS_SAMPLERATE_L -eq 0; then
	fail=1
	echo "Samplerate Libs are required by $PACKAGE_NAME $"
	echo
	echo "Check your distribution, and install the appropriate"
	echo "development libraries"
	echo
dnl add to ${LIBS}
else
	AC_DEFINE(HAS_SAMPLERATE_H, 1, )
	LIBS="${LIBS} -lsamplerate"
	sampleratestatus="OK"
fi

dnl test fftw3
if test $HAS_FFTW3_H -eq 0; then
	fail=1
	echo 
	echo "FFTW3 Headers are required by $PACKAGE_NAME $"
	echo
	echo "Check your distribution, and install the appropriate"
	echo "development package"
	echo

elif test $HAS_FFTW3_L -eq 0; then
	fail=1
	echo "FFTW3 Single Libs are required by $PACKAGE_NAME $"
	echo
	echo "Check your distribution, and install the appropriate"
	echo "libraries"
	echo
else
	AC_DEFINE([HAS_FFTW3_L], 1,)
	AC_DEFINE([HAS_FFTW3_H], 1,)
	LIBS="${LIBS} -lfftw3f"
	fftw3stats="OK"
fi

dnl test portsudio
if test $HAS_PORTAUDIO -eq "1"; then
	AC_DEFINE(HAS_PORTAUDIO, 1,)
	AC_DEFINE(HAS_PORTAUDIO_H, 1,)
	AC_DEFINE(HAS_PORTAUDIO_LIB, 1,)
	pastatus="OK"

dnl We couldn't find portadio, the libs failed or it's the wrong version
else
	fail=1
	echo "Portaudio-v19 is required by $PACKAGE_NAME $"
	echo
	echo "Standard locations were checked. If you have"
	echo "Portaudio installed in a non-standard location,"
	echo "add the following to ./configure:"
	echo "--with-portaudio-include-dir=/path/to/pa"
	echo "--with-portaudio-lib-dir=/path/to/pa/libs"
	echo
	echo "Then re-run ./configure"
	echo
fi

dnl This needs work, how to select python3, pyhton27 f2py or f2py3??
dnl Need m4 module to sort all this out.
dnl For now, should specify:
dnl F2PY=/path/to/f2py3
dnl or add f2py3 to svn
if test "$F2PY" = ""; then
	echo "You are missing f2py, trying local copy."
	F2PY="f2py";	
fi

dnl
dnl If fail a pre-requisite then fail
dnl
if test $fail -eq 1; then
	AC_MSG_ERROR([Please check error messages and install missing packages.])
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
if test $fail -eq 1; then
	AC_MSG_ERROR([Please check error messages and install missing packages.])
fi

dnl do summary
echo
echo "-------------------------------------------"
echo "Configuration Summary"
echo "-------------------------------------------"
echo
echo "Package: ......... WSPR 4.0"
echo "Fcomplier: ....... $fcname";
echo "Samplerate: ...... $sampleratestatus"
echo "FFTW3: ........... $fftw3stats"
echo "Portaudio: ....... $pastatus"
echo "Portaudio Libs: .. $portaudio_lib_dir"
echo "Portaudio Inc: ... $portaudio_include_dir"
echo "Install Prefix: .. $prefix"
echo

