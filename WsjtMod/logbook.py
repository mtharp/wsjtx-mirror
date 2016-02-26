# -*- coding: UTF-8 -*-
#-------------------------------------------------------------------------------
# This file is part of the WSJT application
#
# Author........: Greg Beam, KI7MT, <ki7mt@yahoo.com>
# File Name.....: logbook.py
# Description...: WSJT Logbook Miscellaneous Functions
# 
# Copyright (C) 2001-2016 Joseph Taylor, K1JT
# License: GPL-3
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
# Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
#-------------------------------------------------------------------------------

import sys, os, time, csv, sqlite3, Pmw
from tkinter import *
import tkinter.messagebox
from WsjtMod import appdirs
from appdirs import AppDirs

lbDebug=0
dbname=""
dbf=""
c3csv=""
dbdiur=""
commond=""
sqlname=""
c3csv=""
dbname='wsjt.db'
sql_file='wsjt.sql'
c3csv1='call3.csv'
appdir=os.getcwd()
commond = AppDirs("WSJT", appauthor='', version='', multipath='')
commond = commond.user_data_dir
sqld=(commond + (os.sep) + 'sql')
dbf=(commond + (os.sep) + dbname)
sqlf1 = (sqld + (os.sep) + sql_file)
c3csv = (sqld + (os.sep) + c3csv1)

#----------------------------------------------------------- logbook message box
def lbMsgBox(l):
    tkinter.messagebox._show(message=l)

#-------------------------------------------------------- already in call3 table
def InCall3(call):
    l=(" [ %s ] Is already in the Call3 Database" % call)
    lbMsgBox(l)

#------------------------------------------------------------ reset query timers
def ResetTimers():
    query_time1=""
    query_time2=""

#---------------------------------------------------------- Basic Check Database
def CheckDatabase(dbf):
    if os.path.exists(dbf)==True:
        try:
            app="database"
            con = sqlite3.connect(dbf)
            cur = con.cursor()
            cur.execute('SELECT version FROM version_data WHERE name=?', (app,))
            data = cur.fetchone()
            print("WSJT Database...: %s" % data)
            if con: con.close()

        except sqlite3.OperationalError as err:
            print("\n*********")
            print("Error %s:" % err)
            print("Will Create New Database..: %s" % dbname)
            print("*********\n")
            if con: con.close()
            init_db()

    else:
        init_db()

#---------------------------------------------------- connect to sqlite database
def cdb(dbf):
    global conn
    global ccdb
    conn = None
    try:
        conn = sqlite3.connect(dbf)
        ccdb = conn.cursor()

    except NameError as err:
        print("\n*********")
        print("Name error: {0}".format(err))
        print("Unable to connect to SQLite")
        print("*********\n")
        raise

    except (sqlite3.Error, e):
        print("\n*********")
        print("Error %s:" % e.args[0])
        print("*********\n")

#---------------------------------------------- submode conversion from database
def db_version():
    item='database'
    cdb(dbf)
    ccdb.execute('SELECT version FROM version_data WHERE name=?', (item,))
    for row in ccdb.fetchall():
        dbv = row[0]
    
    conn.close()
    return dbv

#---------------------------------------------- submode conversion from database
def ModeConvert(sm):
    cdb(dbf)
    ccdb.execute('SELECT mode FROM submode_list WHERE submode=?', (sm,))
    for row in ccdb.fetchall():
        mode = row[0]        

    conn.close()
    return mode

#------------------------------------------------- band conversion from database
def BandConvert(tf):
    cdb(dbf)
    ccdb.execute('SELECT band FROM band_list WHERE freq=?', (tf,))
    for row in ccdb.fetchall():
        band = row[0]

    conn.close()
    return band

#-------------------------------------------------------- gen meteor shower list
def MsList():
    cdb(dbf)
    ccdb.row_factory = lambda cursor, row: row[0]
    ms_list = ccdb.execute('SELECT ms_name FROM ms_shower ORDER BY ms_name ASC').fetchall()
    conn.close()
    return ms_list

