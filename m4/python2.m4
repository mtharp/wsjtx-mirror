AC_DEFUN([AC_PYFMT_PYTHON2], [
HAVE_PY2=no

# check with-enable first
AC_ARG_WITH([python2],
AC_HELP_STRING([--with-python2=DIR], [Path to python2]), [PY2=$with_python2])
AC_MSG_CHECKING([Python2 --with-python2])

# if --with-python2 is not empty
if test -n "$PY2"; then

# check if user provided python3 is >= 2.6
$PY2 -c "import sys; sys.exit(sys.version < '2.6')" >/dev/null 2>&1
	
	if test "$?" != "0"; then
		HAVE_PY2=no
		AC_MSG_RESULT([no])
	else
		HAVE_PY2=yes
		PY2_PATH="$PY2"
		PY2V=`$PY2_PATH -c "import sys; print sys.version" |${HEAD} -1 |${AWK} '{print $1}' |${CUT} -c1-5`
		AC_DEFINE([HAVE_PY2], [1])
		AC_DEFINE_UNQUOTED([PY2_PATH], ["${PY2}"], [Path to Python2])
		AC_SUBST([PYTHON2], ["${PY2}"])
		AC_MSG_RESULT([yes ${PY2V}])
	fi
else
	AC_MSG_RESULT([no])
fi

# if not user supplied, check by calling python
if test "$HAVE_PY2" = "no"; then

	AC_MSG_CHECKING([Python2 using: python])
	python -c "import sys; sys.exit(sys.version < '2.6')" >/dev/null 2>&1

	if test "$?" != 0; then
		AC_MSG_RESULT([no])
		HAVE_PY2=no
	else
		HAVE_PY2=yes
		PY2_PATH=`which python`
		PY2V=`$PY2_PATH -c "import sys; print sys.version" |${HEAD} -1 |${AWK} '{print $1}' |${CUT} -c1-5`
		AC_DEFINE([HAVE_PY2], [1])
		AC_DEFINE_UNQUOTED([PY2_PATH], ["${PY2_PATH}"], [Path to Python2])
		AC_SUBST([PYTHON2], ["${PY2_PATH}"])
		AC_MSG_RESULT([yes ${PY2V}])
	fi
fi

# if not user supplied, if not by calling python, check by calling python2
if test "$HAVE_PY2" = "no"; then
	AC_MSG_CHECKING([Python2 using: python2])
	python2 -c "import sys; sys.exit(sys.version < '2.6')" >/dev/null 2>&1

	if test "$?" != 0; then
		AC_MSG_RESULT([no])
		HAVE_PY2=no
	else
		HAVE_PY2=yes
		PY2_PATH=`which python2`
		PY2V=`$PY2_PATH -c "import sys; print sys.version" |${HEAD} -1 |${AWK} '{print $1}' |${CUT} -c1-5`
		AC_DEFINE([HAVE_PY2], [1])
		AC_DEFINE_UNQUOTED([PY2_PATH], ["${PY2_PATH}"], [Path to Python2])
		AC_SUBST([PYTHON2], ["${PY2_PATH}"])
		AC_MSG_RESULT([yes ${PY2V}])
	fi
fi

])
