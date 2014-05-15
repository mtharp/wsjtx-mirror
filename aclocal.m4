dnl ===========================================================================
dnl 
dnl	SYNOPSIS
dnl
dnl	AX_CHECK_GFORTRAN, AX_CHECK_SAMPLERATE, AX_CHECK_PORTAUDIO,
dnl	AX_CHECK_FFTW3, AX_CHECK_PYTHON AX_CHECK_F2PY
dnl
dnl	DESCRIPTION
dnl
dnl	This set of macros checks for Gfortran, Python v3+, F2PY then the
dnl	required header files for each required applicaiton. If present,
dnl	performs a simple library check to ensure it's functional
dnl
dnl	AUTHORS
dnl	* Diane Bruce, VA3DB	
dnl	* Greg Beam, KI7MT <ki7mt@yahoo.com>
dnl	* See AUTHORS for additional contributions
dnl
dnl	COPYRIGHT
dnl
dnl	Copyright (C) 2014 Joseph H Taylor, Jr, K1JT
dnl 
dnl	This program is free software: you can redistribute it and/or modify
dnl	it under the terms of the GNU General Public License as published by
dnl	the Free Software Foundation, either version 3 of the License, or
dnl	(at your option) any later version.
dnl
dnl	This program is distributed in the hope that it will be useful,
dnl	but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl	GNU General Public License for more details.
dnl
dnl ===========================================================================

dnl {{{ ax_check_python
AC_DEFUN([AX_CHECK_PYTHON],[

HAS_PYTHON3=0

AC_ARG_WITH([python3-dir],
	AC_HELP_STRING([--with-python3=<Path to Python3>],
	[Provide path t Python3]),
	[python3_dir=$with_python3])

# Try to get python version
AC_MSG_CHECKING([for Python3 using: python])
PYCHECK=`python -c "import sys; ver = sys.version.split ()[[0]]; print (ver >= '3.2.0')"`

# Check if python3 is called using "python"
if test "$PYCHECK" != "True"; then
	AC_MSG_RESULT([no])
	HAS_PYTHON3A=0
else
	AC_MSG_RESULT([yes])
	HAS_PYTHON3A=1
	pylocation=`which python`
fi

# Check if python3 is called by using "python3" v.s. "python"
if test "${HAS_PYTHON3}" -eq 0; then
AC_MSG_CHECKING([for Python3 using: python3])
PYCHECK=`python3 -c "import sys; ver = sys.version.split ()[[0]]; print (ver >= '3.2.0')"`

	if test "$PYCHECK" != "True"; then
		AC_MSG_RESULT([no])
		HAS_PYTHON3B=0

	else
		AC_MSG_RESULT([yes])
		HAS_PYTHON3B=1
		pylocation=`which python3`
	fi
fi

])dnl }}}


dnl ----------------------------------------------------------------------------
dnl {{{ ax_check_f2py
AC_DEFUN([AX_CHECK_F2PY],[

HAS_F2PY=0

AC_ARG_WITH([f2py3-dir],
	AC_HELP_STRING([--with-f2py3=<Path to F2PY3>],
	[Provide path to f2py3]),
	[f2py3_dir=$with_f2py3])

# Try to get f2py
AC_MSG_CHECKING([for F2PY using: f2py])
F2PYCHECK=`f2py -v  > /dev/null 2>&1`

# Check if f2py3 is called using "f2py"
if test "$?" != "0"; then
	AC_MSG_RESULT([no])
	HAS_F2PYA=0
else
	AC_MSG_RESULT([yes])
	HAS_F2PYA=1
	f2pylocation=`which f2py`
fi

# Check if f2py is called by using "f2py3" v.s. "f2py"
if test "${HAS_F2PY}" -eq 0; then
AC_MSG_CHECKING([for F2PY using: f2py3])
F2PYCHECK=`f2py3 -v > /dev/null 2>&1`

	if test "$?" != "0"; then
		AC_MSG_RESULT([no])
		HAS_F2PYB=0

	else
		AC_MSG_RESULT([yes])
		HAS_F2PYB=1
		f2pylocation=`which f2py3`
	fi
fi

])dnl }}}


