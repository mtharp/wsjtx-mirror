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

##Pmw.initialise(fontScheme='pmw2')

def options2(t):
    root.geometry(t)
    root.deiconify()
    root.focus_set()

#-------------------------------------------------------- Create GUI widgets
nb=Pmw.NoteBook(root)
nb.pack(padx=5,pady=5,fill=BOTH,expand=1)

p1=nb.add("Station parameters")
p2=nb.add("Message templates")
p3=nb.add("EME Echo Mode")

MyCall=StringVar()
MyGrid=StringVar()
#RxDelay=StringVar()
#TxDelay=StringVar()
IDinterval=IntVar()
itype=IntVar()
ComPort=IntVar()
PttPort=StringVar()
g.ndefault=1
inbad=IntVar()
outbad=IntVar()
ndevin=IntVar()
ndevout=IntVar()
ntc=IntVar()
necho=IntVar()
fRIT=IntVar()
dither=IntVar()
dlatency=DoubleVar()
DevinName=StringVar()
DevoutName=StringVar()
samfacin=DoubleVar()
samfacout=DoubleVar()
Template1=StringVar()
Template2=StringVar()
Template3=StringVar()
Template4=StringVar()
Template5=StringVar()
Template6=StringVar()
auxra=StringVar()
auxdec=StringVar()
azeldir=StringVar()

if g.Win32:
    serialportlist=("None","COM1","COM2","COM3","COM4","COM5","COM6", \
        "COM7","COM8","COM9","COM10","COM11","COM12","COM13","COM14","COM15")
else:
    serialportlist=("None","/dev/ttyS0","/dev/ttyS1","/dev/ttyUSB0", \
        "/dev/ttyUSB1","/dev/ttyUSB2","/dev/ttyUSB3","/dev/ttyUSB4", \
        "/dev/ttyUSB5","/dev/ttyUSB6","/dev/ttyUSB7","/dev/ttyUSB8")
                    
indevlist=[]
outdevlist=[]

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

PttPort.set('None')


#---------------------------------------------------------- save()
def save():
    pass

#---------------------------------------------------------- restore()
def restore():
    pass

#---------------------------------------------------------- defaults()
def defaults():
    if g.ndefault==1: def1()
    if g.ndefault==2: def2()
    if g.ndefault==3: def3()
    if g.ndefault==4: def4()

#---------------------------------------------------------- def1()
def def1():
    g.ndefault=1
    tx1.delete(0,END)
    tx2.delete(0,END)
    tx3.delete(0,END)
    tx4.delete(0,END)
    tx5.delete(0,END)
    tx6.delete(0,END)
    tx1.insert(0,'%T %M %G')
    if g.mode[:4]=='JTMS':
        tx2.insert(0,'%T %M 26')
        tx3.insert(0,'R26')
    else:
        tx2.insert(0,'%T %M %G OOO')
        tx3.insert(0,'RO')
    tx4.insert(0,'RRR')
    tx5.insert(0,'73')
    tx6.insert(0,'CQ %M %G')

#---------------------------------------------------------- def2
def def2():
    g.ndefault=2
    tx1.delete(0,END)
    tx2.delete(0,END)
    tx3.delete(0,END)
    tx4.delete(0,END)
    tx5.delete(0,END)
    tx6.delete(0,END)

    tx1.insert(0,'%T %M %G')
    if g.mode[:4]=='JTMS':
        tx2.insert(0,'%T %M 26')
        tx3.insert(0,'%T %M R26')
    else:
        tx2.insert(0,'%T %M %R')
        tx3.insert(0,'%T %M R%R')
    tx4.insert(0,'RRR')
    tx5.insert(0,'TNX 73 GL')
    tx6.insert(0,'CQ %M %G')

#---------------------------------------------------------- def3
def def3():
    g.ndefault=3
    tx1.delete(0,END)
    tx2.delete(0,END)
    tx3.delete(0,END)
    tx4.delete(0,END)
    tx5.delete(0,END)
    tx6.delete(0,END)

    tx1.insert(0,'<%T> %M')
    if g.mode[:4]=='JT64' or g.mode[:5]=='ISCAT':
        tx2.insert(0,'%T <%M> OOO')
        tx3.insert(0,'%T <%M> RO')
    else:
        tx2.insert(0,'%T <%M> 26')
        tx3.insert(0,'%T <%M> R26')
    tx4.insert(0,'RRR')
    tx5.insert(0,'73')
    tx6.insert(0,'CQ %M %G')

#---------------------------------------------------------- def4
def def4():
    g.ndefault=4
    tx1.delete(0,END)
    tx2.delete(0,END)
    tx3.delete(0,END)
    tx4.delete(0,END)
    tx5.delete(0,END)
    tx6.delete(0,END)

    tx1.insert(0,'DE %M')
    if g.mode[:4]=='JT64' or g.mode[:5]=='ISCAT':
        tx2.insert(0,'%T OOO')
        tx3.insert(0,'%T RO')
    else:    
        tx2.insert(0,'%T 26')
        tx3.insert(0,'%T R26')
    tx4.insert(0,'RRR')
    tx5.insert(0,'73')
    tx6.insert(0,'CQ %M')

mycall=Pmw.EntryField(p1,labelpos=W,label_text='My Call:',
        value='K1JT',entry_textvariable=MyCall,entry_width=12)
mygrid=Pmw.EntryField(p1,labelpos=W,label_text='Grid Locator:',
        value='FN20qi',entry_textvariable=MyGrid,entry_width=12)
