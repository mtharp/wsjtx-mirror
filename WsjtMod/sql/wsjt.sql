/*

 my_station and logbook tables conform to ADIF standard v3.0.4
 Ref: http://www.adif.org/304/ADIF_304.htm#QSO_Fields

 LOG FIELD EXPLANATION, from ADIF spec 3.0.4

 NAME           ADIF 3.0.4      DESCRIPTION
 ----------------------------------------------------------------------------
 operator       Yes             the logging operator's callsign
 my_name        Yes             the logging operator's name
 my_gridsquare  Yes             the logging station's 2-character, 4-character, 6-character, or 8-character Maidenhead Grid Square
 my_country     Yes             the logging station's DXCC entity name
 my_cq_zone     Yes             the logging station's CQ Zone
 my_itu_zone    Yes             the logging station's ITU zone

*/
CREATE TABLE my_station (
    operator        TEXT,
    my_name         TEXT,
    my_gridsquare   TEXT,
    my_country      TEXT,
    my_cq_zone      TEXT,
    my_itu_zone     TEXT
);
/*

 LOGBOOK TABLE
 * ADIF spec 3.0.4 Yes / No
 * LoTW - Accepted Fields
 
 NAME           ADIF 3.0.4   LoTW        DESCRIPTION
 ----------------------------------------------------------------------------
 CALL           Yes          Yes        contacted station callsign
 GRIDSQUARE     Yes          Yes        contacted station gridsquare   
 QSO_DATE       Yes          Yes        date on which the QSO started
 TIME_ON        Yes          Yes        HHMM or HHMMSS in UTC
 QSO_DATE_OFF   Yes          Yes        date on which the QSO ended
 TIME_OFF       Yes                     HHMM or HHMMSS in UTC
 SUBMODE        Yes                     QSO submode
 MODE           Yes          Yes        QSO submode
 RST_SENT       Yes                     signal report sent to the contacted station
 RST_RCVD       Yes                     signal report from the contacted station
 TX_PWR         Yes                     the logging station's power in watts
 BAND           Yes          Yes        band on which you transmitted
 FREQ           Yes          Yes        frequncy on which you transmitted
 FORCE_INT      Yes                     new EME "initial"
 MS_SHOWER      Yes                     For Meteor Scatter QSOs, the name of the meteor shower in progress
 MS_BURSTS      Yes                     the number of meteor scatter bursts heard by the logging station
 NR_PINGS       Yes                     the number of meteor scatter pings heard by the logging station
 MAX_BURSTS     Yes                     maximum length of meteor scatter bursts heard by the logging station, in seconds
 VUCC_GRIDS     Yes                     two or four adjacent Maidenhead grid locators,
                                        each four characters long, representing the
                                        contacted station's grid squares credited to the
                                        QSO for the ARRL VUCC award program.
                                        E.g. - DN46,FM08,EM97,FM07
*/
CREATE TABLE logbook(
    call            TEXT    NOT NULL,
    gridsquare      TEXT,
    qso_date        TEXT,
    time_on         TEXT,
    qso_date_off    TEXT,
    time_off        TEXT,
    submode         TEXT,
    mode            TEXT,
    rst_sent        TEXT,
    rst_rcvd        TEXT,
    tx_pwr          TEXT,
    freq            TEXT,
    band            TEXT,
    comment         TEXT,
    force_init string check(force_init='Y' or force_init='N' or force_init='EME' or force_init=''),
    ms_shower       TEXT,
    nr_bursts       TEXT,
    nr_pings        TEXT,
    max_pings       TEXT,
    vucc_grids      TEXT
);
CREATE INDEX LogbookIdx1 ON logbook(call,gridsquare,qso_date,time_on,mode,band);

/*

 CALL3 TABLE
 Not all fields in this tabel conform to ADIF spec 3.0.4

 NAME           ADIF 3.0.4      DESCRIPTION
 ----------------------------------------------------------------------------
 CALL           Yes             contacted station callsign
 GRIDSQUARE     Yes             contacted station gridsquare   
 FORCE_INT      Yes             new EME "initial"
 PREV_CALL      No              Stations previous calls
 COMMENT        Yes             comment field for QSO and CALL3
 LAST_UPDATE    No              last update to call3 record

*/
CREATE TABLE call3(
    call            TEXT    UNIQUE  NOT NULL,
    gridsquare      TEXT,
    force_init string check(force_init='Y' or force_init='N' or force_init='EME' or force_init=''),
    prev_call       TEXT,
    comment         TEXT,
    last_update     TEXT
);
CREATE INDEX Call3Idx1 ON call3(call,gridsquare);

/*
 WSJT Version Data
*/
CREATE TABLE version_data(
    name        TEXT    UNIQUE  NOT NULL,
    version     TEXT    NOT NULL
);
INSERT INTO version_data (name, version) VALUES
    ("database", "10.0"),
    ("hamlib", "1.2.15.3"),
    ("adif", "3.0.4");
