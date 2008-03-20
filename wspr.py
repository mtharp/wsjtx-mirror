#------------------------------------------------------------------------ WSPR
# $Date: 2008-03-17 08:29:04 -0400 (Mon, 17 Mar 2008) $ $Revision: 638 $
#
from Tkinter import *
from tkFileDialog import *
import g,Pmw
from tkMessageBox import showwarning
import os,time,sys
import pyaudio
from math import log10
from numpy.oldnumeric import zeros
import dircache
import Image,ImageTk  #, ImageDraw
from palettes import colormapblue, colormapgray0, colormapHot, \
     colormapAFMHot, colormapgray1, colormapLinrad, Colormap2Palette
from types import *
import array
import thread
import random
import math

root = Tk()
Version="0.4 r" + "$Rev: 638 $"[6:-1]
#Version="0.4"
print "******************************************************************"
print "WSPR Version " + Version + ", by K1JT"
print "Revision date: " + \
      "$Date: 2008-03-17 08:29:04 -0400 (Mon, 17 Mar 2008) $"[7:-1]
print "Run date:   " + time.asctime(time.gmtime()) + " UTC"

#See if we are running in Windows
g.Win32=0
if sys.platform=="win32":
    g.Win32=1
    try:
        root.option_readfile('wsprrc.win')
    except:
        pass
else:
    try:
        root.option_readfile('wsprrc')
    except:
        pass
root_geom=""


#------------------------------------------------------ Global variables
appdir=os.getcwd()
balloon=Pmw.Balloon(root)
bandmap=[]
bandmap2=[]
font1='Helvetica'
g.appdir=appdir
idsec=0
isec0=0
isync=1
cmap0="Linrad"
dBm=IntVar()
mrudir=os.getcwd()
ndbm0=-999
nsave=IntVar()
nsec0=0
nspeed0=IntVar()
NX=500
NY=160
im=Image.new('P',(NX,NY))
im.putpalette(Colormap2Palette(colormapLinrad),"RGB")
pim=ImageTk.PhotoImage(im)
receiving=0
slabel="MinSync  "
transmitting=0

g.ndevin=IntVar()
g.ndevout=IntVar()
g.DevinName=StringVar()
g.DevoutName=StringVar()

#------------------------------------------------------ quit
def quit():
    root.destroy()

#------------------------------------------------------ dbm_balloon
def dbm_balloon():
    mW=int(round(math.pow(10.0,0.1*dBm.get())))
    if(mW<1000):
        t="%.1f mW" % (mW,)
    else:
        t="%.1f W" % (0.001*mW,)
    balloon.bind(ldBm,t)

#------------------------------------------------------ all_hdr
def all_hdr():
    lines="\n " + time.asctime(time.gmtime()) + " UTC\n" + \
        " UTC Sync dB    DT     Freq    Message          \n" + \
        "------------------------------------------------\n"
    try:
        f=open(appdir+'/ALL_MEPT.TXT',mode='a')
        f.writelines(lines)
        f.close()
    except:
        print 'Write to ALL_MEPT.TXT failed.'
        pass

#------------------------------------------------------ openfile
def openfile(event=NONE):
    global mrudir,fileopened,nopen
    nopen=1                         #Work-around for "click feedthrough" bug
    try:
        os.chdir(mrudir)
    except:
        pass
    fname=askopenfilename(filetypes=[("Wave files","*.wav *.WAV")])
    if fname:
        mrudir=os.path.dirname(fname)
        fileopened=os.path.basename(fname)
    os.chdir(appdir)

#------------------------------------------------------ options1
def options1(event=NONE):
    options.options2(root_geom[root_geom.index("+"):])

#------------------------------------------------------ stub
def stub(event=NONE):
    MsgBox("Sorry, this function is not yet implemented.")

#------------------------------------------------------ MsgBox
def MsgBox(t):
    msg=Pmw.MessageDialog(root,buttons=('OK',),message_text=t)
    result=msg.activate()
    msg.focus_set()

