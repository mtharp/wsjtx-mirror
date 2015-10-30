CREATE TABLE my_station (my_call TEXT,
                        my_grid TEXT,
                        my_cqz TEXT,
                        my_itu TEXT
);
CREATE TABLE call3 (id INTEGER PRIMARY KEY AUTOINCREMENT,
                   call TEXT,
                   grid TEXT,
                   mode TEXT,
                   previous_call TEXT,
                   comment TEXT,
                   last_update
);
CREATE TABLE logbook (id INTEGER PRIMARY KEY AUTOINCREMENT, 
                     call TEXT,
                     qso_date TEXT,
                     qso_time TEXT,
                     mode TEXT,
                     band TEXT,
                     rpt_sent TEXT,
                     rpt_rcvd,
                     grid TEXT,
                     name TEXT,
                     tx_pwr TEXT,
                     comments TEXT
);

* Open JTSDK-Py
* cd src\trunk\logbook\database
* svn update
* .output CALL3.TXT
* .separator ","
* SELECT call, grid mode, previous_call, comment, last_update FROM call3;
* .output stdout