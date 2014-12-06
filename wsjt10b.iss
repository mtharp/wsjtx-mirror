; For Use With JTSDK v2
#define MyAppName "WSJT"
#define MyAppVersion "10.0"
; Change publisher to whomever is creating the formal release
#define MyAppPublisher "Greg Beam, KI7MT"
#define MyAppCopyright "Copyright (C) 2001-2014 by Joe Taylor, K1JT"
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
DisableDirPage=yes
DefaultGroupName=WSJT
DisableProgramGroupPage=yes
; common licenses folder does not exist in JTSDK-PY v1
LicenseFile=C:\JTSDK\common-licenses\GPL-3
; Change to C:\JTSDK-PY\wsjt\package for JTSDK-PY v1
OutputDir=C:\JTSDK\wsjt\package
OutputBaseFilename={#MyAppName}-{#MyAppVersion}-Win32
; icons folder does not exist in JTSDK-PY v1
SetupIconFile=C:\JTSDK\icons\wsjt.ico
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
; Change to C:\JTSDK-PY\wsjt\install for use with JTSDJ-PY v1
Source: "c:\JTSDK\wsjt\install\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; These should all work for JTSDK-PY v1 or JTSDK v2
Name: "{group}\{#MyAppName}\Documentation\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\{#MyAppName}\Resources\{cm:ProgramOnTheWeb,WSJT Group}"; Filename: "{#WsjtGroupURL}"
Name: "{group}\{#MyAppName}\Uninstall\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"; Comment: "Uninstall WSPR";
Name: "{group}\{#MyAppName}\WSJT v10"; Filename: "{app}\wsjt.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{userdesktop}\{#MyAppName}"; Filename: "{app}\wsjt.bat";    WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"

[Run]
Filename: "{app}\wsjt.bat"; Description: "Launch WSJT v10"; Flags: postinstall nowait unchecked