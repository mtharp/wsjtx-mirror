#!/bin/bash.exe
#
# Title ........: cyg32-co-help.sh
# Project ......: Part of the JTSDK v2.0.0 Project
# Description ..: Help File For Checking Out WSJT Documentation
# Project URL ..: http://sourceforge.net/projects/wsjt/
# Usage ........: From Within JTSDK-CYG32, type: co-help
#
# Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
# Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
# License ......: GPL-3
#
# cyg32-co-help.sh is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation either version 3 of the
# License, or (at your option) any later version. 
#
# cyg32-co-help.sh is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#--------------------------------------------------------------------#

# Exit on Errors
set -e

# Source Standard Color Variables File
source /scripts/color-variables

# Display Document Help Help Message
clear
echo -e ${C_Y}"DOCUMENT CHECKOUT HELP"${C_NC}
echo ''
echo ' In order to build WSJT Documentation, you'
echo ' must first perform a checkout from'
echo ' WSJT @ SourceForge'
echo ''
echo -e ${C_C} "ANONYMOUS CHECKOUT"${C_NC}
echo ' -------------------'
echo ' Typpe: checkout-doc'
echo ''
echo -e ${C_C} "DEVELOPER CHECKOUT"${C_NC}
echo ' ------------------'
echo " svn co https://$USER@svn.code.sf.net/p/wsjt/wsjt/branches/doc"
echo ''
echo -e " Replace [ ${C_Y}$USER${C_NC} ] with your SorceForge User Name."
echo ''
echo -e ${C_C} "BUILD COMMANDS"${C_NC}
echo ' ------------------'
echo ' To List build commands, type: build-help'
echo ''

exit 0