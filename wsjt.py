#!/usr/bin/env python
#----------------------------------------------------------------------- WSJT8
# $Date$ $Revision$
#
from Tkinter import *
from tkFileDialog import *
from WsjtMod import Pmw
import tkMessageBox
from WsjtMod import g
import os,time
from WsjtMod import Audio
from math import log10
try:
    from numpy.oldnumeric import zeros
#    print "importing from numpy"
except: 
    from Numeric import zeros
#    print "importing from Numeric"
import dircache
import Image,ImageTk  #, ImageDraw
from WsjtMod.palettes import colormapblue, colormapgray0, colormapHot, \
     colormapAFMHot, colormapgray1, colormapLinrad, Colormap2Palette
from types import *
import array

root = Tk()
Version="8.0 r" + "$Rev$"[6:-1]
print "******************************************************************"
print "WSJT Version " + Version + ", by K1JT"
print "Revision date: " + \
      "$Date$"[7:-1]
print "Run date:   " + time.asctime(time.gmtime()) + " UTC"

appdir=os.getcwd()
g.appdir=appdir

#See if we are running in Windows
g.Win32=0
if sys.platform=="win32":
    g.Win32=1
#    from WsjtMod import options
    try:
        root.option_readfile('wsjtrc.win')
    except:
        pass
else:
#    from WsjtMod import options
    try:
        root.option_readfile('wsjtrc')
    except:
        pass
root_geom=""

Audio.gcom2.appdir=(appdir+(' '*80))[:80]
Audio.gcom2.lenappdir=len(appdir)
i1,i2=Audio.audiodev(0,2)
from WsjtMod import options

#------------------------------------------------------ Global variables
Audio.ftn_init()
first=1
isync=0
isyncMS=2
isync6m=1
isync65=1
isync_save=0
itol=5                                       #Default tol=400 Hz
ntol=(10,25,50,100,200,400,600)              #List of available tolerances
idsec=0
#irdsec=0
lauto=0
ltxdf=0
altmsg=0
cmap0="Linrad"
fileopened=""
font1='Helvetica'
hiscall=""
hisgrid=""
isec0=-99
k2txb=IntVar()
kb8rq=IntVar()
loopall=0
mode=StringVar()
mode.set("")
mrudir=os.getcwd()
MyCall0=""
naz=0
ndepth=IntVar()
nel=0
ncall=0
ncwtrperiod=120
ndmiles=0
ndkm=0
ndebug=IntVar()
neme=IntVar()
nfreeze=IntVar()
nhotaz=0
nhotabetter=0
nin0=0
nout0=0
nopen=0
qdecode=IntVar()
setseq=IntVar()
slabel="Sync   "
textheight=7
ToRadio0=""
tx6alt=""
txsnrdb=99.
TxFirst=IntVar()
a=0
green=zeros(500,'f')
im=Image.new('P',(500,120))
im.putpalette(Colormap2Palette(colormapLinrad),"RGB")
pim=ImageTk.PhotoImage(im)
balloon=Pmw.Balloon(root)

g.freeze_decode=0
g.mode=""
g.ndevin=IntVar()
g.ndevout=IntVar()
g.DevinName=StringVar()
g.DevoutName=StringVar()
#------------------------------------------------------ showspecjt
def showspecjt(event=NONE):
    if g.showspecjt==0: g.showspecjt=1

#------------------------------------------------------ restart
def restart():
    Audio.gcom2.nrestart=1
    Audio.gcom2.mantx=1

#------------------------------------------------------ toggle_freeze
def toggle_freeze(event=NONE):
    nfreeze.set(1-nfreeze.get())

#------------------------------------------------------ btx (1-6)
def btx1(event=NONE):
    ntx.set(1)
    Audio.gcom2.txmsg=(tx1.get()+(' '*28))[:28]
    Audio.gcom2.ntxreq=1
    restart()
def btx2(event=NONE):
    ntx.set(2)
    Audio.gcom2.txmsg=(tx2.get()+(' '*28))[:28]
    Audio.gcom2.ntxreq=2
    restart()
def btx3(event=NONE):
    ntx.set(3)
    Audio.gcom2.txmsg=(tx3.get()+(' '*28))[:28]
    Audio.gcom2.ntxreq=3
    restart()
def btx4(event=NONE):
    ntx.set(4)
    Audio.gcom2.txmsg=(tx4.get()+(' '*28))[:28]
    Audio.gcom2.ntxreq=4
    restart()
def btx5(event=NONE):
    ntx.set(5)
    Audio.gcom2.txmsg=(tx5.get()+(' '*28))[:28]
    Audio.gcom2.ntxreq=5
    restart()
def btx6(event=NONE):
    ntx.set(6)
    Audio.gcom2.txmsg=(tx6.get()+(' '*28))[:28]
    Audio.gcom2.ntxreq=6
    restart()

#------------------------------------------------------ quit
def quit(event=NONE):
    root.destroy()

#------------------------------------------------------ testmsgs
def testmsgs():
    for m in (tx1, tx2, tx3, tx4, tx5, tx6):
        m.delete(0,99)
    tx1.insert(0,"@500")
    tx2.insert(0,"@1000")
    tx3.insert(0,"@1270")
    tx4.insert(0,"@1500")
    tx5.insert(0,"@2000")
    tx6.insert(0,"@2500")

#------------------------------------------------------ textsize
def textsize():
    global textheight
    if textheight <= 9:
        textheight=21
    else:
        if mode.get()[:4]=='JT64' or mode.get()=='ISCAT' or \
               mode.get()[:3]=='JT8':
##            textheight=7
            textheight=9
        else:
            textheight=9
    text.configure(height=textheight)

#------------------------------------------------------ logqso
def logqso(event=NONE):
    t=time.strftime("%Y-%b-%d,%H:%M",time.gmtime())
    tf=str(g.nfreq)
    if g.nfreq==2: tf="1.8"
    if g.nfreq==4: tf="3.5"
    t=t+","+ToRadio.get()+","+HisGrid.get()+","+tf+","+g.mode+"\n"
    t2="Please confirm making the following entry in WSJT.LOG:\n\n" + t
    result=tkMessageBox.askyesno(message=t2)
    if result:
        f=open(appdir+'/WSJT.LOG','a')
        f.write(t)
        f.close()
    
#------------------------------------------------------ monitor
def monitor(event=NONE):
    bmonitor.configure(bg='green')
    Audio.gcom2.monitoring=1

#------------------------------------------------------ stopmon
def stopmon(event=NONE):
    global loopall
    loopall=0
    bmonitor.configure(bg='gray85')
    Audio.gcom2.monitoring=0    

#------------------------------------------------------ dbl_click_text
def dbl_click_text(event):
    t=text.get('1.0',END)           #Entire contents of text box
    t1=text.get('1.0',CURRENT)      #Contents from start to mouse pointer
    dbl_click_call(t,t1,'OOO',event)

#------------------------------------------------------ dbl_click3_text
def dbl_click3_text(event):
    if mode.get()[:4]=='JT64' or mode.get()=='ISCAT' or \
           mode.get()[:3]=='JT8':
        t=text.get('1.0',END)           #Entire contents of text box
        t1=text.get('1.0',CURRENT)      #Contents from start to mouse pointer
        n=t1.rfind("\n")
        rpt=t1[n+12:n+15]
        if rpt[0:1] == " ": rpt=rpt[1:]
        if mode.get()=='ISCAT' or mode.get()[:4]=='JT64':
            i=int((int(rpt)+33)/3)
            if i<1: i=1
            if i>9: i=9
            rpt="S%d" % (i,)
#            report.insert(0,rpt)
        dbl_click_call(t,t1,rpt,event)

#------------------------------------------------------ dbl_click_ave
def dbl_click_ave(event):
    t=avetext.get('1.0',END)           #Entire contents of text box
    t1=avetext.get('1.0',CURRENT)      #Contents from start to mouse pointer
    dbl_click_call(t,t1,'OOO',event)
#------------------------------------------------------ dbl_click_call
def dbl_click_call(t,t1,rpt,event):
    global hiscall
    i=len(t1)                       #Length to mouse pointer
    i1=t1.rfind(' ')+1              #index of preceding space
    i2=i1+t[i1:].find(' ')          #index of next space
    hiscall=t[i1:i2]                #selected word, assumed as callsign
    if hiscall[0:1]=='<' and hiscall [i2-i1-1:]=='>':
        hiscall=hiscall[1:i2-i1-1]
    ToRadio.delete(0,END)
    ToRadio.insert(0,hiscall)
    i3=t1.rfind('\n')+1             #start of selected line
    if i>6 and i2>i1:
        try:
            nsec=60*int(t1[i3+2:i3+4]) + int(t1[i3+4:i3+6])
        except:
            nsec=0
        if setseq.get(): TxFirst.set((nsec/Audio.gcom1.trperiod)%2)
        lookup()
        GenStdMsgs()
        if (mode.get()[:4]=='JT64' or mode.get()[:5]=='ISCAT' or \
           mode.get()[:3]=='JT8') and rpt <> "OOO":
            n=tx1.get().rfind(" ")
            t2=tx1.get()[0:n+1]
            tx2.delete(0,END)
            tx2.insert(0,t2+rpt)
            tx3.delete(0,END)
            tx3.insert(0,t2+"R"+rpt)
            tx4.delete(0,END)
            tx4.insert(0,t2+"RRR")
            tx5.delete(0,END)
            tx5.insert(0,t2+"73")
        i3=t[:i1].strip().rfind(' ')+1
        if t[i3:i1].strip() == 'CQ':
            ntx.set(1)
        else:
            ntx.set(2)
        if event.num==3 and not lauto: toggleauto()

def textkey(event=NONE):
    text.configure(state=DISABLED)
def avetextkey(event=NONE):
    avetext.configure(state=DISABLED)

#------------------------------------------------------ force_decode
def force_decode(event=NONE):
    Audio.gcom2.nforce=1
    if event.keysym == 'd': Audio.gcom2.ntx2=0
    if event.keysym == 'D': Audio.gcom2.ntx2=1
    decode()

#------------------------------------------------------ decode
def decode(event=NONE):
    if Audio.gcom2.ndecoding==0:        #If already busy, ignore request
        Audio.gcom2.nagain=1
        Audio.gcom2.npingtime=0         #Decode whole record
        n=1
        Audio.gcom2.mousebutton=0
        if Audio.gcom2.ndecoding0==4: n=4
        Audio.gcom2.ndecoding=n         #Standard decode, full file (d2a)

#------------------------------------------------------ decode_include
def decode_include(event=NONE):
    global isync,isync_save
    isync_save=isync
    isync=-99
    Audio.gcom2.minsigdb=-99
    decode()

#------------------------------------------------------ decode_exclude
def decode_exclude(event=NONE):
    global isync,isync_save
    isync_save=isync
    isync=99
    Audio.gcom2.minsigdb=99
    decode()

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
        Audio.getfile(fname,len(fname))
        if Audio.gcom2.ierr: print 'Error ',Audio.gcom2.ierr, \
           'when trying to read file',fname
        mrudir=os.path.dirname(fname)
        fileopened=os.path.basename(fname)
    os.chdir(appdir)
 
#------------------------------------------------------ opennext
def opennext(event=NONE):
    global ncall,fileopened,loopall,mrudir
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
#            if not lauto: stopmon()
            Audio.getfile(fname,len(fname))
            if Audio.gcom2.ierr: print 'Error ',Audio.gcom2.ierr, \
               'when trying to read file',fname
            mrudir=os.path.dirname(fname)
            fileopened=os.path.basename(fname)
        else:
            t="No more *.wav files in this directory."
	    tkMessageBox.showwarning(message=t)
            ncall=0
            loopall=0

