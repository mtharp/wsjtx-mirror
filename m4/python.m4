AC_DEFUN([AC_PYFMT_PYTHON], [

# make sure python is not less than 2.6 if yes should yeild = '0'
AC_MSG_CHECKING([python])

python -c "import sys; sys.exit(sys.version < '2.6')" >/dev/null 2>&1
if test "$?" = 0; then

    # now chek if python is > 2.9 = if yes should yeils '1'
    python -c "import sys; sys.exit(sys.version > '2.9')" >/dev/null 2>&1
    if test $? = '1'; then
        # Python3 Syntax
        PYV=`python -c "import sys; print(sys.version)" |${HEAD} -1 |${AWK} '{print $1}' |${CUT} -c1-5`
    else
        # Python2 Syntax
        PYV=`python -c "import sys; print sys.version" |${HEAD} -1 |${AWK} '{print $1}' |${CUT} -c1-5`
    fi

    HAVE_PY=yes
    PY_PATH=`which python`
    AC_DEFINE([HAVE_PY], [1])
    AC_DEFINE_UNQUOTED([PY_PATH], ["${PY_PATH}"], [Path to Python])
    AC_SUBST([PYTHON], ["${PY_PATH}"])
    AC_MSG_RESULT([yes ${PYV}])
fi

# if we are using Python as the default Python, we need Pmw-2.0.0 files
python -c "import sys; sys.exit(sys.version > '2.9')" >/dev/null 2>&1
if test "$?" != '0'; then
    PMW3='Yes'
else
    PMW3='No'
fi

AC_MSG_NOTICE([need Pmw v2.0.0 files... ${PMW3}])
AC_SUBST([PMW3], ["${PMW3}"])

])
