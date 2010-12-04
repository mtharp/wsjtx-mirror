#------------------------------------------------------------------ iq
from Tkinter import *
import Pmw
import g
import w
import time
import tkMessageBox
from functools import partial

def done():
    root.withdraw()

root=Toplevel()
root.withdraw()
root.protocol('WM_DELETE_WINDOW',done)
if g.Win32: root.iconbitmap("wsjt.ico")
root.title("Frequency Hopping")

def hopping2(t):
    root.geometry(t)
    root.deiconify()
    root.focus_set()

# bands, labeled 1 to 14 (and 15 for 'other')
bandlabels=['dummy','600 m','160 m','80 m','60 m','40 m','30 m',\
            '20 m','17 m','15 m','12 m','10 m','6 m','4 m','2 m',\
            'Other']

coord_bands=IntVar()
coord_bands.set(0)
hopping=IntVar()
hopping.set(0)
hoppingconfigured=IntVar()
hoppingconfigured.set(0)
bhopping   =range(len(bandlabels))
shopping   =range(len(bandlabels))
lhopping   =range(len(bandlabels))
hoppingflag=range(len(bandlabels))
hoppingpctx=range(len(bandlabels))

#-------------------------------------------------------- Create GUI widgets
g1=Pmw.Group(root,tag_pyclass=None)
r=0
lband=Label(g1.interior(),text='Band')
lband.grid(row=r,column=0,padx=2,pady=2,sticky='SW')
lpctx=Label(g1.interior(),text='Tx fraction (%)')
lpctx.grid(row=r,column=1,padx=2,pady=2,sticky='SW')
llab=Label(g1.interior(),text='      ') # to make space for the percentage labels without repacking
llab.grid(row=r,column=2,padx=2,pady=2,sticky='SW')

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
    bhopping[r]=Checkbutton(g1.interior(),text=bandlabels[r],command=bcmd,variable=hoppingflag[r])
    bhopping[r].grid(row=r,column=0,padx=2,pady=3,sticky='SW')
    shopping[r]=Scale(g1.interior(),orient=HORIZONTAL,length=200,from_=0, to=100,command=scmd,variable=hoppingpctx[r],showvalue=0)
    shopping[r].grid(row=r,column=1,padx=2,pady=2,sticky='SW')
    lhopping[r]=Label(g1.interior(),text='0')
    lhopping[r].grid(row=r,column=2,padx=2,pady=2,sticky='SW')

cbcoord=Checkbutton(g1.interior(),text='Coordinated bands',variable=coord_bands)
cbcoord.grid(row=18,column=1,padx=2,pady=2,sticky='S')
g1.pack(side=LEFT,fill=X,expand=0,padx=4,pady=4)

