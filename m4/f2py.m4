AC_DEFUN([AC_WSJT_F2PY], [
HAVE_F2PY=no

# check with-f2py first
AC_ARG_WITH([f2py],
AC_HELP_STRING([--with-f2py=DIR], [Path to f2py3]), [F2PY=$with_f2py])
AC_MSG_CHECKING([F2PY --with-f2py])

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

# if f2py is not supplied, try calling with with f2py3
if test "$HAVE_F2PY" = "no"; then

	AC_MSG_CHECKING([F2PY using: f2py3])
	f2py3 -v  >/dev/null 2>&1

	# test if f2py3 is called with f2py3 worked
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

# if not user supplied, check by calling f2py
if test "$HAVE_F2PY" = "no"; then

	AC_MSG_CHECKING([F2PY using: f2py])
	f2py -v  >/dev/null 2>&1

	# test if f2py3 is called using "f2py"
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

])
