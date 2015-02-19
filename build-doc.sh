#!/usr/bin/env bash
#
# Title ........: build-doc.sh
# Description ..: WSJT Documentation Main Build Script for Win32/Linux
# Project URL ..: http://sourceforge.net/projects/wsjt/
# Requires .....: Python 2.5 <=> 2.7, AsciiDoc, rsync, Awk, Bash, Coreutils
#
# Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
# Copyright ....: Copyright (C) 2014-2015 Joe Taylor, K1JT
# License ......: GPL-3
#
# Comment ......: This script is used with JTSDK v2 for Windows via the
#                 JTSDK-DOC environment (Cyg32) and should work as a stand
#                 alone script on Linux provided the package requirments
#                 are met.
#
# build-doc.sh is free software: you can redistribute it and/or modify it 
# under the terms of the GNU General Public License as published by the Free
# Software Foundation either version 3 of the License, or (at your option) any
# later version. 
#
# build-doc.sh is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

################################################################################

# BASIC USAGE
#
# [ build-doc.sh] [ option ]
#
# OPTIONS: All map65 simjt wsjt wsjtx wspr wsprx wfmt devg qref help clean
#
# BUILD LINKED
#  All .....: ./build-doc.sh all
#  WSJT-X...: ./build-doc.sh wsjtx
#
# BUILD DATA-URI - (Stand Alone)
#	All .....: ./build-doc.sh dall
#   WSJT-X ..: ./build-doc.sh dwsjtx
#
# CLEAN FOLDERS & FILES
#  All .....: ./build-doc.sh clean
#
# NOTE(s)
#  The same method is used for all documentaion.
#  The prefix "d" designates data-uri or a stand
#  alone version of the document
#
################################################################################


# Exit on error
set -e

################################################################################
# Variables                                                                    #
################################################################################

# Main variables
SCRIPTVER="0.9.0"
BASEDIR=$(exec pwd)
DEVMAIL="wsjt-devel@lists.berlios.de"
MAP65="$BASEDIR/map65"
SIMJT="$BASEDIR/simjt"
WSJT="$BASEDIR/wsjt"
WSJTX="$BASEDIR/wsjtx"
WSPR="$BASEDIR/wspr"
WFMT="$BASEDIR/wfmt"
WSPRX="$BASEDIR/wsprx"
DEVG="$BASEDIR/dev-guide"
DEVG2="$BASEDIR/dev-guide2"
QREF="$BASEDIR/quick-ref"
ICONSDIR="../icons"
DICONSDIR="$BASEDIR/icons"
export PATH="$BASEDIR/asciidoc:$PATH"

# Link build (linked css, images, js)
TOC="asciidoc.py -b xhtml11 -a toc2 -a iconsdir=$ICONSDIR -a max-width=1024px"

# data-uri build (embedded images, css, js)
DTOC="asciidoc.py -b xhtml11 -a data-uri -a toc2 -a iconsdir=$DICONSDIR -a max-width=1024px"

# build manpage (under construction)
# data-uri builds (embedded images, css, js)
# MTOC="a2x.py --format=manpage --doctype=manpage --no-xmllint -o $OUPUT_FILE $INPUT_FILE"

# all available documents
declare -a doc_ary=('map65' 'simjt' 'wsjt' 'wsjtx' 'wspr' 'wsprx' 'wfmt' 'quick-ref' 'dev-guide' 'dev-guide2')

# Color variables
C_R='\033[01;31m'		# red
C_G='\033[01;32m'		# green
C_Y='\033[01;33m'		# yellow
C_C='\033[01;36m'		# cyan
C_NC='\033[01;37m'		# no color

################################################################################
# Functions                                                                    #
################################################################################

