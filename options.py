#------------------------------------------------------ options
from Tkinter import *
import Pmw
import g

def done():
    root.withdraw()

root=Toplevel()
root.withdraw()
root.protocol('WM_DELETE_WINDOW',done)
if g.Win32: root.iconbitmap("wsjt.ico")
root.title("Options")

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

idinterval=Pmw.EntryField(g1.interior(),labelpos=W,label_text='ID Interval (m):',
        value=10,entry_textvariable=IDinterval,entry_width=12)
comport=Pmw.EntryField(g1.interior(),labelpos=W,label_text='PTT Port:',
        value='/dev/ttyS0',entry_textvariable=PttPort,entry_width=12)
audioin=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Audio In:',
        value='0',entry_textvariable=DevinName,entry_width=12)
audioout=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Audio Out:',
        value='0',entry_textvariable=DevoutName,entry_width=12)

widgets = (idinterval,comport,audioin,audioout)
for widget in widgets:
    widget.pack(fill=X,expand=1,padx=10,pady=2)

Pmw.alignlabels(widgets)
f1=Frame(g1.interior(),width=100,height=20)
f1.pack()

g1.pack(side=LEFT,fill=BOTH,expand=1,padx=6,pady=6)