#------------------------------------------------------ decodeall
def decodeall(event=NONE):
    global loopall
    loopall=1
    opennext()

#------------------------------------------------------ astro1
def astro1(event=NONE):
    astro.astro2(g.astro_geom0)

#------------------------------------------------------ options1
def options1(event=NONE):
    t='400x265' + root_geom[root_geom.index("+"):]
    options.options2(t)

#------------------------------------------------------ txmute
def txmute(event=NONE):
    Audio.gcom1.mute=1-Audio.gcom1.mute
    if Audio.gcom1.mute:
        lab7.configure(bg='red',fg='black')
    else:
        lab7.configure(bg='gray85',fg='gray85')

#------------------------------------------------------ savelast
def savelast(event=NONE):
    Audio.gcom2.nsavelast=1

#------------------------------------------------------ stub
def stub(event=NONE):
    MsgBox("Sorry, this function is not yet implemented.")

#------------------------------------------------------ MsgBox
def MsgBox(t):
    tkMessageBox._show(message=t)

#------------------------------------------------------ txstop
def txstop(event=NONE):
    if lauto: toggleauto()
    Audio.gcom1.txok=0
    Audio.gcom2.mantx=0
    
#------------------------------------------------------ lookup
def lookup(event=NONE):
    global hiscall,hisgrid
    hiscall=ToRadio.get().upper().strip()
    ToRadio.delete(0,END)
    ToRadio.insert(0,hiscall)
    s=whois(hiscall)
    balloon.bind(ToRadio,s[:-1])
    hisgrid=""
    if s:
        i1=s.find(',')
        i2=s.find(',',i1+1)
        hisgrid=s[i1+1:i2]
        hisgrid=hisgrid[:2].upper()+hisgrid[2:4]+hisgrid[4:6].lower()
    if len(hisgrid)==4: hisgrid=hisgrid+"mm"
    if len(hisgrid)==5: hisgrid=hisgrid+"m"
    HisGrid.delete(0,99)
    HisGrid.insert(0,hisgrid)

def lookup_gen(event):
    lookup()
    GenStdMsgs()

#-------------------------------------------------------- addtodb
def addtodb():
    global hiscall
    if HisGrid.get()=="":
        MsgBox("Please enter a valid grid locator.")
    else:
        modified=0
        hiscall=ToRadio.get().upper().strip()
        hisgrid=HisGrid.get().strip()
        hc=hiscall
        NewEntry=hc + "," + hisgrid
	result=tkMessageBox.askyesno(message="Is this station known to be active on EME?")
        if result:
            NewEntry=NewEntry + ",EME,,"
        else:
            NewEntry=NewEntry + ",,,"
        try:
            f=open(appdir+'/CALL3.TXT','r')
            s=f.readlines()
        except:
            print 'Error opening CALL3.TXT'
            s=""
        f.close()
        hc2=""
        stmp=[]
        for i in range(len(s)):
            hc1=hc2
            if s[i][:2]=="//":
                stmp.append(s[i])
            else:
                i1=s[i].find(",")
                hc2=s[i][:i1]
                if hc>hc1 and hc<hc2:
                    stmp.append(NewEntry+"\n")
                    modified=1
                elif hc==hc2:
                    t=s[i] + "\n\n is already in CALL3.TXT\nDo you wish to replace this entry?"
		    result=tkMessageBox.askyesno(message=t)
                    if result:
                        i1=s[i].find(",")
                        i2=s[i].find(",",i1+1)
                        i3=s[i].find(",",i2+1)
                        i4=len(NewEntry)
                        s[i]=NewEntry[:i4-1] + s[i][i3+1:]
                        modified=1
                stmp.append(s[i])
        if hc>hc1 and modified==0:
            stmp.append(NewEntry+"\n")
        try:
            f=open(appdir+'/CALL3.TMP','w')
            f.writelines(stmp)
            f.close()
        except:
            print 'Error in opening or writing to CALL3.TMP'

        if modified:
            if os.path.exists("CALL3.OLD"): os.remove("CALL3.OLD")
            os.rename("CALL3.TXT","CALL3.OLD")
            os.rename("CALL3.TMP","CALL3.TXT")

#-------------------------------------------------------- clrToRadio
def clrToRadio(event):
    ToRadio.delete(0,END)
    HisGrid.delete(0,99)
    ToRadio.focus_set()
    if kb8rq.get():
        ntx.set(6)
        nfreeze.set(0)

#------------------------------------------------------ whois
def whois(hiscall):
    whodat=""
    try:
        f=open(appdir+'/CALL3.TXT','r')
        s=f.readlines()
        f.close()
    except:
        print 'Error when searching CALL3.TXT, or no such file present'
        s=""
    for i in range(len(s)):
        if s[i][:2] != '//':
            i1=s[i].find(',')
            if s[i][:i1] == hiscall:
                return s[i]
    return ""

#------------------------------------------------------ cleartext
def cleartext():
    f=open(appdir+'/decoded.txt',mode='w')
    f.truncate(0)                           #Delete contents of decoded.txt
    f.close()
    f=open(appdir+'/decoded.ave',mode='w')
    f.truncate(0)                           #Delete contents of decoded.ave
    f.close()

#------------------------------------------------------ ModeJTMS
def ModeJTMS(event=NONE):
    global slabel,isync,isyncMS,textheight,itol
    if g.mode != "JTMS":
        if lauto: toggleauto()
        mode.set("JTMS")
        cleartext()
        Audio.gcom1.trperiod=30
        lab2.configure(text='FileID             T      Width     dB    Rpt          DF')
        lab1.configure(text='Time (s)',bg="green")
        lab4.configure(fg='black')
        lab5.configure(fg='black')
        lab6.configure(bg="green")
        isync=isyncMS
        slabel="S      "
        lsync.configure(text=slabel+str(isync))
        iframe4b.pack_forget()
        textheight=9
        text.configure(height=textheight)
        bclravg.configure(state=DISABLED)
        binclude.configure(state=DISABLED)
        bexclude.configure(state=DISABLED)
        cbfreeze.configure(state=NORMAL)
        if ltxdf: toggletxdf()
        btxdf.configure(state=DISABLED)
        graph2.configure(bg='black')
        itol=4
        inctol()
        ntx.set(1)
        GenStdMsgs()
        erase()

#------------------------------------------------------ ModeJT64
def ModeJT64():
    global slabel,isync,isync65,textheight,itol
    cleartext()
    lab2.configure(text='FileID      Sync     dB        DT       DF    *')
    lab4.configure(fg='gray85')
    lab5.configure(fg='gray85')
    Audio.gcom1.trperiod=60
##    iframe4b.pack(after=iframe4,expand=1, fill=X, padx=4)
##    textheight=7
    iframe4b.pack_forget()
    textheight=9
    text.configure(height=textheight)
    isync=isync65
    slabel="Sync   "
    lsync.configure(text=slabel+str(isync))
##    bclravg.configure(state=NORMAL)
##    binclude.configure(state=NORMAL)
##    bexclude.configure(state=NORMAL)
    bclravg.configure(state=DISABLED)
    binclude.configure(state=DISABLED)
    bexclude.configure(state=DISABLED)
    cbfreeze.configure(state=NORMAL)
    if ltxdf: toggletxdf()
    btxdf.configure(state=NORMAL)
    graph2.configure(bg='#66FFFF')
    itol=4
    inctol()
    nfreeze.set(0)
    ntx.set(1)
    GenStdMsgs()
    erase()
#    graph2.pack_forget()

#------------------------------------------------------ ModeJT64A
def ModeJT64A(event=NONE):
    if g.mode != "JT64A":
        if lauto: toggleauto()
        mode.set("JT64A")
        ModeJT64()

#------------------------------------------------------ ModeJT64B
def ModeJT64B(event=NONE):
    if g.mode != "JT64B":
        if lauto: toggleauto()
        mode.set("JT64B")
        ModeJT64()

#------------------------------------------------------ ModeJT64C
def ModeJT64C(event=NONE):
    if g.mode != "JT64C":
        if lauto: toggleauto()
        mode.set("JT64C")
        ModeJT64()

#------------------------------------------------------ ModeISCAT
def ModeISCAT(event=NONE):
    global slabel,isync,isync6m,itol
    if g.mode != "ISCAT":
        if lauto: toggleauto()
        cleartext()
        ModeJTMS()
        lab2.configure(text='FileID      Sync       dB        DF     *')
        mode.set("ISCAT")
        isync=isync6m
        lsync.configure(text=slabel+str(isync))
        bclravg.configure(state=DISABLED)
        binclude.configure(state=DISABLED)
        bexclude.configure(state=DISABLED)
        cbfreeze.configure(state=NORMAL)
        itol=4
        ltol.configure(text='Tol    '+str(ntol[itol]))
        inctol()
        nfreeze.set(1)
        ntx.set(1)
        Audio.gcom2.mousedf=0
        GenStdMsgs()
        erase()

#------------------------------------------------------ ModeJT8
def ModeJT8():
    global slabel,isync,isync65,textheight,itol
    ModeJT64()
    mode.set("JT8")
    Audio.gcom2.mode4=1

#------------------------------------------------------ ModeEcho
def ModeEcho(event=NONE):
    mode.set("Echo")
    ModeJT64()
    if lauto: toggleauto()
    lab2.configure(text='     N      Level         Sig              DF         Width      Q')
#    tx1.delete(0,99)
#    tx1.insert(0,"ECHO")

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
    t="WSJT8 Version " + Version + ", by K1JT"
    Label(about,text=t,font=(font1,16)).pack(padx=20,pady=5)
    t="""
WSJT8 is a weak signal communications program.  It supports
these operating modes:

  1. JT64  - EME
  2. ISCAT - ionospheric scatter on 50 MHz
  3. JTMS  - fast mode for meteor scatter
  4. JT8   - for HF
  5. Echo  - EME Echo testing

Copyright (c) 2001-2009 by Joseph H. Taylor, Jr., K1JT, with
contributions from additional authors.  WSJT is Open Source 
software, licensed under the GNU General Public License (GPL).
Source code and programming information may be found at 
http://developer.berlios.de/projects/wsjt/.
"""
    Label(about,text=t,justify=LEFT).pack(padx=20)
    t="Revision date: " + \
      "$Date$"[7:-1]
    Label(about,text=t,justify=LEFT).pack(padx=20)
    about.focus_set()

#------------------------------------------------------ shortcuts
def shortcuts(event=NONE):
    scwid=Toplevel(root)
    scwid.geometry(msgpos())
    if g.Win32: scwid.iconbitmap("wsjt.ico")
    t="""
F1	List keyboard shortcuts
Shift+F1	List special mouse commands
Ctrl+F1	About WSJT
F2	Options
Shift+F2   WSPR structured messages
F3	Tx Mute
F4	Clear "To Radio"
Alt+F4      Exit program
F5	What message to send?
Shift+F5	Examples of minimal JT64 QSOs
F6	Open next file in directory
Shift+F6	Decode all wave files in directory
F7	Set JTMS mode
Shift+F7	Set ISCAT mode
F8	Set JT64A mode
Shift+F8	Set JT64B mode
Ctrl+F8	Set JT64C mode
Shift+Ctrl+F8 Set JT64D mode
F10	Show SpecJT
Shift+F10  Show astronomical data
F11	Decrement Freeze DF
F12	Increment Freeze DF
Alt+1 to Alt+6  Tx1 to Tx6
Alt+A	Toggle Auto On/Off
Alt+D	Decode
Ctrl+D	Force Decode 
Shift+Ctrl+D  Force Decode, no shorthands 
Alt+E	Erase
Alt+F	Toggle Freeze
Alt+G	Generate Standard Messages
Ctrl+G	Generate Alternate JT64 Messages
Alt+I	Include
Alt+L	Lookup
Ctrl+L	Lookup, then Generate Standard Messages
Alt+M	Monitor
Alt+O	Tx Stop
Alt+Q	Log QSO
Alt+S	Stop Monitoring or Decoding
Alt+V	Save Last
Alt+X	Exclude
"""
    Label(scwid,text=t,justify=LEFT).pack(padx=20)
    scwid.focus_set()

