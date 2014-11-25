#!/bin/bash.exe
#
# Title ........: docenv-help-build.sh
# Project ......: Part of the JTSDK v2.0.0 Project
# Description ..: Help File For Building WSJT Documentation
# Project URL ..: http://sourceforge.net/projects/wsjt/
# Usage ........: From Within JTSDK-DOC, type: build-help
#
# Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
# Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
# License ......: GPL-3
#
# docenv-help-build.sh is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation either version 3 of the
# License, or (at your option) any later version. 
#
# docenv-help-build.sh is distributed in the hope that it will be
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
echo -e ${C_Y}"JTSDK-DOC BUILD HELP PAGE\n"${C_NC}
echo 'USAGE: [ build-doc.sh ] [ option ]'
echo ''
echo 'OPTION(s): all map65 simjt wsjt wsjtx'
echo '           wspr wsprx wfmt devg qref help clean'
echo ''
echo -e ${C_C}"BUILD LINKED"${C_NC}
echo '  All .....: ./build-doc.sh all'
echo '  WSJT-X ..: ./build-doc.sh wsjtx'
echo
echo -e ${C_C}"BUILD DATA-URI - ( single-file )"${C_NC}
echo '  All .....: ./build-doc.sh dall'
echo '  WSJT-X ..: ./build-doc.sh dwsjtx'
echo
echo -e ${C_C}"CLEAN FILES & FOLDERS"${C_NC}
echo '  All .....: ./build-doc.sh clean'
echo ''
echo -e ${C_C}"NOTE(s)"${C_NC}
echo -e '  [1] The same method is used for all documentaion.
      The prefix "d" designates a DATA-URI ( single-file )
      version of the document.
  
  [2] To see additional Short-Cuts, type: lista'
echo ''

exit 0
