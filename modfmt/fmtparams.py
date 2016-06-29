#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import absolute_import, division, print_function

r"""Setup Station Parameters

    This module sets the users information (Call and Grid Square), Input Audio
    Devices, selects rig control (CAT) via Hamlib, and comport settings. 


    Buttons
    -------
    Save Button: saves the main fmtparams.ini
    Show Button: upon successful CAT initialization, displays fmt.ini
    Exit Button: exits the widget


    Python Module Requirements
    -------------------------
    Pmw, pyaudio, pyserial

    * All packages are available from PyPi
    * To install: python -m pip install Pmw pyaudio pyserial


    System Level Requirements
    ------------------------
    portaudio19-dev
    rigctrl and libhamlib.a
    
    * Hamlib3 is built from G4WJS Hamlib3 Integration branch ( Git repo )


    Outputs
    -------
    FMTEST.ini
    fmt.ini


    Optional
    ---------
   soundevice, cffi, numpy

    An optional approach for audio chain selection would be to use the
    module sounddevice. NumPY is only required if if you want to record
    and play back numpy-arrays.

"""
import tkinter
from tkinter import *
import tkinter.messagebox
import tkinter.font
import math
import os
import sys
import glob
import csv
import time
import serial
import pyaudio
import Pmw

qt1 = time.time()
# set default paths
appdir = os.getcwd()
mrudir = os.getcwd()

# generate lists
indevlist=[]
riglist=[]
devices = []
baudlist = (1200,1800,2400,4800,9600,19200,38400,57600,115200) # Do we need more?
hslist = ("None","XONXOFF","Hardware")
datalist=(7,8)
stoplist=(1,2)

#------------------------------------------------------------------------- done
def done():
    """Exit the main Widget"""
    root.destroy()

#----------------------------------------------------------------- clear_screen
def clear_screen():
    """Clear Screen Based On Platform Type"""
    if sys.platform == 'wi32':
        os.system('cls')
    else:
        os.system('clear')

clear_screen()
Version="4.0.0"
print(65 * '*')
print("FMTest Version ..: " + Version + ", by K1JT")
print("Run date ........: " + time.asctime(time.gmtime()) + " UTC")
print(65 * '*')

#--------------------------------------------------------------- serialportlist
# for Windows
print("* Generating Serial Port List")
if sys.platform.startswith('win'):
    ports = ['COM%s' % (i + 1) for i in range(256)]

# for Linux
elif sys.platform.startswith('linux'):
    ports = glob.glob('/dev/tty[A-Za-z]*')
    ports.append('USB')

# for OSX
elif sys.platform.startswith('darwin'):
    ports = glob.glob('/dev/tty.*')

# else, unsupported platform message
else:
    raise EnvironmentError('Unsupported Platform')

# create the list of ports
result = []
for port in ports:
    try:
        s = serial.Serial(port)
        s.close()
        result.append(port)
    except (OSError, serial.SerialException):
        pass

# set the final list
serialportlist = result

#-------------------------------------------------------------------- indevlist
# requires Portaudio19-Dev to be installed at the system level
print("* Generating Audio Device List")
p = pyaudio.PyAudio()
count = p.get_device_count()

for i in range(count):
    devices.append(p.get_device_info_by_index(i))

for i, dev in enumerate(devices):
    a = (str(i) + ' ' + str(dev['name']))
    indevlist.append(a)

#---------------------------------------------------------------------  riglist
# requires comma separated file from Hamlib: rigctrl --list
print("* Generating Hamlib Rig List")
with open('hamlib_rig_numbers', 'r') as csvfile:
	list = csv.reader(csvfile, delimiter=',')
	for row in list:
		line = (row[0] + ' ' + row[1] + ' ' + row[2])
		riglist.append(line)

#------------------------------------------------------------------------------
# Start Main Widget
#------------------------------------------------------------------------------
root = Tk()
if sys.platform == 'win32':
    root.option_readfile('wsprrc.win')
else:
    root.option_readfile('wsprrc.nix')
root.protocol('WM_DELETE_WINDOW',done)
root.title("FMT Parameters")
root_geom=""
balloon = Pmw.Balloon(root)

#-------------------------------------------------------- Main Widget Variables
g1 = Pmw.Group(root,tag_pyclass=None)

MyCall=StringVar()
MyGrid=StringVar()

DevinName = StringVar()
ndevin = IntVar()

RiginName = StringVar()
ndevrig = IntVar()

CatPort = StringVar()
ncatport = StringVar()

serial_rate = IntVar()
databits = IntVar()
stopbits = IntVar()
serial_handshake = StringVar()

#---------------------------------------------------------------------- saveini
def saveini():
    """Save parameters and quit"""
    save_params()

#---------------------------------------------------------------------- saveini
def quit():
    """Quit quit without saving"""
    print("Exiting FMT Parameters\n")
    root.quit()

