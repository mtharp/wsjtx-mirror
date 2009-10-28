#------------------------------------------------------ options
from Tkinter import *
import Pmw
import g
import math

def done():
    root.withdraw()

root=Toplevel()
root.withdraw()
root.protocol('WM_DELETE_WINDOW',done)
if g.Win32: root.iconbitmap("wsjt.ico")
root.title("Options")

balloon=Pmw.Balloon(root)

#------------------------------------------------------ dbm_balloon
def dbm_balloon():
    mW=int(round(math.pow(10.0,0.1*dBm.get())))
    if(mW<1000):
        if mW==501: mW=500
        t="%d mW" % (mW,)
    else:
        W=int(0.001*mW + 0.5)
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
bfofreq=IntVar()
ComPort=IntVar()
SerialPort=StringVar()
ndevin=IntVar()
ndevout=IntVar()
DevinName=StringVar()
DevoutName=StringVar()
dBm=IntVar()
pttmode=StringVar()
serial_rate=IntVar()
serial_handshake=StringVar()
cat_enable=IntVar()
idint=IntVar()
rignum=IntVar()
inbad=IntVar()
outbad=IntVar()

pttmode.set('DTR')
serial_handshake.set('NONE')

pttlist=("CAT","DTR","RTS")
baudlist=(1200,4800,9600,19200,38400,57600)
hslist=("NONE","XONXOFF","Hardware")
pwrlist=(0,3,7,10,13,17,20,23,27,30,33,37,40,43,47,50,53,57,60)

MyCall=StringVar()
MyGrid=StringVar()
lcall=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Call:',
        value='Dummy',entry_textvariable=MyCall,entry_width=8)
lgrid=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Grid:',
        value='AB99',entry_textvariable=MyGrid,entry_width=5)
cwid=Pmw.EntryField(g1.interior(),labelpos=W,label_text='CW ID (min):',
        value='0',entry_textvariable=idint,entry_width=5)
comport=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Serial Port:',
        value='0',entry_textvariable=SerialPort,entry_width=12)
cbptt=Pmw.ComboBox(g1.interior(),labelpos=W,label_text='PTT:',
        entry_textvariable=pttmode,entry_width=4,scrolledlist_items=pttlist)
audioin=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Audio In:',
        value='0',entry_textvariable=DevinName,entry_width=12)
audioout=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Audio Out:',
        value='0',entry_textvariable=DevoutName,entry_width=12)
rxbfo=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Rx BFO (Hz):',
        value='1500',entry_textvariable=bfofreq,entry_width=12)
cbpwr=Pmw.ComboBox(g1.interior(),labelpos=W,label_text='Power (dBm):',
        entry_textvariable=dBm,entry_width=4,scrolledlist_items=pwrlist)
encat=Checkbutton(g1.interior(),text='Enable CAT',variable=cat_enable)
lrignum=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Rig num:',
        value='214',entry_textvariable=rignum,entry_width=8)
cbbaud=Pmw.ComboBox(g1.interior(),labelpos=W,label_text='Serial rate:',
        entry_textvariable=serial_rate,entry_width=4,scrolledlist_items=baudlist)
cbhs=Pmw.ComboBox(g1.interior(),labelpos=W,label_text='Handshake:',
        entry_textvariable=serial_handshake,entry_width=4,scrolledlist_items=hslist)
widgets = (lcall,lgrid,cwid,comport,cbptt,audioin,audioout,rxbfo,\
           cbpwr,encat,lrignum,cbbaud,cbhs)
for widget in widgets:
    widget.pack(fill=X,expand=1,padx=10,pady=2)
Pmw.alignlabels(widgets)
f1=Frame(g1.interior(),width=100,height=10)
f1.pack()

g1.pack(side=LEFT,fill=BOTH,expand=1,padx=6,pady=6)
