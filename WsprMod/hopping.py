#-------------------------------------------------------------------------------
# This file is part of the WSPR application, Weak Signal Propagation Reporter
#
# File Name:    hopping.py
# Description:
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
from tkinter import *
import Pmw
from WsprMod import g
from WsprMod import w
import os,time
import tkinter.messagebox
from functools import partial

def done():
    root.withdraw()

root=Toplevel()
root.withdraw()
root.protocol('WM_DELETE_WINDOW',done)
if g.Win32: root.iconbitmap("wsjt.ico")
root.title("Band Hopping")

def hopping2(t):
    root.geometry(t)
    root.deiconify()
    root.focus_set()

# bands, labeled 1 to 14 (and 15 for 'other')
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

#-------------------------------------------------------- Create GUI widgets
g1=Pmw.Group(root,tag_pyclass=None)
r=0
lband=Label(g1.interior(),text='Band')
lband.grid(row=r,column=0,padx=2,pady=2,sticky='SW')
lpctx=Label(g1.interior(),text='Tx fraction (%)')
lpctx.grid(row=r,column=1,padx=2,pady=2,sticky='SW')
llab=Label(g1.interior(),text='      ') # to make space for the percentage labels without repacking
llab.grid(row=r,column=2,padx=2,pady=2,sticky='SW')
ltune=Label(g1.interior(),text='Tuneup')
ltune.grid(row=r,column=3,padx=2,pady=2,sticky='SW')

def globalupdate():
    global hopping
    localhopping=0
    for band in range(1,len(bandlabels)):
        if hoppingflag[band].get()!=0: localhopping=1
    hoppingconfigured.set(localhopping)
    if not localhopping: hopping.set(0)

def toggle(band):
    globalupdate()

def chpctx(band, event):
    pctx = hoppingpctx[band].get()
    t = "%s" % pctx
    lhopping[band].configure(text=t)

for r in range(1,16):
    bcmd = partial(toggle, r)
    scmd = partial(chpctx, r)
    hoppingflag[r] = IntVar()
    hoppingflag[r].set(0)
    hoppingpctx[r] = IntVar()
    hoppingpctx[r].set(0)
    tuneupflag[r] = IntVar()
    tuneupflag[r].set(0)
    bhopping[r]=Checkbutton(g1.interior(),text=bandlabels[r],command=bcmd, \
                        variable=hoppingflag[r])
    bhopping[r].grid(row=r,column=0,padx=2,pady=3,sticky='SW')
    shopping[r]=Scale(g1.interior(),orient=HORIZONTAL,length=200,from_=0, \
                        to=100,command=scmd,variable=hoppingpctx[r],showvalue=0)
    shopping[r].grid(row=r,column=1,padx=2,pady=2,sticky='SW')
    lhopping[r]=Label(g1.interior(),text='0')
    lhopping[r].grid(row=r,column=2,padx=2,pady=2,sticky='SW')
    btuneup[r]=Checkbutton(g1.interior(),text="",command=bcmd, \
                           variable=tuneupflag[r])
    btuneup[r].grid(row=r,column=3,padx=2,pady=3,sticky='SW')

cbcoord=Checkbutton(g1.interior(),text='Coordinated hopping',variable=coord_bands)
cbcoord.grid(row=18,column=1,padx=2,pady=2,sticky='S')
g1.pack(side=LEFT,fill=X,expand=0,padx=4,pady=4)

def save_params(appdir):
    f=open(appdir+'/hopping.ini',mode='w')
    t="%d %d\n" % (hopping.get(),coord_bands.get())
    f.write(t)
    for r in range(1,16):
        t="%4s %2d %5d %2d\n" % (bandlabels[r][:-2], hoppingflag[r].get(), \
                                hoppingpctx[r].get(),tuneupflag[r].get())
        f.write(t)
    f.close()

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
            globalupdate()
        except:
            print('Error reading hopping.ini.')
