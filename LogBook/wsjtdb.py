# -*- coding: UTF-8 -*-
#-------------------------------------------------------------------------------
# This file is part of the WSJT application
#
# Author........: Greg Beam, KI7MT, <ki7mt@yahoo.com>
# File Name.....: wsjtdb.py
# Description...: WSJT Database Interface Module
# 
# Copyright (C) 2001-2015 Joseph Taylor, K1JT
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

# required modules
import os, sys, time, csv
import sqlite3 as lite
from glob import glob
from os.path import expanduser
from tkinter import *

# process paths and variables
topdir = os.getcwd()
dbdir = os.path.join(topdir, 'Logbook', 'database')
dbackup = os.path.join(dbdir, 'LogBook', 'backup')
wsjtdb = os.path.join(dbdir, 'wsjtdb.db')

testdb = os.path.join(dbdir, 'testdb.db')

wsjtsql = os.path.join(dbdir, 'wsjtdb.sql')
c3csv = os.path.join(dbdir, 'call3.csv')
log_db=(testdb)


################################################################################
#                                                                              #
#  PYTHON DATA TABLES                                                          #
#                                                                              #
################################################################################
'''
 DATA TYPE
 Not all of the data types are used in WSJT at this time.
 
 A: AwardList
  B: Boolean
  D: Date
  E: Enumeration
  G: Multi-line international string
  I: International string
  L: Location
  M: Multi-line string
  N: Number
  S: String
  T: Time

 Data and file type names are CAP as they will be used for ADIF generation
'''
logbook_data_types = ["A",
        "B",
        "D",
        "E",
        "G",
        "I",
        "L",
        "M",
        "N",
        "S",
        "T"
]

#--------------------------------------------------------------- ADIF Field Types
'''
 
 These fileds match the logbook table. The intension is to mirror the logform / 
 dialog displayd with WSJT-X with the log QSO form is presented

 This table, in particualr, only specifies the Data Type for the field.

'''
logbook_field_types = {"CALL": "S", 
        "QSO_DATE": "D",
        "TIME_ON": "T",
        "BAND": "E",
        "MODE": "E",
        "SUBMODE": "E",
        "TX_PWR": "N",
        "RST_SENT": "S",
        "RST_RCVD": "S",
        "GRIDSQUARE": "S", 
        "NAME": "S",
        "COMMENT": "S"
}

#--------------------------------------------------------------- BAND translation
'''
 
 This Python dictionary trnaslates nfreq() from WSJT script, into the Band
 designator for entry into the SQLite DB.

'''
logbook_bands = {"2": "160m",
        "4": "80m",
        "7": "40m",
        "10": "30m",
        "14": "20m",
        "18": "17m",
        "21": "15m",
        "24": "12m",
        "28": "12m",
        "50": "2m",
        "70": "4m",
        "144": "2m",
        "222": "1.25m",
        "432": "70cm",
        "902": "33cm",
        "1296": "23cm",
        "3456": "9cm",
        "5760": "6cm",
        "10368": "3cm",
        "24048": "1.25cm"
}

#--------------------------------------------------------------- BAND translation
'''
 
MODE / SUBMODE CLASSIFICATION ( based on ADIF v3.0.4 )

 The fisrt column in each row is the "Submode", which is them mapped to the
 ADIF standard or parent MODE or classificaiton.

 If a mode does not exist in the ADIF specification, and is a digial mode,
 it gets mapped to "DATA" by LoTW / eQSL.

 It is *not recommended* to add custom mapping to tQSL as that will cause you
 problems later doan the log if/when the mode is accepted as a primary mode, then
 added to the ADIF specification.

'''
logbook_modes = {"PCW": "CW",
        "CW": "CW",
        "FSK441": "FSK441",
        "ISCAT-A": "ISCAT",
        "ISCAT-B": "ISCAT",
        "ISCAT-B": "ISCAT",
        "JT4A": "JT4",
        "JT4B": "JT4",
        "JT4C": "JT4",
        "JT4D": "JT4",
        "JT4E": "JT4",
        "JT4F": "JT4",
        "JT4G": "JT4",
        "JT6M": "JT6M",
        "JT9-1": "JT9",
        "JT9-2": "JT9",
        "JT9-5": "JT9",
        "JT9-10": "JT9",
        "JT9-10": "JT9",
        "JT44": "JT44",
        "JT65A": "JT65",
        "JT65B": "JT65",
        "JT65B2": "JT65",
        "JT65C": "JT65",
        "JT65C2": "JT65",
        "WSPR-2": "WSPR",
        "WSPR-15": "WSPR",
}

