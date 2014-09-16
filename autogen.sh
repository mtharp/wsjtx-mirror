#!/bin/sh
#
#-------------------------------------------------------------------------------
# This file is part of the WSPR application, Weak Signal Propogation Reporter
#
# SVN	: $Id$
#
# File Name:    autogen.sh
# Description:  script to generate configire and makefile
#
# Run ./autogen.sh
#
# Copyright (C) 2001-2014 Joseph Taylor, K1JT
# License: GPL-3+
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

_BASED=$(exec pwd)
_PROGRAM=WSPR

# Start main script
cd $_BASED

autoconf --version > /dev/null 2>&1
if test "$?" -eq 1; then
# message if autoconf was found or not "0"=OK, "1"= Not Reachable
	clear
	echo
	echo "You must have autoconf installed to compile $_PROGRAM."
	echo "Install the appropriate package for your distribution,"
	echo
	exit 1
fi

clear
echo
echo "Running ( autoconf -f -i ) to process configure.ac"

# Generate configure script from configure.ac and aclocal.m4
autoconf -f -i

# simple test for the configure script, after running autogen.sh
if test -s ./configure; then
	echo " ..Finished"
	echo " ..Autoconf will now build the Makefile"
	echo " ..Running ./configure to generate Makefile"
	echo
	sleep 1
else
# message if configure was not found
	echo "There was a problem generating the configure script"
	echo "Check config.status for details."	
	echo
	exit 1
fi

# message if no arguments were presented
if test -z "$*"; then
	echo "Using  ./configure with default arguments"
	echo
	echo "If you wish  change paramaters, add the arguments"
	echo "to use $0 command line."
	echo
	sleep 1
else
# List user input arguments
	echo "Using ./configure $@"
	echo
	sleep 2
fi

$_BASED/configure "$@"

exit 0
