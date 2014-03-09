#!/usr/bin/env bash

# Part of the WSJT Documentation Project
# Usage:  chmod +x ./wsjtx-makefile.sh && ./wsjtx-makefile.sh

# EXIT IF ERRORS
set -e

# SET WSJT-ENV DIRECTORY
BASE_DIR=$HOME/wsjt-env
mkdir -p $BASE_DIR/src
SRC_DIR=$BASE_DIR/src

# MAKE DIRECTORIES
clear && echo Creating WSJT Environment

# CHECKOUT WSJT-X
echo Getting Latest WSJT-X Version
svn co -r 3834 svn://svn.code.sf.net/p/wsjt/wsjt/branches/wsjtx $SRC_DIR/wsjtx

# GET CURRENT REVISION NUMBER
rev_num=$(grep -i "rev=" $SRC_DIR/wsjtx/mainwindow.cpp |awk '{print $3}')

# MAIKEFILE
echo Building WSJTX-$rev_num
cd $SRC_DIR/wsjtx/lib
make -f Makefile.linux

# QMAKE && MAKE
cd $SRC_DIR/wsjtx
export QT_SELECT=qt5
qmake
j_c=$(grep -c ^processor /proc/cpuinfo)
make -j$j_c

# MOVE WSJT-X FOLDER
if test -d $BASE_DIR/wsjtx-$rev_num
then
mv $BASE_DIR/wsjtx-$rev_num $BASE_DIR/wsjtx-$rev_num-$(date +%F-%H%M)
fi
mv $SRC_DIR/wsjtx_install $BASE_DIR/wsjtx-$rev_num

# COPY FILES
cp $SRC_DIR/wsjtx/{*.dat,*.txt} $BASE_DIR/wsjtx-$rev_num/
cp -R $SRC_DIR/wsjtx/{Palettes/,samples/} $BASE_DIR/wsjtx-$rev_num/
rm ./CMake*

# DOWNLOAD KVASD
wget http://www.physics.princeton.edu/pulsar/K1JT/kvasd
chmod +x ./kvasd

# CLEAN UP AFTER MAKE
cd $SRC_DIR/wsjtx/lib && make -f Makefile.linux clean
cd ../ && make clean

# EXIT
clear
echo "WSJTX-$rev_num Build Complete"
echo 'To run WSJT-X: cd' $BASE_DIR/wsjtx-$rev_num
echo 'Then Type: ./wsjtx'
echo
exit 0

