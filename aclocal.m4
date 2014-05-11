dnl ===========================================================================
dnl 
dnl	SYNOPSIS
dnl
dnl	AX_CHECK_GFORTRAN, AX_CHECK_SAMPLERATE, AX_CHECK_PORTAUDIO, AX_CHECK_FFTW3
dnl
dnl	DESCRIPTION
dnl
dnl 	This set of macros checks for G95 or Gfortran, then the required header
dnl		files for each required applicaiton. If present, performs a simple
dnl		library check to ensure it's functional
dnl
dnl	AUTHORS
dnl		Diane Bruce, VA3DB	
dnl		Greg Beam, KI7MT <ki7mt@yahoo.com>
dnl		See AUTHOS for additional contributions
dnl
dnl	COPYRIGHT
dnl
dnl		Copyright (C) 2014 Joseph H Taylor, Jr, K1JT
dnl 
dnl		This program is free software: you can redistribute it and/or modify
dnl		it under the terms of the GNU General Public License as published by
dnl		the Free Software Foundation, either version 3 of the License, or
dnl		(at your option) any later version.
dnl
dnl		This program is distributed in the hope that it will be useful,
dnl		but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl		GNU General Public License for more details.
dnl
dnl ===========================================================================

dnl {{{ ax_check_gfortran
AC_DEFUN([AX_CHECK_GFORTRAN],[

dnl Check gfortran can perform a basic function
AC_CHECK_LIB([gfortran], [_gfortran_st_write], [HAS_GFORTRAN=1], [HAS_GFORTRAN=0])

# Setting HAS_GFORTRAN
if test ${HAS_GFORTRAN} -eq 1; then
	FC=gfortran
	FCV=gnu95
	FC_LIB_PATH=`${FC} -print-file-name=`
fi

AC_DEFINE_UNQUOTED(FC_LIB_PATH, "${FC_LIB_PATH}", [Path to fortran libs.])
AC_SUBST(FC_LIB_PATH, "${FC_LIB_PATH}")
AC_DEFINE_UNQUOTED(FC, "${FC}", [Fortran compiler.])
AC_SUBST(FC, "${FC}")
AC_SUBST(FCV, "${FCV}")

])dnl }}}

