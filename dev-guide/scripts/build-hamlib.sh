#!/bin/bash

# G4WJS Hamlib3 Build for JTSDK-QT using MSYS2
# 
# Reuirments: MSYS Env, Autotools, Automake, Git, Bash
#             Qt5 Toolchain ( 5.2.1 tested )
# MSYS2 includes: Git, SVN, Hg, Autotools, Bash and many more GNU Tools
# MSYS2 Link: http://hivelocity.dl.sourceforge.net/project/mingwbuilds/external-binary-packages/msys%2B7za%2Bwget%2Bsvn%2Bgit%2Bmercurial%2Bcvs-rev13.7z

# exit on errors
set -e

# date an original path variables
today=$(date +"%m-%d-%y")
OLDPATH=$PATH

# This should remain as is, unless you have a custom build you want 
# test. If so, also check the integration setup after cloning
# to ensure you are pulling what you are expecting to pull.
HAMLIBURL='git://git.code.sf.net/u/bsomervi/hamlib'

# For JTSDK-QT, this should remain as is. If you change this path,
# also update jtsdk.toolchain.cmake file to match
INSTALLPREFIX="C:/JTSDK-QT/hamlib3/mingw32"

# Edit paths to suit environment, however, care should be taken to 
# ensure you *do not* use any MSYS compilers from your environment
# as the binaries need to be built using the Qt5 ToolChan. To be safe,
# add only what is necessary. The original path is preserved with
# $OLDPATH and reset at the end of the script and after any exit 1 status
PATH=".:/d/msys32/msys/bin:/c/JTSDK-QT/qt5/Tools/mingw48_32/bin"

# simple exit on error function
function exit_status() {

	if [ "$?" != "0" ];
	then
		PATH=$OLDPATH
		exit 1
	fi
}

# simple hamlib test
function hamlib_test() {

_TEST=$(./tests/rigctl -m1 f)
	
	if [ "$_TEST" == "145000000" ]
	then
		echo " Rig Control ......: OK"
		echo ' Tested With ......: rigctl -m1 f'
		echo ' Expected Result ..: 145000000'
		echo " Returned Result ..: $_TEST"

	else
		echo "Rig Controll .. FAILED"
		echo "Check the build script for possible errors"
		echo 
		read -p "Press [Enter] to continue ..."
		exit_status
	fi
}

echo ''
echo '----------------------------------------------------------------'
echo '  BUILDING G4WJS HAMLIB3 WITH INTEGRATION'
echo '----------------------------------------------------------------'
echo ''

# this does not try to do a Git pull, rather, it removes, then
# downlodas & sets integration each run
if [ -d ~/g4wjs-hamlib ];
then
	rm -rf ~/g4wjs-hamlib
fi

mkdir -p ~/g4wjs-hamlib/build
cd ~/g4wjs-hamlib

echo ''
echo '----------------------------------------------------------------'
echo '  CLONE HAMLIB & CHECKOUT INTEGRATION'
echo '----------------------------------------------------------------'
echo ''
echo '.. Be patient, this can take a few minutes'
echo ''
git clone $HAMLIBURL src
exit_status
cd src
git checkout integration
exit_status

echo ''
echo '----------------------------------------------------------------'
echo '  RUN AUTOGEN TO CONFIGURE THE BUILD'
echo '----------------------------------------------------------------'
echo ''

# running autogen.sh to configure the build, no need to run configure
# a second time as autogen.sh accepts $@
cd ../build
../src/autogen.sh --prefix="$INSTALLPREFIX" \
--disable-shared --enable-static \
--without-cxx-binding --disable-winradio \
CC=C:/JTSDK-QT/qt5/Tools/mingw48_32/bin/gcc \
CXX=C:/JTSDK-QT/qt5/Tools/mingw48_32/bin/g++ \
CFLAGS="-fdata-sections -ffunction-sections" \
LDFLAGS="-s -Wl,--gc-sections"
exit_status

echo ''
echo '----------------------------------------------------------------'
echo '  RUN MAKE and INSTALL'
echo '----------------------------------------------------------------'
echo ''

# remove comment "#" to build in parallel and comment out the second line.
# care should be taken when using parallel builds on Windows as it's
# not 100% proven.
# mingw32-make -s -j6
mingw32-make -s
exit_status

# perform simple rigcltd.exe test before installing. the function will
# exit the script is the expected results do not match the test.
hamlib_test

# Note: If you use the JTSDJ-DOC update method, do not remove the
# build-date-$today file from JTSDK-QT\hamlib3 directory, otherwise, the update
# script will overwrite your latest changes with that which resides in SVN.
# or make a backup of the hamlib3 directory before hand, then reinstate it
# after testing a new Halib3 build.
mingw32-make install
exit_status

echo ''
echo '----------------------------------------------------------------'
echo '  SET BUILD MARKER'
echo '----------------------------------------------------------------'
echo ''
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