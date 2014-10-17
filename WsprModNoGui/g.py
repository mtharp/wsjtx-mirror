#-------------------------------------------------------------------------------
# This file is part of the WSPR_NoGui.py application
#
# File Name:    g.py
# Description:
# Contributors: 4X6IZ, K1JT
# 
# Copyright (C) 2001-2014 Joseph Taylor, K1JT
# License: GPL-3
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
DFreq=0.0
Freq=0.0
PingTime=0.0
PingFile="current"
report="26"
rms=1.0
mode_change=0
showspecjt=0
g2font='courier 16 bold'

#------------------------------------------------------ filetime
def filetime(t):
#    i=t.rfind(".")
    i=rfnd(t,".")
    t=t[:i][-6:]
#    t=t[0:2]+":"+t[2:4]+":"+t[4:6]
    return t

#------------------------------------------------------ rfnd
#Temporary workaround to replace t.rfind(c)
def rfnd(t,c):
    for i in range(len(t)-1,0,-1):
        if t[i:i+1]==c: return i
    return -1
