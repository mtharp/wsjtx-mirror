#!/usr/bin/env python
#-------------------------------------------------------------------------------
# This file is part of the WSPR application, Weak Signal Propagation Reporter
#
# File Name:    setup.py
# Description:  Python3 setup and installation script
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
version = "WSPR Version " + "4.00" + ", by K1JT"

from distutils.core import setup
from distutils.file_util import copy_file
import os

def wspr_install(install):
#
# In a true python environment, w.so would be compiled from python
# I'm doing a nasty hack here to support our hybrid build system -db
#
	if install == 1:
	    os.makedirs('build/lib/WsprMod')
	    copy_file('WsprMod/w.so', 'build/lib/WsprMod')
	setup(name='Wspr',
	version=version,
	description='Wspr Python Module for Weak Signal detection',
	long_description='''
WSPR is a computer program designed to facilitate Amateur Radio
communication under extreme weak-signal conditions. 
''',
	author='Joe Taylor',
	author_email='joe@Princeton.EDU',
	license='GPL-3+',
	url='http://physics.princeton.edu/pulsar/K1JT',
	scripts=['wspr.py'],
	      packages=['WsprMod'],
	)

if __name__ == '__main__':
	import sys
	if 'install' in sys.argv:
		wspr_install(1)
	else:
		wspr_install(0)

