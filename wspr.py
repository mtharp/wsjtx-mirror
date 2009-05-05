#---------------------------------------------------------------------- WSPR
# $Date: 2008-03-17 08:29:04 -0400 (Mon, 17 Mar 2008) $ $Revision$
#
from Tkinter import *
from tkFileDialog import *
import tkMessageBox
import os,time,sys
from WsprMod import g,Pmw
from WsprMod import palettes
from math import log10
try:
    from numpy.oldnumeric import zeros
except: 
    from Numeric import zeros
import array
import dircache
import Image, ImageTk, ImageDraw
from WsprMod.palettes import colormapblue, colormapgray0, colormapHot, \
     colormapAFMHot, colormapgray1, colormapLinrad, Colormap2Palette
from types import *
import array
import random
import math
import string
from WsprMod import w
import socket
import urllib
import thread

root = Tk()
Version="1.12_r" + "$Rev$"[6:-1]
print "******************************************************************"
print "WSPR Version " + Version + ", by K1JT"
##print "Revision date: " + \
##      "$Date: 2008-03-17 08:29:04 -0400 (Mon, 17 Mar 2008) $"[7:-1]
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
from WsprMod import options


#------------------------------------------------------ Global variables
appdir=os.getcwd()
bandmap=[]
bm={}
f0=DoubleVar()
ftx=DoubleVar()
ftx0=0.
ft=[]
fileopened=""
fmid=0.0
fmid0=0.0
font1='Helvetica'
iband=IntVar()
iband0=0
idsec=0
ipctx=IntVar()
isec0=0
isync=1
loopall=0
modpixmap0=0
mrudir=os.getcwd()
ndbm0=-999
ncall=0
ndebug=IntVar()
newdat=1
newspec=1
npal=IntVar()
npal.set(2)
nsave=IntVar()
nscroll=0
nsec0=0
nspeed0=IntVar()
ntr0=0
ntest=IntVar()
ntxfirst=IntVar()
NX=500
NY=160
param20=""
pctx=[-1,0,10,20,25,33,100]
sf0=StringVar()
sftx=StringVar()
txmsg=StringVar()

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
upload=IntVar()

g.appdir=appdir
g.cmap="Linrad"
g.cmap0="Linrad"
g.ndevin=IntVar()
g.ndevout=IntVar()
g.DevinName=StringVar()
g.DevoutName=StringVar()

pwrlist=(0,3,7,10,13,17,20,23,27,30,33,37,40,43,47,50,53,57,60)
freq0=[0,1.8366,3.5926,5.3305,7.0386,10.1387,14.0956,18.1046,21.0946,24.9246,\
       28.1246,50.2930,5.3305]
freqtx=[0,1.8366,3.5926,5.3305,7.0386,10.1387,14.0956,18.1046,21.0946,24.9246,\
       28.1246,50.2930,5.3305]
for i in range(13):
    freqtx[i]=freq0[i]+0.001500

socktimeout = 10
socket.setdefaulttimeout(socktimeout)

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
def quit(event=NONE):
    root.destroy()

#------------------------------------------------------ openfile
def openfile(event=NONE):
    global mrudir,fileopened,nopen,tw
    nopen=1                         #Work-around for "click feedthrough" bug
    upload.set(0)
    try:
        os.chdir(mrudir)
    except:
        pass
    fname=askopenfilename(filetypes=[("Wave files","*.wav *.WAV")])
    if fname:
        w.getfile(fname,len(fname))
        mrudir=os.path.dirname(fname)
        fileopened=os.path.basename(fname)
        i1=fileopened.find('.')
        t=fileopened[i1-4:i1]
        t=t[0:2] + ':' + t[2:4]
        n=len(tw)
        if n>12: tw=tw[:n-1]
        tw=[t,] + tw
    os.chdir(appdir)
    ipctx.set(0)

#------------------------------------------------------ stop_loopall
def stop_loopall(event=NONE):
    global loopall
    loopall=0
    
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
            result=tkMessageBox.showwarning(message=t)
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
    result=tkMessageBox.showwarning(message=t)

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
a digital soundcard mode optimized for beacon-like transmissions
on the LF, MF, and HF bands.