#------------------------------------------------------ msgpos
def msgpos():
    g=root_geom[root_geom.index("+"):]
    t=g[1:]
    x=int(t[:t.index("+")])          # + 70
    y=int(t[t.index("+")+1:])        # + 70
    return "+%d+%d" % (x,y)    

#------------------------------------------------------ about
def about(event=NONE):
    global Version
    about=Toplevel(root)
    about.geometry(msgpos())
    if g.Win32: about.iconbitmap("wsjt.ico")
    t="WSPR Version " + Version + ", by K1JT"
    Label(about,text=t,font=(font1,16)).pack(padx=20,pady=5)
    t="""
WSPR is pronounced "whisper" and stands for "Weak Signal
Propagation Reporter".  The program transmits and receives
the digital soundcard mode "MEPT_JT", which stands for
"Manned Experimental Propagation Tests, by K1JT".

Copyright (c) 2008 by Joseph H. Taylor, Jr., K1JT.
"""
    Label(about,text=t,justify=LEFT).pack(padx=20)
    t="Revision date: " + \
      "$Date: 2008-03-17 08:29:04 -0400 (Mon, 17 Mar 2008) $"[7:-1]
    Label(about,text=t,justify=LEFT).pack(padx=20)
    about.focus_set()

#------------------------------------------------------ incsync
def incsync(event):
    global isync
    if isync<10:
        isync=isync+1
        lsync.configure(text=slabel+str(isync))

#------------------------------------------------------ decsync
def decsync(event):
    global isync
    if isync>-30:
        isync=isync-1
        lsync.configure(text=slabel+str(isync))

#------------------------------------------------------ incdsec
def incdsec(event):
    global idsec
    idsec=idsec+5
    bg='red'
    if idsec==0: bg='white'
    ldsec.configure(text='Dsec  '+str(0.1*idsec),bg=bg)

#------------------------------------------------------ decdsec
def decdsec(event):
    global idsec
    idsec=idsec-5
    bg='red'
    if idsec==0: bg='white'
    ldsec.configure(text='Dsec  '+str(0.1*idsec),bg=bg)

#------------------------------------------------------ erase
def erase(event=NONE):
    text.configure(state=NORMAL)
    text.delete('1.0',END)
    text.configure(state=DISABLED)
    text1.configure(state=NORMAL)
    text1.delete('1.0',END)
    text1.configure(state=DISABLED)
#    graph1.delete(ALL)

#-------------------------------------------------------- draw_axis
def draw_axis():
    xmid=10.1386 + 0.001500
    c.delete(ALL)
    df=12000.0/8192.0
# Draw tick marks
    for iy in range(-120,120,10):
        j=80 - iy/df
        i1=7
        if (iy%50)==0:
            i1=12
            c.create_text(27,j,text=str(iy))
        if (iy%100)==0:
            i1=15
            c.create_text(27,j,text=str(iy))
        c.create_line(0,j,i1,j,fill='black')

#------------------------------------------------------ delwav
def delwav():
    t="Are you sure you want to delete\nall *.WAV files in the RxWav directory?"
    msg=Pmw.MessageDialog(root,buttons=('Yes','No'),message_text=t)
    msg.geometry(msgpos())
    if g.Win32: msg.iconbitmap("wsjt.ico")
    msg.focus_set()
    result=msg.activate()
    if result == 'Yes':
# Make a list of *.wav files in RxWav
        la=dircache.listdir(appdir+'/RxWav')
        lb=[]
        for i in range(len(la)):
            j=la[i].find(".wav") + la[i].find(".WAV")
            if j>0: lb.append(la[i])
# Now delete them all.
        for i in range(len(lb)):
            fname=appdir+'/RxWav/'+lb[i]
            os.remove(fname)

#------------------------------------------------------ toggleauto
def toggleauto(event=NONE):
    global lauto
    lauto=1-lauto
    if lauto==0: auto.configure(bg='gray85',relief=RAISED)
    if lauto==1:
        auto.configure(bg='green',relief=SOLID)

