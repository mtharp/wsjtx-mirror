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
	echo "You must have autoreconf installed to compile $_PROGRAM."
	echo "Install the appropriate package for your distribution,"
	echo
	exit 1
fi

clear
echo
echo "Running ( autoconf -f -i ) to process configure.ac"
echo

# Generate configure script from configure.ac and aclocal.m4
autoconf -f -i

if test -s ./configure; then
	echo "Finished generating configure script."
else
	echo "There was a problem generating the configure script"
	echo "Check config.status for details."	
	echo
	exit 1
fi
	echo
	echo "Autogen is about to run configure to generate the"
	echo "Makefile with default options."
	echo
	echo "To see additional configuration options, select ( N ),"
	echo "then type ..: ./configure --help"
	echo
	echo
while [ 1 ]
do
	read -p "Continue with configure? [ Y / N ]: " yn
	case $yn in
	[Yy]* )
		$_BASED/configure
		echo "Finished creating Makefile, To build $_PROGRAM, type:"
		echo
		echo " make"
		echo
	exit 0
	;;
	[Nn]* )
		exit 0
	;;
	* )
		clear
		echo "Please use 'Y' yes or 'N' No."
	;;
	esac
done
