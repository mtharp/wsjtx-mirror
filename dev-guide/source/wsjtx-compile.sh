#!/usr/bin/env bash

# Part of the WSJT Documentation Project
# Usage:  chmod +x ./wsjtx-compile.sh && ./wsjtx-compile.sh

set -e
# EDIT INSTALL LOCATION IS DESIRED
BUILD_DIR=~/Projects/wsjtx-build

# NO EDITS REQUIRED BEYOND THIS POINT
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# CHECKOUT WSJT-X
clear && echo 'Getting Latest WSJT-X Version'
svn co svn://svn.berlios.de/wsjt/branches/wsjtx
cd ./wsjtx
rev_num=$(grep -i "rev=" mainwindow.cpp |awk '{print $3}')

# MAIKEFILE
cd ./lib
make -f Makefile.linux

# QMAKE && MAKE
cd ../
export QT_SELECT=qt5
qmake
j_c=$(grep -c ^processor /proc/cpuinfo)
make -j$j_c

# MOVE WSJT-X FOLDER
cd ../
mv ./wsjtx_install ./wsjtx-$rev_num
cd ./wsjtx-$rev_num

# COPY FILES
cp ../wsjtx/*.dat ../wsjtx/*.txt ./
cp -R ../wsjtx/Palettes/ ../wsjtx/samples/ ./
rm ./CMake*

# DOWNLOAD KVASD
wget http://www.physics.princeton.edu/pulsar/K1JT/kvasd
chmod +x ./kvasd

# CLEAN-UP
rm -rf ../wsjtx
clear
echo WSJTX-$rev_num Build Complete
echo
exit 0


