#! /usr/bin/env bash
#
# Name			: setup.sh
# Execution		: ./setup.fh
# Author		: Greg, Beam, ki7mt -at- yahoo.com
# Copyright		: Copyright (C) 2014 Joseph H Taylor, Jr, K1JT
# Contributors	: KI7MT
#
# JTSDK-NIX is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation either version 3 of the License, or
# (at your option) any later version. 
#
# JTSDK-NIX is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------#

# error on exit
set -e

# set a reasonable initial window size
printf '\e[8;35;100t'

# set script path's
BASED=$(dirname $(readlink -f $0))

# Using cmake and qmake directories allows for build comparison.
# Need to add support for multiple compilers {g++, intel, clang}
mkdir -p "$BASED"/{tmp,src}
mkdir -p "$BASED"/{wsjt,wspr}
mkdir -p "$BASED"/{wsjtx,wsprx,map65}/qmake/install
mkdir -p "$BASED"/{wsjtx,wsprx,map65}/cmake/{build,install}/{Debug,Release}

# main vars
_CFG="$BASED/config"
_DOCS="$BASED/docs"
_FUNC="$BASED/functions"
_LANG="$BASED/language"
_LOGS="$BASED/logs"
_SRCD="$BASED/src"
_TMP="$BASED/tmp"
_MKRD="$HOME"/.local/share/applications/jtsdk-nix

# process vars
_HAMLIBD="$BASED/hamlib"
_jj=$(grep -c ^processor /proc/cpuinfo)

# source general functions and language
. "$_LANG"/language_en
. "$_FUNC"/sig_catch_cleanup
. "$_FUNC"/clean_exit
. "$_FUNC"/root_chk
. "$_FUNC"/dialog_chk
#. "$_FUNC"/setup_chk
. "$_FUNC"/set_options
. "$_FUNC"/unset_options
. "$_FUNC"/under_development

# Set a few traps to catch signals / interupts
trap sig_catch_cleanup SIGHUP SIGINT SIGQUIT SIGTERM SIGTSTP

# set shell options
set_options

# check if user is root, if yes, warn & exit
root_chk

# checking for package dialog
dialog_chk

# setup main menu help doc var
_HELP="$_DOCS/setup_menu_help.txt"

# start setup menu
while [ 0 ]; do

dialog --ok-label SELECT --nocancel --backtitle "$BACKTITLE" --title \
"$SMTITLE" --menu "$MENUMSG" 16 60 22 --file "$_TMP/SMenu.tmp" 2> "$_TMP/setup_selection"

# get user selection
SMSELECT="`cat $_TMP/setup_selection |head -c 1`"

# start setup menu options

#-------------------------------Arch Linux ------------------------------------#
if [[ $SMSELECT = "A" ]]; then
	# Arch Current Build
	under_development
	continue

#---------------------------------Fedora---------------------------------------#
   elif [[ $SMSELECT = "F" ]]; then
	# Fedora-20+
	under_development
	continue

#---------------------------------Gentoo---------------------------------------#
   elif [[ $SMSELECT = "G" ]]; then
	# Gentoo - Current Build
	under_development	
	continue

#---------------------------------Slackware------------------------------------#
   elif [[ $SMSELECT = "S" ]]; then
	# Slaskware 14.1+
	under_development	
	continue

#---------------------------------Ubuntu---------------------------------------#
   elif [[ $SMSELECT = "U" ]]; then
		# Ubuntu 1404, includes Lubuntu, Xubuntu
		clear
		echo "JTSDK-NIX SETUP"
		source "$_FUNC"/ubuntu_functions
		ubuntu_setup_marker
		ubuntu_distro_info
		echo
		echo 'Distribution .. '"$_DISTRIBUTOR"
		echo 'Release ....... '"$_RELEASE"
		echo 'Arch .......... '"$_ARCH"
		echo
		echo "The following packages with be Checked and / or Installed"
		echo
		cat $_CFG/pkg_list_ubuntu_$(uname -m) | column
		echo

		# moment of truth, install or no :-)
		while [ 1 ]
		do
			echo
			read -p "Start Installation? [ Y/N ]: " yn
			case $yn in
			[Yy]* )
				echo
				echo "Installing Packages for $_DISTRIBUTOR $_RELEASE $_ARCH"
				echo
				ubuntu_pkg_list
				echo
				read -p "Install complete, press [Enter] to continue"
				break ;;
			[Nn]* )
				break ;;
			* )
				clear
				echo "Please use "Y" yes or "N" No."
			;;
			esac
		done

		#clear
		#echo '-------------------------------------------'	
		#echo "Performing Post Installation Package Checks"
		#echo '-------------------------------------------'
		#source "$_FUNC"/post_install_chk
		#sleep 1
		# post_install_chk
		clear
		echo '-------------------------------------------'	
		echo "Performing Pmw-2.0.0 Installation"
		echo '-------------------------------------------'
		source "$_FUNC"/build_pmw
		sleep 1
		build_pmw
		clear
		echo '-------------------------------------------'	
		echo "Performing Hamlib 3.0 Installation"
		echo '-------------------------------------------'
		source "$_FUNC"/build_hamlib
		sleep 1
		build_hamlib
	continue

#-----------------------------------Help---------------------------------------#
   elif [[ $SMSELECT = "H" ]]; then
dialog --exit-label DONE --backtitle "$BACKTITLE" --title "$HTITLE" --textbox "$_HELP" 20 80
	continue

  elif [[ $SMSELECT = "E" ]]; then
	clean_exit
   fi
done

