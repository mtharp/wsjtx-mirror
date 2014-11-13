#!/bin/bash
#
# Title			: build-hamlib.sh
# Version		: 1.0.0
# Description	: Build Hammlib3 from source
# Project URL	: Git: git://git.code.sf.net/u/bsomervi/hamlib
# Usage			: ./build-hamlib.sh
#
# Author		: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
# Copyright		: Copyright (C) 2014 Joe Taylor, K1JT
# License		: GPL-3
#
# build-hamlib.sh is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation either version 3 of the
# License, or (at your option) any later version. 
#
# build-hamlib.sh is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#--------------------------------------------------------------------#

######################################################################
#
# BUILD COMMENTS
#
# G4WJS Hamlib3 Build for JTSDK-QT using MSYS + Qt5 5.2.1 Tool-Chain
# 
# Requirements: MSYS, Autotools, Git, Bash
#               Qt5 Toolchain ( 5.2.1 tested with C/C++ 4.8.0 )
#
# MSYS includes: Git, SVN, Autotools, Bash, Make and many GNU Tools
# MSYS Link: http://sourceforge.net/projects/mingwbuilds/files/external-binary-packages/
# PACKAGE: msys+7za+wget+svn+git+mercurial+cvs-rev13.7z 2013-05-15
#
# To get changes / comits made from a previous date to today, in the 
# shell type, ( changing --since=<date> as needed )
#
# mkdir -p ~/g4wjs-hamlib/build
# git clone git://git.code.sf.net/u/bsomervi/hamlib src
# cd ~/g4wjs-hamlib/src
# git checkout integration
#
# Example-1:
# cd ~/g4wjs/src ; git log --since=1.weeks
#
# Example-2:
# git log --since=2014-04-29 --no-merges --oneline origin/integration 
#
# To create a build log:
# ./build-hamlib.sh |tee -a ~/hamlib3-build-$(date +"%d-%m-%Y").log
#
######################################################################

# Exit on errors
set -e

# General use Vars and colour
PKG_NAME=Hamlib3
today=$(date +"%d-%m-%Y")

# Foreground colours
C_R='\033[01;31m'		# red
C_G='\033[01;32m'		# green
C_Y='\033[01;33m'		# yellow
C_C='\033[01;36m'		# cyan
C_NC='\033[01;37m'		# no color

# Tool-Chain Variables - Adjust to suit your QT5 Tool-Chain Locations
export PATH="/c/JTSDK-QT/qt5/Tools/mingw48_32/bin:$PATH"
TC="C:/JTSDK-QT/qt5/Tools/mingw48_32/bin"

# For JTSDK-QT
PREFIX="C:/JTSDK-QT/hamlib3/mingw32"

# Function -----------------------------------------------------------
tool_check() {
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y}' CHECKING TOOL-CHAIN'${C_NC}
echo '---------------------------------------------------------------'

# Setup array and perform simple version checks
echo ''
array=( 'ar' 'nm' 'ld' 'gcc' 'g++' 'ranlib' )

for i in "${array[@]}"
do
	"$i" --version >/dev/null 2>&1
	
	if [ $? != 0 ];
	then 
		echo -en " $i check" && echo -e ${C_R}' FAILED'${C_NC}
		echo ''
		echo ' If you have not sourced one of the two options, try'
		echo ' that first, otherwise set you path correctly:'
		echo ''
		echo ' [ 1 ] For the QT5 Tool Chain type, ..: source-qt5'
		echo ' [ 2 ] For MinGW Tool-Chain, type ....: source-mingw32'
		echo ''
		exit 1
	else
		echo -en " $i .." && echo -e ${C_G}' OK'${C_NC}
	fi
done

echo -e ' Compiler ver .. '${C_G}"$(gcc --version |awk 'FNR==1')"${C_NC}
echo -e ' Binutils ver .. '${C_G}"$(ranlib --version |awk 'FNR==1')"${C_NC}
echo -e ' Libtool ver ... '${C_G}"$(libtool --version |awk 'FNR==1')"${C_NC}
echo -e ' Pkg-Config  ... '${C_G}"$(pkg-config --version)"${C_NC}

}
# End Function -------------------------------------------------------

# Run Tool Check
clsb
tool_check

if [ "$?" = "0" ];
then
echo -en " TC Path ......." && echo -e ${C_G}" $TC"${C_NC}
echo -en " TC Status ....."&& echo -e ${C_G}' OK'${C_NC}
	echo ''
else
	echo ''
	echo -e ${C_R}"TOOL CHAIN WARNING"${C_NC}
	echo 'There was a problem with the Tool-Chain.'
	echo "$0 Will now exit .."
	exit ''
	exit 1
fi

# Start Git clone
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} ' CLONE G4WJS HAMLIB3'${C_NC}
echo '---------------------------------------------------------------'
echo ''

cd $HOME
mkdir -p ~/g4wjs-hamlib/build
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

# Run configure
cd ~/g4wjs-hamlib/build
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} ' CONFIGURE THE BUILD'${C_NC}
echo '---------------------------------------------------------------'
echo ''
echo '.. This may take a several minutes to complete'

if [ "$1" = "shared" ];
then
# Build shared
echo -en ".. Build Type: " && echo -e ${C_G}'Shared'${C_NC}
echo ''
../src/autogen.sh --prefix=$PREFIX \
	--enable-shared \
	--disable-static \
	--disable-winradio \
	--without-cxx-binding \
	CC=$TC/gcc.exe \
	CXX=$TC/g++.exe \
	CFLAGS='-fdata-sections -ffunction-sections' \
	LDFLAGS='-Wl,--gc-sections'

else

# Build Static ( default )
echo -en ".. Build Type: " && echo -e ${C_G}'Static'${C_NC}
echo ''
../src/autogen.sh --prefix=$PREFIX \
	--disable-shared \
	--enable-static \
	--disable-winradio \
	--without-cxx-binding \
	CC=$TC/gcc.exe \
	CXX=$TC/g++.exe \
	CFLAGS='-fdata-sections -ffunction-sections' \
	LDFLAGS='-Wl,--gc-sections'

fi

# Make clean check
if [ -f "~/g4wjs-hamlib/build/tests/rigctld.exe" ];
then
	echo ''
	echo '---------------------------------------------------------------'
	echo -e ${C_Y} ' RUNNING MAKE CLEAN'${C_NC}
	echo '---------------------------------------------------------------'
	echo ''
	make clean
fi

# Run make
echo ''
echo '----------------------------------------------------------------'
echo -e ${C_Y} ' RUNNING MAKE ALL'${C_NC}
echo '----------------------------------------------------------------'
echo ''
make

# Run make install-strip
echo ''
echo '----------------------------------------------------------------'
echo -e ${C_Y} ' INSTALLING HAMLIB3'${C_NC}
echo '----------------------------------------------------------------'
echo ''
make install-strip

# Finished
if [ "$?" = "0" ];
then
	echo ''
	echo '----------------------------------------------------------------'
	echo -e ${C_G} '  FINISHED HAMLIB3 BUILD'${C_NC}
	echo '----------------------------------------------------------------'
	echo ''
	touch C:/JTSDK-QT/hamlib3/build-date-$today
	echo "Install Location: $PREFIX"
	echo ''
	exit 0
else
	echo -e ${C_G} 'BUILD ERRORS OCCURED'${C_NC}
	echo "Check the screen and correct errors"
	echo ''
	echo "Exiting [ $0 ] with Status [ 1 ]"
	echo ''
	exit 1
fi
