#!/usr/bin/env bash
# Title           : build-doc.sh
# Description     : WSJT Documentation Main Build Script
# Author          : KI7MT
# Email           : ki7mt@yahoo.com
# Date            : FEB-02-2014
# Version         : 0.7.0
# Usage           : ./build-doc.sh [ option ]
# Notes           : Requires: Python 2.7+, AsciiDoc, GNU Source Highlight
#==============================================================================

# Exit on error
set -e

#######################
# Variables           #
#######################

# Main variables
SCRIPTNAME=$(basename $0)
BASEDIR=$(pwd)
export PATH=$BASEDIR/asciidoc:$PATH
DEVMAIL="wsjt-devel@lists.berlios.de"
ICONS_DIR="$(pwd)/icons"
FUNC="$BASEDIR/functions"
MAP65="$BASEDIR/map65"
SIMJT="$BASEDIR/simjt"
WSJT="$BASEDIR/wsjt"
WSJTX="$BASEDIR/wsjtx"
WSPR="$BASEDIR/wspr"
WSPRX="$BASEDIR/wsprx"
NTOC="asciidoc.py -b xhtml11 -a iconsdir=../icons -a max-width=1024px"
TOC1="asciidoc.py -b xhtml11 -a toc -a iconsdir=../icons -a max-width=1024px"
TOC2="asciidoc.py -b xhtml11 -a toc2 -a iconsdir=../icons -a max-width=1024px"

# Color variables
C_R='\033[01;31m'	# red
C_G='\033[01;32m'	# green
C_Y='\033[01;33m'	# yellow
C_C='\033[01;36m'	# cyan
C_NC='\033[01;37m'	# no color

# Array variables
declare -a all_apps_ary=('map65' 'simjt' 'wsjt' 'wsjtx' 'wspr' 'wsprx')
declare -a all_toc_ary=('build_ntoc' 'build_toc1' 'build_toc2')

#######################
# Functions           #
#######################

# clean-exit
# TO-DO: Loop through all directories to clean <app-name>/tmp
function clean_exit() {
	clear
	echo -e ${C_Y}'Signal caught, cleaning up and exiting.'${C_NC}
	sleep 1
	[ -d "$base_dir/tmp" ] && rm -r $base_dir/tmp
	echo -e ${C_Y}'. Done'${C_NC}
	exit 0
}

# No toc
function build_ntoc() {
    $NTOC -o $app_name-main-ntoc.html ./source/$app_name-main.adoc
} # End no toc

# Top toc
function build_toc1() {
    $TOC1 -o $app_name-main-toc1.html ./source/$app_name-main.adoc
} # End top toc

# Left toc
function build_toc2() {
    $TOC2 -o $app_name-main-toc2.html ./source/$app_name-main.adoc
 } # End left toc

# Quick reference guide 
function quick_ref() {
    $TOC2 -o quick-reference.html ./source/quick-reference.adoc
} # End quick reference guide

# Development Guide
function dev_guide() {
    "TOC2" -o dev-guide.html ./source/dev-guide.adoc
} # End development guide

