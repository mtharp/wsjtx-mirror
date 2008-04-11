#------------------------------------------------------------------------ WSPR
# $Date: 2008-03-17 08:29:04 -0400 (Mon, 17 Mar 2008) $ $Revision$
#
from Tkinter import *
from tkFileDialog import *
import g,Pmw
from tkMessageBox import showwarning
import os,time,sys
##import pyaudio
from math import log10
try:
    from numpy.oldnumeric import zeros
#    print "importing from numpy"
except: 
    from Numeric import zeros
#    print "importing from Numeric"
import array
import dircache
import Image, ImageTk, ImageDraw
from palettes import colormapblue, colormapgray0, colormapHot, \
     colormapAFMHot, colormapgray1, colormapLinrad, Colormap2Palette
from types import *
import array
import random
import math
import string
import w

root = Tk()
Version="0.6 r" + "$Rev$"[6:-1]
##print "Ignore any error message above, it is harmless."
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
import options


#------------------------------------------------------ Global variables
appdir=os.getcwd()
bandmap=[]
bandmap2=[]
fmid=0.0
fmid0=0.0
font1='Helvetica'
idsec=0
ipctx=IntVar()
isec0=0
isync=1
loopall=0
modpixmap0=0
modtxrx0=0
mrudir=os.getcwd()
ndbm0=-999
newdat=1
newspec=1
npal=IntVar()
npal.set(2)
nsave=IntVar()
nscroll=0
nsec0=0
nspeed0=IntVar()
NX=500
NY=160
param20=""
pctx=[-1,0,20,25,33,100]

a=array.array('h')
im=Image.new('P',(NX,NY))
draw=ImageDraw.Draw(im)
im.putpalette(Colormap2Palette(colormapLinrad),"RGB")
pim=ImageTk.PhotoImage(im)
receiving=0
scale0=1.0
offset0=0.0
s0=0.0
c0=0.0
slabel="MinSync  "
transmitting=0
tw=[]

g.appdir=appdir
g.cmap="Linrad"
g.cmap0="Linrad"
g.ndevin=IntVar()
g.ndevout=IntVar()
g.DevinName=StringVar()
g.DevoutName=StringVar()

def pal_gray0():
    g.cmap="gray0"
    im.putpalette(Colormap2Palette(colormapgray0),"RGB")
def pal_gray1():
    g.cmap="gray1"
    im.putpalette(Colormap2Palette(colormapgray1),"RGB")
def pal_linrad():
    g.cmap="Linrad"
    im.putpalette(Colormap2Palette(colormapLinrad),"RGB")
def pal_blue():
    g.cmap="blue"
    im.putpalette(Colormap2Palette(colormapblue),"RGB")
def pal_Hot():
    g.cmap="Hot"
    im.putpalette(Colormap2Palette(colormapHot),"RGB")
def pal_AFMHot():
    g.cmap="AFMHot"
    im.putpalette(Colormap2Palette(colormapAFMHot),"RGB")

#------------------------------------------------------ quit
def quit():
    root.destroy()

#------------------------------------------------------ openfile
def openfile(event=NONE):
    global mrudir,fileopened,nopen,tw
    nopen=1                         #Work-around for "click feedthrough" bug
    try:
        os.chdir(mrudir)
    except:
        pass
    fname=askopenfilename(filetypes=[("Wave files","*.wav *.WAV")])
    if fname:
        w.getfile(fname,len(fname))
##        if w.acom1.ierr: print 'Error ',w.acom1.ierr, \
##           'when trying to read file',fname
        mrudir=os.path.dirname(fname)
        fileopened=os.path.basename(fname)
    os.chdir(appdir)

#------------------------------------------------------ opennext
def opennext(event=NONE):
    global ncall,fileopened,loopall,mrudir,tw
    if fileopened=="" and ncall==0:
        openfile()
        ncall=1
    else:
