#! /usr/bin/env bash
#
# Name			: JTSDK-NIX
# Execution		: As normal user ./wsjt-build.sh
# Contact		: ki7mt -at- yahoo.com
# Copyright		: (C) 2014, Greg Beam, KI7MT
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
cd "$(dirname ${BASH_SOURCE[0]})"
BASED=$(pwd -P)

# Using cmake and qmake directories allows for build comparison.
# When Custom Compilers are uses (Intel, etc), additional folders should be
# created by the build script
mkdir -p $BASED/{tmp,src}
mkdir -p $BASED/{wsjt,wspr}
mkdir -p $BASED/{wsjtx,wsprx,map65}/qmake/install
mkdir -p $BASED/{wsjtx,wsprx,map65}/cmake/{build,install}/{Debug,Release}

# set vars
_CONFIG="$BASED/config"
_DOCS="$BASED/docs"
_FUNC="$BASED/functions"
_LANG="$BASED/language"
_LOGS="$BASED/logs"
_SRC="$BASED/src"
_TMP="$BASED/tmp"
_jj=$(grep -c ^processor /proc/cpuinfo)

# source functions and language
. $_LANG/language_en
. $_FUNC/sig_catch_cleanup
. $_FUNC/clean_exit
. $_FUNC/root_chk
. $_FUNC/dialog_chk
. $_FUNC/set_options
. $_FUNC/unset_options

# Set a few traps to catch signals / interupts
trap sig_catch_cleanup SIGHUP SIGINT SIGQUIT SIGTERM SIGTSTP

# set shell options
set_options

# check if user is root, if yes, warn & exit
root_chk

# checking for package dialog
dialog_chk

# initial setup marker check
# setup_check

# setup main menu help doc var
_HELP="$_DOCS/main_menu_help.txt"

# setup main menu
while [ 0 ]; do

dialog --ok-label SELECT --nocancel --backtitle "$BACKTITLE" --title \
"$MMTITLE" --menu "$MENUMSG" 18 60 22 --file "$_TMP/MMenu.tmp" 2> "$_TMP"/selection

# get user selection
MMSELECT="`cat $_TMP/selection |head -c 1`"

# start main menu options
   if [[ $MMSELECT = "A" ]]; then
dialog --exit-label DONE --backtitle "$BACKTITLE" --title "$HTITLE" --textbox "$_HELP" 20 80
     continue


   elif [[ $MMSELECT = "B" ]]; then
dialog --backtitle "$BACKTITLE" --title "$HTITLE" --textbox "$_HELP" 20 80
     continue
   elif [[ $MMSELECT = "C" ]]; then
dialog --backtitle "$BACKTITLE" --title "$HTITLE" --textbox "$_HELP" 20 80
     continue

   elif [[ $MMSELECT = "D" ]]; then
dialog --backtitle "$BACKTITLE" --title "$HTITLE" --textbox "$_HELP" 20 80
     continue

   elif [[ $MMSELECT = "F" ]]; then
dialog --backtitle "$BACKTITLE" --title "$HTITLE" --textbox "$_HELP" 20 80
     continue

   elif [[ $MMSELECT = "G" ]]; then
dialog --backtitle "$BACKTITLE" --title "$HTITLE" --textbox "$_HELP" 20 80
     continue


   elif [[ $MMSELECT = "H" ]]; then
dialog --backtitle "$BACKTITLE" --title "$HTITLE" --textbox "$_HELP" 20 80
     continue

   elif [[ $MMSELECT = "I" ]]; then
dialog --backtitle "$BACKTITLE" --title "$HTITLE" --textbox "$_HELP" 20 80
     continue

   elif [[ $MMSELECT = "Z" ]]; then
dialog --backtitle "$BACKTITLE" --title "$HTITLE" --textbox "$_HELP" 20 80
     continue


  elif [[ $MMSELECT = "E" ]]; then
   clean_exit
   fi
done