Copyright (c) 2008 by Joseph H. Taylor, Jr., K1JT.
"""
    Label(about,text=t,justify=LEFT).pack(padx=20)
##    t="Revision date: " + \
##      "$Date: 2008-03-17 08:29:04 -0400 (Mon, 17 Mar 2008) $"[7:-1]
##    Label(about,text=t,justify=LEFT).pack(padx=20)
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
   Audio In and Audio Out (see console window for a list
   of available devices).

2. Select the desired band from the Band menu and optionally
   enter your USB dial frequency and/or Tx frequency on the
   main screen.  You can also select a Tx frequency by
   double-clicking on the waterfall display.

3. Click on 'Rx' to receive only, 'Tx' to transmit only, or
   the desired average percentage of transmission cycles.

4. Be sure that your computer clock is correct to +/- 1 s. If
   necessary you can make small adjustments by left- or right-
   clicking on the 'Dsec' label.

5. The program will begin a Tx or Rx sequence at the start of
    each even minute.  The waterfall will update and decoding
    will take place at the end of each Rx sequence.  During
    reception, you can adjust the Rx noise level to get
    something close to 0 dB.  Use Setup -> Rx volume control
    or change your receiver's output level.
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
    global bandmap,bm
    text.configure(state=NORMAL)
    text.delete('1.0',END)
    text.configure(state=DISABLED)
    text1.configure(state=NORMAL)
    text1.delete('1.0',END)
    text1.configure(state=DISABLED)
    bandmap=[]
    bm={}

#----------------------------------------------------- df_readout
# Readout of graphical cursor location
def df_readout(event):
    global fmid
    nhz=1000000*fmid + (80.0-event.y) * 12000/8192.0
    nhz=int(nhz%1000)
    t="%3d Hz" % nhz
    lab02.configure(text=t,bg='red')

#----------------------------------------------------- set_tx_freq
def set_tx_freq(event):
    global fmid
    nftx=int(1000000.0*fmid + (80.0-event.y) * 12000/8192.0)
    fmhz=0.000001*nftx
    t="Please confirm setting Tx frequency to " + "%.06f MHz" % fmhz
    result=tkMessageBox.askyesno(message=t)
    if result:
        ftx.set(0.000001*nftx)
        sftx.set('%.06f' % ftx.get())

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
    iy=1000000.0*(ftx.get()-f0.get()) - 1500
    if abs(iy)<=100:
        j=80 - iy/df
        c.create_line(0,j,13,j,fill='red',width=3)
        bg='gray85'
        fg='gray85'
    else:
        bg='red'
        fg='black'
    laberr.configure(bg=bg,fg=fg)

#------------------------------------------------------ del_all
def del_all():
    fname=appdir+'/ALL_MEPT.TXT'
    try:
        os.remove(fname)
    except:
        pass

#------------------------------------------------------ delwav
def delwav():
    t="Are you sure you want to delete\nall *.WAV files in the Save directory?"
    result=tkMessageBox.askyesno(message=t)
    if result:
# Make a list of *.wav files in Save
        la=dircache.listdir(appdir+'/save')
        lb=[]
        for i in range(len(la)):
            j=la[i].find(".wav") + la[i].find(".WAV")
            if j>0: lb.append(la[i])
# Now delete them all.
        for i in range(len(lb)):
            fname=appdir+'/save/'+lb[i]
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
    global bandmap,bm,newdat,loopall
    
# Get lines from decoded.txt and parse each into an assoc array
    try:
        f=open(appdir+'/decoded.txt',mode='r')
        decodes = []
        for line in f:
            fields = line.split()
            if len(fields) < 10: continue
            msg = fields[6:-3]
            d = {}
            d['date'] = fields[0]
            d['time'] = fields[1]
            d['sync'] = fields[2]
            d['snr'] = fields[3]
            d['dt'] = fields[4]
            d['freq'] = fields[5]
            d['msg'] = msg
            d['drift'] = fields[-3]
            d['cycles'] = fields[-2]
            d['ii'] = fields[-1]
            # try to figure out whether this is a beacon msg or QSO msg
            d['beacon'] = True
            if len(msg) != 3 or len(msg[1]) != 4 or len(msg[0]) < 3 or len(msg[0]) > 6 \
                   or not msg[2].isdigit():
                d['beacon'] = False
            else:
                dbm = int(msg[2])
                if dbm < 0 or dbm > 60:
                    d['beacon'] = False
            # try to extract the callsign of the Tx station from beacon or QSO msg
            if d['beacon']: d['call'] = d['msg'][0]
            elif d['msg'][0] == 'CQ' or d['msg'][0][0] == '<':
                d['call'] = d['msg'][1]
            decodes.append(d)
        f.close()
    except:
        decodes = []

    if len(decodes) > 0:
#  Write data to text box and insert freqs and calls into bandmap.
        text.configure(state=NORMAL)
        nseq=0
        nfmid=int(1.0e6*fmid)%1000
        for d in decodes:
            text.insert(END, "%4s %3s %4s %10s %2s %s\n" % \
                (d['time'],d['snr'],d['dt'],d['freq'],d['drift'],' '.join(d['msg'])))
            try:
                callsign=d['call']
                nseq=60*int(d['time'][0:2]) + int(d['time'][2:4])
                ndf=int(d['freq'][-3:])
                bm[callsign]=(ndf,nseq)
            except:
                pass
        text.configure(state=DISABLED)
        text.see(END)

#  Remove any "too old" information from bandmap.
        bandmap=[]
        for callsign,ft in bm.iteritems():
            ndf,tdecoded=ft
            if nseq-tdecoded < 60:                        #60 minutes 
                bandmap.append((ndf,callsign,tdecoded))

        iz=len(bandmap)
        bm={}
        for i in range(iz):
            bm[bandmap[i][1]]=(bandmap[i][0],bandmap[i][2])

#  Sort bandmap in reverse frequency order
        bandmap.sort()
        bandmap.reverse()
        text1.configure(state=NORMAL)
        text1.delete('1.0',END)
        for i in range(iz):
            t="%4d" % (bandmap[i][0],) + " " + bandmap[i][1]
            nage=int((nseq - bandmap[i][2])/15)
            attr='age0'
            if nage==1: attr='age1'
            if nage==2: attr='age2'
            if nage>=3: attr='age3'
            text1.insert(END,t+"\n",attr)
        text1.configure(state=DISABLED)
        text1.see(END)

    if upload.get():
        #Dispatch autologger thread.
        thread.start_new_thread(autolog, (decodes,))

    if loopall: opennext()

#------------------------------------------------------ autologger
def autolog(decodes):
    # Random delay of up to 15 seconds to spread load out on server --W1BW
    time.sleep(random.random() * 15.0)

    try:
        # This code originally by W6CQZ ... modified by W1BW
        # TODO:  Cache entries for later uploading if net is down.
        # TODO:  (Maybe??) Allow for stations wishing to collect spot data but
        #       only upload in batch form vs real-time.
        # Any spots to upload?
        if len(decodes) > 0:
            for d in decodes:
                # don't upload QSO messages, only things we think are beacons
                if not d['beacon']: continue
                # now to format as a string to use for autologger upload using urlencode
                # so we get a string formatted for http get/put operations:
                m = d['msg']
                reportparams = urllib.urlencode({'function': 'wspr',
                                                 'rcall': options.MyCall.get(),
                                                 'rgrid': options.MyGrid.get(),
                                                 'rqrg': str(f0),
                                                 'date': d['date'],
                                                 'time': d['time'],
                                                 #'sync': d['sync'],
                                                 'sig': d['snr'],
                                                 'dt': d['dt'],
                                                 'tqrg': d['freq'],
                                                 'drift': d['drift'],
                                                 'tcall': m[0],
                                                 'tgrid': m[1],
                                                 'dbm': m[2],
                                                 'version': Version})
                # reportparams now contains a properly formed http request string for
                # the agreed upon format between W6CQZ and N8FQ.
                # any other data collection point can be added as desired if it conforms
                # to the 'standard format' defined above.
                # The following opens a url and passes the reception report to the database
                # insertion handler for W6CQZ:
                #                urlf = urllib.urlopen("http://jt65.w6cqz.org/rbc.php?%s" % reportparams)
                # The following opens a url and passes the reception report to the
                # database insertion handler from W1BW:
                urlf = urllib.urlopen("http://wsprnet.org/meptspots.php?%s" \
                                  % reportparams)
                reply = urlf.readlines()
                #for r in reply:
                #    print r
                urlf.close()
        else:
            # No spots to report, so upload status message instead. --W1BW
            reportparams = urllib.urlencode({'function': 'wsprstat',
                                             'rcall': options.MyCall.get(),
                                             'rgrid': options.MyGrid.get(),
                                             'rqrg': str(fmid),
                                             'tpct': str(pctx[ipctx.get()]), 
                                             'tqrg': sftx.get(),
                                             'dbm': str(options.dBm.get()),
                                             'version': Version})
            urlf = urllib.urlopen("http://wsprnet.org/meptspots.php?%s" \
                                  % reportparams)
            reply = urlf.readlines()
            #for r in reply:
            #    print r
            urlf.close()
    # The proper way to handle url posting will be to define the url as a
    # configuration parameter so data sinks could be added/removed as necessary.
    # It is not strictly necessary to post reports to W6CQZ, but, since I
    # happen to be W6CQZ I can better debug things from the server side by
    # sending to my system during the active development phase of this code.
    except:
        print "Socket error, non-fatal."

#------------------------------------------------------ put_params
def put_params(param3=NONE):
    global idsec,param20

    try:
        w.acom1.f0=f0.get()
        w.acom1.ftx=ftx.get()
    except:
        pass
    w.acom1.callsign=(options.MyCall.get().strip().upper()+'      ')[:6]
    w.acom1.grid=(options.MyGrid.get().strip().upper()+'    ')[:4]
    w.acom1.ctxmsg=(txmsg.get().strip().upper()+'                      ')[:22]

    # numeric port ==> COM%d, else string of device.  --W1BW
    port = options.PttPort.get()
    if port.isdigit():
        w.acom1.nport = int(port)
        port = "COM%d" % (int(port))
    else:
        w.acom1.nport = 0
    w.acom1.pttport = (port + 80*' ')[:80]

    for i in range(len(pwrlist)):
        try:
            if pwrlist[i]==options.dBm.get():
                w.acom1.ndbm=pwrlist[i]
                break
        except:
            pass
    w.acom1.pctx=pctx[ipctx.get()]
    w.acom1.idsec=idsec
    w.acom1.ntest=ntest.get()
    w.acom1.ntxfirst=ntxfirst.get()
    w.acom1.nsave=nsave.get()
    try:
        g.ndevin.set(options.DevinName.get())
        w.acom1.ndevin=g.ndevin.get()
    except:
        g.ndevin.set(0)
        w.acom1.ndevin=0
    try:
        g.ndevout.set(options.DevoutName.get())
        w.acom1.ndevout=g.ndevout.get()
    except:
        g.ndevout.set(0)
        w.acom1.ndevout=0

#------------------------------------------------------ update
def update():
    global root_geom,isec0,im,pim,ndbm0,nsec0,a,ftx0, \
        receiving,transmitting,newdat,nscroll,newspec,scale0,offset0, \
        modpixmap0,tw,s0,c0,fmid,fmid0,idsec,loopall,ntr0,txmsg,iband0

    tsec=time.time() + 0.1*idsec
    utc=time.gmtime(tsec)
    nsec=int(tsec)
    nsec0=nsec
    ns120=nsec % 120
    try:
        f0.set(float(sf0.get()))
        ftx.set(float(sftx.get()))
    except:
        pass
    isec=utc[5]

    if iband.get()!=iband0:
        f0.set(freq0[iband.get()])
        ftx.set(freqtx[iband.get()])
        sf0.set(freq0[iband.get()])
        sftx.set(freqtx[iband.get()])
        iband0=iband.get()
    freq0[iband.get()]=f0.get()
    freqtx[iband.get()]=ftx.get()

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
        nndf=int(1000000.0*(ftx.get()-f0.get()) + 0.5) - 1500
        ndb=int(w.acom1.xdb1-57.0)
        if ndb<-30: ndb=-30
        t='Rx Noise: '+str(ndb)+' dB'
        bg='gray85'
        if ndb<-10 or ndb>10: bg='red'
        msg1.configure(text=t,bg=bg)

# If T/R status has changed, get new info
    ntr=int(w.acom1.ntr)
    if ntr!=ntr0:
        ntr0=ntr
        if ntr==-1:
            transmitting=1
            receiving=0
        elif ntr==0:
            transmitting=0
            receiving=0
        else:
            transmitting=0
            receiving=1
            n=len(tw)
            if n>12: tw=tw[:n-1]
            rxtime=g.ftnstr(w.acom1.rxtime)
            rxtime=rxtime[:2] + ':' + rxtime[2:]
            tw=[rxtime,] + tw

    bgcolor='gray85'
    t='Waiting to start'
    bgcolor='pink'
    if transmitting:
        t='Txing: '+g.ftnstr(w.acom1.sending)
        bgcolor='yellow'
    if receiving:
        t='Receiving'
        bgcolor='green'
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
    try:
        fmid=f0.get() + 0.001500
    except:
        pass
    if fmid!=fmid0 or ftx.get()!=ftx0:
        draw_axis()
    fmid0=fmid
    ftx0=ftx.get()
    w.acom1.ndebug=ndebug.get()
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
filemenu.add('command', label = 'Exit', command = quit, accelerator='Alt+F4')

#------------------------------------------------------ Setup menu
setupbutton = Menubutton(mbar, text = 'Setup')
setupbutton.pack(side = LEFT)
setupmenu = Menu(setupbutton, tearoff=0)
setupbutton['menu'] = setupmenu
setupmenu.add('command', label = 'Options', command = options1,
              accelerator='F2')
setupmenu.add_separator()
setupmenu.add('command', label = 'Rx volume control', command = rx_volume)
setupmenu.add('command', label = 'Tx volume control', command = tx_volume)
setupmenu.add_separator()
setupmenu.add_checkbutton(label = 'Enable diagnostics',variable=ndebug)

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

#------------------------------------------------------ Band menu
bandbutton = Menubutton(mbar, text = 'Band')
bandbutton.pack(side = LEFT)
bandmenu = Menu(bandbutton, tearoff=1)
bandbutton['menu'] = bandmenu
iband.set(5)
bandmenu.add_radiobutton(label = '160 m', variable=iband,value=1)
bandmenu.add_radiobutton(label = '80 m', variable=iband,value=2)
bandmenu.add_radiobutton(label = '40 m', variable=iband,value=4)
bandmenu.add_radiobutton(label = '30 m', variable=iband,value=5)
bandmenu.add_radiobutton(label = '20 m', variable=iband,value=6)
bandmenu.add_radiobutton(label = '17 m', variable=iband,value=7)
bandmenu.add_radiobutton(label = '15 m', variable=iband,value=8)
bandmenu.add_radiobutton(label = '12 m', variable=iband,value=9)
bandmenu.add_radiobutton(label = '10 m', variable=iband,value=10)
bandmenu.add_radiobutton(label = '6 m', variable=iband,value=11)
bandmenu.add_radiobutton(label = 'Other', variable=iband,value=12)


#------------------------------------------------------  Help menu
helpbutton = Menubutton(mbar, text = 'Help')
helpbutton.pack(side = LEFT)
helpmenu = Menu(helpbutton, tearoff=0)
helpbutton['menu'] = helpmenu
helpmenu.add('command', label = 'Help', command = help, accelerator='F1')
helpmenu.add('command', label = 'About WSPR', command = about)

root.bind_all('<Escape>', stop_loopall)
root.bind_all('<F1>', help)
root.bind_all('<F2>', options1)
root.bind_all('<Alt-F4>', quit)
root.bind_all('<F6>', opennext)
root.bind_all('<Shift-F6>', decodeall)
root.bind_all('<Control-o>',openfile)
root.bind_all('<Control-O>',openfile)

#------------------------------------------------------ Graphics area
iframe1 = Frame(frame, bd=1, relief=SUNKEN)

graph1=Canvas(iframe1, bg='black', width=NX, height=NY,cursor='crosshair')
Widget.bind(graph1,"<Motion>",df_readout)
Widget.bind(graph1,"<Double-Button-1>",set_tx_freq)
graph1.pack(side=LEFT)
c=Canvas(iframe1, bg='white', width=40, height=NY,bd=0)
c.pack(side=LEFT)

text1=Text(iframe1, height=10, width=12, bg="Navy", fg="yellow")
text1.pack(side=LEFT, padx=1)
text1.tag_configure('age0',foreground='red')
text1.tag_configure('age1',foreground='yellow')
text1.tag_configure('age2',foreground='gray75')
text1.tag_configure('age3',foreground='gray50')
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
bupload=Checkbutton(iframe2,text='Upload spots',justify=RIGHT,variable=upload)
bupload.place(x=360,y=12, anchor='e')
#bupload.pack(side=LEFT)
lab02=Label(iframe2, text='')
lab02.place(x=500,y=10, anchor='e')
lab00=Label(iframe2, text='Band Map').place(x=623,y=10, anchor='e')
iframe2.pack(expand=1, fill=X, padx=4)

#------------------------------------------------------ Labels under graphics
iframe2a = Frame(frame, bd=1, relief=FLAT)
g1=Pmw.Group(iframe2a,tag_text="Frequencies (MHz)")
lf0=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Dial:',
        value=10.1387,entry_textvariable=sf0,entry_width=12)
laberr=Label(g1.interior(), bg='gray85', fg='gray85', text='*')
lftx=Pmw.EntryField(g1.interior(),labelpos=W,label_text='Tx:',
        entry_textvariable=sftx,entry_width=12)
widgets = (lf0,laberr,lftx)
for widget in widgets:
    widget.pack(side=LEFT,padx=5,pady=2)
g1.pack(side=LEFT,fill=BOTH,expand=0,padx=6,pady=6)
lab01=Label(iframe2a, text='').pack(side=LEFT,padx=1)
g2=Pmw.Group(iframe2a,tag_text="T/R cycle")
#------------------------------------------------------ T/R Cycle Select
for i in range(7):
    t="Idle"
    if i==1:
        t="Rx"
    elif i==2:
        t="10%"
    elif i==3:
        t="20%"
    elif i==4:
        t="25%"
    elif i==5:
        t="33%"
    elif i==6:
        t="Tx"
    Radiobutton(g2.interior(),text=t,value=i,
                variable=ipctx).pack(side=LEFT,padx=4)
ipctx.set(0)
g2.pack(side=RIGHT,fill=BOTH,expand=0,padx=6,pady=6)
iframe2a.pack(expand=1, fill=X, padx=1)

iframe2 = Frame(frame, bd=1, relief=FLAT,height=15)
lab2=Label(iframe2, text='UTC        dB        DT             Freq             Drift')
lab2.place(x=150,y=6, anchor='w')
iframe2.pack(expand=1, fill=X, padx=4)

#-------------------------------------------------------- Buttons, UTC, etc
iframe4 = Frame(frame, bd=1, relief=SUNKEN)
f4a=Frame(iframe4,height=170,bd=2,relief=FLAT)

berase=Button(f4a, text='Erase',underline=0,command=erase,padx=1,pady=1)
berase.pack(side=TOP,padx=0,pady=15)

ldate=Label(f4a, bg='black', fg='yellow', width=11, bd=4,
        text='2005 Apr 22\n01:23:45', relief=RIDGE,
        justify=CENTER, font=(font1,14))
ldate.pack(side=TOP,padx=2,pady=5)

ldsec=Label(f4a, bg='white', fg='black', text='Dsec  0.0', width=8, relief=RIDGE)
ldsec.pack(side=TOP,ipadx=3,padx=2,pady=10)
Widget.bind(ldsec,'<Button-1>',incdsec)
Widget.bind(ldsec,'<Button-3>',decdsec)

f4a.pack(side=LEFT,expand=0,fill=Y)

#--------------------------------------------------------- Decoded text box
f4b=Frame(iframe4,height=170,bd=2,relief=FLAT)
text=Text(f4b, height=11, width=63, bg='white')
sb = Scrollbar(f4b, orient=VERTICAL, command=text.yview)
sb.pack(side=RIGHT, fill=Y)
text.pack(side=RIGHT, fill=X, padx=1)
text.insert(END,'1054   4 -25   1.12  10.140140  K1JT FN20 25')
text.configure(yscrollcommand=sb.set)
f4b.pack(side=LEFT,expand=0,fill=Y)
iframe4.pack(expand=1, fill=X, padx=4)


#------------------------------------------------------------ Status Bar
iframe6 = Frame(frame, bd=1, relief=SUNKEN)
msg1=Message(iframe6, text='      ', width=300,relief=SUNKEN)
msg1.pack(side=LEFT, fill=X, padx=1)
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
iband.set(5)

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
#            w.acom1.devin_name=(options.DevinName.get()+'            ')[:12]
        elif key == 'AudioOut':
            try:
                g.ndevout.set(value)
            except:
                g.ndevout.set(0)
            g.DevoutName.set(value)
            options.DevoutName.set(value)
#            w.acom1.devout_name=(options.DevoutName.get()+'            ')[:12]
        elif key == 'Nsave': nsave.set(value)
        elif key == 'Upload': upload.set(value)
        elif key == 'Debug': ndebug.set(value)
        elif key == 'WatScale': sc1.set(value)
        elif key == 'WatOffset': sc2.set(value)

        elif key == 'freq0_160': freq0[1]=float(value)
        elif key == 'freq0_80': freq0[2]=float(value)
        elif key == 'freq0_40': freq0[4]=float(value)
        elif key == 'freq0_30': freq0[5]=float(value)
        elif key == 'freq0_20': freq0[6]=float(value)
        elif key == 'freq0_17': freq0[7]=float(value)
        elif key == 'freq0_15': freq0[8]=float(value)
        elif key == 'freq0_12': freq0[9]=float(value)
        elif key == 'freq0_10': freq0[10]=float(value)
        elif key == 'freq0_6': freq0[11]=float(value)
        elif key == 'freq0_other': freq0[12]=float(value)

        elif key == 'freqtx_160': freqtx[1]=float(value)
        elif key == 'freqtx_80': freqtx[2]=float(value)
        elif key == 'freqtx_40': freqtx[4]=float(value)
        elif key == 'freqtx_30': freqtx[5]=float(value)
        elif key == 'freqtx_20': freqtx[6]=float(value)
        elif key == 'freqtx_17': freqtx[7]=float(value)
        elif key == 'freqtx_15': freqtx[8]=float(value)
        elif key == 'freqtx_12': freqtx[9]=float(value)
        elif key == 'freqtx_10': freqtx[10]=float(value)
        elif key == 'freqtx_6': freqtx[11]=float(value)
        elif key == 'freqtx_other': freqtx[12]=float(value)
        elif key == 'iband': iband.set(value)

        elif key == 'MRUDir': mrudir=value.replace("#"," ")
except:
    print 'Error reading WSPR.INI, continuing with defaults.'
    print key,value

f0.set(freq0[iband.get()])
ftx.set(freqtx[iband.get()])

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
sftx.set('%.06f' % ftx.get())
draw_axis()
erase()
if g.Win32: root.iconbitmap("wsjt.ico")
root.title('  WSPR 1.12     by K1JT')

put_params()
try:
    os.remove('decoded.txt')
except:
    pass
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
f.write("Upload " + str(upload.get()) + "\n")
f.write("Debug " + str(ndebug.get()) + "\n")
mrudir2=mrudir.replace(" ","#")
f.write("MRUDir " + mrudir2 + "\n")
f.write("WatScale " + str(s0)+ "\n")
##f.write("f0 " + str(f0.get()) + "\n")
##f.write("ftx " + str(ftx.get()) + "\n")
f.write("freq0_160 " + str( freq0[1]) + "\n")
f.write("freqtx_160 " + str(freqtx[1]) + "\n")
f.write("freq0_80 "  + str( freq0[2]) + "\n")
f.write("freqtx_80 " + str(freqtx[2]) + "\n")
f.write("freq0_40 "  + str( freq0[4]) + "\n")
f.write("freqtx_40 " + str(freqtx[4]) + "\n")
f.write("freq0_30 "  + str( freq0[5]) + "\n")
f.write("freqtx_30 " + str(freqtx[5]) + "\n")
f.write("freq0_20 "  + str( freq0[6]) + "\n")
f.write("freqtx_20 " + str(freqtx[6]) + "\n")
f.write("freq0_17 "  + str( freq0[7]) + "\n")
f.write("freqtx_17 " + str(freqtx[7]) + "\n")
f.write("freq0_15 "  + str( freq0[8]) + "\n")
f.write("freqtx_15 " + str(freqtx[8]) + "\n")
f.write("freq0_12 "  + str( freq0[9]) + "\n")
f.write("freqtx_12 " + str(freqtx[9]) + "\n")
f.write("freq0_10 "  + str( freq0[10]) + "\n")
f.write("freqtx_10 " + str(freqtx[10]) + "\n")
f.write("freq0_6 "  + str( freq0[11]) + "\n")
f.write("freqtx_6 " + str(freqtx[11]) + "\n")
f.write("freq0_other "  + str( freq0[12]) + "\n")
f.write("freqtx_other " + str(freqtx[12]) + "\n")
f.write("iband " + str(iband.get()) + "\n")

f.close()

#Terminate PortAudio
w.paterminate()
time.sleep(0.5)
