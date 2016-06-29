AC_DEFUN([AC_PYFMT_PORTAUDIO], [
HAVE_PORTAUDIO=0
#
# This unpleasant hack due to FreeBSD supporting both portaudio2 (v19+)
# and older portaudio. Many programs depend on older. Sorry :-( - db
#
case "${host_os}" in
	*freebsd* )
	AC_SUBST([PORTAUDIO_INCLUDE], ["-I/usr/local/include/portaudio2"])
	AC_SUBST([PORTAUDIO_LIBDIR], ["-L/usr/local/lib/portaudio2"])
	LDFLAGS="-L/usr/local/lib/portaudio2 ${LDFLAGS}"
	;;
	*)
	;;
esac

AC_CHECK_LIB([portaudio], [Pa_Initialize], [], [])
if test "$ac_cv_lib_portaudio_Pa_Initialize" = "yes"; then
		LIBS="-lportaudio ${LIBS}"
fi

# if headers and libs found, set define
if test "$ac_cv_header_portaudio_h" = "yes" -a "$ac_cv_lib_portaudio_Pa_Initialize" = "yes"; then
	HAVE_PORTAUDIO=1
	AC_DEFINE([HAVE_PORTAUDIO_H], [1], [Portaudio Header])
	AC_DEFINE([HAVE_PORTAUDIO_LIB], [1], [Portaudio Lib])
fi

#
# Ensure FreeBSD picks up the right portaudio -db
#
case "${host_os}" in
	*freebsd* )
	AC_SUBST([PORTAUDIO_INCLUDE], ["-I/usr/local/include/portaudio2"])
	AC_SUBST([PORTAUDIO_LIBDIR], ["-L/usr/local/lib/portaudio2"])
	LDFLAGS="-L/usr/local/lib/portaudio2 ${LDFLAGS}"
	;;
	*)
	;;
esac

])