#------------------------------------------------- grid square lookup from call3
def Whois(hiscall):
    ResetTimers()
    query_time1 = time.time()
    call=""
    grid=""
    eme=""
    previous=""
    comment=""
    lupdate=""
    cdb(dbf)
    ccdb.execute('SELECT * FROM call3 WHERE call=?', (hiscall,))
    for row in ccdb.fetchall():
        call = row[0]
        grid = row[1]
        eme = row[2]
        previous = row[3]
        comment = row[4]
        lupdate = row[5]

    if call=="":
        s=""
        print("[ %s ] Was Not Found In The Call3 Database" % (hiscall))
    else:
        # TO-DO: this should be a function
        grid=grid[:2].upper()+grid[2:4]+grid[4:6].lower()
        if len(grid)==4: grid=hisgrid+"mm"
        if len(grid)==5: grid=hisgrid+"m"
        
        query_time2 = (time.time()-query_time1)
        s=grid
        print("\nCall3 Lookup Found")
        print("---------------------------------------------------")
        print("Station Call ....: %s" % call)
        print("Station Grid ....: %s" % grid)
        print("Previous Calls ..: %s" % previous)
        print("EME Station .....: %s" % eme)
        print("Last Update .....: %s" % lupdate)
        print("Comment  ........: %s" % comment)
        print("Query Time ......: %.5f seconds" % (query_time2))

    conn.close()
    return s

#--------------------------------------------------- add callsign to call3 table
# call3 tables fields: call, gridsquare, force_init, prev_call, comment, last_update
# This is also used when adding a QSO via the LogQSO button, however not all
# fields are used in both cases.
def AddCall3(callsign,his_grid,eme_status):
    # init form variables
    c3o=StringVar()     # callsign
    c3g=StringVar()     # grid
    c3p=StringVar()     # previous calls
    c3c=StringVar()     # comment
    c3d=StringVar()     # last update
    previous=StringVar()
    comment=StringVar()
    previous=""
    comment=""
    emeval=IntVar()
    if eme_status==1:
        emeval.set(1)

    print(eme_status,emeval)

    # check if callsign exists in call3 Database
    cdb(dbf)
    ccdb.execute('SELECT * FROM call3 WHERE call=?', (callsign,))
    for row in ccdb.fetchall():
        call = row[0]
        if call != None:
            InCall3(call)
            return
    conn.close()

    # EME variable call back
    def emecb():
        return emeval.get()   
   
    # open Toplevel QSO Form
    root=Toplevel()
    root.title("Add Station To Call3 Database")
    root.resizable(0,0)
    x = (root.winfo_screenwidth() - root.winfo_reqwidth()) / 2
    y = (root.winfo_screenheight() - root.winfo_reqheight()) / 2
    root.geometry("+%d+%d" % (x, y))

    # get form values after user edits, then commit to call3 Table
    def CommitCall3():
        CALL=c3o.get()
        PREVIOUS=c3p.get()
        PREVIOUS=PREVIOUS.replace(',', '').upper()
        C3COMMENT=c3c.get()
        C3COMMENT=C3COMMENT.replace(',', '')
        LUPDATE=time.strftime("%Y%m%d",time.gmtime())
        if emeval.get()==1:
            EME="Y"
        else:
            EME="N"
       
        # from wsjtlookup, make sure the grid is somewhat valid
        # TO-DO: this should be a function
        grid=c3g.get()
        grid=grid[:2].upper()+grid[2:4]+grid[4:6].lower()
        if len(grid)==4: grid=grid+"mm"
        if len(grid)==5: grid=grid+"m"
        GRIDSQUARE=grid

        cdb(dbf)
        ccdb.execute('''INSERT INTO call3 (call, gridsquare, force_init, prev_call, comment, last_update) 
                    VALUES(?,?,?,?,?,?)''', (CALL,GRIDSQUARE,EME,PREVIOUS,C3COMMENT,LUPDATE))
        conn.commit()

        print("\nAdded Station to Call3 Database")
        print("---------------------------------------------------")
        print("Station Call ....: %s" % CALL)
        print("Station Grid ....: %s" % GRIDSQUARE)
        print("Previous Calls ..: %s" % PREVIOUS)
        print("EME Station .....: %s" % EME)
        print("Last Update .....: %s" % LUPDATE)
        print("Comment  ........: %s" % C3COMMENT)
        root.withdraw()

        conn.close()

    # Start the main log form frame
    # top frame (c3f1)
    c3f1 = LabelFrame(root, text="")
    c3f1.grid(row=0, columnspan=7, sticky='W', padx=5, pady=5, ipadx=5, ipady=5)

    # EME Station
    c3f2 = LabelFrame(root, text="Previous Calls")
    c3f2.grid(row=4, columnspan=7, sticky='W', padx=5, pady=5, ipadx=5, ipady=5)

    # Call3 Comments
    c3f3 = LabelFrame(root, text=" Comments ")
    c3f3.grid(row=6, columnspan=7, sticky='W', padx=5, pady=5, ipadx=5, ipady=5)

    # bottom frame (c3f3)
    c3f4 = LabelFrame(root)
    c3f4.grid(row=8, sticky='W', padx=5, pady=5)

    #-------------------------------------------------- top frame (lbf1)
    # Callsign
    c3o_label = Label(c3f1, text="Call")
    c3o_label.grid(row=0, column=0, sticky='W', padx=5, pady=2)
    c3o = Entry(c3f1, width=10)
    c3o.insert(END, callsign)
    c3o.grid(row=1, column=0, sticky="W", padx=5)

    # His Grid
    c3g_label = Label(c3f1, text="Grid")
    c3g_label.grid(row=0, column=1, sticky='W', padx=5, pady=2)
    c3g = Entry(c3f1, width=8)
    c3g.insert(END, his_grid)
    c3g.grid(row=1, column=1, sticky='W', padx=5, pady=2)

    # EME Station
    c3e = Checkbutton(c3f1, text="EME Station", variable=emeval, command=emecb)
    c3e.grid(row=1, column=4, sticky='W', padx=5, pady=2)

    # C3 Previous calls
    c3p = Entry(c3f2, width=34)
    c3p.grid(row=2, column=1, columnspan=7, sticky="W", padx=5)
    c3p.insert(END, previous)

    # C3 Comment
    c3c = Entry(c3f3, width=34)
    c3c.grid(row=2, column=1, columnspan=7, sticky="W", padx=5)
    c3c.insert(END, comment)

    #---------------------------------- save / hrlp / cancel bottom frame (lbf3)
    # Save QSO Button
    save_button = Button(c3f4, text="Save", fg="black", activebackground="cyan", background="cyan", command=CommitCall3)
    save_button.grid(row=0, column=0, sticky='WE', padx=5, pady=6)

    # Cancel QSO Button
    cancel_button = Button(c3f4, text="Cancel", fg="black", activebackground="red", background="red", command=root.withdraw)
    cancel_button.grid(row=0, column=1, sticky='WE', padx=5, pady=6)
    root.deiconify()

