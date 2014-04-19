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
printf '\e[8;28;100t'

# set script path's
BASED=$(pwd -P)

# Using cmake and qmake directories allows for build comparison.
# Need to add support for multiple compilers {g++, intel, clang}
mkdir -p "$BASED"/{tmp,src}
mkdir -p "$BASED"/{wsjt,wspr}
mkdir -p "$BASED"/{wsjtx,wsprx,map65}/qmake/install
mkdir -p "$BASED"/{wsjtx,wsprx,map65}/cmake/{build,install}/{Debug,Release}

# main vars
_CONFIG="$BASED/config"
_DOCS="$BASED/docs"
_FUNC="$BASED/functions"
_LANG="$BASED/language"
_LOGS="$BASED/logs"
_SRCD="$BASED/src"
_TMP="$BASED/tmp"
_MKRD=~/.local/share/applications/jtsdk-nix

# process vars
_HAMLIBD="/home/$USER/Projects/jtsdk-nix/hamlib"
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
. "$_FUNC"/build_hamlib

# Set a few traps to catch signals / interupts
trap sig_catch_cleanup SIGHUP SIGINT SIGQUIT SIGTERM SIGTSTP

# set shell options
set_options

# check if user is root, if yes, warn & exit
root_chk

# checking for package dialog
dialog_chk

# initial setup marker check
# setup_chk

# setup main menu help doc var
_HELP="$_DOCS/main_menu_help.txt"


# distrobutions specific functions
#. "$_FUNC"/arch_functions
#. "$_FUNC"/fedora_functions
#. "$_FUNC"/gentoo_functions
#. "$_FUNC"/slackware_functions

# start setup menu
while [ 0 ]; do

dialog --ok-label SELECT --nocancel --backtitle "$BACKTITLE" --title \
"$SMTITLE" --menu "$MENUMSG" 16 60 22 --file "$_TMP/SMenu.tmp" 2> "$_TMP/setup_selection"

# get user selection
SMSELECT="`cat $_TMP/setup_selection |head -c 1`"

# start setup menu options
if [[ $SMSELECT = "A" ]]; then
	# Arch Current Build
	under_development
	continue

   elif [[ $SMSELECT = "F" ]]; then
	# Fedora-20+
	under_development
	continue

   elif [[ $SMSELECT = "G" ]]; then
	# Gentoo - Current Bild
	under_development	
	continue

   elif [[ $SMSELECT = "S" ]]; then
	# Slaskware 14.1+
	under_development	
	continue

   elif [[ $SMSELECT = "U" ]]; then
	# Ubuntu 1404, includes Lubuntu, Xubuntu
	clear
	echo "Sourcing Ubuntu Setup Functions .."
	. "$_FUNC"/ubuntu_functions
	ubuntu_x86_64_list
#	build_hamlib
	continue

   elif [[ $SMSELECT = "H" ]]; then
dialog --exit-label DONE --backtitle "$BACKTITLE" --title "$HTITLE" --textbox "$_HELP" 20 80
	continue

  elif [[ $SMSELECT = "E" ]]; then
	clean_exit
   fi
done