# clean-exit -------------------------------------------------------------------
function clean_exit() {
	clear
	echo -e ${C_R}'*** SIGNAL CAUGHT, PERFORMING CLEAN EXIT ***'${C_NC}
	echo
	echo -e ${C_Y}'Removing Temorary Folders'${C_NC}
	echo

	# Delete any /tmp folders 
	for i in "${doc_ary[@]}"
		do
			cd "$BASEDIR"
			TMP="$BASEDIR/$i/tmp"
			echo -e ${C_C}".. cleaning $TMP"${C_NC}
			rm -rf "$TMP"
	done

# ask to remove *.html files	
while [ 1 ]
do
	echo
	read -p "Remove HTML Files? [ Y /N ]: " yn
	case $yn in
	[Yy]* )
		clear
		echo -e ${C_Y}"Removing All HTML Files ... "${C_NC}
		echo
		# loop through all docs
		for i in "${doc_ary[@]}"
		do
			cd "$BASEDIR"
			clean_dir="$BASEDIR/$i"
			echo -e ${C_C}".. cleaning $clean_dir/*.html"${C_NC}
			rm -rf "$clean_dir"/*.html
			cd "$BASEDIR"
		done
		echo
		echo -e ${C_Y}"Clean up complete"${C_NC}
		echo
		exit 0
	;;
	[Nn]* )
		echo
		echo -e ${C_Y}"Exiting build script without cleaning"${C_NC}
		echo
		exit 0
	;;
	* )
		clear
		echo -e ${C_Y}"Please use "Y" yes or "N" No."${C_NC}
	;;
	esac
done
trap - SIGHUP SIGINT SIGQUIT SIGTERM SIGTSTP
exit 0
}	

# Build All Documentation ------------------------------------------------------
function build_all_guides() {
	clear
	echo
	echo -e ${C_Y}"Building All WSJT Documentation"${C_NC}
	echo
	while [ 1 ]
	do
		for f in "${doc_ary[@]}"
		do
			app_name="$f"
			cd "$f/"
			if [[ $doc_type == "D" ]]
			then
				echo -e ${C_C}".. building data-uri version for ( $f )"${C_NC}
				copy_image_folders
				build_ddoc
				remove_image_folders
			fi
			if [[ $doc_type == "L" ]]
			then
				echo -e ${C_C}".. building linked version for ( $f )"${C_NC}
				build_doc
			fi
			cd "$BASEDIR"
		done
		echo
		echo -e ${C_Y}'Finished Building All Documentation'${C_NC}
		echo
	break
	done
}

# Build linked (css, images, js) html documents --------------------------------
function build_doc() {
	$TOC -o $app_name-main.html ./source/$app_name-main.adoc
}
 
# Build data-uri (embedded css, images, js ) documents -------------------------
function build_ddoc() {

	$DTOC -o $app_name-main.html ./source/$app_name-main.adoc

}

# Build manpages ---------------------------------------------------------------
function build_man() {

	# * Need input and output method
	# * Manpages should reside in source trees, but there's no
	#   reason they cannot be built externally, then update the 
	#   source tree file as a fully formated manpage.
	$MTOC -o $app_name.1 ./source/$app_name.1.txt

}

# Copy Images & Icons Dir to $app_name -----------------------------------------
function copy_image_folders() {

# data-uri does not like rpaths and wants the images at the ./source file level
# rsync is just easier to use than cp etc and it excludes .svn easier
mkdir -p $BASEDIR/$app_name/source/images
rsync -aq --exclude=.svn $BASEDIR/$app_name/images/ $BASEDIR/$app_name/source/images

}

# Remove Images & Icons Dir to $app_name ---------------------------------------
function remove_image_folders() {

# remove all the files we used for data-uri building
rm -r $BASEDIR/$app_name/source/images

}

# Main wording -----------------------------------------------------------------
function main_wording() {

	echo -e ${C_Y}"Building $display_name\n"${C_NC}

}

# Location wording -------------------------------------------------------------
function location_wording() {

	echo -e ${C_Y}"$display_name file saved to:"${C_NC}${C_C} "$base_dir/$app_name" ${C_NC}

}

# Tail wording -----------------------------------------------------------------
function tail_wording() {

	echo -e ${C_G}"Finished Building All Guides\n"${C_NC}

}

# Check for file before building -----------------------------------------------
function pre_file_check() {

if test -e ./*.html
then 

while [ 1 ]
do
	clear
	echo -e ${C_R}"$(pwd) contains previous build files"${C_NC}
	echo
	read -p "Remove old file before continuing? [ Y/N ]: " yn
	case $yn in
	[Yy]* )
		clear
		echo -e ${C_Y}".. removing old files ... "${C_NC}
		sleep 1
		rm ./*.html
		return
	;;
	[Nn]* )
		return
	;;
	* )
		clear
		echo -e ${C_Y}"Please answer with "Y" yes or "N" No."${C_NC}
		echo
	;;
	esac
done

fi
}

# Check for file after build ---------------------------------------------------
function post_file_check() {

if test -e ./*.html
  then
    clear
    echo -e ${C_Y}"Finished Building $display_name"${C_NC}
    echo
    echo -e ${C_Y}"File Location: $(pwd)"${C_NC}
    echo
    return

else
	clear
	echo -e ${C_R}"$display_name BUILD ERROR - No File(s) Found"${C_NC}
	echo "Gathering System Information"
	PY_VER=$(python -V)	
	SYS_INFO=$(uname -a)
	SVN_VER=$(svn info | grep ^Revision)
	BASH_VER=$(bash --version |awk 'FNR==1')
	S_HIGH=$(source-highlight --version |awk 'FNR==1')
	echo "Script version: v$SCRIPTVER"
	echo "Repository Version: ${SVN_VER: -4}"
	echo "$SYS_INFO"
	echo "$BASH_VER"
	echo "$S_HIGH"
	echo
	echo "Please Email Info to WSJT Dev-Group: $DEVMAIL"
	echo "Provide as much detail as you can about the problem."
	echo -e "\nThank You."
	echo
	exit 1
fi
}


# Clean Folders ----------------------------------------------------------------
function clean_up() {
	# Delete any /tmp folders then remove HTML files
	# suitable for use before sommit code changes to SVN
	clear
	echo
	echo -e ${C_Y}'Cleaning Temp Folders and HTML Files'${C_NC}
	echo
	for i in "${doc_ary[@]}"
		do
			cd "$BASEDIR"
			TMP="$BASEDIR/$i/tmp"
			clean_dir="$BASEDIR/$i"
			echo -e ${C_C}".. cleaning ( $i ) tmp && *.html"${C_NC}
			# clean the folders
			rm -rf "$TMP"
			# clean html files
			rm -rf "$clean_dir"/*.html
	done
	echo
	echo -e ${C_Y}'Finished Clean up'${C_NC}
	echo
}

# Main help menu ---------------------------------------------------------------
function app_menu_help() {
	clear
	echo -e ${C_G}"WSJT DOCUMENTATION HELP MENU\n"${C_NC}
	echo 'USAGE: [ build-doc.sh] [ option ]'
	echo
	echo 'OPTION: All map65 simjt wsjt wsjtx wspr wsprx'
	echo '        wfmt devg devg2 qref help clean'
	echo
	echo 'BUILD LINKED:'
	echo '-----------------------------------'
	echo '  All .....: ./build-doc.sh all'
	echo '  WSJT-X...: ./build-doc.sh wsjtx'
	echo
	echo 'BUILD DATA-URI - (Stand Alone)'
	echo '----------------------------------'
	echo '  All .....: ./build-doc.sh dall'
	echo '  WSJT-X...: ./build-doc.sh dwsjtx'
	echo
	echo 'CLEAN FOLDERS & FILES'
	echo '----------------------------------'
	echo '  All .....: ./build-doc.sh clean'
	echo
	echo 'NOTE(s)'
	echo '----------------------------------'
	echo 'The same method is used for all documentaion.'
	echo 'The prefix "d" designates data-uri or a stand'
	echo 'alone version of the document'
	echo
}

################################################################################
# start the main script                                                        #
################################################################################

# Trap Ctrl+C, Ctrl+Z and quit signals
trap clean_exit SIGHUP SIGINT SIGQUIT SIGTERM SIGTSTP

# Display help if $1 is "" or "help" 
if [[ $1 = "" ]] || [[ $1 = "help" ]]
  then
    app_menu_help

# Clean Files & Folders
elif [[ $1 = "clean" ]]
	then
	clean_up
	
# Build All Guides
# Linked version
elif [[ $1 = "all" ]]
	then
	doc_type=L
	build_all_guides

# Build All Documentation
# embedded css, images, js
elif [[ $1 = "dall" ]]
	then
	doc_type=D
	build_all_guides


# Quick Reference Guides -------------------------------------------------------
# Linked version
elif [[ $1 = "qref" ]]
	then
		display_name="Quick Reference"
		app_name="quick-ref"
		cd "$QREF"
		pre_file_check
		clear
		main_wording
		build_doc
		post_file_check

# embedded css, images, js
elif [[ $1 = "dqref" ]]
	then
		display_name="Quick Reference data-uri"
		app_name="quick-ref"
		cd "$QREF"
		pre_file_check
		clear
		main_wording
		copy_image_folders
		build_ddoc
		remove_image_folders
		post_file_check

# Development Guide for JTSDK v1.0.0 -------------------------------------------
# Linked version
elif [[ $1 = "devg" ]]
	then
		display_name="WSJT Developer's Guide for JTSDK v1"
		app_name="dev-guide"
		cd "$DEVG"
		pre_file_check
		clear
		main_wording
		build_doc
		post_file_check

# embedded css, images, js
elif [[ $1 = "ddevg" ]]
	then
		display_name="WSJT Developer's Guide data-uri for JTSDK v1"
		app_name="dev-guide"
		cd "$DEVG"
		pre_file_check
		clear
		main_wording
		copy_image_folders
		build_ddoc
		remove_image_folders
		post_file_check

# Development Guide for JTSDK v2.0.0 -------------------------------------------
# Linked version
elif [[ $1 = "devg2" ]]
	then
		display_name="WSJT Developer's Guide for JTSDK v2"
		app_name="dev-guide2"
		cd "$DEVG2"
		pre_file_check
		clear
		main_wording
		build_doc
		post_file_check

# embedded css, images, js
elif [[ $1 = "ddevg2" ]]
	then
		display_name="WSJT Developer's Guide data-uri for JTSDK v2"
		app_name="dev-guide2"
		cd "$DEVG2"
		pre_file_check
		clear
		main_wording
		copy_image_folders
		build_ddoc
		remove_image_folders
		post_file_check

# MAP65 build ------------------------------------------------------------------
# Linked version
elif [[ $1 = "map65" ]]
	then
		display_name="MAP65"
		app_name="map65"
		cd "$MAP65"
		pre_file_check
		clear
		main_wording
		build_doc
		post_file_check
		
# embedded css, images, js
elif [[ $1 = "dmap65" ]]
	then
		display_name="MAP65 data-uri"
		app_name="map65"
		cd "$MAP65"
		pre_file_check
		clear
		main_wording
		copy_image_folders
		build_ddoc
		remove_image_folders
		post_file_check
		
# SimJT build ------------------------------------------------------------------
# Linked version
elif [[ $1 = "simjt" ]]
	then
		display_name="SimJT"
		app_name="simjt"
		cd "$SIMJT"
		pre_file_check
		clear
		main_wording
		build_doc
		post_file_check

# embedded css, images, js
elif [[ $1 = "dsimjt" ]]
	then
		display_name="SimJT data-uri"
		app_name="simjt"
		cd "$SIMJT"
		pre_file_check
		clear
		main_wording
		copy_image_folders
		build_ddoc
		remove_image_folders
		post_file_check

# WSJT build -------------------------------------------------------------------
# Linked versoin
elif [[ $1 = "wsjt" ]]
	then
		display_name="WSJT"
		app_name="wsjt"
		cd "$WSJT"
		pre_file_check
		clear
		main_wording
		build_doc
		post_file_check

# embedded css, images, js
elif [[ $1 = "dwsjt" ]]
	then
		display_name="WSJT"
		app_name="wsjt"
		cd "$WSJT"
		pre_file_check
		clear
		main_wording
		copy_image_folders
		build_ddoc
		remove_image_folders
		post_file_check

# WSJT-X build -----------------------------------------------------------------
# Linked version
elif [[ $1 = "wsjtx" ]]
	then
		display_name="WSJT-X"
		app_name="wsjtx"
		cd "$WSJTX"
		pre_file_check
		clear
		main_wording
		build_doc
		post_file_check

# embedded css, images, js
elif [[ $1 = "dwsjtx" ]]
	then
		display_name="WSJT-X data-uri"
		app_name="wsjtx"
		cd "$WSJTX"
		pre_file_check
		clear
		main_wording
		copy_image_folders
		build_ddoc
		remove_image_folders
		post_file_check

# WSPR build -------------------------------------------------------------------
# Linked version
elif [[ $1 = "wspr" ]]
	then
		display_name="WSPR"
		app_name="wspr"
		cd "$WSPR"
		pre_file_check
		clear
		main_wording
		build_doc
		post_file_check

# embedded css, images, js
elif [[ $1 = "dwspr" ]]
	then
		display_name="WSPR data-uri"
		app_name="wspr"
		cd "$WSPR"
		pre_file_check
		clear
		main_wording
		copy_image_folders
		build_ddoc
		remove_image_folders
		post_file_check
		
# WSPR-FMT build ---------------------------------------------------------------
# Linked version
elif [[ $1 = "wfmt" ]]
	then
		display_name="WFMT"
		app_name="wfmt"
		cd "$WFMT"
		pre_file_check
		clear
		main_wording
		build_doc
		post_file_check

# embedded css, images, js
elif [[ $1 = "dwfmt" ]]
	then
		display_name="WFMT"
		app_name="wfmt"
		cd "$WFMT"
		pre_file_check
		clear
		main_wording
		copy_image_folders
		build_ddoc
		remove_image_folders
		post_file_check
		
# WSPR-X build -----------------------------------------------------------------
# Linked version
elif [[ $1 = "wsprx" ]]
	then
		display_name="WSPR-X"
		app_name="wsprx"
		cd "$WSPRX"
		pre_file_check
		clear
		main_wording
		build_doc
		post_file_check

# embedded css, images, js
elif [[ $1 = "dwsprx" ]]
	then
		display_name="WSPR-X data-uri"
		app_name="wsprx"
		cd "$WSPRX"
		pre_file_check
		clear
		main_wording
		copy_image_folders
		build_ddoc
		remove_image_folders
		post_file_check

# Anything else for $1 do help -------------------------------------------------
else
	cd "$BASEDIR"
	app_menu_help
fi
exit 0
