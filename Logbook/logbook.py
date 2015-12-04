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

import sys, os, time, Pmw, csv
from tkinter import *
import sqlite3
import appdirs
from appdirs import AppDirs

dbf='test.db'
wsjtdb='wsjt.db'
testdb='test.db'
sql_file='logbook.sql'
c3csv='call3.csv'

# For testing FSH directories
db_prefix = AppDirs("WSJT", appauthor='', version='', multipath='')
appdir=os.getcwd()
dbdir=(db_prefix.user_data_dir)
dbdir = os.path.join(appdir, 'logbook')
dbackup = os.path.join(appdir, 'logbook')
wsjtdb = os.path.join(dbdir, 'wsjt.db')
testdb = os.path.join(dbdir, 'test.db')
sql_file = os.path.join(dbdir, 'logbook.sql')
c3csv = os.path.join(dbdir, 'call3.csv')

    # make the new FSH directories
    for p in (dbdir):
        try:
            if not os.path.exists(p):
                os.makedirs(p)
        except:
            pass

#------------------------------------------------------ Submode dictionary
'''
 Used to convert Submode into Mode for lb_EntryForm
'''
lb_submode={"PCW": "CW", \
            "CW": "CW", \
            "FSK441": "FSK441", \
            "ISCAT-A": "ISCAT", \
            "ISCAT-B": "ISCAT", \
            "JT6M": "JT6M", \
            "JT4A": "JT4", \
            "JT4B": "JT4", \
            "JT4C": "JT4", \
            "JT4D": "JT4", \
            "JT4E": "JT4", \
            "JT4F": "JT4", \
            "JT4G": "JT4", \
            "JT6M": "JT6M", \
            "JT9-1": "JT9", \
            "JT9-2": "JT9", \
            "JT9-5": "JT9", \
            "JT9-10": "JT9", \
            "JT9-10": "JT9", \
            "JT44": "JT44", \
            "JT65A": "JT65", \
            "JT65B": "JT65", \
            "JT65B2": "JT65", \
            "JT65C": "JT65", \
            "JT65C2": "JT65", \
            "WSPR-2": "WSPR", \
            "WSPR-15": "WSPR"
}

#------------------------------------------------------ Band dictionary
'''
 Used to convert (tf) from selected frequency to band
'''
lb_band={"2": "160m", \
        "4": "80m", \
        "7": "40m", \
        "10": "30m", \
        "14": "20m", \
        "18": "17m", \
        "21": "15m", \
        "24": "12m", \
        "28": "12m", \
        "50": "2m", \
        "70": "4m", \
        "144": "2m", \
        "222": "1.25m", \
        "432": "70cm", \
        "902": "33cm", \
        "1296": "23cm", \
        "3456": "9cm", \
        "5760": "6cm", \
        "10368": "3cm", \
        "24048": "1.25cm"
}

#------------------------------------------------------ State/Provience List
'''
 Used for select state or provience in lb_EntryForm
'''
lb_StateProv=['BC', 'MB', 'NB', 'NL', 'NS', 'NT', 'NU', 'ON', 'PE', 'QC',
'SK', 'YT', 'AL', 'AR', 'AZ', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 'IA',
'ID', 'IL', 'IN', 'KS', 'KY', 'LA', 'MA', 'MD', 'ME', 'MI', 'MN', 'MO', 'MS',
'MT', 'NC', 'ND', 'NE', 'NH', 'NJ', 'NM', 'NV', 'NY', 'OH', 'OK', 'OR', 'PA',
'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VA', 'VT', 'WA', 'WI', 'WV', 'WY'
]

#------------------------------------------------------ Clear screen
def lb_ClearScreen():
    if sys.platform == 'win32':
        os.system('cls')
    else:
        os.system('clear')

#------------------------------------------------------ Band conversion
'''
    Look up the frequency supplied from (tf), then find the associated
    band (20m, 40m, 2m, etc) for logbook entry.
    
    Examples:
              tf='14' or tf=str(g.nfreq)
              logbook.bandConvert('14')
              logbook.bandConvert(tf)
'''
def lb_BandConvert(tf):
    if tf in lb_band:
        band=(str(lb_band[tf]))
        print(tf, 'was converted to', band )
    else:
        print(tf, 'was not found in the conversion dictionary')

