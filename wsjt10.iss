[Setup]
AppName=WSJT
AppVerName=WSJT Version 10.0 r3769
AppCopyright=Copyright (C) 2001-2014 by Joe Taylor, K1JT
DefaultDirName={pf}\WSJT10
DefaultGroupName=WSJT10

[Files]
Source: "c:\Users\joe\wsjt\trunk\wsjt10.exe";        DestDir: "{app}"
Source: "c:\Users\joe\wsjt\trunk\jt65code.exe";      DestDir: "{app}"
Source: "c:\Users\joe\wsjt\trunk\jt4code.exe";       DestDir: "{app}"
Source: "c:\Users\joe\wsjt\trunk\CALL3.TXT";         DestDir: "{app}"; Flags: onlyifdoesntexist
Source: "c:\Users\joe\wsjt\trunk\wsjt.ico";          DestDir: "{app}"; Flags: onlyifdoesntexist
Source: "c:\Users\joe\wsjt\trunk\TSKY.DAT";          DestDir: "{app}"; Flags: onlyifdoesntexist
Source: "c:\Users\joe\wsjt\trunk\libsamplerate.dll"; DestDir: "{app}"; Flags: onlyifdoesntexist
Source: "c:\Users\joe\wsjt\trunk\KVASD_g95.EXE";     DestDir: "{app}";
Source: "c:\Users\joe\wsjt\trunk\kvasd.dat";         DestDir: "{app}"; Flags: onlyifdoesntexist
Source: "c:\Users\joe\wsjt\trunk\wsjtrc.win";        DestDir: "{app}";
Source: "c:\Users\joe\wsjt\trunk\RxWav\Samples\W8WN_010809_110400.wav";  DestDir: "{app}\RxWav\Samples\"; Flags: onlyifdoesntexist

[Icons]
Name: "{group}\WSJT10";        Filename: "{app}\wsjt10.exe"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{userdesktop}\WSJT10";  Filename: "{app}\wsjt10.exe"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"


