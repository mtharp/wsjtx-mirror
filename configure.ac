# ------------------------------------------------------------------------------
# Process this file with autoconf to create configure. -*- autoconf -*-
# ------------------------------------------------------------------------------
AC_PREREQ([2.65])
AC_INIT([KVASD Installer],[1.12],[wsjt-devel@lists.sourceforge.net],[],
[http://physics.princeton.edu/pulsar/k1jt/devel.html])
AC_CONFIG_AUX_DIR([build-aux])
AUTHORS="Greg Beam, Joseph H Taylor, and others"
COPYRIGHT="Copyright (C) 2014-2015 Joseph H Taylor, Jr, K1JT"
LICENSE='GPL-3'

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
HOMEDIR="/home/$LOGNAME/.local/share/kvasd-installer"

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
AC_PATH_PROG([AWK], [awk])
AC_PATH_PROG([CP], [cp])
AC_PATH_PROG([INSTALL], [install])
AC_PATH_PROG([MAKE], [make])
AC_PATH_PROG([MKDIR], [mkdir])
AC_PATH_PROG([MV], [mv])
AC_PATH_PROG([RM], [rm])
AC_PATH_PROG([SED], [sed])
AC_PATH_PROG([SHELL], [bash])
AC_PATH_PROG([TOUCH], [touch])
AC_PATH_PROG([TEE], [tee])

# ------------------------------------------------------------------------------
#  check for dialog installation
# ------------------------------------------------------------------------------
AC_CHECK_PROG([DIALOG], [dialog], [yes], [no])
if test "$DIALOG" = no ; then
	echo ''
	AC_MSG_WARN([Critial Package Missing])
	echo ''
	echo 'The package ( Dialog ) is required to run kvasd-installer.'
	echo 'Possible solutions are:'
	echo ''
	echo ' [1] Use your package manager to search for dialog'
	echo ' [2] Review this link for additional options:'
	echo '     URL: http://invisible-island.net/dialog/dialog.html'
	echo ''
	exit 1
fi

# generate pkg-info.txt file
if test -f ./pkg-info.txt ; then rm -f ./pkg-info.txt ; fi
touch ./pkg-info.txt 
PKGINFO='./pkg-info.txt'

# ------------------------------------------------------------------------------
#  substitutions
# ------------------------------------------------------------------------------
AC_SUBST([PREFIX], ["$prefix"])
AC_SUBST([BUGS], ["$PACKAGE_BUGREPORT"])
AC_SUBST([PROGRAM], ["$PACKAGE_NAME"])
AC_SUBST([VERSION], ["$PACKAGE_VERSION"])
AC_SUBST([LICENSE], ["$LICENSE"])
AC_SUBST([AUTHORS], ["$AUTHORS"])
AC_SUBST([COPYRIGHT], ["$COPYRIGHT"])
AC_SUBST([WEB], ["$PACKAGE_URL"])
AC_SUBST([SHARED], ["$PREFIX"/share/kvasd-installer])
AC_SUBST([BINDIR], ["$PREFIX"/bin])
AC_SUBST([HOMEDIR], [/home/"$USER"/.local/share/kvasd-installer])
AC_SUBST([USER], ["$USER"])
AC_CONFIG_FILES([Makefile
kvasd-installer
])
AC_OUTPUT

# ------------------------------------------------------------------------------
#  configure summary
# ------------------------------------------------------------------------------
echo ''
echo "-------------------------------------------"
echo " Configuration Summary"
echo "-------------------------------------------"
echo ''
echo " Program ...........: ${PROGRAM} ${VERSION}" |tee -a "$PKGINFO"
echo " Version ...........: ${VERSION}" |tee -a "$PKGINFO"
echo " OS ................: ${_OS}" |tee -a "$PKGINFO"
echo " CPU ...............: ${_CPU}" |tee -a "$PKGINFO"
echo " Copyright .........: $COPYRIGHT" |tee -a "$PKGINFO"
echo " Authors ...........: $AUTHORS" |tee -a "$PKGINFO"
echo " License ...........: $LICENSE" |tee -a "$PKGINFO"
echo " Website ...........: ${WEB}" |tee -a "$PKGINFO"
echo " Report Bugs To ....: ${BUGS}" |tee -a "$PKGINFO"
echo ''
echo " Instal Prefix .....: ${PREFIX}"
echo ' To Install, type ..: sudo make install'
echo ''
echo ''
