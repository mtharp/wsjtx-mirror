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

# Note: For full support with ASIO, WDMKS, WASAPI
# See www.sm5bsz.com/linuxdsp/install/pa/pa.htm

# Exit on errors
set -e

# General use Vars and colour
today=$(date +"%d-%m-%Y")

# Source color options
C_R='\033[01;31m'		# red
C_G='\033[01;32m'		# green
C_Y='\033[01;33m'		# yellow
C_C='\033[01;36m'		# cyan
C_NC='\033[01;37m'		# no color

# MSYS Package Variables
TC='C:/JTSDK/qt5/Tools/mingw48_32/bin'
export PATH="/c/JTSDK/qt5/Tools/mingw48_32/bin:$PATH"

# Create build directories
mkdir -p $HOME/src/win32

# PA Package Information
# Note: PREFIX is set for JTSDK v2
PREFIX="C:/JTSDK/portaudio" 
BUILDER='Greg Beam, KI7MT <ki7mt@yahoo.com>'
PKG_NAME='portaudio'
PKG_VER='20140130-SVN-1919'
PKG_ARCHIVE='pa_stable_v19_20140130.tgz'
PKG_WEBSITE='http://www.portaudio.com/'
PKG_DOWNLOAD='http://sourceforge.net/projects/jtsdk/files/win32/2.0.0/src/portaudio/pa_stable_v19_20140130.tgz'

# DX9 Package Information
PKG_NAME1='dx9mgw'
PKG_VER1='dx9mgw'
PKG_ARCHIVE1='dx9mgw.zip'
PKG_WEBSITE1='http://alleg.sourceforge.net/'
PKG_DOWNLOAD1='http://alleg.sourceforge.net/files/dx9mgw.zip'


# -------------------------------------------------------------------------------
#  FUNCTIONS
# ------------------------------------------------------------------------------- 

# Tool-Chain Check
tool_check() {
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

# -----------------------------------------------------------------------------
#  MAIN SCRIPT
# ----------------------------------------------------------------------------- 

# Run Tool Check
clsb
tool_check

# PA Download Source
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} " DOWNLOADING PACKAGES "${C_NC}
echo '---------------------------------------------------------------'
echo ''
cd $HOME/src
echo "..DOWNLOADING PORTAUDIO"
rm -f ./$PKG_ARCHIVE
curl -sS -L $PKG_DOWNLOAD > $PKG_ARCHIVE
echo '..Finished'
echo ''

# DX9 Download Source
echo "..DOWNLOADING DX9 HEADERS"
rm -rf ./$PKG_ARCHIVE1
curl -sS -L $PKG_DOWNLOAD1 > $PKG_ARCHIVE1
echo '..Finished'
echo ''

# DX9 Unpack
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} " UNPACKING [ $PKG_NAME1 ]"${C_NC}
echo '---------------------------------------------------------------'
echo ''
unzip -q -o $PKG_ARCHIVE1 -d ~/src/win32/
echo '  Finished Unpacking'

# PA Unpack
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} " UNPACKING [ $PKG_NAME ]"${C_NC}
echo '---------------------------------------------------------------'
echo ''
tar -xf $PKG_ARCHIVE -C ~/src/win32/
echo '  Finished Unpacking'

# Run configure
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} " CONFIGURING [ $PKG_NAME $PKG_VER ]"${C_NC}
echo '---------------------------------------------------------------'
echo ''
echo '  This can take a several minutes to complete'
echo ''

# CD To Source Directory
cd ~/src/win32/$PKG_NAME

# For Linux Cross Compiling, requires mingw32 packages
# PREFIX=$HOME/win32
# export AR=i586-mingw32msvc-ar
# export CC=i586-mingw32msvc-gcc
# export CXX=i586-mingw32msvc-g++
# export RANLIB=i586-mingw32msvc-ranlib
# export CROSSCFG='--build=x86_64-pc-none --host=i586-mingw32msvc'
# export LINKCFG='--enable-static --disable-shared'
# ./configure --prefix=$PREFIX $CROSSCFG $LINKCFG --with-winapi=wmme,directx --with-dxdir=../dx9mgw

./configure --prefix=$PREFIX --build=i686-pc-mingw32 --host=i686-pc-mingw32 \
--disable-shared --enable-static CC=$TC/gcc.exe CXX=$TC/g++.exe \
--with-winapi=wmme,directx --with-dxdir=../dx9mgw

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

# Generate Readme if build finishes .. OK ..
rm -rf $PREFIX/README.$PKG_NAME
echo ''
echo '---------------------------------------------------------------'
echo -e ${C_Y} " ADDING BUILD INFO [ $PKG_NAME.build.info ] "${C_NC}
echo '---------------------------------------------------------------'
echo ''
echo '..Adding build info'

(
cat <<'EOF_BUILD-INFO'

# PA Package Information
PREFIX="C:/JTSDK/portaudio" 
BUILDER='Greg Beam, KI7MT <ki7mt@yahoo.com>'
PKG_NAME='portaudio'
PKG_VER='20140130-SVN-1919'
PKG_ARCHIVE='pa_stable_v19_20140130.tgz'
PKG_WEBSITE='http://www.portaudio.com/'
PKG_DOWNLOAD='http://sourceforge.net/projects/jtsdk/files/win32/2.0.0/src/portaudio/pa_stable_v19_20140130.tgz'

# DX9 Package Information
PKG_NAME1='dx9mgw'
PKG_VER1='dx9mgw'
PKG_ARCHIVE1='dx9mgw.zip'
PKG_WEBSITE1='http://alleg.sourceforge.net/'
PKG_DOWNLOAD1='http://alleg.sourceforge.net/files/dx9mgw.zip'

# Configure Options
./configure --prefix=$PREFIX --build=i686-pc-mingw32 --host=i686-pc-mingw32 \
--disable-shared --enable-static CC=$TC/gcc.exe CXX=$TC/g++.exe \
--with-winapi=wmme,directx --with-dxdir=../dx9mgw

# Build Commands
make -s
make install

EOF_BUILD-INFO
) > $PREFIX/$PKG_NAME.build.info

	echo '..Finished'

# Finished
echo ''
echo '----------------------------------------------------------------'
echo -e ${C_G} "  FINISHED INSTALLING [ $PKG_NAME ]"${C_NC}
echo '----------------------------------------------------------------'
echo ''
touch $PREFIX/build-date-$today
echo "Install Location: $PREFIX"
echo ''
cd $HOME

exit 0
