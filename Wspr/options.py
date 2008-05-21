#------------------------------------------------------ options
from Tkinter import *
import Pmw
import g
import math
##import pyaudio

def done():
    root.withdraw()

root=Toplevel()
root.withdraw()
root.protocol('WM_DELETE_WINDOW',done)
if g.Win32: root.iconbitmap("wsjt.ico")
root.title("Options")

balloon=Pmw.Balloon(root)
##p = pyaudio.PyAudio()

#------------------------------------------------------ dbm_balloon
def dbm_balloon():
    mW=int(round(math.pow(10.0,0.1*dBm.get())))
    if(mW<1000):
        if mW==501: mW=500
        t="%d mW" % (mW,)
    else:
        W=int(mW/1000)
        if W==501: W=500
        t="%d W" % (W,)
    balloon.bind(cbpwr,t)


def options2(t):
    root.geometry(t)
    root.deiconify()
    root.focus_set()

#-------------------------------------------------------- Create GUI widgets
g1=Pmw.Group(root,tag_text="Station parameters")
IDinterval=IntVar()
ComPort=IntVar()
PttPort=StringVar()
ndevin=IntVar()
ndevout=IntVar()
DevinName=StringVar()
DevoutName=StringVar()
dBm=IntVar()

pwrlist=(0,3,7,10,13,17,20,23,27,30,33,37,40,43,47,50,53,57,60)

MyCall=StringVar()
MyGrid=StringVar()
lcall=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Call:',
        value='K1JT',entry_textvariable=MyCall,entry_width=8)
lgrid=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Grid:',
        value='FN20',entry_textvariable=MyGrid,entry_width=5)
##idinterval=Pmw.EntryField(g1.interior(),labelpos=W,label_text='ID Interval (m):',
##        value=0,entry_textvariable=IDinterval,entry_width=12)
comport=Pmw.EntryField(g1.interior(),labelpos=W,label_text='PTT Port:',
        value='0',entry_textvariable=PttPort,entry_width=12)
audioin=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Audio In:',
        value='0',entry_textvariable=DevinName,entry_width=12)
audioout=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Audio Out:',
        value='0',entry_textvariable=DevoutName,entry_width=12)
cbpwr=Pmw.ComboBox(g1.interior(),labelpos=W,label_text='Power (dBm):',
        entry_textvariable=dBm,entry_width=4,scrolledlist_items=pwrlist)

widgets = (lcall,lgrid,comport,audioin,audioout,cbpwr)
for widget in widgets:
    widget.pack(fill=X,expand=1,padx=10,pady=2)
Pmw.alignlabels(widgets)
f1=Frame(g1.interior(),width=100,height=10)
f1.pack()

g1.pack(side=LEFT,fill=BOTH,expand=1,padx=6,pady=6)
