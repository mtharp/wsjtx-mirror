/*

 my_station and logbook tables conform to ADIF standard v3.0.4
 Ref: http://www.adif.org/304/ADIF_304.htm#QSO_Fields

 NAME           DESCRIPTION
 ----------------------------------------------------------------------------
  call           The contacted station's Callsign
  my_name        Name of the operator
  my_gridsquare  Operators grid square
  my_cqz         Operators CQ Zone
  my_itu         Operators ITU Zone

*/
CREATE TABLE my_station (operator TEXT,
                        my_name TEXT,
                        my_gridsquare TEXT,
                        my_cq_zone TEXT,
                        my_itu_zone TEXT
);
/*

 LOG FIELD EXPLANATION

 NAME         DESCRIPTION
 ----------------------------------------------------------------------------
  call         The contacted station's Callsign
  qso_date     QSO date
  time_on      QSO Log time    
  band         QSO Band
  mode         QSO Mode
  submode      QSO Submode, use enumeration values for interoperability
  rpt_sent     Signal report sent to the contacted station
  rpt_rcvd     Signal report from the contacted station
  force_init   A new ADIF v.3.0.4 that identifies a QSO as an EME QSO.
  gridsquare   The contacted station's 2, 4, 6,, 8 character Maidenhead Grid Square
  tx_pwr       The logging station's power in watts
  comment      Comment field for QSO    

*/
CREATE TABLE logbook (id INTEGER PRIMARY KEY AUTOINCREMENT, 
                     call TEXT,
                     qso_date TEXT,
                     time_on TEXT,
                     band TEXT,
                     mode TEXT,
                     submode TEXT,
                     rpt_sent TEXT,
                     rpt_rcvd,
                     gridsquare TEXT,
                     name TEXT,
                     tx_pwr TEXT,
                     force_init TEXT,
                     comment TEXT
);
/*

 This table does *not* conform to ADIF standard v.3.0.4. Rather, it matches
 the files contructed in WSJT got the CALL3.TEXT file and grid lookup.

 LOG FIELD EXPLANATION

 NAME          DESCRIPTION
 ----------------------------------------------------------------------------
  call           The contacted station's Callsign
  gridsquare     The contacted station's 2, 4, 6,, 8 character Maidenhead Grid Square
  force_init     A new ADIF v.3.0.4 that identifies a QSO as an EME QSO.
  previous_call  Non Adif file for adding ex calls ro the record
  notes          Comment field for QSO, different filed for C3 comments
  last_update    Non ADIF field for adding date of last update

*/
CREATE TABLE call3 (id INTEGER PRIMARY KEY AUTOINCREMENT,
                   call TEXT,
                   gridsquare TEXT,
                   force_init TEXT,
                   previous_call TEXT,
                   comment TEXT,
                   last_update TEXT
);
/*
 Meteor Shower Table from WikiPedia: https://en.wikipedia.org/wiki/List_of_meteor_showers
 
 TO-DO: add table for MS Shower selection
 
 */
