; For Use With JTSDK v2.0.0
#define MyAppName "WSPRX"
#define MyAppVersion "0.9"
#define MyAppPublisher "Greg Beam, KI7MT"
#define MyAppCopyright "Copyright (C) 2001-2014 by Joe Taylor, K1JT"
#define MyAppURL "http://physics.princeton.edu/pulsar/k1jt/wspr.html"
#define WsjtGroupURL "https://groups.yahoo.com/neo/groups/wsjtgroup/info"

[Setup]
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DisableReadyPage=yes
DefaultDirName=C:\WSJT\WSPRX-{#MyAppVersion}
DisableDirPage=yes
DefaultGroupName=WSJT
DisableProgramGroupPage=yes
LicenseFile=C:\JTSDK\common-licenses\GPL-3
OutputDir=C:\JTSDK\wspr\package
OutputBaseFilename={#MyAppName}-{#MyAppVersion}-Win32
SetupIconFile=C:\JTSDK\icons\wsjt.ico
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "c:\JTSDK\wsprx\install\Release\bin\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}\Documentation\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\{#MyAppName}\Resources\{cm:ProgramOnTheWeb,WSJT Group}"; Filename: "{#WsjtGroupURL}"
Name: "{group}\{#MyAppName}\Uninstall\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"; Comment: "Uninstall WSPRX";
Name: "{group}\{#MyAppName}\{#MyAppName}"; Filename: "{app}\wsprx.exe"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{userdesktop}\{#MyAppName}"; Filename: "{app}\wsprx.exe";    WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"

[Run]
Filename: "{app}\wsprx.exe"; Description: "Launch WSPR-X"; Flags: postinstall nowait unchecked