#!/usr/bin/env bash
#
# Title ........: build-doc.sh
# Version ......: $Id$ 
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
#                 alone script on Linux provided the package requirements
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
#  The same method is used for all documentation.
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
BASEDIR=$(exec pwd)
DEVMAIL="wsjt-devel@lists.sourceforge.net"
ICONSDIR="../icons"
DICONSDIR="$BASEDIR/icons"
export PATH="$BASEDIR/asciidoc:$PATH"

# Document Build Vars
DEVG="$BASEDIR/dev-guide"
MAP65="$BASEDIR/map65"
QREF="$BASEDIR/quick-ref"
SIMJT="$BASEDIR/simjt"
WSJT="$BASEDIR/wsjt"
WSJTX="$BASEDIR/wsjtx"
WSPR="$BASEDIR/wspr"
WFMT="$BASEDIR/wfmt"
WSPRX="$BASEDIR/wsprx"

# Link build (linked css, images, js)
TOC="asciidoc.py -b xhtml11 -a toc2 -a iconsdir=$ICONSDIR -a max-width=1024px"

# data-uri build (embedded images, css, js)
DTOC="asciidoc.py -b xhtml11 -a data-uri -a toc2 -a iconsdir=$DICONSDIR -a max-width=1024px"

# all available documents
declare -a doc_ary=('map65' 'simjt' 'wsjt' 'wsjtx' 'wspr' 'wsprx' 'wfmt' 'quick-ref' 'dev-guide')

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

# Copy Images & Icons Dir to $app_name -----------------------------------------
function copy_image_folders() {

# data-uri does not like rpaths and wants the images at the ./source file level
# rsync is just easier to use than cp etc and it excludes .svn easier
mkdir -p $BASEDIR/$app_name/source/images
rsync -aq --exclude=.svn $BASEDIR/$app_name/images/ $BASEDIR/$app_name/source/images

}