################################################################################
#                                                                              #
#  TEST DATABASE FUNCTIONS                                                     #
#                                                                              #
################################################################################

def clearscreen():
    '''' * Simple clear screen function used for testing locally
         * ALso set the GUI widget Icon file
    '''
    if sys.platform == 'win32':
        os.system('cls')
        icon = ("wsjt.ico")
    else:
        os.system('clear')
        icon =  ("wsjt.jpg")

#--------------------------------------------------------------- SQLite3 version
def test_sql3v():
    ''' fetch the SQLite Version '''
    con = lite.connect(log_db)
    c = con.cursor()
    c.execute('SELECT SQLITE_VERSION()')
    Sv = c.fetchone()
    con.close()
    print(" SQLite version ......: %s" % Sv)


#--------------------------------------------------------------- number of tables
def test_ntables():    
    ''' count the number of tables in the database'''
    con = lite.connect(log_db)
    c = con.cursor()
    c.execute("SELECT Count(*) as nTables FROM sqlite_master where type='table';")
    Nt = c.fetchone()
    con.close()
    print(" Number of Tables ....: %s" % Nt)


#--------------------------------------------------------------- call3 entries
def test_c3entries():    
    ''' count the number of records in Call3 Table '''
    con = lite.connect(log_db)
    c = con.cursor()
    c.execute("SELECT Count(*) FROM call3;")
    C3 = c.fetchone()
    con.close()
    print(" Call3 Record Count ..: %s" % C3)


#--------------------------------------------------------------- testdb entries
def test_logentries():    
    ''' count the number of records in Call3 Table '''
    con = lite.connect(log_db)
    c = con.cursor()
    c.execute("SELECT Count(*) FROM log_db;")
    Lc = c.fetchone()
    con.close()
    print(" Main Log Count ......: %s" % Lc)


#--------------------------------------------------------------- create test db
def create_test_db():
    '''
    Test function is to create a test database, tables and insert call3 data.

    TO-DO: consolidate functions to allow argv input for either
    the test database or the main log database.
        
    '''
    clearscreen()
    query_time1 = time.time() # start script 
    print("----------------------------------------")
    print("GENERATE TEST DATABASE")
    print("----------------------------------------")       
    print(" Database ............:%s", log_db)
        
    if os.path.exists(log_db):
        print(" Remove old DB .......: OK")
        os.remove(log_db)
    
    con = lite.connect(log_db)
    c = con.cursor()
    print(" Reading SQL input ...: OK")
    fd = open(wsjtsql, 'r')
    script = fd.read()
    print(" Importing data ......: OK")
    c.executescript(script)
    fd.close()
    c3data = csv.reader(open(c3csv))
    c.executemany('''INSERT into call3(id, call, gridsquare, force_init,
                previous_call, comment, last_update)
                values (?, ?, ?, ?, ?, ?, ?);''', c3data)
    print(" Commit changes ......: OK\n")
    con.commit()
    c.close()

    print("DATABASE QUERIES")
    con = lite.connect(log_db)
    c = con.cursor()
    c.execute('SELECT SQLITE_VERSION()')
    Sv = c.fetchone()
    con.close()
    print(" SQLite version ......: %s" % Sv)

    con = lite.connect(log_db)
    c = con.cursor()
    c.execute("SELECT Count(*) as nTables FROM sqlite_master where type='table';")
    Nt = c.fetchone()
    con.close()
    print(" Number of Tables ....: %s" % Nt)

    con = lite.connect(log_db)
    c = con.cursor()
    c.execute("SELECT Count(*) FROM logbook;")
    Lc = c.fetchone()
    con.close()
    print(" Main Log Count ......: %s" % Lc)

    con = lite.connect(log_db)
    c = con.cursor()
    c.execute("SELECT Count(*) FROM call3;")
    C3 = c.fetchone()
    con.close()
    print(" Call3 Record Count ..: %s" % C3)

    query_time2 = (time.time()-query_time1) # end script timer
    print(" Execution time.......: %.5f seconds\n" % query_time2)

    return None
    
