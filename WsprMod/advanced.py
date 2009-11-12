#------------------------------------------------------ advanced
from Tkinter import *
import Pmw
import g
import w
import time

def done():
    root.withdraw()

root=Toplevel()
root.withdraw()
root.protocol('WM_DELETE_WINDOW',done)
if g.Win32: root.iconbitmap("wsjt.ico")
root.title("Advanced")

def advanced2(t):
    root.geometry(t)
    root.deiconify()
    root.focus_set()

idint=IntVar()
bfofreq=IntVar()
idint=IntVar()
igrid6=IntVar()
calfactor=DoubleVar()

#------------------------------------------------------ freqcal
def freqcal(event=NONE):
    if w.acom1.ncal==0:
        bcal.configure(bg='green')
        w.acom1.ncal=1

#-------------------------------------------------------- Create GUI widgets
g1=Pmw.Group(root,tag_pyclass=None)

t="""
Important:   please read the WSPR User's
Guide (F3 key) before using features on
this screen.
"""
lab1=Label(g1.interior(),text=t,justify=LEFT)
lab1.pack(fill=X,expand=1,padx=5,pady=0)

cwid=Pmw.EntryField(g1.interior(),labelpos=W,label_text='CW ID (minutes):',
        value='0',entry_textvariable=idint,entry_width=5,
        validate={'validator':'numeric','min':0,'max':60})
rxbfo=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Rx BFO (Hz):',
        value='1500',entry_textvariable=bfofreq,entry_width=10,
        validate={'validator':'real','min':-3000,'max':3000})
fcal=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Fcal factor:',
        value='1.0000000',entry_textvariable=calfactor,entry_width=10,
        validate={'validator':'real','min':0.99999,'max':1.00001,
        'minstrict':0,'maxstrict':0})
widgets = (cwid,rxbfo,fcal)
for widget in widgets:
    widget.pack(fill=X,padx=2,pady=2)

bcal=Button(g1.interior(), text='Measure an audio frequency',command=freqcal,
             width=26,padx=1,pady=2)
bcal.pack(padx=5,pady=5)
bgrid6=Checkbutton(g1.interior(),text='Transmit 6-digit locator',
                   variable=igrid6)
bgrid6.pack(padx=5,pady=2)

Pmw.alignlabels(widgets)
f1=Frame(g1.interior(),width=100,height=10)
f1.pack()
g1.pack(side=LEFT,fill=BOTH,expand=1,padx=4,pady=4)
