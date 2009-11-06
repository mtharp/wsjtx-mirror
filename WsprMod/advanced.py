#------------------------------------------------------ advanced
from Tkinter import *
import Pmw
import g

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


#-------------------------------------------------------- Create GUI widgets
g1=Pmw.Group(root,tag_pyclass=None)

t="""
Set a CW ID interval (in minutes) only if your regulating
authority requires you to identify in Morse code.
Otherwise leave the ID interval set to 0.

Please note: unnecessary use of CW identification causes
needless interference to other WSPR signals, since CW
bandwidth is much more than WSPR signal bandwidth.
"""
lab1=Label(g1.interior(),text=t,justify=LEFT)

cwid=Pmw.EntryField(g1.interior(),labelpos=W,label_text='CW ID (minutes):',
        value='0',entry_textvariable=idint,entry_width=5)

t="""
Normally the WSPR reception band is centered at dial
frequency plus 1500 Hz.  This offset is the correct value
for all standard transceivers.  Users of special hardware
(SoftRock, etc.) may select a different BFO frequency here.  
"""
lab2=Label(g1.interior(),text=t,justify=LEFT)

rxbfo=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Rx BFO (Hz):',
        value='1500',entry_textvariable=bfofreq,entry_width=12)

t="""
Normal WSPR transmissions use 4-character locators,
foe example:

    K1ABC FN42 37

If you must use a compound callsign such as PJ4/K1ABC
or K1ABC/P, WSPR will use a two-transmission sequence
including your 6-digit locator:

    PJ4/K1ABC 37
    <K1ABC> FK52UD 37

Although not recommended for normal use, you may force
two-transmission sequences with 6-digit locators by
checking the box below.  The sequence will then have
this form:

    K1ABC FN42 37
    <K1ABC> FN42AX 37
"""
lab3=Label(g1.interior(),text=t,justify=LEFT)
bgrid6=Checkbutton(g1.interior(),text='Transmit 6-digit locator',variable=igrid6)

widgets = (lab1,cwid,lab2,rxbfo,lab3,bgrid6)
for widget in widgets:
    widget.pack(fill=X,expand=1,padx=5,pady=0)
Pmw.alignlabels(widgets)
f1=Frame(g1.interior(),width=100,height=10)
f1.pack()
g1.pack(side=LEFT,fill=BOTH,expand=1,padx=4,pady=4)