#---------------------------------------------------------------------- MsgWarn
def MsgWarn(t):
    result=tkinter.messagebox.showwarning(message=t)

#---------------------------------------------------------------------- Msginfo
def MsgInfo(t):
    result=tkinter.messagebox.showinfo(message=t)

#------------------------------------------------------------------ save_params
def save_params():
    r"""Save fmtparams.ini and fmt.ini if CAT / Rig Control checks pass
    
    The function will try to change frequencies to the 20M WSPR frequency.
    If it passes, the both the fmtparams.ini and fmt.ini files will be written,
    and Info Message box is displayed, otherwise, an Error Message Box is shown
    to the user, with a prompt to correct the settings.

    """
    # 20m band WSPR frequenccy
    test_band = str(14095600)
    # Hamlib rigctrl command
    cmd = "rigctl -m %s -r %s -s %s -C data_bits=%s -C stop_bits=%s -C serial_handshake=%s F %s" % \
        (
        RiginName.get().split()[0],
        CatPort.get(),
        serial_rate.get(),
        databits.get(),
        stopbits.get(),
        serial_handshake.get(),
        test_band
        )

    # try to change bands with the rig
    ierr = os.system(cmd)
    if ierr != 0:
        t = "Rig Control Failed!\nCheck CAT Setting and Re-Save"
        MsgWarn(t)
        status = 1
    else:
        # write fmtparams.ini
        with open(appdir + (os.sep) + 'fmtparams.ini', mode = 'w') as f:
            f.write("MyCall" + "=" + MyCall.get() + "\n")
            f.write("MyGrid" + "=" + MyGrid.get() + "\n")
            f.write("AudioIn" + "=" + str(DevinName.get().split()[0]) + "\n")
            f.write("Rig" + "=" + str(RiginName.get().split()[0]) + "\n")
            f.write("CatPort" + "=" + str(CatPort.get()) + "\n")
            f.write("SerialRate" + "=" + str(serial_rate.get()) + "\n")
            f.write("DataBits" + "=" + str(databits.get()) + "\n")
            f.write("StopBits" + "=" + str(stopbits.get()) + "\n")
            f.write("Handshake" + "=" + serial_handshake.get() + "\n")
        f.close()

        # write fmt.ini
        with open(appdir + (os.sep) + 'fmt.ini', mode = 'w') as f:
            f.write(cmd + '\n')
            f.write(str(DevinName.get().split()[0]) + '\n')
            f.write(MyCall.get() + '\n')
            f.write(MyGrid.get() + '\n')
        f.close()

        # show sucess message
        t = "Rig Control is ( OK )\nParameter files have been saved"
        MsgInfo(t)
        status = 0

#--------------------------------------------------------------- callback audin
def audin(event=NONE):
    r"""Callback: user selected input sound device"""
    DevinName.get().split()[0]
    ndevin.set(DevinName.get().split()[0])

#--------------------------------------------------------------- callback rigin
def rigin(event=NONE):
    r"""Callback: user selected rig number from widget"""
    RiginName.get().split()[0]
    ndevrig.set(RiginName.get().split()[0])

#---------------------------------------------------------------- callback catp
def catp(event=NONE):
    r"""Callback: user selected cat port"""
    CatPort.get()
    ncatport.set(CatPort.get())

#------------------------------------------------------------- callback chkcall
def chkcall(t):
    r"""Callback: check if user entered call is valid"""
    r = -1
    n = len(t)
    if n >= 3 and n <= 10:
        i1 = t.count('/')
        i2 = t.find('/')
        if i1 == 1 and i2 > 0:
            t = t[:i2-1] + t[i2+1:]
        if t.isalnum() and t.find(' ') <0:
            r = 1
    return r

#------------------------------------------------------------- callback chkcall
def listini():
    print("")
    print(45 * '-')
    print("Show fmt.ini")
    print(45 * '-')
    with open('fmt.ini', mode = 'r') as f:
        for line in f:
            line = line.rstrip('\n')
            print(line)
    f.close()

#------------------------------------------------------------- callback chkgrid
def chkgrid(t):
    r"""Callback: check if user entered grid square is valid"""
    r = -1
    n = len(t)
    if n == 4 or n == 6:
        if int(t[0:1],36) >= 10 and int(t[0:1],36) <= 27 and \
           int(t[1:2],36) >= 10 and int(t[1:2],36) <= 27 and \
           int(t[2:3],36) >= 0 and int(t[2:3],36) <= 9 and \
           int(t[3:4],36) >= 0 and int(t[3:4],36) <= 9: r = 1
        if r == 1 and n == 6:
            r = -1
            if int(t[4:5],36) >= 10 and int(t[4:5],36) <= 33 and \
               int(t[5:6],36) >= 10 and int(t[5:6],36) <= 33: r = 1
    return r

