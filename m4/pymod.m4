AC_DEFUN([AC_PYFMT_PYMOD],[
    PYTHON_NAME=`basename $PYTHON`
    AC_MSG_CHECKING($PYTHON_NAME module: $1)
    $PYTHON -c "import $1" 2>/dev/null
    if test $? -eq 0 ;
    then
        AC_MSG_RESULT(yes)
    else
        AC_MSG_RESULT(no)
        AC_MSG_ERROR(Critical Error - cannot find module $1)
        exit 1
    fi
])
