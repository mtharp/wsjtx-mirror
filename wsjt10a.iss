[Setup]
AppName=WSJT
AppVerName=WSJT Version 10.0 r3869
AppCopyright=Copyright (C) 2001-2014 by Joe Taylor, K1JT
DefaultDirName={pf}\WSJT10
DefaultGroupName=WSJT10

[Files]
Source: "c:\JTSDK\src\trunk\install\*";         DestDir: "{app}"; Flags: recursesubdirs
Source: "c:\JTSDK\src\trunk\jt65code.exe";      DestDir: "{app}"
Source: "c:\JTSDK\src\trunk\jt4code.exe";       DestDir: "{app}"

[Icons]
Name: "{group}\WSJT10";        Filename: "{app}\wsjt10.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{userdesktop}\WSJT10";  Filename: "{app}\wsjt10.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"


