#!/bin/sh
#
#-------------------------------------------------------------------------------
# This file is part of the kvasd-instter application
#
# File Name ....: autogen.sh
# Description ..: script to generate configire and makefile
# Execution ....: ./autogen.sh
#
# Author .......: Greg Beam, KI7MT <ki7mt@yahoo.com>
# Copyright ....: Copyright (C) 2014-2015 Joseph Taylor, K1JT
# License ......: GPL-3+
# Website ......: http://physics.princeton.edu/pulsar/k1jt/devel.html
# Report Bugs ..: wsjt-devel@lists.sourceforge.net
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
# Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
#-------------------------------------------------------------------------------

set -e

BASED=$(exec pwd)
PROGRAM='KVASD Installer'

# Foreground colours
C_R='\033[01;31m'	# red
C_G='\033[01;32m'	# green
C_Y='\033[01;33m'	# yellow
C_C='\033[01;36m'	# cyan
C_NC='\033[01;37m'	# no color

# Start main script
cd $BASED

# Test if Bash is installed
bash --version > /dev/null 2>&1 || {
	clear
	echo '---------------------------------------------'
	echo 'PACKAGE DEPENDENCY ERROR'
	echo '---------------------------------------------'
	echo ''
	echo 'You must have the package [ Bash ( >= 4.2 ) ]'
	echo " installed to compile $PROGRAM. Please install"
	echo ' the appropriate package for your distribution.'	
	echo ''
	exit 1
}

# Test if Awk is installed
awk --version > /dev/null 2>&1 || {
	clear
	echo '---------------------------------------------'
	echo 'PACKAGE DEPENDENCY ERROR'
	echo '---------------------------------------------'
	echo ''
	echo 'You must have the package [ Awk or Gawk ]'
	echo "installed to compile $PROGRAM. Please install"
	echo 'the appropriate package for your distribution.'	
	echo ''
	exit 1
}

# Test if Dialog is installed
dialog --version > /dev/null 2>&1 || {
	clear
	echo '---------------------------------------------'
	echo 'PACKAGE DEPENDENCY ERROR'
	echo '---------------------------------------------'
	echo ''
	echo 'You must have the package [ dialog ] installed'
	echo "to compile $PROGRAM. Please install the"
	echo 'appropriate package for your distribution.'	
	echo ''
	exit 1
}

# Test if autoconf is installed
autoconf --version > /dev/null 2>&1 || {
	clear
	echo '---------------------------------------------'
	echo 'PACKAGE DEPENDENCY ERROR'
	echo '---------------------------------------------'
	echo ''
	echo 'You must have [ autoconf ] installed to compile'
	echo "$PROGRAM. Install the appropriate package for"
	echo 'your distribution.'
	echo ''
	exit 1
}

# Test if Subversion is installed
svn --version > /dev/null 2>&1 || {
	clear
	echo '---------------------------------------------'
	echo 'PACKAGE DEPENDENCY ERROR'
	echo '---------------------------------------------'
	echo ''
	echo 'You must have [ Subversion ] installed to compile'
	echo "$PROGRAM. Install the appropriate package for"
	echo 'your distribution.'
	echo ''
	exit 1
}

# run make clean if makefile and configure are found
if test -f ./Makefile -a ./configure ; then
	clear
	echo '---------------------------------------------------'
	echo ${C_Y}"Checking for Old Makefile & Configure Script"${C_NC}
	echo '---------------------------------------------------'
	echo ''
	echo 'Found old files, running make clean first'
	echo ''
	make -s clean
	echo '---------------------------------------------------'
	echo ${C_Y}"Running ( autoconf ) to process configure.ac"${C_NC}
	echo '---------------------------------------------------'
	autoconf -f -i
else
	clear
	echo '---------------------------------------------------'
	echo ${C_Y}"Running ( autoconf ) to process configure.ac"${C_NC}
	echo '---------------------------------------------------'
	autoconf -f -i
fi

# simple test for the configure script, after running autogen.sh
if test -s ./configure; then
	echo "Finished generating configure script"
else
# message if configure was not found
	echo ''
	echo "There was a problem generating the configure script"
	echo "Check config.status for details."	
	echo ''
	exit 1
fi

# message if no arguments were presented
if test -z "$*"; then
	echo "Using ./configure With Default Options"
else
# List user input arguments
	echo "Using ./configure $@"
fi

$BASED/configure "$@"

exit 0