# Remove Images & Icons Dir to $app_name ---------------------------------------
function remove_image_folders() {

# Remove all the files we used for data-uri building
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
		rm -f ./*.html
		sleep 1
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
	# suitable for use before commit code changes to SVN
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

function update_doc() {

# check for svn
which svn > /dev/null
if [ "$?" -eq "1" ]; then
	clear
	echo -e ${C_Y}"Subversion Error: Not Found"${C_NC}
	echo
	echo 'Please ensure Subversion is installed and can be'
	echo "found from the command line, then re-run $0"
	echo
	trap - SIGHUP SIGINT SIGQUIT SIGTERM SIGTSTP
	exit 1
fi

# start updating
clear
echo -e ${C_Y}"Updating Documentation Folders From SVN"${C_NC}
echo

# loop through each sub-folder in the array and svn update
for f in "${doc_ary[@]}"
	do
		app_name="$f"
		cd "$f/"
		dir=$(exec pwd)
		echo -e ${C_C}"updating: $dir"${C_NC}
		svn cleanup
		svn update
		cd "$BASEDIR"
	done
echo
echo -e ${C_Y}"Finishing Updating: ${doc_ary[*]}"${C_NC}
echo

}

# Hack to force updating the $app_name-main.adoc file to 
# update the HTML file footer Last Update time.
# This is a Bug in AsciiDoc as it does not update
# the -m or --time=mtime if the $app_name-main.adoc file
# if ::includes[] files are modified.
function update_timestamp() {

touch ./source/$app_name-main.adoc

}

################################################################################
# start the main script                                                        #
################################################################################

# Trap Ctrl+C, Ctrl+Z and quit signals
trap clean_exit SIGHUP SIGINT SIGQUIT SIGTERM SIGTSTP

option=$(echo ${1,,})

case "$option" in
	# Help ---------------------------------------------------------------------
	# Display Help Menu
	-h|-help|--help)
		app_menu_help	
	;;

	# Update -------------------------------------------------------------------
	# Update all SVN folders
	update|-update|--update)
		update_doc
	;;

	# Clean --------------------------------------------------------------------
	# Clean Files & Folders
	clean|-clean|--clean)
		clean_up
	;;

	# All Documents ------------------------------------------------------------
	# Linked Version
	all|-all|--all)
		doc_type=L
		build_all_guides
	;;

	# Embedded CSS, Images, JS
	dall|-dall|--dall)
		doc_type=D
		build_all_guides
	;;

	# Quick Reference ----------------------------------------------------------
	# Linked Version
	qref)
		display_name="Quick Reference"
		app_name="quick-ref"
		cd "$QREF"
		pre_file_check
		update_timestamp
		clear
		main_wording
		build_doc
		post_file_check
	;;

	# Embedded CSS, Images, JS
	dqref)
		display_name="Quick Reference data-uri"
		app_name="quick-ref"
		cd "$QREF"
		pre_file_check
		update_timestamp
		clear
		main_wording
		copy_image_folders
		build_ddoc
		remove_image_folders
		post_file_check
	;;

	# Dev-Guide ----------------------------------------------------------------
	# Linked Version
	devg)
		display_name="WSJT Developer's Guide for JTSDK"
		app_name="dev-guide"
		cd "$DEVG"
		pre_file_check
		update_timestamp
		clear
		main_wording
		build_doc
		post_file_check
	;;

	# Embedded CSS, Images, JS
	ddevg)
		display_name="WSJT Developer's Guide data-uri for JTSDK"
		app_name="dev-guide"
		cd "$DEVG"
		pre_file_check
		update_timestamp
		clear
		main_wording
		copy_image_folders
		build_ddoc
		remove_image_folders
		post_file_check
	;;

	# MAP65 --------------------------------------------------------------------
	# Linked Version
	map65)
		display_name="MAP65"
		app_name="map65"
		cd "$MAP65"
		pre_file_check
		update_timestamp
		clear
		main_wording
		build_doc
		post_file_check
	;;

	# Embedded CSS, Images, JS	
	dmap65)		
		display_name="MAP65 data-uri"
		app_name="map65"
		cd "$MAP65"
		pre_file_check
		update_timestamp
		clear
		main_wording
		copy_image_folders
		build_ddoc
		remove_image_folders
		post_file_check
	;;

	# SimJT --------------------------------------------------------------------
	# Linked Version
	simjt)		
		display_name="SimJT"
		app_name="simjt"
		cd "$SIMJT"
		pre_file_check
		update_timestamp
		clear
		main_wording
		build_doc
		post_file_check
	;;

	# Embedded CSS, Images, JS
	dsimjt)
		display_name="SimJT data-uri"
		app_name="simjt"
		cd "$SIMJT"
		pre_file_check
		update_timestamp
		clear
		main_wording
		copy_image_folders
		build_ddoc
		remove_image_folders
		post_file_check
	;;

	# WSJT ---------------------------------------------------------------------
	# Linked Versoin
	wsjt)
		display_name="WSJT"
		app_name="wsjt"
		cd "$WSJT"
		pre_file_check
		update_timestamp
		clear
		main_wording
		build_doc
		post_file_check
	;;

	# Embedded CSS, Images, JS
	dwsjt)
		display_name="WSJT"
		app_name="wsjt"
		cd "$WSJT"
		pre_file_check
		update_timestamp
		clear
		main_wording
		copy_image_folders
		build_ddoc
		remove_image_folders
		post_file_check
	;;

	# WSJT-X -------------------------------------------------------------------
	# Linked Version
	wsjtx)
		display_name="WSJT-X"
		app_name="wsjtx"
		cd "$WSJTX"
		pre_file_check
		update_timestamp
		clear
		main_wording
		build_doc
		post_file_check
	;;

	# Embedded CSS, Images, JS
	dwsjtx)
		display_name="WSJT-X data-uri"
		app_name="wsjtx"
		cd "$WSJTX"
		pre_file_check
		update_timestamp
		clear
		main_wording
		copy_image_folders
		build_ddoc
		remove_image_folders
		post_file_check
	;;

	# WSPR ---------------------------------------------------------------------
	# Linked version
	wspr)
		display_name="WSPR"
		app_name="wspr"
		cd "$WSPR"
		pre_file_check
		update_timestamp
		clear
		main_wording
		build_doc
		post_file_check
	;;

	# Embedded CSS, Images, JS
	dwspr)
		display_name="WSPR data-uri"
		app_name="wspr"
		cd "$WSPR"
		pre_file_check
		update_timestamp
		clear
		main_wording
		copy_image_folders
		build_ddoc
		remove_image_folders
		post_file_check
	;;

	# WSPR-FMT -----------------------------------------------------------------
	# Linked Version
	wfmt)
		display_name="WFMT"
		app_name="wfmt"
		cd "$WFMT"
		pre_file_check
		update_timestamp
		clear
		main_wording
		build_doc
		post_file_check
	;;


	# Embedded CSS, Images, JS
	dwfmt)
		display_name="WFMT"
		app_name="wfmt"
		cd "$WFMT"
		pre_file_check
		update_timestamp
		clear
		main_wording
		copy_image_folders
		build_ddoc
		remove_image_folders
		post_file_check
	;;

	# WSPR-X -------------------------------------------------------------------
	# Linked Version
	wsprx)
		display_name="WSPR-X"
		app_name="wsprx"
		cd "$WSPRX"
		pre_file_check
		update_timestamp
		clear
		main_wording
		build_doc
		post_file_check
	;;

	# Embedded CSS, Images, JS
	dwsprx)
		display_name="WSPR-X data-uri"
		app_name="wsprx"
		cd "$WSPRX"
		pre_file_check
		update_timestamp
		clear
		main_wording
		copy_image_folders
		build_ddoc
		remove_image_folders
		post_file_check

	;;

	# Anything Else, Display Help Message
	*)
		cd "$BASEDIR"
		app_menu_help
	;;
esac

exit 0
