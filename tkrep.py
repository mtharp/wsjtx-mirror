#-------------------------------------------------------------------------------
# This file is part of the WSPR_NoGui.py application
#
# File Name:    tkrep.py
# Description:  replacement for Tk classes
# Contributors: 4X6IZ, K1JT
# 
# Copyright (C) 2001-2014 Joseph Taylor, K1JT
# License: GPL-3+
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
NONE=None

class IntVar:
    def __init__(self):
        self.i = 0
    def set(self, i):
        self.i = int(i)
    def get(self):
        return self.i

class StringVar:
    def __init__(self):
        self.i = ''
    def set(self, i):
        self.i = i
    def get(self):
        return self.i

# Sivan: seems that newly created DoubleVar's contain a string, not a float 0.0. Strange
class DoubleVar:
    def __init__(self):
        self.i = 0.0
    def set(self, i):
        self.i = float(i)
    def get(self):
        return self.i