# Make a list of *.wav files in mrudir
        la=os.listdir(mrudir)
        la.sort()
        lb=[]
        for i in range(len(la)):
            j=la[i].find(".wav") + la[i].find(".WAV")
            if j>0: lb.append(la[i])
        for i in range(len(lb)):
            if lb[i]==fileopened:
                break
        if i<len(lb)-1:
            fname=mrudir+"/"+lb[i+1]
            w.getfile(fname,len(fname))
            mrudir=os.path.dirname(fname)
            fileopened=os.path.basename(fname)
            i1=fileopened.find('.')
            t=fileopened[i1-4:i1]
            t=t[0:2] + ':' + t[2:4]
            n=len(tw)
            if n>12: tw=tw[:n-1]
            tw=[t,] + tw
        else:
            t="No more *.wav files in this directory."
            msg=Pmw.MessageDialog(root,buttons=('OK',),message_text=t)
            msg.geometry(msgpos())
#            if g.Win32: msg.iconbitmap("wsjt.ico")
            msg.focus_set()
            ncall=0
            loopall=0

#------------------------------------------------------ decodeall
def decodeall(event=NONE):
    global loopall
    loopall=1
    opennext()

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

#------------------------------------------------------ 
def help(event=NONE):
    about=Toplevel(root)
    about.geometry(msgpos())
    if g.Win32: about.iconbitmap("wsjt.ico")
    t="Basic Operating Instructions"
    Label(about,text=t,font=(font1,14)).pack(padx=20,pady=5)
    t="""
1. Open the Setup | Options page and enter your callsign,
   grid locator, COM port number (for PTT control), and Tx
   power in dBm.  If you do not wish to use the system's
   default sound card, enter suitable device numbers for
   Audio In and Audio Out.

2. On the main screen, enter your dial frequency (USB) and
    Tx frequency in MHz.  Click on 'Rx' to receive only,
    'Tx' to transmit only, or the desired average percentage
    of transmission cycles.

3. Be sure that your computer clock is correct to +/- 1 s. If
   necessary you can make small adjustments by left- or right-
   clicking on the 'Dsec' label.

4. The program will begin a Tx or Rx sequence at the start of
    each even minute.  The waterfall will update only near the
    end of each Rx sequence.
"""
    Label(about,text=t,justify=LEFT).pack(padx=20)
    about.focus_set()

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
    global fmid
    c.delete(ALL)
    df=12000.0/8192.0
    nfmid=int(1.0e6*fmid)%1000
# Draw and label tick marks
    for iy in range(-120,120,10):
        j=80 - iy/df
        i1=7
        if (iy%50)==0:
            i1=12
            if (iy%100)==0: i1=15
            n=nfmid+iy
            if n<0: n=n+1000
            c.create_text(27,j,text=str(n))
        c.create_line(0,j,i1,j,fill='black')

#------------------------------------------------------ del_all
def del_all():
    fname=appdir+'/ALL_MEPT.TXT'
    os.remove(fname)

#------------------------------------------------------ delwav
def delwav():
    t="Are you sure you want to delete\nall *.WAV files in the Save directory?"
    msg=Pmw.MessageDialog(root,buttons=('Yes','No'),message_text=t)
    msg.geometry(msgpos())
    if g.Win32: msg.iconbitmap("wsjt.ico")
    msg.focus_set()
    result=msg.activate()
    if result == 'Yes':
# Make a list of *.wav files in Save
        la=dircache.listdir(appdir+'/Save')
        lb=[]
        for i in range(len(la)):
            j=la[i].find(".wav") + la[i].find(".WAV")
            if j>0: lb.append(la[i])
# Now delete them all.
        for i in range(len(lb)):
            fname=appdir+'/Save/'+lb[i]
            os.remove(fname)

#--------------------------------------------------- rx_volume
def rx_volume():
    for path in string.split(os.environ["PATH"], os.pathsep):
        file = os.path.join(path, "sndvol32") + ".exe"
        try:
            return os.spawnv(os.P_NOWAIT, file, (file,) + (" -r",))
        except os.error:
            pass
    raise os.error, "Cannot find "+file

#--------------------------------------------------- tx_volume
def tx_volume():
    for path in string.split(os.environ["PATH"], os.pathsep):
        file = os.path.join(path, "sndvol32") + ".exe"
        try:
            return os.spawnv(os.P_NOWAIT, file, (file,))
        except os.error:
            pass
    raise os.error, "Cannot find "+file

#------------------------------------------------------ get_decoded
def get_decoded():
    global bandmap,bandmap2,newdat,loopall
    
