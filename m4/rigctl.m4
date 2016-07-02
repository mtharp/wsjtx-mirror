AC_DEFUN([AC_PYFMT_RIGCTL], [
HAVE_RGC=no

# check with-enable first
AC_ARG_WITH([rigctl],
AC_HELP_STRING([--with-rigctl=PATH], [Path to rigctl]), [RGC=$with_rigctl])
AC_MSG_CHECKING([rigctl using: ${with_rigctl}])

# if --with-rigctl is not empty
if test -n "$RGC"; then

# check if user provided python3 is >= 3.2
$RGC -V >/dev/null 2>&1
	
	if test "$?" != "0"; then
		HAVE_RGC=no
		AC_MSG_RESULT([no])
	else
		HAVE_RGC=yes
		RGC_PATH="$RGC"
		RGCV=`${RGC} --version | ${AWK} 'FNR==1{print $3}'`
		AC_DEFINE([HAVE_RGC], [1])
		AC_DEFINE_UNQUOTED([RGC_PATH], ["${RGC}"], [Path to Rigctl])
		AC_SUBST([RIGCTL], ["${RGC}"])
		AC_MSG_RESULT([yes])
	fi
else
	AC_MSG_RESULT([no])
fi

# if not user supplied, check by calling rigctl directly
if test "$HAVE_RGC" = "no"; then
	AC_MSG_CHECKING([rigctl using: rigctl])
	rigctl -h >/dev/null 2>&1

	if test "$?" != 0; then
		AC_MSG_RESULT([no])
		HAVE_RGC=no
	else
		HAVE_RGC=1
		RGC_PATH=`which rigctl`
		RGCV=`$RGC_PATH --version |head -1`
		AC_DEFINE([HAVE_RGC], [1])
		AC_DEFINE_UNQUOTED([RGC_PATH], ["${RGC_PATH}"], [Path to Rigctl])
		AC_SUBST([RIGCTL], ["${RGC_PATH}"])
		AC_MSG_RESULT([yes ${RGCV}])
	fi
fi

])