/*
 Frequency to band conversion
*/
CREATE TABLE band_list(
    freq    TEXT PRIMARY KEY    UNIQUE  NOT NULL,
    band    TEXT
);
INSERT INTO band_list (freq, band) VALUES
    ("2", "160m"),
    ("4", "80m"),
    ("7", "40m"),
    ("10", "30m"),
    ("14", "20m"),
    ("18", "17m"),
    ("21", "15m"),
    ("24", "12m"),
    ("28", "12m"),
    ("50", "2m"),
    ("70", "4m"),
    ("144", "2m"),
    ("222", "1.25m"),
    ("432", "70cm"),
    ("902", "33cm"),
    ("1296", "23cm"),
    ("3456", "9cm"),
    ("5760", "6cm"),
    ("10368", "3cm"),
    ("24048", "1.25cm");
/*
 Submode List
*/
CREATE TABLE submode_list(
    submode TEXT,
    mode    TEXT
);
INSERT INTO submode_list (submode, mode) VALUES
    ("PCW", "CW"),
    ("CW", "CW"),
    ("FSK441", "FSK441"),
    ("ISCAT-A", "ISCAT"),
    ("ISCAT-B", "ISCAT"),
    ("JT6M", "JT6M"),
    ("JT4A", "JT4"),
    ("JT4B", "JT4"),
    ("JT4C", "JT4"),
    ("JT4D", "JT4"),
    ("JT4E", "JT4"),
    ("JT4F", "JT4"),
    ("JT4G", "JT4"),
    ("JT6M", "JT6M"),
    ("JT9-1", "JT9"),
    ("JT9-2", "JT9"),
    ("JT9-5", "JT9"),
    ("JT9-10", "JT9"),
    ("JT44", "JT44"),
    ("JT65A", "JT65"),
    ("JT65B", "JT65"),
    ("JT65B2", "JT65"),
    ("JT65C", "JT65"),
    ("JT65C2", "JT65"),
    ("WSPR-2", "WSPR"),
    ("WSPR-15", "WSPR");
/*
 Meteor Shower Table from WikiPedia: https://en.wikipedia.org/wiki/List_of_meteor_showers
 Template (10 Fields) ("", "", "", "", "", "", "", "", "", ""),

*/
CREATE TABLE ms_shower(ms_name TEXT PRIMARY KEY	UNIQUE	NOT NULL);
INSERT INTO ms_shower (ms_name) VALUES
    ("Alpha Aurigids"),
    ("Alpha Capricornids"),
    ("Alpha Centaurids"),
    ("Alpha Monocerotids"),
    ("Alpha Scorpiids"),
    ("Antihelion Source"),
    ("April Piscids"),
    ("Beta Cassiopeids"),
    ("Camelopardalids"),
    ("Chi Capricornids"),
    ("Comae Berenicids"),
    ("Daytime Beta Taurids"),
    ("Daytime Capri Sagitt"),
    ("Daytime Eps. Arietids"),
    ("Daytime May Arietids"),
    ("Daytime Sextantids"),
    ("Daytime Zeta Perseids"),
    ("Dec. Leonis Minorids"),
    ("Delta Aurigids"),
    ("Delta Piscids"),
    ("Draconids"),
    ("Epsilon Geminids"),
    ("Eta Aquariids"),
    ("Eta Eridanids"),
    ("Eta Lyrids"),
    ("Gamma Doradids"),
    ("Gamma Leonids"),
    ("Gamma Normids"),
    ("Geminids"),
    ("July Phoenicids"),
    ("June Bootids"),
    ("June Lyrids"),
    ("Kappa Cygnids"),
    ("Kappa Serpentids"),
    ("Leo Minorids"),
    ("Leonids"),
    ("Lyrids"),
    ("Monocerotids"),
    ("North Delta Aquariids"),
    ("North Omega Scorpiids"),
    ("Northern Taurids"),
    ("Nov. Iota Aurigids"),
    ("Omega Cetids"),
    ("Omicron Cetids"),
    ("Orionids"),
    ("Perseids"),
    ("Phoenicids"),
    ("Pi Cetids"),
    ("Pi Puppids"),
    ("Piscis Austrinids"),
    ("Puppid-Velids"),
    ("Quadrantids"),
    ("Sept. Epsilon Perseids"),
    ("Sigma Hydrids"),
    ("South June Aquilids"),
    ("South Omega Scorpiids"),
    ("Southern Delta Aquariids"),
    ("Southern Taurids"),
    ("Tau Aquariids"),
    ("Theta Centaurids"),
    ("Ursids"),
    ("Virginids"),
    ("Zeta Aurigids");
