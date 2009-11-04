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
ptt_port=IntVar()
CatPort=StringVar()
PttPort=StringVar()
ndevin=IntVar()
ndevout=IntVar()
DevinName=StringVar()
DevoutName=StringVar()
dBm=IntVar()
dBm.set(37)
pttmode=StringVar()
serial_rate=IntVar()
serial_rate.set(4800)
databits=IntVar()
databits.set(8)
stopbits=IntVar()
stopbits.set(2)
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
hslist=("None","XONXOFF","Hardware")
pwrlist=(0,3,7,10,13,17,20,23,27,30,33,37,40,43,47,50,53,57,60)

if g.Win32:
    serialportlist=("None","COM1","COM2","COM3","COM4","COM5","COM6", \
        "COM7","COM8","COM9","COM10","COM11","COM12","COM13","COM14","COM15")
else:
    serialportlist=("None","/dev/ttyS0","/dev/ttyS1","/dev/ttyUSB0", \
        "/dev/ttyUSB1","/dev/ttyUSB2","/dev/ttyUSB3","/dev/ttyUSB4", \
        "/dev/ttyUSB5","/dev/ttyUSB6","/dev/ttyUSB7","/dev/ttyUSB8")
                    
datalist=(7,8)
stoplist=(1,2)
indevlist=[]
outdevlist=[]

MyCall=StringVar()
MyGrid=StringVar()

try:
    f=open('audio_caps','r')
    s=f.readlines()
    f.close
    t="Input Devices:\n"
    for i in range(len(s)):
        col=s[i].split()
        if int(col[1])>0:
            t=str(i) + s[i][29:]
            t=t[:len(t)-1]
            indevlist.append(t)
    for i in range(len(s)):
        col=s[i].split()
        if int(col[2])>0:
            t=str(i) + s[i][29:]
            t=t[:len(t)-1]
            outdevlist.append(t)
except:
    pass

#------------------------------------------------------ audin
def audin(event=NONE):
    g.DevinName.set(DevinName.get())
    g.ndevin.set(int(DevinName.get()[:2]))
    
#------------------------------------------------------ audout
def audout(event=NONE):
    g.DevoutName.set(DevoutName.get())
    g.ndevout.set(int(DevoutName.get()[:2]))


lcall=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Call:',
        value='',entry_textvariable=MyCall,entry_width=8)
lgrid=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Grid:',
        value='',entry_textvariable=MyGrid,entry_width=5)
cwid=Pmw.EntryField(g1.interior(),labelpos=W,label_text='CW ID (min):',
        value='0',entry_textvariable=idint,entry_width=5)
rxbfo=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Rx BFO (Hz):',
        value='1500',entry_textvariable=bfofreq,entry_width=12)
audioin=Pmw.ComboBox(g1.interior(),labelpos=W,label_text='Audio In:',
        entry_textvariable=DevinName,entry_width=30,
        scrolledlist_items=indevlist,selectioncommand=audin)
audioout=Pmw.ComboBox(g1.interior(),labelpos=W,label_text='Audio Out:',
        entry_textvariable=DevoutName,entry_width=30,
        scrolledlist_items=outdevlist,selectioncommand=audout)
cbpwr=Pmw.ComboBox(g1.interior(),labelpos=W,label_text='Power (dBm):',
        entry_textvariable=dBm,entry_width=4,scrolledlist_items=pwrlist)
cbptt=Pmw.ComboBox(g1.interior(),labelpos=W,label_text='PTT method:',
        entry_textvariable=pttmode,entry_width=4,scrolledlist_items=pttlist)
ptt_port=Pmw.ComboBox(g1.interior(),labelpos=W,label_text='PTT port:',
        entry_textvariable=PttPort,entry_width=12,\
        scrolledlist_items=serialportlist)
encat=Checkbutton(g1.interior(),text='Enable CAT',variable=cat_enable)
cat_port=Pmw.ComboBox(g1.interior(),labelpos=W,label_text='CAT port:',
        entry_textvariable=CatPort,entry_width=12,\
        scrolledlist_items=serialportlist)
lrignum=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Rig num:',
        value='214',entry_textvariable=rignum,entry_width=8)
cbbaud=Pmw.ComboBox(g1.interior(),labelpos=W,label_text='Serial rate:',
        entry_textvariable=serial_rate,entry_width=4,scrolledlist_items=baudlist)
cbdata=Pmw.ComboBox(g1.interior(),labelpos=W,label_text='Data bits:',
        entry_textvariable=databits,entry_width=4,scrolledlist_items=datalist)
cbstop=Pmw.ComboBox(g1.interior(),labelpos=W,label_text='Stop bits:',
        entry_textvariable=stopbits,entry_width=4,scrolledlist_items=stoplist)
cbhs=Pmw.ComboBox(g1.interior(),labelpos=W,label_text='Handshake:',
        entry_textvariable=serial_handshake,entry_width=4,scrolledlist_items=hslist)
widgets = (lcall,lgrid,cwid,rxbfo,audioin,audioout,cbpwr,cbptt,ptt_port,\
           encat,cat_port,lrignum,cbbaud,cbdata,cbstop,cbhs)
for widget in widgets:
    widget.pack(fill=X,expand=1,padx=10,pady=2)
Pmw.alignlabels(widgets)
f1=Frame(g1.interior(),width=100,height=10)
f1.pack()
g1.pack(side=LEFT,fill=BOTH,expand=1,padx=6,pady=6)
