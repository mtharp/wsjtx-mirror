dnl $Id$
dnl Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_COPYRIGHT([$Id$])
AC_INIT([WSPR], [4.0], [wsjt-devel@lists.sourceforge.net],[],
[http://www.physics.princeton.edu/pulsar/K1JT/wspr.html])

AC_CONFIG_AUX_DIR([build-aux])
AC_PREFIX_DEFAULT([$HOME/wspr])
AC_CANONICAL_HOST

dnl ----------------------------------------------------------------------------
dnl check compiler programs
dnl ----------------------------------------------------------------------------
OCFLAGS="$CFLAGS"
AC_PROG_CC
AC_PROG_CXX
AC_PROG_FC
AC_PROG_GCC_TRADITIONAL
AC_PROG_MAKE_SET
AC_PROG_RANLIB
AC_PROG_MAKE_SET
AC_USE_SYSTEM_EXTENSIONS
CFLAGS="$OCFLAGS"

dnl ----------------------------------------------------------------------------
dnl check standard apps
dnl ----------------------------------------------------------------------------
AC_C_INLINE
AC_PATH_PROG([AR], [ar])
AC_PATH_PROG([AWK], [awk])
AC_PATH_PROG([CP], [cp])
AC_PATH_PROG([CR], [cr])
AC_PATH_PROG([LD], [ld])
AC_PATH_PROG([LN], [ln])
AC_PATH_PROG([MKDIR], [mkdir])
AC_PATH_PROG([MV], [mv])
AC_PATH_PROG([RANLIB], [ranlib])
AC_PATH_PROG([RM], [rm])
AC_PATH_PROG([SED], [sed])
AC_PATH_PROG([SHELL], [bash])
AC_PATH_PROG([SORT], [sort])
AC_PATH_PROG([TR], [tr])
AC_SUBST([OS], ["$host_os"])
AC_SUBST([CPU], ["$host_cpu"])

dnl ----------------------------------------------------------------------------
dnl check headers
dnl ----------------------------------------------------------------------------
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
limits.h linux/ppdev.h dev/ppbus/ppi.h linux/parport.h pthread.h portaudio.h \
samplerate.h stddef.h stdint.h stdint.h stdio.h stdlib.h string.h strings.h \
sys/ioctl.h sys/ioctl.h sys/param.h sys/resource.h sys/stat.h sys/syslog.h \
sys/time.h sys/wait.h termios.h unistd.h wait.h])


dnl ----------------------------------------------------------------------------
dnl add additional lib paths
dnl ----------------------------------------------------------------------------
if test -d "/usr/lib64"; then LDFLAGS="-L/usr/lib64 ${LDFLAGS}"; fi
if test -d "/usr/local/lib"; then LDFLAGS="-L/usr/local/lib ${LDFLAGS}"; fi
if test -d "/usr/lib/x86_64-linux-gnu"; then LDFLAGS="-L/usr/lib/x86_64-linux-gnu ${LDFLAGS}"; fi
if test -d "/usr/lib/i386-linux-gnu"; then LDFLAGS="-L/usr/lib/i386-linux-gnu ${LDFLAGS}"; fi
if test -d "/usr/lib"; then LDFLAGS="-L/usr/lib ${LDFLAGS}"; fi


dnl ----------------------------------------------------------------------------
dnl find Python3
dnl ----------------------------------------------------------------------------

HAVE_PY3=no

# check with-enable first
AC_MSG_CHECKING([Python3 --with-python3])
AC_ARG_WITH([f2py], [  --with-python3=PATH     path to: ../python3],
PY3="$withval")

# if --with-python3 is not empty
if test -n "$PY3"; then

# check if user provided python3 is >= 3.2
python3 -c "import sys; sys.exit(sys.version < '3.2')" >/dev/null 2>&1
	
	if test "$?" != "0"; then
		HAVE_PY3=no
		AC_MSG_RESULT([no])
	else
		HAVE_PY3=yes
		PY3_PATH="$PY3"
		PY3V=`$PY3 -V`
		AC_DEFINE([HAVE_PY3], [1])
		AC_DEFINE_UNQUOTED([PY3_PATH], ["${PY3}"], [Path to Python3])
		AC_SUBST([PYTHON], ["${PY3}"])
		AC_MSG_RESULT([yes ${PY3V}])
	fi
else
	AC_MSG_RESULT([no])
fi

