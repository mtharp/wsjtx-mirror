#!/usr/bin/env python3

# Simple gridsquare look up from CALL3 Table
# Run this script in the folder where wsjt.db resides
#
# Usage: call3.py -c <callsign>

import sys, getopt, sqlite3
dbf='wsjt.db'

def main(argv):
    data = ''
    call = ''
    try:
        opts, args = getopt.getopt(argv,"hc:",["call"])
    
    except getopt.GetoptError:
      print("\nUsage: call3.py -c <call>\n")
      sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            print("call3.py -c <call>")
            sys.exit()
        elif opt in ("-c", "--ccall"):
            call = arg.upper()
            print("\nChecking CALL3 Table For [ %s ]" % call)
            con = sqlite3.connect(dbf)
            cur = con.cursor()
            cur.execute('SELECT gridsquare FROM call3 WHERE call=?', (call,))
            for row in cur.fetchall():
                data = row[0]
        else:
            assert False, "unhandled option"
 
    if data=="":
        print(" [ %s ] Was Not Found In CALL3 Database\n" % (call))
    else:
        print("Found %s, grid is %s.\n" % (call, data))

if __name__ == "__main__":
   main(sys.argv[1:])
