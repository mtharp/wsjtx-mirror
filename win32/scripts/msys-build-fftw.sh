#!/bin/bash
#
# Title ........: msys-build-fftw.sh
# Version ......: 3.3.4
# Description ..: Build FFTW Static Libs from source
# Project URL ..: http://www.fftw.org/download.html
# Usage ........: ./msys-build-fftw.sh or alias build-fftw
#
# Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
# Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
# License ......: GPL-3
#
# msys-build-fftw.sh is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation either version 3 of the
# License, or (at your option) any later version. 
#
# msys-build-fftw.sh is distributed in the hope that it will be
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

# Source color options
source /scripts/color-variables

# General use Vars and colour
export PATH="/c/JTSDK/qt5/Tools/mingw48_32/bin:$PATH"
TC='C:/JTSDK/qt5/Tools/Tools/mingw48_32/bin'
URL='https://sourceforge.net/projects/jtsdk/files/2.0.0/src/fftw-3.3.4.tar.gz'
SRC=~/src

# Manually set mumber of pcrocessors
JJ=4

# Package Information
PREFIX="C:/JTSDK/fftw3f/static" 
BUILDER='Greg Beam, KI7MT <ki7mt@yahoo.com>'
PKG_NAME=fftw-3.3.4
PKG_VER='3.3.4'
PKG_ARCHIVE='fftw-3.3.4.tar.gz'
PKG_WEBSITE='http://www.fftw.org/'
PKG_DOWNLOAD='http://www.fftw.org/download.html'


# -------------------------------------------------------------------------------
#  FUNCTIONS
# ------------------------------------------------------------------------------- 

# Tool-Chain Check
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
		echo ' Check your tool-chain path is set correctly:'
		echo ''
		echo ' For QT5 ....: export PATH="/c/JTSDK/qt5/bin:$PATH"'
		echo ' For MinGW ..: export PATH="/c/JTSDK/mingw32/bin:$PATH"'
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

} # End Tool-Chain Check

# Download Error Message
download_error() {
	echo ''
	echo -e ${C_R}"DOWNLOAD ERROR"${C_NC}
	echo ''
	echo " $0 was unable to download $PKG_ARCHIVE"
	echo ' Check your connection or the script for errors'
	echo ''
	cd $HOME
	exit 1
} # End Download Error Message


# -------------------------------------------------------------------------------
#  MAIN SCRIPT
# ------------------------------------------------------------------------------- 

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

# Download FFTW source
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} " DOWNLOADING [ $PKG_NAME ]"${C_NC}
echo '---------------------------------------------------------------'
echo ''
mkdir -p ~/src && cd ~/src
cd ~/src
echo "..Downloading $PKG_ARCHIVE"
# -sS is for quiet mode, -L is to allow the Sourceforge Re-Direct
curl -sS -L $URL > $PKG_ARCHIVE
if [ "$?" != "0" ]; then download_error ; fi
echo '..Finished'
echo ''

# Unpack archive
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} " UNPACKING [ $PKG_NAME ]"${C_NC}
echo '---------------------------------------------------------------'
echo ''
mkdir -p ~/src/win32 && cd $SRC
if [ -d ~/src/win32/$PKG_NAME ] ; then rm -rf ~/src/win32/$PKG_NAME ; fi

# Unpack archive
echo "..Unpacking $PKG_ARCHIVE"
tar -xf ~/src/$PKG_ARCHIVE -C ~/src/win32/
echo '..Finished'
echo ''

# Run configure
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} " CONFIGURING [ $PKG_NAME ]"${C_NC}
echo '---------------------------------------------------------------'
echo ''
echo ' This can take a several minutes ( 15+ ) to complete'
echo -en " Build Type: " && echo -e ${C_G}'Static'${C_NC}
echo ''

# Package Variables
cd ~/src/win32/$PKG_NAME

# Single Precision
./configure --prefix=$PREFIX --with-our-malloc16 --with-windows-f77-mangling \
--enable-static --disable-shared --enable-threads --with-combined-threads \
--enable-float --enable-sse2 --enable-avx --with-incoming-stack-boundary=2

# Run make
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} " RUNNING MAKE ALL FOR [ $PKG_NAME ]"${C_NC}
echo '---------------------------------------------------------------'
echo ''
# To Make parallel, use:  make -s -j$JJ
make -s

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
	echo -e ${C_Y} " ADDING BUILD INFO [ $PKG_NAME.build.info ] "${C_NC}
	echo '---------------------------------------------------------------'
	echo ''
	echo '..Adding build info'

# Generate Readme file
# Ensure this matches the top of the page
(
cat <<'EOF_BUILD-INFO'

# Package Information
PREFIX="C:/JTSDK/fftw3f/static" 
BUILDER='Greg Beam, KI7MT <ki7mt@yahoo.com>'
PKG_NAME=fftw-3.3.4
PKG_VER='3.3.4'
PKG_ARCHIVE='fftw-3.3.4.tar.gz'
PKG_WEBSITE='http://www.fftw.org/'
PKG_DOWNLOAD='https://sourceforge.net/projects/jtsdk/files/2.0.0/src/fftw-3.3.4.tar.gz'

# Configure Options <single-percision>:
./configure --prefix=$PREFIX --with-our-malloc16 --with-windows-f77-mangling \
--enable-static --disable-shared --enable-threads --with-combined-threads \
--enable-float --enable-sse2 --enable-avx --with-incoming-stack-boundary=2

# Build Commands
make -s -j$JJ
make install

EOF_BUILD-INFO
) > $PREFIX/$PKG_NAME.build.info

	echo '..Finished'

fi

# Finished
if [ "$?" = "0" ];
then
	echo ''
	echo '----------------------------------------------------------------'
	echo -e ${C_G} "  FINISHED INSTALLING [ $PKG_NAME $PKG_VER ]"${C_NC}
	echo '----------------------------------------------------------------'
	echo ''
	touch C:/JTSDK/fftw3f/build-date-$today
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

exit 0