#------------------------------------------------------ start_rx
def start_rx(f0,nsec):
    global receiving,transmitting,bandmap,bandmap2

    utc=time.gmtime(time.time()+0.1*idsec)
    t="%02d%02d%02d_%02d%02d" % (utc[0]-2000,utc[1],utc[2],utc[3],utc[4])
    savefile=t+".WAV"
    cmd="wspr_rx.exe"
    args=str(f0) + " " + str(nsec) + " " + str(isync) + " " + \
        str(nsave.get()) + " " + options.DevinName.get() + " " + savefile
    receiving=1
    try:
        os.spawnv(os.P_WAIT,cmd,(cmd,) + (args,))
    except:
        print cmd + ' ' + args + ' failed.'
    receiving=0

# Get lines from decoded.txt
    try:
        f=open(appdir+'/decoded.txt',mode='r')
        lines=f.readlines()
        f.close()
    except:
        lines=""
#  Write data to text box and insert freqs and calls into bandmap.
    text.configure(state=NORMAL)
    nseq=0
    for i in range(len(lines)):
        text.insert(END,lines[i][:46]+"\n")
        callsign=lines[i][31:38]
        if callsign[:1] != ' ':
            i1=callsign.find(' ')
            callsign=callsign[:i1]
            nseq=int(lines[i][55:64])
            ndf=int(lines[i][64:68])
            bandmap.append((ndf,callsign,nseq))
    text.configure(state=DISABLED)
    text.see(END)

#  Remove information that's too old from bandmap.
    iz=len(bandmap)
    for i in range(iz-1,0,-1):
        if (nseq - bandmap[i][2]) > 15:           # 15 sequences = 30 minutes
            bandmap=bandmap[i+1:]
            break
    
#  Sort bandmap in reverse frequency order
    bandmap2=bandmap
    bandmap2.sort()
    bandmap2.reverse()
    iz=len(bandmap2)
    call0=""
    text1.configure(state=NORMAL)
    text1.delete('1.0',END)
    for i in range(iz):
#        print i,bandmap2[i][0],bandmap2[i][1],call0
        if i==0:
            t="%4d" % (bandmap2[i][0],) + " " + bandmap2[i][1]
            text1.insert(END,t+"\n")
        else:
            if bandmap2[i][1]!=call0:
                t="%4d" % (bandmap2[i][0],) + " " + bandmap2[i][1]
                text1.insert(END,t+"\n")
        call0=bandmap2[i][1]
    text1.configure(state=DISABLED)
    text1.see(END)

#------------------------------------------------------ start_tx
def start_tx(mycall,mygrid,ndbm,ntxdf,f0):
    global receiving,transmitting
    cmd="wspr_tx.exe"
    args=mycall + " " + mygrid + " " + str(ndbm) + \
          " " + str(options.PttPort.get()) + " " + str(ntxdf) + \
          " " + options.DevoutName.get() + " " + str(f0)
    transmitting=1
    try:
        os.spawnv(os.P_WAIT,cmd,(cmd,) + (args,))
    except:
        print cmd + ' ' + args + ' failed.'
    transmitting=0

#------------------------------------------------------ update
def update():
    global root_geom,isec0,im,pim,cmap0,lauto,ndbm0,nsec0, \
        receiving,transmitting
    tsec=time.time()
    nsec=int(tsec)
    if nsec<nsec0:
        all_hdr()
    nsec0=nsec
    ns120=nsec%120
    if ns120==0 and (not transmitting) and (not receiving):
        x=random.uniform(0.,100.)
        if x<options.pctx.get() and lauto:
            ntxdf=int(round(1.e6*(ftx.get()-f0.get())))-1500
            thread.start_new_thread(start_tx,
                (MyCall.get(),MyGrid.get(),dBm.get(),ntxdf,f0.get()),)
        else:
            thread.start_new_thread(start_rx,
                (f0.get(),nsec))

    utc=time.gmtime(tsec+0.1*idsec)
    isec=utc[5]
    if isec != isec0:                           #Do once per second
        isec0=isec
        t=time.strftime('%Y %b %d\n%H:%M:%S',utc)
        ldate.configure(text=t)
        root_geom=root.geometry()
        utchours=utc[3]+utc[4]/60.0 + utc[5]/3600.0
        try:
            if dBm.get()!=ndbm0:
                ndbm0=dBm.get()
                dbm_balloon()
        except:
            pass

    bgcolor='gray85'
    t=''
    if transmitting:
        t='Txing: '+MyCall.get().strip() + ' ' + MyGrid.get().strip() + \
           ' ' + str(dBm.get())
        bgcolor='yellow'
    if receiving:
        bgcolor='green'
        t='Receiving'
    msg6.configure(text=t,bg=bgcolor)
    
    ldate.after(100,update)
    
