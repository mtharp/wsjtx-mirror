#!/usr/bin/env bash
# Title           : build-doc.sh
# Description     : WSJT Documentation Main Build Script for *Nix
# Author          : KI7MT
# Email           : ki7mt@yahoo.com
# Date            : 2014
# Version         : 0.7.1
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

# Exit on error
set -e

#######################
# Variables           #
#######################

# Main variables
SCRIPTVER="0.7.0"
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
NTOC="asciidoc.py -b xhtml11 -a iconsdir=../icons -a max-width=1024px"
TOC1="asciidoc.py -b xhtml11 -a toc -a iconsdir=../icons -a max-width=1024px"
TOC2="asciidoc.py -b xhtml11 -a toc2 -a iconsdir=../icons -a max-width=1024px"

# Color variables
C_R='\033[01;31m'		# red
C_G='\033[01;32m'		# green
C_Y='\033[01;33m'		# yellow
C_C='\033[01;36m'		# cyan
C_NC='\033[01;37m'	# no color

# Array variables
declare -a all_apps_ary=('map65' 'simjt' 'wsjt' 'wsjtx' 'wspr' 'wsprx' \
'quick-ref' 'dev-guide' )

declare -a all_toc_ary=('build_ntoc' 'build_toc1' 'build_toc2')

#######################
# Functions           #
#######################

