#!/usr/bin/env bash
#
# Manpage generation script for WSPR.
# Builds then moves manpages to: /wspr/manpages/man1
#
# Author		Greg Beam, <ki7mt@yahoo.com>
# Copyright		None
# Usage			build-man.sh $1
# Example		./build-man.sh wspr.1.txt
#
# Ooptions		all or specific manpage:
# Manpages		wspr.1.txt, wspr0.1.txt, wsprcode.1.txt, fmtest.1.txt
#				fmtave.1.txt, fcal.1.txt, fmeasure.1.txt
#

# error on exit
set -e

_OPTION=$1
_A2XOPT="a2x --doctype manpage --format manpage --no-xmllint"
manpage_array=$(ls *.1.txt)

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

# build all man pages
if [[ $_OPTION = "all" ]]; then
	clear
    echo
    echo "Building All Maqnpages. Be patient, this can take a few minutes!"

        for i in ${manpage_array[@]}
            do
            $_A2XOPT $i
            mv ${i%.*} ./man1/
            echo '.. finished' ${i%.*}
        done
    echo
    echo "Finished building all manpages"
    echo 'Location ..:' $(pwd)/man1
    echo
    exit 0

# build a specific manpage
else
		# disply help if manypage source not found
		if [[ ! -f $_OPTION ]]; then
		    clear
	    	echo
	    	echo '========================'
	    	echo "HELP - GENERATE MAPPAGES"
	    	echo '========================'
	    	echo
	    	echo "Manpage Source: [ $_OPTION ] was not found"
	    	echo
	    	echo 'Build All Mangapges .....: ./build-man.sh all'
	    	echo 'Build Specific Manpage ..: ./build-man.sh <NAME>'
	    	echo
	    	echo 'Availabe Manpages <NAMES>:'
	    	echo
	    	echo ${manpage_array[@]}	
	    	echo
	    	exit 1
		fi

	# build the requested manpage
	clear
	echo "Building $_OPTION"
	$_A2XOPT $1
	mv ${_OPTION%.*} ./man1/
	echo 'Finished building ..: '${_OPTION%.*}
	echo 'Location ...........: '$(pwd)/man1/${_OPTION%.*}
	echo
	exit 0
fi

exit 0
