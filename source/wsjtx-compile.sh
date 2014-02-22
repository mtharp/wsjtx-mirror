#!/usr/bin/env bash

# Part of the WSJT Documentation Project
# Usage:  chmod +x ./wsjtx-compile.sh && ./wsjtx-compile.sh

# EXIT IF ERRORS
set -e

# SET WSJT-ENV DIRECTORY
BUILD_DIR=~/wsjt-env/wsjtx-build
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

# Test for mutiple builds of same $rev_num
# For manual entry, Copy & Paste from if .. fi as one command, then [ENTER]
if test -d ./wsjtx-$rev_num
then
mv ./wsjtx-$rev_num ./wsjtx-$rev_num-$(date +%F-%H%M)
fi

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