#------------------------------------------------------ Top level frame
frame = Frame(root)

#------------------------------------------------------ Menu Bar
mbar = Frame(frame)
mbar.pack(fill = X)

#------------------------------------------------------ File Menu
filebutton = Menubutton(mbar, text = 'File')
filebutton.pack(side = LEFT)
filemenu = Menu(filebutton, tearoff=0)
filebutton['menu'] = filemenu
filemenu.add('command', label = 'Open', command = openfile, \
             accelerator='Ctrl+O')
filemenu.add_separator()
filemenu.add('command', label = 'Delete all *.WAV files in RxWav', \
             command = delwav)
filemenu.add_separator()
filemenu.add('command', label = 'Erase ALL.TXT', command = stub)
filemenu.add_separator()
filemenu.add('command', label = 'Exit', command = quit)

#------------------------------------------------------ Setup menu
setupbutton = Menubutton(mbar, text = 'Setup')
setupbutton.pack(side = LEFT)
setupmenu = Menu(setupbutton, tearoff=0)
setupbutton['menu'] = setupmenu
setupmenu.add('command', label = 'Options', command = options1)

#------------------------------------------------------ Save menu
savebutton = Menubutton(mbar, text = 'Save')
savebutton.pack(side = LEFT)
savemenu = Menu(savebutton, tearoff=1)
savebutton['menu'] = savemenu
savemenu.add_radiobutton(label = 'None', variable=nsave,value=0)
savemenu.add_radiobutton(label = 'Save decoded', variable=nsave,value=1)
savemenu.add_radiobutton(label = 'Save all', variable=nsave,value=2)
nsave.set(0)

#------------------------------------------------------  Help menu
helpbutton = Menubutton(mbar, text = 'Help')
helpbutton.pack(side = LEFT)
helpmenu = Menu(helpbutton, tearoff=0)
helpbutton['menu'] = helpmenu
helpmenu.add('command', label = 'About WSPR', command = about)

#------------------------------------------------- Speed selection buttons
for i in (5, 4, 3, 2, 1):
    t=str(i)
    Radiobutton(mbar,text=t,value=i,variable=nspeed0).pack(side=RIGHT)
nspeed0.set(2)
lab1=Label(mbar,text='Speed: ',bd=0)
lab1.pack(side=RIGHT)

#------------------------------------------------------ Graphics area
iframe1 = Frame(frame, bd=1, relief=SUNKEN)
graph1=Canvas(iframe1, bg='black', width=NX, height=NY,cursor='crosshair')
graph1.pack(side=LEFT)
c=Canvas(iframe1, bg='white', width=40, height=NY,bd=0)
c.pack(side=LEFT)

#-------------------------------------------------------- Band map
text1=Text(iframe1, height=10, width=12)
text1.pack(side=LEFT, padx=1)
text1.insert(END,'132 ZL1BPU')
sb = Scrollbar(iframe1, orient=VERTICAL, command=text1.yview)
sb.pack(side=RIGHT, fill=Y)
text1.configure(yscrollcommand=sb.set)
iframe1.pack(expand=1, fill=X, padx=4)

#------------------------------------------------------ Labels under graphics
iframe2a = Frame(frame, bd=1, relief=FLAT, height=10)
g1=Pmw.Group(iframe2a,tag_text="Frequency setup")
f0=DoubleVar()
ftx=DoubleVar()
lf0=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Carrier freq:',
        value=10.1386,entry_textvariable=f0,entry_width=12)
