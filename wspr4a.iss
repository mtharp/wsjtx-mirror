[Setup]
AppName=WSPR
AppVerName=WSPR Version 4.0 r3894
AppCopyright=Copyright (C) 2001-2014 by Joe Taylor, K1JT
DefaultDirName={pf}\WSPR4
DefaultGroupName=WSPR4

[Files]
Source: "c:\JTSDK\src\wspr\install\*";         DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\WSPR4";        Filename: "{app}\wspr.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{userdesktop}\WSPR4";  Filename: "{app}\wspr.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
