AC_DEFUN([AC_WSPR_PYTHON3], [
HAVE_PY3=no

# check with-enable first
AC_ARG_WITH([python3],
AC_HELP_STRING([--with-python3=DIR], [Path to python3]), [PY3=$with_python3])
AC_MSG_CHECKING([Python3 --with-python3])

# if --with-python3 is not empty
if test -n "$PY3"; then

# check if user provided python3 is >= 3.2
$PY3 -c "import sys; sys.exit(sys.version < '3.2')" >/dev/null 2>&1
	
	if test "$?" != "0"; then
		HAVE_PY3=no
		AC_MSG_RESULT([no])
	else
		HAVE_PY3=yes
		PY3_PATH="$PY3"
		PY3V=`$PY3_PATH -c "import sys; print(sys.version)" |${HEAD} -1 |${AWK} '{print $1}' |${CUT} -c1-5`
		AC_DEFINE([HAVE_PY3], [1])
		AC_DEFINE_UNQUOTED([PY3_PATH], ["${PY3}"], [Path to Python3])
		AC_SUBST([PYTHON3], ["${PY3}"])
		AC_MSG_RESULT([yes ${PY3V}])
	fi
else
	AC_MSG_RESULT([no])
fi

# if not user supplied, check by calling python3
if test "$HAVE_PY3" = "no"; then
	AC_MSG_CHECKING([Python3 using: python3])
	python3 -c "import sys; sys.exit(sys.version < '3.2')" >/dev/null 2>&1

	if test "$?" != 0; then
		AC_MSG_RESULT([no])
		HAVE_PY3=no
	else
		HAVE_PY3=yes
		PY3_PATH=`which python3`
		PY3V=`$PY3_PATH -c "import sys; print(sys.version)" |${HEAD} -1 |${AWK} '{print $1}' |${CUT} -c1-5`
		AC_DEFINE([HAVE_PY3], [1])
		AC_DEFINE_UNQUOTED([PY3_PATH], ["${PY3_PATH}"], [Path to Python3])
		AC_SUBST([PYTHON3], ["${PY3_PATH}"])
		AC_MSG_RESULT([yes ${PY3V}])
	fi
fi

# if not user supplied, if not by using python3, check by calling python
if test "$HAVE_PY3" = "no"; then

	AC_MSG_CHECKING([Python3 using: python])
	python -c "import sys; sys.exit(sys.version < '3.2')" >/dev/null 2>&1

	if test "$?" != 0; then
		AC_MSG_RESULT([no])
		HAVE_PY3=no
	else
		HAVE_PY3=yes
		PY3_PATH=`which python`
		PY3V=`$PY3_PATH -c "import sys; print(sys.version)" |${HEAD} -1 |${AWK} '{print $1}' |${CUT} -c1-5`
		AC_DEFINE([HAVE_PY3], [1])
		AC_DEFINE_UNQUOTED([PY3_PATH], ["${PY3_PATH}"], [Path to Python3])
		AC_SUBST([PYTHON3], ["${PY3_PATH}"])
		AC_MSG_RESULT([yes ${PY3V}])
	fi
fi

])
