#!/bin/bash

# G4WJS Hamlib3 Build for JTSDK-QT using MSYS/MSYS2
# 
# Requirements: MSYS Env, Autotools, Git, Bash
#               Qt5 Toolchain ( 5.2.1 tested with C/C++ 4.8.0 )

# MSYS2 includes: Git, SVN, Hg, Autotools, Bash, Make and many GNU Tools
# MSYS2 Link: http://hivelocity.dl.sourceforge.net/project/mingwbuilds/external-binary-packages/msys%2B7za%2Bwget%2Bsvn%2Bgit%2Bmercurial%2Bcvs-rev13.7z

# Exit on errors
set -e

# Date an create build directory
today=$(date +"%m-%d-%y")
mkdir -p ~/g4wjs-hamlib/build

# Path to Compilers & Binutils, in JTSDK-QT
# If you change the path, check the autogen section to ensure each
# item can be found, otherwise you may get errors.
TOOLS="C:/JTSDK-QT/qt5/Tools/mingw48_32/bin"

# For JTSDK-QT use, this should remain as is. If you change this path,
# also update jtsdk.toolchain.cmake file to match the new location.
INSTALLPREFIX="C:/JTSDK-QT/hamlib3/mingw32"

# Simple exit on error function
function exit_status() {

	if [ "$?" != "0" ];
	then
		exit 1
	fi
}

echo ''
echo '----------------------------------------------------------------'
echo '  CLONE G4WJS HAMLIB3 & CHECKOUT INTEGRATION'
echo '----------------------------------------------------------------'
echo ''
echo '.. Be patient, this can take a few minutes'
echo ''

# Note: Rather than perform a full download each run, the script
# deletes the build directory instead. If autogeh.sh exists, it will
# perform a pull & integration rather than clone & integration

if [ -f ~/g4wjs-hamlib/src/autogen.sh ];
then
	cd ~/g4wjs-hamlib/src
	git pull
	git checkout integration
else
	cd ~/g4wjs-hamlib
	git clone git://git.code.sf.net/u/bsomervi/hamlib src
	exit_status
	cd ~/g4wjs-hamlib/src
	git checkout integration
	exit_status
fi

echo ''
echo '----------------------------------------------------------------'
echo '  RUN AUTOGEN TO CONFIGURE THE BUILD'
echo '----------------------------------------------------------------'
echo ''
echo '.. Be patient, this can take a few minutes'
echo ''

# Running autogen.sh to configure the build. No need to run configure
# as autogen.sh accepts $@

# Note: It *may not* be necessary to set each of the Binutil items, but
# to ensure the build uses the same binary set as the compilers,
# each has been set in the autogen.sh invocation

cd ~/g4wjs-hamlib/build
../src/autogen.sh --prefix="$INSTALLPREFIX" \
--disable-shared --enable-static \
--without-cxx-binding --disable-winradio \
CC=C:/JTSDK-QT/qt5/Tools/mingw48_32/bin/gcc \
CXX=C:/JTSDK-QT/qt5/Tools/mingw48_32/bin/g++ \
CFLAGS="-fdata-sections -ffunction-sections" \
LDFLAGS="-s -Wl,--gc-sections" \
ADDR2LINE=$TOOLS/addr2line AR=$TOOLS/ar DLLTOOL=$TOOLS/dlltool \
DLLWRAP=$TOOLS/dllwrap GPROF=$TOOLS/gprog GDB=$TOOLS/gdb LD=$TOOLS/ld \
NM=$TOOLS/nm OBJCOPY=$TOOLS/objcopy OBJDUMP=$TOOLS/objdump \
RANLIB=$TOOLS/ranlib READELF=$TOOLS/readelf SIZE=$TOOLS/size S\
TRIP=$TOOLS/strip STRINGS=$TOOLS/strings WINDRES=$TOOLS/windres \
WINDMC=$TOOLS/windmc
exit_status

# Make clean check
if [ -f ~/g4wjs-hamlib/build/tests/rigctld.exe ];
then
	echo ''
	echo '----------------------------------------------------------------'
	echo '  RUNNING MAKE CLEAN'
	echo '----------------------------------------------------------------'
	echo ''
	make -s clean
fi

# Run Make
echo ''
echo '----------------------------------------------------------------'
echo '  RUNNING MAKE'
echo '----------------------------------------------------------------'
echo ''
make -s
exit_status

# Note: If you use the JTSDJ-DOC update method, do not remove the
# build-date-$today file from JTSDK-QT\hamlib3 directory, otherwise,
# the update script will overwrite your latest changes with that which
# resides in SVN. Instead, make a backup of the hamlib3 directory
# before hand, then reinstate it after testing a new Halib3 build
# if your concerned about loosing the original build.

# Run Make Install
echo ''
echo '----------------------------------------------------------------'
echo '  INSTALLING HAMLIB3'
echo '----------------------------------------------------------------'
echo ''

make -s install
exit_status
touch C:/JTSDK-QT/hamlib3/build-date-$today
exit_status

echo ''
echo '----------------------------------------------------------------'
echo '  FINISHED HAMLIB3 BUILD'
echo '----------------------------------------------------------------'
echo ''
echo "Install Location: $INSTALLPREFIX"
echo ''

exit 0
