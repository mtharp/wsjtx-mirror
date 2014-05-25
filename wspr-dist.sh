#!/usr/bin/env bash
#
# Script to create ${name}-${version}.tar.gz
#
# USAGE: wspr-dist.sh [NAME] [VERSION]
# 
# Example1 cmd line: ./wspr-dist.sh wspr 4.0
# Example2 Makefile: make dist
#
# Generates ......: wspr-4.0.tar.gz
# File Location ..: $(src-path)/wspr/dist
#

set -e

_NAME=$(echo $1 |tr [:upper:] [:lower:])
_VER=$2
_BASED=$(exec pwd)
_SCRIPT=$(basename "$0")
_TARNAME="$_NAME-$_VER.tar.gz"
_MANIFEST=wspr-manifest.in
_DISTD="$_BASED/dist"
_DOC="$_DISTD/$_NAME/doc"
_MAN1="$_DISTD/$_NAME/man1"

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

function re_run() {
	echo
	echo "Check the build script for accuracy, and re-run $_SCRIPT"
	echo
	exit 1
}

# start main
clear
echo
echo "Creating ( $_NAME-$_VER ) Distribution Tarball"
echo

# look for manifest file
if [[ -f $_BASED/$_MANIFEST ]]; then

	echo " ..found $_MANIFEST"

else
	echo
	echo "$_MANIFEST is missing!, cannot continue."
	echo
	exit 1
fi

# make dist diirectory
if [[ -d $_DISTD/$_NAME ]]; then
	rm -r "$_DISTD/$_NAME" && mkdir -p "$_DISTD/$_NAME"
	echo " ..created build directory: $_DISTD/$_NAME"
else
	echo " ..created build directory: $_DISTD/$_NAME"
	mkdir -p $_DISTD/$_NAME
fi

# start copying files & folders
if [[ -d WsprMod/__pycache__ ]]
then 
	rm -r WsprMod/__pycache__
fi 

cp -r save/ WsprMod/ build-aux/ "$_DISTD/$_NAME"

# remove any .dll's from WsprMod
echo " ..removing any .dll files"
find "$_DISTD/$_NAME/" -maxdepth 2 -type f -name "*.dll" -delete

# copy full documentation
mkdir -p "$_DOC"
cp -r doc/WSPR0_4.0_Users_Guide.txt doc/WSPR_4.0_User.docx /doc/examples "$_DOC"

# copy man pages
mkdir -p "$_MAN1"
cp -r manpages/man1/*.1 "$_MAN1/"

# start copy loop
for line in $(< $_MANIFEST)
do
	if [[ -f $line ]]; then
		cp "$line" "$_DISTD/$_NAME"
	else 
		echo
		echo "Missing Manifest File $line"
		echo "Please Verify the file list and re-run $_SCRIPT"
		echo
		exit 1
	fi
done

# check $_DISTD/$_NAME exists and is not empty
_FOLDEZISE=$(du -sk $_DISTD/$_NAME | cut -f1)

if [[ -d $_DISTD/$_NAME ]] && [[ $_FOLDERSIZE -ge "0" ]]; then
	echo " ..copying complete, build dir size: $_FOLDEZISE kb "
else
		echo
		echo "Build Folder Error"
		echo 
		echo "The folder size is odd or it is missing."
		echo "Please Verify the file list and re-run $_SCRIPT"
		re_run
fi

# start building the tarball
# check that $_NAME folder actally exists before running tar
cd "$_DISTD"

if [[ -d $_DISTD/$_NAME ]]; then

	# remove old file if exists
	if [[ -f $_TARNAME ]]; then
	echo " ..removing previous build"
	fi

	echo " ..building new tar file"
	export GZIP=-9
	tar -czf "$_TARNAME" ./"$_NAME"
else
	echo
	echo "Folder Error !"
	echo "Could not find $_DISTD/$_NAME"
	re_run
fi

# test the tar ball was built, and is not "0" in size
if [[ -f $_DISTD/$_TARNAME ]] && [[ $(ls -l $_TARNAME |awk '{print $5}') -ge "0" ]]; then
	echo " ..$_TARNAME is present and seems ok"
else
	echo
	echo "Tar File Error"
	echo "$_TARNAME is missing or has a value of '0'"
	re_run
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
	re_run
fi

# removing build directory
if [[ -f $_TARNAME ]]; then
	echo " ..removing build directory"
	rm -r "$_DISTD/$_NAME"
fi

# print summary
_FILESIZE=$(du -k "$_TARNAME" | cut -f1)
_FILEPATH=$(readlink -e $_TARNAME)
echo
echo "----------------------------------------------"
echo " Summary for $_TARNAME"
echo "----------------------------------------------"
echo
echo "Created ....: $_TARNAME"
echo "File Size ..: $_FILESIZE kb"
echo "MD5SUM: ....: $_MD5"
echo "SHASUM .....: $_SHA"
echo "Location ...: $_FILEPATH"
echo

# change directories back to $_BASED
cd "$_BASED"

exit 0