# if not user supplied, check by calling python
if test "$HAVE_PY3" = "no"; then

	AC_MSG_CHECKING([Python3 using: python])
	python -c "import sys; sys.exit(sys.version < '3.2')" >/dev/null 2>&1

	if test "$?" != 0; then
		AC_MSG_RESULT([no])
		HAVE_PY3=no
	else
		HAVE_PY3=yes
		PY3_PATH=`which python`
		PY3V=`"$PY3_PATH" -V`
		AC_DEFINE([HAVE_PY3], [1])
		AC_DEFINE_UNQUOTED([PY3_PATH], ["${PY3_PATH}"], [Path to Python3])
		AC_SUBST([PYTHON], ["${PY3_PATH}"])
		AC_MSG_RESULT([yes ${PY3V}])
	fi
fi

# if not user supplied && not from calling python, check by calling python3
if test "$HAVE_PY3" = "no"; then
	AC_MSG_CHECKING([Python3 using: python3])
	python3 -c "import sys; sys.exit(sys.version < '3.2')" >/dev/null 2>&1

	if test "$?" != 0; then
		AC_MSG_RESULT([no])
		HAVE_PY3=no
	else
		HAVE_PY3=yes
		PY3_PATH=`which python3`
		PY3V=`"$PY3_PATH" -V`
		AC_DEFINE([HAVE_PY3], [1])
		AC_DEFINE_UNQUOTED([PY3_PATH], ["${PY3_PATH}"], [Path to Python3])
		AC_SUBST([PYTHON], ["${PY3_PATH}"])
		AC_MSG_RESULT([yes ${PY3V}])
	fi
fi

dnl ----------------------------------------------------------------------------
dnl find that pesky f2py program
dnl ----------------------------------------------------------------------------

HAVE_F2PY=no

# check with-enable first
AC_MSG_CHECKING([F2PY --with-f2py])
AC_ARG_WITH([f2py], [  --with-f2py=PATH        path to: ../f2py ../f2py3],
F2PY="$withval")

# if --with-f2py is not empty
if test -n "$F2PY"; then

# check if user provided location works
$F2PY -v >/dev/null 2>&1
	
	if test "$?" != "0"; then
		HAVE_F2PY=no
		AC_MSG_RESULT([no])
	else
		HAVE_F2PY=yes
		F2PY_PATH="$F2PY"
		F2PYV=`$F2PY -v`
		AC_DEFINE([HAVE_F2PY], [1])
		AC_DEFINE_UNQUOTED([F2PY_PATH], ["${F2PY}"], [Path to F2PY])
		AC_SUBST([F2PY], ["${F2PY}"])
		AC_MSG_RESULT([yes v${F2PYV}])
	fi
else
	AC_MSG_RESULT([no])
fi

# if not user supplied, check by calling f2py
if test "$HAVE_F2PY" = "no"; then

	AC_MSG_CHECKING([F2PY using: f2py])
	f2py -v  >/dev/null 2>&1

	# Check if f2py3 is called using "f2py"
	if test "$?" != "0"; then
		AC_MSG_RESULT([no])
		HAVE_F2PY=no
	else
		HAVE_F2PY=yes
		F2PY=`which f2py`
		F2PYV=`$F2PY -v`
		AC_DEFINE([HAVE_F2PY], [1])
		AC_DEFINE_UNQUOTED([F2PY], ["${F2PY}"], [Path to F2PY])
		AC_SUBST([F2PY], ["${F2PY}"])
		AC_MSG_RESULT([yes])
		AC_MSG_RESULT([yes v${F2PYV}])
	fi
fi

# if not user supplied, or by calling f2py, try f2py3
if test "$HAVE_F2PY" = "no"; then
	AC_MSG_CHECKING([F2PY using: f2py3])
	f2py3 -v | head -c 1 >/dev/null 2>&1

	if test "$?" != "0"; then
		AC_MSG_RESULT([no])
		HAVE_F2PY=no
	else
		HAVE_F2PY=yes
		F2PY=`which f2py3`
		F2PYV=`$F2PY -v`
		AC_DEFINE([HAVE_F2PY], [1])
		AC_DEFINE_UNQUOTED([F2PY], ["${F2PY}"], [Path to F2PY])
		AC_SUBST([F2PY], ["${F2PY}"])
		AC_MSG_RESULT([yes v${F2PYV}])
	fi
fi


dnl ----------------------------------------------------------------------------
dnl check gfortran basic funciton
dnl ----------------------------------------------------------------------------

AC_CHECK_LIB([gfortran], [_gfortran_st_write], [], [])

if test "$ac_cv_lib_gfortran__gfortran_st_write" != "yes"; then
	HAVE_GFORTRAN=0