dnl ----------------------------------------------------------------------------
dnl {{{ ax_check_portaudio
AC_DEFUN([AX_CHECK_PORTAUDIO],[

HAS_PORTAUDIO_H=0
HAS_PORTAUDIO_LIB=0
HAS_PORTAUDIO=0


dnl Look in more places for portaudio.h
portaudio_include_dir="/usr/include"
pa_include_dir1="/usr/local/include"

dnl Look in more places for libportaudio.{a.so}
portaudio_lib_dir="/usr/lib"
pa_lib_dir1="/usr/local/lib"
pa_lib_dir2="/usr/lib/x86_64-linux-gnu"
pa_lib_dir3="/usr/lib/i386-linux-gnu"

dnl User Supplied ARGS
AC_ARG_WITH([portaudio-include-dir],
AC_HELP_STRING([--with-portaudio-include-dir=<path>],
    [path to portaudio include files]),
    [portaudio_include_dir=$with_portaudio_include_dir])

AC_ARG_WITH([portaudio-lib-dir],
AC_HELP_STRING([--with-portaudio-lib-dir=<path>],
    [path to portaudio lib files]),
    [portaudio_lib_dir=$with_portaudio_lib_dir])

# dnl If not User Supplied ARGS, look in alternative locations
if test -e ${portaudio_include_dir}/portaudio.h; then
	HAS_PORTAUDIO_H=1

elif test -e ${pa_include_dir1}/portaudio.h; then
	HAS_PORTAUDIO_H=1
else 
	HAS_PORTAUDIO_H=0
fi

dnl Test for lib directories (4) locaitons
dnl We can add more as ndded.

# Testing Traditional Location First
if test -e ${portaudio_lib_dir}/libportaudio.so -o -e ${portaudio_lib_dir}/libportaudio.a; then
	HAS_PORTAUDIO_LIB=1

# Testing Alternate Location: /usr/local/lib
elif test -e ${pa_lib_dir1}/libportaudio.so -o -e ${pa_lib_dir1}/libportaudio.a; then
	HAS_PORTAUDIO_LIB=1
	portaudio_lib_dir="${pa_lib_dir1}"

# Testing Alternate /usr/lib/x86_64-linux-gnu
elif test -e $[{pa_lib_dir2}]/libportaudio.so -o -e $[{pa_lib_dir2}]/libportaudio.a; then
	HAS_PORTAUDIO_LIB=1
	portaudio_lib_dir="${pa_lib_dir2}"

# Testing Alternate /usr/lib/i386-linux-gnu
elif test -e ${pa_lib_dir3}/libportaudio.so -o -e ${pa_lib_dir3}/libportaudio.a; then
	HAS_PORTAUDIO_LIB=1
	portaudio_lib_dir="${pa_lib_dir3}"

else
	HAS_PORTAUDIO_LIB=0
fi

# Setting HAS_PORTAUDIO
if test ${HAS_PORTAUDIO_H} -eq 1 -a ${HAS_PORTAUDIO_LIB} -eq 1; then

	CPPFLAGS="-I${portaudio_include_dir} ${CPPFLAGS}"
	LDFLAGS="-L${portaudio_lib_dir} ${LDFLAGS}"
	LIBS="${LIBS} -lportaudio"

	dnl Check Portaudio can perform a basic function
	AC_CHECK_LIB([portaudio], [Pa_GetVersion], [HAS_PORTAUDIO_VERSION=1], [HAS_PORTAUDIO_VERSION=0])

	if test $[{HAS_PORTAUDIO_VERSION}] -eq 0; then
		AC_MSG_RESULT([Check portaudio19-dev is installed])
	else
		HAS_PORTAUDIO=1
	fi
fi

])dnl }}}


dnl ----------------------------------------------------------------------------
dnl {{{ ax_check_samplerate
AC_DEFUN([AX_CHECK_SAMPLERATE],[

HAS_SAMPLERATE_H=0
HAS_SAMPLERATE_LIB=0
HAS_PORTAUDIO=0

dnl Look in more places for portaudio.h
samplerate_include_dir="/usr/include"
sr_include_dir1="/usr/local/include"

dnl Look in more places for libportaudio.{a.so}
samplerate_lib_dir="/usr/lib"
sr_lib_dir1="/usr/local/lib"
sr_lib_dir2="/usr/lib/x86_64-linux-gnu"
sr_lib_dir3="/usr/lib/i386-linux-gnu"


dnl User Supplied ARGS
AC_ARG_WITH([samplerate-include-dir],
AC_HELP_STRING([--with-samplerate-include-dir=<path>],
    [path to samplerate include files]),
    [samplerate_include_dir=$with_samplerate_include_dir])

AC_ARG_WITH([samplerate-lib-dir],
AC_HELP_STRING([--with-samplerate-lib-dir=<path>],
    [path to samplerate lib files]),
    [samplerate_lib_dir=$with_samplerate_lib_dir])

# dnl If not User Supplied ARGS, look in alternative locations
if test -e $[{samplerate_include_dir}]/samplerate.h; then
	HAS_SAMPLERATE_H=1

elif test -e ${sr_include_dir1}/samplerate.h; then
	HAS_SAMPLERATE_H=1
	samplerate_include_dir="${sr_include_dir1}"
else 
	HAS_SAMPLERATE_H=0
fi

dnl Test for lib directories (4) locaitons
dnl We can add more as ndded.

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
	samplerate_lib_dir="$[{sr_lib_dir2}]"

# Testing Alternate /usr/lib/i386-linux-gnu
elif test -e ${pa_lib_dir3}/libsamplerate.so -o -e ${pa_lib_dir3}/libsamplerate.a; then
	HAS_SAMPLERATE_LIB=1
	samplerate_lib_dir="${sr_lib_dir3}"

else
	HAS_SAMPLERATE_LIB=0
fi

# Setting HAS_SAMPLERATE
if test ${HAS_SAMPLERATE_H} -eq 1 -a ${HAS_SAMPLERATE_LIB} -eq 1; then

	CPPFLAGS="-I${samplerate_include_dir} ${CPPFLAGS}"
	LDFLAGS="-L${samplerate_lib_dir} ${LDFLAGS}"
	LIBS="${LIBS} -lsamplerate"

	dnl Check Samplrate can perform a basic funciton
	AC_CHECK_LIB([samplerate], [src_simple], [HAS_SAMPLERATE_LIB=1], [HAS_SAMPLERATE_LIB=0])

	if test $[{HAS_SAMPLERATE_LIB}] -eq 0; then
		AC_MSG_RESULT([Check samplerate-dev package is installed.])
	else
		HAS_SAMPLERATE=1
	fi
fi

])dnl }}}


