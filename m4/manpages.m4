AC_DEFUN([AC_PYFMT_MANPAGES], [
AC_ARG_ENABLE([manpages],
	AC_HELP_STRING([--disable-manpages], [Disable Manpages]),
	[ac_cv_manpages=yes],
	[ac_cv_manpages=no]
	)

if test "x$ac_cv_manpages" = "xyes"; then
    BMANP="No"
	AC_MSG_NOTICE([Manpages Disabled by user])
else
    AC_MSG_NOTICE([User Requested Manpages])    
	AC_PATH_PROG(ADOCP,asciidoctor)
    if test $? != 0; then
		AC_MSG_NOTICE([Manpages disabled, Asciidoctor not found])
	else
        BMANP="Yes"
        AC_MSG_NOTICE([Manpages Enabled])  
        AC_SUBST([ASCIIDOCTOR], ["$ac_cv_path_ADOCP"])
	fi
fi

AC_SUBST([BMANP], ["$BMANP"])

])
