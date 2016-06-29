AC_DEFUN([AC_PYFMT_GFORTRAN], [
gfortran="gfortran"
#
# Sames as portadio, use case for FreeBSD to prevent Linux shell errors. -gb
#
case "${host_os}" in
	*freebsd* )
		# if --with-gfortran is not empty
		AC_ARG_WITH([gfortran],
		AC_HELP_STRING([--with-gfortran=DIR], [Path to gfortran]), [gfortran=$with_gfortran])
		AC_MSG_CHECKING([F2PY --with-f2py])
		if test -n ${with_gfortran}; then
			gfortran="${with_gfortran}"
			gfpath=`${gfortran} --print-file-name=|awk -F/ '{print $1 "/" $2 "/" $3 "/" $4 "/" $5}'`
			LDFLAGS="-L${gfpath} ${LDFLAGS}"
		fi
	;;
	*darwin* )
		# if --with-gfortran is not empty
		AC_ARG_WITH([gfortran],
		AC_HELP_STRING([--with-gfortran=DIR], [Path to gfortran]), [gfortran=$with_gfortran])
		AC_MSG_CHECKING([F2PY --with-f2py])
		if test -n ${with_gfortran}; then
			gfortran="${with_gfortran}"
			gfpath=`${gfortran} --print-file-name=|awk -F/ '{print $1 "/" $2 "/" $3 "/" $4 "/" $5}'`
			LDFLAGS="-L${gfpath} ${LDFLAGS}"
		fi
	;;
	*)
	;;
esac

AC_CHECK_LIB([gfortran], [_gfortran_st_write], [], [])

if test "$ac_cv_lib_gfortran__gfortran_st_write" != "yes"; then
	HAVE_GFORTRAN=0
else
	HAVE_GFORTRAN=1
	FC=${gfortran}
	FCV=gnu95
	FC_LIB_PATH=`${FC} -print-file-name=`
	AC_DEFINE_UNQUOTED([FC_LIB_PATH], ["${FC_LIB_PATH}"], [Path to Gfortran libs.])
	AC_SUBST([FC_LIB_PATH], ["${FC_LIB_PATH}"])
	AC_DEFINE_UNQUOTED([FC], ["${FC}"], [Gfortran Compiler])
	AC_SUBST([FC], ["${FC}"])
	AC_SUBST([FCV], ["${FCV}"])
	AC_DEFINE([HAVE_GFORTRAN], [1],)
	AC_DEFINE([HAVE_GFORTRAN_LIB], [1],)
fi

])