#------------------------------------------------------ Submode converstion
'''
    Look up the submode supplied from ( g.modes() ), then find the associated
    mode for logbook entry. e.g. JT65A --> JT65, ISCAT-B --> ISCAT
    
    Examples:
              sm='JT65A' or str(g.mode)
              logbook.submodeConvert('JT65A')
              logbook.submodeConvert(sm)
'''
def lb_SubmodeConvert(sm):
    if sm in lb_submode:
        mode=(str(lb_submode[sm]))
        print(sm, 'was converted to', mode )
    else:
        print(sm, 'was not found in the conversion dictionary')


#------------------------------------------------------ Create DB Start
def lb_CreateTestDatabase():
    lb_ClearScreen()
    query_time1 = time.time()
    print("----------------------------------------")
    print("GENERATE TEST DATABASE")
    print("----------------------------------------")       
    print(" Database ............:", dbf)        
 
    # remove old db if exists
    if os.path.exists(dbf):
        print(" Remove old DB .......: OK")
        os.remove(dbf)

    # connect to db, get SQL3 version
    db = sqlite3.connect(dbf)
    cursor = db.cursor()

    # read in the sql script file
    print(" Reading SQL input ...: OK")
    fd = open(sql_file, 'r')
    script = fd.read()

    # execute the sql script
    cursor.executescript(script)
    fd.close()
    c3data = csv.reader(open(c3csv))
    cursor.executemany('''INSERT into call3(id, call, gridsquare, force_init, 
                            previous_call, comment, last_update) 
                            values (?, ?, ?, ?, ?, ?, ?);''', c3data)

    print(" Importing data ......: OK")
    print(" Commit changes ......: OK\n")
    db.commit()    

    # get SQLite3 version
    print("DATABASE QUERIES")
    cursor.execute('SELECT SQLITE_VERSION()')
    Sv = cursor.fetchone()
    print(" SQLite version ......: %s" % Sv) 
 
    # get total tables in the database
    cursor.execute("SELECT Count(*) as nTables FROM sqlite_master where type='table';")
    Nt = cursor.fetchone()
    print(" Number of Tables ....: %s" % Nt)
    
    # get the number of records in the main log table
    cursor.execute("SELECT Count(*) FROM logbook;")
    Lc = cursor.fetchone()
    print(" Main Log Count ......: %s" % Lc)
    cursor.execute("SELECT Count(*) FROM call3;")
    C3 = cursor.fetchone()
    
    # get the number of records in the call3 table
    print(" Call3 Record Count ..: %s" % C3)
    query_time2 = (time.time()-query_time1)
    
    # close the db
    db.close() 

    # print total execution time
    print(" Execution time.......: %.5f seconds\n" % query_time2)

 #------------------------------------------------------ Logbook Entry Form
'''
    Main Logbook Entry Form
'''
def lb_EntryForm():
    # Use these for real WSJT.py script
    # lb_operator=ToRadio.get()
    #lb_date=time.strftime("%Y-%b-%d",time.gmtime())
    #lb_time=time.strftime("%H:%M",time.gmtime())
    #lb_gridsquare=HisGrid.get()
    #lb_rpt_rcvd=report.get()
    #lb_rpt_sent=report.get()
    #lb_submode=g.mode

    # For Testing Entry Form
    lb_operator="K1JT"
    lb_date=time.strftime("%Y-%b-%d",time.gmtime())
    lb_time=time.strftime("%H:%M",time.gmtime())
    lb_gridsquare="EM13"
    lb_rpt_rcvd="-10"
    lb_rpt_sent="-15"
    lb_submode="JT65A"
    
    form = Tk()
    form.title('WSJT Logbook Entry FOrm')
    form.resizable(0,0)

    #-------------------------------------------------- Logbook UI Frames
    # top frame (lbf1)
    lbf1 = LabelFrame(form, text="  QSO Log Table ")
    lbf1.grid(row=0, columnspan=7, sticky='W', padx=5, pady=5, ipadx=5, ipady=5)

    # bottom left (lbf2)
    lbf2 = LabelFrame(form, text="  Call3 Data Table")
    lbf2.grid(row=2, columnspan=4, sticky='W', padx=5, pady=5, ipadx=8, ipady=8)

    # bottom right (lbf2)
    lbf3 = LabelFrame(form, text="  Save Options ")
    lbf3.grid(row=2, column=6, columnspan=1, sticky='N', padx=4, pady=4, ipadx=0, ipady=0)

    #-------------------------------------------------- QSO Log Frame
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


    #-------------------------------------------------- Call3 Data Table
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

    #-------------------------------------------------- Save Options
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
 