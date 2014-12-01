; For Use With JTSDK v2.0.0
#define MyAppName "WSPR"
#define MyAppVersion "4.0"
#define MyAppPublisher "Greg Beam, KI7MT"
#define MyAppCopyright "Copyright (C) 2001-2014 by Joe Taylor, K1JT"
#define MyAppURL "http://physics.princeton.edu/pulsar/k1jt/"
#define MyFmtURL "http://physics.princeton.edu/pulsar/K1JT/FMT_User.pdf"
#define WsprNetURL "http://wsprnet.org/drupal/wsprnet/map"
#define WsjtGroupURL "https://groups.yahoo.com/neo/groups/wsjtgroup/info

[Setup]
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DisableReadyPage=yes
DefaultDirName=C:\WSJT\WSPR-{#MyAppVersion}
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
Source: "c:\JTSDK\wspr\install\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}\Documentation\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\{#MyAppName}\Documentation\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyFmtURL}"
Name: "{group}\{#MyAppName}\Resources\{cm:ProgramOnTheWeb,WSPR Net}"; Filename: "{#WsprNetURL}"
Name: "{group}\{#MyAppName}\Resources\{cm:ProgramOnTheWeb,WSJT Group}"; Filename: "{#WsjtGroupURL}"
Name: "{group}\{#MyAppName}\Uninstall\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"; Comment: "Uninstall WSPR";
Name: "{group}\{#MyAppName}\FMT-Tool"; Filename: "{app}\fmt-env.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{group}\{#MyAppName}\WSPR-Code"; Filename: "{app}\fmt-env.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{group}\{#MyAppName}\WSPR"; Filename: "{app}\wspr.bat"; WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"
Name: "{userdesktop}\{#MyAppName}"; Filename: "{app}\wspr.bat";    WorkingDir: {app}; IconFileName: "{app}\wsjt.ico"

[Run]
Filename: "{app}\wspr.bat"; Description: "Launch WSPR"; Flags: postinstall nowait unchecked