# Main wording
function main_wording() {
echo -e ${C_Y}"Building Documentation for $display_name\n"${C_NC}
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

# Check for file before building
function pre_file_check() {

if [[ $(ls -1 ./*.html 2>/dev/null | wc -l) > 0 ]]
then 
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
		echo "Please answer with "Y" yes or "N" No.";;
	esac
fi
} # End check for files before building

# Check for file after build
# TO-DO: Use associative array to validate build manifest
function post_file_check() {
	if [[ $(ls -1 ./*.html 2>/dev/null | wc -l) > 0 ]]
	then
		clear
		echo -e ${C_Y}"Finished Building $display_name Documentation"${C_NC}
		echo
		echo -e ${C_C}"File(s) located in: $(pwd)"${C_NC}
		echo
		return
	else
		clear
		echo -e ${C_R}"$display_name DOCS BUILD ERROR - No File(s) Found"
		echo -e "Contact the Dev-Group: $DEVMAIL"
		echo
		exit 1
	fi
} # End file check after build

# Main help menu
function app_menu_help() {
	clear
    echo -e ${C_G}"WSJT DOCUMENTATION MAIN HELP MENU\n"${C_NC}
    echo 'USAGE: build-doc.sh [ option1 ] [ option2 ]'
	echo
	echo 'OPTION1: map65 simjt wsjt wsjtx wspr wsprx help'
	echo 'OPTION2: ntoc toc1 toc2 all'
	echo
    echo 'Examples:'
	echo 'All TOC Versions: ./build-doc.sh wsjtx all'
	echo 'No TOC:           ./build-doc.sh wsjtx ntoc'
	echo 'Top TOC Only:     ./build-doc.sh wsjtx toc1'
	echo 'Left TOC only:    ./build-doc,sh wsjtx toc2'
	echo
	echo 'The same method is used for all applications .'
	echo 'For Help: ./build-doc.sh help'
	
} # End main menu help

#######################
# start the main script
#######################

# Trap Ctrl+C, Ctrl+Z and quit signals
trap '' SIGINT SIGQUIT SIGTSTP

# **************************** NEW BUILD LOGIC *********************************
# Logic: 
# ./build-doc.sh $1 $2
# ./build-doc.sh [ app-name ] [ toc-version ]
# $1 Options: map65 simjt wsjt wsjtx wspr wsprx quick-ref dev-guide
# $2 Options: "", ntoc, toc1, toc2, all, "" defaults to TOC2
# if $2 = "NTOC" build no table of contents
# if $2 = "TOC1" build top table of contents 
# if $2 = "TOC2" build left table of contents 
# if $2 = "all" build all three toc versions
#
# ******************************************************************************

# Display help if $1 is "" > Null
if [[ $1 = "" ]]
then
	app_menu_help
#
# MAP65 build options
#
elif [[ $1 = "map65" && -z $2 ]] || [[ $1 = "map65" && $2 = "toc2" ]]
	then
		display_name="MAP65"
		app_name="map65"
		cd "$MAP65"
		pre_file_check
		clear
		main_wording
		build_toc2
		post_file_check

elif [[ $1 = "map65" && $2 = "toc1" ]]  
	then
		display_name="MAP65"
		app_name="map65"
		cd "$MAP65"
		pre_file_check
		clear
		main_wording
		build_toc1
		post_file_check

		elif [[ $1 = "map65" && $2 = "NTOC" ]]  
	then
		display_name="MAP65"
		app_name="map65"
		cd "$MAP65"
		pre_file_check
		clear
		main_wording
		build_ntoc
		post_file_check

elif [[ $1 = "map65" && $2 = "all" ]]  
	then
		display_name="MAP65"
		app_name="map65"
		cd "$MAP65"
		pre_file_check
		clear
		main_wording
		for f in "${all_toc_ary[@]}"; do $f; done
		post_file_check

#
# SimJT build options
#
elif [[ $1 = "simjt" && -z $2 ]] || [[ $1 = "simjt" && $2 = "toc2" ]]
	then
		display_name="SimJT"
		app_name="simjt"
		cd "$SIMJT"
		pre_file_check
		clear
		main_wording
		build_toc2
		post_file_check

elif [[ $1 = "simjt" && $2 = "toc1" ]]  
	then
		display_name="SimJT"
		app_name="simjt"
		cd "$SIMJT"
		pre_file_check
		clear
		main_wording
		build_toc1
		post_file_check

		elif [[ $1 = "map65" && $2 = "NTOC" ]]  
	then
		display_name="SimJT"
		app_name="simjt"
		cd "$SIMJT"
		pre_file_check
		clear
		main_wording
		build_ntoc
		post_file_check

elif [[ $1 = "simjt" && $2 = "all" ]]  
	then
		display_name="SimJT"
		app_name="simjt"
		cd "$SIMJT"
		pre_file_check
		clear
		main_wording
		for f in "${all_toc_ary[@]}"; do $f; done
		post_file_check

#
# WSJT build options
#
elif [[ $1 = "wsjt" && -z $2 ]] || [[ $1 = "wsjt" && $2 = "toc2" ]]
	then
		display_name="WSJT"
		app_name="wsjt"
		cd "$WSJT"
		pre_file_check
		clear
		main_wording
		build_toc2
		post_file_check

elif [[ $1 = "wsjt" && $2 = "toc1" ]]  
	then
		display_name="WSJT"
		app_name="wsjt"
		cd "$WSJT"
		pre_file_check
		clear
		main_wording
		build_toc1
		post_file_check

		elif [[ $1 = "wsjt" && $2 = "NTOC" ]]  
	then
		display_name="WSJT"
		app_name="wsjt"
		cd "$WSJT"
		pre_file_check
		clear
		main_wording
		build_ntoc
		post_file_check

elif [[ $1 = "wsjt" && $2 = "all" ]]  
	then
		display_name="WSJT"
		app_name="wsjt"
		cd "$WSJT"
		pre_file_check
		clear
		main_wording
		for f in "${all_toc_ary[@]}"; do $f; done
		post_file_check
#
# WSJT-X build options
#
elif [[ $1 = "wsjtx" && -z $2 ]] || [[ $1 = "wsjtx" && $2 = "toc2" ]]
	then
		display_name="WSJT-X"
		app_name="wsjtx"
		cd "$WSJTX"
		pre_file_check
		clear
		main_wording
		build_toc2
		post_file_check

elif [[ $1 = "wsjtx" && $2 = "toc1" ]]  
	then
		display_name="WSJT-X"
		app_name="wsjtx"
		cd "$WSJTX"
		pre_file_check
		clear
		main_wording
		build_toc1
		post_file_check

		elif [[ $1 = "wsjtx" && $2 = "NTOC" ]]  
	then
		display_name="WSJT-X"
		app_name="wsjtx"
		cd "$WSJTX"
		pre_file_check
		clear
		main_wording
		build_ntoc
		post_file_check

elif [[ $1 = "wsjtx" && $2 = "all" ]]  
	then
		display_name="WSJT-X"
		app_name="wsjtx"
		cd "$WSJTX"
		pre_file_check
		clear
		main_wording
		for f in "${all_toc_ary[@]}"; do $f; done
		post_file_check

#
# WSPR build options
#
elif [[ $1 = "wspr" && -z $2 ]] || [[ $1 = "wspr" && $2 = "toc2" ]]
	then
		display_name="WSPR"
		app_name="wspr"
		cd "$WSPR"
		pre_file_check
		clear
		main_wording
		build_toc2
		post_file_check

elif [[ $1 = "wspr" && $2 = "toc1" ]]  
	then
		display_name="WSPR"
		app_name="wspr"
		cd "$WSPR"
		pre_file_check
		clear
		main_wording
		build_toc1
		post_file_check

		elif [[ $1 = "wspr" && $2 = "NTOC" ]]  
	then
		display_name="WSPR"
		app_name="wspr"
		cd "$WSPR"
		pre_file_check
		clear
		main_wording
		build_ntoc
		post_file_check

elif [[ $1 = "wspr" && $2 = "all" ]]  
	then
		display_name="WSPR"
		app_name="wspr"
		cd "$WSPR"
		pre_file_check
		clear
		main_wording
		for f in "${all_toc_ary[@]}"; do $f; done
		post_file_check
#
# WSPR-X build options
#
elif [[ $1 = "wsprx" && -z $2 ]] || [[ $1 = "wsprx" && $2 = "toc2" ]]
	then
		display_name="WSPR-X"
		app_name="wsprx"
		cd "$WSPRX"
		pre_file_check
		clear
		main_wording
		build_toc2
		post_file_check

elif [[ $1 = "wsprx" && $2 = "toc1" ]]  
	then
		display_name="WSPR-X"
		app_name="wsprx"
		cd "$WSPRX"
		pre_file_check
		clear
		main_wording
		build_toc1
		post_file_check

		elif [[ $1 = "wsprx" && $2 = "NTOC" ]]  
	then
		display_name="WSJT-X"
		app_name="wsjtx"
		cd "$WSJTX"
		pre_file_check
		clear
		main_wording
		build_ntoc
		post_file_check

elif [[ $1 = "wsprx" && $2 = "all" ]]  
	then
		display_name="WSPR-X"
		app_name="wsprx"
		cd "$WSPRX"
		pre_file_check
		clear
		main_wording
		for f in "${all_toc_ary[@]}"; do $f; done
		post_file_check

else
	cd "$BASEDIR"
	app_menu_help
fi
