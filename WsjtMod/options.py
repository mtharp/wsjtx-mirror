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
MyCall=StringVar()
MyGrid=StringVar()
#RxDelay=StringVar()
#TxDelay=StringVar()
IDinterval=IntVar()
ComPort=IntVar()
PttPort=StringVar()
ndevin=IntVar()
ndevout=IntVar()
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

def defaults():
    if itype.get()==0:
        tx1.delete(0,END)
        tx1.insert(0,'DE %M')
        tx2.delete(0,END)
        tx2.insert(0,'%T OOO')
        tx3.delete(0,END)
        tx3.insert(0,'%T RO')
        tx4.delete(0,END)
        tx4.insert(0,'RRR')
        tx5.delete(0,END)
        tx5.insert(0,'73')
        tx6.delete(0,END)
        tx6.insert(0,'CQ %M')
    elif itype.get()==1:
        tx1.delete(0,END)
        tx1.insert(0,'<%T> %M')
        tx2.delete(0,END)
        tx2.insert(0,'%T <%M> OOO')
        tx3.delete(0,END)
        tx3.insert(0,'%T <%M> RO')
        tx4.delete(0,END)
        tx4.insert(0,'<%T> %M RRR')
        tx5.delete(0,END)
        tx5.insert(0,'73')
        tx6.delete(0,END)
        tx6.insert(0,'CQ %M %G')
    elif itype.get()==2:
        tx1.delete(0,END)
        tx1.insert(0,'%T %M %G')
        tx2.delete(0,END)
        tx2.insert(0,'%T %M %G OOO')
        tx3.delete(0,END)
        tx3.insert(0,'RO')
        tx4.delete(0,END)
        tx4.insert(0,'RRR')
        tx5.delete(0,END)
        tx5.insert(0,'73')
        tx6.delete(0,END)
        tx6.insert(0,'CQ %M %G')

mycall=Pmw.EntryField(g1.interior(),labelpos=W,label_text='My Call:',
        value='K1JT',entry_textvariable=MyCall,entry_width=12)
mygrid=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Grid Locator:',
        value='FN20qi',entry_textvariable=MyGrid,entry_width=12)
##rxdelay=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Rx Delay (s):',
##        value='0.2',entry_textvariable=RxDelay)
##txdelay=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Tx Delay (s):',
##        value='0.2',entry_textvariable=TxDelay)
idinterval=Pmw.EntryField(g1.interior(),labelpos=W,label_text='ID Interval (m):',
        value=10,entry_textvariable=IDinterval,entry_width=12)
comport=Pmw.EntryField(g1.interior(),labelpos=W,label_text='PTT Port:',
        value='/dev/ttyS0',entry_textvariable=PttPort,entry_width=12)
audioin=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Audio In:',
        value='0',entry_textvariable=DevinName,entry_width=12)
audioout=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Audio Out:',
        value='0',entry_textvariable=DevoutName,entry_width=12)
azeldir_entry=Pmw.EntryField(g1.interior(),labelpos=W,label_text='AzElDir:',
    entry_width=9,value=g.appdir,entry_textvariable=azeldir)

widgets = (mycall, mygrid,idinterval,comport,audioin,audioout,azeldir_entry)
for widget in widgets:
    widget.pack(fill=X,expand=1,padx=10,pady=2)

Pmw.alignlabels(widgets)
mycall.component('entry').focus_set()
f1=Frame(g1.interior(),width=100,height=20)
mileskm=IntVar()
Label(f1,text='Distance unit:').pack(side=LEFT)
rb5=Radiobutton(f1,text='mi',value=0,variable=mileskm)
rb6=Radiobutton(f1,text='km',value=1,variable=mileskm)
rb5.pack(anchor=W,side=LEFT,padx=2,pady=2)
rb6.pack(anchor=W,side=LEFT,padx=2,pady=2)
f1.pack()

g2=Pmw.Group(root,tag_text="Message templates")
f2=Frame(g2.interior(),width=100,height=20)
f2a=Frame(f2,width=50,height=20,bd=2,relief=GROOVE)
f2a.pack(side=LEFT,padx=6,pady=6)

itype=IntVar()
rb1=Radiobutton(f2a,text='Sm',value=0,variable=itype,command=defaults)
rb2=Radiobutton(f2a,text='Med',value=1,variable=itype,command=defaults)
rb3=Radiobutton(f2a,text='Lg',value=2,variable=itype,command=defaults)
rb1.pack(anchor=W,side=LEFT,padx=2,pady=2)
rb2.pack(anchor=W,side=LEFT,padx=2,pady=2)
rb3.pack(anchor=W,side=LEFT,padx=2,pady=2)

f2.pack()

#Button(g2.interior(),text="Reset defaults",command=defaults).pack(padx=6,pady=6)

tx1=Pmw.EntryField(g2.interior(),labelpos=W,label_text='Tx 1:',
                   entry_textvariable=Template1)
tx2=Pmw.EntryField(g2.interior(),labelpos=W,label_text='Tx 2:',
                   entry_textvariable=Template2)
tx3=Pmw.EntryField(g2.interior(),labelpos=W,label_text='Tx 3:',
                   entry_textvariable=Template3)
tx4=Pmw.EntryField(g2.interior(),labelpos=W,label_text='Tx 4:',
                   entry_textvariable=Template4)
tx5=Pmw.EntryField(g2.interior(),labelpos=W,label_text='Tx 5:',
                   entry_textvariable=Template5)
tx6=Pmw.EntryField(g2.interior(),labelpos=W,label_text='Tx 6:',
                   entry_textvariable=Template6)

messages=(tx1,tx2,tx3,tx4,tx5,tx6)
for m in messages:
    m.pack(fill=X,expand=1,padx=10,pady=2)

g1.pack(side=LEFT,fill=BOTH,expand=1,padx=6,pady=6)
g2.pack(side=LEFT,fill=BOTH,expand=1,padx=6,pady=6)