#------------------------------------------------------ mouse_commands
def mouse_commands(event=NONE):
    scwid=Toplevel(root)
    scwid.geometry(msgpos())
    if g.Win32: scwid.iconbitmap("wsjt.ico")
    t="""
Click on          Action
--------------------------------------------------------
Waterfall        JTMS: click to decode ping
                 JT64: Click to set DF for Freeze
                       Double-click to Freeze and Decode

Main screen,     JTMS: click to decode ping
graphics area    JT64: Click to set DF for Freeze
                           Double-click to Freeze and Decode

Main screen,     Double-click puts callsign in Tx messages
text area           Right-double-click also sets Auto ON

Sync, Tol,       Left/Right click to increase/decrease
"""
    Label(scwid,text=t,justify=LEFT).pack(padx=20)
    scwid.focus_set()

#------------------------------------------------------ what2send
def what2send(event=NONE):
    screenf5=Toplevel(root)
    screenf5.geometry(root_geom[root_geom.index("+"):])
    if g.Win32: screenf5.iconbitmap("wsjt.ico")
    t="""
To optimize your chances of completing a valid QSO using WSJT,
use the following standard procedures and *do not* exchange pertinent
information by other means (e.g., internet, telephone, ...) while the
QSO is in progress!

JTMS or ISCAT:   If you have received
    ... less than both calls from the other station, send both calls.
    ... both calls, send both calls and your signal report.
    ... both calls and signal report, send R and your report.
    ... R plus signal report, send RRR.
    ... RRR, the QSO is complete.  However, the other station may not
know this, so it is conventional to send 73 to signify that you are done.



JT64:   If you have received
    ... less than both calls, send both calls and your grid locator.
    ... both calls, send both calls, your grid locator, and OOO.
    ... both calls and OOO, send RO.
    ... RO, send RRR.
    ... RRR, the QSO is complete.  However, the other station may not
know this, so it is conventional to send 73 to signify that you are done.
"""
    Label(screenf5,text=t,justify=LEFT).pack(padx=20)
    screenf5.focus_set()

#------------------------------------------------------ minimal_qso
def minimal_qso(event=NONE):
    screenf5s=Toplevel(root)
    screenf5s.geometry(root_geom[root_geom.index("+"):])
    if g.Win32: screenf5s.iconbitmap("wsjt.ico")
    t="""
The following are recommended sequences for valid QSOs
using the standard messages:

Station #1                            Station #2
----------------------------------------------------------
CQ K1JT FN20
                                            K1JT DL3XYZ JO61
DL3XYZ K1JT FN20 OOO
                                            RO
RRR
                                            73
----------------------------------------------------------
CQ K1JT FN20
                                            K1JT VK7ABC QE37
VK7ABC K1JT -22
                                            K1JT VK7ABC R-23
VK7ABC K1JT RRR
                                            TNX JOE 73
"""
    Label(screenf5s,text=t,justify=LEFT).pack(padx=20)
    screenf5s.focus_set()

#------------------------------------------------------ azdist
def azdist():
    if len(HisGrid.get().strip())<4:
        labAz.configure(text="")
        labHotAB.configure(text="",bg='gray85')
        labDist.configure(text="")
    else:
        if mode.get()[:4]=='JT64' or mode.get()[:3]=='JT8':
            labAz.configure(text="Az: %d" % (naz,))
            labHotAB.configure(text="",bg='gray85')
        else:
            labAz.configure(text="Az: %d   El: %d" % (naz,nel))
            if nhotabetter:
                labHotAB.configure(text="Hot A: "+str(nhotaz),bg='#FF9900')
            else:
                labHotAB.configure(text="Hot B: "+str(nhotaz),bg='#FF9900')
        if options.mileskm.get()==0:
            labDist.configure(text=str(ndmiles)+" mi")
        else:
            labDist.configure(text=str(int(1.609344*ndmiles))+" km")
    
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

#------------------------------------------------------ inctol
def inctol(event=NONE):
    global itol
    maxitol=5
    if mode.get()[:4]=='JT64': maxitol=6
    if itol<maxitol: itol=itol+1
    ltol.configure(text='Tol    '+str(ntol[itol]))

#------------------------------------------------------ dectol
def dectol(event):
    global itol
    if itol>0 : itol=itol-1
    ltol.configure(text='Tol    '+str(ntol[itol]))

#------------------------------------------------------ incdsec
def incdsec(event):
    global idsec
    idsec=idsec+5
    bg='red'
    if idsec==0: bg='white'
    ldsec.configure(text='Dsec  '+str(0.1*idsec),bg=bg)
    Audio.gcom1.ndsec=idsec

#------------------------------------------------------ decdsec
def decdsec(event):
    global idsec
    idsec=idsec-5
    bg='red'
    if idsec==0: bg='white'
    ldsec.configure(text='Dsec  '+str(0.1*idsec),bg=bg)
    Audio.gcom1.ndsec=idsec

#------------------------------------------------------ inctrperiod
def inctrperiod(event):
    global ncwtrperiod
    if mode.get()[:2]=="CW":
        if ncwtrperiod==120: ncwtrperiod=150
        if ncwtrperiod==60:  ncwtrperiod=120
        Audio.gcom1.trperiod=ncwtrperiod

#------------------------------------------------------ dectrperiod
def dectrperiod(event):
    global ncwtrperiod
    if mode.get()[:2]=="CW":
        if ncwtrperiod==120: ncwtrperiod=60
        if ncwtrperiod==150: ncwtrperiod=120
        Audio.gcom1.trperiod=ncwtrperiod

#------------------------------------------------------ erase
def erase(event=NONE):
    graph1.delete(ALL)
    if mode.get()[:4]=="JTMS" or mode.get()[:5]=="ISCAT":
        graph2.delete(ALL)
    text.configure(state=NORMAL)
    text.delete('1.0',END)
    text.configure(state=DISABLED)
    avetext.configure(state=NORMAL)
    avetext.delete('1.0',END)
    avetext.configure(state=DISABLED)
    lab3.configure(text=" ")
    Audio.gcom2.decodedfile="                        "
#------------------------------------------------------ clear_avg
def clear_avg(event=NONE):
    avetext.configure(state=NORMAL)
    avetext.delete('1.0',END)
    avetext.configure(state=DISABLED)
    f=open(appdir+'/decoded.ave',mode='w')
    f.truncate(0)                           #Delete contents of decoded.ave
    f.close()
    Audio.gcom2.nclearave=1

#------------------------------------------------------ delwav
def delwav():
    t="Are you sure you want to delete\nall *.WAV files in the RxWav directory?"
    result=tkMessageBox.askyesno(message=t)
    if result:
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

#------------------------------------------------------ del_all
def del_all():
    Audio.gcom1.ns0=-999999

#------------------------------------------------------ toggleauto
def toggleauto(event=NONE):
    global lauto
    lauto=1-lauto
    Audio.gcom2.lauto=lauto
    if lauto and mode.get()!='Echo':
        monitor()
    else:
        Audio.gcom1.txok=0
        Audio.gcom2.mantx=0
    if lauto==0: auto.configure(text='Auto is OFF',bg='gray85',relief=RAISED)
    if lauto==1: auto.configure(text='Auto is ON',bg='red',relief=SOLID)
    
#------------------------------------------------------ toggletxdf
def toggletxdf(event=NONE):
    global ltxdf
    ltxdf=1-ltxdf
    if ltxdf:
        Audio.gcom2.ntxdf=Audio.gcom2.mousedf
        t="TxDF = %d" % (int(Audio.gcom2.mousedf),)
        btxdf.configure(text=t,bg='red',relief=SOLID)
    else:
        Audio.gcom2.ntxdf=0
        btxdf.configure(text='TxDF = 0',bg='gray85',relief=RAISED)
    if Audio.gcom1.transmitting:
        txstop()

#----------------------------------------------------- dtdf_change
# Readout of graphical cursor location
def dtdf_change(event):
    if mode.get()[:4]=='JTMS':
        t="%.1f" % (event.x*30.0/500.0,)
        lab6.configure(text=t,bg='green')
    else:
        if event.y<40 and Audio.gcom2.nspecial==0 and mode.get()<>'ISCAT':
            lab1.configure(text='Time (s)',bg="#33FFFF")   #light blue
##            t="%.1f" % (12.0*event.x/500.0-2.0,)
            t="%.1f" % float(event.x)
            lab6.configure(text=t,bg="#33FFFF")
        elif (event.y>=40 and event.y<95) or \
              (event.y<95 and (Audio.gcom2.nspecial>0 or mode.get()=='ISCAT')):
            lab1.configure(text='DF (Hz)',bg='red')
            idf=Audio.gcom2.idf
            if mode.get()[:5]=='ISCAT':
                t="%d" % int(0.25*(12000.0/1024.0)*(event.x-250.0))
            else:
                t="%d" % int(0.5*(idf+1200.0*event.x/500.0-600.0))
            lab6.configure(text=t,bg="red")
        else:
            lab1.configure(text='Time (s)',bg='green')
            if mode.get()=='ISCAT':
                t="%.1f" % (event.x*30.0/500.0,)
            else:
                t="%.1f" % (53.0*event.x/500.0,)
            lab6.configure(text=t,bg="green")

#---------------------------------------------------- mouse_click_g1
def mouse_click_g1(event):
    global nopen,nxa
    nxa=max(1,event.x)
    if not nopen:
        if mode.get()[:4]=='JT64' or mode.get()[:3]=='JT8':
#            Audio.gcom2.mousedf=int(Audio.gcom2.idf+(event.x-250)*2.4)
            Audio.gcom2.mousedf=int(Audio.gcom2.idf+(event.x-250)*1.2)
        elif mode.get()=='JTMS':
            if Audio.gcom2.ndecoding==0:              #If decoder is busy, ignore
                Audio.gcom2.nagain=1
                Audio.gcom2.mousebutton=event.num     #Left=1, Right=3
                Audio.gcom2.npingtime=int(195+60*event.x) #Time (ms) of mouse-picked ping
                if Audio.gcom2.ndecoding0==4:
                    Audio.gcom2.ndecoding=4           #Decode from recorded file
                elif Audio.gcom2.ndecoding0==1:
                    Audio.gcom2.ndecoding=5        #Decode data in main screen

#------------------------------------------------------ double-click_g1
def double_click_g1(event):
    if (mode.get()[:4]=='JT64' or mode.get()[:5]=='ISCAT' or \
        mode.get()[:3]=='JT8') and Audio.gcom2.ndecoding==0:
        g.freeze_decode=1
    
#------------------------------------------------------ mouse_up_g1
def mouse_up_g1(event):
    global nopen,nxa
    if mode.get()=='ISCAT':
        if abs(event.x-nxa)>10:
            nxb=min(event.x,500)
            if nxb<nxa:
                t=nxb
                nxb=nxa
                nxa=t
            Audio.gcom2.nxa=nxa
            Audio.gcom2.nxb=nxb
            decode()
        else:
            if not nopen:
                mdf=int(Audio.gcom2.idf+(event.x-250)*2.9296875)
                if mdf<-400: mdf=-400
                if mdf>400: mdf=400
                Audio.gcom2.mousedf=mdf
    nopen=0

#------------------------------------------------------ right_arrow
def right_arrow(event=NONE):
    n=5*int(Audio.gcom2.mousedf/5)
    if n!=0: n=n+5
    if n==Audio.gcom2.mousedf: n=n+5
    Audio.gcom2.mousedf=n