# END OF TEST FUNCTIONS


################################################################################
#                                                                              #
#  QSO LOGGING FUNCTIONS                                                       #
#                                                                              #
################################################################################
''''

 Thesese functions are uses to trnaslate various WSJT variables and prepare
 SQL statments for adding QSO data to the logbook.

 BASIC PROCESS STEPS

 * call_entry_var       --> get the worked station callsign ( var )
 * date_entry_var       --> get the GMT date for the QSO ( var )
 * time_entry_ver       --> get the logging time for the qso (var )
 * band_entry_var       --> get the band  worked ( var )
 * mode_entry_var       --> get the mode worked ( var )
 * submode_entry_var    --> get the Submode worked ( var )
 * rpt_sent_var         --> get the report sent ( var )
 * rpt_rcvd_var         --> get the report sent ( var )
 * grid_entry_var       --> get the worked station grid square ( var )
 * name_entry_var       ( TO-DO: only used when the Logbook form is finished )
 * comment_entry_var    ( TO-DO: only used when the Logbook form is finished )
 * entry_stmt           --> Create SQL entry statement
 * execute_entry        --> Add the record

'''
#--------------------------------------------------------------- call entry var
def call_entry_var():
    pass


#--------------------------------------------------------------- date entry var
def date_entry_var():
    pass


#--------------------------------------------------------------- time entry var
def time_entry_var():
    pass


#--------------------------------------------------------------- band entry var
def band_entry_var():
    pass


#--------------------------------------------------------------- band entry var
def band_entry_var():
    # Note: not all ADIF bands are represented, only those listed
    # in the Band Menubar of WSJT are represented
    # now set the band_variable
    if tf == '2':
        band_entry='160m'
    elif tf == '4':
        band_entry='80m'
    elif tf == '7':
        band_entry='40m'
    elif tf == '10':
        band_entry='30m'
    elif tf == '14':
        band_entry='20m'
    elif tf == '18':
        band_entry='17m'
    elif tf == '21':
        band_entry='15m'
    elif tf == '24':
        band_entry='12m'
    elif tf == '28':
        band_entry='10m'
    elif tf == '50':
        band_entry='6m'
    elif tf == '70':
        band_entry='4m'
    elif tf == '144':
        band_entry='2m'
    elif tf == '222':
        band_entry='1.25m'
    elif tf == '432':
        band_entry='70cm'
    elif tf == '902':
        band_entry='33cm'
    elif tf == '1296':
        band_entry='23'
    elif tf == '3456':
        band_entry='9cm'
    elif tf == '5760':
        band_entry='6cm'
    elif tf == '10368':
        band_entry='3cm'
    elif tf == '24048':
        band_entry='1.25cm'
    else:
        band_entry='' # create null value if nothing is passes from (tf)


#--------------------------------------------------------------- mode entry var
def mode_entry_var():
    pass


#--------------------------------------------------------------- submode entry var
def submode_entry_var():
    pass


#--------------------------------------------------------------- rpt sent entry var
def rpt_sent_entry_var():
    pass


#--------------------------------------------------------------- rpt rcvd entry var
def rpt_rcvd_entry_var():
    pass


#--------------------------------------------------------------- grid entry var
def grid_entry_var():
    pass


#--------------------------------------------------------------- name entry var
def name_entry_var():
    pass


#--------------------------------------------------------------- comment entry var
def comment_entry_var():
    pass


#--------------------------------------------------------------- entry_statement
def entry_stmt():
    pass


#--------------------------------------------------------------- execute_entry
def execute_entry():
    pass

