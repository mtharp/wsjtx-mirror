# -*- coding: UTF-8 -*-
#-------------------------------------------------------------------------------
# This file is part of the WSJT application
#
# Author........: Greg Beam, KI7MT, <ki7mt@yahoo.com>
# File Name.....: logbook.py
# Description...: WSJT Loogbook Interface Module
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

import sys, os, csv
import sqlite3 as lite

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

'''
 lb_band and lb_mode are testing lists for manual selection during
 UI development.
'''
b_band=('160m','80m','40m','30m','20m','17m','15m','12m','10m','2m',"4m",\
        '1.25m','70cm','33cm','23cm','9cm','6cm','3cm','1.25cm')
	
lb_mode=('CW','ISCAT-A','ISCAT-B','ISCAT-B','JT44','JT4A','JT4B','JT4C','JT4D',
        'JT4E','JT4F','JT4G','JT65A','JT65B','JT65B2','JT65C','JT65C2','JT6M',\
        'JT9-1','JT9-10','JT9-2','JT9-30','JT9-5','SK441','WSPR-15','WSPR-2')

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

def logqso_form():
    lb_operator=ToRadio.get()
    lb_date=time.strftime("%Y-%b-%d",time.gmtime())
    lb_time=time.strftime("%H:%M",time.gmtime())
    lb_gridsquare=HisGrid.get()
    lb_rpt_sent=report.get()
    lb_submode=g.mode
    lb_band=tf
    lb_rpt_rcvd=report.get()

    form = Toplevel()
    form.title('WSJT Logbook')
    form.resizable(0,0)
    #------------------------------------------------------ Main UI Frames
    # top frame (lbf1)
    lbf1 = LabelFrame(form, text="  QSO Log Table ")
    lbf1.grid(row=0, columnspan=7, sticky='W', padx=5, pady=5, ipadx=5, ipady=5)

    # bottom left (lbf2)
    lbf2 = LabelFrame(form, text="  Call3 Data Table")
    lbf2.grid(row=2, columnspan=4, sticky='W', padx=5, pady=5, ipadx=8, ipady=8)

    # bottom right (lbf2)
    lbf3 = LabelFrame(form, text="  Save Options ")
    lbf3.grid(row=2, column=6, columnspan=1, sticky='N', padx=4, pady=4, ipadx=0, ipady=0)

    #------------------------------------------------------ QSO Log Frame
    # Call Pmw.EntryField
    lbf1_operator_Lbl = Label(lbf1, text="Callsign")
    lbf1_operator_Lbl.grid(row=0, column=0, sticky='W', padx=5, pady=2)
    lbf1_operator_txt = Entry(lbf1)
    lbf1_operator_txt.insert(END, lb_operator)
    lbf1_operator_txt.grid(row=1, column=0, columnspan=1, padx=5, sticky="WE", pady=3)

    # Date Pmw.EntryField w/Validator
    lbf1_qso_date_lbl = Label(lbf1, text="Date (UTC)")
    lbf1_qso_date_lbl.grid(row=0, column=1, sticky='W', padx=5, pady=2)
    lbf1_qso_date_txt = Entry(lbf1)
    lbf1_qso_date_txt.insert(END, lb_date)
    lbf1_qso_date_txt.grid(row=1, column=1, columnspan=1, padx=5, sticky="WE", pady=3)

    # Time Pmw.EntryField w/Validator
    lbf1_time_on_lbl= Label(lbf1, text="Time  (UTC)")
    lbf1_time_on_lbl.grid(row=0, column=2, sticky='W', padx=5, pady=2)
    lbf1_time_on_txt = Entry(lbf1)
    lbf1_time_on_txt.insert(END, lb_time)
    lbf1_time_on_txt.grid(row=1, column=2, columnspan=1, padx=5, sticky="WE", pady=3)

    # Submode Selection Pmw.Combobox
    lbf1_submode_lbl = Label(lbf1, text="Mode Select")
    lbf1_submode_lbl.grid(row=0, column=3, sticky='W', padx=5, pady=2)
    lbf1_submode_txt = Entry(lbf1)
    lbf1_submode_txt.insert(END, lb_submode)
    lbf1_submode_txt.grid(row=1, column=3, columnspan=1, padx=5, sticky="WE", pady=3)

    # Band Slection Pmw.ComboBox
    lbf1_band_lbl = Label(lbf1, text="Band Select")
    lbf1_band_lbl.grid(row=0, column=4, sticky='W', padx=5, pady=2)
    lbf1_band_txt = Entry(lbf1)
    lbf1_band_txt.insert(END, lb_band)
    lbf1_band_txt.grid(row=1, column=4, columnspan=1, padx=5, sticky="WE", pady=3)

    # Rpt_Sent Pmw.EntryField 
    lbf1_rpt_sent_lbl = Label(lbf1, text="Rpt Sent")
    lbf1_rpt_sent_lbl.grid(row=2, column=0, sticky='W', padx=5, pady=2)
    lbf1_rpt_sent_txt = Entry(lbf1)
    lbf1_rpt_sent_txt.grid(row=3, column=0, columnspan=1, padx=5, sticky="WE", pady=3)

    # Rpt_Rcvd
    lbf1_rpt_rcvd_lbl = Label(lbf1, text="Rpt Rcvd")
    lbf1_rpt_rcvd_lbl.grid(row=2, column=1, sticky='W', padx=5, pady=2)
    lbf1_rpt_rcvd_txt = Entry(lbf1)
    lbf1_rpt_rcvd_txt.insert(END, lb_rpt_rcvd)
    lbf1_rpt_rcvd_txt.grid(row=3, column=1, columnspan=1, padx=5, sticky="WE", pady=3)

    # Grid
    lbf1_gridsquare_lbl = Label(lbf1, text="Grid")
    lbf1_gridsquare_lbl.grid(row=2, column=2, sticky='W', padx=5, pady=2)
    lbf1_gridsquare_txt = Entry(lbf1)
    lbf1_gridsquare_txt.insert(END, lb_gridsquare)
    lbf1_gridsquare_txt.grid(row=3, column=2, columnspan=1, padx=5, sticky="WE", pady=3)

    # Name
    lbf1_name_lbl = Label(lbf1, text="Name")
    lbf1_name_lbl.grid(row=2, column=3, sticky='W', padx=5, pady=2)
    lbf1_name_txt = Entry(lbf1)
    lbf1_name_txt.grid(row=3, column=3, columnspan=1, padx=5, sticky="WE", pady=3)

    # TxPwr
    lbf1_tx_pwr_lbl = Label(lbf1, text="Tx Pwr")
    lbf1_tx_pwr_lbl.grid(row=2, column=4, sticky='W', padx=5, pady=2)
    lbf1_tx_pwr_txt = Entry(lbf1)
    lbf1_tx_pwr_txt.grid(row=3, column=4, columnspan=1, padx=5, sticky="WE", pady=3)

    # Comment
    lbf1_comment_lbl= Label(lbf1, text="General Comments")
    lbf1_comment_lbl.grid(row=7, column=0, sticky='W', padx=5, pady=2)
    lbf1_comment_txt = Entry(lbf1)
    lbf1_comment_txt.grid(row=8, column=0, columnspan=3, rowspan=2, padx=5, sticky="WE", pady=3)


    #------------------------------------------------------ Call3 Data Table
    # C3 Call
    lbf2_operator_lbl = Label(lbf2, text="Callsign")
    lbf2_operator_lbl.grid(row=0, column=0, sticky='W', padx=5, pady=2)
    lbf2_operator_txt = Entry(lbf2)
    lbf2_operator_txt.grid(row=1, column=0, columnspan=1, padx=5, sticky="WE", pady=3)

    # C3 Grid
    lbf2_gridsquare_lbl = Label(lbf2, text="Grid")
    lbf2_gridsquare_lbl.grid(row=0, column=1, sticky='W', padx=5, pady=2)
    lbf2_gridsquare_txt = Entry(lbf2)
    lbf2_gridsquare_txt.grid(row=1, column=1, columnspan=1, padx=5, sticky="WE", pady=3)

    # C3 notes
    lbf2_notes_lbl= Label(lbf2, text="Previous Calls")
    lbf2_notes_lbl.grid(row=0, column=2, sticky='W', padx=5, pady=2)
    lbf2_notes_txt = Entry(lbf2)
    lbf2_notes_txt.grid(row=1, column=2, columnspan=1, padx=5, sticky="WE", pady=3)

    # C3 Last Update ( Non ADIF Spec Field )
    lbf2_last_update_lbl = Label(lbf2, text="Last Update")
    lbf2_last_update_lbl.grid(row=0, column=3, sticky='W', padx=5, pady=2)
    lbf2_last_update_txt = Entry(lbf2)
    lbf2_last_update_txt.grid(row=1, column=3, columnspan=1, padx=5, sticky="WE", pady=3)

    # C3 Comment field
    lbf2_comment_lbl = Label(lbf2, text="General Comments")
    lbf2_comment_lbl.grid(row=3, column=0, sticky='W', padx=5, pady=2)
    lbf2_comment_txt = Entry(lbf2)
    lbf2_comment_txt.grid(row=4, column=0, columnspan=3, rowspan=2, padx=5, sticky="WE", pady=3)


    #------------------------------------------------------ Save Options
    # Update Call3 Data (checkbox)
    lbf3_update_lbf2_txt = Checkbutton(lbf3, text="Update Call3 Table", onvalue=1, offvalue=0)
    lbf3_update_lbf2_txt.grid(row=1, column=0, sticky='W', padx=5, pady=2)

    # EME QSO Y/N (checkbox)
    lbf3_is_eme_qso_txt = Checkbutton(lbf3, text="Contact is EME QSO", onvalue=1, offvalue=0)
    lbf3_is_eme_qso_txt.grid(row=2, column=0, sticky='W', padx=5, pady=2)

    # Save Buttons
    lbf3_save_qso_button_txt = Button(lbf3, text=" Save ", fg="black", activebackground="green", background="green", command=form.destroy)
    lbf3_save_qso_button_txt.grid(row=3, column=0, sticky='N', padx=1, pady=1, ipadx=1, ipady=1)

    # Cancel Button
    lbf3_cancel_button_txt = Button(lbf3, text="Cancel", fg="black", activebackground="red", background="red", command=form.destroy)
    lbf3_cancel_button_txt.grid(row=4, column=0, sticky='S', padx=1, pady=1, ipadx=1, ipady=1)

    form.mainloop()

# END WSJTDB MODULE
