#!/usr/bin/env python3
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

import sys, os, csv, time
import sqlite3

#--------------------------------------------------------------- submodes dict
'''
    Sumbodes in dictionary form
'''

lb_submodes_dict = {"PCW": "CW",
                    "CW": "CW",
                    "FSK441": "FSK441",
                    "ISCAT-A": "ISCAT",
                    "ISCAT-B": "ISCAT",
                    "JT6M": "JT6M",
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


#--------------------------------------------------------------- submodes list
'''
    Sumbodes in list form """
'''

lb_submodes_list = ('PCW',
                    'CW',
                    'ISCAT-A',
                    'ISCAT-B',
                    'JT6M',
                    'JT44',
                    'JT4A',
                    'JT4B',
                    'JT4C',
                    'JT4D',
                    'JT4E',
                    'JT4F',
                    'JT4G',
                    'JT65A',
                    'JT65B',
                    'JT65B2',
                    'JT65C',
                    'JT65C2',
                    'JT6M',
                    'JT9-1',
                    'JT9-10',
                    'JT9-2',
                    'JT9-30',
                    'JT9-5',
                    'FSK441',
                    'WSPR-15',
                    'WSPR-2'
)


#--------------------------------------------------------------- bands dict
'''
    Bands in dictionary form
'''

lb_band_dict = {"2": "160m","4": "80m","7": "40m","10": "30m","14": "20m",\
                "18": "17m","21": "15m","24": "12m","28": "12m","50": "2m",\
                "70": "4m","144": "2m","222": "1.25m","432": "70cm",\
                "902": "33cm","1296": "23cm","3456": "9cm","5760": "6cm",\
                "10368": "3cm","24048": "1.25cm"
}

#--------------------------------------------------------------- bands list
'''
    Bands in list form
'''

lb_band_list=('160m',
              '80m',
              '40m',
              '30m',
              '20m',
              '17m',
              '15m',
              '12m',
              '10m',
              '2m',
              '4m',
              '1.25m',
              '70cm',
              '33cm',
              '23cm',
              '9cm',
              '6cm',
              '3cm',
              '1.25cm'
)

#------------------------------------------------------------------------------#
#
# Global Functions
#
#------------------------------------------------------------------------------#


#--------------------------------------------------------------- cleab scren
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


#--------------------------------------------------------------- band 
def lb_band_conv():
    if tf == '2':
        value='160m'
    elif tf == '4':
        value='80m'
    elif tf == '7':
        value='40m'
    elif tf == '10':
        value='30m'
    elif tf == '14':
        value='20m'
    elif tf == '18':
        value='17m'
    elif tf == '21':
        value='15m'
    elif tf == '24':
        value='12m'
    elif tf == '28':
        value='10m'
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
        value == '6cm'
    elif tf == '10368':
        value='3cm'
    elif tf == '24048':
        value='1.25cm'
    else:
        band_entry='' # create null value if nothing is passes from (tf)

#------------------------------------------------------------------------------#
#
# Test Database
#
#------------------------------------------------------------------------------#

def testDatabase():
    ''' test basic database functions '''

    dbf='test.db'
    sql_file='logbook.sql'
    c3csv='call3.csv'

    # clear and start the script
    clearscreen()
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
    print(" Importing data ......: OK")
    cursor.executescript(script)
    fd.close()
    c3data = csv.reader(open(c3csv))
    cursor.executemany('''INSERT into call3(id, call, gridsquare, force_init,
                previous_call, comment, last_update)
                values (?, ?, ?, ?, ?, ?, ?);''', c3data)
    print(" Commit changes ......: OK\n")
    db.commit()

    # get SQL2 version
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


#------------------------------------------------------------------------------#

if __name__ == '__main__':
    testDatabase()

# END WSJTDB MODULE
