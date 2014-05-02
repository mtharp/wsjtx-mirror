#! /usr/bin/env bash
#
# Name			: JTSDK-NIX
# Execution		: As normal user ./jtsdk-nix.sh
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
_BASED=$(exec pwd)

# Using cmake and qmake directories allows for build comparison.
# Need to add support for multiple compilers {g++, intel, clang}
mkdir -p "$_BASED"/{tmp,src}
mkdir -p "$_BASED"/{wsjt,wspr}
mkdir -p "$_BASED"/{wsjtx,wsprx,map65}/qmake/install
mkdir -p "$_BASED"/{wsjtx,wsprx,map65}/cmake/{build,install}/{Debug,Release}

# path vars
_CFG="$_BASED/config"
_DOCS="$_BASED/docs"
_FUNC="$_BASED/functions"
_LANG="$_BASED/language"
_LOGS="$_BASED/logs"
_SRCD="$_BASED/src"
_TMP="$_BASED/tmp"
_MKRD=/home/$USER/.local/share/applications/jtsdk-nix

# process vars
# - Hamlib   == Hamlib Fork from G4WJS, required for WSJT-X
# - AsciiDoc == 8.6.9, current release (simple unzip from source)
_HAMLIBD=/home/$USER/.local/share/applications/hamlib
_ADOCD=/home/$USER/.local/share/applications/asciidoc

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

# initial setup marker / sanity check
setup_chk

# setup main menu help doc var
_HELP="$_BASED/README"

# setup main menu
while [ 0 ]; do

dialog --ok-label SELECT --nocancel --backtitle "$BACKTITLE" --title \
"$MMTITLE" --menu "$MENUMSG" 16 60 22 --file "$_TMP/MMenu.tmp" 2> "$_TMP/selection"

# get user selection
MMSELECT=$(head -c 1 < $_TMP/selection)

# WSJT w/Python3
if [[ $MMSELECT = "A" ]]; then
	_APP_NAME=wsjt
	_APP_SRC="$_SRCD/trunk"
	python_nix
	continue

# WSPR w/Python3
elif [[ $MMSELECT = "B" ]]; then
	_APP_NAME=wspr
	_APP_SRC="$_SRCD/wspr"
	python_nix
	continue

# WSJT-X w/CMake
   elif [[ $MMSELECT = "C" ]]; then
	_APP_NAME=wsjtx
	_OPTION=Release
	cmake_nix
	continue

# WSPR-X w/CMake
   elif [[ $MMSELECT = "D" ]]; then
	_APP_NAME=wsprx
	_OPTION=Release
	cmake_nix
	continue

# MAP65 w/CMake
   elif [[ $MMSELECT = "F" ]]; then
	_APP_NAME=map65
	_OPTION=Release
	cmake_nix
	continue

# All Apps
   elif [[ $MMSELECT = "Z" ]]; then
	under_development
	continue

# All Apps
   elif [[ $MMSELECT = "H" ]]; then

dialog --exit-label DONE --backtitle "$BACKTITLE" --title "$HTITLE" --textbox "$_HELP" 20 80
	continue

# Exit JTSDK-NIX
  elif [[ $MMSELECT = "E" ]]; then
   clean_exit
   fi
done