# Get lines from decoded.txt
    try:
        f=open(appdir+'/decoded.txt',mode='r')
        lines=f.readlines()
        f.close()
        if lines[0][:4]=="$EOF": lines=""
    except:
        lines=""
    if len(lines)>0:
#  Write data to text box and insert freqs and calls into bandmap.
        text.configure(state=NORMAL)
        nseq=0
        nfmid=int(1.0e6*fmid)%1000
        for i in range(len(lines)):
            text.insert(END,lines[i][:53]+"\n")
            callsign=lines[i][38:45]
            if callsign[:1] != ' ':
                i1=callsign.find(' ')
                callsign=callsign[:i1]
                nseq=int(lines[i][7:11])
                ndf=int(lines[i][33:36])
                bandmap.append((ndf,callsign,nseq))
        text.configure(state=DISABLED)
        text.see(END)
        
#  Remove any "too old" information from bandmap.
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

    if loopall: opennext()

#------------------------------------------------------ put_params
def put_params(param3=NONE):
    global idsec,param20

    w.acom1.f0=f0.get()
    w.acom1.ftx=ftx.get()
    w.acom1.callsign=(options.MyCall.get()+'      ')[:6]
    w.acom1.grid=(options.MyGrid.get()+'    ')[:4]
    try:
        w.acom1.nport=int(options.PttPort.get())
    except:
        w.acom1.nport=0
    w.acom1.ndbm=options.dBm.get()
    w.acom1.pctx=pctx[ipctx.get()]
    w.acom1.idsec=idsec
    w.acom1.nsave=nsave.get()

#------------------------------------------------------ update
def update():
    global root_geom,isec0,im,pim,ndbm0,nsec0,a, \
        receiving,transmitting,newdat,nscroll,newspec,scale0,offset0, \
        modpixmap0,modtxrx0,tw,s0,c0,fmid,fmid0,idsec
    tsec=time.time() + 0.1*idsec
    utc=time.gmtime(tsec)
    nsec=int(tsec)
    nsec0=nsec

    isec=utc[5]
    if isec != isec0:                           #Do once per second
        isec0=isec
        t=time.strftime('%Y %b %d\n%H:%M:%S',utc)
        ldate.configure(text=t)
        root_geom=root.geometry()
        utchours=utc[3]+utc[4]/60.0 + utc[5]/3600.0
        try:
            if options.dBm.get()!=ndbm0:
                ndbm0=options.dBm.get()
                options.dbm_balloon()
        except:
            pass
        put_params()

# If T/R status has changed, get new info
    try:
        modtxrx=os.stat('txrxtime.txt')[8]
        if modtxrx!=modtxrx0:
            f=open('txrxtime.txt',mode='r')
            t=f.read()
            transmitting=0
            receiving=0
            f.close()
            modtxrx0=os.stat('txrxtime.txt')[8]
            if t[:9]=='Receiving':
                receiving=1
                n=len(tw)
                if n>12: tw=tw[:n-1]
                tw=[t[13:18],] + tw
            if t[:12]=='Transmitting':
                transmitting=1
    except:
        pass

    bgcolor='gray85'
    t=''
    if transmitting:
        t='Txing: '+options.MyCall.get().strip().upper() + ' ' + \
           options.MyGrid.get().strip().upper() + ' ' + str(options.dBm.get())
        bgcolor='yellow'
    if receiving:
        bgcolor='green'
        t='Receiving'
    msg6.configure(text=t,bg=bgcolor)

# If new decoded text has appeared, display it.
    if w.acom1.ndecdone:
        get_decoded()
        w.acom1.ndecdone=0