#------------------------------------------------ add the QSO to SQLit3 database
def AddQSO(MCALL, MGRID, CALL, GRIDSQUARE, QSO_DATE, TIME_ON, QSO_DATE_OFF, TIME_OFF, SUBMODE, MODE, RST_SENT, RST_RCVD, TX_PWR, BAND, QSO_TYPE, MS_SHOWER, NR_BURSTS, NR_PINGS, VUCC_GRIDS, C3UPD):
    FORCE_INIT=""
    MSQSO=""
    C3UPDATE=""
    
    # set EME QSO Status
    if QSO_TYPE==1:
        FORCE_INIT="Y"
        MSQSO="N"
    elif QSO_TYPE==2:
       FORCE_INIT="N"
       MSQSO="Y"
    else:
        FORCE_INIT="N"
        MSQSO="N"

    # check if CALL3 update was requested
    if C3UPD==1:
        C3UPDATE="Y"
        LUPDATE=time.strftime("%Y%m%d",time.gmtime())
    else:
        C3UPDATE="N"

    cdb(dbf)
    ccdb.execute('''INSERT INTO logbook(call, gridsquare, qso_date, time_on, qso_date_off, time_off, submode, mode, rst_sent, rst_rcvd, tx_pwr, band, force_init, ms_shower, nr_bursts, nr_pings, vucc_grids) 
                    VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)''', (CALL,GRIDSQUARE,QSO_DATE,TIME_ON,QSO_DATE_OFF,TIME_OFF,SUBMODE,MODE,RST_SENT,RST_RCVD,TX_PWR,BAND,FORCE_INIT,MS_SHOWER,NR_BURSTS,NR_PINGS,VUCC_GRIDS))

    conn.commit()
    
