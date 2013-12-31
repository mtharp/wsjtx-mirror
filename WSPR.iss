[Setup]
AppName=WSPR
AppVerName=WSPR Version 2.12 r3617

AppCopyright=Copyright (C) 2008-2014 by Joe Taylor, K1JT
DefaultDirName={pf}\WSPR
DefaultGroupName=WSPR

[Files]
Source: "c:\Users\joe\wsjt\wspr212\wspr.exe";            DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wspr212\wsjt.ico";            DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wspr212\wsprrc.win";          DestDir: "{app}";  Flags: onlyifdoesntexist
Source: "c:\Users\joe\wsjt\wspr212\hamlib_rig_numbers";  DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wspr212\rigctl.exe";          DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wspr212\libhamlib-2.dll";     DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wspr212\hamlib*.dll";         DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wspr212\libusb0.dll";         DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wspr212\pthreadGC2.dll";      DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wspr212\save\Samples\091022_0436.wav";  DestDir: "{app}\save\Samples";  Flags: onlyifdoesntexist
Source: "c:\Users\joe\wsjt\wspr212\fcal.exe";            DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wspr212\fcal.dat";            DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wspr212\fmt.exe";             DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wspr212\fmtave.exe";          DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wspr212\fmeasure.exe";        DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wspr212\gocal.bat";           DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wspr212\0230.bat";            DestDir: "{app}"

[Icons]
Name: "{group}\WSPR";        Filename: "{app}\WSPR.EXE"; WorkingDir: {app}; IconFilename: {app}\wsjt.ico
Name: "{userdesktop}\WSPR";  Filename: "{app}\WSPR.EXE"; WorkingDir: {app}; IconFilename: {app}\wsjt.ico

