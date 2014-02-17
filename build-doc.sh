#!/usr/bin/env bash
# Title           : build-doc.sh
# Description     : WSJT Documentation Main Build Script for *Nix
# Author          : KI7MT
# Email           : ki7mt@yahoo.com
# Date            : 2014
# Version         : 0.8.1
# Usage           : ./build-doc.sh [ option ]
# Notes           : Requires: Python 2.7+, AsciiDoc, GNU Source Highlight
# Copyright       : GPLv(3)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#==============================================================================

# TO-DO:
# - When the next WSJT-X is released:
# -- a. add WSJT-X to short_list array
# -- b. remove WSJT-X Special build function

# Exit on error
set -e

#######################
# Variables           #
#######################

# Main variables
SCRIPTVER="0.8.1"
SCRIPTNAME=$(basename $0)
BASEDIR=$(pwd)
export PATH="$PATH:$BASEDIR/asciidoc"
DEVMAIL="wsjt-devel@lists.berlios.de"
MAP65="$BASEDIR/map65"
SIMJT="$BASEDIR/simjt"
WSJT="$BASEDIR/wsjt"
WSJTX="$BASEDIR/wsjtx"
WSPR="$BASEDIR/wspr"
WSPRX="$BASEDIR/wsprx"
DEVG="$BASEDIR/dev-guide"
QUICKR="$BASEDIR/quick-ref"
TOC="asciidoc.py -b xhtml11 -a toc2 -a iconsdir=../icons -a max-width=1024px"
declare -a all_apps_ary=('map65' 'simjt' 'wsjt' 'wsjtx' 'wspr' 'wsprx' \
'quick-ref' 'dev-guide' )
declare -a short_list=('map65' 'simjt' 'wsjt' 'wspr' 'wsprx')

# Color variables
C_R='\033[01;31m'		# red
C_G='\033[01;32m'		# green
C_Y='\033[01;33m'		# yellow
C_C='\033[01;36m'		# cyan
C_NC='\033[01;37m'		# no color

#######################
# Functions           #
#######################

