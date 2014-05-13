#!/usr/bin/env bash
#
#
# Script to create wpsr-${version}-linux.tar.gz
#
# USAGE: wspr-dist.sh [NAME] [VERSION]
# 
# Example: ./wspr-dist.sh wspr 4.0
#
# Generates: wspr-4.0.tar.gz
#

_NAME=$1
_VER=$2

set -e
# test $1
if [[ -z $_NAME ]]; then
	echo
	echo "Input Error"
	echo
	echo "You need to specify a name to proceed."
	echo
	echo "USAGE: wspr-dist.sh [NAME] [VERSION]"
	echo
	echo "Example: ./wspr-dist.sh wspr 4.0"
	echo
	exit 1
fi

_BASED=$(exec pwd)
_TARNAME="$_NAME-$_VER-linux.tar.gz"
_DISTD=$_BASED/dist
_SCRIPT=$(basename "$0")

# look for manifest file
if [[ -f $_BASED/$_NAME-manifest.in ]]; then

	echo " ..have manifest"
else
	echo
	echo "wspr-manifest.in is missing!, cannot continue."
	echo
	exit 1
fi

# start main
clear
echo
echo "$_SCRIPT Started Creating ( $_NAME-$_VER ) Tarball"
echo

# make dist diirectory
if [[ -d $_DISTD/$_NAME ]]; then
	echo " ..removing old distributions directory"
	rm -r $_DISTD/$_NAME && mkdir -p $_DISTD/$_NAME
	echo " ..new directory created: $_DISTD/$_NAME"
else
	echo " ..new directory created: $_DISTD/$_NAME"
	mkdir -p $_DISTD/$_NAME
fi

# start copying files & folders
cp -r save/ WsprMod/ WsprModNoGui/ build-aux/ $_DISTD/$_NAME


# remove any .dll's from WsprMod
echo " ..removing any .dll files"
rm $_DISTD/$_NAME/WsprMod/*.dll 

# copy man pages
cp -r doc/man1/ $_DISTD/$_NAME

# start copy loop
for line in $(< $_NAME-manifest.in)
do
	if [[ -f $line ]]; then
		cp "$line" $_DISTD/$_NAME
	else 
		echo
		echo "Missing Manifest File $line"
		echo "Please Verify the file list and re-run $_SCRIPT"
		echo
		exit 1
	fi
done

# start building the tarball
echo " ..copying complete, building tar file"
cd $_DISTD

# check that $_NAME folder actally exists before running tar
if [[ -d $_DISTD/$_NAME ]]; then
	export GZIP=-9
	tar -czf $_TARNAME ./$_NAME
else
	echo
	echo "Folder Error !"
	echo "Could not find $_DISTD/$_NAME"
	echo
	echo "Check the build script for accuracy, and re-run $_SCRIPT"
	echo
	exit 1
fi

# test the tar ball was built, and is not "0" in size
if [[ -f $_DISTD/$_TARNAME ]] && [[ $(ls -l $_TARNAME |awk '{print $5}') -ge "0" ]]; then
	echo " ..$_TARNAME is present and seems ok"
else
	echo
	echo "Tar File Error"
	echo "$_TARNAME is missing or has a value of '0'"
	echo
	echo "Check the build script for accuracy, and re-run $_SCRIPT"
	echo
	exit 1
fi
	
# perform MD5 && SHA sums on the file
_MD5=$(md5sum $_TARNAME |awk '{print $1}')
_SHA=$(shasum $_TARNAME |awk '{print $1}')

if [[ -n $_MD5 ]] && [[ -n $_SHA ]]; then
	echo " ..finished checksums"
else
	echo
	echo "Checksum Error"
	echo "SHA or MD5 failed to create a hash"
	echo
	echo "Check the build script for accuracy, and re-run $_SCRIPT"
	echo
	exit 1
fi

# removing build directory
if [[ -f $_TARNAME ]]; then
	echo " ..removing build directory"
	rm -r $_DISTD/$_NAME
fi

# print summary
_FILESIZE=$(du -k "$_TARNAME" | cut -f1)
_FILEPATH=$(readlink -e $_TARNAME)
echo
echo "----------------------------------------------"
echo " Package Summary for $_TARNAME"
echo "----------------------------------------------"
echo
echo "Created ....: $_TARNAME"
echo "File Size ..: $_FILESIZE kb"
echo "MD5SUM: ....: $_MD5"
echo "SHASUM .....: $_SHA"
echo "Location ...: $_FILEPATH"
echo
exit 0

