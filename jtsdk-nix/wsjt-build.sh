#! /usr/bin/env bash
#
# Name			: JTSDK-NIX
# Execution		: As normal user ./wsjt-build.sh
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
#-------------------------------------------------------------------------#

# set a reasonable initial window size
printf '\e[8;28;100t'

# set script path's
BASED=$(dirname $(readlink -f $0))

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
_HAMLIBD="$_MKRD/hamlib"
_jj=$(grep -c ^processor /proc/cpuinfo)

# source functions and language
. "$_LANG"/language_en
. "$_FUNC"/sig_catch_cleanup
. "$_FUNC"/clean_exit
. "$_FUNC"/root_chk
. "$_FUNC"/dialog_chk
. "$_FUNC"/setup_chk
. "$_FUNC"/set_options
. "$_FUNC"/unset_options
. "$_FUNC"/under_development
. "$_FUNC"/cmake_nix

# Set a few traps to catch signals / interupts
trap sig_catch_cleanup SIGHUP SIGINT SIGQUIT SIGTERM SIGTSTP

# set shell options
set_options

# check if user is root, if yes, warn & exit
root_chk

# checking for package dialog
dialog_chk

# initial setup marker check
setup_chk

# setup main menu help doc var
_HELP="$_DOCS/main_menu_help.txt"

# setup main menu
while [ 0 ]; do

dialog --ok-label SELECT --nocancel --backtitle "$BACKTITLE" --title \
"$MMTITLE" --menu "$MENUMSG" 16 60 22 --file "$_TMP/MMenu.tmp" 2> "$_TMP/selection"

# get user selection
MMSELECT="`cat $_TMP/selection |head -c 1`"

# Used for help-section when ready
# dialog --exit-label DONE --backtitle "$BACKTITLE" --title "$HTITLE" --textbox "$_HELP" 20 80

# start main menu options
if [[ $MMSELECT = "A" ]]; then
	_APP_NAME=wsjtx
	_OPTION=Release
	cmake_nix
	continue

   elif [[ $MMSELECT = "B" ]]; then
	under_development
	continue

   elif [[ $MMSELECT = "C" ]]; then
	under_development	
	continue

   elif [[ $MMSELECT = "D" ]]; then
	under_development
	continue

   elif [[ $MMSELECT = "F" ]]; then
	under_development
	continue

#   elif [[ $MMSELECT = "G" ]]; then
#	under_development
#	continue

#  elif [[ $MMSELECT = "H" ]]; then
#	under_development
#	continue

#   elif [[ $MMSELECT = "I" ]]; then
#	under_development
#	continue

   elif [[ $MMSELECT = "Z" ]]; then
	under_development
	continue

  elif [[ $MMSELECT = "E" ]]; then
   clean_exit
   fi
done