# Display the waterfall
    try:
        modpixmap=os.stat('pixmap.dat')[8]
        if modpixmap!=modpixmap0:
            f=open('pixmap.dat','rb')
            a=array.array('h')
            a.fromfile(f,NX*NY)
            f.close()
            newdat=1
            modpixmap0=modpixmap
    except:
        newdat=0
    scale=math.pow(10.0,0.003*sc1.get())
    offset=0.3*sc2.get()
    if newdat or scale!= scale0 or offset!=offset0 or g.cmap!=g.cmap0:
        im.putdata(a,scale,offset)              #Compute whole new image
        if newdat:
            n=len(tw)
            for i in range(n-1,-1,-1):
                x=465-39*i
                draw.text((x,148),tw[i],fill=253)   #Insert time label
        pim=ImageTk.PhotoImage(im)              #Convert Image to PhotoImage
        graph1.delete(ALL)
        graph1.create_image(0,0+2,anchor='nw',image=pim)
        g.ndecphase=2
        newMinute=0
        scale0=scale
        offset0=offset
        g.cmap0=g.cmap
        newdat=0

    s0=sc1.get()
    c0=sc2.get()
    fmid=f0.get() + 0.001500
    if fmid!=fmid0:
        draw_axis()
    ldate.after(200,update)
    
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
filemenu.add('command', label = 'Open next in directory', command = opennext, \
             accelerator='F6')
filemenu.add('command', label = 'Decode remaining files in directory', \
             command = decodeall, accelerator='Shift+F6')
filemenu.add_separator()
filemenu.add('command', label = 'Delete all *.WAV files in Save', \
             command = delwav)
filemenu.add_separator()
filemenu.add('command', label = 'Erase ALL_MEPT.TXT', command = del_all)
filemenu.add_separator()
filemenu.add('command', label = 'Exit', command = quit)

#------------------------------------------------------ Setup menu
setupbutton = Menubutton(mbar, text = 'Setup')
setupbutton.pack(side = LEFT)
setupmenu = Menu(setupbutton, tearoff=0)
setupbutton['menu'] = setupmenu
setupmenu.add('command', label = 'Options', command = options1)
setupmenu.add_separator()
setupmenu.add('command', label = 'Rx volume control', command = rx_volume)
setupmenu.add('command', label = 'Tx volume control', command = tx_volume)

#--------------------------------------------------------- View menu
setupbutton = Menubutton(mbar, text = 'View', )
setupbutton.pack(side = LEFT)
setupmenu = Menu(setupbutton, tearoff=1)
setupbutton['menu'] = setupmenu
setupmenu.palettes=Menu(setupmenu,tearoff=0)
setupmenu.palettes.add_radiobutton(label='Gray0',command=pal_gray0,
            value=0,variable=npal)
setupmenu.palettes.add_radiobutton(label='Gray1',command=pal_gray1,
            value=1,variable=npal)
setupmenu.palettes.add_radiobutton(label='Linrad',command=pal_linrad,
            value=2,variable=npal)
setupmenu.palettes.add_radiobutton(label='Blue',command=pal_blue,
            value=3,variable=npal)
setupmenu.palettes.add_radiobutton(label='Hot',command=pal_Hot,
            value=4,variable=npal)
setupmenu.palettes.add_radiobutton(label='AFMHot',command=pal_AFMHot,
            value=5,variable=npal)
setupmenu.add_cascade(label = 'Palette',menu=setupmenu.palettes)

#------------------------------------------------------ Save menu
savebutton = Menubutton(mbar, text = 'Save')
savebutton.pack(side = LEFT)
savemenu = Menu(savebutton, tearoff=1)
savebutton['menu'] = savemenu
savemenu.add_radiobutton(label = 'None', variable=nsave,value=0)
#savemenu.add_radiobutton(label = 'Save decoded', variable=nsave,value=1)
savemenu.add_radiobutton(label = 'Save all', variable=nsave,value=2)
nsave.set(0)

#------------------------------------------------------  Help menu
helpbutton = Menubutton(mbar, text = 'Help')
helpbutton.pack(side = LEFT)
helpmenu = Menu(helpbutton, tearoff=1)
helpbutton['menu'] = helpmenu
helpmenu.add('command', label = 'Help', command = help)
helpmenu.add('command', label = 'About WSPR', command = about)

#------------------------------------------------------ Graphics area
iframe1 = Frame(frame, bd=1, relief=SUNKEN)

graph1=Canvas(iframe1, bg='black', width=NX, height=NY,cursor='crosshair')
graph1.pack(side=LEFT)
c=Canvas(iframe1, bg='white', width=40, height=NY,bd=0)
c.pack(side=LEFT)

