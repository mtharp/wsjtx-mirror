[Setup]
AppName=WSJT
AppVerName=WSJT Version 8 r1928
AppCopyright=Copyright (C) 2001-2010 by Joe Taylor, K1JT
DefaultDirName={pf}\WSJT8
DefaultGroupName=WSJT8

[Files]
Source: "c:\Users\joe\wsjt\wsjt8a\WSJT8.EXE";         DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wspr\pthreadGC2.dll";      DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wsjt8a\qso.txt";           DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wsjt8a\WSJT8codes.out";    DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wsjt8a\wsjt.ico";          DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wsjt8a\TSKY.DAT";          DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wsjt8a\kvasd2.exe";        DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wsjt8a\kvasd.dat";         DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wsjt8a\wsjtrc.win";        DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wsjt8a\samples\JTMS.wav";  DestDir: "{app}\RxWav\Samples\";
Source: "c:\Users\joe\wsjt\wsjt8a\samples\ISCAT.wav"; DestDir: "{app}\RxWav\Samples\";
Source: "c:\Users\joe\wsjt\wsjt8a\samples\JT64.wav";  DestDir: "{app}\RxWav\Samples\";
Source: "c:\Users\joe\wsjt\wsjt8a\samples\JT8.wav";   DestDir: "{app}\RxWav\Samples\";
Source: "c:\Users\joe\wsjt\wsjt8a\met2.21";           DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wsjt8a\met8.21";           DestDir: "{app}";

[Icons]
Name: "{group}\WSJT8";        Filename: "{app}\WSJT8.EXE"; WorkingDir: {app}
Name: "{userdesktop}\WSJT8";  Filename: "{app}\WSJT8.EXE"; WorkingDir: {app}

