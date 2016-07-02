AC_DEFUN([AC_PYFMT_DOCS], [
AC_ARG_ENABLE([docs],
	AC_HELP_STRING([--disable-docs], [Disable Documentation]),[ac_cv_docs=yes],[])

if test "x$ac_cv_docs" = "xyes"; then
    BDOC="No"
	AC_MSG_NOTICE([Docs Disabled by user])
else
    AC_MSG_NOTICE([User Requested Docs])    
	AC_PATH_PROG(ADOCP,asciidoctor)
    if test $? != 0; then
		AC_MSG_NOTICE([Docs disabled, Asciidoctor not found])
	else
        BDOC="Yes"
        AC_MSG_NOTICE([Docs Enabled])  
        AC_SUBST([ASCIIDOCTOR], ["$ac_cv_path_ADOCP"])
	fi
fi

AC_SUBST([BDOC], ["$BDOC"])

])
