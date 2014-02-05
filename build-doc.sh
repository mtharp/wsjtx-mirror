#!/usr/bin/env bash
# Title           : build-doc.sh
# Description     : WSJT-X Documentation Main Build Script
# Author          : KI7MT
# Email           : ki7mt@yahoo.com
# Date            : FEB-02-2014
# Version         : 0.6
# Usage           : ./build-doc.sh [ option ]
# Notes           : Python 2.7+ and GNU Source Highlight
#==============================================================================

# exit on error
set -e

#add some color
red='\033[01;31m'
green='\033[01;32m'
yellow='\033[01;33m'
cyan='\033[01;36m'
no_col='\033[01;37m'

# MAIN VARIABLE's
base_dir=$(pwd)
script_name=$(basename $0)
func_dir="$base_dir/functions"
map65_dir="$base_dir/map65"
simjt_dir="$base_dir/simjt"
wsjt_dir="$base_dir/wsjt"
wsjtx_dir="$base_dir/wsjtx"
wspr_dir="$base_dir/wspr"
wsprx_dir="$base_dir/wsprx"
c_asciidoc="../asciidoc/asciidoc.py -b xhtml11 -a iconsdir="../icons" -a max-width=1024px"
d_asciidoc="./asciidoc/asciidoc.py -b xhtml11 -a iconsdir="./icons" -a max-width=1024px"

#######################
# clean-exit
#######################

function clean_exit() {
	clear
	echo -e ${yellow}'Signal caught, cleaning up and exiting.'${no_col}
	sleep 1
	[ -d "$base_dir/tmp" ] && rm -r $base_dir/tmp
	echo -e ${yellow}'. Done'${no_col}
	exit 0
}

# Trap Ctrl+C, Ctrl+Z and quit signals
trap '' SIGINT SIGQUIT SIGTSTP

function main_toc2() {
    echo -e ${yellow}"Building $display_name Main with TOC2"${no_col}
    $c_asciidoc -a toc2 -o $app_name-main-toc2.html ./source/$app_name-main.adoc
    echo -e ${green}". $app_name-main-toc2.html"${no_col}
} # end of main toc2

function quick_ref() {
    echo -e ${yellow}"Building Quick Reference Guide"${no_col}
    $d_asciidoc -a toc2 -o quick-reference.html ./source/quick-reference.adoc
    echo -e ${green}".. quick-reference.html"${no_col}
} # end of quick-reference

function dev_guide() {
    echo -e ${yellow}"Building Development Guide"${no_col}
    $d_asciidoc -a toc2 -o dev-guide.html ./source/dev-guide.adoc
    echo -e ${green}".. dev-guide.html"${no_col}
} # end of dev-guide

function main_wording() {
clear
echo -e ${yellow}"Building Documentation for $display_name\n"${no_col}
}

function quick_ref_wording() {
clear
echo -e ${yellow}"Building Quick Reference Guide\n"${no_col}
}

function dev_guide_wording() {
clear
echo -e ${yellow}"Building Development Guide\n"${no_col}
}

function location_wording() {
	echo
	echo -e ${yellow}"$display_name file saved to:"${no_col}${cyan} "$base_dir/$app_name" ${no_col}
	echo
 exit 0
}

#######################
# start the main script
#######################

# help menu options
function help_menu() {
	clear
    echo -e ${green}"BUILD SCRIPT HELP MENU\n"${no_col}
    echo 'USAGE: build-doc.sh [ option ]'
	echo
	echo 'OPTIONS: map65 simjt wsjt wsjtx wspr wsprx quick-ref'
	echo '         dev-guide help'
	echo
    echo -e ${yellow}'WSJT Documentation Options'${no_col}
    echo ' [1] Build MAP65'
    echo ' [2] Build SimJT'
    echo ' [3] Build WSJT'
    echo ' [4] Build WSJT-X'
    echo ' [5] Build WSPR'
	echo ' [6] Build WSPR-X'
	echo
	echo -e ${yellow}"\nSuplementry Documentation"${no_col}
	echo ' [7] Quick Reference Guide'
	echo ' [8] Development Guide'
	echo
    echo ' [0] Exit'
	echo
} # end of help menu

if [[ $1 = "map65" ]]
	then
		clear
		display_name="MAP65"
		app_name="map65"
		cd $map65_dir
		main_toc2
		location_wording
elif [[ $1 = "simjt" ]]
	then
		clear
		display_name="SimJT"
		app_name="simjt"
		cd $simjt_dir
		main_toc2
		location_wording

elif [[ $1 = "wsjt" ]]
	then
		clear
		display_name="WSJT"
		app_name="wsjt"
		cd $wsjt_dir
		main_toc2
		location_wording

elif [[ $1 = "wsjtx" ]]
	then
		clear
		display_name="WSJT-X"
		app_name="wsjtx"
		cd $wsjtx_dir
		main_toc2
		location_wording

elif [[ $1 = "wspr" ]]
	then
		clear
		display_name="WSPR"
		app_name="wspr"
		cd $wspr_dir
		main_toc2
		location_wording

elif [[ $1 = "wsprx" ]]
	then
		clear
		display_name="WSPR-X"
		app_name="wsprx"
		cd $wsprx_dir
		main_toc2
		location_wording

elif [[ $1 = "quick-ref" ]]
	then
		clear
		display_name="Quick Reference Guide"
		quick_ref
		location_wording

elif [[ $1 = "dev-guide" ]]
	then
		clear
		display_name="Development Guide"
		dev_guide
		location_wording

else
	while [ 1 ]
	do
		help_menu
		read -p "Enter Selection [ A-H or 0 to Exit ]: " SELECTION
		case "$SELECTION" in
			"1") # no table of contents build
				display_name="MAP65"
				app_name="map65"
				cd $map65_dir
				main_wording
				main_toc2
				exit 0
				;;
			"2") # top table of contents build
				display_name="SimJT"
				app_name="simjt"
				cd $simjt_dir
				main_wording
				main_toc2
				exit 0
				;;
			"3")
				display_name="WSJT"
				app_name="wsjt"
				cd $wsjt_dir
				main_wording
				main_toc2
				exit 0
				;;
			"4")
				display_name="WSJT-X"
				app_name="wsjtx"
				cd $wsjtx_dir
				main_wording
				main_toc2
				exit 0
				;;
			"5")
				display_name="WSPR"
				app_name="wspr"
				cd $wspr_dir
				main_wording
				main_toc2
				exit 0
				;;
			"6")
				display_name="WSPR-X"
				app_name="wsprx"
				cd $wsprx_dir
				main_wording
				main_toc2
				exit 0
				;;
			"7")
				clear
				quick_ref
				exit 0
				;;
			"8")
				clear
				dev_guide
				exit 0
				;;				
			"0")
				exit 0
				;;
		esac
	done
fi
exit 0