/*
 WSJT Prefix Table
*/
CREATE TABLE dxcc_prefix(prefix TEXT   UNIQUE NOT NULL);
INSERT INTO dxcc_prefix (prefix) VALUES
	("/0"),
	("/1"),
	("1A"),
	("1S"),
	("/2"),
	("/3"),
	("3A"),
	("3B6"),
	("3B8"),
	("3B9"),
	("3C"),
	("3C0"),
	("3D2"),
	("3D2C"),
	("3D2R"),
	("3DA"),
	("3V"),
	("3W"),
	("3X"),
	("3Y"),
	("3YB"),
	("3YP"),
	("/4"),
	("4J"),
	("4L"),
	("4S"),
	("4U1I"),
	("4U1U"),
	("4W"),
	("4X"),
	("/5"),
	("5A"),
	("5B"),
	("5H"),
	("5N"),
	("5R"),
	("5T"),
	("5U"),
	("5V"),
	("5W"),
	("5X"),
	("5Z"),
	("/6"),
	("6W"),
	("6Y"),
	("/7"),
	("7O"),
	("7P"),
	("7Q"),
	("7X"),
	("/8"),
	("8P"),
	("8Q"),
	("8R"),
	("/9"),
	("9A"),
	("9G"),
	("9H"),
	("9J"),
	("9K"),
	("9L"),
	("9M2"),
	("9M6"),
	("9N"),
	("9Q"),
	("9U"),
	("9V"),
	("9X"),
	("9Y"),
	("/A"),
	("A2"),
	("A3"),
	("A4"),
	("A5"),
	("A6"),
	("A7"),
	("A9"),
	("AP"),
	("BS7"),
	("BV"),
	("BV9"),
	("BY"),
	("C2"),
	("C3"),
	("C5"),
	("C6"),
	("C9"),
	("CE"),
	("CE0X"),
	("CE0Y"),
	("CE0Z"),
	("CE9"),
	("CM"),
	("CN"),
	("CP"),
	("CT"),
	("CT3"),
	("CU"),
	("CX"),
	("CY0"),
	("CY9"),
	("D2"),
	("D4"),
	("D6"),
	("DL"),
	("DU"),
	("E3"),
	("E4"),
	("E5"),
	("EA"),
	("EA6"),
	("EA8"),
	("EA9"),
	("EI"),
	("EK"),
	("EL"),
	("EP"),
	("ER"),
	("ES"),
	("ET"),
	("EU"),
	("EX"),
	("EY"),
	("EZ"),
	("F"),
	("FG"),
	("FH"),
	("FJ"),
	("FK"),
	("FKC"),
	("FM"),
	("FO"),
	("FOA"),
	("FOC"),
	("FOM"),
	("FP"),
	("FR"),
	("FRG"),
	("FRJ"),
	("FRT"),
	("FT5W"),
	("FT5X"),
	("FT5Z"),
	("FW"),
	("FY"),
	("H4"),
	("H40"),
	("HA"),
	("HB"),
	("HB0"),
	("HC"),
	("HC8"),
	("HH"),
	("HI"),
	("HK"),
	("HK0"),
	("HK0M"),
	("HL"),
	("HM"),
	("HP"),
	("HR"),
	("HS"),
	("HV"),
	("HZ"),
	("I"),
	("IS"),
	("IS0"),
	("J2"),
	("J3"),
	("J5"),
	("J6"),
	("J7"),
	("J8"),
	("JA"),
	("JDM"),
	("JDO"),
	("JT"),
	("JW"),
	("JX"),
	("JY"),
	("K"),
	("KC4"),
	("KG4"),
	("KH0"),
	("KH1"),
	("KH2"),
	("KH3"),
	("KH4"),
	("KH5"),
	("KH5K"),
	("KH6"),
	("KH7"),
	("KH8"),
	("KH9"),
	("KL"),
	("KP1"),
	("KP2"),
	("KP4"),
	("KP5"),
	("LA"),
	("LU"),
	("LX"),
	("LY"),
	("LZ"),
	("M"),
	("MD"),
	("MI"),
	("MJ"),
	("MM"),
	("MU"),
	("MW"),
	("OA"),
	("OD"),
	("OE"),
	("OH"),
	("OH0"),
	("OJ0"),
	("OK"),
	("OM"),
	("ON"),
	("OX"),
	("OY"),
	("OZ"),
	("/P"),
	("P2"),
	("P4"),
	("PA"),
	("PJ2"),
	("PJ7"),
	("PT0S"),
	("PY"),
	("PY0F"),
	("PY0T"),
	("PZ"),
	("R1F"),
	("R1M"),
	("S0"),
	("S2"),
	("S5"),
	("S7"),
	("S9"),
	("SM"),
	("SP"),
	("ST"),
	("SU"),
	("SV"),
	("SV5"),
	("SV9"),
	("SVA"),
	("T2"),
	("T30"),
	("T31"),
	("T32"),
	("T33"),
	("T5"),
	("T7"),
	("T8"),
	("T9"),
	("TA"),
	("TF"),
	("TG"),
	("TI"),
	("TI9"),
	("TJ"),
	("TK"),
	("TL"),
	("TN"),
	("TR"),
	("TT"),
	("TU"),
	("TY"),
	("TZ"),
	("UA"),
	("UA2"),
	("UA9"),
	("UK"),
	("UN"),
	("UR"),
	("V2"),
	("V3"),
	("V4"),
	("V5"),
	("V6"),
	("V7"),
	("V8"),
	("VE"),
	("VK"),
	("VK0H"),
	("VK0M"),
	("VK9C"),
	("VK9L"),
	("VK9M"),
	("VK9N"),
	("VK9W"),
	("VK9X"),
	("VP2E"),
	("VP2M"),
	("VP2V"),
	("VP5"),
	("VP6"),
	("VP6D"),
	("VP8"),
	("VP8G"),
	("VP8H"),
	("VP8O"),
	("VP8S"),
	("VP9"),
	("VQ9"),
	("VR"),
	("VU"),
	("VU4"),
	("VU7"),
	("XE"),
	("XF4"),
	("XT"),
	("XU"),
	("XW"),
	("XX9"),
	("XZ"),
	("YA"),
	("YB"),
	("YI"),
	("YJ"),
	("YK"),
	("YL"),
	("YN"),
	("YO"),
	("YS"),
	("YU"),
	("YV"),
	("YV0"),
	("Z2"),
	("Z3"),
	("ZA"),
	("ZB"),
	("ZC4"),
	("ZD7"),
	("ZD8"),
	("ZD9"),
	("ZF"),
	("ZK1N"),
	("ZK1S"),
	("ZK2"),
	("ZK3"),
	("ZL"),
	("ZL7"),
	("ZL8"),
	("ZL9"),
	("ZP"),
	("ZS"),
	("ZS8");