#    if C3UPD==1:
#        ccdb.execute('''REPLACE INTO call3 (call, gridsquare, force_init, last_update) VALUES (?,?,?,?)''', (CALL,GRIDSQUARE,FORCE_INIT,LUPDATE))
#        conn.commit()
#    
#    conn.close()

    try:
        if lbDebug==1:
            print("\nDebug Data")
            print("----------------------------------------------------------------")
            print("[1]  My Station......: %s %s" % (MCALL, MGRID))
            print("[2]  His Call........: %s" % CALL)
            print("[3]  His Grid........: %s" % GRIDSQUARE)
            print("[4]  QSO Start Date..: %s" % QSO_DATE)
            print("[5]  QSO Start Time..: %s" % TIME_ON)
            print("[6]  QSO End Date....: %s" % QSO_DATE_OFF)
            print("[7]  QSO End Time....: %s" % TIME_OFF)
            print("[8]  Submode.........: %s" % SUBMODE)
            print("[9]  Mode............: %s" % MODE)
            print("[10] RST Sent........: %s" % RST_SENT)
            print("[11] RST Rcvd........: %s" % RST_RCVD)
            print("[12] TX PWR..........: %s" % TX_PWR)
            print("[13] Band............: %s" % BAND)
            print("[14] EME QSO.........: %s" % FORCE_INIT)
            print("[15] MS QSO..........: %s" % MSQSO)
            print("[16] Meteor Shower...: %s" % MS_SHOWER)
            print("[17] MS Bursts.......: %s" % NR_BURSTS)
            print("[18] MS Pings........: %s" % NR_PINGS)
            print("[19] VUCC Grid.......: %s" % VUCC_GRIDS)
            print("[20] Update Call3....: %s" % C3UPDATE)
            print("[21] Logbook.........: %s" % dbname)
            print("----------------------------------------------------------------")

        else:
            print("\nLogged QSO..: %s" % CALL, GRIDSQUARE, QSO_DATE_OFF, TIME_OFF, SUBMODE)
            
    except NameError as err:
        print("\n*********")
        print("Name error: {0}".format(err))
        print("The QSO **was not** added to:", dbname)
        print("*********")

    except:
        print("Unexpected error:", sys.exc_info()[0])
        raise

#------------------------------------------------------------------ Clear screen
def clear_screen():
    if sys.platform == 'win32':
        os.system('cls')
    else:
        os.system('clear')

#--------------------------------------------------------------- Create Database
def init_db():
    query_time1 = time.time()
    print("\n---------------------------------------")
    print("Creating New WSJT Database")
    print("---------------------------------------")
    # connect to db
    cdb(dbf)

    # get SQLite3 version
    ccdb.execute('SELECT SQLITE_VERSION()')
    Sv = ccdb.fetchone()
    print(" SQLite version..........: %s" % Sv)
    print(" Database name...........: %s" % dbname)
    

    # read sql script and setup tables
    if os.path.exists(sqlf1)==True:
        print(" Reading SQL input file..: %s" % sql_file)
        fd = open(sqlf1, 'r')
        script = fd.read()
        ccdb.executescript(script)
        fd.close()
    else:
        raise Exception("SQL File Not Found %s, cannot continue." % sql_file)
        print(" Database Logging Disabled")

    # add CALL3 data
    try:
        open(c3csv, "r")
        have_c3csv=1

    except IOError:
        print(" CALL3 Import Error .....: cannot read %s" % c3csv1)
        have_c3csv=0

    if have_c3csv==1:
        c3data = csv.reader(open(c3csv))
        ccdb.executemany('''INSERT into call3(call, gridsquare, force_init,
                        prev_call, comment, last_update)
                        values (?, ?, ?, ?, ?, ?);''', c3data)
        conn.commit()

    # get total tables in the database
    ccdb.execute("SELECT Count(*) as nTables FROM sqlite_master where type='table';")
    Nt = ccdb.fetchone()
    print(" Number of Tables........: %s" % Nt)
    
    # get main log and call3 record count
    ccdb.execute("SELECT Count(*) FROM logbook;")
    Lc = ccdb.fetchone()
    print(" Main Log Count..........: %s" % Lc)
    ccdb.execute("SELECT Count(*) FROM call3;")
    C3 = ccdb.fetchone()
    print(" Call3 Record Count......: %s" % C3)
    query_time2 = (time.time()-query_time1)

    # close the db
    conn.close()

    # print total execution time
    print(" Execution time..........: %.3f seconds" % query_time2)
    print("\n")    
    conn.close()

