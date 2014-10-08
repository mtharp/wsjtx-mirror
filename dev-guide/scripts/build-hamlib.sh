#!/bin/bash

# G4WJS Hamlib3 Build for JTSDK-QT using MSYS/MSYS2
# 
# Requirements: MSYS Env, Autotools, Git, Bash
#               Qt5 Toolchain ( 5.2.1 tested with C/C++ 4.8.0 )

# MSYS includes: Git, SVN, Autotools, Bash, Make and many GNU Tools
# MSYS Link: http://sourceforge.net/projects/mingwbuilds/files/external-binary-packages/
# PACKAGE: msys+7za+wget+svn+git+mercurial+cvs-rev13.7z 2013-05-15

# Exit on errors
set -e

# Date, build and tool-chain paths
today=$(date +"%d-%b-%y"-"%H%M")
PATH="/c/JTSDK-QT/qt5/Tools/mingw48_32/bin:$PATH"
mkdir -p ~/g4wjs-hamlib/build

# For JTSDK-QT use, this should remain as is. If you change this path,
# also update jtsdk.toolchain.cmake file to match the new location.
INSTALLPREFIX=C:/JTSDK-QT/hamlib3/mingw32

# Simple exit on error function
function exit_status() {

	if [[ $? != 0 ]];
	then
		exit 1
	fi
}

echo
echo '----------------------------------------------------------------'
echo '  CLONE G4WJS HAMLIB3 & CHECKOUT INTEGRATION'
echo '----------------------------------------------------------------'
echo
echo ".. Be patient, this can take a few minutes"
echo 

if [[ -f ~/g4wjs-hamlib/src/autogen.sh ]];
then
	cd ~/g4wjs-hamlib/src
	git pull
	git checkout integration
	exit_status
else
	cd ~/g4wjs-hamlib
	if [ -d ~/g4wjs-hamlib/src ]; then rm -rf ~/g4wjs-hamlib/src ; fi
	git clone git://git.code.sf.net/u/bsomervi/hamlib src
	exit_status
	cd ~/g4wjs-hamlib/src
	git checkout integration
	exit_status
fi

echo
echo '----------------------------------------------------------------'
echo '  RUN AUTOGEN TO CONFIGURE THE BUILD'
echo '----------------------------------------------------------------'
echo
echo '.. Be patient, this can take a few minutes'
echo

# Running autogen.sh to configure the build. No need to run configure
# as autogen.sh accepts $@

cd ~/g4wjs-hamlib/build
../src/autogen.sh --prefix="$INSTALLPREFIX" \
--disable-shared --enable-static \
--without-cxx-binding --disable-winradio \
CC=C:/JTSDK-QT/qt5/Tools/mingw48_32/bin/gcc \
CXX=C:/JTSDK-QT/qt5/Tools/mingw48_32/bin/g++ \
CFLAGS="-fdata-sections -ffunction-sections" \
LDFLAGS="-s -Wl,--gc-sections"
exit_status

# Make clean check
if [[ -f ~/g4wjs-hamlib/build/tests/rigctld.exe ]];
then
	echo
	echo '----------------------------------------------------------------'
	echo '  RUNNING MAKE CLEAN'
	echo '----------------------------------------------------------------'
	echo
	make -s clean
fi

# Run Make
echo
echo '----------------------------------------------------------------'
echo '  RUNNING MAKE'
echo '----------------------------------------------------------------'
echo
make -s
exit_status

# Run Make Install
echo
echo '----------------------------------------------------------------'
echo '  INSTALLING HAMLIB3'
echo '----------------------------------------------------------------'
echo

make -s install-strip
exit_status
touch C:/JTSDK-QT/hamlib3/build-date-$today
exit_status

echo
echo '----------------------------------------------------------------'
echo '  FINISHED HAMLIB3 BUILD'
echo '----------------------------------------------------------------'
echo 
echo "Install Location: $INSTALLPREFIX"
echo

exit 0
