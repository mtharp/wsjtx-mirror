; NOTE: AppVerName needs updating at release / beta release time.
[Setup]
AppName=WSJT
AppVerName=WSJT Version 10.0 r4227
AppCopyright=Copyright (C) 2001-2014 by Joe Taylor, K1JT
DefaultDirName=C:\WSJT\WSJT10
DefaultGroupName=WSJT\WSJT10

[Files]
Source: "c:\JTSDK-PY\src\trunk\install\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\WSJT10";          Filename: "{app}\wsjt.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{userdesktop}\WSJT10";    Filename: "{app}\wsjt.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: {group}\Uninstall WSJT10;  Filename: {uninstallexe}

[Run]
Filename: "{app}\wsjt.bat"; Description: "Launch WSJT"; Flags: postinstall nowait unchecked
