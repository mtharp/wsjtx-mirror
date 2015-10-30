# -*- coding: UTF-8 -*-
#-------------------------------------------------------------------------------
# This file is part of the WSJT application
#
# Author........: Greg Beam, KI7MT, <ki7mt@yahoo.com>
# File Name.....: wsjtdb.py
# Description...: WSJt Database Interface Module
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

import os, sys, time
import sqlite3 as lite

# Sqlite3 variables
wsjtdb="database/wsjt.db"
db_exists = os.path.exists(wsjtdb)
con = lite.connect(wsjtdb)
cur = con.cursor()

#--------------------------------------------------------------- clean screen
def clearscreen():
    '''' simple clear screen function used for testing locally '''
    if sys.platform == 'win32':
        os.system('cls')
    else:
        os.system('cls')

#--------------------------------------------------------------- SQlite3 version
def sql3v():
    ''' fetch the SQLite Version '''
    cur = con.cursor()
    cur.execute('SELECT SQLITE_VERSION()')
    Sv = cur.fetchone()
    print(" SQLite version ......: %s" % Sv)

#--------------------------------------------------------------- number of tables
def ntables():    
    ''' count the number of tables in the database'''
    cur = con.cursor()
    cur.execute("SELECT Count(*) as nTables FROM sqlite_master where type='table';")
    Nt = cur.fetchone()
    print(" Number of Tables ....: %s" % Nt)

#--------------------------------------------------------------- call3 entries
def c3entries():    
    ''' count the number of records in Call3 Table '''
    cur = con.cursor()
    cur.execute("SELECT Count(*) FROM call3;")
    C3 = cur.fetchone()
    print(" Call3 Record Count ..: %s" % C3)

#--------------------------------------------------------------- logbook entries
def logentries():    
    ''' count the number of records in Call3 Table '''
    cur = con.cursor()
    cur.execute("SELECT Count(*) FROM logbook;")
    Lc = cur.fetchone()
    print(" Main Log Count ......: %s" % Lc)

#--------------------------------------------------------------- test the functions
if __name__ == '__main__':
    ''' print the data to screen '''
    query_time1 = time.time() # start script 
    clearscreen()
    print("****************************************")
    print("DATABASE CONNECTION TEST")
    print("****************************************")       
    print(" Database ............:", wsjtdb)
    sql3v()
    ntables()
    logentries()
    c3entries()
    query_time2 = (time.time()-query_time1) # end script timer
    print(" Execution Time.......: %.5f seconds" % query_time2)
    cur.close()

 # end wsjtdb module