##rxdelay=Pmw.EntryField(p1,labelpos=W,label_text='Rx Delay (s):',
##        value='0.2',entry_textvariable=RxDelay)
##txdelay=Pmw.EntryField(p1,labelpos=W,label_text='Tx Delay (s):',
##        value='0.2',entry_textvariable=TxDelay)
idinterval=Pmw.EntryField(p1,labelpos=W,label_text='ID Interval (m):',
        value=10,entry_textvariable=IDinterval,entry_width=12)

##comport=Pmw.EntryField(p1,labelpos=W,label_text='PTT Port:',
##        value='/dev/ttyS0',entry_textvariable=PttPort,entry_width=12)
##audioin=Pmw.EntryField(p1,labelpos=W,label_text='Audio In:',
##        value='0',entry_textvariable=DevinName,entry_width=12)
##audioout=Pmw.EntryField(p1,labelpos=W,label_text='Audio Out:',
##        value='0',entry_textvariable=DevoutName,entry_width=12)

audioin=Pmw.ComboBox(p1,labelpos=W,label_text='Audio In:',
        entry_textvariable=DevinName,entry_width=30,
        scrolledlist_items=indevlist,selectioncommand=audin)
audioout=Pmw.ComboBox(p1,labelpos=W,label_text='Audio Out:',
        entry_textvariable=DevoutName,entry_width=30,
        scrolledlist_items=outdevlist,selectioncommand=audout)
##cbptt=Pmw.ComboBox(p1,labelpos=W,label_text='PTT method:',
##        entry_textvariable=pttmode,entry_width=4,scrolledlist_items=pttlist)
comport=Pmw.ComboBox(p1,labelpos=W,label_text='PTT port:',
        entry_textvariable=PttPort,entry_width=12,\
        scrolledlist_items=serialportlist)

azeldir_entry=Pmw.EntryField(p1,labelpos=W,label_text='AzElDir:',
    entry_width=9,value=g.appdir,entry_textvariable=azeldir)

widgets = (mycall, mygrid,idinterval,comport,audioin,audioout,azeldir_entry)
for widget in widgets:
    widget.pack(fill=X,expand=1,padx=10,pady=2)

Pmw.alignlabels(widgets)
mycall.component('entry').focus_set()
f1=Frame(p1,width=100,height=20)
mileskm=IntVar()
Label(f1,text='Distance unit:').pack(side=LEFT)
rb5=Radiobutton(f1,text='mi',value=0,variable=mileskm)
rb6=Radiobutton(f1,text='km',value=1,variable=mileskm)
rb5.pack(anchor=W,side=LEFT,padx=2,pady=2)
rb6.pack(anchor=W,side=LEFT,padx=2,pady=2)
f1.pack()

t='Set ' + g.mode + ' QSO format'
g2=Pmw.Group(p2,tag_text=t)
g2.pack(side=LEFT,fill=BOTH,expand=1,padx=6,pady=6)
##Button(g2.interior(),text="Save",command=save,width=7).pack(side=TOP, \
##            padx=2,pady=2)
##Button(g2.interior(),text="Restore",command=restore,width=7).pack(side=TOP, \
##            padx=2,pady=2)
##g3=Pmw.Group(g2.interior(),tag_text="Set defaults")
##g3.pack(side=LEFT,fill=BOTH,expand=1,padx=6,pady=6)

b1=Button(g2.interior(),text="Standard",command=def1,width=12)
b2=Button(g2.interior(),text="Num Rpts",command=def2,width=12)
b3=Button(g2.interior(),text="Hashed Calls",command=def3,width=12)
b4=Button(g2.interior(),text="Shortest",command=def4,width=12)

b1.pack(side=TOP,padx=2,pady=1,expand=YES)
b2.pack(side=TOP,padx=2,pady=1,expand=YES)
b3.pack(side=TOP,padx=2,pady=1,expand=YES)
b4.pack(side=TOP,padx=2,pady=1,expand=YES)

tx1=Pmw.EntryField(p2,labelpos=W,label_text='Tx 1:',
                   entry_textvariable=Template1)
tx2=Pmw.EntryField(p2,labelpos=W,label_text='Tx 2:',
                   entry_textvariable=Template2)
tx3=Pmw.EntryField(p2,labelpos=W,label_text='Tx 3:',
                   entry_textvariable=Template3)
tx4=Pmw.EntryField(p2,labelpos=W,label_text='Tx 4:',
                   entry_textvariable=Template4)
tx5=Pmw.EntryField(p2,labelpos=W,label_text='Tx 5:',
                   entry_textvariable=Template5)
tx6=Pmw.EntryField(p2,labelpos=W,label_text='Tx 6:',
                   entry_textvariable=Template6)

messages=(tx1,tx2,tx3,tx4,tx5,tx6)
for m in messages:
    m.pack(fill=X,expand=1,padx=10,pady=2)

echo_ntc=Pmw.EntryField(p3,labelpos=W,label_text='Averaging time (m):',
        value='1',entry_textvariable=ntc,entry_width=6)
echo_necho=Pmw.EntryField(p3,labelpos=W,label_text='Echo waveform (0 or 1):',
        value='0',entry_textvariable=necho,entry_width=6)
echo_fRIT=Pmw.EntryField(p3,labelpos=W,label_text='RIT setting (Hz):',
        value='0',entry_textvariable=fRIT,entry_width=6)
echo_dither=Pmw.EntryField(p3,labelpos=W,label_text='Dither range (Hz):',
        value='300',entry_textvariable=dither,entry_width=6)
echo_dlatency=Pmw.EntryField(p3,labelpos=W,label_text='Latency correction (s):',
        value='0.0',entry_textvariable=dlatency,entry_width=6)

widgets = (echo_ntc,echo_necho,echo_fRIT,echo_dither,echo_dlatency)
for widget in widgets:
    widget.pack(fill=X,expand=1,padx=10,pady=2)
Pmw.alignlabels(widgets)

nb.selectpage(0)
def4()
