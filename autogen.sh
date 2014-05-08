#!/bin/sh

# Run ./autogen.sh to build configure and Makeflie

set -e

_BASED=$(exec pwd)
_PROJECT=WSPR

# Start main script
cd $_BASED

autoconf --version > /dev/null 2>&1
if test "$?" -eq 1; then 
	clear
	echo
	echo "You must have autoreconf installed to compile $_PROJECT."
	echo "Install the appropriate package for your distribution,"
	echo
	exit 1
fi

clear
echo
echo "Running ( autoconf -i ) to process configure.ac"
echo "to generate configure script."
echo

# Generate configure script from configure.ac and aclocal.m4

autoconf -i

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
	echo "Makefile. Command line options are available for $_PROJECT"
	echo "build. If you would like to see the options"
	echo "or need to add configuration paths, select ( N ) and"
	echo "autogen.sh will list options, then exit. Otherwise"
	echo "Type ( Y ) to create Makefile without options"
	echo
	echo "At any time, to re-list options, at the prompt, type:"
	echo
	echo "./configure --help"
	echo
while [ 1 ]
do
	read -p "Continue with configure? [ Y / N ]: " yn
	case $yn in
	[Yy]* )
		echo "Running configure script .. generating Makefile"
		# run ./configure
		$_BASED/configure
			echo "Finished creating Makefile, To build $_PROJECT, type:"
			echo
			echo " make"
			echo
			echo "After build, to run $_PROJECT, type:"
			echo
			echo " python3 -O wspr.py"
			echo
	exit 0
	;;
	[Nn]* )
		clear
		$_BASED/configure --help
		exit 0
	;;
	* )
	clear
	echo "Please use 'Y' yes or 'N' No."
	;;
	esac
done
