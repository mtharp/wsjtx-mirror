#!/bin/bash
#
# Title ........: msys-build-samplerate.sh
# Version ......: 0.1.8
# Description ..: Build Samplerate Static Libs from source
# Project URL ..: http://www.mega-nerd.com/SRC/
# Usage ........: ./msys-build-samplerate.sh
#
# Author ......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
# Copyright ...: Copyright (C) 2014 Joe Taylor, K1JT
# License .....: GPL-3
#
# msys-build-samplerate.sh is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation either version 3 of the
# License, or (at your option) any later version. 
#
# msys-build-samplerate.sh is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#--------------------------------------------------------------------#

# Exit on errors
set -e
today=$(date +"%d-%m-%Y")

# General use Vars and colour
export PATH="/c/JTSDK/qt5/Tools/mingw48_32/bin:$PATH"
TC='C:/JTSDK/qt5/Tools/mingw48_32/bin'
SRC=/c/JTSDK/src/win32

# Foreground colours
C_R='\033[01;31m'		# red
C_G='\033[01;32m'		# green
C_Y='\033[01;33m'		# yellow
C_C='\033[01;36m'		# cyan
C_NC='\033[01;37m'		# no color

# Package Information
PREFIX="C:/JTSDK/samplerate" 
BUILDER='Greg Beam, KI7MT <ki7mt@yahoo.com>'
PKG_NAME=libsamplerate-0.1.8
PKG_VER='0.1.8'
PKG_ARCHIVE='libsamplerate-0.1.8.tar.gz'
PKG_WEBSITE='http://www.mega-nerd.com/SRC/index.html'
PKG_DOWNLOAD='http://www.mega-nerd.com/SRC/download.html'
TOOL_CHAIN='Mingw32 GNU 4.8.1'

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
	
	if [ "$?" = "1" ];
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

# List tools versions
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

# Unpack archive
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} " UNPACKING [ $PKG_NAME ]"${C_NC}
echo '---------------------------------------------------------------'
echo ''
cd $HOME
mkdir -p ~/src/win32 && cd ~/src
if [ -d ~/src/win32/$PKG_NAME ] ; then rm -rf ~/src/win32/$PKG_NAME ; fi

# Unpack archive
echo " Unpacking $PKG_NAME"
tar -xf $SRC/$PKG_ARCHIVE -C ~/src/win32/
echo ' Finished'
echo ''

# Run configure
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} " CONFIGURING [ $PKG_NAME ]"${C_NC}
echo '---------------------------------------------------------------'
echo ''
echo ' This can take a several minutes to complete'
echo -en " Build Type: " && echo -e ${C_G}'Static'${C_NC}
echo ''

# Package Variables
cd ~/src/win32/$PKG_NAME

# Single Precision
./configure --prefix=$PREFIX --enable-static --disable-shared \
--disable-fftw --disable-sndfile

# Run make
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} " RUNNING MAKE ALL FOR [ $PKG_NAME ]"${C_NC}
echo '---------------------------------------------------------------'
echo ''
make

# Run make install
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} " INSTALLING [ $PKG_NAME ]"${C_NC}
echo '---------------------------------------------------------------'
echo ''
make install

# Generate Readme if build finishes .. OK ..
if [ $? = "0" ];
then
	if [ -f $PREFIX/README.$PKG_NAME ]; then rm -f $PREFIX/README.$PKG_NAME ; fi

	echo ''
	echo '---------------------------------------------------------------'
	echo -e ${C_Y} " ADDING README DOC [ README.$PKG_NAME ] "${C_NC}
	echo '---------------------------------------------------------------'
	echo ''
	echo '  Adding Readme'

# Generate Readme file
# Ensure this matches the top of the page
(
cat <<'EOF_README'

# Package Information

# Package Information
PREFIX="C:/JTSDK/samplerate" 
BUILDER='Greg Beam, KI7MT <ki7mt@yahoo.com>'
PKG_NAME=libsamplerate-0.1.8
PKG_VER='0.1.8'
PKG_ARCHIVE='libsamplerate-0.1.8.tar.gz'
PKG_WEBSITE='http://www.mega-nerd.com/SRC/index.html'
PKG_DOWNLOAD='http://www.mega-nerd.com/SRC/download.html'
TOOL_CHAIN='Mingw32 GNU 4.8.1'

# Configure Options <single-percision>:

./configure --prefix=$PREFIX --enable-static --disable-shared \
--disable-fftw --disable-sndfile

# Build Commands

make
make install

EOF_README
) > $PREFIX/$PKG_NAME.build.info

	echo '  Finished'

fi

# Finished
if [ "$?" = "0" ];
then
	echo ''
	echo '----------------------------------------------------------------'
	echo -e ${C_G} "  FINISHED INSTALLING [ $PKG_NAME ]"${C_NC}
	echo '----------------------------------------------------------------'
	echo ''
	touch C:/JTSDK/samplerate/build-date-$today
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
