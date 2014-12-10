dnl $Id$
dnl Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_COPYRIGHT([$Id$])
AC_INIT([WSPR], [4.0], [wsjt-devel@lists.sourceforge.net],[],
[http://www.physics.princeton.edu/pulsar/K1JT/wspr.html])

# ------------------------------------------------------------------------------
#  path vars
# ------------------------------------------------------------------------------
AC_CONFIG_AUX_DIR([build-aux])
AC_CANONICAL_HOST
AC_CANONICAL_BUILD

dnl enable configurable prefix path
AC_PREFIX_DEFAULT("/usr")
if test "$prefix" = "NONE"; then 
	prefix=${ac_default_prefix}
fi

# ------------------------------------------------------------------------------
#  user input paths
# ------------------------------------------------------------------------------
DOCDIR="$prefix"/share/doc/wspr
MANDIR="$prefix"/share/man/man1

AC_ARG_WITH([docdir],
AC_HELP_STRING([--with-docdir=PATH], [path to documentuments]), [docdir=$with_docdir])
if test -n "$with_docdir"; then
	AC_SUBST([DOCDIR], ["$with_docdir"])
fi

AC_ARG_WITH([mandir],
AC_HELP_STRING([--with-mandir=PATH], [path to manpages]), [mandir=$with_mandir])
if test -n "$with_mandir"; then
	AC_SUBST([MANDIR], ["$with_mandir"])
fi

# ------------------------------------------------------------------------------
#  check compilers
# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
# check standard apps
# ------------------------------------------------------------------------------
AC_C_INLINE
AC_PATH_PROG([AR], [ar])
AC_PATH_PROG([AWK], [awk])
AC_PATH_PROG([CP], [cp])
AC_PATH_PROG([CHOWN], [chown])
AC_PATH_PROG([CHMOD], [chmod])
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

# ------------------------------------------------------------------------------
#  check headers
# ------------------------------------------------------------------------------
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


# ------------------------------------------------------------------------------
#  add additional lib paths
# ----------------------------------------------------------------------------
if test -d "/usr/lib64"; then LIBDIR="-L/usr/lib64 ${LIBDIR}"; fi
if test -d "/usr/local/lib"; then LIBDIR="-L/usr/local/lib ${LIBDIR}"; fi
if test -d "/usr/lib/x86_64-linux-gnu"; then LIBDIR="-L/usr/lib/x86_64-linux-gnu ${LIBDIR}"; fi
if test -d "/usr/lib/i386-linux-gnu"; then LIBDIR="-L/usr/lib/i386-linux-gnu ${LIBDIR}"; fi
if test -d "/usr/lib"; then LIBDIR="-L/usr/lib ${LIBDIR}"; fi
if test -d "/usr/lib/arm-linux-gnueabihf"; then LIBDIR="-L/usr/lib/arm-linux-gnueabihf ${LIBDIR}"; fi

# ------------------------------------------------------------------------------
#  find Python3
# ------------------------------------------------------------------------------

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

# ------------------------------------------------------------------------------
#  find f2py
# ------------------------------------------------------------------------------

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

# ------------------------------------------------------------------------------
#  check gfortran
# ------------------------------------------------------------------------------

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
	AC_DEFINE([HAVE_GFORTRAN], [1],)
	AC_DEFINE([HAVE_GFORTRAN_LIB], [1],)
fi

# ------------------------------------------------------------------------------
#  check portaudio
# ------------------------------------------------------------------------------

AC_CHECK_LIB([portaudio], [Pa_Initialize], [], [])
if test "$ac_cv_lib_portaudio_Pa_Initialize" = "yes"; then
		LIBS="-lportaudio ${LIBS}"
fi

# if headers and libs found, set define
if test "$ac_cv_header_portaudio_h" = "yes" -a "$ac_cv_lib_portaudio_Pa_Initialize" = "yes"; then
	HAVE_PORTAUDIO=1
	AC_DEFINE([HAVE_PORTAUDIO_H], [1], [Portaudio Header])
	AC_DEFINE([HAVE_PORTAUDIO_LIB], [1], [Portaudio Lib])
fi


# ------------------------------------------------------------------------------
#  check fftw3
# ------------------------------------------------------------------------------

AC_CHECK_LIB([fftw3f], [sfftw_destroy_plan_], [], [])

if test "$ac_cv_lib_fftw3f_sfftw_destroy_plan_" = "yes"; then
	LIBS="-lfftw3f ${LIBS}"
fi

# if headers and libs found, set defines
if test "$ac_cv_lib_fftw3f_sfftw_destroy_plan_" = "yes"; then
	HAVE_FFTW3_LIB=1
	AC_DEFINE([HAVE_FFTW3_LIB], [1], [FFTW3 Libs])
fi


# ------------------------------------------------------------------------------
#  check samplerate
# ------------------------------------------------------------------------------

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

# ------------------------------------------------------------------------------
#  consolidate flags - ( remove dupes and sort )
# ------------------------------------------------------------------------------

_LBU=$(echo "-lpthread $LIBS" |tr ' ' '\n'|sort -su |tr '\n' ' ')
LIBS="$_LBU"

_LDU=$(echo "$LIBDIR" |tr ' ' '\n'|sort -su |tr '\n' ' ')
LIBDIR="$_LDU"

_CPPU=$(echo "-I/usr/include -I/usr/local/include $CPPFLAGS" |tr ' ' '\n'|sort -su |tr '\n' ' ')
CPPFLAGS="$_CPPU"

case "${host_os}" in
	*linux* )
		FCOPT="-cpp -fbounds-check -O2"
			case "${host_cpu}" in
				*armv6* )
					CFLAGS="-O2 -march=armv6j -mfpu=vfp -mfloat-abi=hard -fpic"
					FFLAGS="-O2 -Wall -fno-range-check -ffixed-line-length-none \
-Wno-character-truncation -Wno-conversion -Wtabs -mfloat-abi=hard -fPIC"
					LDFLAGS="-Wl,-O1 -Wl,--as-needed"						
				;;
				*armv7* )
					CFLAGS="-fpic"
					FFLAGS="-O2 -Wall -fbounds-check -fno-second-underscore \
-Wno-conversion -Wno-character-truncation -fPIC"
					LDFLAGS=""						
				;;
				*x86_64* )
					CFLAGS="-fPIC"
					FFLAGS="-O2 -Wall -fbounds-check -fno-second-underscore \
-Wno-conversion -Wno-character-truncation -fPIC"
					LDFLAGS="-Wl,-O1 -Wl,--as-needed"
				;;
				*i386* )
					CFLAGS="-fPIC"
					FFLAGS="-O2 -Wall -fbounds-check -fno-second-underscore \
-Wno-conversion -Wno-character-truncation -fPIC"
					LDFLAGS="-Wl,-O1 -Wl,--as-needed"
				;;
			esac
	;;
	*-*-darwin-* )
		FCOPT="-cpp -fbounds-check -O2"
		CFLAGS="-Wall -O0 -fPIC -m64"
		FFLAGS="-O2 -m64 -Wall -fbounds-check -fno-second-underscore \
-Wno-conversion -Wno-character-truncation -fPIC"
		LDFLAGS="-Wl,-O1 -Wl,--as-needed"
	;;
	*)
		AC_MSG_ERROR([Unsupported System: ${host_os}.])
	;;
