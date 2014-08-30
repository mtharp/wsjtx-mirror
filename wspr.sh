#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# This file is part of the WSPR application, Weak Signal Propogation Reporter
#
# File Name:    wspr.sh
# Description:  Shell script wrapper to update or copy files from system install
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

set -e

# set dir's
_HOMEDIR="/home/$USER/.wspr"

# make a few dir's
mkdir -p $_HOMEDIR

# update files only if newer
cp -uR /usr/share/wspr/* $_HOMEDIR
cp -uR /usr/share/doc/wspr/* $_HOMEDIR/
cp -uR /usr/lib/wspr/* $_HOMEDIR

# run: py location updated by configure.ac
cd $_HOMEDIR
/usr/bin/python3 -O wspr.py
