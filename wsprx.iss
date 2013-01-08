[Setup]
AppName=wsprx
AppVerName=wsprx Version 0.5 r2904
AppCopyright=Copyright (C) 2001-2013 by Joe Taylor, K1JT
DefaultDirName=c:\wsprx
DefaultGroupName=wsprx

[Files]
Source: "c:\Users\joe\wsjt\wsprx_install\wsprx.exe";         DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wsprx_install\wsprd.exe";         DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wsprx_install\curl.exe";          DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wsprx_install\wsjt.ico";          DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wsprx_install\afmhot.dat";        DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wsprx_install\blue.dat";          DestDir: "{app}";
Source: "c:\Users\joe\wsjt\QtSupport\*.dll";                 DestDir: "{app}";  Flags: onlyifdoesntexist

[Icons]
Name: "{group}\wsprx";        Filename: "{app}\wsprx.exe";   WorkingDir: {app}; IconFilename: {app}\wsjt.ico
Name: "{userdesktop}\wsprx";  Filename: "{app}\wsprx.exe";   WorkingDir: {app}; IconFilename: {app}\wsjt.ico