dnl ----------------------------------------------------------------------------
dnl {{{ ax_check_gfortran
AC_DEFUN([AX_CHECK_GFORTRAN],[

AC_ARG_WITH([gfortran-lib-dir],
	AC_HELP_STRING([--with-gfortran-lib-dir=<path>],
	[Provide path to Lib Gfortran]),
	[gfortran_lib_dir=$with_gfortran_lib_dir])

# Check gfortran can perform a basic function
AC_CHECK_LIB([gfortran], [_gfortran_st_write], [HAS_GFORTRAN=1], [HAS_GFORTRAN=0])

if test ${HAS_GFORTRAN} -eq 0; then
	AC_MSG_RESULT([no])
	HAS_GFORTRAN=0

else
	FC=gfortran
	FCV=gnu95
	FC_LIB_PATH=`${FC} -print-file-name=`
	AC_DEFINE_UNQUOTED(FC_LIB_PATH, "${FC_LIB_PATH}", [Path to fortran libs.])
	AC_SUBST(FC_LIB_PATH, "${FC_LIB_PATH}")
	AC_DEFINE_UNQUOTED(FC, "${FC}", [Fortran compiler.])
	AC_SUBST(FC, "${FC}")
	AC_SUBST(FCV, "${FCV}")
fi


])dnl }}}

dnl ----------------------------------------------------------------------------
dnl {{{ ax_check_portaudio
AC_DEFUN([AX_CHECK_PORTAUDIO],[

HAS_PORTAUDIO_H=0
HAS_PORTAUDIO_LIB=0
HAS_PORTAUDIO=0

AC_ARG_WITH([portaudio-include-dir],
	AC_HELP_STRING([--with-portaudio-include-dir=<path>],
	[path to portaudio include files]),
	[portaudio_include_dir=$with_portaudio_include_dir])

AC_ARG_WITH([portaudio-lib-dir],
	AC_HELP_STRING([--with-portaudio-lib-dir=<Path to Portaudio Libs>],
	[Provide path to Portaudio lib files]),
	[portaudio_lib_dir=$with_portaudio_lib_dir])

# Look in more places for portaudio.h
portaudio_include_dir="/usr/include"
pa_include_dir1="/usr/local/include"

# Look in more places for libportaudio.{a.so}
portaudio_lib_dir="/usr/lib"
pa_lib_dir1="/usr/local/lib"
pa_lib_dir2="/usr/lib/x86_64-linux-gnu"
pa_lib_dir3="/usr/lib/i386-linux-gnu"

# If not User Supplied ARGS, look in alternative locations
if test -e ${portaudio_include_dir}/portaudio.h; then
	HAS_PORTAUDIO_H=1

elif test -e ${pa_include_dir1}/portaudio.h; then
	HAS_PORTAUDIO_H=1
else 
	HAS_PORTAUDIO_H=0
fi

# Testing Traditional Location First
if test -e ${portaudio_lib_dir}/libportaudio.so -o -e ${portaudio_lib_dir}/libportaudio.a; then
	HAS_PORTAUDIO_LIB=1

# Testing Alternate Location: /usr/local/lib
elif test -e ${pa_lib_dir1}/libportaudio.so -o -e ${pa_lib_dir1}/libportaudio.a; then
	HAS_PORTAUDIO_LIB=1
	portaudio_lib_dir="${pa_lib_dir1}"

# Testing Alternate /usr/lib/x86_64-linux-gnu
elif test -e ${pa_lib_dir2}/libportaudio.so -o -e ${pa_lib_dir2}/libportaudio.a; then
	HAS_PORTAUDIO_LIB=1
	portaudio_lib_dir="${pa_lib_dir2}"

# Testing Alternate /usr/lib/i386-linux-gnu
elif test -e ${pa_lib_dir3}/libportaudio.so -o -e ${pa_lib_dir3}/libportaudio.a; then
	HAS_PORTAUDIO_LIB=1
	portaudio_lib_dir="${pa_lib_dir3}"

else
	HAS_PORTAUDIO_LIB=0
fi

# Test a simple Portaudio function
if test ${HAS_PORTAUDIO_H} -eq 1 -a ${HAS_PORTAUDIO_LIB} -eq 1; then
AC_CHECK_LIB([portaudio], [Pa_GetVersion], [HAS_PORTAUDIO_VERSION=1], [HAS_PORTAUDIO_VERSION=0])

	if test $[{HAS_PORTAUDIO_VERSION}] -eq 0; then
		HAS_PORTAUDIO=0

	else
		HAS_PORTAUDIO=1
		CPPFLAGS="-I${portaudio_include_dir} ${CPPFLAGS}"
		PALD="-L${portaudio_lib_dir}"
		LIBS="${LIBS} -lportaudio"
	fi
fi

])dnl }}}