else
	HAVE_GFORTRAN=1
	FC=gfortran
	FCV=gnu95
	FC_LIB_PATH=`${FC} -print-file-name=`
	AC_DEFINE_UNQUOTED([FC_LIB_PATH], ["${FC_LIB_PATH}"], [Path to Gfortran libs.])
	AC_SUBST([FC_LIB_PATH], ["${FC_LIB_PATH}"])
	AC_DEFINE_UNQUOTED([FC], ["${FC}"], [Gfortran Compiler])
	AC_SUBST([FC], ["${FC}"])
	AC_SUBST([FCV], ["${FCV}"])
fi


dnl ----------------------------------------------------------------------------
dnl check portaudio
dnl ----------------------------------------------------------------------------

AC_CHECK_LIB([portaudio], [Pa_Initialize], [], [])
if test "$ac_cv_lib_portaudio_Pa_Initialize" = "yes"; then
		LIBS="-lportaudio ${LIBS}"
fi

# if header and libs found, set HAVE_PORTAUDIO
if test "$ac_cv_header_portaudio_h" = "yes" -a "$ac_cv_lib_portaudio_Pa_Initialize" = "yes"; then
	HAVE_PORTAUDIO=1
	AC_DEFINE([HAVE_PORTAUDIO_H], [1], [Portaudio Header])
	AC_DEFINE([HAVE_PORTAUDIO_LIB], [1], [Portaudio Lib])
fi


dnl ----------------------------------------------------------------------------
dnl check fftw3
dnl ----------------------------------------------------------------------------

AC_CHECK_LIB([fftw3f], [sfftw_destroy_plan_], [], [])

if test "$ac_cv_lib_fftw3f_sfftw_destroy_plan_" = "yes"; then
	LIBS="-lfftw3f ${LIBS}"
fi

# if headers and libs found, set defines
if test "$ac_cv_lib_fftw3f_sfftw_destroy_plan_" = "yes"; then
	HAVE_FFTW3_LIB=1
	AC_DEFINE([HAVE_FFTW3_LIB], [1], [FFTW3 Libs])
fi


dnl ----------------------------------------------------------------------------
dnl check samplerate
dnl ----------------------------------------------------------------------------

AC_CHECK_LIB([samplerate], [src_simple], [], [])

if test "$ac_cv_lib_samplerate_src_simple" = "yes"; then
	LIBS="-lsamplerate ${LIBS}"
fi

# if headers and libs found, set define
if test "$ac_cv_header_samplerate_h" = "yes" -a "$ac_cv_lib_samplerate_src_simple" = "yes"; then
	HAVE_SAMPLERATE=1
	AC_DEFINE([HAVE_SAMPLERATE_H], [1], [Samplerate Header])
	AC_DEFINE([HAVE_SAMPLERATE_LIB], [1], [Samplerate Lib])
fi


dnl ----------------------------------------------------------------------------
dnl cosolidate flags - (remove dupes if any)
dnl ----------------------------------------------------------------------------

_LBU=$(echo "-lpthread $LIBS" |tr ' ' '\n'| sort -su |tr '\n' ' ')
LIBS="$_LBU"

_LDU=$(echo "$LDFLAGS" |tr ' ' '\n'| sort -su |tr '\n' ' ')
LDFLAGS="$_LDU"

_CPPU=$(echo "-I/usr/include -I/usr/local/include $CPPFLAGS" |tr ' ' '\n'| sort -su |tr '\n' ' ')
CPPFLAGS="$_CPPU"

# OS specfic flags
if test "${host_os}" = *darwin* ; then
	CFLAGS="-Wall -O0 -fPIC -m64"
	FFLAGS="-O2 -Wall -fbounds-check -fno-second-underscore \
-Wno-conversion -Wno-character-truncation -fPIC -m64"
	FCOPT="-cpp -fbounds-check -O2"
else
	CFLAGS="-fPIC"
	FFLAGS="-O2 -Wall -fbounds-check -fno-second-underscore \
-Wno-conversion -Wno-character-truncation -fPIC"
	FCOPT="-cpp -fbounds-check -O2"
fi


dnl ----------------------------------------------------------------------------
dnl report Python
dnl ----------------------------------------------------------------------------

if test "$HAVE_PY3" = "no"; then
	pylocation="FAILED!!"	
	FAIL=yes
	echo
	echo "Python v3.2+ is required to build $PACKAGE_NAME"
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: Python v3.2+"
	echo "[2] Add Python3.2+ to your system paths"
	echo "[3] Include Python3.2+:"
	echo
	echo './configure --with-python3="/home/$USER/test/python3"'