# clean-exit
function clean_exit() {
	clear
	echo -e ${C_R}'*** SIGNAL CAUGHT, PERFORMING CLEAN EXIT ***'${C_NC}
	echo
	echo -e ${C_Y}'Removing Temorary Folders'${C_NC}

	# Delete any /tmp folders 
	for i in "${all_apps_ary[@]}"
		do
			cd "$BASEDIR"
			TMP="$BASEDIR/$i/tmp"
			echo -e ${C_C}". Cleaning $TMP"${C_NC}
			rm -rf "$TMP"
	done

# Yy / Nn answer on removing HTML files	
while [ 1 ]
do
	echo
	read -p "Remove HTML Files? [ Yy /Nn ]: " yn
	case $yn in
	[Yy]* )
		clear
		echo -e ${C_Y}"Removing All HTML Files ... "${C_NC}
		for i in "${all_apps_ary[@]}"
		do
			cd "$BASEDIR"
			clean_dir="$BASEDIR/$i"
			echo -e ${C_C}". Cleaning $clean_dir/*.html"${C_NC}
			rm -rf "$clean_dir"/*.html
			cd "$BASEDIR"
		done
		echo
		echo -e ${C_G}"Done .. Now Exiting"${C_NC}
		echo
		exit 0
	;;
	[Nn]* )
		exit 0
	;;
	* )
		clear
		echo -e ${C_Y}"Please use "Y" yes or "N" No."${C_NC}
	;;
	esac
done
trap - SIGINT SIGQUIT SIGTSTP
exit 0
}	

# Build All Guides
function build_all_guides() {
	clear
	pre_file_check
	echo -e ${C_Y}"Building All WSJT Documentation"${C_NC}
	echo

while [ 1 ]
do
	read -p "Please confirm to start building? [ Yy / Nn ]: " yn
	case $yn in
	[Yy]* )
		clear
		echo -e ${C_Y}"Building All WSJT Documentation"${C_NC}

		# Short List Loop: map65 simjt wsjt wspr wsprx
		for f in "${short_list[@]}"
		do
			app_name="$f"
			dir_=$(echo $f | tr [:lower:] [:upper:])
			cd "$dir_"
			echo -e ${C_C}"Building $dir_"${C_NC}
			build_doc
			echo -e ${C_G}". $app_name-main.html"${C_NC}
			cd "$BASEDIR"
		done

		# WSJT-X: special build until the next application release
		# Must keep wsjtx-main-toc2.html as it's ahrd coded in the app.
		echo -e ${C_C}'Building WSJT-X'${C_NC}
		app_name="wsjtx"
		cd "$WSJTX"
		build_wsjtx
		echo -e ${C_G}". wsjtx-main-toc2.html"${C_NC}

		# QUICK-REF
		echo -e ${C_C}'Building Quick Reference'${C_NC}
		cd "$BASEDIR/quick-ref"
		quick_ref
		echo -e ${C_G}". quick-reference.html"${C_NC}
		
		# DEV-GUIDE
		echo -e ${C_C}'Building Development Guide'${C_NC}
		cd "$BASEDIR/dev-guide"
		dev_guide
		echo -e ${C_G}".dev-guide-main.html"${C_NC}
		echo
		echo -e ${C_Y}'Finished Building All Documentation'${C_NC}
		return
	;;
	[Nn]* )
		clear
		echo -e ${C_Y}"Ok, returning to the shell"${C_NC}
		echo
		return
	;;
	* )
		clear
		echo -e ${C_Y}"Please answer with "Y" yes or "N" No."${C_NC}
		echo
	;;
	esac
done
}

# Special build for wsjtx-main-toc2.html
function build_wsjtx() {
	$TOC -o $app_name-main-toc2.html ./source/$app_name-main.adoc
 } # End build document string

# Build documents
function build_doc() {
	$TOC -o $app_name-main.html ./source/$app_name-main.adoc
 } # End build document string

# Build Quick Reference Guide 
function quick_ref() {
	$TOC -o quick-reference.html ./source/quick-ref-main.adoc
} # End Quick Reference Guide

# Build Developer's Guide
function dev_guide() {
	$TOC -o wsjt-dev-guide.html ./source/dev-guide-main.adoc
} # End Developer's Guide

# Main wording
function main_wording() {
	echo -e ${C_Y}"Building $display_name\n"${C_NC}
} # End main wording

# Quick reference guide wording
function quick_ref_wording() {
	echo -e ${C_Y}"Building Quick Reference Guide\n"${C_NC}
} # End quick reference guide wording

# Development guide wording
function dev_guide_wording() {
	echo -e ${C_Y}"Building Development Guide\n"${C_NC}
} # End development guide wording

function location_wording() {
	echo -e ${C_Y}"$display_name file saved to:"${C_NC}${C_C} "$base_dir/$app_name" ${C_NC}
}

function tail_wording() {
	echo -e ${C_G}"Finished Building All Guides\n"${C_NC}
}

# Check for file before building
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
		echo -e ${C_Y}"Removing old html files ... "${C_NC}
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
} # End check for files before building

# Check for file after build
# TO-DO: Use associative array to validate build manifest
function post_file_check() {

if test -e ./*.html
  then
    clear
    echo -e ${C_Y}"Finished Building $display_name"${C_NC}
    echo
    echo -e ${C_Y}"File(s) located in: $(pwd)"${C_NC}
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
} # End file check after build

# Main help menu
function app_menu_help() {
	clear
	echo -e ${C_G}"WSJT DOCUMENTATION HELP MENU\n"${C_NC}
	echo 'USAGE: build-doc.sh [ option ]'
	echo
	echo 'OPTION: All map65 simjt wsjt wsjtx wspr wsprx'
	echo '        quick-ref dev-guide help'
	echo
	echo 'Example(s):'
	echo 'Build All Guides:  ./build-doc.sh all'
	echo 'Build WSJT-X Only: ./build-doc.sh wsjtx'
	echo
	echo 'The same method is used for all applications.'
} # End main menu help

#######################
# start the main script
#######################

# Trap Ctrl+C, Ctrl+Z and quit signals
trap clean_exit SIGINT SIGQUIT SIGTSTP

# **************************** NEW BUILD LOGIC *********************************
# Logic: 
# ./build-doc.sh $1
# ./build-doc.sh [ app-name ]
# $1 Options: map65 simjt wsjt wsjtx wspr wsprx quick-ref dev-guide
#
# ******************************************************************************

# Display help if $1 is "" or "help" 
if [[ $1 = "" ]] || [[ $1 = "help" ]]
  then
    app_menu_help

# Build All Guides
elif [[ $1 = "all" ]]
	then
		build_all_guides	

# Quick Reference Guide
elif [[ $1 = "quick-ref" ]]
	then
		display_name="Quick Reference"
		cd "$QUICKR"
		pre_file_check
		clear
		main_wording
		quick_ref
		post_file_check

# Development Guide
elif [[ $1 = "dev-guide" ]]
	then
		display_name="WSJT Developer's Guide"
		cd "$DEVG"
		pre_file_check
		clear
		main_wording
		dev_guide
		post_file_check

# MAP65 build
#
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

#
# SimJT build
#
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

#
# WSJT build
#
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

#
# WSJT-X build
#
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

#
# WSPR build
#
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

#
# WSPR-X build
#
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

#
# Anything else for $1 do help
#
else
	cd "$BASEDIR"
	app_menu_help
fi
exit 0
