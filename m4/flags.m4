AC_DEFUN([AC_PYFMT_FLAGS], [
_LBU=$(echo "-lpthread $LIBS" |tr ' ' '\n'|sort -su |tr '\n' ' ')
LIBS="$_LBU"

_LDU=$(echo "$LIBDIR" |tr ' ' '\n'|sort -su |tr '\n' ' ')
LIBDIR="$_LDU"

_CPPU=$(echo "-I/usr/include -I/usr/local/include $CPPFLAGS" |tr ' ' '\n'|sort -su |tr '\n' ' ')
CPPFLAGS="$_CPPU"

case "${host_os}" in
	*linux* )
		FCOPT="-cpp -fbounds-check -O2"
			case "${host_cpu}" in
				*armv6* )
					CFLAGS="-O2 -march=armv6j -mfpu=vfp -mfloat-abi=hard -fpic"
					FFLAGS="-O2 -Wall -fno-range-check -ffixed-line-length-none \
-Wno-character-truncation -Wno-conversion -Wtabs -mfloat-abi=hard -fPIC"
				;;
				*armv7* )
					CFLAGS="-mabi=aapcs-linux -mtune=cortex-a7 -march=armv7-a -mfpu=vfp -fpic"
					FFLAGS="-O2 -Wall -fbounds-check -fno-second-underscore \
-Wno-conversion -Wno-character-truncation -fPIC"
				;;
				*x86_64* )
					CFLAGS="-fPIC"
					FFLAGS="-O2 -Wall -fbounds-check -fno-second-underscore \
-Wno-conversion -Wno-character-truncation -fPIC"
				;;
				*i386* )
					CFLAGS="-fPIC"
					FFLAGS="-O2 -Wall -fbounds-check -fno-second-underscore \
-Wno-conversion -Wno-character-truncation -fPIC"
				;;
				*powerpc* )
					CFLAGS="-fPIE"
					FFLAGS="-O2 -Wall -fbounds-check -fno-second-underscore \
-Wno-conversion -Wno-character-truncation -fPIE"
				;;
			esac
	;;
	*darwin* )
		FCOPT="-cpp -fbounds-check -O2"
		CFLAGS="-Wall -O0 -fPIC -m64"
		FFLAGS="-O2 -m64 -Wall -fbounds-check -fno-second-underscore \
-Wno-conversion -Wno-character-truncation -fPIC"
	;;
	*freebsd* )
		CFLAGS="${CFLAGS} -fpic"
		FFLAGS="-O2 -m64 -Wall -fbounds-check -fno-second-underscore \
-Wno-conversion -Wno-character-truncation -fPIC"
	;;
	*)
		AC_MSG_ERROR([Unsupported System: ${host_os}.])
	;;
esac

])