#------------------------------------------------------ left_arrow
def left_arrow(event=NONE):
    n=5*int(Audio.gcom2.mousedf/5)
    if n==Audio.gcom2.mousedf: n=n-5
    Audio.gcom2.mousedf=n
    
#------------------------------------------------------ GenStdMsgs
def GenStdMsgs(event=NONE):
    global altmsg,MyCall0,ToRadio0
    t=ToRadio.get().upper().strip()
    ToRadio.delete(0,99)
    ToRadio.insert(0,t)
    if k2txb.get()!=0: ntx.set(1)
    Audio.gcom2.hiscall=(ToRadio.get()+(' '*12))[:12]
    for m in (tx1, tx2, tx3, tx4, tx5, tx6):
        m.delete(0,99)

    tx1.insert(0,setmsg(options.tx1.get()))
    tx2.insert(0,setmsg(options.tx2.get()))
    tx3.insert(0,setmsg(options.tx3.get()))
    tx4.insert(0,setmsg(options.tx4.get()))
    tx5.insert(0,setmsg(options.tx5.get()))
    tx6.insert(0,setmsg(options.tx6.get()))
    
#------------------------------------------------------ GenAltMsgs
def GenAltMsgs(event=NONE):
    global altmsg,tx6alt
    t=ToRadio.get().upper().strip()
    ToRadio.delete(0,99)
    ToRadio.insert(0,t)
    if k2txb.get()!=0: ntx.set(1)
    Audio.gcom2.hiscall=(ToRadio.get()+(' '*12))[:12]
    if (mode.get()[:4]=='JT64' or mode.get()[:4]=='ISCAT' or \
        mode.get()[:3]=='JT8') and ToRadio.get().find("/") == -1 and \
               options.MyCall.get().find("/") == -1:
        for m in (tx1, tx2, tx3, tx4, tx5, tx6):
            m.delete(0,99)
        t=ToRadio.get() + " "+options.MyCall.get()
        tx1.insert(0,t.upper())
        tx2.insert(0,tx1.get()+" OOO")
        tx3.insert(0,tx1.get()+" RO")
        tx4.insert(0,tx1.get()+" RRR")
        tx5.insert(0,"TNX 73 GL ")
        tx6.insert(0,tx6alt.upper())
        altmsg=1

#------------------------------------------------------ setmsg
def setmsg(template):
    msg=""
    r='-20'
    npct=0
    for i in range(len(template)):
        if npct:
            if template[i]=="M": msg=msg+options.MyCall.get().upper().strip()
            if template[i]=="T": msg=msg+ToRadio.get().upper().strip()
            if template[i]=="R": msg=msg+r
            if template[i]=="G": msg=msg+options.MyGrid.get()[:4]
            if template[i]=="L": msg=msg+options.MyGrid.get()
            npct=0
        else:
            npct=0
            if template[i]=="%":
                npct=1
            else:
                msg=msg+template[i]
    return msg.upper()
    
#------------------------------------------------------ plot_large
def plot_large():
    "Plot the green, red, and blue curves."
    graph1.delete(ALL)
    y=[]
    ngreen=Audio.gcom2.ngreen
    if ngreen>0:
        for i in range(ngreen):             #Find ymax for green curve
            green=Audio.gcom2.green[i]
            y.append(green)
        ymax=max(y)
        ymin=min(y)
        if ymax<1: ymax=1
        yfac=4.0
        if ymax>75.0/yfac: yfac=75.0/ymax
        xy=[]
        for i in range(ngreen):             #Make xy list for green curve
            green=Audio.gcom2.green[i]
            n=int(105.0-yfac*green)
            xy.append(i)
            xy.append(n)
        graph1.create_line(xy,fill="green")

        if Audio.gcom2.nxb>0:
            graph1.create_line(Audio.gcom2.nxa,110,Audio.gcom2.nxb,110,fill='yellow')
            graph1.create_line(Audio.gcom2.nxa,105,Audio.gcom2.nxa,115,fill='yellow')
            graph1.create_line(Audio.gcom2.nxb,105,Audio.gcom2.nxb,115,fill='yellow')
            Audio.gcom2.nxa=0
            Audio.gcom2.nxb=0

        if Audio.gcom2.nspecial==0:
            y=[]
            for i in range(446):                #Find ymax for red curve
                psavg=Audio.gcom2.psavg[i+1]
                y.append(psavg)
            ymax=max(y)
            yfac=90.0
            if ymax>(85.0/yfac): yfac=85.0/ymax
            if mode.get()[:4]=='JT64':
                yfac=60.0
                if ymax>4: yfac=4*yfac/ymax
            xy=[]
            fac=500.0/446.0
            for i in range(446):                #Make xy list for red curve
                x=i*fac
                if mode.get()=='ISCAT':
                    x=4*i - 642
                psavg=0.3*Audio.gcom2.psavg[i+1]
                n=int(90.0-yfac*psavg)
                xy.append(x)
                xy.append(n)
            graph1.create_line(xy,fill="red")
        else:
            y1=[]
            y2=[]
            for i in range(446):        #Find ymax for magenta/orange curves
                ss1=Audio.gcom2.ss1[i+1]
                y1.append(ss1)
                ss2=Audio.gcom2.ss2[i+1]
                y2.append(ss2)
            ymax=max(y1+y2)
            yfac=30.0
            if ymax>85.0/yfac: yfac=85.0/ymax
            xy1=[]
            xy2=[]
            fac=500.0/446.0
            for i in range(446):        #Make xy list for magenta/orange curves
                x=i*fac
                ss1=Audio.gcom2.ss1[i+1]
                n=int(90.0-yfac*ss1)
                xy1.append(x)
                xy1.append(n)
                ss2=Audio.gcom2.ss2[i+1]
                n=int(90.0-yfac*ss2) - 20
                xy2.append(x)
                xy2.append(n)
            graph1.create_line(xy1,fill="magenta")
            graph1.create_line(xy2,fill="orange")

            x1 = 250.0 + fac*Audio.gcom2.ndf/2.6916504
            x2 = x1 + Audio.gcom2.mode65*Audio.gcom2.nspecial*10*fac
            graph1.create_line([x1,85,x1,95],fill="yellow")
            graph1.create_line([x2,85,x2,95],fill="yellow")
            t="RO"
            if Audio.gcom2.nspecial==2: t="RRR"
            if Audio.gcom2.nspecial==3: t="73"
            graph1.create_text(x2+3,93,anchor=W,text=t,fill="yellow")

        if Audio.gcom2.ccf[0] != -9999.0:
            y=[]
            imax=65
            if mode.get()[:5]=='ISCAT': imax=545
            for i in range(imax):             #Find ymax for blue curve
                ccf=Audio.gcom2.ccf[i]
                y.append(ccf)
            ymax=max(y)
            yfac=2.0
            if mode.get()=='JT8': yfac=5.0
            if ymax>(55.0/yfac): yfac=55.0/ymax
            xy2=[]
            fac=500.0/(imax-0.4)
            if mode.get()[:5]=='ISCAT': fac=1.0
            for i in range(imax):             #Make xy list for blue curve
                x=(i+0.5)*fac
                ccf=Audio.gcom2.ccf[i]
                n=int(60.0-yfac*ccf)
                xy2.append(x)
                xy2.append(n)
            graph1.create_line(xy2,fill='#33FFFF')

#  Put in the tick marks
        for i in range(13):
            x=int(i*41.667)
            j2=115
            if i==1 or i==6 or i==11: j2=110
            graph1.create_line([x,j2,x,125],fill="red")
            if Audio.gcom2.nspecial==0:
#                x=int((i-0.8)*41.667)
                j1=9
                if i==2 or i==7 or i==12: j1=14
                graph1.create_line([x,0,x,j1],fill="#33FFFF")  #light blue
            else:
                graph1.create_line([x,0,x,125-j2],fill="red")

#------------------------------------------------------ plot_small
def plot_small():        
    graph2.delete(ALL)
    xy=[]
    xy2=[]
    if mode.get()[:5]=='ISCAT':
        df=12000.0/1024.0
        iz=256
    elif mode.get()[:4]=='JTMS':
        df=12000.0/256.0
        iz=128
    fac=150.0/3500.0
    for i in range(iz):
        x=int(i*df*fac)
        xy.append(x)
        if mode.get()[:5]=='ISCAT':
            psavg=Audio.gcom2.ps0[i]
            n=int(150.0-3*(psavg+20))
        elif mode.get()[:4]=='JTMS':
            psavg=Audio.gcom2.psavg[i]
            n=int(150.0-2.5*(psavg+15))
        xy.append(n)
    graph2.create_line(xy,fill="magenta")

    for i in range(7):
        x=i*500*fac
        ytop=110
        if i%2: ytop=115
        graph2.create_line([x,120,x,ytop],fill="white")

#------------------------------------------------------ update
def update():
    global root_geom,isec0,naz,nel,ndmiles,ndkm,nhotaz,nhotabetter,nopen, \
           im,pim,cmap0,isync,isyncMS,isync6m,isync65,isync_save,idsec, \
           first,itol,txsnrdb,tx6alt,nin0,nout0,lauto
    
    utc=time.gmtime(time.time()+0.1*idsec)
    isec=utc[5]

    if isec != isec0:                           #Do once per second
        isec0=isec
        t=time.strftime('%Y %b %d\n%H:%M:%S',utc)
        Audio.gcom2.utcdate=t[:12]
        Audio.gcom2.iyr=utc[0]
        Audio.gcom2.imo=utc[1]
        Audio.gcom2.ida=utc[2]
        Audio.gcom2.ihr=utc[3]
        Audio.gcom2.imi=utc[4]
        Audio.gcom2.isc=utc[5]
        ldate.configure(text=t)
        root_geom=root.geometry()
        utchours=utc[3]+utc[4]/60.0 + utc[5]/3600.0
        naz,nel,ndmiles,ndkm,nhotaz,nhotabetter=Audio.azdist0( \
            options.MyGrid.get().upper(),HisGrid.get().upper(),utchours)
        azdist()
        g.nfreq=nfreq.get()
        if tx1.get()[0:2]=='GO' and mode.get()=='Echo':
            try:
                nmin=int(tx1.get()[3:5])
            except:
                nmin=10
            if isec==0 and (utc[4]%nmin)==0 and lauto==0:
                toggleauto()
            if isec==4 and (utc[4]%nmin)==1 and lauto==1:
                toggleauto()
                Audio.gcom2.nsumecho=0

        if Audio.gcom2.ndecoding==0:
            g.AzSun,g.ElSun,g.AzMoon,g.ElMoon,g.AzMoonB,g.ElMoonB,g.ntsky, \
                g.ndop,g.ndop00,g.dbMoon,g.RAMoon,g.DecMoon,g.HA8,g.Dgrd,  \
                g.sd,g.poloffset,g.MaxNR,g.dfdt,g.dfdt0,g.RaAux,g.DecAux, \
                g.AzAux,g.ElAux = Audio.astro0(utc[0],utc[1],utc[2],  \
                utchours,nfreq.get(),options.MyGrid.get().upper(), \
                    options.auxra.get()+(' '*9)[:9],     \
                    options.auxdec.get()+(' '*9)[:9])

            if len(HisGrid.get().strip())<4:
                g.ndop=g.ndop00
                g.dfdt=g.dfdt0

        if mode.get()[:4]=='JT64' or mode.get()=='JT8' or mode.get()=='Echo':
            graph2.delete(ALL)
            graph2.create_text(80,13,anchor=CENTER,text="Moon",font=g2font)
            graph2.create_text(13,37,anchor=W, text="Az: %6.2f" % g.AzMoon,font=g2font)
            graph2.create_text(13,61,anchor=W, text="El: %6.2f" % g.ElMoon,font=g2font)
            graph2.create_text(13,85,anchor=W, text="Dop:%6d" % g.ndop,font=g2font)
            graph2.create_text(13,109,anchor=W,text="Dgrd:%5.1f" % g.Dgrd,font=g2font)

    if (mode.get()[:4]=='JT64' or mode.get()[:3]=='JT8' or \
        mode.get()[:5]=='ISCAT') and g.freeze_decode:
        itol=2
        ltol.configure(text='Tol    '+str(50))
        Audio.gcom2.dftolerance=50
        nfreeze.set(1)
        Audio.gcom2.nfreeze=1
        if Audio.gcom2.monitoring:
            Audio.gcom2.ndecoding=1
            Audio.gcom2.nagain=0
        else:
            Audio.gcom2.ndecoding=4
            Audio.gcom2.nagain=1
        g.freeze_decode=0

    n=-99
    g.rms=g.rms+0.001
    if g.rms > 0:
        n=int(20.0*log10(g.rms/770.0+0.01))
    else:
        print "RMS noise:", g.rms, " out of range."
    t="Rx noise:%3d dB" % (n,)
    if n>=-10 and n<=10:
        msg4.configure(text=t,bg='gray85')
    else:
        msg4.configure(text=t,bg='red')

    t=g.ftnstr(Audio.gcom2.decodedfile)