/*
 Hamlib Rig List Table
 Based on v1.2.15.3
*/
BEGIN TRANSACTION;
CREATE TABLE hamlib_list(
    rig         TEXT    PRIMARY KEY UNIQUE NOT NULL,
    mfg         TEXT,
    model       TEXT,
    version     TEXT,
    status      TEXT
);
INSERT INTO `hamlib_list` VALUES ('1','Hamlib','Dummy','0.5','Beta');
INSERT INTO `hamlib_list` VALUES ('2','Hamlib','NET rigctl','0.3','Beta');
INSERT INTO `hamlib_list` VALUES ('101','Yaesu','FT-847','0.5','Beta');
INSERT INTO `hamlib_list` VALUES ('103','Yaesu','FT-1000D','0.0.6','Alpha');
INSERT INTO `hamlib_list` VALUES ('104','Yaesu','MARK-V FT-1000MP','0.0.5','Alpha');
INSERT INTO `hamlib_list` VALUES ('105','Yaesu','FT-747GX','0.4.1','Beta');
INSERT INTO `hamlib_list` VALUES ('106','Yaesu','FT-757GX','0.4.1','Beta');
INSERT INTO `hamlib_list` VALUES ('107','Yaesu','FT-757GXII','0.4','Stable');
INSERT INTO `hamlib_list` VALUES ('109','Yaesu','FT-767GX','1.0','Stable');
INSERT INTO `hamlib_list` VALUES ('110','Yaesu','FT-736R','0.3','Stable');
INSERT INTO `hamlib_list` VALUES ('111','Yaesu','FT-840','0.1','Untested');
INSERT INTO `hamlib_list` VALUES ('113','Yaesu','FT-900','0.1','Untested');
INSERT INTO `hamlib_list` VALUES ('114','Yaesu','FT-920','2010-08-23','Stable');
INSERT INTO `hamlib_list` VALUES ('115','Yaesu','FT-890','0.1','Stable');
INSERT INTO `hamlib_list` VALUES ('116','Yaesu','FT-990','0.2.1','Alpha');
INSERT INTO `hamlib_list` VALUES ('117','Yaesu','FRG-100','0.4','Beta');
INSERT INTO `hamlib_list` VALUES ('118','Yaesu','FRG-9600','0.2','Untested');
INSERT INTO `hamlib_list` VALUES ('119','Yaesu','FRG-8800','0.2','Untested');
INSERT INTO `hamlib_list` VALUES ('120','Yaesu','FT-817','0.5.1','Beta');
INSERT INTO `hamlib_list` VALUES ('121','Yaesu','FT-100','0.4.1','Beta');
INSERT INTO `hamlib_list` VALUES ('122','Yaesu','FT-857','0.4','Beta');
INSERT INTO `hamlib_list` VALUES ('123','Yaesu','FT-897','0.3.3','Beta');
INSERT INTO `hamlib_list` VALUES ('124','Yaesu','FT-1000MP','0.1.1','Beta');
INSERT INTO `hamlib_list` VALUES ('125','Yaesu','MARK-V Field FT-1000MP','0.0.5','Alpha');
INSERT INTO `hamlib_list` VALUES ('126','Yaesu','VR-5000','0.2','Alpha');
INSERT INTO `hamlib_list` VALUES ('127','Yaesu','FT-450','0.22.1','Beta');
INSERT INTO `hamlib_list` VALUES ('128','Yaesu','FT-950','0.22.2','Stable');
INSERT INTO `hamlib_list` VALUES ('129','Yaesu','FT-2000','0.22.1','Stable');
INSERT INTO `hamlib_list` VALUES ('130','Yaesu','FTDX-9000','0.22.1','Untested');
INSERT INTO `hamlib_list` VALUES ('131','Yaesu','FT-980','0.1','Alpha');
INSERT INTO `hamlib_list` VALUES ('132','Yaesu','FT-DX5000','0.22','Alpha');
INSERT INTO `hamlib_list` VALUES ('133','Vertex Standard','VX-1700','1.1','Alpha');
INSERT INTO `hamlib_list` VALUES ('201','Kenwood','TS-50S','0.8','Untested');
INSERT INTO `hamlib_list` VALUES ('202','Kenwood','TS-440','0.8.0.6.1','Alpha');
INSERT INTO `hamlib_list` VALUES ('203','Kenwood','TS-450S','0.8.1','Beta');
INSERT INTO `hamlib_list` VALUES ('204','Kenwood','TS-570D','0.8.2','Stable');
INSERT INTO `hamlib_list` VALUES ('205','Kenwood','TS-690S','0.8.1','Beta');
INSERT INTO `hamlib_list` VALUES ('206','Kenwood','TS-711','0.8.0.6.1','Untested');
INSERT INTO `hamlib_list` VALUES ('207','Kenwood','TS-790','0.8.2','Alpha');
INSERT INTO `hamlib_list` VALUES ('208','Kenwood','TS-811','0.8.0.6.1','Untested');
INSERT INTO `hamlib_list` VALUES ('209','Kenwood','TS-850','0.8.1','Beta');
INSERT INTO `hamlib_list` VALUES ('210','Kenwood','TS-870S','0.8.0','Beta');
INSERT INTO `hamlib_list` VALUES ('211','Kenwood','TS-940S','0.8.0.6.1','Alpha');
INSERT INTO `hamlib_list` VALUES ('213','Kenwood','TS-950SDX','0.8','Beta');
INSERT INTO `hamlib_list` VALUES ('214','Kenwood','TS-2000','0.8.4','Beta');
INSERT INTO `hamlib_list` VALUES ('215','Kenwood','R-5000','0.6.1','Alpha');
INSERT INTO `hamlib_list` VALUES ('216','Kenwood','TS-570S','0.8.1','Stable');
INSERT INTO `hamlib_list` VALUES ('217','Kenwood','TH-D7A','0.5','Alpha');
INSERT INTO `hamlib_list` VALUES ('219','Kenwood','TH-F6A','0.5','Beta');
INSERT INTO `hamlib_list` VALUES ('220','Kenwood','TH-F7E','0.5.1','Beta');
INSERT INTO `hamlib_list` VALUES ('221','Elecraft','K2','20120615','Beta');
INSERT INTO `hamlib_list` VALUES ('222','Kenwood','TS-930','0.8','Untested');
INSERT INTO `hamlib_list` VALUES ('223','Kenwood','TH-G71','0.5','Beta');
INSERT INTO `hamlib_list` VALUES ('224','Kenwood','TS-680S','0.8.1','Beta');
INSERT INTO `hamlib_list` VALUES ('225','Kenwood','TS-140S','0.8.1','Beta');
INSERT INTO `hamlib_list` VALUES ('226','Kenwood','TM-D700','0.5','Beta');
INSERT INTO `hamlib_list` VALUES ('227','Kenwood','TM-V7','0.5','Beta');
INSERT INTO `hamlib_list` VALUES ('228','Kenwood','TS-480','0.8.5','Untested');
INSERT INTO `hamlib_list` VALUES ('229','Elecraft','K3/KX3','20120615','Beta');
INSERT INTO `hamlib_list` VALUES ('230','Kenwood','TRC-80','0.8','Alpha');
INSERT INTO `hamlib_list` VALUES ('231','Kenwood','TS-590S','0.8.1','Beta');
INSERT INTO `hamlib_list` VALUES ('232','SigFox','Transfox','20111223','Alpha');
INSERT INTO `hamlib_list` VALUES ('233','Kenwood','TH-D72A','0.5.1','Alpha');
INSERT INTO `hamlib_list` VALUES ('234','Kenwood','TM-D710','0.5','Untested');
INSERT INTO `hamlib_list` VALUES ('302','Icom','IC-1275','0.7','Beta');
INSERT INTO `hamlib_list` VALUES ('303','Icom','IC-271','0.7','Untested');
INSERT INTO `hamlib_list` VALUES ('304','Icom','IC-275','0.7.1','Beta');
INSERT INTO `hamlib_list` VALUES ('306','Icom','IC-471','0.7','Untested');
INSERT INTO `hamlib_list` VALUES ('307','Icom','IC-475','0.7.1','Beta');
INSERT INTO `hamlib_list` VALUES ('309','Icom','IC-706','0.7.1','Untested');
INSERT INTO `hamlib_list` VALUES ('310','Icom','IC-706MkII','0.7.1','Untested');
INSERT INTO `hamlib_list` VALUES ('311','Icom','IC-706MkIIG','0.7.2','Stable');
INSERT INTO `hamlib_list` VALUES ('312','Icom','IC-707','0.7','Untested');
INSERT INTO `hamlib_list` VALUES ('313','Icom','IC-718','0.7.1','Beta');
INSERT INTO `hamlib_list` VALUES ('314','Icom','IC-725','0.7.1','Stable');
INSERT INTO `hamlib_list` VALUES ('315','Icom','IC-726','0.7','Stable');
INSERT INTO `hamlib_list` VALUES ('316','Icom','IC-728','0.7','Untested');
INSERT INTO `hamlib_list` VALUES ('319','Icom','IC-735','0.7.1','Beta');
INSERT INTO `hamlib_list` VALUES ('320','Icom','IC-736','0.7','Untested');
INSERT INTO `hamlib_list` VALUES ('321','Icom','IC-737','0.7','Untested');
INSERT INTO `hamlib_list` VALUES ('322','Icom','IC-738','0.7','Untested');
INSERT INTO `hamlib_list` VALUES ('323','Icom','IC-746','0.7.1','Beta');
INSERT INTO `hamlib_list` VALUES ('324','Icom','IC-751','0.7.1','Beta');
INSERT INTO `hamlib_list` VALUES ('326','Icom','IC-756','0.7.1','Alpha');
INSERT INTO `hamlib_list` VALUES ('327','Icom','IC-756PRO','0.7','Untested');
INSERT INTO `hamlib_list` VALUES ('328','Icom','IC-761','0.7.1','Stable');
INSERT INTO `hamlib_list` VALUES ('329','Icom','IC-765','0.7','Stable');
INSERT INTO `hamlib_list` VALUES ('330','Icom','IC-775','0.7.1','Untested');
INSERT INTO `hamlib_list` VALUES ('331','Icom','IC-781','0.7.1','Untested');
INSERT INTO `hamlib_list` VALUES ('332','Icom','IC-820H','0.7','Alpha');
INSERT INTO `hamlib_list` VALUES ('334','Icom','IC-821H','0.7','Alpha');
INSERT INTO `hamlib_list` VALUES ('335','Icom','IC-970','0.7','Untested');
INSERT INTO `hamlib_list` VALUES ('336','Icom','IC-R10','0.7','Untested');
INSERT INTO `hamlib_list` VALUES ('337','Icom','IC-R71','0.7','Untested');
INSERT INTO `hamlib_list` VALUES ('338','Icom','IC-R72','0.7','Untested');
INSERT INTO `hamlib_list` VALUES ('339','Icom','IC-R75','0.7','Beta');
INSERT INTO `hamlib_list` VALUES ('340','Icom','IC-R7000','0.7.0','Alpha');
INSERT INTO `hamlib_list` VALUES ('341','Icom','IC-R7100','0.7.0','Untested');
INSERT INTO `hamlib_list` VALUES ('342','Icom','ICR-8500','0.7.1','Beta');
INSERT INTO `hamlib_list` VALUES ('343','Icom','IC-R9000','0.7.1','Alpha');
INSERT INTO `hamlib_list` VALUES ('344','Icom','IC-910','0.7.1','Beta');
INSERT INTO `hamlib_list` VALUES ('345','Icom','IC-78','0.7','Untested');
INSERT INTO `hamlib_list` VALUES ('346','Icom','IC-746PRO','0.7','Stable');
INSERT INTO `hamlib_list` VALUES ('347','Icom','IC-756PROII','0.7','Alpha');
INSERT INTO `hamlib_list` VALUES ('351','Ten-Tec','Omni VI Plus','0.2','Beta');
INSERT INTO `hamlib_list` VALUES ('352','Optoelectronics','OptoScan535','0.3','Beta');
INSERT INTO `hamlib_list` VALUES ('353','Optoelectronics','OptoScan456','0.3','Beta');
INSERT INTO `hamlib_list` VALUES ('354','Icom','IC ID-1','0.7','Untested');
INSERT INTO `hamlib_list` VALUES ('355','Icom','IC-703','0.7','Untested');
INSERT INTO `hamlib_list` VALUES ('356','Icom','IC-7800','0.7.2','Untested');
INSERT INTO `hamlib_list` VALUES ('357','Icom','IC-756PROIII','0.7.1','Beta');
INSERT INTO `hamlib_list` VALUES ('358','Icom','IC-R20','0.7','Untested');
INSERT INTO `hamlib_list` VALUES ('360','Icom','IC-7000','0.7.2','Beta');
INSERT INTO `hamlib_list` VALUES ('361','Icom','IC-7200','0.7','Beta');
INSERT INTO `hamlib_list` VALUES ('362','Icom','IC-7700','0.7.1','Stable');
INSERT INTO `hamlib_list` VALUES ('363','Icom','IC-7600','0.7','Beta');
INSERT INTO `hamlib_list` VALUES ('364','Ten-Tec','Delta II','0.1','Untested');
INSERT INTO `hamlib_list` VALUES ('365','Icom','IC-92D','0.7','Untested');
INSERT INTO `hamlib_list` VALUES ('366','Icom','IC-R9500','0.7.1','Untested');
INSERT INTO `hamlib_list` VALUES ('367','Icom','IC-7410','0.7','Untested');
INSERT INTO `hamlib_list` VALUES ('368','Icom','IC-9100','0.7','Untested');
INSERT INTO `hamlib_list` VALUES ('369','Icom','IC-RX7','0.7','Untested');
INSERT INTO `hamlib_list` VALUES ('401','Icom','IC-PCR1000','0.8','Beta');
INSERT INTO `hamlib_list` VALUES ('402','Icom','IC-PCR100','0.8','Beta');
INSERT INTO `hamlib_list` VALUES ('403','Icom','IC-PCR1500','0.8','Beta');
INSERT INTO `hamlib_list` VALUES ('404','Icom','IC-PCR2500','0.8','Beta');
INSERT INTO `hamlib_list` VALUES ('501','AOR','AR8200','0.6.1','Alpha');
INSERT INTO `hamlib_list` VALUES ('502','AOR','AR8000','0.6.1','Beta');
INSERT INTO `hamlib_list` VALUES ('503','AOR','AR7030','0.4.1','Beta');
INSERT INTO `hamlib_list` VALUES ('504','AOR','AR5000','0.6.1','Beta');
INSERT INTO `hamlib_list` VALUES ('505','AOR','AR3030','0.4','Untested');
INSERT INTO `hamlib_list` VALUES ('506','AOR','AR3000A','0.5','Beta');
INSERT INTO `hamlib_list` VALUES ('508','AOR','AR2700','0.6','Untested');
INSERT INTO `hamlib_list` VALUES ('513','AOR','AR8600','0.6.1','Beta');
INSERT INTO `hamlib_list` VALUES ('514','AOR','AR5000A','0.6','Alpha');
INSERT INTO `hamlib_list` VALUES ('515','AOR','AR7030 Plus','0.1','Beta');
INSERT INTO `hamlib_list` VALUES ('516','AOR','SR2200','0.1','Beta');
INSERT INTO `hamlib_list` VALUES ('605','JRC','NRD-525','0.1','Alpha');
INSERT INTO `hamlib_list` VALUES ('606','JRC','NRD-535D','0.6','Stable');
INSERT INTO `hamlib_list` VALUES ('607','JRC','NRD-545 DSP','0.6','Beta');
INSERT INTO `hamlib_list` VALUES ('801','Uniden','BC780xlt','0.3','Untested');
INSERT INTO `hamlib_list` VALUES ('802','Uniden','BC245xlt','0.3','Untested');
INSERT INTO `hamlib_list` VALUES ('803','Uniden','BC895xlt','0.3','Untested');
INSERT INTO `hamlib_list` VALUES ('804','Radio Shack','PRO-2052','0.3','Untested');
INSERT INTO `hamlib_list` VALUES ('806','Uniden','BC250D','0.3','Untested');
INSERT INTO `hamlib_list` VALUES ('810','Uniden','BCD-396T','0.3','Alpha');
INSERT INTO `hamlib_list` VALUES ('811','Uniden','BCD-996T','0.3','Alpha');
INSERT INTO `hamlib_list` VALUES ('812','Uniden','BC898T','0.3','Untested');
INSERT INTO `hamlib_list` VALUES ('902','Drake','R-8A','0.5.1','Beta');
INSERT INTO `hamlib_list` VALUES ('903','Drake','R-8B','0.5','Untested');
INSERT INTO `hamlib_list` VALUES ('1004','Lowe','HF-235','0.3','Alpha');
INSERT INTO `hamlib_list` VALUES ('1103','Racal','RA6790/GM','0.1','Untested');
INSERT INTO `hamlib_list` VALUES ('1105','Racal','RA3702','0.1','Alpha');
INSERT INTO `hamlib_list` VALUES ('1204','Watkins-Johnson','WJ-8888','0.2','Untested');
INSERT INTO `hamlib_list` VALUES ('1402','Skanti','TRP8000','0.2','Untested');
INSERT INTO `hamlib_list` VALUES ('1404','Skanti','TRP 8255 S R','0.1','Untested');
INSERT INTO `hamlib_list` VALUES ('1501','Winradio','WR-1000','0.6','Untested');
INSERT INTO `hamlib_list` VALUES ('1502','Winradio','WR-1500','0.6','Untested');
INSERT INTO `hamlib_list` VALUES ('1503','Winradio','WR-1550','0.6','Untested');
INSERT INTO `hamlib_list` VALUES ('1504','Winradio','WR-3100','0.6','Untested');
INSERT INTO `hamlib_list` VALUES ('1505','Winradio','WR-3150','0.6','Untested');
INSERT INTO `hamlib_list` VALUES ('1506','Winradio','WR-3500','0.6','Untested');
INSERT INTO `hamlib_list` VALUES ('1507','Winradio','WR-3700','0.6','Untested');
INSERT INTO `hamlib_list` VALUES ('1601','Ten-Tec','TT-550','0.2','Beta');
INSERT INTO `hamlib_list` VALUES ('1602','Ten-Tec','TT-538 Jupiter','0.6','Beta');
INSERT INTO `hamlib_list` VALUES ('1603','Ten-Tec','RX-320','0.6','Stable');
INSERT INTO `hamlib_list` VALUES ('1604','Ten-Tec','RX-340','0.3','Untested');
INSERT INTO `hamlib_list` VALUES ('1605','Ten-Tec','RX-350','0.1','Untested');
INSERT INTO `hamlib_list` VALUES ('1607','Ten-Tec','TT-516 Argonaut V','0.2','Stable');
INSERT INTO `hamlib_list` VALUES ('1608','Ten-Tec','TT-565 Orion','0.5','Beta');
INSERT INTO `hamlib_list` VALUES ('1609','Ten-Tec','TT-585 Paragon','0.3','Beta');
INSERT INTO `hamlib_list` VALUES ('1611','Ten-Tec','TT-588 Omni VII','0.3','Alpha');
INSERT INTO `hamlib_list` VALUES ('1612','Ten-Tec','RX-331','0.1','Beta');
INSERT INTO `hamlib_list` VALUES ('1613','Ten-Tec','TT-599 Eagle','0.4','Untested');
INSERT INTO `hamlib_list` VALUES ('1701','Alinco','DX-77','0.7','Beta');
INSERT INTO `hamlib_list` VALUES ('1801','Kachina','505DSP','0.3','Alpha');
INSERT INTO `hamlib_list` VALUES ('1901','Hamlib','RPC rig','0.3','Beta');
INSERT INTO `hamlib_list` VALUES ('2201','TAPR','DSP-10','0.2','Alpha');
INSERT INTO `hamlib_list` VALUES ('2301','Flex-radio','SDR-1000','0.2','Untested');
INSERT INTO `hamlib_list` VALUES ('2303','DTTS Microwave Society','DttSP IPC','0.2','Alpha');
INSERT INTO `hamlib_list` VALUES ('2304','DTTS Microwave Society','DttSP UDP','0.2','Alpha');
INSERT INTO `hamlib_list` VALUES ('2401','RFT','EKD-500','0.4','Alpha');
INSERT INTO `hamlib_list` VALUES ('2501','Elektor','Elektor 3/04','0.4','Stable');
INSERT INTO `hamlib_list` VALUES ('2502','SAT-Schneider','DRT1','0.2','Beta');
INSERT INTO `hamlib_list` VALUES ('2503','Coding Technologies','Digital World Traveller','0.1','Untested');
INSERT INTO `hamlib_list` VALUES ('2506','AmQRP','DDS-60','0.1','Alpha');
INSERT INTO `hamlib_list` VALUES ('2507','Elektor','Elektor SDR-USB','0.3.1','Stable');
INSERT INTO `hamlib_list` VALUES ('2508','mRS','miniVNA','0.1','Alpha');
INSERT INTO `hamlib_list` VALUES ('2509','SoftRock','Si570 AVR-USB','0.2','Beta');
INSERT INTO `hamlib_list` VALUES ('2511','KTH-SDR kit','Si570 PIC-USB','0.2','Beta');
INSERT INTO `hamlib_list` VALUES ('2512','FiFi','FiFi-SDR','0.5','Beta');
INSERT INTO `hamlib_list` VALUES ('2513','AMSAT-UK','FUNcube Dongle','0.2','Beta');
INSERT INTO `hamlib_list` VALUES ('2514','N2ADR','HiQSDR','0.2','Untested');
INSERT INTO `hamlib_list` VALUES ('2601','Video4Linux','SW/FM radio','0.2.1','Beta');
INSERT INTO `hamlib_list` VALUES ('2602','Video4Linux2','SW/FM radio','0.2.1','Alpha');
INSERT INTO `hamlib_list` VALUES ('2701','Rohde&Schwarz','ESMC','0.1','Alpha');
INSERT INTO `hamlib_list` VALUES ('2702','Rohde&Schwarz','EB200','0.1','Untested');
INSERT INTO `hamlib_list` VALUES ('2801','Philips/Simoco','PRM8060','0.1','Alpha');
INSERT INTO `hamlib_list` VALUES ('2901','ADAT www.adat.ch','ADT-200A','1.36','Beta');
CREATE INDEX HamlibIdx1 ON hamlib_list(model,rig);
COMMIT;