fi


dnl ----------------------------------------------------------------------------
dnl report f2py
dnl ----------------------------------------------------------------------------

if test "$HAVE_F2PY" = "no"; then
	f2pylocation="FAILED!!"
	FAIL=yes
	echo
	echo "F2PY v2.0 (Numpy 1.8.1+) is required to build $PACKAGE_NAME"
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: Python3 Numpy 1.8.1+"
	echo "[2] Add F2PY v2.0 to your system paths"
	echo "[3] Include F2PY:"
	echo
	echo './configure --with-f2py="/home/$USER/test/f2py"'
	echo 
fi

dnl ----------------------------------------------------------------------------
dnl report gfortran
dnl ----------------------------------------------------------------------------

if test ${HAVE_GFORTRAN} -eq 1; then
	AC_DEFINE([HAVE_GFORTRAN], [1],)
	AC_DEFINE([HAVE_GFORTRAN_LIB], [1],)

# if we could not find Gfortran
else
	FC="FAILED!!"
	FAIL=yes
	echo
	echo "Gfortran is required to build $PACKAGE_NAME"
	echo
	echo "Standard locations were checked, and not found."
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: gfortran"
	echo
fi


dnl ----------------------------------------------------------------------------
dnl report samplerate
dnl ----------------------------------------------------------------------------

if test "$HAVE_SAMPLERATE" = "1"; then
	srstatus="OK"
else
	FAIL=yes
	srstatus="FAILED!!"
	echo
	echo "Samplerate-dev is required to build $PACKAGE_NAME"
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: Samplerate-dev"
	echo "[2] Confiure Samplerate with non-standard paths:"
	echo
	echo './configure CPPFLAGS="-I/home/$USER/test/samplerate/include"'
	echo 'LDFLAGS="-L/home/$USER/test/samplerate/lib"'
	echo
fi

dnl ----------------------------------------------------------------------------
dnl report fftw
dnl ----------------------------------------------------------------------------

if test "$HAVE_FFTW3_LIB" = "1"; then
	ffstatus="OK"
else
	ffstatus="FAILED!!"
	FAIL=yes
	echo
	echo "FFTW3 Libs were not found"
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: libfftw3-dev"
	echo "[2] Confiure FFTW with non-standard paths:"
	echo
	echo './configure LDFLAGS="-L/home/$USER/test/fftw3/lib"'
	echo
fi


dnl ----------------------------------------------------------------------------
dnl report portaudio
dnl ----------------------------------------------------------------------------

if test "$HAVE_PORTAUDIO" = "1"; then
	pastatus="OK"
else
	FAIL=yes
	pastatus="FAILED"
	echo
	echo "Portaudio-v19 was not found"
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: portaudio19-dev"
	echo "[2] Confiure portaudio with non-standard paths:"
	echo
	echo './configure CPPFLAGS="-I/home/$USER/test/portaudio/include"'
	echo 'LDFLAGS="-L/home/$USER/test/portaudio/lib"'
	echo
fi


dnl ----------------------------------------------------------------------------
dnl substitutions
dnl ----------------------------------------------------------------------------

if test "$prefix" = "NONE"; then
   prefix=$ac_default_prefix
fi

AC_SUBST([BUGS], ["$PACKAGE_BUGREPORT"])
AC_SUBST([CFLAGS], ["$CFLAGS"])
AC_SUBST([CPPFLAGS], ["$CPPFLAGS"])
AC_SUBST([FCOPT], ["$FCOPT"])
AC_SUBST([FFLAGS], ["$FFLAGS"])
AC_SUBST([LDFLAGS], ["$LDFLAGS"])
AC_SUBST([LIBS], ["$LIBS"])
AC_SUBST([PREFIX], ["$prefix"])
AC_SUBST([PROGRAM], ["$PACKAGE_NAME"])
AC_SUBST([VERSION], ["$PACKAGE_VERSION"])
AC_SUBST([WEB], ["$PACKAGE_URL"])
AC_CONFIG_FILES([Makefile])
AC_OUTPUT


dnl ----------------------------------------------------------------------------
dnl configure summary
dnl ----------------------------------------------------------------------------

echo
echo "-------------------------------------------"
echo " Configuration Summary"
echo "-------------------------------------------"
echo
if test "$FAIL" = "yes"; then
	echo
	echo "** Configure Warning, Check Errors **"
	echo
fi
echo " Package: .........: ${PROGRAM} ${VERSION}"
echo " Python3: .........: ${PYTHON}"
echo " F2py: ............: ${F2PY}"
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