#    i=t.rfind(".")
    i=g.rfnd(t,".")
    t=t[:i]
    lab3.configure(text=t)
    if mode.get() != g.mode or first:
        if mode.get()=="JTMS":
            msg2.configure(bg='#FFFF00')
        elif mode.get()=="ISCAT":
            msg2.configure(bg='#FF00FF')
        elif mode.get()[:4]=="JT64":
            msg2.configure(bg='#00FFFF')
        elif mode.get()[:3]=="JT8":
            msg2.configure(bg='#88FF88')
        elif mode.get()=="Echo":
            msg2.configure(bg='#FF0000')
        if mode.get()[:3]=="JT8":
            options.b1.configure(state=DISABLED)
            options.b2.configure(state=DISABLED)
            options.b3.configure(state=DISABLED)
        else:
            options.b1.configure(state=NORMAL)
            options.b2.configure(state=NORMAL)
            options.b3.configure(state=NORMAL)
            
        g.mode=mode.get()
        t='Set ' + g.mode + ' defaults'
        options.g2.configure(tag_text=t)
        if first and mode.get()!='Echo' : GenStdMsgs()
        first=0

    samfac_in=Audio.gcom1.mfsample/120000.0
    samfac_out=Audio.gcom1.mfsample2/120000.0
    msg1.configure(text="%6.4f %6.4f" % (samfac_in,samfac_out))
    msg2.configure(text=mode.get())
    t="Freeze DF:%4d" % (int(Audio.gcom2.mousedf),)
    if abs(int(Audio.gcom2.mousedf))>400:
        msg3.configure(text=t,fg='black',bg='red')
    else:
        msg3.configure(text=t,fg='black',bg='gray85')    
    bdecode.configure(bg='gray85',activebackground='gray95')
    if (sys.platform == 'darwin'):
        bdecode.configure(text='Decode')
    if Audio.gcom2.ndecoding:       #Set button bg=light_blue while decoding
        bdecode.configure(bg='#66FFFF',activebackground='#66FFFF')
        if (sys.platform == 'darwin'):
           bdecode.configure(text='*Decode*')
    msg5.configure(text="TR Period: %d s" % (Audio.gcom1.trperiod,), \
                       bg='gray85')
    t="%d" % (int(Audio.gcom2.nbitsent),)
    msg6.configure(text=t)
    if isync>=0:
        lsync.configure(bg='white')
    else:
        lsync.configure(bg='red')

    tx1.configure(bg='white')
    tx2.configure(bg='white')
    tx3.configure(bg='white')
    tx4.configure(bg='white')
    tx5.configure(bg='white')
    if len(tx5.get())>14: tx5.configure(bg='pink')

    tx5.configure(bg='white')
    if tx5.get()[:1]=='#':
        try:
            rxsnrdb=float(tx5.get()[1:])
            if rxsnrdb>-99.0 and rxsnrdb<0.0:
                Audio.gcom1.rxsnrdb=rxsnrdb
                tx5.configure(bg='orange')
        except:
            rxsnrdb=0.0
    else:
        rxsnrdb=0.0
        Audio.gcom1.rxsnrdb=rxsnrdb

    tx6.configure(bg='white')
    if tx6.get()[:1]=='#':
        try:
            txsnrdb=float(tx6.get()[1:])
            if txsnrdb>-99.0 and txsnrdb<40.0:
                Audio.gcom1.txsnrdb=txsnrdb
                tx6.configure(bg='orange')
        except:
            txsnrdb=99.0
    else:
        txsnrdb=99.0
        Audio.gcom1.txsnrdb=txsnrdb
        
    if Audio.gcom2.monitoring and not Audio.gcom1.transmitting:
        bmonitor.configure(bg='green')
        if (sys.platform == 'darwin'):
           bmonitor.configure(text='*Monitor*')
    else:
        bmonitor.configure(bg='gray85')    
        if (sys.platform == 'darwin'):
           bmonitor.configure(text='Monitor')    
    if Audio.gcom1.transmitting:
        nmsg=int(Audio.gcom2.nmsg)
        t=g.ftnstr(Audio.gcom2.sending)
        if mode.get()=='Echo':
            t='ECHO TEST'
            nmsg=9
            Audio.gcom2.ntxnow=0
        t="Txing:  "+t[:nmsg]
        bgcolor='yellow'
        if Audio.gcom2.sendingsh==1:  bgcolor='#66FFFF'    #Shorthand (lt blue)
        if Audio.gcom2.sendingsh==-1: bgcolor='red'        #Plain Text
        if Audio.gcom2.sendingsh==2: bgcolor='pink'        #Test file
        if txsnrdb<90.0: bgcolor='orange'                  #Simulation mode
        if Audio.gcom2.ntxnow==1: tx1.configure(bg=bgcolor)
        elif Audio.gcom2.ntxnow==2: tx2.configure(bg=bgcolor)
        elif Audio.gcom2.ntxnow==3: tx3.configure(bg=bgcolor)
        elif Audio.gcom2.ntxnow==4: tx4.configure(bg=bgcolor)
        elif Audio.gcom2.ntxnow==5: tx5.configure(bg=bgcolor)
        elif Audio.gcom2.ntxnow==6: tx6.configure(bg=bgcolor)
    else:
        bgcolor='green'
        t='Receiving'
    msg7.configure(text=t,bg=bgcolor)

    if Audio.gcom2.ndecdone==1 or g.cmap != cmap0:
        if Audio.gcom2.ndecdone==1:
            if isync==-99 or isync==99:
                isync=isync_save
                Audio.gcom2.minsigdb=isync
            try:
                f=open(appdir+'/decoded.txt',mode='r')
                lines=f.readlines()
                f.close()
            except:
                lines=""
            text.configure(state=NORMAL)
            for i in range(len(lines)):
                text.insert(END,lines[i])
            text.see(END)
#            text.configure(state=DISABLED)

            if mode.get()[:4]=='JT64':
                try:
                    f=open(appdir+'/decoded.ave',mode='r')
                    lines=f.readlines()
                    f.close()
                except:
                    lines[0]=""
                    lines[1]=""
                avetext.configure(state=NORMAL)
                avetext.delete('1.0',END)
                if len(lines)>1:
                    avetext.insert(END,lines[0])
                    avetext.insert(END,lines[1])
#                avetext.configure(state=DISABLED)
            Audio.gcom2.ndecdone=2
        
        if g.cmap != cmap0:
            im.putpalette(g.palette)
            cmap0=g.cmap

        if mode.get()[:4]=='JT64' or mode.get()[:5]=='ISCAT' or \
               mode.get()[:3]=='JT8':
            plot_large()
        if mode.get()=='ISCAT' or mode.get()=='JTMS':
            plot_small()
        if mode.get()=='JTMS':
            im.putdata(Audio.gcom2.b)
            pim=ImageTk.PhotoImage(im)          #Convert Image to PhotoImage
            graph1.delete(ALL)
# NB: top two lines are probably invisible ...
            graph1.create_image(0,0,anchor='nw',image=pim)
            t=g.filetime(g.ftnstr(Audio.gcom2.decodedfile))
            graph1.create_text(100,80,anchor=W,text=t,fill="white")
        if loopall: opennext()
        nopen=0

# Save some parameters
    g.mode=mode.get()
    if mode.get()=='JTMS': isyncMS=isync
    elif mode.get()=='ISCAT': isync6m=isync
    elif mode.get()[:4]=='JT64': isync65=isync
    Audio.gcom1.txfirst=TxFirst.get()
    Audio.gcom2.mycall=(options.MyCall.get()+(' '*12))[:12]
    Audio.gcom2.hiscall=(ToRadio.get()+(' '*12))[:12]
    Audio.gcom2.hisgrid=(HisGrid.get()+(' '*6))[:6]
    Audio.gcom2.ntxreq=ntx.get()
    tx=(tx1,tx2,tx3,tx4,tx5,tx6)
    Audio.gcom2.txmsg=(tx[ntx.get()-1].get()+(' '*28))[:28]
    Audio.gcom2.mode=(mode.get()+(' '*6))[:6]
    Audio.gcom2.nsave=nsave.get()
    Audio.gcom2.ndebug=ndebug.get()
    Audio.gcom2.minsigdb=isync
    Audio.gcom2.nfreeze=nfreeze.get()
    Audio.gcom2.dftolerance=ntol[itol]
    Audio.gcom2.neme=neme.get()
    Audio.gcom2.ndepth=ndepth.get()
    if qdecode.get():
        Audio.gcom2.ntdecode=48
    else:
        Audio.gcom2.ntdecode=52

    try:
        Audio.gcom2.idinterval=options.IDinterval.get()
    except:
        Audio.gcom2.idinterval=0
#    Audio.gcom1.rxdelay=float('0'+options.RxDelay.get())
#    Audio.gcom1.txdelay=float('0'+options.TxDelay.get())
    Audio.gcom2.nslim2=isync-4

    port = options.PttPort.get()
    if port=='None': port='0'
    if port[:3]=='COM': port=port[3:]
    if port.isdigit():
        Audio.gcom2.nport = int(port)
        port = "COM%d" % (int(port))
    else:
        Audio.gcom2.nport = 0
    Audio.gcom2.pttport = (port + 80*' ')[:80]

    try:
        Audio.gcom2.ntc=options.ntc.get()
        Audio.gcom2.necho=options.necho.get()
        Audio.gcom2.nfrit=options.fRIT.get()
        Audio.gcom2.ndither=options.dither.get()
        Audio.gcom2.dlatency=options.dlatency.get()
    except:
        pass

    if g.ndevin.get()!= nin0 or g.ndevout.get()!=nout0:
        audio_config()
        nin0=g.ndevin.get()
        nout0=g.ndevout.get()
##    if options.inbad.get()==0:
##        msg2.configure(text='',bg='gray85')
##    else:
##        msg2.configure(text='Invalid audio input device.',bg='red')
##    if options.outbad.get()==0:
##        msg3.configure(text='',bg='gray85')
##    else:
##        msg3.configure(text='Invalid audio output device.',bg='red')    

    if altmsg: tx6alt=tx6.get()
# Queue up the next update
    ldate.after(100,update)

#------------------------------------------------------ audio_config
def audio_config():
    inbad,outbad=Audio.audiodev(g.ndevin.get(),g.ndevout.get())
    options.inbad.set(inbad)
    options.outbad.set(outbad)
    if inbad or outbad:
        Audio.gcom2.ndevsok=0
        options1()
    else:
        Audio.gcom2.ndevsok=1
    
