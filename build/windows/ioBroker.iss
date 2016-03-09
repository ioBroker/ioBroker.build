; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "ioBroker automation platform"
#define MyAppShortName "ioBroker"
#define MyAppLCShortName "iobroker"
#define MyAppVersion "@@version"
#define MyAppPublisher "ioBroker.net"
#define MyAppURL "http://ioBroker.net/"
#define MyAppIcon "ioBroker.ico"


[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{97DA02F5-2E8C-4B96-BB42-61ED2BBF34DF}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={drive:{pf}}\ioBroker
;DisableDirPage=yes
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=..\..\delivery
OutputBaseFilename={#MyAppShortName}Installer.{#MyAppVersion}
SetupIconFile={#MyAppIcon}
Compression=lzma
SolidCompression=yes
UsePreviousAppDir=yes
ArchitecturesInstallIn64BitMode=x64
UninstallDisplayIcon={app}\{#MyAppIcon}
CloseApplications=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "german";  MessagesFile: "compiler:Languages\German.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

; enable scripting to force admin mode
[Registry]
Root: HKLM; Subkey: "Software\Microsoft\Windows Script Host\Settings"; ValueType: dword; ValueName: "Enabled"; ValueData: "00000001"

[Files]
Source: "nodejs\node.msi"; DestDir: "{app}"; Flags: ignoreversion deleteafterinstall; Check: not Is64BitInstallMode
Source: "nodejs\node-x64.msi"; DestDir: "{app}"; DestName: "node.msi"; Flags: ignoreversion deleteafterinstall; Check: Is64BitInstallMode
;Source: "redis-v2.4.6\redis-2.4.6-setup-32-bit.exe"; DestDir: "{app}"; DestName: "redisSetup.exe"; Flags: ignoreversion deleteafterinstall; Check: not Is64BitInstallMode
;Source: "redis-v2.4.6\redis-2.4.6-setup-64-bit.exe"; DestDir: "{app}"; DestName: "redisSetup.exe"; Flags: ignoreversion deleteafterinstall; Check: Is64BitInstallMode
;Source: "couchDB\couchDBsetup.exe"; DestDir: "{app}"; Flags: ignoreversion deleteafterinstall;
;Source: "*.js"; DestDir: "{app}"; Flags: ignoreversion
;Source: "install.bat"; DestDir: "{app}"; Flags: ignoreversion
;Source: "package.json"; DestDir: "{app}"; Flags: ignoreversion
;Source: "npm.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#MyAppIcon}"; DestDir: "{app}"; Flags: ignoreversion
;Source: "..\.windows-ready\data\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
;Source: "node_modules\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{#MyAppShortName} Settings"; Filename: "http://localhost:8081"; IconFilename: "{app}\{#MyAppIcon}"
Name: "{group}\{#MyAppShortName} Uninstall"; Filename: "{uninstallexe}"
Name: "{group}\Start {#MyAppShortName} Service"; Filename: "{app}\serviceIoBroker.bat"; Parameters: "start"
Name: "{group}\Stop {#MyAppShortName} Service"; Filename: "{app}\serviceIoBroker.bat"; Parameters: "stop"
Name: "{group}\Restart {#MyAppShortName} Service"; Filename: "{app}\serviceIoBroker.bat"; Parameters: "restart"

[Code]
function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ResultCode: integer;
begin
  Result := '';
  if FileExists(ExpandConstant('{app}\serviceIoBroker.bat')) then begin
     Exec(ExpandConstant('{app}\serviceIoBroker.bat'), 'stop', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;

function FileReplaceString(const FileName, SearchString, ReplaceString: string):boolean;
var
  MyFile : TStrings;
  MyText : string;
begin
  MyFile := TStringList.Create;

  try
    result := true;

    try
      MyFile.LoadFromFile(FileName);
      MyText := MyFile.Text;

      if StringChangeEx(MyText, SearchString, ReplaceString, True) > 0 then //Only save if text has been changed.
      begin;
        MyFile.Text := MyText;
        MyFile.SaveToFile(FileName);
      end;
    except
      result := false;
    end;
  finally
    MyFile.Free;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  fileName : string;
  lang : string;
begin
  if  CurStep=ssPostInstall then
    begin
      lang := ActiveLanguage();
      if lang = 'russian' then begin
        lang := 'ru';
      end
      else begin
          if lang = 'german' then begin
            lang := 'de';
          end
          else begin
            lang := '';
          end;
      end;
      if lang <> '' then begin
          fileName := ExpandConstant('{app}\settings-dist.json');
          //FileReplaceString(fileName, '"language": "en"', '"language": "' + lang + '"');
      end;
    end;
end;

function RedisNeedsInstall():boolean;
begin
   result := not FileExists(ExpandConstant('{pf}\Redis\redis-service.exe'));
end;

function CouchNeedsInstall():boolean;
begin
   result := not FileExists(ExpandConstant('{pf32}\Apache Software Foundation\CouchDB\Install.exe'));
end;

function NodeJsNeedsInstall():boolean;
var
  ResultCode: integer;
begin

  result := true;
  if IsWin64 then begin
      result := not FileExists(ExpandConstant('{pf64}\nodejs\node.exe'));

      if result then begin
        result := not FileExists(ExpandConstant('{pf32}\nodejs\node.exe'));
      end;
  end;

  if result then begin
    result := not FileExists(ExpandConstant('{pf}\nodejs\node.exe'));
  end;

  if not DirExists(ExpandConstant('{userappdata}\npm')) then begin
     Exec(ExpandConstant('mkdir'), ExpandConstant('{userappdata}\npm'), '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
  if not DirExists(ExpandConstant('{userappdata}\npm-cache')) then begin
     Exec(ExpandConstant('mkdir'), ExpandConstant('{userappdata}\npm-cache'), '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;

function NodeJsPath(Param: String):String;
begin
  result := '';

  if DirExists(ExpandConstant('{pf}\nodejs')) then begin
    result := ExpandConstant('{pf}\nodejs');
  end;

  if IsWin64 then begin
      if DirExists(ExpandConstant('{pf32}\nodejs')) then begin
        result := ExpandConstant('{pf32}\nodejs');
      end;

      if DirExists(ExpandConstant('{pf64}\nodejs')) then begin
        result := ExpandConstant('{pf64}\nodejs');
      end;
  end;
end;

function GetAdminPageText(Param: String):String;
begin
  result := 'Open settings page';

  if ActiveLanguage() = 'german' then begin
    result := 'Einstellungen aufmachen';
  end;

  if ActiveLanguage() = 'russian' then begin
      result := '������� ���������';
  end;
end;

[Run]
; postinstall launch
Filename: "msiexec.exe"; Parameters: "/i ""{app}\node.msi"" /passive"; Check: NodeJsNeedsInstall
Filename: "{code:NodeJsPath}\npm.cmd"; Parameters: "install iobroker --prefix ""{app}""";
;Filename: "{app}\redisSetup.exe"; Check: RedisNeedsInstall
;Filename: "{app}\couchDBsetup.exe"; Parameters: "/SILENT"; Check: CouchNeedsInstall
;Filename: "{sys}\net.exe"; Parameters: "start redis"
;Filename: "{app}\install.bat"
;Filename: "{code:NodeJsPath}\node.exe"; Parameters: """{app}\install.js"""; Flags: runhidden;
;Filename: "{app}\serviceIoBroker.bat"; Parameters: "start"; Flags: runhidden;
; Add Firewall Rules
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall add rule name=""Node In"" program=""{code:NodeJsPath}\node.exe"" dir=in action=allow enable=yes"; Flags: runhidden;
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall add rule name=""Node Out"" program=""{code:NodeJsPath}\node.exe"" dir=out action=allow enable=yes"; Flags: runhidden;
Filename: http://localhost:8081/; Description: "{cm:AdminPage,None}"; Flags: postinstall shellexec

[UninstallRun]
; Removes System Service
Filename: "{code:NodeJsPath}\node.exe"; Parameters: """{app}\uninstall.js"""; Flags: runhidden;
Filename: "{sys}\del"; Parameters: "/Q /S ""{app}\daemon""";
Filename: "{sys}\rmdir"; Parameters: "/Q /S ""{app}\daemon""";
Filename: "{sys}\del"; Parameters: "/Q /S ""{app}\node_modules""";
Filename: "{sys}\rmdir"; Parameters: "/Q /S ""{app}\node_modules""";
;Filename: "{sys}\net"; Parameters: "stop redis"; Flags: runhidden;
;Filename: "{pf}\Redis\unins000.exe"
;Filename: "{pf32}\Apache Software Foundation\CouchDB\unins000.exe"
; Remove Firewall Rules
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall delete rule name=""Node In"" program=""{code:NodeJsPath}\node.exe"""; Flags: runhidden;
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall delete rule name=""Node Out"" program=""{code:NodeJsPath}\node.exe"""; Flags: runhidden;
; Remove all leftovers
