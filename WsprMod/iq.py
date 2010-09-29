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
root.title("I-Q Mode")

def iq2(t):
    root.geometry(t)
    root.deiconify()
    root.focus_set()

iqmode=IntVar()
iqrx=IntVar()
iqtx=IntVar()
fiq=IntVar()
iqrxapp=IntVar()
iqrxadj=IntVar()

isc1=IntVar()
isc1.set(0)
isc2=IntVar()
isc2.set(0)
isc2a=IntVar()
isc2a.set(0)
isc3=IntVar()
isc3.set(0)
isc3a=IntVar()
isc3a.set(0)

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

biqtx=Checkbutton(g1.interior(),text='Reverse Tx I,Q',variable=iqtx)
biqtx.pack(anchor=W,padx=5,pady=2)

biqrx=Checkbutton(g1.interior(),text='Reverse Rx I,Q',variable=iqrx)
biqrx.pack(anchor=W,padx=5,pady=2)

biqrxapp=Checkbutton(g1.interior(),text='Apply phasing corrections', \
        variable=iqrxapp)
biqrxapp.pack(anchor=W,padx=5,pady=2)

biqrxadj=Checkbutton(g1.interior(),text='Adjust phasing', \
        variable=iqrxadj)
biqrxadj.pack(anchor=W,padx=5,pady=2)

lab1=Label(g1.interior(),text='',justify=LEFT)
lab1.pack(anchor=W,padx=5,pady=4)

fiq_entry=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Fiq (Hz):         ',
        value='12000',entry_textvariable=fiq,entry_width=10,
        validate={'validator':'integer','min':-24000,'max':24000,
        'minstrict':0,'maxstrict':0})
fiq_entry.pack(fill=X,padx=2,pady=4)

##t='Tx dB  Tx amp  Tx Pha'
##lab1=Label(g1.interior(),text=t,justify=LEFT)
##lab1.pack(fill=X,expand=1,padx=5,pady=0)

sc1=Scale(g1.interior(),orient=HORIZONTAL,length=200,from_=-30, \
        to=0,variable=isc1,label='Tx dB',relief=SOLID,bg='#FFC0CB')
sc1.pack(side=TOP,padx=4,pady=2)

sc2=Scale(g1.interior(),orient=HORIZONTAL,length=200,from_=-30, \
        to=30,variable=isc2,label='Tx I/Q Balance (0.1 dB)', \
        relief=SOLID,bg='#EEDD82')
sc2.pack(side=TOP,padx=4,pady=2)

sc2a=Scale(g1.interior(),orient=HORIZONTAL,length=200,from_=-100, \
        to=100,variable=isc2a,label='Tx I/Q Balance (0.002 dB)', \
        relief=SOLID,bg='#EEDD82')
sc2a.pack(side=TOP,padx=4,pady=2)

sc3=Scale(g1.interior(),orient=HORIZONTAL,length=200,from_=-20, \
        to=20,variable=isc3,label='Tx Phase (deg)', \
        relief=SOLID,bg='#AFeeee')
sc3.pack(side=TOP,padx=4,pady=2)
sc3a=Scale(g1.interior(),orient=HORIZONTAL,length=200,from_=-100, \
        to=100,variable=isc3a,label='Tx Phase (0.02 deg)', \
        relief=SOLID,bg='#AFeeee')
sc3a.pack(side=TOP,padx=4,pady=2)

f1=Frame(g1.interior(),width=100,height=10)
f1.pack()
g1.pack(side=LEFT,fill=BOTH,expand=1,padx=4,pady=4)
