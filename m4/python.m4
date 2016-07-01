AC_DEFUN([AC_PYFMT_PYTHON], [
HAVE_PY=no

# check with-enable first
AC_ARG_WITH([python],
AC_HELP_STRING([--with-python=DIR], [Path to python]), [PY=$with_python2])
AC_MSG_CHECKING([Python --with-python])

# if --with-python2 is not empty
if test -n "$PY"; then

# check if user provided python3 is >= 2.6
$PY -c "import sys; sys.exit(sys.version < '2.6')" >/dev/null 2>&1
	
	if test "$?" != "0"; then
		HAVE_PY=no
		AC_MSG_RESULT([no])
	else
		HAVE_PY=yes
		PY_PATH="$PY"
		PYV=`$PY_PATH -c "import sys; print sys.version" |${HEAD} -1 |${AWK} '{print $1}' |${CUT} -c1-5`
		AC_DEFINE([HAVE_PY], [1])
		AC_DEFINE_UNQUOTED([PY_PATH], ["${PY}"], [Path to Python])
		AC_SUBST([PYTHON], ["${PY}"])
		AC_MSG_RESULT([yes ${PYV}])
	fi
else
	AC_MSG_RESULT([no])
fi

# if not user supplied, check by calling python
if test "$HAVE_PY" = "no"; then

	AC_MSG_CHECKING([Python using: python])
	python -c "import sys; sys.exit(sys.version < '2.6')" >/dev/null 2>&1

	if test "$?" != 0; then
		AC_MSG_RESULT([no])
		HAVE_PY=no
	else
		HAVE_PY=yes
		PY_PATH=`which python`
		PYV=`$PY_PATH -c "import sys; print sys.version" |${HEAD} -1 |${AWK} '{print $1}' |${CUT} -c1-5`
		AC_DEFINE([HAVE_PY], [1])
		AC_DEFINE_UNQUOTED([PY_PATH], ["${PY_PATH}"], [Path to Python])
		AC_SUBST([PYTHON], ["${PY_PATH}"])
		AC_MSG_RESULT([yes ${PYV}])
	fi
fi

# if not user supplied, if not by calling python, check by calling python2
if test "$HAVE_PY" = "no"; then
	AC_MSG_CHECKING([Python using: python])
	python -c "import sys; sys.exit(sys.version < '2.6')" >/dev/null 2>&1

	if test "$?" != 0; then
		AC_MSG_RESULT([no])
		HAVE_PY=no
	else
		HAVE_PY=yes
		PY_PATH=`which python2`
		PYV=`$PY_PATH -c "import sys; print sys.version" |${HEAD} -1 |${AWK} '{print $1}' |${CUT} -c1-5`
		AC_DEFINE([HAVE_PY], [1])
		AC_DEFINE_UNQUOTED([PY_PATH], ["${PY_PATH}"], [Path to Python])
		AC_SUBST([PYTHON], ["${PY_PATH}"])
		AC_MSG_RESULT([yes ${PYV}])
	fi
fi

])
