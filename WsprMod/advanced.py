#------------------------------------------------------ advanced
from Tkinter import *
import Pmw
import g
import w

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
    w.acom1.ncal=1
    bcal.configure(bg='green')

#-------------------------------------------------------- Create GUI widgets
g1=Pmw.Group(root,tag_pyclass=None)

t="""
Important:

Please read the WSPR User's Guide before
using any features on this screen.
"""
lab1=Label(g1.interior(),text=t,justify=LEFT)

cwid=Pmw.EntryField(g1.interior(),labelpos=W,label_text='CW ID (minutes):',
        value='0',entry_textvariable=idint,entry_width=5)
rxbfo=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Rx BFO (Hz):',
        value='1500',entry_textvariable=bfofreq,entry_width=10)
fcal=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Fcal factor:',
        value='1.0000000',entry_textvariable=calfactor,entry_width=10)
lab2=Label(g1.interior(),text='',justify=LEFT)
bgrid6=Checkbutton(g1.interior(),text='Transmit 6-digit locator',variable=igrid6)

widgets = (lab1,cwid,rxbfo,fcal,lab2,bgrid6)
for widget in widgets:
    widget.pack(fill=X,expand=1,padx=5,pady=0)

lab3=Label(g1.interior(),text='',justify=LEFT).pack()

bcal=Button(g1.interior(), text='Measure an audio\nfrequency',command=freqcal,
             width=16,padx=1,pady=2)
bcal.pack(side=TOP,padx=10,pady=3)

Pmw.alignlabels(widgets)
f1=Frame(g1.interior(),width=100,height=10)
f1.pack()
g1.pack(side=LEFT,fill=BOTH,expand=1,padx=4,pady=4)
