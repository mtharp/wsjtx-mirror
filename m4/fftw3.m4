AC_DEFUN([AC_PYFMT_FFTW3], [
HAVE_FFTW3_LIB=0
AC_CHECK_LIB([fftw3f], [sfftw_destroy_plan_], [], [])

if test "$ac_cv_lib_fftw3f_sfftw_destroy_plan_" = "yes"; then
	LIBS="-lfftw3f ${LIBS}"
fi

# if headers and libs found, set defines
if test "$ac_cv_lib_fftw3f_sfftw_destroy_plan_" = "yes"; then
	HAVE_FFTW3_LIB=1
	AC_DEFINE([HAVE_FFTW3_LIB], [1], [FFTW3 Libs])
fi

])
