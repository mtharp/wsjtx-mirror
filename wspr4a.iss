; NOTE: AppVerName needs updating at release / beta release time.
; Only works with JTSDK-PY v1
[Setup]
AppName=WSPR
AppVerName=WSPR Version 4.0 r4522
AppCopyright=Copyright (C) 2001-2014 by Joe Taylor, K1JT
DefaultDirName=C:\WSJT\WSPR4
DefaultGroupName=WSJT\WSPR4

[Files]
; Change to C:\JTSDK\wsjt\install for JTSDK v2
Source: "c:\JTSDK-PY\wspr\install\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
; These should work for both JTSDK-PY v1 and JTSDK v2.
Name: "{group}\WSPR4";                   Filename: "{app}\wspr.bat";    WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{group}\WSPR Command Line";       Filename: "{app}\fmt-env.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{group}\Fmtest Suite";            Filename: "{app}\fmt-env.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{group}\WSPRcode";                Filename: "{app}\fmt-env.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{userdesktop}\WSPR4";             Filename: "{app}\wspr.bat";    WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: {group}\Uninstall\Uninstall WSPR4; Filename: {uninstallexe}

[Run]
Filename: "{app}\wspr.bat"; Description: "Launch WSPR"; Flags: postinstall nowait unchecked
