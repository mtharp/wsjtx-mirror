#!/bin/bash.exe
#
# Title ........: msys-alias-list.sh
# Project ......: Part of the JTSDK v2.0.0 Project
# Description ..: List Alias commands in a readable format
# Project URL ..: http://sourceforge.net/projects/wsjt/
# Usage ........: From Within JTSDK-MSYS, type: lista
#
# Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
# Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
# License ......: GPL-3
#
# msys-alias-list.sh is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation either version 3 of the
# License, or (at your option) any later version. 
#
# msys-alias-list.sh is distributed in the hope that it will be
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

clsb
echo -e ${C_Y}"JTSDK-MSYS ALIAS LIST ( short-cuts )\n"${C_NC}
echo 'USAGE: [ command ]'
echo ''
echo -e ${C_C}"GENERAL COMMANDS"${C_NC}
echo -e "  build-hamlib3     # Build G4WJS Public Version of Hamlib3
  build-fftw        # Build FFTW Single ( static )
  build-portaudio   # Build Portaudio ( static )
  build-samplerate  # Build libsamplerate ( static )
  lista             # Display this help screen"
echo ''

exit 0
