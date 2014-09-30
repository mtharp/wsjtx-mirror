#!/usr/bin/env bash
#
# Description: Simplified build script for WSJT-X
#
# USAGE: ./wsjtx-build.sh $1
# Example: ./wsjtx-build.sh rc
#
# exit on error
set -e
_SELECTION=$1

if [ "$_SELECTION" == "rc" ];
then
	# RELEASE CANDIDATE BRANCH
	_WSJTXURL="https://svn.code.sf.net/p/wsjt/wsjt/branches/wsjtx-1.4"
	_APP_SRC_NAME="wsjtx-1.4"
	_APP_NAME="wsjtx-1.4.0"
else 
	# HEAD OF DEVELOPMENT BRANCH
	_WSJTXURL="https://svn.code.sf.net/p/wsjt/wsjt/branches/wsjtx"
	_APP_SRC_NAME="wsjtx"
	_APP_NAME="wsjtx-dev"
fi

# other paths and vars
_OPTION=Release
_HAMLIBURL="git://git.code.sf.net/u/bsomervi/hamlib"
_BASED=$(exec pwd)
_BUILDD="$_BASED/$_APP_NAME/build/$_OPTION"
_INSTALLD="$_BASED/$_APP_NAME/install/$_OPTION"
_SRCD="$_BASED/$_APP_NAME/src"
_G4WJS_GIT="$_BASED/$_APP_NAME/src/g4wjs-hamlib"
_G4WJS_HAMLIB_BUILD="$_BASED/$_APP_NAME/src/build"
_G4WJS_HAMLIB3="$_BASED/$_APP_NAME/hamlib3"

# make the dir's
mkdir -p "$_BASED/$_APP_NAME"/{build/"$_OPTION",install/"$_OPTION",src/build}

# exit on non "0" status
function exit_status()
if [ "$?" != "0" ]
then
	exit 1
fi

# simple hamlib test
function hamlib_test() {

_TEST=$($_G4WJS_HAMLIB3/bin/rigctl -m1 f)
	
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

# ensure build and runtime deps are installed.
echo
echo '-------------------------------------------'
echo ' INSTALLING BUILD AND RUNTIME DEPS'
echo '-------------------------------------------'
echo

# look for prevous install marker
if [ ! -f ./dep.mkr ];
then
	# install deps
	sudo apt-get -y -q install --reinstall --no-install-recommends \
	cmake clang-3.5 gfortran libfftw3-dev git libgfortran3:i386 libusb-dev \
	autoconf libtool texinfo qt5-default qtmultimedia5-dev \
	libqt5multimedia5-plugins libhamlib2 libhamlib-utils

	exit_status
	touch ./dep.mkr
	sudo -k
else
	echo ".. Previous Dep Install marker found, moving to Hamlib3 Build"
fi

# clone G4WJS hamlib3
echo
echo '-------------------------------------------'
echo ' GIT CLONE G4WJS HAMLIB v3.0'
echo '-------------------------------------------'
echo

cd $_SRCD
if [ -f "$_G4WJS_GIT/autogen.sh" ]
then
	cd "$_G4WJS_GIT"
	git pull
	exit_status
	git checkout integration
	exit_status
else
	git clone "$_HAMLIBURL" g4wjs-hamlib
	exit_status
	cd $_G4WJS_GIT
	git checkout integration
	exit_status
fi

# clone G4WJS hamlib3
echo
echo '-------------------------------------------'
echo ' CONFIGURE HAMLIB v3.0'
echo '-------------------------------------------'
echo

cd $_G4WJS_HAMLIB_BUILD
$_G4WJS_GIT/autogen.sh --prefix="$_G4WJS_HAMLIB3" \
--disable-winradio --without-cxx-binding \
--disable-shared --enable-static  \
CFLAGS="-fdata-sections -ffunction-sections" \
LDFLAGS="-s -Wl,--gc-sections"
exit_status

# run make file
echo
echo '-------------------------------------------'
echo ' RUN MAKE'
echo '-------------------------------------------'
echo
make -s
exit_status

# make install
echo
echo '-------------------------------------------'
echo ' INSTALL HAMLIB'
echo '-------------------------------------------'
echo
make -s install
exit_status

# run hamlib test
echo
echo '-------------------------------------------'
echo ' RUN SIMPLE HAMLIB TEST'
echo '-------------------------------------------'
echo
hamlib_test

# checkout WSJT-X from WSJT SVN
echo
echo '-------------------------------------------'
echo ' CHECKOUT WSJT-X'
echo '-------------------------------------------'
echo
cd "$_SRCD"
if [ -d "./.svn" ]
then
	svn cleanup && svn update
else
	svn checkout "$_WSJTXURL"
fi
exit_status

# configure build tree
echo
echo '-------------------------------------------'
echo ' CONFIGURE WSJT-X BUILD TREE'
echo '-------------------------------------------'
echo
cd $_BUILDD
cmake -D CMAKE_PREFIX_PATH:PATH="$_G4WJS_HAMLIB3" \
-D WSJT_SKIP_MANPAGES=ON \
-D CMAKE_BUILD_TYPE="$_OPTION" \
-D CMAKE_INSTALL_PREFIX="$_INSTALLD" "$_SRCD/$_APP_SRC_NAME"
exit_status

# build install release install target
echo
echo '-------------------------------------------'
echo " BUILDING ( $_APP_NAME )"
echo '-------------------------------------------'
echo
cd "$_BUILDD"
cmake --build . --target install --clean-first
exit_status

# Finished
echo
echo '-------------------------------------------'
echo " FINISHED BUILDING ( $_APP_NAME )"
echo '-------------------------------------------'
echo
echo "If we got this far, things are probably ok"
echo
echo "To Run ......: $_APP_NAME"
echo " ............: cd  $_INSTALLD/bin"
echo "Then type ...: ./wsjtx"
echo
echo
exit 0