text1=Text(iframe1, height=10, width=12)
text1.pack(side=LEFT, padx=1)
text1.insert(END,'132 ZL1BPU')
sb = Scrollbar(iframe1, orient=VERTICAL, command=text1.yview)
sb.pack(side=RIGHT, fill=Y)
text1.configure(yscrollcommand=sb.set)
iframe1.pack(expand=1, fill=X, padx=4)

iframe2 = Frame(frame, bd=1, relief=FLAT)
sc1=Scale(iframe2,from_=-100.0,to_=100.0,orient='horizontal',
    showvalue=0,sliderlength=5)
sc1.pack(side=LEFT)
sc2=Scale(iframe2,from_=-100.0,to_=100.0,orient='horizontal',
    showvalue=0,sliderlength=5)
sc2.pack(side=LEFT)
lab00=Label(iframe2, text='Band Map').place(x=623,y=10, anchor='e')
iframe2.pack(expand=1, fill=X, padx=4)

#------------------------------------------------------ Labels under graphics
iframe2a = Frame(frame, bd=1, relief=FLAT)
g1=Pmw.Group(iframe2a,tag_text="Frequencies (MHz)")
f0=DoubleVar()
ftx=DoubleVar()
lf0=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Dial freq:',
        value=10.1387,entry_textvariable=f0,entry_width=12)
lftx=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Tx freq:',
        value=10.140150,entry_textvariable=ftx,entry_width=12)
widgets = (lf0, lftx)
for widget in widgets:
    widget.pack(side=LEFT,padx=5,pady=2)
g1.pack(side=LEFT,fill=BOTH,expand=0,padx=6,pady=6)
lab01=Label(iframe2a, text='').pack(side=LEFT,padx=1)
g2=Pmw.Group(iframe2a,tag_text="T/R cycle")
#------------------------------------------------------ T/R Cycle Select
for i in range(6):
    t="Idle"
    if i==1:
        t="Rx"
    elif i==2:
        t="20%"
    elif i==3:
        t="25%"
    elif i==4:
        t="33%"
    elif i==5:
        t="Tx"
    Radiobutton(g2.interior(),text=t,value=i,
                variable=ipctx).pack(side=LEFT,padx=4)
ipctx.set(0)
g2.pack(side=LEFT,fill=BOTH,expand=0,padx=6,pady=6)
iframe2a.pack(expand=1, fill=X, padx=1)

iframe2 = Frame(frame, bd=1, relief=FLAT,height=15)
lab2=Label(iframe2, text='DATE       UTC    Sync    dB        DT           Freq')
lab2.place(x=160,y=6, anchor='w')
iframe2.pack(expand=1, fill=X, padx=4)

#-------------------------------------------------------- Buttons, UTC, etc
iframe4 = Frame(frame, bd=1, relief=SUNKEN)
f4a=Frame(iframe4,height=170,bd=2,relief=FLAT)

berase=Button(f4a, text='Erase',underline=0,command=erase,padx=1,pady=1)
berase.pack(side=TOP,padx=0,pady=15)

ldate=Label(f4a, bg='black', fg='yellow', width=11, bd=4,
        text='2005 Apr 22\n01:23:45', relief=RIDGE,
        justify=CENTER, font=(font1,16))
ldate.pack(side=TOP,padx=2,pady=5)

ldsec=Label(f4a, bg='white', fg='black', text='Dsec  0.0', width=8, relief=RIDGE)
ldsec.pack(side=TOP,ipadx=3,padx=2,pady=10)
Widget.bind(ldsec,'<Button-1>',incdsec)
Widget.bind(ldsec,'<Button-3>',decdsec)

f4a.pack(side=LEFT,expand=0,fill=Y)

#--------------------------------------------------------- Decoded text box
f4b=Frame(iframe4,height=170,bd=2,relief=FLAT)
text=Text(f4b, height=11, width=68)
sb = Scrollbar(f4b, orient=VERTICAL, command=text.yview)
sb.pack(side=RIGHT, fill=Y)
text.pack(side=RIGHT, fill=X, padx=1)
text.insert(END,'1054   4 -25   1.1  10.140140  K1JT FN20 25')
text.configure(yscrollcommand=sb.set)
f4b.pack(side=LEFT,expand=0,fill=Y)
iframe4.pack(expand=1, fill=X, padx=4)

