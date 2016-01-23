AC_DEFUN([AC_WSJT_SAMPLERATE], [
HAVE_SAMPLERATE=0
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

])
