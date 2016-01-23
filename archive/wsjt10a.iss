; NOTE: AppVerName needs updating at release / beta release time.
; Works only with JTSDK-PY v1
[Setup]
AppName=WSJT
AppVerName=WSJT Version 10.0 r4768
AppCopyright=Copyright (C) 2001-2014 by Joe Taylor, K1JT
DefaultDirName=C:\WSJT\WSJT10
DefaultGroupName=WSJT\WSJT10

[Files]
; Change Path to C:\JTSDK\wsjt\install for use with JTSDK v2.0.0
Source: "c:\JTSDK-PY\wsjt\install\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
; These shoudl work with both JTSDJ-PY v1 and JTSDK v2
Name: "{group}\WSJT10"; Filename: "{app}\wsjt.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{userdesktop}\WSJT10"; Filename: "{app}\wsjt.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: {group}\Uninstall\Uninstall WSJT10; Filename: {uninstallexe}

[Run]
Filename: "{app}\wsjt.bat"; Description: "Launch WSJT"; Flags: postinstall nowait unchecked
