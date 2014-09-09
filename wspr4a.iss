; NOTE: AppVerName needs updating at release / beta release time.
[Setup]
AppName=WSPR
AppVerName=WSPR Version 4.0 r4233
AppCopyright=Copyright (C) 2001-2014 by Joe Taylor, K1JT
DefaultDirName=C:\WSJT\WSPR4
DefaultGroupName=WSJT\WSPR4

[Files]
Source: "c:\JTSDK-PY\src\wspr\install\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\WSPR4";                   Filename: "{app}\wspr.bat";    WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{group}\WSPR Command Line";       Filename: "{app}\fmt-env.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{group}\Fmtest Suite";            Filename: "{app}\fmt-env.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{group}\WSPRcode";                Filename: "{app}\fmt-env.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{userdesktop}\WSPR4";             Filename: "{app}\wspr.bat";    WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: {group}\Uninstall\Uninstall WSPR4; Filename: {uninstallexe}

[Run]
Filename: "{app}\wspr.bat"; Description: "Launch WSPR"; Flags: postinstall nowait unchecked