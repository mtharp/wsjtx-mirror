#!/usr/bin/env bash

# Part of the WSJT Documentation Project
# Usage:  chmod +x ./wsjtx-cmake.sh && ./wsjtx-cmake.sh

# EXIT IF ERRORS
set -e

# SETUP BASE DIR
BASE_DIR=$HOME/Projects/wsjt-env

# MAKE DIRECTORY STRUCTURE
mkdir -p $BASE_DIR/wsjtx/{build,install}/{Debug,Release}

# GET USER BUILD OPTION
if [[ $1 = "-d" ]] || [[ $1 = "-D" ]]
then
	OPTION=Debug
else
	OPTION=Release
fi

# CHECK OUT LATEST WSJT-X
echo Checking out WSJT-X From SourceForge
svn co svn://svn.code.sf.net/p/wsjt/wsjt/branches/wsjtx $BASE_DIR/src/wsjtx/

# CD TO BUILD DIRECTORY
cd $BASE_DIR/wsjtx/build/$OPTION

# BUILD SETUP
echo Building WSJT-X $OPTION
cmake -D CMAKE_INSTALL_PREFIX=$BASE_DIR/install/$OPTION \
-D CMAKE_BUILD_TYPE=$OPTION $BASE_DIR/src/wsjtx

# BUILD && INSTALL TARGET
j_c=$(grep -c ^processor /proc/cpuinfo)
cmake --build . --target install -- -j$j_c

# IF BUILD EXISTS MV to wsjtx-date-HHMM
rev_num=$(grep -i "rev=" $BASE_DIR/src/wsjtx/mainwindow.cpp |awk '{print $3}')
if test -d $BASE_DIR/wsjtx-$rev_num
then
mv $BASE_DIR/wsjtx-$rev_num $BASE_DIR/wsjtx-$rev_num-$(date +%F-%H%M)
fi

# MOVE \bin
mv $BASE_DIR/install/$OPTION/bin $BASE_DIR/wsjtx-$rev_num
cd $BASE_DIR

clear
echo Finished WSJT-X Build
echo
exit 0

