[Setup]
AppName=WSJT
AppVerName=WSJT Version 10.0 r4227
AppCopyright=Copyright (C) 2001-2014 by Joe Taylor, K1JT
DefaultDirName=C:\WSJT\WSJT10
DefaultGroupName=WSJT\WSJT10

[Files]
Source: "c:\JTSDK-PY\src\trunk\install\*";         DestDir: "{app}"; Flags: recursesubdirs
Source: "c:\JTSDK-PY\src\trunk\jt65code.exe";      DestDir: "{app}"
Source: "c:\JTSDK-PY\src\trunk\jt4code.exe";       DestDir: "{app}"

[Icons]
Name: {group}\WSJT10 Uninstall; Filename: {uninstallexe}
Name: "{userdesktop}\WSJT10";  Filename: "{app}\wsjt.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{group}\WSJT\WSJT10";        Filename: "{app}\wsjt.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
