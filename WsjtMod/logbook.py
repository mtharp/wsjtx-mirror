# -*- coding: UTF-8 -*-
#-------------------------------------------------------------------------------
# This file is part of the WSJT application
#
# Author........: Greg Beam, KI7MT, <ki7mt@yahoo.com>
# File Name.....: logbook.py
# Description...: WSJT Loogbook Miscellaneous Functions
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

import sys, os, time, csv, sqlite3
from tkinter import *
import tkinter.messagebox
import appdirs
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

#------------------------------------------------------ logbook message box
def lbMsgBox(l):
    tkinter.messagebox._show(message=l)

#------------------------------------------------------ Check Database
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
            lb_create_database()

    else:
        lb_create_database()

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
def lb_mode_convert(sm):
    cdb(dbf)
    ccdb.execute('SELECT mode FROM submode_list WHERE submode=?', (sm,))
    for row in ccdb.fetchall():
        mode = row[0]        

    conn.close()
    return mode

#------------------------------------------------- band conversion from database
def lb_band_convert(tf):
    cdb(dbf)
    ccdb.execute('SELECT band FROM band_list WHERE freq=?', (tf,))
    for row in ccdb.fetchall():
        band = row[0]

    conn.close()
    return band

#-------------------------------------------------------- gen meteor shower list
def lb_gen_mslist():
    cdb(dbf)
    ccdb.row_factory = lambda cursor, row: row[0]
    ms_list = ccdb.execute('SELECT ms_name FROM ms_shower ORDER BY ms_name ASC').fetchall()
    conn.close()
    return ms_list

#------------------------------------------------- grid square lookup from call3
def lb_whois(hiscall):
    query_time1=""
    query_time2=""
    
    if lbDebug==1:
        query_time1 = time.time()
    
    cdb(dbf)
    ccdb.execute('SELECT gridsquare FROM call3 WHERE call=?', (hiscall,))
    data=ccdb.fetchone()
    conn.close()

    if data==None:
        s=""
        if lbDebug==1:
            print("%s Was Not Found In CALL3 Database" % (hiscall))
    else:
        s=data[0]

    if lbDebug==1:
        query_time2 = (time.time()-query_time1)
        print("%s Grid Lookup Took %.5f seconds" % (hiscall, query_time2))

    return s
   
#------------------------------------------------ add the QSO to SQLit3 database
def lb_addqso(MCALL, MGRID, CALL, GRIDSQUARE, QSO_DATE, TIME_ON, QSO_DATE_OFF, TIME_OFF, SUBMODE, MODE, RST_SENT, RST_RCVD, TX_PWR, BAND, QSO_TYPE, MS_SHOWER, NR_BURSTS, NR_PINGS, VUCC_GRIDS, C3UPD):
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
    
    if C3UPD==1:
        ccdb.execute('''REPLACE INTO call3 (call, gridsquare, force_init, last_update) VALUES (?,?,?,?)''', (CALL,GRIDSQUARE,FORCE_INIT,LUPDATE))
        conn.commit()
    
    conn.close()

    try:
        if lbDebug==1:
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
            print("Loogged QSO..: %s" % CALL, GRIDSQUARE, QSO_DATE_OFF, TIME_OFF, SUBMODE)
            
    except NameError as err:
        print("\n*********")
        print("Name error: {0}".format(err))
        print("The QSO **was not** added to:", dbname)
        print("*********")

    except:
        print("Unexpected error:", sys.exc_info()[0])
        raise

#------------------------------------------------------------------ Clear screen
def lb_clear_screen():
    if sys.platform == 'win32':
        os.system('cls')
    else:
        os.system('clear')

#--------------------------------------------------------------- Create Database
def lb_create_database():
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