#------------------------------------------------------ entry form help
def QsoFormHelp():
    msg="""
The following Fields are used when logging QSO and / or updating
the CALL3 Database Table. All fileds should be updated as
appropriate before saving.

Field       Description
------------------------------------------------------------------
Call........: Station being worked callsign
Grid........: Station being worked Grid
Start Date..: Date when QSO started, (UTC), update as Needed
Start Time..: Time when QSO Started, (UTC), update as Needed
End Date....: Date when QSO ended, (UTC), set when logging QSO
End Time....: Time when QSO ended, (UTC), set when logging QSO
Submode.....: Set from Main Menu >> Mode
Mode........: Cross reference based on Submode
Snt Rpt.....: Report set to Call Station
Rcvd Rpt....: Report Recieved from Call Station
TxPwr.......: Power level used during QSO, optional field
Band........: Set from Main Menu >> Band

Add QSO to Call3, if checked, will the QSO to the Call3 Table in wsjt.db
if it does not exist.

Rebuild Call3 file, if checked, will regenerate a CALL3.TXT file
if a call has been added to the CALL3 table in wsjt.db

Contact is EME QSO, if checked, will add a flag in both the QSO
log and CALL3 data table.

"""
    root=Toplevel()
    root.title('Log QSO Entry Form Help')
    Label(root,text=msg,justify=LEFT).pack(padx=20)
    root.focus_set()

