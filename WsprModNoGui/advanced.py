#-------------------------------------------------------------------------------
# This file is part of the WSPR_NoGui.py application
#
# File Name:    advanced.py
# Description:
# Contributors: 4X6IZ, K1JT
# 
# Copyright (C) 2001-2014 Joseph Taylor, K1JT
# License: GNU GPL v3
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
# Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
#-------------------------------------------------------------------------------
#import g
from WsprModNoGui import g
from tkrep import *

idint=IntVar()
bfofreq=IntVar()
idint=IntVar()
igrid6=IntVar()
isc1=IntVar()
isc1.set(0)
encal=IntVar()
fset=IntVar()
Acal=DoubleVar()
Bcal=DoubleVar()
fset.set(0)