esac

# ------------------------------------------------------------------------------
#  report Python
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
	echo './configure --with-python3="/home/$USER/test/python3"'
	echo
	exit 1
else
	# add python3 path to wspr.sh script
	sed -i '/wspr.py/d' wspr.sh
	echo "$PY3_PATH -O wspr.py" >> wspr.sh
fi

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
	echo './configure --with-f2py="/home/$USER/test/f2py"'
	echo 
	exit 1
fi

# ------------------------------------------------------------------------------
#  report gfortran
# ------------------------------------------------------------------------------

if test ${HAVE_GFORTRAN} -eq 0; then
	echo
	echo "CONFIGURATION ERROR"
	echo
	echo "Gfortran is required to build $PACKAGE_NAME"
	echo
	echo "Standard locations were checked, and not found."
	echo
	echo "Possible Solutions:"
	echo "[1] Install your distro version of: gfortran"
	echo "[2] On x86_64 systems, ensure you include x86 / i386 libgfortran"
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
	echo './configure CPPFLAGS="-I/home/$USER/test/samplerate/include" \'
	echo 'LIBDIR="/home/$USER/test/samplerate/lib"'
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
	echo './configure LIBDIR="/home/$USER/test/fftw3/lib"'
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
	echo './configure CPPFLAGS="-I/home/$USER/test/portaudio/include" \'
	echo 'LIBDIR="/home/$USER/test/portaudio/lib"'
	echo
	exit 1
fi

# ------------------------------------------------------------------------------
#  substitutions
# ------------------------------------------------------------------------------

AC_SUBST([PREFIX], ["$prefix"])
AC_SUBST([BUGS], ["$PACKAGE_BUGREPORT"])
AC_SUBST([PROGRAM], ["$PACKAGE_NAME"])
AC_SUBST([VERSION], ["$PACKAGE_VERSION"])
AC_SUBST([WEB], ["$PACKAGE_URL"])
AC_SUBST([CFLAGS], ["$CFLAGS"])
AC_SUBST([CPPFLAGS], ["$CPPFLAGS"])
AC_SUBST([FFLAGS], ["$FFLAGS"])
AC_SUBST([LDFLAGS], ["$LDFLAGS"])
AC_SUBST([FCOPT], ["$FCOPT"])
AC_SUBST([LIBDIR], ["$LIBDIR"])
AC_SUBST([SHARED], ["$PREFIX"/share/wspr])
AC_SUBST([WSPRLIB], ["$PREFIX"/lib/wspr])
AC_SUBST([BINDIR], ["$PREFIX"/bin])
AC_SUBST([LIBS], ["$LIBS"])
AC_SUBST([HOMEDIR], [/home/"$USER"/.wspr])
AC_SUBST([USER], ["$USER"])
AC_CONFIG_FILES([Makefile])
AC_OUTPUT

# ------------------------------------------------------------------------------
#  configure summary
# ------------------------------------------------------------------------------

echo
echo "-------------------------------------------"
echo " Configuration Summary"
echo "-------------------------------------------"
echo
echo " Package: .........: ${PROGRAM} ${VERSION}"
echo " Python3: .........: ${PYTHON}"
echo " F2py: ............: ${F2PY}"
echo " Fcomplier: .......: ${FC}"
echo " Samplerate: ......: ${srstatus}"
echo " FFTW3: ...........: ${ffstatus}"
echo " Portaudio: .......: ${pastatus}"
echo " Website ..........: ${WEB}"
echo " Report Bugs To ...: ${BUGS}"
echo " Install prefix ...: ${PREFIX}"
echo
echo " Finished creating Makefile"
echo
echo " To build and install $PROGRAM, type"
echo
echo " make && sudo make install"
echo
echo