#------------------------------------------------------ main entry form
def QsoForm(mcall,mgrid,operator,qso_date,qso_time,his_grid,rpt_sent,rpt_rcvd,pwr,tf,sm,last_update,band,mode):

    # open Toplevel QSO Form
    root=Toplevel()
    root.title('Log QSO Entry Form')
    root.resizable(0,0)
    balloon = Pmw.Balloon()

    # attempt to center log form in the middle of the screen
    x = (root.winfo_screenwidth() - root.winfo_reqwidth()) / 2
    y = (root.winfo_screenheight() - root.winfo_reqheight()) / 2
    root.geometry("+%d+%d" % (x, y))

    # initilize variables used in log entry form
    lbo=StringVar()
    lbg=StringVar()
    lb_date=StringVar()
    lb_time=StringVar()
    lb_submode=StringVar()
    lb_mode=StringVar()
    lb_band=StringVar()
    lb_rpt_sent=StringVar()
    lb_rpt_rcvd=StringVar()
    lb_band_list=StringVar()
    lb_submode_list=StringVar()
    ms_list_dropdown=StringVar()
    nr_bursts=IntVar()
    nr_pings=IntVar()
    c3update=IntVar()
    qsotype=IntVar()
    eme_ms=BooleanVar()

    def rbselect():
        return eme_ms.get()

    # get form values after save, then send them to the logbook
    def AddQsoToDatabase():
        MCALL=mcall
        MGRID=mgrid
        CALL=lbo.get()
        GRIDSQUARE=lbg.get()
        QSO_DATE=lb_date_start.get()
        TIME_ON=lb_time_start.get()
        QSO_DATE_OFF=lb_date_end.get()
        TIME_OFF=lb_time_end.get()
        SUBMODE=lb_submode.get()
        MODE=lb_mode.get()
        RST_SENT=lb_rpt_sent.get()
        RST_RCVD=lb_rpt_sent.get()
        TX_PWR=lb_pwr.get()
        BAND=lb_band.get()
        NR_BURSTS=nr_bursts.get()
        NR_PINGS=nr_pings.get()
        VUCC_GRIDS=lbg.get()[:4].upper()
        QSO_TYPE=eme_ms.get()
        MS_SHOWER=ms_list_dropdown.get()
        NR_BURSTS=nr_bursts.get()
        NR_PINGS=nr_pings.get()
        C3UPD=c3update.get()

        # try to post qso data to log book
        # QSO_TYPE is a swithch for EME or MS QSO's
        try:
            AddQSO(MCALL, MGRID, CALL, GRIDSQUARE, QSO_DATE, TIME_ON, QSO_DATE_OFF, TIME_OFF, SUBMODE, MODE, RST_SENT, RST_RCVD, TX_PWR, BAND, QSO_TYPE, MS_SHOWER, NR_BURSTS, NR_PINGS, VUCC_GRIDS, C3UPD)

        except (ValueError):
            print("\n*********")
            print("An Error occured while adding the QSO", Argument)
            print("The QSO was not added to the database")
            print("\n*********")
            root.withdraw()
            
        finally:
            root.withdraw()
            # if log QSO was sucessfull && update call3 was selected
            # send the qso data to the call3 table   
            if c3update.get()==1:
                callsign=CALL
                his_grid=GRIDSQUARE
                eme_status=QSO_TYPE
                AddCall3(callsign,his_grid,eme_status)

    # Start the main log form frame
    # top frame (lbf1)
    lbf1 = LabelFrame(root, text=" QSO Data ")
    lbf1.grid(row=0, columnspan=7, sticky='W', padx=5, pady=5, ipadx=5, ipady=5)

    # middle frame (lbf2)
    lbf2 = LabelFrame(root, text=" Meteor Shower Data ")
    lbf2.grid(row=4, columnspan=7, sticky='WE', padx=4, pady=4, ipadx=0, ipady=0)

    # meator shower frame (lbf3)
    lbf3 = LabelFrame(root, text=" Save Options ")
    lbf3.grid(row=5, columnspan=7, sticky='WE', padx=4, pady=4, ipadx=0, ipady=0)

    # bottom frame (lbf3)
    lbf4 = LabelFrame(root)
    lbf4.grid(row=6, sticky='W', padx=4, pady=4, ipadx=0, ipady=0)

    #-------------------------------------------------- top frame (lbf1)
    # Operator Call
    lbo_label = Label(lbf1, text="Call")
    lbo_label.grid(row=0, column=0, sticky='W', padx=5, pady=2)
    lbo = Entry(lbf1, width=10)
    lbo.insert(END, operator)
    lbo.grid(row=1, column=0, sticky="W", padx=5)

    # His Grid
    lbg_label = Label(lbf1, text="Grid")
    lbg_label.grid(row=0, column=1, sticky='W', padx=5, pady=2)
    lbg = Entry(lbf1, width=8)
    lbg.insert(END, his_grid)
    lbg.grid(row=1, column=1, sticky='W', padx=5, pady=2)

    # QSO Start Date
    lb_date_label = Label(lbf1, text="Start Date")
    lb_date_label.grid(row=0, column=2, sticky='W', padx=5, pady=2)
    lb_date_start = Entry(lbf1, width=10)
    lb_date_start.insert(END, qso_date)
    lb_date_start.focus_set()
    lb_date_start.grid(row=1, column=2, sticky='W', padx=5, pady=2)

    # QSO Start Time
    lb_time_label = Label(lbf1, text="Start Time")
    lb_time_label.grid(row=0, column=3, sticky='W', padx=5, pady=2)
    lb_time_start = Entry(lbf1, width=8)
    lb_time_start.insert(END, qso_time)
    lb_time_start.grid(row=1, column=3, sticky='W', padx=5, pady=2)

    # QSO End Date
    lb_date_label = Label(lbf1, text="End Date")
    lb_date_label.grid(row=0, column=4, sticky='W', padx=5, pady=2)
    lb_date_end = Entry(lbf1, width=10)
    lb_date_end.insert(END, qso_date)
    lb_date_end.grid(row=1, column=4, sticky='W', padx=5, pady=2)

    # QSO End Time
    lb_time_label = Label(lbf1, text="End Time")
    lb_time_label.grid(row=0, column=5, sticky='W', padx=5, pady=2)
    lb_time_end = Entry(lbf1, width=8)
    lb_time_end.insert(END, qso_time)
    lb_time_end.grid(row=1, column=5, sticky='W', padx=5, pady=2)

    # Submode
    lb_submode_label = Label(lbf1, text="Submode")
    lb_submode_label.grid(row=2, column=0, sticky='W', padx=5, pady=2)
    lb_submode = Entry(lbf1, width=10)
    lb_submode.insert(END, sm)
    lb_submode.grid(row=3, column=0, sticky='W', padx=5, pady=2)

    # Mode
    lb_mode_label = Label(lbf1, text="Mode")
    lb_mode_label.grid(row=2, column=1, sticky='W', padx=5, pady=2)
    lb_mode = Entry(lbf1, width=8)
    lb_mode.insert(END, mode)
    lb_mode.grid(row=3, column=1, sticky='W', padx=5, pady=2)

    # Rpt Sent
    lb_rpt_sent_label = Label(lbf1, text="Rpt Sent")
    lb_rpt_sent_label.grid(row=2, column=2, sticky='W', padx=5, pady=2)
    lb_rpt_sent = Entry(lbf1, width=8)
    lb_rpt_sent.insert(0, rpt_sent)
    lb_rpt_sent.grid(row=3, column=2, sticky='W', padx=5, pady=2)

    # Rpt_Rcvd
    lb_rpt_rcvd_label = Label(lbf1, text="Rpt Rcvd")
    lb_rpt_rcvd_label.grid(row=2, column=3, sticky='W', padx=5, pady=2)
    lb_rpt_rcvd = Entry(lbf1, width=8)
    lb_rpt_rcvd.insert(0, rpt_rcvd)
    lb_rpt_rcvd.grid(row=3, column=3, sticky='W', padx=5, pady=2)

    # TxPwr
    lb_pwr_label = Label(lbf1, text="Tx Pwr")
    lb_pwr_label.grid(row=2, column=4, sticky='W', padx=5, pady=2)
    lb_pwr = Entry(lbf1, width=10)
    lb_pwr.insert(0, pwr)
    lb_pwr.grid(row=3, column=4, sticky='W', padx=5, pady=2)

    # Band
    lb_band_label = Label(lbf1, text="Band")
    lb_band_label.grid(row=2, column=5, sticky='W', padx=5, pady=2)
    lb_band = Entry(lbf1, width=4)
    lb_band.insert(END, band)
    lb_band.grid(row=3, column=5, sticky='W', padx=5, pady=2)

    #-------------------------------------------------- middle frame (lbf2)
    ms_list_label = Label(lbf2, text="Select")
    ms_list_label.grid(row=0, column=0, sticky='W', padx=5, pady=2)
    ms_list_dropdown = Pmw.ComboBox(lbf2, scrolledlist_items=(MsList()), entry_width=20)
    balloon.bind(ms_list_dropdown, 'Slect Meteor Shower')
    ms_list_dropdown.grid(row=1, column=0, padx=5, sticky="WE", pady=3)

    # Bursts
    nr_bursts_label = Label(lbf2, text="Bursts")
    nr_bursts_label.grid(row=0, column=1, sticky='W', padx=5, pady=2)
    nr_bursts = Entry(lbf2, width=6)
    balloon.bind(nr_bursts, 'Enter Number of Bursts Detected')
    nr_bursts.grid(row=1, column=1, sticky='W', padx=5, pady=2)

    # Pings
    nr_pings_label = Label(lbf2, text="Pings")
    nr_pings_label.grid(row=0, column=2, sticky='W', padx=5, pady=2)
    nr_pings = Entry(lbf2, width=6)
    balloon.bind(nr_pings, 'Enter Number of Pings Detected')
    nr_pings.grid(row=1, column=2, sticky='W', padx=5, pady=2)

    #-------------------------------------------------- meteor shower frame (lbf3)
    # Update Call3 Data Checkbox, Default Set to "Yes"
    c3_update = Checkbutton(lbf3, text="Update Call3 Table", variable=c3update, onvalue=1, offvalue=0, )
    c3_update.select()
    balloon.bind(c3_update, 'Click to update CALL3 Table')
    c3_update.grid(row=1, column=0, sticky='W', padx=5, pady=2)

    # EME QSO Y/N
    R1 = Radiobutton(lbf3, text="EME QSO", variable=eme_ms, value=1, command=rbselect)
    balloon.bind(R1, 'Click if Station is an EME Operator')
    R1.grid(row=1, column=3, sticky='W', padx=5, pady=2)

    # MS QSO Y/N
    R2 = Radiobutton(lbf3, text="MS QSO", variable=eme_ms, value=2, command=rbselect)
    balloon.bind(R2, 'Click to Set Meteor Scatter Contact')
    R2.grid(row=1, column=4, sticky='W', padx=5, pady=2)

    #---------------------------------- save / hrlp / cancel bottom frame (lbf3)
    # Save QSO Button
    save_button = Button(lbf4, text="Save", fg="black", activebackground="cyan", background="cyan", command=AddQsoToDatabase)
    balloon.bind(save_button, 'Add QSO to Database')
    save_button.grid(row=0, column=0, sticky='WE', padx=5, pady=6)

    # Entry Form Help Button
    help_button = Button(lbf4, text="Help", fg="black", activebackground="yellow", background="yellow", command=QsoFormHelp)
    balloon.bind(help_button, 'Display Logform Help')
    help_button.grid(row=0, column=1, sticky='WE', padx=5, pady=6)

    # Cancel QSO Button
    cancel_button = Button(lbf4, text="Cancel", fg="black", activebackground="red", background="red", command=root.withdraw)
    balloon.bind(cancel_button, 'Cancel Without Saving QSO')
    cancel_button.grid(row=0, column=2, sticky='WE', padx=5, pady=6)
    root.deiconify()