#------------------------------------------------------ Top level frame
frame = Frame(root)

#------------------------------------------------------ Menu Bar
if (sys.platform != 'darwin'):
   mbar = Frame(frame)
   mbar.pack(fill = X)
else:
   mbar = Menu(root)
   root.config(menu=mbar)

#------------------------------------------------------ File Menu
filebutton = Menubutton(mbar, text = 'File')
filebutton.pack(side = LEFT)
filemenu = Menu(filebutton)
filebutton['menu'] = filemenu
filemenu.add('command', label = 'Open', command = openfile, \
             accelerator='Ctrl+O')
filemenu.add('command', label = 'Open next in directory', command = opennext, \
             accelerator='F6')
filemenu.add('command', label = 'Decode remaining files in directory', \
             command = decodeall, accelerator='Shift+F6')
filemenu.add_separator()
filemenu.add('command', label = 'Delete all *.WAV files in RxWav', \
             command = delwav)
filemenu.add_separator()
filemenu.add('command', label = 'Erase ALL.TXT', command = del_all)
filemenu.add_separator()
filemenu.add('command', label = 'Exit', command = quit, accelerator='Alt+F4')

if (sys.platform == 'darwin'):
    mbar.add_cascade(label="File", menu=filemenu)

#------------------------------------------------------ Setup menu
setupbutton = Menubutton(mbar, text = 'Setup')
setupbutton.pack(side = LEFT)
setupmenu = Menu(setupbutton)
setupbutton['menu'] = setupmenu
setupmenu.add('command', label = 'Options', command = options1, \
              accelerator='F2')
setupmenu.add_separator()
setupmenu.add('command', label = 'Toggle size of text window', command=textsize)
setupmenu.add('command', label = 'Generate messages for test tones', command=testmsgs)
setupmenu.add_separator()
setupmenu.add_checkbutton(label = 'F4 sets Tx6',variable=kb8rq)
setupmenu.add_checkbutton(label = 'Double-click on callsign sets TxFirst',
                          variable=setseq)
setupmenu.add_checkbutton(label = 'GenStdMsgs sets Tx1',variable=k2txb)
setupmenu.add_separator()
setupmenu.add_checkbutton(label = 'Enable diagnostics',variable=ndebug)

if (sys.platform == 'darwin'):
    mbar.add_cascade(label="Setup", menu=setupmenu)

#------------------------------------------------------ View menu
viewbutton=Menubutton(mbar,text='View')
viewbutton.pack(side=LEFT)
viewmenu=Menu(viewbutton)
viewbutton['menu']=viewmenu
viewmenu.add('command', label = 'SpecJT', command = showspecjt, \
             accelerator='F10')
viewmenu.add('command', label = 'Astronomical data', command = astro1, \
             accelerator='Shift+F10')

if (sys.platform == 'darwin'):
    mbar.add_cascade(label="View", menu=viewmenu)

#------------------------------------------------------ Mode menu
modebutton = Menubutton(mbar, text = 'Mode')
modebutton.pack(side = LEFT)
modemenu = Menu(modebutton)
modebutton['menu'] = modemenu

# To enable menu item 0:
# modemenu.entryconfig(0,state=NORMAL)
# Can use the following to retrieve the state:
# state=modemenu.entrycget(0,"state")

if (sys.platform=='darwin') :
    # accelerators break radiobutton behaviour in Darwin
    modemenu.add_radiobutton(label = 'JTMS', variable=mode,command = ModeJTMS, state=NORMAL)
    modemenu.add_radiobutton(label = 'ISCAT', variable=mode, command = ModeISCAT)
    modemenu.add_radiobutton(label = 'JT64A', variable=mode, command = ModeJT64A)
else:
    modemenu.add_radiobutton(label = 'JTMS', variable=mode,command = ModeJTMS, state=NORMAL, accelerator='F7')
    modemenu.add_radiobutton(label = 'ISCAT', variable=mode, command = ModeISCAT,accelerator='Shift+F7')
    modemenu.add_radiobutton(label = 'JT64A', variable=mode, command = ModeJT64A,accelerator='F8')

modemenu.add_radiobutton(label = 'JT8', variable=mode, command = ModeJT8)
modemenu.add_radiobutton(label = 'Echo', variable=mode, command = ModeEcho)

if (sys.platform == 'darwin'):
    mbar.add_cascade(label="Mode", menu=modemenu)

#------------------------------------------------------ Decode menu
decodebutton = Menubutton(mbar, text = 'Decode')
decodebutton.pack(side = LEFT)
decodemenu = Menu(decodebutton)
decodebutton['menu'] = decodemenu
decodemenu.JTMS=Menu(decodemenu)
decodemenu.JTMS.add_radiobutton(label = 'Normal',
                                variable=ndepth, value=1)
decodemenu.JTMS.add_radiobutton(label = 'Aggressive',
                                variable=ndepth, value=2)

decodemenu.add_cascade(label = 'JTMS',menu=decodemenu.JTMS)

if (sys.platform == 'darwin'):
    mbar.add_cascade(label="Decode", menu=decodemenu)

#------------------------------------------------------ Save menu
savebutton = Menubutton(mbar, text = 'Save')
savebutton.pack(side = LEFT)
savemenu = Menu(savebutton)
savebutton['menu'] = savemenu
nsave=IntVar()
savemenu.add_radiobutton(label = 'None', variable=nsave,value=0)
savemenu.add_radiobutton(label = 'Save decoded', variable=nsave,value=1)
savemenu.add_radiobutton(label = 'Save if Auto On', variable=nsave,value=2)
savemenu.add_radiobutton(label = 'Save all', variable=nsave,value=3)
nsave.set(0)

if (sys.platform == 'darwin'):
    mbar.add_cascade(label="Save", menu=savemenu)

#------------------------------------------------------ Band menu
bandbutton = Menubutton(mbar, text = 'Band')
bandbutton.pack(side = LEFT)
bandmenu = Menu(bandbutton)
bandbutton['menu'] = bandmenu
nfreq=IntVar()
bandmenu.add_radiobutton(label = '1.8', variable=nfreq,value=2)
bandmenu.add_radiobutton(label = '3.5', variable=nfreq,value=4)
bandmenu.add_radiobutton(label = '7', variable=nfreq,value=7)
bandmenu.add_radiobutton(label = '10', variable=nfreq,value=10)
bandmenu.add_radiobutton(label = '14', variable=nfreq,value=14)
bandmenu.add_radiobutton(label = '18', variable=nfreq,value=18)
bandmenu.add_radiobutton(label = '21', variable=nfreq,value=21)
bandmenu.add_radiobutton(label = '24', variable=nfreq,value=24)
bandmenu.add_radiobutton(label = '28', variable=nfreq,value=28)
bandmenu.add_radiobutton(label = '50', variable=nfreq,value=50)
bandmenu.add_radiobutton(label = '144', variable=nfreq,value=144)
bandmenu.add_radiobutton(label = '222', variable=nfreq,value=222)
bandmenu.add_radiobutton(label = '432', variable=nfreq,value=432)
bandmenu.add_radiobutton(label = '1296', variable=nfreq,value=1296)
bandmenu.add_radiobutton(label = '2304', variable=nfreq,value=2304)
bandmenu.add_radiobutton(label = '3456', variable=nfreq,value=3456)
bandmenu.add_radiobutton(label = '5760', variable=nfreq,value=5760)
bandmenu.add_radiobutton(label = '10368', variable=nfreq,value=10368)
nfreq.set(144)

if (sys.platform == 'darwin'):
    mbar.add_cascade(label="Band", menu=bandmenu)

#------------------------------------------------------ Help menu
helpbutton = Menubutton(mbar, text = 'Help')
helpbutton.pack(side = LEFT)
helpmenu = Menu(helpbutton)
helpbutton['menu'] = helpmenu
helpmenu.add('command', label = 'Keyboard shortcuts', command = shortcuts, \
             accelerator='F1')
helpmenu.add('command', label = 'Special mouse commands', \
             command = mouse_commands, accelerator='Shift+F1')
helpmenu.add('command', label = 'What message to send?', \
             command = what2send, accelerator='F5')
helpmenu.add('command', label = 'Examples of minimal QSOs', \
             command = minimal_qso, accelerator='Shift+F5')
helpmenu.add('command', label = 'About WSJT', command = about, \
             accelerator='Ctrl+F1')

if (sys.platform == 'darwin'):
    mbar.add_cascade(label="Help", menu=helpmenu)

#------------------------------------------------------ Graphics areas
iframe1 = Frame(frame, bd=1, relief=SUNKEN)
graph1=Canvas(iframe1, bg='black', width=500, height=120,cursor='crosshair')
Widget.bind(graph1,"<Motion>",dtdf_change)
Widget.bind(graph1,"<Button-1>",mouse_click_g1)
Widget.bind(graph1,"<Double-Button-1>",double_click_g1)
Widget.bind(graph1,"<ButtonRelease-1>",mouse_up_g1)
Widget.bind(graph1,"<Button-3>",mouse_click_g1)
graph1.pack(side=LEFT)
graph2=Canvas(iframe1, bg='black', width=150, height=120,cursor='crosshair')
graph2.pack(side=LEFT)
##g2font=graph2.option_get("font","font")
g2font=("Lucida Console",16)
if g2font!="": g.g2font=g2font
iframe1.pack(expand=1, fill=X, padx=4)

#------------------------------------------------------ Labels under graphics
iframe2a = Frame(frame, bd=1, relief=FLAT, height=15)
lab1=Label(iframe2a, text='Time (s)')
lab1.place(x=250, y=6, anchor=CENTER)
lab3=Label(iframe2a, text=' ')
lab3.place(x=400,y=6, anchor=CENTER)
lab4=Label(iframe2a, text='1             2            3')
lab4.place(x=593,y=6, anchor=CENTER)
iframe2a.pack(expand=1, fill=X, padx=1)
iframe2 = Frame(frame, bd=1, relief=FLAT,height=15)
lab2=Label(iframe2, text='FileID     Sync     dB        DT        DF      W')
lab2.place(x=3,y=6, anchor='w')
lab5=Label(iframe2, text='Freq (kHz)')
lab5.place(x=580,y=6, anchor=CENTER)
lab6=Label(iframe2a,text='0.0',bg='green')
lab6.place(x=40,y=6, anchor=CENTER)
lab7=Label(iframe2a,text='F3',fg='gray85')
lab7.place(x=495,y=6, anchor=CENTER)
lab8=Label(iframe2a,text='1.0000  1.0000',fg='gray85')
lab8.place(x=135,y=6, anchor=CENTER)
iframe2.pack(expand=1, fill=X, padx=4)

#-------------------------------------------------------- Decoded text
iframe4 = Frame(frame, bd=1, relief=SUNKEN)
text=Text(iframe4, height=6, width=80)
text.bind('<Double-Button-1>',dbl_click_text)
text.bind('<Double-Button-3>',dbl_click3_text)
text.bind('<Key>',textkey)

root.bind_all('<F1>', shortcuts)
root.bind_all('<Shift-F1>', mouse_commands)
root.bind_all('<Control-F1>', about)
root.bind_all('<F2>', options1)
root.bind_all('<F3>', txmute)
root.bind_all('<F4>', clrToRadio)
root.bind_all('<Alt-F4>', quit)
root.bind_all('<F5>', what2send)
root.bind_all('<Shift-F5>', minimal_qso)
root.bind_all('<F6>', opennext)
root.bind_all('<Shift-F6>', decodeall)
root.bind_all('<F7>', ModeJTMS)
root.bind_all('<F8>', ModeJT64A)
#root.bind_all('<Shift-F8>', ModeJT65B)
#root.bind_all('<Control-F8>', ModeJT65C)
root.bind_all('<Shift-F7>', ModeISCAT)
#root.bind_all('<F9>', ModeEcho)
root.bind_all('<F10>', showspecjt)
root.bind_all('<Shift-F10>', astro1)
root.bind_all('<F11>', left_arrow)
root.bind_all('<F12>', right_arrow)