dnl ----------------------------------------------------------------------------
dnl {{{ ax_check_samplerate
AC_DEFUN([AX_CHECK_SAMPLERATE],[

HAS_SAMPLERATE_H=0
HAS_SAMPLERATE_LIB=0
HAS_PORTAUDIO=0


AC_ARG_WITH([samplerate-include-dir],
	AC_HELP_STRING([--with-samplerate-include-dir=<path>],
	[Provide path to Samplerate include files]),
	[samplerate_include_dir=$with_samplerate_include_dir])

AC_ARG_WITH([samplerate-lib-dir],
	AC_HELP_STRING([--with-samplerate-lib-dir=<Path to Samplerate Libs>],
	[Provide path to Samplerate lib files]),
	[samplerate_lib_dir=$with_samplerate_lib_dir])


# Look in more places for samplerate.h
samplerate_include_dir="/usr/include"
sr_include_dir1="/usr/local/include"

# If not User Supplied ARGS, look in alternative locations
if test -e ${samplerate_include_dir}/samplerate.h; then
	HAS_SAMPLERATE_H=1

elif test -e ${sr_include_dir1}/samplerate.h; then
	HAS_SAMPLERATE_H=1
	samplerate_include_dir="${sr_include_dir1}"
else 
	HAS_SAMPLERATE_H=0
fi

# Look in more places for libsamplerate.{a.so}
samplerate_lib_dir="/usr/lib"
sr_lib_dir1="/usr/local/lib"
sr_lib_dir2="/usr/lib/x86_64-linux-gnu"
sr_lib_dir3="/usr/lib/i386-linux-gnu"

# Testing Traditional Location First
if test -e ${samplerate_lib_dir}/libsamplerate.so -o -e ${samplerate_lib_dir}/libsamplerate.a; then
	HAS_SAMPLERATE_LIB=1

# Testing Alternate Location: /usr/local/lib
elif test -e ${sr_lib_dir1}/libsamplerate.so -o -e ${sr_lib_dir1}/libsamplerate.a; then
	HAS_SAMPLERATE_LIB=1
	samplerate_lib_dir="${sr_lib_dir1}"

# Testing Alternate /usr/lib/x86_64-linux-gnu
elif test -e ${sr_lib_dir2}/libsamplerate.so -o -e ${sr_lib_dir2}/libsamplerate.a; then
	HAS_SAMPLERATE_LIB=1
	samplerate_lib_dir="${sr_lib_dir2}"

# Testing Alternate /usr/lib/i386-linux-gnu
elif test -e ${sr_lib_dir3}/libsamplerate.so -o -e ${sr_lib_dir3}/libsamplerate.a; then
	HAS_SAMPLERATE_LIB=1
	samplerate_lib_dir="${sr_lib_dir3}"
else
	HAS_SAMPLERATE_LIB=0
fi

# Test a simple Samplerate function
if test ${HAS_SAMPLERATE_H} -eq 1 -a ${HAS_SAMPLERATE_LIB} -eq 1; then

	dnl Check Samplrate can perform a basic funciton
	AC_CHECK_LIB([samplerate], [src_simple], [HAS_SAMPLERATE_LIB=1], [HAS_SAMPLERATE_LIB=0])

	if test $[{HAS_SAMPLERATE_LIB}] -eq 0; then
		HAS_SAMPLERATE=0

	else
		HAS_SAMPLERATE=1
		CPPFLAGS="-I${samplerate_include_dir} ${CPPFLAGS}"
		SRLD="-L${samplerate_lib_dir}"
		LIBS="${LIBS} -lsamplerate"
	fi
fi

])dnl }}}


