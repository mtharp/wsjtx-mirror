#!/usr/bin/env bash
# Title           : build-doc.sh
# Description     : WSJT Documentation Main Build Script for *Nix
# Author          : KI7MT
# Email           : ki7mt@yahoo.com
# Date            : 2014
# Usage           : ./build-doc.sh [ option ]
# Notes           : Requires:	Python 2.5 <=> 2.7.6, AsciiDoc, rsync
#								bash 4.0+
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

################################################################################
# Variables                                                                    #
################################################################################
# Main variables
SCRIPTVER="0.9.0"
BASEDIR=$(dirname $(readlink -f $0))
DEVMAIL="wsjt-devel@lists.berlios.de"
MAP65="$BASEDIR/map65"
SIMJT="$BASEDIR/simjt"
WSJT="$BASEDIR/wsjt"
WSJTX="$BASEDIR/wsjtx"
WSPR="$BASEDIR/wspr"
WFMT="$BASEDIR/wfmt"
WSPRX="$BASEDIR/wsprx"
DEVG="$BASEDIR/dev-guide"
QREF="$BASEDIR/quick-ref"
export PATH="$BASEDIR/asciidoc:$PATH"
ICONSDIR="$BASEDIR/icons"

# non-data-uri builds (linked css, images, js)
TOC="asciidoc.py -b xhtml11 -a toc2 -a iconsdir=$ICONSDIR -a max-width=1024px"

# data-uri builds (embedded images, css, js)
DTOC="asciidoc.py -b xhtml11 -a data-uri -a toc2 -a iconsdir=$ICONSDIR -a max-width=1024px"

# build manpage (under construction)
# data-uri builds (embedded images, css, js)
# MTOC="a2x.py --format=manpage --doctype=manpage --no-xmllint"

# all available documents
declare -a doc_ary=('map65' 'simjt' 'wsjt' 'wsjtx' 'wspr' 'wfmt' 'wsprx' 'quick-ref' 'dev-guide')

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
		echo -e ${C_G}".. cleaning complete, now exiting"${C_NC}
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

# Build linked html documents --------------------------------------------------
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
	# * Mmanpages should reside in source trees, but there's no
	#   reason they cannot be build externally, then updates the 
	#   source tree file as a fully formated manpage.
	$MTOC -o $app_name.1 ./source/$app_name.1.txt

}

# Copy Images & Icons Dir to $app_name -----------------------------------------
function copy_image_folders() {
# data-uri does not like rpaths and wants the incos and images under ./source
# rsync is just easier to use than cp, mkdir etc and it excludes
# .svn easier

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

} # End main wording

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

# Main help menu ---------------------------------------------------------------
function app_menu_help() {
	clear
	echo -e ${C_G}"WSJT DOCUMENTATION HELP MENU\n"${C_NC}
	echo 'USAGE: [ build-doc.sh] [ option ]'
	echo
	echo 'OPTION: All map65 simjt wsjt wsjtx'
	echo '        wspr wsprx wfmt devg qref help'
	echo
	echo 'Build Linked:'
	echo '---------------------------'
	echo 'All .....: ./build-doc.sh all'
	echo 'WSJT-X...: ./build-doc.sh wsjtx'
	echo
	echo 'Build Data URI (Stand Alone)'
	echo '----------------------------'
	echo 'All .....: ./build-doc.sh dall'
	echo 'WSJT-X...: ./build-doc.sh dwsjtx'
	echo
	echo 'The same method is used for all documentaion.'
	echo 'The prtefix "d" designates data-uri or a stand'
	echo 'version of the document'
	echo
} # End main menu help

################################################################################
# start the main script                                                        #
################################################################################

# Trap Ctrl+C, Ctrl+Z and quit signals
trap clean_exit SIGHUP SIGINT SIGQUIT SIGTERM SIGTSTP

# Display help if $1 is "" or "help" 
if [[ $1 = "" ]] || [[ $1 = "help" ]]
  then
    app_menu_help

# Build All Guides
# Linked version
elif [[ $1 = "all" ]]
	then
	doc_type=L
	build_all_guides

# Build All Guides 
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

# Development Guide -----------------------------------------------------------
# Linked versoin
elif [[ $1 = "devg" ]]
	then
		display_name="WSJT Developer's Guide"
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
		display_name="WSJT Developer's Guide data-uri"
		app_name="dev-guide"
		cd "$DEVG"
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
elif [[ $1 = "wsjt" ]]
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
