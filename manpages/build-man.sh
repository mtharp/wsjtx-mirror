#!/usr/bin/env bash
#
# Manpage generation script for WSPR.
# Builds then moves manpages to: /wspr/manpages/man1
# Files must be present or the script will error with exit 1
#
# Author:       Greg Beam, <ki7mt@yahoo.com>
# Copyright:    None
# Usage:		build-man.sh $1
# Available: 	all or specific manpage:
# Manpages: 	wspr, wspr0, fmtest, fmtave, fcal, fmeasure
#
# error on exit
set -e

_OPTION=$1
_A2XOPT="a2x --doctype manpage --format manpage --no-xmllint"

# test for a2x (AsciiDoc) installation, requires Python2.5 thru 2.7
# Will 'NOT' run with Python3.x
a2x --version > /dev/null 2>&1

if [[ $? -ne 0 ]]; then
    echo
    echo "AsciiDoc is required to build Manpages"
    echo "Please install Asciidoc to continue."
    echo
    echo "See the ~/wspr/manpages/README"
    echo "for AsciiDoc setup instruction."
    echo
    exit 1
fi

# setup list of manpages to build
array=('wspr' 'wspr0' 'wsprcode' 'fmtest' 'fmtave' 'fcal' 'fmeasure')

# build all man pages
if [[ $_OPTION = "all" ]]; then

    echo
    echo "Building All Maqnpages. Be patient, this can take a few minutes!"

        for i in "${array[@]}"
            do
            $_A2XOPT $i.1.txt
            mv $i.1 ./man1/
            echo ".. finished $i"
        done

    echo "Finished building pages"
    echo "Location: "$(pwd)/man1
    echo
    exit 0

#build specific manpages
elif [[ $_OPTION = "wspr" ]]; then
    echo "Building $1"
    $_A2XOPT $_OPTION.1.txt
    mv $_OPTION.1 ./man1/
    echo ".. finished"
    echo
    exit 0

elif [[ $_OPTION = "wspr0" ]]; then
    echo "Building $_OPTION"
    $_A2XOPT $_OPTION.1.txt
    mv $_OPTION.1 ./man1/
    echo ".. finished"
    echo
    exit 0

elif [[ $_OPTION = "wsprcode" ]]; then
    echo "Building $_OPTION"
    $_A2XOPT $_OPTION.1.txt
    mv $_OPTION.1 ./man1/
    echo ".. finished"
    echo
    exit 0

elif [[ $_OPTION = "fmtest" ]]; then
    echo "Building $_OPTION"
    $_A2XOPT $_OPTION.1.txt
    mv $_OPTION.1 ./man1/
    echo ".. finished"
    echo
    exit 0

elif [[ $_OPTION = "fmtave" ]]; then
    echo "Building $_OPTION"
    $_A2XOPT $_OPTION.1.txt
    mv $_OPTION.1 ./man1/
    echo ".. finished"
    echo
    exit 0

elif [[ $_OPTION = "fcal" ]]; then
    echo "Building $_OPTION"
    $_A2XOPT $_OPTION.1.txt
    mv $_OPTION.1 ./man1/
    echo ".. finished"
    echo
    exit 0

elif [[ $_OPTION = "fmeasure" ]]; then
    echo "Building $1"
    $_A2XOPT $_OPTION.1.txt
    mv $_OPTION.1 ./man1/
    echo ".. finished"
    echo
    exit 0

else
    clear
    echo
    echo '========================'
    echo "HELP - GENERATE MAPPAGES"
    echo '========================'
    echo		
    echo "Build All Mangapges, type:    ./build-man.sh all"
    echo "Build Specific Manpage, type  ./build-man.sh <NAME>"
    echo
    echo "Availabe Manpages <NAMES>:"
    echo ${array[@]}	
    echo
    exit 1
fi

exit 0

