dnl $Id$
dnl Process this file with autoconf to produce a configure script.

dnl AC_PREREQ(2.61)

dnl This should be a svn hook instead.
dnl Sneakier way to get a Version into setup.py
AC_COPYRIGHT([$Id$])

AC_INIT([wspr],[4.0] )
fail=0

AC_CONFIG_AUX_DIR([build-aux])
AC_PREFIX_DEFAULT(/usr/local/)

dnl Checks for programs.
AC_PROG_CC
AC_LANG(C)
AC_PROG_F77

dnl Updated aclocal.m4 to find search alternative locations. Libs are only
dnl added is aclocal.m4 finds them.
CFLAGS="-Wall -O0"
CPPFLAGS="-I/usr/include -I/usr/local/include ${CPPFLAGS}"
LDFLAGS="-L/usr/lib ${LDFLAGS}"
LIBS="-lpthread ${LIBS}"
FFLAGS_GFORTRAN="${FFLAGS} -fbounds-check -fno-second-underscore -Wall -Wno-conversion -Wno-character-truncation -fPIC -m64"
FFLAGS_G95="${FFLAGS} -Wall -Wno-precision-loss -fbounds-check -fno-second-underscore -fPIC -m64"

dnl Check which fortran - macro from aclocal.m4
AX_CHECK_GFORTRAN

dnl find portaudio libs and include directories - macro from aclocal.m4
AX_CHECK_PORTAUDIO

dnl test for Darwin compilers
if test "$ac_cv_c_compiler_gnu" = yes; then
	AC_MSG_CHECKING(if $CC is Apple GCC)
	
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
AC_SUBST(OS, "${OS}")

dnl Checks for header files.
AC_HEADER_STDC
AC_HEADER_TIME

AC_CHECK_HEADERS([errno.h fcntl.h inttypes.h libgen.h stdint.h stddef.h stdio.h \
termios.h wait.h dev/ppbus/ppi.h linux/ppdev.h sys/ioctl.h sys/resource.h \
sys/resource.h sys/param.h sys/stat.h sys/syslog.h sys/time.h sys/wait.h])

AC_CHECK_HEADERS([fftw3.h], [HAS_FFTW3_H=1], [HAS_FFTW3_H=0])
AC_CHECK_HEADERS([samplerate.h], [HAS_SAMPLERATE_H=1], [HAS_SAMPLERATE_H=0])

dnl See whether we can include both string.h and strings.h.
AC_CACHE_CHECK([whether string.h and strings.h may both be included],
gcc_cv_header_string,
[
	AC_COMPILE_IFELSE(
	[#include <string.h>
	#include <strings.h>], 
	[gcc_cv_header_string=yes],
	[gcc_cv_header_string=no])
])

if test "$gcc_cv_header_string" = "yes"; then
	AC_DEFINE(STRING_WITH_STRINGS, 1, [Define to 1 if string.h may be included along with strings.h])
fi

dnl Check for stdarg.h - if we can't find it, halt configure
AC_CHECK_HEADER(stdarg.h, , [AC_MSG_ERROR([** stdarg.h could not be found - wsjt will not compile without it **])])

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

dnl test for smaplerate
if test $HAS_SAMPLERATE_H -eq 0; then
	fail=1
	echo "You need to install the samplerate library"

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
	echo "FFTW3 Libs are required by $PACKAGE_NAME $"
	echo
	echo "Check your distrobution, and install the appropriate"
	echo "libraries"
	echo

else
	AC_DEFINE(HAS_FFTW3_H, 1,)
	LIBS="${LIBS} -lfftw3f"
	fftw3stats="OK"
fi

dnl test portsudio status
if test $HAS_PORTAUDIO -eq 1; then
	AC_DEFINE(HAS_PORTAUDIO, 1,)
	AC_DEFINE(HAS_PORTAUDIO_H, 1,)
	AC_DEFINE(HAS_PORTAUDIO_LIB, 1,)
	pastatus="OK"

dnl We couldn't find portadio, the libs failed or it's the wrong version
else
	fail=1
	echo "Portaudio-v19 is required by $PACKAGE_NAME $"
	echo
	echo "Standard locations wehre checked. If you have"
	echo "Portaudio installed in a non-standard location,"
	echo "add the following to ./configure:"
	echo "--with-portaudio-include-dir=/path/to/pa"
	echo "--with-portaudio-lib-dir=/path/to/pa/libs"
	echo
	echo "The re-run ./configure"
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