root.bind_all('<Alt-Key-1>',btx1)
root.bind_all('<Alt-Key-2>',btx2)
root.bind_all('<Alt-Key-3>',btx3)
root.bind_all('<Alt-Key-4>',btx4)
root.bind_all('<Alt-Key-5>',btx5)
root.bind_all('<Alt-Key-6>',btx6)

root.bind_all('<Alt-a>',toggleauto)
root.bind_all('<Alt-A>',toggleauto)
root.bind_all('<Alt-c>',clear_avg)
root.bind_all('<Alt-C>',clear_avg)
root.bind_all('<Alt-d>',decode)
root.bind_all('<Alt-D>',decode)
root.bind_all('<Control-d>',force_decode)
root.bind_all('<Control-D>',force_decode)
root.bind_all('<Alt-e>',erase)
root.bind_all('<Alt-E>',erase)
root.bind_all('<Alt-f>',toggle_freeze)
root.bind_all('<Alt-F>',toggle_freeze)
root.bind_all('<Alt-g>',GenStdMsgs)
root.bind_all('<Alt-G>',GenStdMsgs)
root.bind_all('<Control-g>', GenAltMsgs)
root.bind_all('<Control-G>', GenAltMsgs)
root.bind_all('<Alt-i>',decode_include)
root.bind_all('<Alt-I>',decode_include)
root.bind_all('<Alt-l>',lookup)
root.bind_all('<Alt-L>',lookup)
root.bind_all('<Alt-m>',monitor)
root.bind_all('<Alt-M>',monitor)
root.bind_all('<Alt-o>',txstop)
root.bind_all('<Alt-O>',txstop)
root.bind_all('<Control-o>',openfile)
root.bind_all('<Control-O>',openfile)
root.bind_all('<Alt-q>',logqso)
root.bind_all('<Alt-Q>',logqso)
root.bind_all('<Alt-s>',stopmon)
root.bind_all('<Alt-S>',stopmon)
root.bind_all('<Alt-v>',savelast)
root.bind_all('<Alt-V>',savelast)
root.bind_all('<Alt-x>',decode_exclude)
root.bind_all('<Alt-X>',decode_exclude)
root.bind_all('<Control-l>',lookup_gen)
root.bind_all('<Control-L>',lookup_gen)

text.pack(side=LEFT, fill=X, padx=1)
sb = Scrollbar(iframe4, orient=VERTICAL, command=text.yview)
sb.pack(side=RIGHT, fill=Y)
text.configure(yscrollcommand=sb.set)
iframe4.pack(expand=1, fill=X, padx=4)
iframe4b = Frame(frame, bd=1, relief=SUNKEN)
avetext=Text(iframe4b, height=2, width=80)
avetext.bind('<Double-Button-1>',dbl_click_ave)
avetext.bind('<Key>',avetextkey)
avetext.pack(side=LEFT, fill=X, padx=1)
iframe4b.pack(expand=1, fill=X, padx=4)

#------------------------------------------------------- Button Bar
iframe4c = Frame(frame, bd=1, relief=SUNKEN)
blogqso=Button(iframe4c, text='Log QSO',underline=4,command=logqso,
                padx=1,pady=1)
bstop=Button(iframe4c, text='Stop',underline=0,command=stopmon,
                padx=1,pady=1)
bmonitor=Button(iframe4c, text='Monitor',underline=0,command=monitor,
                padx=1,pady=1)
bsavelast=Button(iframe4c, text='Save',underline=2,command=savelast,
                padx=1,pady=1)
bdecode=Button(iframe4c, text='Decode',underline=0,command=decode,
                padx=1,pady=1)
berase=Button(iframe4c, text='Erase',underline=0,command=erase,
                padx=1,pady=1)
bclravg=Button(iframe4c, text='Clear Avg',underline=0,command=clear_avg,
                padx=1,pady=1)
binclude=Button(iframe4c, text='Include',underline=0,
                command=decode_include,padx=1,pady=1)
bexclude=Button(iframe4c, text='Exclude',underline=1,
                command=decode_exclude,padx=1,pady=1)
btxstop=Button(iframe4c,text='TxStop',underline=4,command=txstop,
                padx=1,pady=1)

blogqso.pack(side=LEFT,expand=1,fill=X)
#bplay.pack(side=LEFT,expand=1,fill=X)
bstop.pack(side=LEFT,expand=1,fill=X)
bmonitor.pack(side=LEFT,expand=1,fill=X)
bsavelast.pack(side=LEFT,expand=1,fill=X)
bdecode.pack(side=LEFT,expand=1,fill=X)
berase.pack(side=LEFT,expand=1,fill=X)
bclravg.pack(side=LEFT,expand=1,fill=X)
binclude.pack(side=LEFT,expand=1,fill=X)
bexclude.pack(side=LEFT,expand=1,fill=X)
btxstop.pack(side=LEFT,expand=1,fill=X)
iframe4c.pack(expand=1, fill=X, padx=4)

#-----------------------------------------------------General control area
iframe5 = Frame(frame, bd=1, relief=FLAT,height=180)

#------------------------------------------------------ "Other station" info
f5a=Frame(iframe5,height=170,bd=2,relief=GROOVE)
labToRadio=Label(f5a,text='To radio:', width=9, relief=FLAT)
labToRadio.grid(column=0,row=0)
ToRadio=Entry(f5a,width=9)
ToRadio.insert(0,'W8WN')
ToRadio.grid(column=1,row=0,pady=3)
bLookup=Button(f5a, text='Lookup',underline=0,command=lookup,padx=1,pady=1)
bLookup.grid(column=2,row=0,sticky='EW',padx=4)
labGrid=Label(f5a,text='Grid:', width=9, relief=FLAT)
labGrid.grid(column=0,row=1)
HisGrid=Entry(f5a,width=9)
HisGrid.grid(column=1,row=1,pady=1)
bAdd=Button(f5a, text='Add',command=addtodb,padx=1,pady=1)
bAdd.grid(column=2,row=1,sticky='EW',padx=4)
labAz=Label(f5a,text='Az 257  El 15',width=11)
labAz.grid(column=1,row=2)
labHotAB=Label(f5a,bg='#FFCCFF',text='HotA: 247')
labHotAB.grid(column=0,row=2,sticky='EW',padx=4,pady=3)
labDist=Label(f5a,text='16753 km')
labDist.grid(column=2,row=2)

#------------------------------------------------------ Date and Time
ldate=Label(f5a, bg='black', fg='yellow', width=11, bd=4,
        text='2005 Apr 22\n01:23:45', relief=RIDGE,
        justify=CENTER, font=(font1,16))
ldate.grid(column=0,columnspan=3,row=3,rowspan=2,pady=2)
f5a.pack(side=LEFT,expand=1,fill=BOTH)

#------------------------------------------------------ Receiving parameters
f5b=Frame(iframe5,bd=2,relief=GROOVE)
lsync=Label(f5b, bg='white', fg='black', text='Sync   1', width=8, relief=RIDGE)
lsync.grid(column=0,row=0,padx=2,pady=1,sticky='EW')
Widget.bind(lsync,'<Button-1>',incsync)
Widget.bind(lsync,'<Button-3>',decsync)
cbfreeze=Checkbutton(f5b,text='Freeze',underline=0,variable=nfreeze)
cbfreeze.grid(column=1,row=2,padx=2,sticky='W')
ltol=Label(f5b, bg='white', fg='black', text='Tol    400', width=8, relief=RIDGE)
ltol.grid(column=0,row=2,padx=2,pady=1,sticky='EW')
Widget.bind(ltol,'<Button-1>',inctol)
Widget.bind(ltol,'<Button-3>',dectol)
ldsec=Label(f5b, bg='white', fg='black', text='Dsec  0.0', width=8, relief=RIDGE)
ldsec.grid(column=0,row=4,ipadx=3,padx=2,pady=5,sticky='EW')
Widget.bind(ldsec,'<Button-1>',incdsec)
Widget.bind(ldsec,'<Button-3>',decdsec)

f5b.pack(side=LEFT,expand=0,fill=BOTH)

#------------------------------------------------------ Tx params and msgs
f5c=Frame(iframe5,bd=2,relief=GROOVE)
txfirst=Checkbutton(f5c,text='Tx First',justify=RIGHT,variable=TxFirst)
f5c2=Frame(f5c,bd=0)
btxdf=Button(f5c,text='TxDF = 0',command=toggletxdf,
            padx=1,pady=1)
genmsg=Button(f5c,text='GenStdMsgs',underline=0,command=GenStdMsgs,
            padx=1,pady=1)
auto=Button(f5c,text='Auto is Off',underline=0,command=toggleauto,
            padx=1,pady=1)
auto.focus_set()

txfirst.grid(column=0,row=0,sticky='W',padx=4)
f5c2.grid(column=0,row=1,sticky='W',padx=4)
btxdf.grid(column=0,row=3,sticky='EW',padx=4)
genmsg.grid(column=0,row=4,sticky='W',padx=4)
auto.grid(column=0,row=5,sticky='EW',padx=4)
#txstop.grid(column=0,row=6,sticky='EW',padx=4)

ntx=IntVar()
tx1=Entry(f5c,width=24)
rb1=Radiobutton(f5c,value=1,variable=ntx)
b1=Button(f5c, text='Tx1',underline=2,command=btx1,padx=1,pady=1)
tx1.grid(column=1,row=0)
rb1.grid(column=2,row=0)
b1.grid(column=3,row=0)

tx2=Entry(f5c,width=24)
rb2=Radiobutton(f5c,value=2,variable=ntx)
b2=Button(f5c, text='Tx2',underline=2,command=btx2,padx=1,pady=1)
tx2.grid(column=1,row=1)
rb2.grid(column=2,row=1)
b2.grid(column=3,row=1)

tx3=Entry(f5c,width=24)
rb3=Radiobutton(f5c,value=3,variable=ntx)
b3=Button(f5c, text='Tx3',underline=2,command=btx3,padx=1,pady=1)
tx3.grid(column=1,row=2)
rb3.grid(column=2,row=2)
b3.grid(column=3,row=2)

tx4=Entry(f5c,width=24)
rb4=Radiobutton(f5c,value=4,variable=ntx)
b4=Button(f5c, text='Tx4',underline=2,command=btx4,padx=1,pady=1)
tx4.grid(column=1,row=3)
rb4.grid(column=2,row=3)
b4.grid(column=3,row=3)

tx5=Entry(f5c,width=24)
rb5=Radiobutton(f5c,value=5,variable=ntx)
b5=Button(f5c, text='Tx5',underline=2,command=btx5,padx=1,pady=1)
tx5.grid(column=1,row=4)
rb5.grid(column=2,row=4)
b5.grid(column=3,row=4)

tx6=Entry(f5c,width=24)
rb6=Radiobutton(f5c,value=6,variable=ntx)
b6=Button(f5c, text='Tx6',underline=2,command=btx6,padx=1,pady=1)
tx6.grid(column=1,row=5)
rb6.grid(column=2,row=5)
b6.grid(column=3,row=5)

f5c.pack(side=LEFT,fill=BOTH)
iframe5.pack(expand=1, fill=X, padx=4)

