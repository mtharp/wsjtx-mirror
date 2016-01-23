AC_DEFUN([AC_WSJT_MANPAGES], [
AC_ARG_ENABLE([manpages],
	AC_HELP_STRING([--disable-manpages], [Disable Manpages]),
	[ac_cv_manpages=yes],
	[ac_cv_manpages=no]
	)

if test "x$ac_cv_manpages" = "xyes"; then
	BMANP=No
	AC_MSG_NOTICE([Build Manpages is Disabled])
else
	BMANP=Yes
	AC_MSG_NOTICE([Build Manpages is Enabled])
	AC_PATH_PROG([A2X], [a2x])
fi
AC_SUBST([BMANP], ["$BMANP"])

])