# clean-exit
function clean_exit() {
	clear
	echo -e ${C_R}'*** SIGNAL CAUGHT, PERFORMING CLEAN EXIT ***'${C_NC}
	echo
	echo -e ${C_Y}'Removeing Temorary Folders'${C_NC}

	# Delete any /tmp folders 
	for i in "${all_apps_ary[@]}"
		do
			cd ./$i
			echo -e ${C_C}". Cleaning $(pwd)/tmp"${C_NC}
			rm -rf ./tmp
			cd ..
	done

# Yy / Nn answer on removing HTML files	
while [ 1 ]
do
	echo
	read -p "Remove HTML Files? [ Y/N ]: " yn
	case $yn in
	[Yy]* )
		clear
		echo -e ${C_Y}"Removing html files ... "${C_NC}
		echo -e ${C_C}". Cleaning $(pwd)/*.html"${C_NC}
		rm -rf ./*.html
		
		for i in "${all_apps_ary[@]}"
		do
			cd ./$i
			echo -e ${C_C}". Cleaning $(pwd)/*.html"${C_NC}
			rm -rf ./*.html
			cd ..
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
	echo -e ${C_Y}"Building All WSJT Documentation"${C_NC}
	echo

while [ 1 ]
do
	read -p "Please confirm to start building? [ Y/N ]: " yn
	case $yn in
	[Yy]* )
		clear
		echo -e ${C_Y}"Building All WSJT Documentation"${C_NC}
		
		# MAP65 
		echo -e ${C_C}'MAP65'${C_NC}
		app_name="map65"
		cd "$MAP65"
		build_ntoc
		echo -e ${C_G} '.. map65-main.html'${C_NC}
		build_toc1
		echo -e ${C_G} '.. map65-main-toc1.html'${C_NC}
		build_toc2
		echo -e ${C_G} '.. map65-main-toc2.html'${C_NC}
		echo -e ${C_Y} 'File(s) located in:' "$MAP65"${C_NC}
		echo
		
		# SIMJT
		echo -e ${C_C}'SimJT'${C_NC}
		app_name="simjt"
		cd "$SIMJT"
		build_ntoc
		echo -e ${C_G} '.. simjt-main.html'${C_NC}
		build_toc1
		echo -e ${C_G} '.. simjt-main-toc1.html'${C_NC}
		build_toc2
		echo -e ${C_G} '.. simjt-main-toc2.html'${C_NC}
		echo -e ${C_Y} 'File(s) located in:' "$SIMJT"${C_NC}
		echo
		
		# WSJT
		echo -e ${C_C}'WSJT'${C_NC}
		app_name="wsjt"
		cd "$WSJT"
		build_ntoc
		echo -e ${C_G} '.. wsjt-main.html'${C_NC}
		build_toc1
		echo -e ${C_G} '.. wsjt-main-toc1.html'${C_NC}
		build_toc2
		echo -e ${C_G} '.. wsjt-main-toc2.html'${C_NC}
		echo -e ${C_Y} 'File(s) located in:' "$WSJT"${C_NC}
		echo
		
		# WSJTX
		echo -e ${C_C}'WSJT-X'${C_NC}
		app_name="wsjtx"
		cd "$WSJTX"
		build_ntoc
		echo -e ${C_G} '.. wsjtx-main.html'${C_NC}
		build_toc1
		echo -e ${C_G} '.. wsjtx-main-toc1.html'${C_NC}
		build_toc2
		echo -e ${C_G} '.. wsjtx-main-toc2.html'${C_NC}
		echo -e ${C_Y} 'File(s) located in:' "$WSJTX"${C_NC}
		echo
		
		# WSPR
		echo -e ${C_C}'WSPR'${C_NC}
		app_name="wspr"
		cd "$WSPR"
		build_ntoc
		echo -e ${C_G} '.. wspr-main.html'${C_NC}
		build_toc1
		echo -e ${C_G} '.. wspr-main-toc1.html'${C_NC}
		build_toc2
		echo -e ${C_G} '.. wspr-main-toc2.html'${C_NC}
		echo -e ${C_Y} 'File(s) located in:' "$WSPR"${C_NC}
		echo
		
		# WSPR-X
		echo -e ${C_C}'WSPR-X'${C_NC}
		app_name="wsprx"
		cd "$WSPRX"
		build_ntoc
		echo -e ${C_G} '.. wsprx-main.html'${C_NC}
		build_toc1
		echo -e ${C_G} '.. wsprx-main-toc1.html'${C_NC}
		build_toc2
		echo -e ${C_G} '.. wsprx-main-toc2.html'${C_NC}
		echo -e ${C_Y} 'File(s) located in:' "$WSPRX"${C_NC}
		echo
		
		# QUICK-REF
		echo -e ${C_C}'Quick Reference'${C_NC}
		cd "$BASEDIR/quick-ref"
		quick_ref
		echo -e ${C_G} '.. quick-reference.html'${C_NC}
		echo -e ${C_Y} 'File(s) located in:' "$QUICKR"${C_NC}
		echo
		
		# DEV-GUIDE
		echo -e ${C_C}'Development Guide'${C_NC}
		cd "$BASEDIR/dev-guide"
		dev_guide
		echo -e ${C_G} '.. compiling_wsjtx_linux.html'${C_NC}
		echo -e ${C_Y} 'File(s) located in:' "$DEVG"${C_NC}
		echo
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
	$TOC2 -o quick-reference.html ./source/quick-ref-main.adoc
} # End quick reference guide

# Development Guide
function dev_guide() {
	$TOC2 -o wsjt-dev-guide.html ./source/dev-guide-main.adoc
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
if [[ $(ls -1 ./*.html 2>/dev/null | wc -l) > 0 ]]
  then
    clear
    echo -e ${C_Y}"Finished Building $display_name Documentation"${C_NC}
    echo
    echo -e ${C_Y}"File(s) located in: $(pwd)"${C_NC}
    echo
    return

else
	clear
	echo -e ${C_R}"$display_name DOCS BUILD ERROR - No File(s) Found"${C_NC}
	echo "Gathering System Information"
  PY_VER=$(python -V)	
  SYS_INFO=$(uname -a)
	SVN_VER=$(svn log -l1 |awk 'FNR==2 {print $1}')
	BASH_VER=$(bash --version |awk 'NR==1')
  S_HIGH=$(source-highlight --version |awk 'NR==1')
	echo "Script version: v$SCRIPTVER"
	echo "SVN Version: $SVN_VER"
	echo "$SYS_INFO"
	echo "$BASH_VER"
  echo "$S_HIGH"
  echo
	echo "Please Email Info to WSJT Dev-Group: $DEVMAIL"
  echo "Provide as much detail as you can about the problem."
	echo "Thank You."
  echo
	exit 1
fi
} # End file check after build

# Main help menu
function app_menu_help() {
	clear
  echo -e ${C_G}"WSJT DOCUMENTATION HELP MENU\n"${C_NC}
  echo 'USAGE: build-doc.sh [ option1 ] [ option2 ]'
	echo
	echo 'OPTION1: All map65 simjt wsjt wsjtx'
	echo '         wspr wsprx quick-ref dev-guide help'
	echo 'OPTION2: ntoc toc1 toc2 all'
	echo
  echo 'Examples:'
	echo 'All TOC Versions: ./build-doc.sh wsjtx all'
	echo 'No TOC:           ./build-doc.sh wsjtx ntoc'
	echo 'Top TOC Only:     ./build-doc.sh wsjtx toc1'
	echo 'Left TOC only:    ./build-doc.sh wsjtx toc2'
	echo
	echo 'The same method is used for all applications .'
	echo 'For Help: ./build-doc.sh help'
} # End main menu help

#######################
# start the main script
#######################

# Trap Ctrl+C, Ctrl+Z and quit signals
trap clean_exit SIGINT SIGQUIT SIGTSTP

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

# Display help if $1 is "" or "help" 
if [[ $1 = "" ]] || [[ $1 = "help" ]]
  then
    app_menu_help

# Build all documentation
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
		display_name="Development Guide"
		cd "$DEVG"
		pre_file_check
		clear
		main_wording
		dev_guide
		post_file_check

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

exit 0