dnl ----------------------------------------------------------------------------
dnl {{{ ax_check_fftw3
AC_DEFUN([AX_CHECK_FFTW3],[

HAS_FFTW3_LIB=0
HAS_FFTW3=0

AC_ARG_WITH([fftw3-lib-dir],
	AC_HELP_STRING([--with-fftw3-lib-dir=<Path to FFTW3 Libs>],
	[Provide path to FFTW lib files]),
	[fftw3_lib_dir=$with_fftw3_lib_dir])

dnl Look in more places for libfftw3f.{a.so}
fftw3_lib_dir="/usr/lib"
ff_lib_dir1="/usr/local/lib"
ff_lib_dir2="/usr/lib/x86_64-linux-gnu"
ff_lib_dir3="/usr/lib/i386-linux-gnu"
ff_lib_dir4="/usr/lib64"

# If not User Supplied ARGS, look in alternative locations
if test -e ${fftw3_lib_dir}/libfftw3f.so -o -e ${fftw3_lib_dir}/libfftw3f.a; then
	HAS_FFTW3_LIB=1

# Testing Alternate Location: /usr/local/lib
elif test -e ${ff_lib_dir1}/libfftw3f.so -o -e ${ff_lib_dir1}/libfftw3f.a; then
	HAS_FFTW3_LIB=1
	fftw3_lib_dir="${ff_lib_dir1}"

# Testing Alternate /usr/lib/x86_64-linux-gnu
elif test -e ${ff_lib_dir2}/libfftw3f.so -o -e ${ff_lib_dir2}/libfftw3f.a; then
	HAS_FFTW3_LIB=1
	fftw3_lib_dir="${ff_lib_dir2}"

# Testing Alternate /usr/lib/i386-linux-gnu
elif test -e ${ff_lib_dir3}/libfftw3f.so -o -e ${ff_lib_dir3}/libfftw3f.a; then
	HAS_FFTW3_LIB=1
	fftw3_lib_dir="${ff_lib_dir3}"

# Testing Alternate /usr/lib/i386-linux-gnu
elif test -e ${ff_lib_dir4}/libfftw3f.so -o -e ${ff_lib_dir4}/libfftw3f.a; then
	HAS_FFTW3_LIB=1
	fftw3_lib_dir="${ff_lib_dir4}"

else
	HAS_FFTW3_LIB=0

fi

# Test a simple FFTW function
if test "${HAS_FFTW3_LIB}" -eq 1; then

	dnl Check FFTW can perform  a basic function
	AC_CHECK_LIB([fftw3f], [sfftw_destroy_plan_], [HAS_FFTW3_L=1], [HAS_FFTW3_L=0])

	if test ${HAS_FFTW3_LIB} -eq 0; then
		HAS_FFTW3=0

	else
		HAS_FFTW3=1
		CPPFLAGS="-I${fftw3_include_dir} ${CPPFLAGS}"
		FFLD="-L${fftw3_lib_dir}"
		LIBS="${LIBS} -lfftw3f"
	fi
fi

])dnl }}}

