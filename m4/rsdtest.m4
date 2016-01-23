AC_DEFUN([AC_WSJT_RSDTEST], [
AC_ARG_ENABLE([rsdtest],
	AC_HELP_STRING([--enable-rsdtest], [Enable RSD Test Tools]),
	[ac_cv_rsdtest=yes],
	[ac_cv_rsdtest=no]
	)
if test "x$ac_cv_rsdtest" = "xyes"; then
	RSDTEST=Yes
	AC_MSG_NOTICE([RSD Test Tools Enabled])
else
	RSDTEST=No
	AC_MSG_NOTICE([RSD Test Tools Disabled])
fi
AC_SUBST([RSDTEST], ["$RSDTEST"])

])