def logui():
    import tkinter
    form = tkinter.Tk()
    form.wm_title('WSJT Logbook')
    form.iconbitmap("wsjt.ico")
    # top frame
    stepOne = tkinter.LabelFrame(form, text=" 1. Verify Log Data is Correct : ")
    stepOne.grid(row=0, columnspan=7, sticky='W', padx=5, pady=5, ipadx=5, ipady=5)

    # middle frame
    stepTwo = tkinter.LabelFrame(form, text=" 2. Check Call3 Table Data : ")
    stepTwo.grid(row=2, columnspan=7, sticky='W', padx=5, pady=5, ipadx=5, ipady=5)

    stepThree = tkinter.LabelFrame(form, text="3. Make a Choice... :")
    stepThree.grid(row=3, columnspan=7, sticky='W', padx=5, pady=5, ipadx=5, ipady=5)

# -------------------------------------------------------------- First Framt (top)
    # Call
    inCallLbl = tkinter.Label(stepOne, text="Callsign")
    inCallLbl.grid(row=0, column=0, sticky='W', padx=5, pady=2)
    inCallTxt = tkinter.Entry(stepOne)
    inCallTxt.grid(row=1, column=0, columnspan=1, padx=5, sticky="WE", pady=3)

    # Date
    inDateLbl = tkinter.Label(stepOne, text="Date")
    inDateLbl.grid(row=0, column=1, sticky='W', padx=5, pady=2)
    inDateTxt = tkinter.Entry(stepOne)
    inDateTxt.grid(row=1, column=1, columnspan=1, padx=5, sticky="WE", pady=3)

    # Time
    inTimeLbl = tkinter.Label(stepOne, text="Time")
    inTimeLbl.grid(row=0, column=2, sticky='W', padx=5, pady=2)
    inTimeTxt = tkinter.Entry(stepOne)
    inTimeTxt.grid(row=1, column=2, columnspan=1, padx=5, sticky="WE", pady=3)

    # Mode
    inModeLbl = tkinter.Label(stepOne, text="Mode")
    inModeLbl.grid(row=0, column=3, sticky='W', padx=5, pady=2)
    inModeTxt = tkinter.Entry(stepOne)
    inModeTxt.grid(row=1, column=3, columnspan=1, padx=5, sticky="WE", pady=3)

    # Band
    inBandLbl = tkinter.Label(stepOne, text="Band")
    inBandLbl.grid(row=0, column=4, sticky='W', padx=5, pady=2)
    inBandTxt = tkinter.Entry(stepOne)
    inBandTxt.grid(row=1, column=4, columnspan=1, padx=5, sticky="WE", pady=3)

    # Rpt_Sent
    inRsentLbl = tkinter.Label(stepOne, text="Rpt Sent")
    inRsentLbl.grid(row=2, column=0, sticky='W', padx=5, pady=2)
    inRsentTxt = tkinter.Entry(stepOne)
    inRsentTxt.grid(row=3, column=0, columnspan=1, padx=5, sticky="WE", pady=3)

    # Rpt_Rcvd
    inRrcvdLbl = tkinter.Label(stepOne, text="Rpt Rcvd")
    inRrcvdLbl.grid(row=2, column=1, sticky='W', padx=5, pady=2)
    inRrcvdTxt = tkinter.Entry(stepOne)
    inRrcvdTxt.grid(row=3, column=1, columnspan=1, padx=5, sticky="WE", pady=3)

    # Grid
    inGridLbl = tkinter.Label(stepOne, text="Grid")
    inGridLbl.grid(row=2, column=2, sticky='W', padx=5, pady=2)
    inGridTxt = tkinter.Entry(stepOne)
    inGridTxt.grid(row=3, column=2, columnspan=1, padx=5, sticky="WE", pady=3)

    # Name
    inNameLbl = tkinter.Label(stepOne, text="Name")
    inNameLbl.grid(row=2, column=3, sticky='W', padx=5, pady=2)
    inNameTxt = tkinter.Entry(stepOne)
    inNameTxt.grid(row=3, column=3, columnspan=1, padx=5, sticky="WE", pady=3)

    # EME COntact
    inEme = tkinter.Checkbutton(stepOne, text="Contact is an EME QSO", onvalue=1, offvalue=0)
    inEme.grid(row=4, column=0, sticky='W', padx=5, pady=2)

    # TxPwr
    inTxpwrLbl = tkinter.Label(stepOne, text="Tx Pwr")
    inTxpwrLbl.grid(row=6, column=0, sticky='W', padx=5, pady=2)
    inTxpwrTxt = tkinter.Entry(stepOne)
    inTxpwrTxt.grid(row=7, column=0, columnspan=1, padx=5, sticky="WE", pady=3)

    # Retain Tx Pwr Setting
    retainPwr = tkinter.Checkbutton(stepOne, text="Retain", onvalue=1, offvalue=0)
    retainPwr.grid(row=7, column=1, sticky='W', padx=5, pady=2)

    # Comment
    inCommentLbl = tkinter.Label(stepOne, text="General Comments")
    inCommentLbl.grid(row=8, column=0, sticky='W', padx=5, pady=2)
    inCommentTxt = tkinter.Entry(stepOne)
    inCommentTxt.grid(row=9, column=0, columnspan=7, rowspan=2, padx=5, sticky="WE", pady=3)

    # Retain Comment Setting
    retainComment = tkinter.Checkbutton(stepOne, text="Retain", onvalue=1, offvalue=0)
    retainComment.grid(row=9, column=8, sticky='E', padx=5, pady=2)

