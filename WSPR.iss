[Setup]
AppName=WSPR
AppVerName=WSPR Version 2.00 r1630
AppCopyright=Copyright (C) 2008-2009 by Joe Taylor, K1JT
DefaultDirName={pf}\WSPR
DefaultGroupName=WSPR

[Files]
Source: "c:\k1jt\svn\wsjt\wspr\wspr.exe";            DestDir: "{app}"
Source: "c:\k1jt\svn\wsjt\wspr\wsjt.ico";            DestDir: "{app}";
Source: "c:\k1jt\svn\wsjt\wspr\wsprrc.win";          DestDir: "{app}";
Source: "c:\k1jt\svn\wsjt\wspr\supported_rigs.txt";  DestDir: "{app}";
Source: "c:\k1jt\svn\wsjt\wspr\rigctl.exe";          DestDir: "{app}";
Source: "c:\k1jt\svn\wsjt\wspr\libhamlib-2.dll";     DestDir: "{app}";
Source: "c:\k1jt\svn\wsjt\wspr\hamlib*.dll";         DestDir: "{app}";
Source: "c:\k1jt\svn\wsjt\wspr\save\dummy";          DestDir: "{app}\save\"

[Icons]
Name: "{group}\WSPR";        Filename: "{app}\WSPR.EXE"; WorkingDir: {app}
Name: "{userdesktop}\WSPR";  Filename: "{app}\WSPR.EXE"; WorkingDir: {app}

