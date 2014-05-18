#!/bin/sh
#
# SVN	: $Id$
#
# Run ./autogen.sh to build configure and Makeflie

set -e

_BASED=$(exec pwd)
_PROGRAM=WSPR

# Start main script
cd $_BASED

autoconf --version > /dev/null 2>&1
if test "$?" -eq 1; then 
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

if test -s ./configure; then
	echo " ..Finished"
	echo " ..Autoconf will now build the Makefile"
	echo
	echo "To see additional configuration options, at the prompt, "
	echo "type: ./configure --help=short"
	echo
	read -p "Press any key to start ..." justgo
else
	echo "There was a problem generating the configure script"
	echo "Check config.status for details."	
	echo
	exit 1
fi
$_BASED/configure

exit 0
