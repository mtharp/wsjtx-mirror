#!/bin/bash

# G4WJS Hamlib3 Build for JTSDK-QT using MSYS + Qt5 5.2.1 Too-Chain
# 
# Requirements: MSYS, Autotools, Git, Bash
#               Qt5 Toolchain ( 5.2.1 tested with C/C++ 4.8.0 )

# MSYS includes: Git, SVN, Autotools, Bash, Make and many GNU Tools
# MSYS Link: http://sourceforge.net/projects/mingwbuilds/files/external-binary-packages/
# PACKAGE: msys+7za+wget+svn+git+mercurial+cvs-rev13.7z 2013-05-15

# To get get the changes made from a previous date to today, in the 
# shell type, ( changing --since=<date> as needed )
#
# mkdir -p ~/g4wjs-hamlib/build
# git clone git://git.code.sf.net/u/bsomervi/hamlib src
# cd ~/g4wjs-hamlib/src
# git checkout integration
# git log --since=2014-04-29 --no-merges --oneline origin/integration 
#
# To create a build log:
# ./build-hamlib.sh |tee -a ~/hamlib-build-$($(date +"%d-%m-%Y").log
#

# Exit on errors
set -e

# Date, build and tool-chain paths
today=$(date +"%d-%m-%Y")
PATH="/c/JTSDK-QT/qt5/Tools/mingw48_32/bin:$PATH"
mkdir -p ~/g4wjs-hamlib/build

# For JTSDK-QT use, this should remain as is. If you change this path,
# also update jtsdk.toolchain.cmake file to match the new location.
INSTALLPREFIX=C:/JTSDK-QT/hamlib3/mingw32

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
else
	cd ~/g4wjs-hamlib
	if [ -d ~/g4wjs-hamlib/src ]; then rm -rf ~/g4wjs-hamlib/src ; fi
	git clone git://git.code.sf.net/u/bsomervi/hamlib src
	cd ~/g4wjs-hamlib/src
	git checkout integration
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
../src/autogen.sh --prefix=$INSTALLPREFIX \
--disable-shared --enable-static \
--without-cxx-binding --disable-winradio \
CC='C:/JTSDK-QT/qt5/Tools/mingw48_32/bin/gcc.exe' \
CXX='C:/JTSDK-QT/qt5/Tools/mingw48_32/bin/g++.exe' \
CFLAGS='-fdata-sections -ffunction-sections' \
LDFLAGS='-Wl,--gc-sections'

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

# Run Make Install
echo
echo '----------------------------------------------------------------'
echo '  INSTALLING HAMLIB3'
echo '----------------------------------------------------------------'
echo
make -s install-strip
touch C:/JTSDK-QT/hamlib3/build-date-$today

echo
echo '----------------------------------------------------------------'
echo '  FINISHED HAMLIB3 BUILD'
echo '----------------------------------------------------------------'
echo 
echo "Install Location: $INSTALLPREFIX"
echo

exit 0
