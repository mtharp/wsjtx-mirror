#!/bin/bash.exe
#
# Title ........: docenv-alias-list.sh
# Project ......: Part of the JTSDK v2.0.0 Project
# Description ..: List Alias commands in a readable format
# Project URL ..: http://sourceforge.net/projects/wsjt/
# Usage ........: From Within JTSDK-DOC, type: lista
#
# Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
# Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
# License ......: GPL-3
#
# docenv-alias-list.sh is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation either version 3 of the
# License, or (at your option) any later version. 
#
# docenv-alias-list.sh is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#--------------------------------------------------------------------#

# Exit on Errors
set -e

# Source Color Variables
source /scripts/color-variables

clear
echo -e ${C_Y}"JTSDK-DOC ALIAS LIST ( short-cuts )\n"${C_NC}
echo 'USAGE: [ command ]'
echo ''
echo -e ${C_C}"GENERAL COMMANDS"${C_NC}
echo -e "  help-jtsdk    # JTSDK-DOC main help file (man page)
  help-build    # Help with building documents
  help-co       # Help with checking out documentation
  checkout-doc  # Perform SVN Check ( anonymous )
  lista         # Display this help screen"
echo ''
echo -e ${C_C}"SVN COMMANDS"${C_NC}
echo -e "  svnu          # Perform SVN Update
   ss           # Normal SVN status
   sv           # List files not under SVN control
   sa           # List Added files only
   sm           # List Modified files only
   sd           # List Deleted files only"
echo ''
echo -e ${C_C}"BUILD COMMANDS ( requires $HOME/doc directory )"${C_NC}
echo -e '  You can build all documents either DATA-URI ( single file ), or
  linked. The syntax is the same for all. For DATA-URI, simply prefix
  the APP_NAME with the letter  ( d ).
  
  APP_NAMES:    all wsjtx wsjt wspr wfmt wsprx map65 simjt
  
  build-dwsjtx  # Build WSJT-X DATA-URI version
  build-wsjtx   # Build WSJT-X Linked version
  build-clean   # Remove "All" pre-built files
  build-devg    # Build dev-guide
  build-qref    # Build quick-reference guide'
echo ''

exit 0
