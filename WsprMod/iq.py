#------------------------------------------------------------------ iq
from Tkinter import *
import Pmw
import g
import w
import time
import tkMessageBox

def done():
    root.withdraw()

root=Toplevel()
root.withdraw()
root.protocol('WM_DELETE_WINDOW',done)
if g.Win32: root.iconbitmap("wsjt.ico")
root.title("Advanced")

def iq2(t):
    root.geometry(t)
    root.deiconify()
    root.focus_set()

iqmode=IntVar()
iqrx=IntVar()
iqtx=IntVar()
fiq=IntVar()

#-------------------------------------------------------- Create GUI widgets
g1=Pmw.Group(root,tag_pyclass=None)

##t="""
##Important:   please read the WSPR User's
##Guide (F3 key) before using features on
##this screen.
##"""
##lab1=Label(g1.interior(),text=t,justify=LEFT)
##lab1.pack(fill=X,expand=1,padx=5,pady=0)

biqmode=Checkbutton(g1.interior(),text='Enable I/Q mode',variable=iqmode)
biqmode.pack(anchor=W,padx=5,pady=2)

biqrx=Checkbutton(g1.interior(),text='Reverse Rx I,Q',variable=iqrx)
biqrx.pack(anchor=W,padx=5,pady=2)

biqtx=Checkbutton(g1.interior(),text='Reverse Tx I,Q',variable=iqtx)
biqtx.pack(anchor=W,padx=5,pady=2)

fiq_entry=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Fiq (Hz):         ',
        value='12000',entry_textvariable=fiq,entry_width=10,
        validate={'validator':'integer','min':-24000,'max':24000,
        'minstrict':0,'maxstrict':0})
fiq_entry.pack(fill=X,padx=2,pady=2)

##pctscale=Scale(g2.interior(),orient=HORIZONTAL,length=350,from_=0, \
##               to=100,tickinterval=10,variable=ipctx)
##pctscale.pack(side=LEFT,padx=4)
##balloon.bind(pctscale,"Select desired fraction of sequences to transmit")
##ipctx.set(0)

f1=Frame(g1.interior(),width=100,height=10)
f1.pack()
g1.pack(side=LEFT,fill=BOTH,expand=1,padx=4,pady=4)