#-------------------------------------------------------- process fmtparams.ini
# read ini file
try:
    with open("fmtparams.ini", mode = 'r') as f:
        params = f.read().splitlines()
        print("* Reading fmtparams.ini file")
        for i in range(len(params)):
            key,value = params[i].split("=")
            if   key == 'MyCall': MyCall.set(value)
            elif key == 'MyGrid': MyGrid.set(value)
            elif key == 'AudioIn': DevinName.set(value)
            elif key == 'CatPort': CatPort.set(value)
            elif key == 'Rig': RiginName.set(value)
            elif key == 'SerialRate': serial_rate.set(int(value))
            elif key == 'DataBits': databits.set(int(value))
            elif key == 'StopBits': stopbits.set(int(value))
            elif key == 'Handshake': serial_handshake.set(str(value))
    f.close()
except:
    # set some default values
    MyCall.set("")
    MyGrid.set("")
    DevinName.set("Select Device -->")
    CatPort.set("Select Port -->")
    RiginName.set("Select Rig -->")
    serial_rate.set(4800)
    databits.set(8)
    stopbits.set(2)
    serial_handshake.set('None')

#******************************************************************************
# Main Widget Fields - Pmw
#******************************************************************************

# Callsign EntryField
lcall = Pmw.EntryField(
    g1.interior(),
    labelpos = W,
    label_text='Call:',
    value='',
    entry_textvariable=MyCall,
    entry_width = 8,
    validate=chkcall
    )
# Grid EntryField
lgrid = Pmw.EntryField(
    g1.interior(),
    labelpos=W,
    label_text='Grid:',
    value='',
    entry_textvariable=MyGrid,
    entry_width = 5,
    validate=chkgrid
    )
# AudioIn  ComboBox
audioin = Pmw.ComboBox(
    g1.interior(),
    labelpos=W,
    label_text='Audio In:',
    entry_textvariable=DevinName,
    entry_width = 30,
    scrolledlist_items=indevlist,
    selectioncommand=audin
    )
# Rig Number ComboBox
lrignum = Pmw.ComboBox(
    g1.interior(),
    labelpos=W,
    label_text='Rig number:',
    entry_textvariable=RiginName,
    entry_width = 30,
    scrolledlist_items=riglist,
    selectioncommand=rigin
    )
# CAT Port ComboBox
cat_port = Pmw.ComboBox(
    g1.interior(),
    labelpos=W,
    label_text='CAT port:',
    entry_textvariable=CatPort,
    entry_width = 12,
    scrolledlist_items=serialportlist,
    selectioncommand=catp
    )
# Baud ComboBox
cbbaud = Pmw.ComboBox(
    g1.interior(),
    labelpos=W,
    label_text='Serial rate:',
    entry_textvariable=serial_rate,
    entry_width = 4,
    scrolledlist_items=baudlist
    )
# Data Bit ComboBox
cbdata = Pmw.ComboBox(
    g1.interior(),
    labelpos=W,
    label_text='Data bits:',
    entry_textvariable=databits,
    entry_width = 4,
    scrolledlist_items=datalist
    )
# Stop Bit ComboBox
cbstop = Pmw.ComboBox(
    g1.interior(),
    labelpos=W,
    label_text='Stop bits:',
    entry_textvariable=stopbits,
    entry_width = 4,
    scrolledlist_items=stoplist
    )
# Handshake ComboBox
cbhs = Pmw.ComboBox(
    g1.interior(),
    labelpos=W,
    label_text='Handshake:',
    entry_textvariable=serial_handshake,
    entry_width = 4,
    scrolledlist_items=hslist
    )

# Widget List
widgets = (lcall,lgrid,audioin,lrignum,cat_port,cbbaud,cbdata,cbstop,cbhs)

# pack widgets and align
for widget in widgets:
    widget.pack(fill=X, expand = 1, padx = 10, pady = 2)
Pmw.alignlabels(widgets)

# Frame-1 Alignment
f1 = Frame(g1.interior(), width = 100, height = 10)
f1.pack()
g1.pack(side=LEFT, fill=BOTH, expand = 1, padx = 4, pady = 4)

# side buttons
save_button = Button(text="Save", command = saveini)
balloon.bind(save_button, 'Save Current Settings')

show_button = Button(text="Show", command = listini)
balloon.bind(show_button, 'Display Contents of fmt.ini file')

exit_button = Button(text="Exit", command = quit)
balloon.bind(exit_button, 'Exit widget without changes')
buttons = (save_button,show_button,exit_button)

# pack buttons
for button in buttons:
    button.pack(fill='both', padx=4, pady=4)

qt2 = (time.time() - qt1)
print("* Execution time ..: %.3f seconds" % qt2)

root.mainloop()

# END fmtparams.py