#--------------------------------------------------------------- Second Frame (middle)
    # Call
    inC3CallLbl = tkinter.Label(stepTwo, text="Callsign")
    inC3CallLbl.grid(row=0, column=0, sticky='W', padx=5, pady=2)
    inC3CallTxt = tkinter.Entry(stepTwo)
    inC3CallTxt.grid(row=1, column=0, columnspan=1, padx=5, sticky="WE", pady=3)

    # Grid
    inC3GridLbl = tkinter.Label(stepTwo, text="Grid")
    inC3GridLbl.grid(row=0, column=1, sticky='W', padx=5, pady=2)
    inC3GridTxt = tkinter.Entry(stepTwo)
    inC3GridTxt.grid(row=1, column=1, columnspan=1, padx=5, sticky="WE", pady=3)

    # Previous Calls
    inC3PcallLbl = tkinter.Label(stepTwo, text="Previous")
    inC3PcallLbl.grid(row=0, column=2, sticky='W', padx=5, pady=2)
    inC3PcallTxt = tkinter.Entry(stepTwo)
    inC3PcallTxt.grid(row=1, column=2, columnspan=1, padx=5, sticky="WE", pady=3)

   # Previous Calls
    inC3LastUpdateLbl = tkinter.Label(stepTwo, text="Last Update")
    inC3LastUpdateLbl.grid(row=0, column=3, sticky='W', padx=5, pady=2)
    inC3LastUpdateTxt = tkinter.Entry(stepTwo)
    inC3LastUpdateTxt.grid(row=1, column=3, columnspan=1, padx=5, sticky="WE", pady=3)

    # EME Contact
    inEme = tkinter.Checkbutton(stepTwo, text="Contact is an EME QSO", onvalue=1, offvalue=0)
    inEme.grid(row=2, column=0, sticky='W', padx=5, pady=2)

    # CALL3 Comment field
    inC3commentLbl = tkinter.Label(stepTwo, text="General Comments")
    inC3commentLbl.grid(row=3, column=0, sticky='W', padx=5, pady=2)
    inC3commentTxt = tkinter.Entry(stepTwo)
    inC3commentTxt.grid(row=4, column=0, columnspan=7, rowspan=2, padx=5, sticky="WE", pady=3)


#--------------------------------------------------------------- Third Frame (bottom)
    outSaveBtn = tkinter.Button(stepThree, text="Save", fg="black")
    outSaveBtn.grid(row=0, column=0, sticky='W', padx=5, pady=2)
    
    outCancelBtn = tkinter.Button(stepThree, text="Cancel", fg="black", command=form.quit)
    outCancelBtn.grid(row=0, column=2, sticky='W', padx=5, pady=2)
    
    form.mainloop()
    return


if __name__ == '__main__':
    logui()