lftx=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Tx freq:',
        value=10.140150,entry_textvariable=ftx,entry_width=12)
widgets = (lf0, lftx)
for widget in widgets:
    widget.pack(side=LEFT,padx=5,pady=2)
f1=Frame(g1.interior())
f1.pack()
g1.pack(side=LEFT,fill=BOTH,expand=1,padx=6,pady=6)

#------------------------------------------------------ Tx params and msgs
g2=Pmw.Group(iframe2a,tag_text="Tx message")
MyCall=StringVar()
MyGrid=StringVar()
lcall=Pmw.EntryField(g2.interior(),labelpos=W,label_text='Call:',
        value='K1JT',entry_textvariable=MyCall,entry_width=8)
lgrid=Pmw.EntryField(g2.interior(),labelpos=W,label_text='Grid:',
        value='FN20',entry_textvariable=MyGrid,entry_width=5)
ldBm=Pmw.EntryField(g2.interior(),labelpos=W,label_text='Power (dBm):',
        value=30,entry_textvariable=dBm,entry_width=4)
widgets = (lcall, lgrid, ldBm)
for widget in widgets:
    widget.pack(side=LEFT,padx=5,pady=2)
f2=Frame(g1.interior())
f2.pack()
g2.pack(side=LEFT,fill=BOTH,expand=1,padx=6,pady=6)

iframe2a.pack(expand=1, fill=X, padx=1)
iframe2 = Frame(frame, bd=1, relief=FLAT,height=15)
lab2=Label(iframe2, text='UTC      Sync   dB        DT           Freq')
lab2.place(x=170,y=6, anchor='w')
iframe2.pack(expand=1, fill=X, padx=4)

#-------------------------------------------------------- Buttons, UTC, etc
iframe4 = Frame(frame, bd=1, relief=SUNKEN)
f4a=Frame(iframe4,height=170,bd=2,relief=FLAT)

berase=Button(f4a, text='Erase',underline=0,command=erase,padx=1,pady=1)
berase.pack(side=TOP,expand=1,fill=BOTH)
auto=Button(f4a,text='Enable Tx',underline=0,command=toggleauto,
            padx=1,pady=1)
auto.pack(side=TOP,expand=1,fill=BOTH)

lsync=Label(f4a, bg='white', fg='black', text='Sync   1', width=8, relief=RIDGE)
lsync.pack(side=TOP,ipadx=3,padx=2,pady=5)
Widget.bind(lsync,'<Button-1>',incsync)
Widget.bind(lsync,'<Button-3>',decsync)

ldsec=Label(f4a, bg='white', fg='black', text='Dsec  0.0', width=8, relief=RIDGE)
ldsec.pack(side=TOP,ipadx=3,padx=2,pady=5)
Widget.bind(ldsec,'<Button-1>',incdsec)
Widget.bind(ldsec,'<Button-3>',decdsec)

ldate=Label(f4a, bg='black', fg='yellow', width=11, bd=4,
        text='2005 Apr 22\n01:23:45', relief=RIDGE,
        justify=CENTER, font=(font1,16))
ldate.pack(side=TOP,padx=2,pady=2)
f4a.pack(side=LEFT,expand=0,fill=Y)

f4b=Frame(iframe4,height=170,bd=2,relief=FLAT)
text=Text(f4b, height=11, width=68)
text.pack(side=RIGHT, fill=X, padx=1)
text.insert(END,'1054   4 -25   1.1  10.140140  K1JT FN20 25')
sb = Scrollbar(f4b, orient=VERTICAL, command=text.yview)
sb.pack(side=RIGHT, fill=Y)
text.configure(yscrollcommand=sb.set)
f4b.pack(side=LEFT,expand=0,fill=Y)
iframe4.pack(expand=1, fill=X, padx=4)

