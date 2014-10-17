#-------------------------------------------------------------------------------
# This file is part of the WSPR_NoGui.py application
#
# File Name:    iq.py
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
#import w
#import g
from WsprModNoGui import g
from WsprModNoGui import w
from tkrep import *
import pickle

NONE=None

iqmode=IntVar()
iqrx=IntVar()
iqtx=IntVar()
fiq=IntVar()
iqrxapp=IntVar()
iqrxadj=IntVar()

isc2=IntVar()
isc2.set(0)
isc2a=IntVar()
isc2a.set(0)
isc3=IntVar()
isc3.set(0)
isc3a=IntVar()
isc3a.set(0)

ib=IntVar()
gain=DoubleVar()
phdeg=DoubleVar()
mb=[0,600,160,80,60,40,30,20,17,15,12,10,6,4,2,0]
tbal=[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
tpha=[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
rbal=[1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0]
rpha=[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
allbands=0

def saveband(event=NONE):
    global allbands,tbal,tpha,rbal,rpha
    if allbands:
        for j in range(1,15):
            tbal[j]=isc2.get() + 0.02*isc2a.get()
            tpha[j]=isc3.get() + 0.02*isc3a.get()
            rbal[j]=w.acom1.gain
            rpha[j]=57.2957795*w.acom1.phase
    else:
        j=ib.get()
        tbal[j]=isc2.get() + 0.02*isc2a.get()
        tpha[j]=isc3.get() + 0.02*isc3a.get()
        rbal[j]=w.acom1.gain
        rpha[j]=57.2957795*w.acom1.phase

    f=open(g.appdir+'/iqpickle',mode='w')
    pickle.dump(tbal,f)    
    pickle.dump(tpha,f)    
    pickle.dump(rbal,f)    
    pickle.dump(rpha,f)    
    f.close()

def saveall(event=NONE):
    global allbands
    allbands=1
    saveband()
    allbands=0

def restore():
    global tbal,tpha,rbal,rpha
    try:
        f=open(g.appdir+'/iqpickle',mode='r')
        tbal=pickle.load(f)
        tpha=pickle.load(f)
        rbal=pickle.load(f)
        rpha=pickle.load(f)
        f.close()
    except:
        pass
    newband()

def newband():
    j=ib.get()
    #lab0.configure(text=str(mb[j])+' m') #gui related
    w.acom1.gain=rbal[j]
    w.acom1.phase=rpha[j]/57.2957795
    isc2.set(int(tbal[j]))
    isc2a.set(int((tbal[j]-isc2.get())/0.02))
    isc3.set(int(tpha[j]))
    isc3a.set(int((tpha[j]-isc3.get())/0.02))