#------------------------------------------------------------ Status Bar
iframe6 = Frame(frame, bd=1, relief=SUNKEN)
msg1=Message(iframe6, text='                    ', width=300,relief=SUNKEN)
msg1.pack(side=LEFT, fill=X, padx=1)
msg2=Message(iframe6, text='Message #2', width=300,relief=SUNKEN)
msg2.pack(side=LEFT, fill=X, padx=1)
msg3=Message(iframe6,width=300,relief=SUNKEN)
msg3.pack(side=LEFT, fill=X, padx=1)
msg4=Message(iframe6, text='Message #4', width=300,relief=SUNKEN)
msg4.pack(side=LEFT, fill=X, padx=1)
msg5=Message(iframe6, text='Message #5', width=300,relief=SUNKEN)
msg5.pack(side=LEFT, fill=X, padx=1)
msg6=Message(iframe6, text='', width=300,relief=SUNKEN)
msg6.pack(side=LEFT, fill=X, padx=1)
Widget.bind(msg5,'<Button-1>',inctrperiod)
Widget.bind(msg5,'<Button-3>',dectrperiod)
msg7=Message(iframe6, text='                        ', width=300,relief=SUNKEN)
msg7.pack(side=RIGHT, fill=X, padx=1)
iframe6.pack(expand=1, fill=X, padx=4)
frame.pack()

lauto=0
isync=1
ntx.set(1)
ndepth.set(0)
ModeJTMS()
lookup()
balloon.unbind(ToRadio)
g.astro_geom0="+25+25"
Audio.gcom1.mute=0
Audio.gcom2.nforce=1
Audio.gcom2.mode4=1

#---------------------------------------------------------- Process INI file
try:
    f=open(appdir+'/WSJT.INI',mode='r')
    params=f.readlines()
except:
    params=""
    if g.Win32:
        options.PttPort.set("0")
    else:
        options.PttPort.set("/dev/ttyS0")
    Audio.gcom2.nport=0

try:
    for i in range(len(params)):
        key,value=params[i].split()
        if   key == 'WSJTGeometry': root.geometry(value)
        elif key == 'Mode':
            mode.set(value)
            if value=='JTMS':
                ModeJTMS()
            elif value=='ISCAT':
                ModeISCAT()
            elif value=='JT64A':
                ModeJT64A()
            elif value[:3]=='JT8':
                ModeJT8()
            elif value[:4]=='Echo':
                ModeEcho()
        elif key == 'MyCall': options.MyCall.set(value)
        elif key == 'MyGrid': options.MyGrid.set(value)
        elif key == 'HisCall':
            hiscall=value
            if hiscall=="______": hiscall=""
            ToRadio.delete(0,END)
            ToRadio.insert(0,hiscall)
        elif key == 'HisGrid':
            hisgrid=value
            if hisgrid == "XX00xx":
                lookup()
            HisGrid.delete(0,END)
            HisGrid.insert(0,hisgrid)
#        elif key == 'RxDelay': options.RxDelay.set(value)
#        elif key == 'TxDelay': options.TxDelay.set(value)
        elif key == 'IDinterval': options.IDinterval.set(value)
        elif key == 'PttPort':
            try:
                options.PttPort.set(value)
                try:
                    Audio.gcom2.nport=int(options.PttPort.get())
                except:
                    Audio.gcom2.nport=0
            except:
                if g.Win32:
                    options.PttPort.set("0")
                else:
                    options.PttPort.set("/dev/ttyS0")
                Audio.gcom2.nport=0
            Audio.gcom2.pttport=(options.PttPort.get()+(' '*80))[:80]
        elif key == 'Mileskm': options.mileskm.set(value)
        elif key == 'MsgStyle': options.itype.set(value)
        
##        elif key == 'AudioIn':
##            try:
##                g.ndevin.set(value)
##            except:
##                g.ndevin.set(0)
##            g.DevinName.set(value)
##            options.DevinName.set(value)
##            Audio.gcom1.devin_name=(options.DevinName.get()+(' '*12))[:12]
##        elif key == 'AudioOut':
##            try:
##                g.ndevout.set(value)
##            except:
##                g.ndevout.set(0)
##            g.DevoutName.set(value)
##            options.DevoutName.set(value)
##            Audio.gcom1.devout_name=(options.DevoutName.get()+(' '*12))[:12]

        elif key == 'AudioIn':
            value=value.replace("#"," ")
            g.DevinName.set(value)
            try:
                g.ndevin.set(int(value[:2]))
            except:
                g.ndevin.set(0)
            options.DevinName.set(value)


        elif key == 'AudioOut':
            value=value.replace("#"," ")
            g.DevoutName.set(value)
            try:
                g.ndevout.set(int(value[:2]))
            except:
                g.ndevout.set(0)
            options.DevoutName.set(value)

        elif key == 'Template1': options.Template1.set(value.replace("_"," "))
        elif key == 'Template2': options.Template2.set(value.replace("_"," "))
        elif key == 'Template3': options.Template3.set(value.replace("_"," "))
        elif key == 'Template4': options.Template4.set(value.replace("_"," "))
        elif key == 'Template5': options.Template5.set(value.replace("_"," "))
        elif key == 'Template6':
            options.Template6.set(value.replace("_"," "))
            if options.Template6.get()==" ": options.Template6.set("")
        elif key == 'AuxRA': options.auxra.set(value)
        elif key == 'AuxDEC': options.auxdec.set(value)
        elif key == 'AzElDir':
	    options.azeldir.set(value.replace("#"," "))
            try:
		os.stat(options.azeldir.get())
	    except:
		options.azeldir.set(os.getcwd())
        elif key == 'Ntc': options.ntc.set(value)
        elif key == 'Necho': options.necho.set(value)
        elif key == 'fRIT': options.fRIT.set(value)
        elif key == 'Dither': options.dither.set(value)
        elif key == 'Dlatency': options.dlatency.set(value)
        elif key == 'TxFirst': TxFirst.set(value)
        elif key == 'KB8RQ': kb8rq.set(value)
        elif key == 'K2TXB': k2txb.set(value)
        elif key == 'SetSeq': setseq.set(value)
        elif key == 'Nsave': nsave.set(value)
        elif key == 'Band': nfreq.set(value)
        elif key == 'SyncMS': isyncMS=int(value)
        elif key == 'S6m': isync6m=int(value)
        elif key == 'Sync': isync65=int(value)
        elif key == 'QDecode': qdecode.set(value)
        elif key == 'NEME': neme.set(value)
        elif key == 'NDepth': ndepth.set(value)
        elif key == 'Debug': ndebug.set(value)
        elif key == 'HisCall':
            Audio.gcom2.hiscall=(value+' '*12)[:12]
            ToRadio.delete(0,99)
            ToRadio.insert(0,value)
            lookup()                       #Maybe should save HisGrid, instead?
        elif key == 'MRUDir': mrudir=value.replace("#"," ")
        elif key == 'AstroGeometry': g.astro_geom0 =value
        else:
            pass
except:
    print 'Error reading WSJT.INI, continuing with defaults.'
    print key,value

g.mode=mode.get()
if mode.get()=='JTMS': isync=isyncMS
elif mode.get()=='ISCAT': isync=isync6m
elif mode.get()[:4]=='JT64': isync=isync65
lsync.configure(text=slabel+str(isync))
Audio.gcom2.azeldir=(options.azeldir.get()+' '*80)[:80]
Audio.gcom2.ndepth=ndepth.get()
Audio.gcom2.nxa=0
Audio.gcom2.nxb=0
stopmon()
if g.Win32: root.iconbitmap("wsjt.ico")
root.title('  WSJT 8     by K1JT')
from WsjtMod import astro
ldate.after(100,update)

from WsjtMod import specjt

# SpecJT has a "mainloop", so does not return until it is terminated.
#root.mainloop()   #Superseded by mainloop in SpecJT

# Clean up and save user options before terminating
f=open(appdir+'/WSJT.INI',mode='a')
root_geom=root_geom[root_geom.index("+"):]
f.write("WSJTGeometry " + root_geom + "\n")
f.write("Mode " + g.mode + "\n")
f.write("MyCall " + options.MyCall.get() + "\n")
f.write("MyGrid " + options.MyGrid.get() + "\n")
t=g.ftnstr(Audio.gcom2.hiscall)
if t[:1]==" ": t="______"
f.write("HisCall " + t + "\n")
t=g.ftnstr(Audio.gcom2.hisgrid)
if t=="      ": t="XX00xx"
f.write("HisGrid " + t + "\n")
#f.write("RxDelay " + str(options.RxDelay.get()) + "\n")
#f.write("TxDelay " + str(options.TxDelay.get()) + "\n")
f.write("IDinterval " + str(options.IDinterval.get()) + "\n")
f.write("PttPort " + str(options.PttPort.get()) + "\n")
f.write("Mileskm " + str(options.mileskm.get()) + "\n")
f.write("MsgStyle " + str(options.itype.get()) + "\n")
if options.DevinName.get()=='': options.DevinName.set('0')
f.write("AudioIn "  + options.DevinName.get().replace(" ","#") + "\n")
if options.DevoutName.get()=='': options.DevoutName.set('2')
f.write("AudioOut " + options.DevoutName.get().replace(" ","#") + "\n")
if options.Template6.get()=="": options.Template6.set("_")
f.write("Template1 " + options.Template1.get().replace(" ","_") + "\n")
f.write("Template2 " + options.Template2.get().replace(" ","_") + "\n")
f.write("Template3 " + options.Template3.get().replace(" ","_") + "\n")
f.write("Template4 " + options.Template4.get().replace(" ","_") + "\n")
f.write("Template5 " + options.Template5.get().replace(" ","_") + "\n")
f.write("Template6 " + options.Template6.get().replace(" ","_") + "\n")
if options.auxra.get()=="": options.auxra.set("0")
if options.auxdec.get()=="": options.auxdec.set("0")
f.write("AuxRA " + options.auxra.get() + "\n")
f.write("AuxDEC " + options.auxdec.get() + "\n")
f.write("AzElDir " + str(options.azeldir.get()).replace(" ","#") + "\n")
f.write("Ntc " + str(options.ntc.get()) + "\n")
f.write("Necho " + str(options.necho.get()) + "\n")
f.write("fRIT " + str(options.fRIT.get()) + "\n")
f.write("Dither " + str(options.dither.get()) + "\n")
f.write("Dlatency " + str(options.dlatency.get()) + "\n")
f.write("TxFirst " + str(TxFirst.get()) + "\n")
f.write("KB8RQ " + str(kb8rq.get()) + "\n")
f.write("K2TXB " + str(k2txb.get()) + "\n")
f.write("SetSeq " + str(setseq.get()) + "\n")
f.write("Report " + g.report + "\n")
f.write("Nsave " + str(nsave.get()) + "\n")
f.write("Band " + str(nfreq.get()) + "\n")
f.write("SyncMS " + str(isyncMS) + "\n")
f.write("S6m " + str(isync6m) + "\n")
f.write("Sync " + str(isync65) + "\n")
f.write("QDecode " + str(qdecode.get()) + "\n")
f.write("NEME " + str(neme.get()) + "\n")
f.write("NDepth " + str(ndepth.get()) + "\n")
f.write("Debug " + str(ndebug.get()) + "\n")
#f.write("TRPeriod " + str(Audio.gcom1.trperiod) + "\n")
mrudir2=mrudir.replace(" ","#")
f.write("MRUDir " + mrudir2 + "\n")
if g.astro_geom[:7]=="200x200": g.astro_geom="316x373" + g.astro_geom[7:]
f.write("AstroGeometry " + g.astro_geom + "\n")
f.write("CWTRPeriod " + str(ncwtrperiod) + "\n")
f.close()

Audio.ftn_quit()
Audio.gcom1.ngo=0                         #Terminate audio streams
Audio.gcom2.lauto=0
Audio.gcom1.txok=0
time.sleep(0.5)
