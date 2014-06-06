#-------------------------------------------------------------------------------
# This file is part of the WSPR_NoGui.py application
#
# File Name:    hopping.py
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
import os,time
from . import g
from tkrep import *

bandlabels=['dummy','600 m','160 m','80 m','60 m','40 m','30 m',\
            '20 m','17 m','15 m','12 m','10 m','6 m','4 m','2 m',\
            'Other']

coord_bands=IntVar()
coord_bands.set(1)
hopping=IntVar()
hopping.set(0)
hoppingconfigured=IntVar()
hoppingconfigured.set(0)
bhopping   =list(range(len(bandlabels)))
shopping   =list(range(len(bandlabels)))
lhopping   =list(range(len(bandlabels)))
hoppingflag=list(range(len(bandlabels)))
hoppingpctx=list(range(len(bandlabels)))
btuneup    =list(range(len(bandlabels)))
tuneupflag =list(range(len(bandlabels)))

for r in range(1,16):
    hoppingflag[r] = IntVar()
    hoppingflag[r].set(0)
    hoppingpctx[r] = IntVar()
    hoppingpctx[r].set(0)
    tuneupflag[r] = IntVar()
    tuneupflag[r].set(0)

#def save_params(appdir):
#    f=open(appdir+'/hopping.ini',mode='w')
#    t="%d %d\n" % (hopping.get(),coord_bands.get())
#    f.write(t)
#    for r in range(1,16):
#        t="%4s %2d %5d %2d\n" % (bandlabels[r][:-2], hoppingflag[r].get(), \
#                                hoppingpctx[r].get(),tuneupflag[r].get())
#        f.write(t)
#    f.close()

def restore_params(appdir):
    if os.path.isfile(appdir+'/hopping.ini'):
        try:
            f=open(appdir+'/hopping.ini',mode='r')
            s=f.readlines()
            f.close()
            hopping.set(int(s[0][0:1]))
            coord_bands.set(int(s[0][2:3]))
            for r in range(1,16):
                hoppingflag[r].set(int(s[r][6:7]))
                hoppingpctx[r].set(int(s[r][8:13]))
                tuneupflag[r].set(int(s[r][13:16]))
#            globalupdate()
        except:
            print('Error reading hopping.ini.')
