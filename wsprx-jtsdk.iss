[Setup]
AppName=WSPRX
AppVerName=WSPRX Version 0.8 r4178
AppCopyright=Copyright (C) 2001-2013 by Joe Taylor, K1JT
DefaultDirName=C:\WSJT\WSPRX
DefaultGroupName=WSJT\WSPRX

[Files]
Source: "c:\JTSDK-QT\wsprx\install\Release\bin\*";                      DestDir: "{app}"
Source: "C:\JTSDK-QT\wsprx\install\Release\bin\platforms\qwindows.dll"; DestDir: "{app}\platforms"
Source: "C:\JTSDK-QT\wsprx\install\Release\bin\save\Samples";            DestDir: "{app}\save\Samples"; Flags: recursesubdirs createallsubdirs

[Icons]
Name: "{group}\WSPRX";         Filename: "{app}\wsprx.exe"; WorkingDir: {app}; IconFilename: {app}\wsjt.ico
Name: "{userdesktop}\WSPRX";   Filename: "{app}\wsprx.exe"; WorkingDir: {app}; IconFilename: {app}\wsjt.ico
Name: {group}\WSPRX Uninstall; Filename: {uninstallexe}

[Run]
Filename: "{app}\wsprx.exe"; Description: "Launch WSPR-X"; Flags: postinstall nowait unchecked

