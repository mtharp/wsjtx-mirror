#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import absolute_import, division, print_function

r"""PyFMT Main Module

    TODO
    ----
    Update fmtmain description with full details.

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
import subprocess
import argparse
import serial
import pyaudio
import Pmw
from builtins import input
from _version import __version__

# set default paths
Version="0.1.0"
appdir = os.getcwd()
mrudir = os.getcwd()

# set debug print mode, 1 for debug, 0 disables additional prints
debug = 0

#--------------------------------------------------------------- Pause function
def pause():
    """Pause Statement

    Actions Performed:
        1. Prompt the user for input to create a pause"""
    input("\nPress [ ENTER ] to continue...")

#------------------------------------------------------------------------- done
def done():
    """Exit messagebox window"""
    root.quit()

#---------------------------------------------------------------------- msgWarn
def msgUdev():
    root = Tk()
    root.withdraw()
    tkinter.messagebox.showinfo("Under Development", "Feature is under development")
    root.destroy()

#----------------------------------------------------------------- clear_screen
def clearScreen():
    """Clear Screen Based On Platform Type"""
    if sys.platform == 'win32':
        os.system('cls')
    else:
        os.system('clear')

#******************************************************************************
# Begin - Stations Parameter Widget
#******************************************************************************
def stationParams():
    """Function to set the following:

    Callsign
    Grid Square
    Audio In Device

    Cate Control
        Hamlib Rig Number
        Serial Rate
        Data Bits
        Stop Bits
        Handshake
    """
    # widget lists
    qt1 = time.time()
    indevlist=[]
    riglist=[]
    devices = []
    baudlist = (1200,1800,2400,4800,9600,19200,38400,57600,115200) # Do we need more?
    hslist = ("None","XONXOFF","Hardware")
    datalist=(7,8)
    stoplist=(1,2)
    
    #-------------------------------------------------------- Audio Device List
    # PyAudio requires Portaudio19-Dev
    if debug == 1:
        print("* Generating Audio Device List")
    p = pyaudio.PyAudio()
    count = p.get_device_count()

    for i in range(count):
        devices.append(p.get_device_info_by_index(i))

    for i, dev in enumerate(devices):
        a = (str(i) + ' ' + str(dev['name']))
        indevlist.append(a)

    #----------------------------------------------------------------- Rig List
    # Rig Lists requires Hamlib rigctl
    if debug == 1:
        print("* Generating Hamlib Rig List")
    with open('hamlib_rig_numbers', 'r') as csvfile:
        list = csv.reader(csvfile, delimiter=',')
        for row in list:
            line = (row[0] + ' ' + row[1] + ' ' + row[2])
            riglist.append(line)

    #------------------------------------------------------------ COM Port List
    # Requires pyserial
    # for Windows
    if debug ==1:
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

    #--------------------------------------------------------------------------
    # Stat Window
    #--------------------------------------------------------------------------
    window = Tk()
    if sys.platform == 'win32':
        window.option_readfile('pyfmtrc.win')
    else:
        window.option_readfile('pyfmtrc.nix')
    window.title("Station Parameters")

    # try to center widget in the middle of screen
    window.update_idletasks()
    x = (window.winfo_screenwidth() - window.winfo_reqwidth()) / 2
    y = (window.winfo_screenheight() - window.winfo_reqheight()) / 2
    window.geometry("+%d+%d" % (x, y))
    window.deiconify()

    # balloon for tool-tips
    balloon = Pmw.Balloon(window)

    #---------------------------------------------------- Main Widget Variables
    g1 = Pmw.Group(window,tag_pyclass=None)

    MyCall=StringVar()
    MyGrid=StringVar()

    DevinName = StringVar()
    ndevin = IntVar()

    RiginName = StringVar()
    ndevrig = IntVar()

    CatPort = StringVar()
    ncatPortort = StringVar()

    serial_rate = IntVar()
    databits = IntVar()
    stopbits = IntVar()
    serial_handshake = StringVar()

    #---------------------------------------------------------------- onDestroy
    def onDestroy():
        """Exit the main Widget"""
        window.destroy()

    #------------------------------------------------------------------ saveIni
    def doNothing():
        """Dummy function, used for testing"""
        print("Dummy Function, doing nothing")

    #------------------------------------------------------------------ saveIni
    def saveIni():
        """Save parameters and quit"""
        saveParams()

    #------------------------------------------------------------------ msgWarn
    def msgWarn(t):
        result=tkinter.messagebox.showwarning(message=t)

    #------------------------------------------------------------------ msgInfo
    def msgInfo(t):
        result=tkinter.messagebox.showinfo(message=t)

    #-----------------------------------------------------------------redButton
    def redButton(bc):
        """Sets a button background color to red"""
        bc.configure(bg='red')

    #------------------------------------------------------------- yellowButton
    def yellowButton(bc):
        """Sets a button background color to yellow"""
        bc.configure(bg='yellow')

    #-------------------------------------------------------------- greenButton
    def greenButton(bc):
        """Sets a button background color to green"""
        bc.configure(bg='green')

    #----------------------------------------------------------------- testCcat
    def testCat():
        r"""Test CAT connection by reading the current rig frequency
        
        Assumption
            If you can read the rigs frequency, you should be able to
            change bands
        """
        global scmd
        global rcmd
        global cstatus
        freq = 14095600
        # Hamlib rigctrl command
        # sets the rig frequency using u/c F
        scmd = "rigctl -m %s -r %s -s %s -C data_bits=%s -C stop_bits=%s -C serial_handshake=%s F" % \
            (
            RiginName.get().split()[0],
            CatPort.get(),
            serial_rate.get(),
            databits.get(),
            stopbits.get(),
            serial_handshake.get(),
            )
        # reads the rig frequency with l/c f
        rcmd = "rigctl -m %s -r %s -s %s -C data_bits=%s -C stop_bits=%s -C serial_handshake=%s f" % \
            (
            RiginName.get().split()[0],
            CatPort.get(),
            serial_rate.get(),
            databits.get(),
            stopbits.get(),
            serial_handshake.get(),
            ) 
        # try to read the rig frequency
        if os.system(rcmd) != 0:
            print
            bc = test_cat_button
            redButton(bc)
            t = "\n       Rig Control Failed!\nCheck CAT Setting and Re-Test  "
            msgWarn(t)
            status = 1
        else:
            # show sucess message
            if debug == 1:
                t = ("\n  Rig Number [ %s ] is OK  " % RiginName.get().split()[0])
                msgInfo(t)
            bc = test_cat_button
            greenButton(bc)
            status = 0

        return rcmd
        cstatus = status
        return cstatus

    #---------------------------------------------------------- testAudioDevice
    def testAudioDevice():
        """Test if selected Audio device supports 48000.0 khz sampling rate
        
        Important
            If the device index being testing is in use, 
        
        """
        global astatus
        try:
            idx = int(DevinName.get().split()[0])
            srate = 48000.0
            p = pyaudio.PyAudio()
            devinfo = p.get_device_info_by_index(idx)
        except ValueError:
            bc = test_audio_button
            redButton(bc)
            t = "  Please select a valid audio device  "
            msgWarn(t)
            status = 1
            return

        try:
            for x in range(1):
                p.is_format_supported(
                    srate,
                    input_device=devinfo['index'],
                    input_channels=devinfo['maxInputChannels'],
                    input_format=pyaudio.paInt16
                    )
                if x != 0:
                    bc = test_audio_button
                    redButton(bc)
                    t = "\n    Device Busy or Unsupported   "
                    msgWarn(t)
                    status = 1
                else:
                    # show success message
                    if debug == 1:
                        t = ("\n  Audio Device [ %s ] is OK  " % idx)
                        msgInfo(t)
                    bc = test_audio_button
                    greenButton(bc)
                    status = 0

        except ValueError:
            bc = test_audio_button
            redButton(bc)
            t = "\n    Wrong Audio Device Selected   "
            msgWarn(t)
            status = 1
            return

        p.terminate()
        astatus = status
        return astatus

    #-------------------------------------------------------------- saveParams
    def saveParams():
        r"""Save pyfmt.ini and fmt.ini 
        
        Note
            This will save both ini files even with bad data, however,
            the button changes colors alerting the user that either CAT or
            the Audio device selection has an error.
        
        """
        testAudioDevice()
        testCat()
        # write pyfmt.ini
        with open(appdir + (os.sep) + 'pyfmt.ini', mode = 'w') as f:
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
            f.write(scmd + '\n')
            f.write(str(DevinName.get().split()[0]) + '\n')
            f.write(MyCall.get() + '\n')
            f.write(MyGrid.get() + '\n')
        f.close()


    #----------------------------------------------------------- callback audin
    def audin(event=NONE):
        r"""Callback: user selected input sound device"""
        DevinName.get().split()[0]
        ndevin.set(DevinName.get().split()[0])

    #----------------------------------------------------------- callback rigin
    def rigin(event=NONE):
        r"""Callback: user selected rig number from widget"""
        RiginName.get().split()[0]
        ndevrig.set(RiginName.get().split()[0])

    #------------------------------------------------------------ callback catPort
    def catPort(event=NONE):
        r"""Callback: user selected cat port"""
        CatPort.get()
        ncatPortort.set(CatPort.get())

    #--------------------------------------------------------- callback chkcall
    def chkCall(t):
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

    #--------------------------------------------------------- callback chkCall
    def showFmtIni():
        source=('fmt.ini')
        if ( not os.path.isfile(source)):
            t = "  Try settings first, then show results  "
            msgWarn(t)
            return             
        else:
            print("")
            print(45 * '-')
            print("Show fmt.ini")
            print(45 * '-')
            with open(source, mode = 'r') as f:
                for line in f:
                    line = line.rstrip('\n')
                    print(line) 
            f.close()

    #--------------------------------------------------------- callback chkGrid
    def chkGrid(t):
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

    #--------------------------------------------------------------------------
    # Draw Station Parameters Widget
    #--------------------------------------------------------------------------
    # try to read pyfmt.ini file before drawing the widget
    try:
        with open("pyfmt.ini", mode = 'r') as f:
            params = f.read().splitlines()
            if debug ==1:
                print("* Reading pyfmt.ini file")
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

    # Callsign EntryField
    lcall = Pmw.EntryField(
        g1.interior(),
        labelpos = W,
        label_text='Call:',
        value='',
        entry_textvariable=MyCall,
        entry_width = 8,
        validate=chkCall
        )
    # Grid EntryField
    lgrid = Pmw.EntryField(
        g1.interior(),
        labelpos=W,
        label_text='Grid:',
        value='',
        entry_textvariable=MyGrid,
        entry_width = 5,
        validate=chkGrid
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
        selectioncommand=catPort
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
    test_audio_button = Button(text="Test Audio", command = testAudioDevice)
    balloon.bind(test_audio_button, 'Test Audio Device Sample Rate')

    test_cat_button = Button(text="Test CAT", command = testCat)
    balloon.bind(test_cat_button, 'Check CAT Settings')

    save_button = Button(text="Save", command = saveIni)
    balloon.bind(save_button, 'Save Current Settings')

    show_button = Button(text="Show", command = showFmtIni)
    balloon.bind(show_button, 'Display Contents of fmt.ini file')

    exit_button = Button(text="Exit", command = onDestroy)
    balloon.bind(exit_button, 'Exit widget without changes')
    buttons =   (
                test_audio_button,
                test_cat_button,
                save_button,
                show_button,
                exit_button
                )

    # pack buttons
    for button in buttons:
        button.pack(fill='both', padx=4, pady=4)

    qt2 = (time.time() - qt1)
    if debug ==1:
        print("* Execution time ..: %.3f seconds" % qt2)

    window.mainloop()

#******************************************************************************
# End - Stations Parameter Widget
#******************************************************************************

#---------------------------------------------------------- Main Menu Functions
def main():
    """Main Menu Functions

    Function Notes:
        * Setup Station Parameters
        * Tests CAT control via Hamlib
        * Test AUdio Device Sample Rate
        * Writes pyfmt.ini and fmt.ini

    All other functions are under development

    """
    clearScreen()
    #----------------------------------------------------------------- Main Menu
    def main_menu():
        """Prints The Main Menu"""
        print("\n Station Parameters")
        print("   1. Set Station Parameters and Rig Control")
        print("\n Rig Calibration")
        print("   2. Setup Test Stations")
        print("\n ARRL  Frequency Measuring")
        print("   3. Setup ARRL Run Stations")
        print("\n Utilities")
        print("   4. Exit")
        print("")

    while True:
        main_menu()
        selection = input("Selection: ")
        # Set Station Parameters and Rig Control
        if selection == '1':
            stationParams()
            clearScreen()
            main()
        # Ris Calibration Functions
        elif selection == '2':
            msgUdev()
            clearScreen()
            main()
        # ARRL FM Test Functions
        elif selection == '3':
            t='Ths feature is under development'
            msgUdev()
            clearScreen()
            main()
        # exit basic menu
        elif selection == '4':
            sys.exit(0)
        else:
            clearScreen()
            main()



if __name__ == "__main__":
    main()
