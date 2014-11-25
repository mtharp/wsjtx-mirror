#!/bin/bash.exe
#
# Title ........: docenv-header.sh
# Project ......: Part of the JTSDK v2.0.0 Project
# Description ..: Displays the login and man page test
# Project URL ..: http://sourceforge.net/projects/wsjt/
# Usage ........: From Within JTSDK-DOC, type: co-help
#
# Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
# Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
# License ......: GPL-3
#
# docenv-header.sh is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation either version 3 of the
# License, or (at your option) any later version. 
#
# docenv-header.sh is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#--------------------------------------------------------------------#

# Exit on Errors
set -e
source /scripts/color-variables

clear
echo -en ${C_Y} && cat /scripts/docenv-header.txt && echo -e ${C_NC}

exit 0 
 
 