dnl ----------------------------------------------------------------------------
dnl {{{ ax_check_fftw3
AC_DEFUN([AX_CHECK_FFTW3],[

HAS_FFTW3_LIB=0
HAS_FFTW3=0

dnl Look in more places for libfftw3f.{a.so}
fftw3_lib_dir="/usr/lib"
ff_lib_dir1="/usr/local/lib"
ff_lib_dir2="/usr/lib/x86_64-linux-gnu"
ff_lib_dir3="/usr/lib/i386-linux-gnu"

dnl User Supplied ARGS
AC_ARG_WITH([fftw3-lib-dir],
AC_HELP_STRING([--with-fftw3-lib-dir=<path>],
    [path to fftw3 lib files]),
    [fftw3_lib_dir=$with_samplerate_lib_dir])

dnl Test for lib directories (4) locaitons
dnl We can add more as ndded.

# Testing Traditional Location First
if test -e ${fftw3_lib_dir}/libfftw3f.so -o -e ${fftw3_lib_dir}/libfftw3f.a; then
	HAS_FFTW3_LIB=1

# Testing Alternate Location: /usr/local/lib
elif test -e ${ff_lib_dir1}/libfftw3f.so -o -e ${ff_lib_dir1}/libfftw3f.a; then
	HAS_FFTW3_LIB=1
	fftw3_lib_dir="${sr_lib_dir1}"

# Testing Alternate /usr/lib/x86_64-linux-gnu
elif test -e ${ff_lib_dir2}/libfftw3f.so -o -e ${ff_lib_dir2}/libfftw3f.a; then
	HAS_FFTW3_LIB=1
	fftw3_lib_dir="${sr_lib_dir2}"

# Testing Alternate /usr/lib/i386-linux-gnu
elif test -e ${ff_lib_dir3}/libfftw3f.so -o -e ${pa_lib_dir3}/libfftw3f.a; then
	HAS_FFTW3_LIB=1
	fftw3_lib_dir="${sr_lib_dir3}"

else
	HAS_FFTW3_LIB=0
fi

# Setting FFTW HAS_FFTW3
if test "${HAS_FFTW3_LIB}" -eq 1; then

	CPPFLAGS="-I${fftw3_include_dir} ${CPPFLAGS}"
	LDFLAGS="-L${fftw3_lib_dir} ${LDFLAGS}"
	LIBS="${LIBS} -lfftw3f"

	dnl Check FFTW can perform  a basic function
	AC_CHECK_LIB([fftw3f], [sfftw_destroy_plan_], [HAS_FFTW3_L=1], [HAS_FFTW3_L=0])

	if test ${HAS_FFTW3_LIB} -eq 0; then
		AC_MSG_RESULT([Check libfftw3-dev is installed.])
	else
		HAS_FFTW3=1
	fi
fi

])dnl }}}

