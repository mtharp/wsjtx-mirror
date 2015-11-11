; For Use With JTSDK v2
#define MyAppName "WSJT"
#define MyAppVersion "10.0"
#define MyAppPublisher "Joe Taylor, K1JT"
#define MyAppCopyright "Copyright (C) 2001-2015 by Joe Taylor, K1JT"
#define MyAppURL "http://physics.princeton.edu/pulsar/k1jt/doc/wsjt/"
#define WsjtGroupURL "https://groups.yahoo.com/neo/groups/wsjtgroup/info"

[Setup]
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DisableReadyPage=yes
DefaultDirName=C:\WSJT\WSJT-{#MyAppVersion}
DefaultGroupName=WSJT
LicenseFile=C:\JTSDK\common-licenses\GPL-3
OutputDir=C:\JTSDK\wsjt\package
OutputBaseFilename={#MyAppName}-{#MyAppVersion}-Win32
SetupIconFile=C:\JTSDK\icons\wsjt.ico
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "c:\JTSDK\wsjt\install\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}\Documentation\WSJT {#MyAppVersion} User Guide"; Filename: "{app}\wsjt-main-{#MyAppVersion}.html"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{group}\{#MyAppName}\Documentation\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\{#MyAppName}\Resources\{cm:ProgramOnTheWeb,WSJT Group}"; Filename: "{#WsjtGroupURL}"
Name: "{group}\{#MyAppName}\Uninstall\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"; Comment: "Uninstall WSPR";
Name: "{group}\{#MyAppName}\WSJT v10"; Filename: "{app}\wsjt.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{userdesktop}\{#MyAppName}"; Filename: "{app}\wsjt.bat";    WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"

[Run]
Filename: "{app}\wsjt.bat"; Description: "Launch WSJT v10"; Flags: postinstall nowait unchecked