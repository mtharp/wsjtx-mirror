AC_DEFUN([AC_WSJT_DOCS], [
AC_ARG_ENABLE([docs],
	AC_HELP_STRING([--disable-docs], [Disable Documentation]),
	[ac_cv_docs=yes],
	[ac_cv_docs=no]
	)
if test "x$ac_cv_docs" = "xyes"; then
	BDOC=No
	AC_MSG_NOTICE([Build Documentation Disabled])
else
	BDOC=Yes
	AC_MSG_NOTICE([Build Documentation Enabled])
	AC_PATH_PROG([ASCIIDOCTOR], [asciidoctor])
fi
AC_SUBST([BDOC], ["$BDOC"])

])
