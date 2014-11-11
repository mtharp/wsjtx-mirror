# ------------------------------------------------------------------------------
# Process this file with autoconf to create configure. -*- autoconf -*-
# ------------------------------------------------------------------------------
AC_PREREQ([2.69])
AC_INIT([KVASD-INSTALLER],[1.12.0],[wsjt-devel@lists.sourceforge.net],[],
[http://physics.princeton.edu/pulsar/k1jt/devel.html])
AC_CONFIG_AUX_DIR([build-aux])


# ------------------------------------------------------------------------------
#  canonical host information
# ------------------------------------------------------------------------------
AC_CANONICAL_HOST
AC_DEFINE_UNQUOTED(_NAME, "${host}",[Canonical name (cpu-vendor-os) of your system.])
AC_DEFINE_UNQUOTED(_CPU, "${host_cpu}",[Name of the CPU of your system.])
AC_DEFINE_UNQUOTED(_VENDOR, "${host_vendor}",[Name of the vendor of your system.])
AC_DEFINE_UNQUOTED(_OS, "${host_os}",[Name of the OS of your system.])
AC_SUBST([_NAME], [${host}])
AC_SUBST([_OS], [${host_os}])
AC_SUBST([_CPU], [${host_cpu}])
AC_SUBST([_VENDOR], [${host_vendor}])


# ------------------------------------------------------------------------------
#  base compiler setup
# ------------------------------------------------------------------------------
OCFLAGS="$CFLAGS"
AC_PROG_CC
AC_PROG_CXX
AC_PROG_FC
AC_PROG_GCC_TRADITIONAL
AC_PROG_MAKE_SET
AC_PROG_RANLIB
AC_PROG_MAKE_SET
AC_USE_SYSTEM_EXTENSIONS
CFLAGS="$OCFLAGS"


# ------------------------------------------------------------------------------
#  set default path if not set
# ------------------------------------------------------------------------------
AC_PREFIX_DEFAULT("/usr")
if test "$prefix" = "NONE"; then 
	prefix=${ac_default_prefix}
fi


# ------------------------------------------------------------------------------
#  path variables
# ------------------------------------------------------------------------------
BINDIR="$prefix"/bin
SHARED="$prefix"/share/kvasd-installer
DOCDIR="$prefix"/share/doc/kvasd-installer
MANDIR="$prefix"/share/man/man1

AC_ARG_WITH([docdir],
AC_HELP_STRING([--with-docdir=PATH], [path to documentuments]), [docdir=$with_docdir])
if test -n "$with_docdir"; then
	AC_SUBST([DOCDIR], ["$with_docdir"])
fi

AC_ARG_WITH([mandir],
AC_HELP_STRING([--with-mandir=PATH], [path to manpages]), [mandir=$with_mandir])
if test -n "$with_mandir"; then
	AC_SUBST([MANDIR], ["$with_mandir"])
fi


# ------------------------------------------------------------------------------
# check for standard apps
# ------------------------------------------------------------------------------
AC_C_INLINE
AC_PATH_PROG([AWK], [awk])
AC_PATH_PROG([CP], [cp])
AC_PATH_PROG([INSTALL], [install])
AC_PATH_PROG([MKDIR], [mkdir])
AC_PATH_PROG([MV], [mv])
AC_PATH_PROG([RM], [rm])
AC_PATH_PROG([SED], [sed])
AC_PATH_PROG([SHELL], [bash])
AC_PATH_PROG([TOUCH], [touch])


# ------------------------------------------------------------------------------
#  check for dialog installation
# ------------------------------------------------------------------------------
AC_CHECK_PROG([DIALOG], [dialog], [yes], [no])
if test "$DIALOG" = no ; then
	echo ''
	AC_MSG_WARN([Critial Package Missing, "Dialog". Please install to continue.])
	echo ' [1] Use your package manager to search for dialog'
	echo ' [2] Review this link for options / ideas:'
	echo '...http://invisible-island.net/dialog/dialog.html'
	echo ''
	exit 1
fi


# ------------------------------------------------------------------------------
#  check for curl installation
# ------------------------------------------------------------------------------
AC_CHECK_PROG([CURL], [curl], [yes], [no])
if test "$CURL" = no ; then
	echo ''
	AC_MSG_WARN([Critial Package Missing, "curl". Please install to continue.])
	echo ''
	echo ' [1] Use your package manager to search, curl or libcurl'
	echo ' [2] Review this link for options / ideas:'
	echo '==> http://curl.haxx.se/download.html <=='
	echo ''
	exit 1
fi


# ------------------------------------------------------------------------------
#  check libgfortran
# ------------------------------------------------------------------------------
AC_CHECK_LIB([gfortran], [_gfortran_st_write], [], [])

if test "$ac_cv_lib_gfortran__gfortran_st_write" != "yes"; then
	echo ''
	AC_MSG_WARN([Critial Package Missing, "gfortran". Please install to continue.])
	echo ''
	exit 1
else
	HAVE_GFORTRAN=1
	FC=gfortran
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


# ------------------------------------------------------------------------------
#  substitutions
# ------------------------------------------------------------------------------
AC_SUBST([PREFIX], ["$prefix"])
AC_SUBST([BUGS], ["$PACKAGE_BUGREPORT"])
AC_SUBST([PROGRAM], ["$PACKAGE_NAME"])
AC_SUBST([VERSION], ["$PACKAGE_VERSION"])
AC_SUBST([WEB], ["$PACKAGE_URL"])
AC_SUBST([SHARED], ["$PREFIX"/share/kvasd-installer])
AC_SUBST([BINDIR], ["$PREFIX"/bin])
AC_SUBST([HOMEDIR], [/home/"$USER"/.local/share/.kvasd-installer])
AC_SUBST([USER], ["$USER"])
AC_CONFIG_FILES([Makefile])
AC_OUTPUT


# ------------------------------------------------------------------------------
#  configure summary
# ------------------------------------------------------------------------------
echo ''
echo "-------------------------------------------"
echo " Configuration Summary"
echo "-------------------------------------------"
echo ''
echo " Package: .........: ${PROGRAM} ${VERSION}"
echo " Install prefix ...: ${PREFIX}"
echo " Canonical name ...: ${_NAME}"
echo " Name of OS .......: ${_OS}"
echo " Name of CPU ......: ${_CPU}"
echo " Name of Vendor ...: ${_VENDOR}"
echo " Website ..........: ${WEB}"
echo " Report Bugs To ...: ${BUGS}"
echo ''
echo " To Build $PROGRAM, type:  make"
echo ''
echo ''

