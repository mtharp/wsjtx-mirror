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

# Start main script
cd $BASED

autoconf --version > /dev/null 2>&1
if test "$?" -eq 1; then
# message if autoconf was found or not "0"=OK, "1"= Not Reachable
	clear
	echo ''
	echo "You must have autoconf installed to compile $PROGRAM."
	echo "Install the appropriate package for your distribution,"
	echo ''
	exit 1
fi

clear
echo ''
echo "-------------------------------------------"
echo " Running Autotools for: $PROGRAM"
echo "-------------------------------------------"
echo ''
echo "Running ( autoconf -f -i ) to process configure.ac"

# Generate configure script from configure.ac and aclocal.m4
autoconf -f -i

# simple test for the configure script, after running autogen.sh
if test -s ./configure; then
	echo "Finished autoconf .."
else
# message if configure was not found
	echo
	echo "There was a problem generating the configure script"
	echo "Check config.status and config.log for details."	
	echo
	exit 1
fi

# message if no arguments were presented
if test -z "$*"; then
	echo "Using ./configure <defualts>"
else
# List user input arguments
	echo "Using ./configure $@"
	echo ''
fi

$BASED/configure "$@"

exit 0
