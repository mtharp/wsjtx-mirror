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

import os, sys, time, csv
import sqlite3 as lite

# Sqlite3 variables
wsjtdb="database/wsjt.db"
wsjtsql="database/wsjtdb.sql"
testdb="database/test.db"
c3csv="database/call3.csv"

#--------------------------------------------------------------- clean screen
def clearscreen():
    '''' simple clear screen function used for testing locally '''
    if sys.platform == 'win32':
        os.system('cls')
    else:
        os.system('clear')

#--------------------------------------------------------------- SQLite3 version
def sql3v():
    ''' fetch the SQLite Version '''
    con = lite.connect(wsjtdb)
    c = con.cursor()
    c.execute('SELECT SQLITE_VERSION()')
    Sv = c.fetchone()
    con.close()
    print(" SQLite version ......: %s" % Sv)

#--------------------------------------------------------------- number of tables
def ntables():    
    ''' count the number of tables in the database'''
    con = lite.connect(wsjtdb)
    c = con.cursor()
    c.execute("SELECT Count(*) as nTables FROM sqlite_master where type='table';")
    Nt = c.fetchone()
    con.close()
    print(" Number of Tables ....: %s" % Nt)

#--------------------------------------------------------------- call3 entries
def c3entries():    
    ''' count the number of records in Call3 Table '''
    con = lite.connect(wsjtdb)
    c = con.cursor()
    c.execute("SELECT Count(*) FROM call3;")
    C3 = c.fetchone()
    con.close()
    print(" Call3 Record Count ..: %s" % C3)

#--------------------------------------------------------------- logbook entries
def logentries():    
    ''' count the number of records in Call3 Table '''
    con = lite.connect(wsjtdb)
    c = con.cursor()
    c.execute("SELECT Count(*) FROM logbook;")
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
    print(" Database ............: test.db")

    if os.path.isfile(testdb):
        print(" Remove old DB .......: OK")
        os.remove(testdb)
   
    con = lite.connect(testdb)
    c = con.cursor()
    print(" Reading SQL input ...: OK")
    fd = open(wsjtsql, 'r')
    script = fd.read()
    print(" Importing data ......: OK")
    c.executescript(script)
    fd.close()
    c3data = csv.reader(open(c3csv))
    c.executemany('''INSERT into call3(id, call, grid, mode, previous_call,
                     comment, last_update) values (?, ?, ?, ?, ?, ?, ?);''', c3data)
    print(" Commit changes ......: OK\n")
    con.commit()
    c.close()

    print("DATABASE QUERIES")
    con = lite.connect(testdb)
    c = con.cursor()
    c.execute('SELECT SQLITE_VERSION()')
    Sv = c.fetchone()
    con.close()
    print(" SQLite version ......: %s" % Sv)

    con = lite.connect(testdb)
    c = con.cursor()
    c.execute("SELECT Count(*) as nTables FROM sqlite_master where type='table';")
    Nt = c.fetchone()
    con.close()
    print(" Number of Tables ....: %s" % Nt)

    con = lite.connect(testdb)
    c = con.cursor()
    c.execute("SELECT Count(*) FROM logbook;")
    Lc = c.fetchone()
    con.close()
    print(" Main Log Count ......: %s" % Lc)

    con = lite.connect(testdb)
    c = con.cursor()
    c.execute("SELECT Count(*) FROM call3;")
    C3 = c.fetchone()
    con.close()
    print(" Call3 Record Count ..: %s" % C3)

    query_time2 = (time.time()-query_time1) # end script timer
    print(" Execution time.......: %.5f seconds\n" % query_time2)

#--------------------------------------------------------------- test the functions
if __name__ == '__main__':
    ''' print the data to screen '''
    query_time1 = time.time() # start script 
    clearscreen()
    print("----------------------------------------")
    print("DATABASE CONNECTION TEST")
    print("----------------------------------------")       
    print(" Database ............:", wsjtdb)
    sql3v()
    ntables()
    logentries()
    c3entries()
    query_time2 = (time.time()-query_time1) # end script timer
    print(" Execution Time.......: %.5f seconds\n" % query_time2)

 # end wsjtdb module
