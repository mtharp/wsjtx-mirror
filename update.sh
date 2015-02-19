#!/usr/bin/env bash
#
# Title ........: update.sh
# Description ..: Update all documentation folders from SVN Win32/Linux
# Project URL ..: http://sourceforge.net/projects/wsjt/
# Requires .....: Bash, Coreutils
#
# Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
# Copyright ....: Copyright (C) 2015 Joe Taylor, K1JT
# License ......: GPL-3
#
# Comment ......: This script is used with JTSDK v2 for Windows via the
#                 JTSDK-DOC environment (Cyg32) and should work as a stand
#                 alone script on Linux provided the package requirments
#                 are met.
#
# update.sh is free software: you can redistribute it and/or modify it 
# under the terms of the GNU General Public License as published by the Free
# Software Foundation either version 3 of the License, or (at your option) any
# later version. 
#
# update.sh is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

################################################################################

# Exit on error
set -e

################################################################################
# Variables                                                                    #
################################################################################

# Main variables
BASEDIR=$(exec pwd)

# Color variables
C_R='\033[01;31m'		# red
C_G='\033[01;32m'		# green
C_Y='\033[01;33m'		# yellow
C_C='\033[01;36m'		# cyan
C_NC='\033[01;37m'		# no color

# document folder names. the names must match the folders actual name
declare -a doc_ary=('map65' 'simjt' 'wsjt' 'wsjtx' 'wspr' 'wsprx' 'wfmt'
'quick-ref' 'dev-guide' 'dev-guide2')

################################################################################
# Functions                                                                    #
################################################################################

# cancel update ----------------------------------------------------------------
function cancel_update() {
	clear
	echo -e ${C_R}'*** SIGNAL CAUGHT, PERFORMING CLEAN EXIT ***'${C_NC}
	echo
	echo -e ${C_Y}'Canceling Update'${C_NC}
	echo

	# reset the traps
	trap - SIGHUP SIGINT SIGQUIT SIGTERM SIGTSTP

	exit 0
}	

################################################################################
# start the main script                                                        #
################################################################################

# Trap Ctrl+C, Ctrl+Z and quit signals
trap cancel_update SIGHUP SIGINT SIGQUIT SIGTERM SIGTSTP

# check for svn
set +e
which svn > /dev/null
if [ "$?" -eq "1" ]; then
	clear
	echo -e ${C_Y}"Subversion Error: Not Found"${C_NC}
	echo
	echo 'Please ensure Subversion is installed and can be'
	echo "found from the command line, then re-run $0"
	echo
	trap - SIGHUP SIGINT SIGQUIT SIGTERM SIGTSTP
	exit 1
fi
set -e

# start updating
clear
echo -e ${C_Y}"Updating Documentation Folders From SVN"${C_NC}
echo

# loop through each sub-folder in the array and svn update
for f in "${doc_ary[@]}"
	do
		app_name="$f"
		cd "$f/"
		dir=$(exec pwd)
		echo -e ${C_C}"updating: $dir"${C_NC}
		svn cleanup
		svn update
		cd "$BASEDIR"
	done
echo
echo -e ${C_Y}"Finishing Updating: ${doc_ary[*]}"${C_NC}
echo

# reset the traps
trap - SIGHUP SIGINT SIGQUIT SIGTERM SIGTSTP

# exit status 0
exit 0
