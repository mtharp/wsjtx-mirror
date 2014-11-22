#!/bin/bash
#
# Title ........: msys-build-portaudio.sh
# Version ......: v19 2014-01-30
# Description ..: Build portaudio from source
# Project URL ..: http://www.portaudio.com/download.html
# Usage ........: ./msys-build-portaudio.sh
#
# Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
# Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
# License ......: GPL-3
#
# msys-build-portaudio.sh is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation either version 3 of the
# License, or (at your option) any later version. 
#
# msys-build-portaudio.sh is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#--------------------------------------------------------------------#

# Exit on errors
set -e

# General use Vars and colour
today=$(date +"%d-%m-%Y")
source /scripts/color-variables

# Package Variables
export PATH="/mingw32:$PATH"
TC="/mingw32"
SRC=~/src && mkdir -p $SRC/win32
PREFIX="C:/JTSDK/usr/local"
PKG_NAME=portaudio
PKG_ARCHIVE='pa_stable_v19_20140130.tgz' # Name as downloaded from site
PKG_VER='v19_20140130'                   # Package version from tar file name


# Function -----------------------------------------------------------
tool_check() {
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y}" Setting Up to build [ $PKG_NAME ]"${C_NC}
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
echo ''
echo " Tool Chain looks ready for compiling"
echo ''

}
# End Function -------------------------------------------------------

# Run Tool Check
clsb
tool_check

if [ "$?" = "1" ];
then
	echo 'There was a problem with the Tool-Chain.'
	echo "$0 Will now exit .."
	exit ''
	exit 1
fi

# Unpack archive
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} " UNPACKING [ $PKG_NAME ]"${C_NC}
echo '---------------------------------------------------------------'
echo ''

cd $SRC
if [ -f ./$PKG_ARCHIVE ];
then
	tar -xf $PKG_ARCHIVE -C ~/src/win32/
	echo '  Finished Unpacking'
else
	echo "Could not find [ $PKG_ARCHIVE ]"
	echo "$(basename $0) will now exit .."
	echo ''
	exit 1
fi

# Run configure
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} " CONFIGURING [ $PKG_NAME $PKG_VER ]"${C_NC}
echo '---------------------------------------------------------------'
echo ''
echo '  This can take a several minutes to complete'
echo ''
# Package Variables
cd $SRC/win32/$PKG_NAME

./configure --prefix=C:/JTSDK/usr/local \
--build=i686-pc-mingw32 --host=i686-pc-mingw32 \
--disable-shared --enable-static CC=/mingw32/gcc.exe \
CXX=/mingw32/g++.exe --with-winapi=wmme,directx --with-dxdir=../dx9mgw



# Make clean check, only if Makefile present
# if [[ -f $SRC/win32/$PKG_NAME/Makefile ]];
# then
	# echo ''
	# echo '--------------------------------------------------------------'
	# echo -e ${C_Y} ' RUNNING MAKE CLEAN'${C_NC}
	# echo '--------------------------------------------------------------'
	# echo ''
	# mingw32-make clean 
# fi

# Run make
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} " RUNNING MAKE ALL FOR [ $PKG_NAME $PKG_VER ]"${C_NC}
echo '---------------------------------------------------------------'
echo ''
make -s

# Run mingw43-make install .. no install-strip
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} " INSTALLING [ $PKG_NAME $PKG_VER ] "${C_NC}
echo '---------------------------------------------------------------'
echo ''
make install

# Finished
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_G} "  FINISHED INSTALLING [ $PKG_NAME }"${C_NC}
echo '---------------------------------------------------------------'
echo ''
touch "$PREFIX/$PKG_NAME-build-date-$today"
echo "Install Location: $PREFIX"
echo ''

exit 0