root.bind_all('<F6>', opennext)
root.bind_all('<Shift-F6>', decodeall)

#------------------------------------------------------------ Status Bar
iframe6 = Frame(frame, bd=1, relief=SUNKEN)
##msg1=Message(iframe6, text='      ', width=300,relief=SUNKEN)
##msg1.pack(side=LEFT, fill=X, padx=1)
##msg2=Message(iframe6, text='      ', width=300,relief=SUNKEN)
##msg2.pack(side=LEFT, fill=X, padx=1)
##msg3=Message(iframe6, text='      ',width=300,relief=SUNKEN)
##msg3.pack(side=LEFT, fill=X, padx=1)
##msg4=Message(iframe6, text='      ', width=300,relief=SUNKEN)
##msg4.pack(side=LEFT, fill=X, padx=1)
##msg5=Message(iframe6, text='      ', width=300,relief=SUNKEN)
##msg5.pack(side=LEFT, fill=X, padx=1)
msg6=Message(iframe6, text='      ', width=400,relief=SUNKEN)
msg6.pack(side=RIGHT, fill=X, padx=1)
iframe6.pack(expand=1, fill=X, padx=4)
frame.pack()

isync=1

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
        elif key == 'MyCall': options.MyCall.set(value)
        elif key == 'MyGrid': options.MyGrid.set(value)
        elif key == 'dBm': options.dBm.set(value)
        elif key == 'PctTx': ipctx.set(value)
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
        elif key == 'WatScale': sc1.set(value)
        elif key == 'WatOffset': sc2.set(value)
        elif key == 'f0': f0.set(value)
        elif key == 'ftx': ftx.set(value)
        elif key == 'MRUDir': mrudir=value.replace("#"," ")
except:
    print 'Error reading WSPR.INI, continuing with defaults.'
    print key,value

#------------------------------------------------------  Select palette
if g.cmap == "gray0":
    pal_gray0()
    npal.set(0)
if g.cmap == "gray1":
    pal_gray1()
    npal.set(1)
if g.cmap == "Linrad":
    pal_linrad()
    npal.set(2)
if g.cmap == "blue":
    pal_blue()
    npal.set(3)
if g.cmap == "Hot":
    pal_Hot()
    npal.set(4)
if g.cmap == "AFMHot":
    pal_AFMHot()
    npal.set(5)


##lsync.configure(text=slabel+str(isync))
options.dbm_balloon()
fmid=f0.get() + 0.001500
draw_axis()
erase()
if g.Win32: root.iconbitmap("wsjt.ico")
root.title('  WSPR      by K1JT')

put_params()
try:
    os.remove('decoded.txt')
except:
    pass
##cmd="wspr_tr.exe"
##args="--gui"
##try:
##    os.spawnv(os.P_NOWAIT,cmd,(cmd,) + (args,))
##except:
##    print cmd + ' ' + args + ' failed.'
try:
    os.remove('pixmap.dat')
except:
    pass

w.wspr1()
graph1.focus_set()
ldate.after(100,update)
root.mainloop()

# Clean up and save user options before terminating
f=open(appdir+'/WSPR.INI',mode='w')
root_geom=root_geom[root_geom.index("+"):]
f.write("WSPRGeometry " + root_geom + "\n")
f.write("MyCall " + options.MyCall.get() + "\n")
f.write("MyGrid " + options.MyGrid.get() + "\n")
f.write("dBm " + str(options.dBm.get()) + "\n")
#f.write("IDinterval " + str(options.IDinterval.get()) + "\n")
f.write("PttPort " + str(options.PttPort.get()) + "\n")
f.write("AudioIn " + options.DevinName.get() + "\n")
f.write("AudioOut " + options.DevoutName.get() + "\n")
f.write("Nsave " + str(nsave.get()) + "\n")
f.write("PctTx " + str(ipctx.get()) + "\n")
f.write("Sync " + str(isync) + "\n")
mrudir2=mrudir.replace(" ","#")
f.write("MRUDir " + mrudir2 + "\n")
f.write("WatScale " + str(s0)+ "\n")
f.write("f0 " + str(f0.get()) + "\n")
f.write("ftx " + str(ftx.get()) + "\n")
f.close()

#  Close sound system