#------------------------------------------------------------ Status Bar
iframe6 = Frame(frame, bd=1, relief=SUNKEN)
msg1=Message(iframe6, text='      ', width=300,relief=SUNKEN)
msg1.pack(side=LEFT, fill=X, padx=1)
msg2=Message(iframe6, text='      ', width=300,relief=SUNKEN)
msg2.pack(side=LEFT, fill=X, padx=1)
msg3=Message(iframe6, text='      ',width=300,relief=SUNKEN)
msg3.pack(side=LEFT, fill=X, padx=1)
msg4=Message(iframe6, text='      ', width=300,relief=SUNKEN)
msg4.pack(side=LEFT, fill=X, padx=1)
msg5=Message(iframe6, text='      ', width=300,relief=SUNKEN)
msg5.pack(side=LEFT, fill=X, padx=1)
msg6=Message(iframe6, text='      ', width=400,relief=SUNKEN)
msg6.pack(side=RIGHT, fill=X, padx=1)
iframe6.pack(expand=1, fill=X, padx=4)
frame.pack()

ldate.after(100,update)

lauto=0
isync=1
import options

#---------------------------------------------------------- Process INI file
try:
    f=open(appdir+'/WSPR.INI',mode='r')
    params=f.readlines()
except:
    params=""
    if g.Win32:
        options.PttPort.set("0")
        pass
    else:
        options.PttPort.set("/dev/ttyS0")
        pass

try:
    for i in range(len(params)):
        key,value=params[i].split()
        if   key == 'WSPRGeometry': root.geometry(value)
        elif key == 'MyCall': MyCall.set(value)
        elif key == 'MyGrid': MyGrid.set(value)
        elif key == 'dBm': dBm.set(value)
        elif key == 'PctTx': options.pctx.set(value)
#        elif key == 'IDinterval': options.IDinterval.set(value)
        elif key == 'PttPort':
            try:
                options.PttPort.set(value)
            except:
                if g.Win32:
                    options.PttPort.set("0")
                else:
                    options.PttPort.set("/dev/ttyS0")
                pass
            pass
        elif key == 'AudioIn':
            try:
                g.ndevin.set(value)
            except:
                g.ndevin.set(0)
            g.DevinName.set(value)
            options.DevinName.set(value)
        elif key == 'AudioOut':
            try:
                g.ndevout.set(value)
            except:
                g.ndevout.set(0)
            g.DevoutName.set(value)
            options.DevoutName.set(value)
        elif key == 'Nsave': nsave.set(value)
        elif key == 'Sync': isync=int(value)
        elif key == 'Debug': ndebug.set(value)
        elif key == 'MRUDir': mrudir=value.replace("#"," ")
except:
    print 'Error reading WSPR.INI, continuing with defaults.'
    print key,value

lsync.configure(text=slabel+str(isync))
dbm_balloon()
draw_axis()
erase()
if g.Win32: root.iconbitmap("wsjt.ico")
root.title('  WSPR      by K1JT')
all_hdr()
graph1.focus_set()
root.mainloop()

# Clean up and save user options before terminating
f=open(appdir+'/WSPR.INI',mode='w')
root_geom=root_geom[root_geom.index("+"):]
f.write("WSPRGeometry " + root_geom + "\n")
f.write("MyCall " + MyCall.get() + "\n")
f.write("MyGrid " + MyGrid.get() + "\n")
f.write("dBm " + str(dBm.get()) + "\n")
#f.write("IDinterval " + str(options.IDinterval.get()) + "\n")
f.write("PttPort " + str(options.PttPort.get()) + "\n")
f.write("AudioIn " + options.DevinName.get() + "\n")
f.write("AudioOut " + options.DevoutName.get() + "\n")
f.write("Nsave " + str(nsave.get()) + "\n")
f.write("PctTx " + str(options.pctx.get()) + "\n")
f.write("Sync " + str(isync) + "\n")
mrudir2=mrudir.replace(" ","#")
f.write("MRUDir " + mrudir2 + "\n")
f.close()

#Terminate audio streams
f=open("abort",mode='w')
#time.sleep(0.5)
#f.close()
