; ----------------------------------------------------------------------------------------------
; - ioBroker Windows Installer                                                                 -
; ----------------------------------------------------------------------------------------------
; -                                                                                            -
; - 21.05.2022 Bluefox: Initial version                                                        -
; - 03.03.2023 Gaspode: Improved look & feel, improved error handling, added several checks,   -
; -                     implemented more options                                               -
; - 04.03.2023 Gaspode: Added several languages                                                -
; - 07.03.2023 Gaspode: Ensure that node path is set correctly when calling 'npx'              -
; - 08.03.2023 Gaspode: Implemented option to modify Windows firewall                          -
; - 10.03.2023 Gaspode: Layout optimizations                                                   -
; - 18.03.2023 Gaspode: Refactored and optimized code, cleanup                                 -
; - 21.03.2023 Gaspode: Support multi server installations in expert mode                      -
; - 22.03.2023 Gaspode: Copy the installer itself to ioBroker directory and create shortcut    -
; - 25.03.2023 Gaspode: Recognize stabilostick installation folder and abort installation      -
; - 26.03.2023 Gaspode: Data migration for new installations implemented                       -
; - 01.04.2023 Gaspode: Option added to set windows service startmode (auto, manual)           -
; - 05.04.2023 Gaspode: Uninstall: keep iobroker-data, but rename it to iobroker-data_backup   -
; - 08.04.2023 Gaspode: Allow to change the root folder for installations in expert mode       -
; - 18.04.2023 Gaspode: Fixed firewall rules                                                   -
; - 28.04.2023 Gaspode: Catch and handle several error conditions                              -
; - 28.04.2023 Gaspode: Use a location for temporary files which causes less problems          -
; - 29.04.2023 Gaspode: Handle ampersand properly when setting path variable                   -
; - 01.05.2023 Gaspode: Remove empty installation root folder if first installation is         -
; -                     cancelled                                                              -
; - 16.07.2023 Gaspode: Workaround for Node installation bug. In case that prefix directory is -
; -                     not created, the installer will create it                              -
; - 05.02.2024 Gaspode: Change detection of supported and recommended Node.js versions         -
; - 07.02.2024 Gaspode: Check for installer update at startup                                  -
; - 08.02.2024 Gaspode: Refactored and optimized code, cleanup                                 -
; - 25.02.2024 Gaspode: Cosmetic change for specific screen resolutions or scaling settings    -
; -                                                                                            -
; ----------------------------------------------------------------------------------------------
#define MyAppName "ioBroker automation platform"
#define MyAppShortName "ioBroker"
#define MyAppLCShortName "iobroker"
#define MyAppPublisher "ioBroker GmbH"
#define MyAppURL "https://www.ioBroker.net/"
#define MyAppIcon "ioBroker.ico"

#define URL_IOB_VERSIONS_JSON 'https://raw.githubusercontent.com/ioBroker/ioBroker/master/versions.json'
#define URL_NODEJS_LATEST_MAJOR 'https://nodejs.org/dist/latest-v%d.x/SHASUMS256.txt'
#define URL_NODEJS_LATEST_FULL 'https://nodejs.org/dist/latest-v%d.x/%s'
#define URL_IOB_BUILD_PACKAGE_JSON 'https://raw.githubusercontent.com/ioBroker/ioBroker.build/master/package.json'
#define URL_INSTALLER_DOWNLOAD 'https://iobroker.live/images/win/iobroker-installer-%s.exe'

#include "..\.windows-ready\version.txt"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{97DA02F5-2E8C-4B96-BB42-61ED2BBF34DF}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={drive:{commonpf}}\ioBroker
DefaultGroupName={#MyAppName}
OutputDir=..\..\delivery
LicenseFile=resource\Lizenz.txt
OutputBaseFilename={#MyAppShortName}Installer.{#MyAppVersion}
SetupIconFile=resource\{#MyAppIcon}
Compression=lzma
SolidCompression=yes
DisableWelcomePage=No
WizardStyle=modern
WizardImageFile=resource\ioBroker.bmp
UninstallDisplayIcon={uninstallexe}
CloseApplications=yes
MissingRunOnceIdsWarning=no
ChangesEnvironment=yes

[Icons]
Name: "{group}\Uninstall {#MyAppShortName}"; Filename: "{uninstallexe}"; IconFilename: {app}\{#MyAppIcon};
Name: "{group}\[{code:getIobServiceName}] ioBroker Admin"; Filename: "http://localhost:{code:getIobAdminPortStr}"; IconFilename: "{app}\{#MyAppIcon}"; Check: UpdateAdminShortcut
Name: "{group}\ioBroker Setup"; Filename: "{app}\ioBrokerInstaller.exe"; IconFilename: "{app}\{#MyAppIcon}";

[Files]
Source: "resource\{#MyAppIcon}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{srcexe}"; DestDir: "{app}"; DestName: "ioBrokerInstaller.exe"; Flags: external overwritereadonly replacesameversion

; Do not display required disk space:
[Messages]
DiskSpaceGBLabel=
DiskSpaceMBLabel=

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"

[CustomMessages]
#include "language\english.txt"
#include "language\dutch.txt"
#include "language\french.txt"
#include "language\german.txt"
#include "language\italian.txt"
#include "language\polish.txt"
#include "language\portuguese.txt"
#include "language\russian.txt"
#include "language\spanish.txt"
#include "language\ukrainian.txt"

[Run]
Filename: http://localhost:{code:getIobAdminPortStr}/; Description: "{cm:OpenIoBrokerSettings}"; Flags: postinstall shellexec;  Check: success and not uninstalled
Filename: {win}\explorer; Parameters: "{code:getIobPath}\log";Description: "{cm:OpenLogFileDirectory}"; Flags: postinstall shellexec;  Check: not success

[UninstallRun]
; Removes System Service
Filename: "{code:getNodePath}\node.exe"; Parameters: """{app}\uninstall.js"""; Flags: runhidden;
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall delete rule ""Node for ioBroker (inbound)"""; Flags: runhidden;
Filename: "{sys}\netsh.exe"; Parameters: "advfirewall firewall delete rule ""Node for ioBroker (outbound)"""; Flags: runhidden;

[UninstallDelete]
Type: filesandordirs; Name: "{app}\*.js"
Type: filesandordirs; Name: "{app}\*.md"
Type: filesandordirs; Name: "{app}\*.cmd"
Type: filesandordirs; Name: "{app}\*.bat"
Type: filesandordirs; Name: "{app}\*.json"
Type: filesandordirs; Name: "{app}\*.ps1"
Type: filesandordirs; Name: "{app}\*.sh"
Type: filesandordirs; Name: "{app}\LICENSE"
Type: filesandordirs; Name: "{app}\.env"
Type: filesandordirs; Name: "{app}\instDone"
Type: filesandordirs; Name: "{app}\daemon"
Type: filesandordirs; Name: "{app}\node_modules"
Type: filesandordirs; Name: "{app}\install"
Type: filesandordirs; Name: "{app}\log"
Type: filesandordirs; Name: "{app}\semver"
Type: filesandordirs; Name: "{app}\iobroker-data_old"

[Registry]
Root: HKLM; Subkey: "Software\ioBroker"; Flags: uninsdeletekey dontcreatekey

[Code]
{
  First Time:
      Normal: Welcome -> License -> Directory -------------------------------------------------> Gather Data -> Summary -> Options -> Ready -> Install -> Completed
      Expert: Welcome -> License -> Directory -> ExpertOptions --new-------> ExpertSettings ---> Gather Data -> Summary -> Options -> Ready -> Install -> Completed
                                                               |-maintain--> set selected dir -> Gather Data -> Summary -> Options -> Ready -> Install -> Completed
                                                               |-uninstall-> set selected dir -> Gather Data -----------------------> Ready -> Install -> Completed

   Already Installed:
      Normal: Welcome --------------------------------------------------> Gather Data -> Summary -> Options -> Ready -> Install -> Completed
      Expert: Welcome -> ExpertOptions --new--------> ExpertSettings ---> Gather Data -> Summary -> Options -> Ready -> Install -> Completed
                                       |--maintain--> set selected dir -> Gather Data -> Summary -> Options -> Ready -> Install -> Completed
                                       |--uninstall-> set selected dir -> Gather Data -----------------------> Ready -> Install -> Completed
}
#include "resource\JsonParser.pas"
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
{ Global variables are initialized with 0, '' or nil by default                                                                                                                                    }
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var

  // Summary page and its controls
  summaryPage: TWizardPage;
  sumInfo1NodeLabel: TLabel;
  sumInfo2NodeLabel: TLabel;
  sumInfo3NodeLabel: TLabel;
  sumInfo1IoBrokerLabel: TLabel;
  sumInfo2IoBrokerLabel: TLabel;
  sumInfo1IoBrokerRunLabel: TLabel;
  sumInfo2IoBrokerRunLabel: TLabel;
  sumInfo1PortStatesLabelA: TLabel;
  sumInfo2PortStatesLabelA: TLabel;
  sumInfo1PortObjectsLabelA: TLabel;
  sumInfo2PortObjectsLabelA: TLabel;
  sumInfo1PortAdminLabelA: TLabel;
  sumInfo2PortAdminLabelA: TLabel;
  sumInfo1PortStatesLabelB: TLabel;
  sumInfo2PortStatesLabelB: TLabel;
  sumInfo1PortObjectsLabelB: TLabel;
  sumInfo2PortObjectsLabelB: TLabel;
  sumInfo1PortAdminLabelB: TLabel;
  sumInfo2PortAdminLabelB: TLabel;
  sumSummaryLabel: TLabel;

  // options page and its controls
  optionsPage: TWizardPage;
  optInstallNodeCB: TCheckBox;
  optInstallIoBrokerCB: TCheckBox;
  optFixIoBrokerCB: TCheckBox;
  optAddFirewallRuleCB: TCheckBox;
  optServiceAutoStartCB: TCheckBox;
  optDataMigrationCB: TCheckBox;
  optDataMigrationButton: TButton;
  optDataMigrationLabel: TLabel;
  optAdditionalHintsLabel: TLabel;
  sumRetryButton: TButton;

  // Expert Options page and controls:
  expertOptionsPage: TWizardPage;
  exoIntroLabel: TLabel;
  exoNewServerRB: TRadioButton;
  exoMaintainServerRB: TRadioButton;
  exoUninstallServerRB: TRadioButton;
  exoNewServerLabel: TLabel;
  exoMaintainServerCombo: TComboBox;
  exoUninstallServerCombo: TComboBox;
  exoChangeDirectoryButton: TButton;

  // Expert Settings page and controls:
  expertSettingsPage: TWizardPage;
  exsIntroLabel: TLabel;
  exsServerNameLabel: TLabel;
  exsServerNameEdit: TEdit;
  exsStatesPortLabel: TLabel;
  exsStatesPortEdit: TEdit;
  exsObjectsPortLabel: TLabel;
  exsObjectsPortEdit: TEdit;
  exsAdminPortLabel: TLabel;
  exsAdminPortEdit: TEdit;

  // Global expert checkbox, checked if installer is in expert mode
  expertCB: TCheckBox;


  // Progress pages
  progressPage: TOutputProgressWizardPage;
  marqueePage: TOutputMarqueeProgressWizardPage;

  readyToInstall: Boolean;            // True if all preconditions are fulfilled to start the installation/fix/other option
  tryStopServiceAtNextRetry: Boolean; // True if the iob service shall be shut down when pressing Retry button
  iobControllerFoundNoNode: Boolean;  // True, if iobroker js-controller was found in the active path, but no Node.js software installed

  nodePath: String;                       // Local Path to currently installed node.exe
  rcmdNodeDownloadPath: String;           // The path (URL) to the currently recommended Node.js MSI file
  acceptedNodeVersions: array of Integer; // Currently supported node major versions

  instNodeVersionMajor: Integer;          // Major Version of installed Node.js software
  instNodeVersionMinor: Integer;          // Minor Version of installed Node.js software
  instNodeVersionPatch: Integer;          // PatchVersion of installed Node.js software

  rcmdNodeVersionMajor: Integer;          // Major Version of recommended Node.js software
  rcmdNodeVersionMinor: Integer;          // Minor Version of recommended Node.js software
  rcmdNodeVersionPatch: Integer;          // Patch Version of recommended Node.js software


  iobHomePath: String;       // Home path of a standard ioBroker installations, equal to appInstPath if not expert mode or standard iob installation
  iobExpertPath: String;     // Home path where new ioBroker installations are located in expert mode
  appInstPath: String;       // Path to the currently handled iob server installation
  iobServiceName: String;    // The service name of the currently handled iob server installation
  iobObjectsPort: Integer;   // objects port of the currently handled iob server installation
  iobStatesPort: Integer;    // states port of the currently handled iob server installation
  iobAdminPort: Integer;     // Admin port of the currently handled iob server installation
  iobServerName: String;     // Servername (Hostname) of the currently handled iob server installation

  iobTargetServiceName: String;  // The target service name of the currently to be installed iob server installation

  iobVersionMajor: Integer;  // Major Version of the  currently handled iob server installation
  iobVersionMinor: Integer;  // Minor Version of the  currently handled iob server installation
  iobVersionPatch: Integer;  // Patch Version of the  currently handled iob server installation

  iobServiceExists: Boolean;     // True if a windows service with service name 'iobServiceName' already exists
  iobInstalled: Boolean;         // True if an ioBroker installation was found and verified in the currently handled path
  isFirstInstallerRun: Boolean;  // True if installer is executed the first time, i.e. in also in standard mode a path can be selected

  installationSuccessful: Boolean; // True if the installation was successful

  expertRegServersRoot: String; // Root path in registry for server information (expert mode only)
  registryPendingDeleteKey: String; // Root path in registry for removal of downloaded installer executable, if newer version was downloaded

  updatedInstallerStarted: Boolean; // True, if a new installer was downloaded and started, otherwise false;

procedure gatherInstNodeData; forward;
function reconfigureIoBroker(info: String; logFileName: String): Boolean; forward;
function reconfigureIoBrokerPorts(statesPort: Integer; objectsPort: Integer; logFileName: String): Boolean; forward;
function reconfigureIoBrokerAdminPort(adminPort: Integer; logFileName: String): Boolean; forward;
function reconfigureIoBrokerServerName(serverName: String; logFileName: String): Boolean; forward;
procedure retryTestReady(sender: TObject); forward;
procedure expertOptionChanged(sender: TObject); forward;
procedure updateExpertOptionsPage; forward;
procedure updateExpertSettingsPage; forward;
procedure keyPressServerName(sender: TObject; var key: Char); forward;
procedure keyPressStatesPort(sender: TObject; var key: Char); forward;
procedure keyPressObjectsPort(sender: TObject; var key: Char); forward;
procedure keyPressAdminPort(sender: TObject; var key: Char); forward;
function checkPort(var edit: TEdit; var portNumber: Integer): Boolean; forward;
function checkAndSetExpertSettings: Boolean; forward;
function stopIobService(serviceName: String; logFileName: String): Boolean; forward;
procedure showExpertMode(sender: TObject); forward;
procedure expertModeCBClicked(sender: TObject); forward;
function expertInstallationExists: Boolean; forward;
procedure expertSelectDirectory(sender: TObject); forward;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 Helper functions for the [xyz] sections of inno setup
 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function getIobAdminPortStr(Param: String): String;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := IntToStr(iobAdminPort);
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function getIobPath(Param: String): String;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := appInstPath;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function getIobServiceName(Param: String): String;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := iobServiceName;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function getNodePath(Param: String): String;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  gatherInstNodeData;
  Result := nodePath;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function getTempPathName: String;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := iobHomePath + '\~tmpInstaller#Gaspode';
  if iobHomePath = '' then begin
    Log('Warning: TempPathName called but no home path set!');
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function getTempPath: String;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  if not dirExists(getTempPathName) then begin
    ForceDirectories(getTempPathName);
  end;
  Result := getTempPathName;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function DownloadTemporaryFileAndCopy(const Url, FileName, RequiredSHA256OfFile: String; const OnDownloadProgress: TOnDownloadProgress): Int64;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := DownloadTemporaryFile(Url, FileName, RequiredSHA256OfFile, OnDownloadProgress);
  if FileCopy(ExpandConstant('{tmp}') + '\' + FileName, getTempPath + '\' + FileName, False) then begin
    Log('Copied downloaded file to ' + getTempPath + '\' + FileName);
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function success: Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := installationSuccessful;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function uninstalled: Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := expertCB.Checked and exoUninstallServerRB.Checked;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function UserDefAdminPort: Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := iobAdminPort <> 8081;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function UpdateAdminShortcut: Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := UserDefAdminPort and not exoUninstallServerRB.Checked;
end;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 general helper functions
 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function GetHKLM: Integer;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  if IsWin64 then
    Result := HKLM64
  else
    Result := HKLM32;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
Function fillStringWithBlanks(str: String; count: Integer): String;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  i: Integer;
begin
  Result := str;
  for i := 0 to count - Length(str) do begin
    Result := Result + ' ';
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function FindJsonObject(Output: TJsonParserOutput; Parent: TJsonObject; Key: TJsonString; var Value: TJsonObject): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  I: Integer;
begin
  for I := 0 to Length(Parent) - 1 do
  begin
    if Parent[I].Key = Key then
    begin
      if (Parent[I].Value.Kind = JVKObject) then
      begin
        Value := Output.Objects[Parent[i].Value.Index];
        Result := True;
        Exit;
      end
    end;
  end;
  Result := False;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function FindJsonNumber(Output: TJsonParserOutput; Parent: TJsonObject; Key: TJsonString; var Value: TJsonNumber): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  I: Integer;
begin
  for I := 0 to Length(Parent) - 1 do
  begin
    if Parent[I].Key = Key then
    begin
      if (Parent[I].Value.Kind = JVKNumber) then
      begin
        Value := Output.Numbers[Parent[i].Value.Index];
        Result := True;
        Exit;
      end
    end;
  end;
  Result := False;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function FindJsonStrValue(Output: TJsonParserOutput; Parent: TJsonObject; Key: TJsonString; var Value: String): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  I: Integer;
begin
  for I := 0 to Length(Parent) - 1 do
  begin
    if Parent[I].Key = Key then
    begin
      if (Parent[I].Value.Kind = JVKString) then
      begin
        Value := Output.Strings[Parent[i].Value.Index];
        Result := True;
        Exit;
      end
    end;
  end;
  Result := False;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function FindJsonStrArray(Output: TJsonParserOutput; Parent: TJsonObject; Key: TJsonString; var values: TArrayOfString): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  I: Integer;
  J: Integer;
  cnt: Integer;
  foundArray: TJsonArray;
begin
  for I := 0 to Length(Parent) - 1 do begin
    if Parent[I].Key = Key then begin
      if (Parent[I].Value.Kind = JVKArray) then begin
        foundArray := Output.Arrays[Parent[i].Value.Index];
        cnt := 0;
        for J := 0 to GetArrayLength(foundArray) -1 do begin
          if foundArray[J].Kind = JVKString then begin
            cnt := cnt+1;
            setArrayLength(values, cnt);
            values[cnt-1] := Output.Strings[foundArray[J].Index];
          end;
        end;
        Result := True;
        Exit;
      end
    end;
  end;
  Result := False;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function FindJsonIntArray(Output: TJsonParserOutput; Parent: TJsonObject; Key: TJsonString; var values: array of integer): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  I: Integer;
  J: Integer;
  cnt: Integer;
  foundArray: TJsonArray;
begin
  for I := 0 to Length(Parent) - 1 do begin
    if Parent[I].Key = Key then begin
      if (Parent[I].Value.Kind = JVKArray) then begin
        foundArray := Output.Arrays[Parent[i].Value.Index];
        cnt := 0;
        for J := 0 to GetArrayLength(foundArray) -1 do begin
          if foundArray[J].Kind = JVKNumber then begin
            cnt := cnt+1;
            setArrayLength(values, cnt);
            values[cnt-1] := Round(Output.Numbers[foundArray[J].Index]);
          end;
        end;
        Result := True;
        Exit;
      end
    end;
  end;
  Result := False;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function UpdateJsonNumber(Output: TJsonParserOutput; Parent: TJsonObject; Key: TJsonString; Value: TJsonNumber): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  I: Integer;
begin
  for I := 0 to Length(Parent) - 1 do
  begin
    if Parent[I].Key = Key then
    begin
      if (Parent[I].Value.Kind = JVKNumber) then
      begin
        Output.Numbers[Parent[i].Value.Index] := Value;
        Result := True;
        Exit;
      end
    end;
  end;
  Result := False;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure explode(var Dest: TArrayOfString; Text: String; Separator: String);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  i, p: Integer;
begin
  i := 0;
  repeat
    SetArrayLength(Dest, i+1);
    p := Pos(Separator,Text);
    if p > 0 then begin
      Dest[i] := Copy(Text, 1, p-1);
      Text := Copy(Text, p + Length(Separator), Length(Text));
      i := i + 1;
    end
    else begin
      Dest[i] := Text;
      Text := '';
    end;
  until Length(Text)=0;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function convertVersion(s: String; var major: Integer; var minor: Integer; var patch: Integer): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  versionArray: TArrayOfString;
begin
  Result := False;
  explode(versionArray, s, '.');
  if (GetArrayLength(versionArray) > 2) then begin
    major := StrToIntDef(versionArray[0], 0);
    minor := StrToIntDef(versionArray[1], 0);
    patch := StrToIntDef(versionArray[2], 0);
    Result := True;
  end
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function execAndReturnOutput(myCmd: String; allLines: Boolean; addPath: String; wrkDir: String): String;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  tmpTxtFileName: String;
  tmpBatFileName: String;
  resultCode: Integer;
  stdOutTxt: TArrayOfString;
  i: Integer;
begin
  Result := '';
  tmpTxtFileName := getTempPath + '\~iobinst_tmp.txt';
  tmpBatFileName := getTempPath + '\~iobinst_tmp.bat';

  if addPath <> '' then begin
    myCmd := '@echo off' + chr(13) + chr(10) + 'SET PATH=' + addPath + ';%PATH:&=^&%' + chr(13) + chr(10) + myCmd;
  end
  else begin
    myCmd := '@echo off' + chr(13) + chr(10) + myCmd;
  end;

  if (SaveStringToFile(tmpBatFileName, myCmd, false)) then begin
    if (Exec(ExpandConstant('{cmd}'), '/C ' + tmpBatFileName + ' > "' + tmpTxtFileName + '" 2>&1', wrkDir, SW_HIDE, ewWaitUntilTerminated, resultCode)) then begin
      if LoadStringsFromFile(tmpTxtFileName, stdOutTxt) then begin
        if GetArrayLength(stdOutTxt) > 0 then begin
          if allLines then begin
            for i := 0 to GetArrayLength(stdOutTxt)-1 do begin
              Result := Result + stdOutTxt[i] + chr(13) + chr(10);
            end;
          end
          else begin
            Result := stdOutTxt[0];
          end;
        end;
      end;
    end;
  end;
  DeleteFile(tmpTxtFileName);
  DeleteFile(tmpBatFileName);
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function execAndStoreOutput(myCmd: String; myLogFileName: String; addPath: String; wrkDir: String) : Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  tmpBatFileName: String;
  resultCode: Integer;
  logPart: String;
begin
  Result := False;
  tmpBatFileName := getTempPath + '\~iobinst_tmp.bat';

  if addPath <> '' then begin
    myCmd := '@echo off' + chr(13) + chr(10) + 'SET PATH=' + addPath + ';%PATH:&=^&%' + chr(13) + chr(10) + myCmd;
  end
  else begin
    myCmd := '@echo off' + chr(13) + chr(10) + myCmd;
  end;

  if myLogFileName <> '' then begin
    logPart := ' >> "' + myLogFileName + '" 2>>&1';
  end
  else begin
    logPart := '';
  end;

  if (SaveStringToFile(tmpBatFileName, myCmd, false)) then begin
    if (Exec(ExpandConstant('{cmd}'), '/C ' + tmpBatFileName + logPart, wrkDir, SW_HIDE, ewWaitUntilTerminated, resultCode)) then begin
      Result := True;
    end;
  end;
  DeleteFile(tmpBatFileName);
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function directoryCopy(SourcePath, DestPath: string): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  FindRec: TFindRec;
  SourceFilePath: string;
  DestFilePath: string;
begin
  Result := True;
  if DirExists(DestPath) or CreateDir(DestPath) then begin
    if FindFirst(SourcePath + '\*', FindRec) then begin
      try
        repeat
          if (FindRec.Name <> '.') and (FindRec.Name <> '..') then begin
            SourceFilePath := SourcePath + '\' + FindRec.Name;
            DestFilePath := DestPath + '\' + FindRec.Name;
            if FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY = 0 then begin
              if FileCopy(SourceFilePath, DestFilePath, False) then begin
                Log(Format('Copied %s to %s', [SourceFilePath, DestFilePath]));
                marqueePage.setText(CustomMessage('Copying'), Format('%s', [DestFilePath]));

              end
              else begin
                Log(Format('Failed to copy %s to %s', [SourceFilePath, DestFilePath]));
                Result := False;
              end;
            end
            else begin
              if DirExists(DestFilePath) or CreateDir(DestFilePath) then begin
                Log(Format('Created %s', [DestFilePath]));
                Result := directoryCopy(SourceFilePath, DestFilePath);
              end
              else begin
                Log(Format('Failed to create %s', [DestFilePath]));
                Result := False;
              end;
            end;
          end;
        until not FindNext(FindRec);
      finally
        FindClose(FindRec);
      end;
    end
    else begin
      Log(Format('Failed to list %s', [SourcePath]));
      Result := False;
    end;
  end
  else begin
    Log(Format('Failed to create %s', [DestPath]));
    Result := False;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function isDirectoryEmpty(path: string): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  FindRec: TFindRec;
begin
  Result := True;
  if DirExists(path) then begin
    if FindFirst(path + '\*', FindRec) then begin
      try
        repeat
          if (FindRec.Name <> '.') and (FindRec.Name <> '..') then begin
            Result := False;
            Exit;
          end;
        until not FindNext(FindRec);
      finally
        FindClose(FindRec);
      end;
    end;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function firewallRuleSet: Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  output: String;
begin
  Result := False;
  output := execAndReturnOutput(ExpandConstant('{sys}') + '\netsh advfirewall firewall show rule name="Node for ioBroker (inbound)" | find "Node for ioBroker (inbound)"', False, '', '');
  if output <> '' then begin
    Log('Found inbound firewall rule');
    output := execAndReturnOutput(ExpandConstant('{sys}') + '\netsh advfirewall firewall show rule name="Node for ioBroker (outbound)" | find "Node for ioBroker (outbound)"', False, '', '');
    if output <> '' then begin
      Log('Found outbound firewall rule');
      Result := True;
    end
    else begin
      Log('Outbound firewall rule not found');
    end;
  end
  else begin
    Log('Inbound firewall rule not found');
  end;
end;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 Logfile names
 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function getLogNameNodeJsInstall: String;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := appInstPath + '\log\installNodeJs.log';
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function getLogNameIoBrokerInstall: String;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := appInstPath + '\log\installIoBroker.log';
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function getLogNameIoBrokerFix: String;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := appInstPath + '\log\installIoBrokerFix.log';
end;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 Callbacks for downloads
 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  if Progress = ProgressMax then
    Log(Format('Successfully downloaded file to %s: %s', [ExpandConstant('{tmp}'), FileName]));
  Result := True;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function OnDownloadProgressNode(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  progressPage.SetProgress(Progress, ProgressMax);
  if Progress = ProgressMax then
    Log(Format('Successfully downloaded file to %s: %s', [ExpandConstant('{tmp}'), FileName]));
  Result := True;
end;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 Functions to get system information
 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function ioBrokerNeedsStart: Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := (optInstallIoBrokerCB.Checked = False) and (optFixIoBrokerCB.Checked = False);
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function isIobServiceRunning(serviceName: String): boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  statusString: String;
begin
  statusString := execAndReturnOutput('sc query ' + serviceName + '.exe', True, '', '');
  Log(Format('ioBroker Service Status: %s', [statusString]));
  Result := pos('RUNNING', statusString) > 0;
end;


{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure createPortBatch;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  txt: String;
begin
  if not fileExists(getTempPath + '\port.bat') then begin
    txt := '@echo off & setlocal EnableDelayedExpansion' + #13#10
         + 'if [%1]==[] goto:ERROR' + #13#10
         +'set port=%1' + #13#10
         + 'set last=[]' + #13#10
         + 'for /f "tokens=1-5" %%a in (''netstat -ano'') do (' + #13#10
         + '  if [%%b] == [[::]:%port%] (' + #13#10
         + '    if not [%%e]==[0] (' + #13#10
         + '      if not !last! == [%%e] (' + #13#10
         + '        for /f "skip=3 tokens=1-5" %%i in (''tasklist /FO TABLE /FI "PID eq %%e"'') do (' + #13#10
         + '          echo %port%;%%i;%%e' + #13#10
         + '        )' + #13#10
         + '      )' + #13#10
         + '      set last=[%%e]' + #13#10
         + '    )' + #13#10
         + '  )' + #13#10
         + #13#10
         + '  if [%%b] == [127.0.0.1:%port%] (' + #13#10
         + '    if not [%%e]==[0] (' + #13#10
         + '      if not !last! == [%%e] (' + #13#10
         + '        for /f "skip=3 tokens=1-5" %%i in (''tasklist /FO TABLE /FI "PID eq %%e"'') do (' + #13#10
         + '          echo %port%;%%i;%%e' + #13#10
         + '        )' + #13#10
         + '      )' + #13#10
         + '      set last=[%%e]' + #13#10
         + '    )' + #13#10
         + '  )' + #13#10
         + ')' + #13#10
         + #13#10
         + 'goto:eof' + #13#10
         + ':ERROR' + #13#10
         + 'echo ERROR - No port given' + #13#10;
    saveStringToFile(getTempPath + '\port.bat', txt, false);
  end;
end;



{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function getPortInfo(port: Integer): String;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  createPortBatch
  Result := execAndReturnOutput(Format('%s\port.bat %d', [getTempPath, port]), False, '', '');
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function checkIoBrokerRunning(info: String): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  iobServiceOK: Boolean;
  portInfo: String;
  i: Integer;
begin
  Result := False;
  marqueePage.SetText(info, CustomMessage('WaitForService'));
  for i := 0 to 15 do begin
    Sleep(1000);
    iobServiceOK := isIobServiceRunning(iobServiceName);
    if iobServiceOK then break;
  end;
  if iobServiceOK then begin
    Log('ioBroker service was started!');
    marqueePage.SetText(info, CustomMessage('WaitForAdmin'));
    for i := 0 to 100 do begin
    Sleep(500);
      portInfo := getPortInfo(iobAdminPort);
      if portInfo <> '' then break;
    end;
    if portInfo <> '' then begin
      Log('ioBroker Admin is reachable!');
      Result := True;
    end
    else begin
      Log('ioBroker Admin is not reachable!');
    end
  end
  else begin
    Log('ioBroker service was not started!');
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function getIoBrokerServiceNameFromEnv(iobPath: String): String;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  envText: TArrayOfString;
  i: Integer;
begin
  Result := 'ioBroker'; // Default server name if no .env file exists
  // Check for user defined service name:
  if FileExists(iobPath + '\.env') then begin
    if LoadStringsFromFile(iobPath + '\.env', envText) then begin
      if GetArrayLength(envText) > 0 then begin
        for i := 0 to GetArrayLength(envText)-1 do begin
          if Pos('iobservicename=', Lowercase(envText[i])) = 1 then begin
            Result := Trim(Copy(envText[i], 16, Length(envText[i])-15));
            Log('ioB service name: ' + Result);
          end;
        end;
      end;
    end;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function gatherIoBrokerInfo: Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  ioBrokerEx: String;
  nodeJsEx: String;
  versionString: String;
begin
  Result := False;
  iobVersionMajor := 0;
  iobVersionMinor := 0;
  iobVersionPatch := 0;

  ioBrokerEx := appInstPath + '\node_modules\iobroker.js-controller/iobroker.js';
  if (FileExists(ioBrokerEx)) then begin
    Result := True;
    if (nodePath <> '') then begin
      nodeJsEx := nodePath + '\node.exe';
      versionString := execAndReturnOutput('"' + nodeJsEx + '" "' + ioBrokerEx + '" --version', False, nodePath, '');
      if (convertVersion(versionString, iobVersionMajor, iobVersionMinor, iobVersionPatch)) then begin
        Log(Format('Found ioBroker version: %d, %d, %d', [iobVersionMajor, iobVersionMinor, iobVersionPatch]));
      end
    end
    else begin
      iobControllerFoundNoNode := True;
      Log('ioBroker.js-controller found, but Node.js not found.');
    end;
  end
  else begin
    Log('ioBroker.js-controller not found.');
  end;

  if expertCB.Checked and exoNewServerRB.Checked then begin
    // In this case we use the entered service name, because the according .env file was not created yet
    iobServiceName := iobTargetServiceName;
  end
  else begin
    // Otherwise we use the service name from the .env file
    iobServiceName := getIoBrokerServiceNameFromEnv(appInstPath);
  end;

  iobServiceExists := (execAndReturnOutput('sc GetDisplayName ' + iobServiceName + '.exe | find /C "' + iobServiceName + '"', False, '', '') = '1');
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function getIobAdminPort(iobPath: String): Integer;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  ioBrokerEx: String;
  nodeJsEx: String;
  tmpFileName: String;
  instanceList: TArrayOfString;
  i: Integer;
  startIdx: Integer;
  endIdx: Integer;
  tmpStr: String;
begin
  ioBrokerEx := iobPath + '\node_modules\iobroker.js-controller/iobroker.js';
  if (FileExists(ioBrokerEx)) and (nodePath <> '' )then begin
    nodeJsEx := nodePath + '\node.exe';
    tmpFileName := getTempPath + '\~iobinstAdmin_tmp.txt';
    if execAndStoreOutput('"' + nodeJsEx + '" "' + ioBrokerEx + '" list instances', tmpFileName, nodePath, '' ) then begin
      if LoadStringsFromFile(tmpFileName, instanceList) then begin
        if GetArrayLength(instanceList) > 0 then begin
          for i := 0 to GetArrayLength(instanceList)-1 do begin
            if Pos('system.adapter.admin', instanceList[i]) > 0 then begin
              startIdx := Pos('enabled', instanceList[i]);
              if startIdx > 0 then begin
                tmpStr := Copy(instanceList[i], startIdx, Length(instanceList[i]) - startIdx)
                startIdx := Pos('port:', tmpStr);
                if startIdx > 0 then begin
                  tmpStr := Copy(tmpStr, startIdx + 5, Length(tmpStr) - startIdx - 3);
                  endIdx := Pos(',', tmpStr);
                  if endIdx > 0 then begin
                    tmpStr := Copy(tmpStr, 1, endIdx-1);
                    Result := StrToIntDef(Trim(tmpStr), 8081);
                    Log('Admin port found!');
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  DeleteFile(tmpFileName);
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure gatherIobPortsAndServername(iobPath: String; var statesPort: Integer; var objectsPort: Integer; var adminPort: Integer; var serverName: string);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  JsonParser: TJsonParser;
  jsonString: AnsiString;
  jsonObject: TJsonObject;
  jsonPort: TJsonNumber;
begin
  // states and objects port:
  if FileExists(iobPath + '\iobroker-data\iobroker.json') then begin
    LoadStringFromFile(iobPath + '\iobroker-data\iobroker.json', jsonString);
    ClearJsonParser(JsonParser);
    ParseJson(JsonParser, jsonString);
    if Length(JsonParser.Output.Objects) > 0 then begin
      if FindJsonObject(JsonParser.Output, JsonParser.Output.Objects[0], 'states', jsonObject) then begin
        if FindJsonNumber(JsonParser.Output, jsonObject, 'port', jsonPort) then begin
          statesPort := Round(jsonPort);
          Log('States port found!');
        end;
      end;
      if FindJsonObject(JsonParser.Output, JsonParser.Output.Objects[0], 'objects', jsonObject) then begin
        if FindJsonNumber(JsonParser.Output, jsonObject, 'port', jsonPort) then begin
          objectsPort := Round(jsonPort);
          Log('Objects port found!');
        end;
      end;
      if FindJsonObject(JsonParser.Output, JsonParser.Output.Objects[0], 'system', jsonObject) then begin
        if FindJsonStrValue(JsonParser.Output, jsonObject, 'hostname', serverName) then begin
          if servername = '' then begin
            serverName := '<Default>';
          end;
          Log('Hostname/Servername found!');
        end
        else begin
          Log('Hostname/Servername NOT found!');
        end;
      end;
    end;
  end;

  // Admin port:
  iobAdminPort := getIobAdminPort(iobPath);

  Log(Format('statesPort:  %d', [statesPort]));
  Log(Format('objectsPort: %d', [objectsPort]));
  Log(Format('adminPort:   %d', [adminPort]));
  Log(Format('serverName:  %s', [serverName]));
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function gatherIoBrokerStatus: boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  ioBrokerEx: String;
  nodeJsEx: String;
begin
  Result := False;
  ioBrokerEx := appInstPath + '\node_modules\iobroker.js-controller/iobroker.js';
  nodeJsEx := nodePath + '\node.exe';
  if (FileExists(ioBrokerEx)) then begin
    // The following code is not optimal, because sometimes "iob status" answers "running"
    // Even if the service has been stopped more than a minute ago.
    {
    if (nodePath <> '') then begin
      statusString := execAndReturnOutput('"' + nodeJsEx + '" "' + ioBrokerEx + '" status', False);
      Log(Format('ioBroker Status: %s', [statusString]));
      Result := statusString = 'iobroker is running on this host.';
    end;
    }
    // Check the service instead:
    Result := isIobServiceRunning(iobServiceName);
  end
  else begin
    Log('ioBroker.js-controller not found.');
  end
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure gatherInstNodeData;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  versionString: String;
  found: boolean;
begin
  found := false;
  instNodeVersionMajor := 0;
  instNodeVersionMinor := 0;
  instNodeVersionPatch := 0;

  if RegKeyExists(GetHKLM, 'SOFTWARE\Node.js') then begin
    if (RegQueryStringValue(GetHKLM, 'SOFTWARE\Node.js', 'InstallPath', nodePath)) then begin
      if (nodePath <> '') then begin
        nodePath := RemoveBackslash(ExtractFilePath(nodePath));
        Log(Format('Found Node.js path: %s', [nodePath]));
        RegQueryStringValue(GetHKLM, 'SOFTWARE\Node.js', 'Version', versionString);
        if (nodePath <> '') then begin
          Log('NodePath: ' + nodePath);
          if (convertVersion(versionString, instNodeVersionMajor, instNodeVersionMinor, instNodeVersionPatch)) then begin
            Log(Format('Found Node version: %d, %d, %d', [instNodeVersionMajor, instNodeVersionMinor, instNodeVersionPatch]));
            found := true;
          end;
        end;
      end;
    end;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure gatherNodeData;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  JsonParser: TJsonParser;
  jsonString: AnsiString;
  nodeRecommendedMajorNr: TJsonNumber;
  nodeRecommendedMajorUrl: String;
  nodeLatestList: TArrayOfString;
  searchString: String;
  i: Integer;
  endPos: Integer;
  startPos: Integer;
  versionString: String;
  nodeFileName: String;
  errorOccurred: Boolean;
begin
  errorOccurred := False;
  try
    if rcmdNodeVersionMajor = 0 then begin
      try
        DownloadTemporaryFileAndCopy(ExpandConstant('{#URL_IOB_VERSIONS_JSON}'), '~iobinfo.json', '', @OnDownloadProgress);
      except
        errorOccurred := True;
      end;
      if not errorOccurred then begin
        LoadStringFromFile(getTempPath + '\~iobinfo.json', jsonString);
        ClearJsonParser(JsonParser);
        ParseJson(JsonParser, jsonString);
        if Length(JsonParser.Output.Objects) > 0 then begin
          if FindJsonNumber(JsonParser.Output, JsonParser.Output.Objects[0], 'nodeJsRecommended', nodeRecommendedMajorNr) then begin
            nodeRecommendedMajorUrl := Format(ExpandConstant('{#URL_NODEJS_LATEST_MAJOR}'), [Round(nodeRecommendedMajorNr)]);
            Log(Format('Node Recommended: %d', [Round(nodeRecommendedMajorNr)]));
            Log('->' + nodeRecommendedMajorUrl);
          end
          else begin
            errorOccurred := True;
          end;
          FindJsonIntArray (JsonParser.Output, JsonParser.Output.Objects[0], 'nodeJsAccepted', acceptedNodeVersions);
          for i:=0 to GetArrayLength(acceptedNodeVersions)-1 do begin
            Log(Format('Node Accepted: %d',[acceptedNodeVersions[i]]));
          end;
        end
        else begin
          errorOccurred := True;
        end;
      end;
      if errorOccurred then begin
        MsgBox(Format(CustomMessage('DownloadError'), [ExpandConstant('{#URL_IOB_VERSIONS_JSON}')]), mbError, MB_OK);
        Exit;
      end;

      try
        DownloadTemporaryFileAndCopy(nodeRecommendedMajorUrl, '~nodeInfo.txt', '', @OnDownloadProgress);
      except
        Log(GetExceptionMessage);
        MsgBox(Format(CustomMessage('DownloadErrorGatherNode'), [nodeRecommendedMajorUrl, '~nodeInfo.txt']), mbError, MB_OK);
        Exit;
      end;
      if LoadStringsFromFile(getTempPath + '\~nodeInfo.txt', nodeLatestList) then begin
        if (IsWin64) then begin
          searchString := '-x64.msi';
        end
        else begin
          searchString := '-x86.msi';
        end;

        for i:=0 to GetArrayLength(nodeLatestList)-1 do begin
          endPos := Pos(searchString, nodeLatestList[i]);
          if endPos > 0 then begin
            startPos := Pos('node-v', nodeLatestList[i]);
            if endpos > startPos then begin
              nodeFileName := Copy(nodeLatestList[i], startPos, endPos-startPos+Length(searchString));
              versionString := Copy(nodeLatestList[i], startPos+6, endPos-startPos-6);
              Log(nodeFileName);
              Log(versionString);
              rcmdNodeDownloadPath := Format( ExpandConstant('{#URL_NODEJS_LATEST_FULL}'),[Round(nodeRecommendedMajorNr), nodeFileName]);
              Log(rcmdNodeDownloadPath);
              if (convertVersion(versionString, rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch)) then begin
                Log(Format('Recommended Node version: %d, %d, %d', [rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch]));
              end;
              break;
            end;
          end;
        end;
      end;
    end;
  except
    Log(GetExceptionMessage);
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function isNodeVersionSupported(version: Integer): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
i: Integer;
begin
  Result := False;
  if version = rcmdNodeVersionMajor then begin
    Result := True;
  end
  else begin
    for i:=0 to GetArrayLength(acceptedNodeVersions)-1 do begin
      if version = acceptedNodeVersions[i] then begin
        Result := True;
        break;
      end;
    end;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function checkForStabilostickInstallation(path: String): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := DirExists(path + '\nodejs');
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function isIobServiceAutoStartReg(serviceName: String): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  serviceStartMode: Cardinal;
begin
  result := True;
  if RegQueryDWordValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Services\' + Lowercase(serviceName) + '.exe', 'Start', ServiceStartMode) then begin
    if ServiceStartMode <> 2 then begin
      result := False;
    end;
  end;
end;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 Update page functions
 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure updateSummaryPagePortsA(statesPort: Integer; objectsPort: Integer; adminPort: Integer; var portsInUse: Boolean; maxProgress: Integer; var progress: Integer);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  portInfo: String;
  portInfoArray: TArrayOfString;
begin
  portInfo := getPortInfo(statesPort);
  if portinfo <> '' then begin
    explode(portInfoArray, portInfo, ';');
    sumInfo1PortStatesLabelA.Font.Color := clRed;
    sumInfo1PortStatesLabelA.Caption := '⚠';
    if GetArrayLength(portInfoArray) >= 3 then begin
      sumInfo2PortStatesLabelA.Caption := Format(CustomMessage('PortInUse'), [portInfoArray[0], portInfoArray[1], portInfoArray[2]]);
    end
    else begin
      sumInfo2PortStatesLabelA.Caption := Format('<unknown> %s', [portInfo]);
    end;
    readyToInstall := False;
    portsInUse := True;
  end
  else begin
    sumInfo1PortStatesLabelA.Font.Color := clGreen;
    sumInfo1PortStatesLabelA.Caption := '✓';
    sumInfo2PortStatesLabelA.Caption := Format(CustomMessage('PortAvailable'), [statesPort]);
  end;
  progressPage.SetProgress(progress, maxProgress); progress := progress + 1;

  portInfo := getPortInfo(objectsPort);
  if portInfo <> '' then begin
    explode(portInfoArray, portInfo, ';');
    sumInfo1PortObjectsLabelA.Font.Color := clRed;
    sumInfo1PortObjectsLabelA.Caption := '⚠';
    if GetArrayLength(portInfoArray) >= 3 then begin
      sumInfo2PortObjectsLabelA.Caption := Format(CustomMessage('PortInUse'), [portInfoArray[0], portInfoArray[1], portInfoArray[2]]);
    end
    else begin
      sumInfo2PortObjectsLabelA.Caption := Format('<unknown> %s', [portInfo]);
    end;
    readyToInstall := False;
    portsInUse := True;
  end
  else begin
    sumInfo1PortObjectsLabelA.Font.Color := clGreen;
    sumInfo1PortObjectsLabelA.Caption := '✓';
    sumInfo2PortObjectsLabelA.Caption := Format(CustomMessage('PortAvailable'), [objectsPort]);
  end;
  progressPage.SetProgress(progress, maxProgress); progress := progress + 1;

  portInfo := getPortInfo(adminPort);
  if portInfo <> '' then begin
    explode(portInfoArray, portInfo, ';');
    sumInfo1PortAdminLabelA.Font.Color := clRed;
    sumInfo1PortAdminLabelA.Caption := '⚠';
    if GetArrayLength(portInfoArray) >= 3 then begin
      sumInfo2PortAdminLabelA.Caption := Format(CustomMessage('PortInUse'), [portInfoArray[0], portInfoArray[1], portInfoArray[2]]);
    end
    else begin
      sumInfo2PortAdminLabelA.Caption := Format('<unknown> %s', [portInfo]);
    end;
    readyToInstall := False;
    portsInUse := True;
  end
  else begin
    sumInfo1PortAdminLabelA.Font.Color := clGreen;
    sumInfo1PortAdminLabelA.Caption := '✓';
    sumInfo2PortAdminLabelA.Caption := Format(CustomMessage('PortAvailable'), [adminPort]);
  end;
  progressPage.SetProgress(progress, maxProgress); progress := progress + 1;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure updateSummaryPagePortsB(statesPort: Integer; objectsPort: Integer; adminPort: Integer; var portsInUse: Boolean; maxProgress: Integer; var progress: Integer);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  portInfo: String;
  portInfoArray: TArrayOfString;
begin
  if statesPort <> 9000 then begin
    portInfo := getPortInfo(statesPort);
    if portinfo <> '' then begin
      explode(portInfoArray, portInfo, ';');
      sumInfo1PortStatesLabelB.Font.Color := clRed;
      sumInfo1PortStatesLabelB.Caption := '⚠';
      if GetArrayLength(portInfoArray) >= 3 then begin
        sumInfo2PortStatesLabelB.Caption := Format(CustomMessage('PortInUse'), [portInfoArray[0], portInfoArray[1], portInfoArray[2]]);
      end
      else begin
        sumInfo2PortStatesLabelB.Caption := Format('<unknown> %s', [portInfo]);
      end;
      readyToInstall := False;
      portsInUse := True;
    end
    else begin
      sumInfo1PortStatesLabelB.Font.Color := clGreen;
      sumInfo1PortStatesLabelB.Caption := '✓';
      sumInfo2PortStatesLabelB.Caption := Format(CustomMessage('PortAvailable'), [statesPort]);
    end;
  end
  else begin
      sumInfo1PortStatesLabelB.Caption := '';
      sumInfo2PortStatesLabelB.Caption := '';
  end;
  progressPage.SetProgress(progress, maxProgress); progress := progress + 1;

  if objectsPort <> 9001 then begin
    portInfo := getPortInfo(objectsPort);
    if portInfo <> '' then begin
      explode(portInfoArray, portInfo, ';');
      sumInfo1PortObjectsLabelB.Font.Color := clRed;
      sumInfo1PortObjectsLabelB.Caption := '⚠';
      if GetArrayLength(portInfoArray) >= 3 then begin
        sumInfo2PortObjectsLabelB.Caption := Format(CustomMessage('PortInUse'), [portInfoArray[0], portInfoArray[1], portInfoArray[2]]);
      end
      else begin
        sumInfo2PortObjectsLabelB.Caption := Format('<unknown> %s', [portInfo]);
      end;
      readyToInstall := False;
      portsInUse := True;
    end
    else begin
      sumInfo1PortObjectsLabelB.Font.Color := clGreen;
      sumInfo1PortObjectsLabelB.Caption := '✓';
      sumInfo2PortObjectsLabelB.Caption := Format(CustomMessage('PortAvailable'), [objectsPort]);
    end;
  end
  else begin
      sumInfo1PortObjectsLabelB.Caption := '';
      sumInfo2PortObjectsLabelB.Caption := '';
  end;
  progressPage.SetProgress(progress, maxProgress); progress := progress + 1;

  if adminPort <> 8081 then begin
    portInfo := getPortInfo(adminPort);
    if portInfo <> '' then begin
      explode(portInfoArray, portInfo, ';');
      sumInfo1PortAdminLabelB.Font.Color := clRed;
      sumInfo1PortAdminLabelB.Caption := '⚠';
      if GetArrayLength(portInfoArray) >= 3 then begin
        sumInfo2PortAdminLabelB.Caption := Format(CustomMessage('PortInUse'), [portInfoArray[0], portInfoArray[1], portInfoArray[2]]);
      end
      else begin
        sumInfo2PortAdminLabelB.Caption := Format('<unknown> %s', [portInfo]);
      end;
      readyToInstall := False;
      portsInUse := True;
    end
    else begin
      sumInfo1PortAdminLabelB.Font.Color := clGreen;
      sumInfo1PortAdminLabelB.Caption := '✓';
      sumInfo2PortAdminLabelB.Caption := Format(CustomMessage('PortAvailable'), [adminPort]);
    end;
  end
  else begin
      sumInfo1PortAdminLabelB.Caption := '';
      sumInfo2PortAdminLabelB.Caption := '';
  end;
  progressPage.SetProgress(progress, maxProgress); progress := progress + 1;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure updateSummaryPage;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  maxProgress: Integer;
  progress: Integer;
  iobRunning: Boolean;
  portsInUse: Boolean;
  summaryText: String;
begin
  iobRunning := False;
  iobInstalled := False;
  summaryText := '';
  portsInUse := False;
  readyToInstall := True;
  maxProgress := 12;
  progress := 0;

  tryStopServiceAtNextRetry := False;

  progressPage.SetProgress(progress, maxProgress); progress := progress + 1;
  progressPage.Show
  progressPage.SetText(CustomMessage('GatherInformation'), 'Node.js');
  gatherInstNodeData;

  progressPage.SetProgress(progress, maxProgress); progress := progress + 1;
  progressPage.SetText(CustomMessage('GatherInformation'), 'ioBroker');
  iobInstalled := gatherIoBrokerInfo;
  progressPage.SetProgress(progress, maxProgress); progress := progress + 1;
  gatherIobPortsAndServername(appInstPath, iobStatesPort, iobObjectsPort, iobAdminPort, iobServerName);

  progressPage.SetProgress(progress, maxProgress); progress := progress + 1;
  iobRunning := gatherIoBrokerStatus;

  progressPage.SetProgress(progress, maxProgress); progress := progress + 1;
  progressPage.SetText(CustomMessage('GatherInformation'), CustomMessage('RecommendenNodeVersion'));
  gatherNodeData;

  progressPage.SetProgress(progress, maxProgress); progress := progress + 1;
  progressPage.SetText(CustomMessage('GatherInformation'), CustomMessage('RequiredPorts'));

  if instNodeVersionMajor = 0 then begin
    sumInfo1NodeLabel.Font.Color := clBlue;
    sumInfo1NodeLabel.Caption := '✗';
    sumInfo2NodeLabel.Caption := CustomMessage('NodeNotInstalled');
  end
  else begin
    if instNodeVersionMajor = rcmdNodeVersionMajor then begin
      sumInfo1NodeLabel.Font.Color := clGreen;
      sumInfo1NodeLabel.Caption := '✓';
      sumInfo2NodeLabel.Caption := Format(CustomMessage('NodeInstalled'), [instNodeVersionMajor, instNodeVersionMinor, instNodeVersionPatch, nodePath]);
    end
    else begin
      if isNodeVersionSupported(instNodeVersionMajor) then begin
        sumInfo1NodeLabel.Font.Color := clYellow;
        sumInfo1NodeLabel.Caption := '⚠';
        sumInfo2NodeLabel.Caption := Format(CustomMessage('NodeInstalled'), [instNodeVersionMajor, instNodeVersionMinor, instNodeVersionPatch, nodePath]);
      end
      else begin
        sumInfo1NodeLabel.Font.Color := clRed;
        sumInfo1NodeLabel.Caption := '⚠';
        sumInfo2NodeLabel.Caption := Format(CustomMessage('NodeInstalled'), [instNodeVersionMajor, instNodeVersionMinor, instNodeVersionPatch, nodePath]);
      end;
    end;
  end;

  sumInfo3NodeLabel.Caption := Format(CustomMessage('NodeRecommended'), [rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch]);

  if iobVersionMajor = 0 then begin
    if iobControllerFoundNoNode then begin
      sumInfo1IoBrokerLabel.Font.Color := clBlue;
      sumInfo1IoBrokerLabel.Caption := '?';
      sumInfo2IoBrokerLabel.Caption := Format(CustomMessage('IoBrokerControllerFoundNoNode'), [appInstPath]);
    end
    else begin
      sumInfo1IoBrokerLabel.Font.Color := clBlue;
      sumInfo1IoBrokerLabel.Caption := '✗';
      sumInfo2IoBrokerLabel.Caption := Format(CustomMessage('IoBrokerNotInstalled'), [appInstPath]);
    end
  end
  else begin
    sumInfo1IoBrokerLabel.Font.Color := clGreen;
    sumInfo1IoBrokerLabel.Caption := '✓';
    sumInfo2IoBrokerLabel.Caption := Format(CustomMessage('IoBrokerInstalled'), [iobVersionMajor, iobVersionMinor, iobVersionPatch, appInstPath]);
  end;

  if iobRunning then begin
    sumInfo1IoBrokerRunLabel.Font.Color := clRed;
    sumInfo1IoBrokerRunLabel.Caption := '⚠';
    sumInfo2IoBrokerRunLabel.Caption := CustomMessage('IoBrokerRunning') + ' ' + Format(CustomMessage('Service'), [iobServiceName]);
    readyToInstall := False;
  end
  else begin
    sumInfo1IoBrokerRunLabel.Font.Color := clGreen;
    sumInfo1IoBrokerRunLabel.Caption := '✓';
    sumInfo2IoBrokerRunLabel.Caption := CustomMessage('IoBrokerNotRunning') + ' ' + Format(CustomMessage('Service'), [iobServiceName]);
  end;

  // Check ports, which are in any case necessary for installation:
  if (iobVersionMajor = 0) and (iobControllerFoundNoNode = False) then begin

    updateSummaryPagePortsA(9000, 9001, 8081, portsInUse, maxProgress, progress);
    updateSummaryPagePortsB(iobStatesPort, iobObjectsPort, iobAdminPort, portsInUse, maxProgress, progress);
  end
  else begin
    // Check used ports if only "fix" is possible (in this case the standard ports above are not relevant)
    sumInfo1PortStatesLabelB.Caption := '';
    sumInfo2PortStatesLabelB.Caption := '';
    sumInfo1PortObjectsLabelB.Caption := '';
    sumInfo2PortObjectsLabelB.Caption := '';
    sumInfo1PortAdminLabelB.Caption := '';
    sumInfo2PortAdminLabelB.Caption := '';

    progressPage.SetProgress(progress, maxProgress); progress := progress +3;
    updateSummaryPagePortsA(iobStatesPort, iobObjectsPort, iobAdminPort, portsInUse, maxProgress, progress);
  end;

  if iobRunning then begin
    if portsInUse then begin
      if iobServiceExists then begin
        summaryText := CustomMessage('noInstPortsAndRunningAndService'); // Try to stop service next retry
        tryStopServiceAtNextRetry := True;
      end
      else begin
        summaryText := CustomMessage('noInstPortsAndRunning');
      end
    end
    else begin
      summaryText := CustomMessage('runningOtherPort'); // Should never occur
      tryStopServiceAtNextRetry := True;
    end
  end
  else begin
    if portsInUse then begin
      summaryText := CustomMessage('noInstPorts');
    end
    else begin
      if iobControllerFoundNoNode then begin
        summaryText := Format(CustomMessage('iobProbablyInstalled'), [appInstPath]);
      end
      else begin
        if iobServiceExists then begin
          if iobInstalled = False then begin
            summaryText := Format(CustomMessage('warningService'), [iobServiceName]);
          end
        end
      end;
    end
  end;

  if readyToInstall then begin
    sumRetryButton.Hide
  end
  else begin
    sumRetryButton.Show
  end;

  sumSummaryLabel.Caption := summaryText;

  progressPage.Hide;

end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure updateOptionsPage;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  optAdditionalHintsLabel.Caption := '';
  optDataMigrationCB.Visible := False;
  optDataMigrationButton.Visible := False;
  optDataMigrationCB.Checked := False;
  optDataMigrationLabel.Caption := '';

  if instNodeVersionMajor = 0 then begin
    optInstallNodeCB.checked := True;
    optInstallNodeCB.Caption := ' ' + Format(CustomMessage('InstallNodejs'),[rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch]);
    optInstallNodeCB.Enabled := False;
  end
  else begin
    if instNodeVersionMajor > rcmdNodeVersionMajor then begin
      optInstallNodeCB.checked := False;
      optInstallNodeCB.Caption := ' ' + Format(CustomMessage('InstallNodejsMajorTooHigh'),[instNodeVersionMajor, instNodeVersionMinor, instNodeVersionPatch, rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch]);
      optInstallNodeCB.Enabled := False;
      optAdditionalHintsLabel.Caption := CustomMessage('NodejsMajorTooHigh');
    end
    else begin
      if isNodeVersionSupported(instNodeVersionMajor) = False then begin
        optInstallNodeCB.checked := True;
        optInstallNodeCB.Caption := ' ' + Format(CustomMessage('InstallNodejsMajorTooLow'),[instNodeVersionMajor, instNodeVersionMinor, instNodeVersionPatch, rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch]);
        optInstallNodeCB.Enabled := False;
        optAdditionalHintsLabel.Caption := CustomMessage('NodejsMajorTooLow');
      end
      else begin
        if (instNodeVersionMajor = rcmdNodeVersionMajor) and (instNodeVersionMinor = rcmdNodeVersionMinor) and (instNodeVersionPatch = rcmdNodeVersionPatch) then begin
          optInstallNodeCB.checked := False;
          optInstallNodeCB.Caption := ' ' + Format(CustomMessage('InstallNodejsAlreadyInstalled'),[instNodeVersionMajor, instNodeVersionMinor, instNodeVersionPatch, rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch]);
          optInstallNodeCB.Enabled := True;
        end
        else begin
          optInstallNodeCB.checked := True;
          optInstallNodeCB.Caption := ' ' + Format(CustomMessage('UpdateNodejs'),[instNodeVersionMajor, instNodeVersionMinor, instNodeVersionPatch, rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch]);
          optInstallNodeCB.Enabled := True;
        end
      end
    end;
  end;

  if (iobVersionMajor = 0) and (iobControllerFoundNoNode = False) then begin
    optInstallIoBrokerCB.checked := True;
    optInstallIoBrokerCB.Caption := ' ' + Format(CustomMessage('InstallIoBroker'),[appInstPath]);
    optInstallIoBrokerCB.Enabled := False;

    optFixIoBrokerCB.checked := False;
    optFixIoBrokerCB.Caption := ' ' + Format(CustomMessage('FixIoBroker'),[appInstPath]);
    optFixIoBrokerCB.Enabled := False;
  end
  else begin
    optInstallIoBrokerCB.checked := False;
    optInstallIoBrokerCB.Caption := ' ' + Format(CustomMessage('InstallIoBrokeralreadyInstalled'),[appInstPath]);
    optInstallIoBrokerCB.Enabled := False;

    optFixIoBrokerCB.checked := True;
    optFixIoBrokerCB.Caption := ' ' + Format(CustomMessage('FixIoBroker'),[appInstPath]);
    optFixIoBrokerCB.Enabled := True;
  end;

  optAddFirewallRuleCB.Checked := optInstallIoBrokerCB.checked or firewallRuleSet;
  optAddFirewallRuleCB.Caption := ' ' + CustomMessage('AdaptFirewallRule');

  optServiceAutoStartCB.Checked := isIobServiceAutoStartReg(iobServiceName);
  optServiceAutoStartCB.Caption := ' ' + CustomMessage('ServiceAutostart');

  if optInstallIoBrokerCB.Checked then begin
    optDataMigrationCB.Visible := True;
    optDataMigrationButton.Visible := True;
    optDataMigrationButton.Enabled := False;
  end;

end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure updateNextOptionPage(sender: TObject);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  WizardForm.NextButton.Enabled := True;
  if (optInstallNodeCB <> nil) and
     (optInstallNodeCB <> nil) and
     (optInstallNodeCB <> nil) and
     (optAddFirewallRuleCB <> nil) and
     (optDataMigrationCB <> nil) and
     (optServiceAutoStartCB <> nil)
  then begin
    if optInstallNodeCB.Checked or
       optInstallIoBrokerCB.Checked or
       optFixIoBrokerCB.Checked or
       optDataMigrationCB.Checked or
       (optServiceAutoStartCB.Checked <> isIobServiceAutoStartReg(iobServiceName)) or
       (optAddFirewallRuleCB.Checked <> firewallRuleSet)

    then begin
      if optDataMigrationCB.Checked and (optDataMigrationLabel.Caption = '') then begin
        WizardForm.NextButton.Enabled := False;
      end
      else begin
        WizardForm.NextButton.Enabled := True;
      end;
    end
    else begin
        WizardForm.NextButton.Enabled := False;
    end;
  end;
  WizardForm.Update;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure updateMigrationControls(sender: TObject);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  if optDataMigrationCB.Checked then begin
    optDataMigrationButton.Enabled := True;
  end
  else begin
    optDataMigrationButton.Enabled := False;
    optDataMigrationLabel.Caption := '';
  end;
  updateNextOptionPage(sender);
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure selectMigrationFolder(sender: TObject);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var dir: String;
begin
  dir := optDataMigrationLabel.Caption;
  if dir = '' then dir := 'c:\';
  if BrowseForFolder(CustomMessage('SelectMigrationDir'), dir, False) then begin
    if FileExists(dir + '\iobroker.json') and FileExists(dir + '\objects.jsonl')  and FileExists(dir + '\states.jsonl') then begin
      optDataMigrationLabel.Caption := dir;
    end
    else begin
      dir := dir + '\iobroker-data';
      if FileExists(dir + '\iobroker.json') and FileExists(dir + '\objects.jsonl')  and FileExists(dir + '\states.jsonl') then begin
        optDataMigrationLabel.Caption := dir;
      end
      else begin
        optDataMigrationLabel.Caption := '';
        MsgBox(Format(CustomMessage('NoValidMigrationFolder'), [rcmdNodeDownloadPath]), mbError, MB_OK);
      end;
    end;
    updateNextOptionPage(sender);
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure createPages;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  if summaryPage = nil then begin
    if isFirstInstallerRun then begin
      expertOptionsPage := CreateCustomPage(wpSelectDir, CustomMessage('ExpertMode'), CustomMessage('ExpertOptionsCaption'));
    end
    else begin
      expertOptionsPage := CreateCustomPage(wpWelcome, CustomMessage('ExpertMode'), CustomMessage('ExpertOptionsCaption'));
    end;

    expertSettingsPage := CreateCustomPage(expertOptionsPage.ID, CustomMessage('ExpertMode'), '');
    summaryPage := CreateCustomPage(expertSettingsPage.ID, 'ioBroker - Automate your life', '');
    optionsPage := CreateCustomPage(summaryPage.ID, 'ioBroker - Automate your life', '');

    // Controls summary page -----------------------------------------------------------------------------------
    sumInfo1NodeLabel := TLabel.Create(WizardForm);
    with sumInfo1NodeLabel do begin
      Parent := summaryPage.Surface;
      Left := ScaleX(8);
      Top := 0;
      Width := ScaleX(12);
      Height := ScaleX(12);
      Font.Style := [fsBold];
    end;

    sumInfo2NodeLabel := TLabel.Create(WizardForm);
    with sumInfo2NodeLabel do begin
      Parent := summaryPage.Surface;
      Left := ScaleX(22);
      Top := 0;
      Width := summaryPage.SurfaceWidth - ScaleX(22);
      Height := ScaleY(16);
    end;

    sumInfo3NodeLabel := TLabel.Create(WizardForm);
    with sumInfo3NodeLabel do begin
      Parent := summaryPage.Surface;
      Left := ScaleX(22);
      Top := sumInfo1NodeLabel.Top + sumInfo1NodeLabel.Height + ScaleY(4);
      Width := summaryPage.SurfaceWidth - ScaleX(22);
      Height := ScaleY(16);
    end;

    sumInfo1IoBrokerLabel := TLabel.Create(WizardForm);
    with sumInfo1IoBrokerLabel do begin
      Parent := summaryPage.Surface;
      Left := ScaleX(8);
      Top := sumInfo3NodeLabel.Top + sumInfo1NodeLabel.Height + ScaleY(12);
      Width := ScaleX(12);
      Height := ScaleY(12);
      Font.Style := [fsBold];
    end;

    sumInfo2IoBrokerLabel := TLabel.Create(WizardForm);
    with sumInfo2IoBrokerLabel do begin
      Parent := summaryPage.Surface;
      Left := ScaleX(22);
      Top := sumInfo3NodeLabel.Top + sumInfo1NodeLabel.Height + ScaleY(12);
      Width := summaryPage.SurfaceWidth - ScaleX(22);
      Height := ScaleY(12);
    end;

    sumInfo1IoBrokerRunLabel := TLabel.Create(WizardForm);
    with sumInfo1IoBrokerRunLabel do begin
      Parent := summaryPage.Surface;
      Left := ScaleX(8);
      Top := sumInfo1IoBrokerLabel.Top + sumInfo1IoBrokerLabel.Height + ScaleY(4);
      Width := ScaleX(12);
      Height := ScaleY(12);
      Font.Style := [fsBold];
    end;

    sumInfo2IoBrokerRunLabel := TLabel.Create(WizardForm);
    with sumInfo2IoBrokerRunLabel do begin
      Parent := summaryPage.Surface;
      Left := ScaleX(22);
      Top := sumInfo1IoBrokerLabel.Top + sumInfo1IoBrokerLabel.Height + ScaleY(4);
      Width := summaryPage.SurfaceWidth - ScaleX(22);
      Height := ScaleY(12);
    end;

    sumInfo1PortStatesLabelA := TLabel.Create(WizardForm);
    with sumInfo1PortStatesLabelA do begin
      Parent := summaryPage.Surface;
      Left := ScaleX(8);
      Top := sumInfo2IoBrokerRunLabel.Top + sumInfo2IoBrokerRunLabel.Height + ScaleY(12);
      Width := ScaleX(12);
      Height := ScaleY(12);
      Font.Style := [fsBold];
    end;

    sumInfo2PortStatesLabelA := TLabel.Create(WizardForm);
    with sumInfo2PortStatesLabelA do begin
      Parent := summaryPage.Surface;
      Left := ScaleX(22);
      Top := sumInfo2IoBrokerRunLabel.Top + sumInfo2IoBrokerRunLabel.Height + ScaleY(12);
      Width := summaryPage.SurfaceWidth - ScaleX(22);
      Height := ScaleY(12);
    end;

    sumInfo1PortObjectsLabelA := TLabel.Create(WizardForm);
    with sumInfo1PortObjectsLabelA do begin
      Parent := summaryPage.Surface;
      Left := ScaleX(8);
      Top := sumInfo1PortStatesLabelA.Top + sumInfo1PortStatesLabelA.Height + ScaleY(4);
      Width := ScaleX(12);
      Height := ScaleY(12);
      Font.Style := [fsBold];
    end;

    sumInfo2PortObjectsLabelA := TLabel.Create(WizardForm);
    with sumInfo2PortObjectsLabelA do begin
      Parent := summaryPage.Surface;
      Left := ScaleX(22);
      Top := sumInfo1PortStatesLabelA.Top + sumInfo1PortStatesLabelA.Height + ScaleY(4);
      Width := summaryPage.SurfaceWidth - ScaleX(22);
      Height := ScaleY(12);
    end;

    sumInfo1PortAdminLabelA := TLabel.Create(WizardForm);
    with sumInfo1PortAdminLabelA do begin
      Parent := summaryPage.Surface;
      Left := ScaleX(8);
      Top := sumInfo1PortObjectsLabelA.Top + sumInfo1PortObjectsLabelA.Height + ScaleY(4);
      Width := ScaleX(12);
      Height := ScaleY(12);
      Font.Style := [fsBold];
    end;

    sumInfo2PortAdminLabelA := TLabel.Create(WizardForm);
    with sumInfo2PortAdminLabelA do begin
      Parent := summaryPage.Surface;
      Left := ScaleX(22);
      Top := sumInfo1PortObjectsLabelA.Top + sumInfo1PortObjectsLabelA.Height + ScaleY(4);
      Width := summaryPage.SurfaceWidth - ScaleX(22);
      Height := ScaleY(12);
    end;

    sumInfo1PortStatesLabelB := TLabel.Create(WizardForm);
    with sumInfo1PortStatesLabelB do begin
      Parent := summaryPage.Surface;
      Left := ScaleX(8);
      Top := sumInfo1PortAdminLabelA.Top + sumInfo1PortAdminLabelA.Height + ScaleY(4);
      Width := ScaleX(12);
      Height := ScaleY(12);
      Font.Style := [fsBold];
    end;

    sumInfo2PortStatesLabelB := TLabel.Create(WizardForm);
    with sumInfo2PortStatesLabelB do begin
      Parent := summaryPage.Surface;
      Left := ScaleX(22);
      Top := sumInfo1PortAdminLabelA.Top + sumInfo1PortAdminLabelA.Height + ScaleY(4);
      Width := summaryPage.SurfaceWidth - ScaleX(22);
      Height := ScaleY(12);
    end;

    sumInfo1PortObjectsLabelB := TLabel.Create(WizardForm);
    with sumInfo1PortObjectsLabelB do begin
      Parent := summaryPage.Surface;
      Left := ScaleX(8);
      Top := sumInfo1PortStatesLabelB.Top + sumInfo1PortStatesLabelB.Height + ScaleY(4);
      Width := ScaleX(12);
      Height := ScaleY(12);
      Font.Style := [fsBold];
    end;

    sumInfo2PortObjectsLabelB := TLabel.Create(WizardForm);
    with sumInfo2PortObjectsLabelB do begin
      Parent := summaryPage.Surface;
      Left := ScaleX(22);
      Top := sumInfo1PortStatesLabelB.Top + sumInfo1PortStatesLabelB.Height + ScaleY(4);
      Width := summaryPage.SurfaceWidth - ScaleX(22);
      Height := ScaleY(12);
    end;

    sumInfo1PortAdminLabelB := TLabel.Create(WizardForm);
    with sumInfo1PortAdminLabelB do begin
      Parent := summaryPage.Surface;
      Left := ScaleX(8);
      Top := sumInfo1PortObjectsLabelB.Top + sumInfo1PortObjectsLabelB.Height + ScaleY(4);
      Width := ScaleX(12);
      Height := ScaleY(12);
      Font.Style := [fsBold];
    end;

    sumInfo2PortAdminLabelB := TLabel.Create(WizardForm);
    with sumInfo2PortAdminLabelB do begin
      Parent := summaryPage.Surface;
      Left := ScaleX(22);
      Top := sumInfo1PortObjectsLabelB.Top + sumInfo1PortObjectsLabelB.Height + ScaleY(4);
      Width := summaryPage.SurfaceWidth - ScaleX(22);
      Height := ScaleY(12);
    end;

    sumSummaryLabel := TLabel.Create(WizardForm);
    with sumSummaryLabel do begin
      Parent := summaryPage.Surface;
      Top := sumInfo1PortAdminLabelB.Top + sumInfo1PortAdminLabelB.Height + ScaleY(10);
      Width := summaryPage.SurfaceWidth - ScaleX(4);
      Height := ScaleY(75);
      AutoSize := False;
      Wordwrap := True;
    end;

    sumRetryButton := TButton.Create(WizardForm);
    with sumRetryButton do begin
      Parent := summaryPage.Surface;
      Top := sumSummaryLabel.Top + sumSummaryLabel.Height + ScaleY(2);
      Width := ScaleX(100);
      Height := ScaleY(30);
      Caption := CustomMessage('CheckAgain');
      OnClick := @retryTestReady;
    end;

    // Controls options page -----------------------------------------------------------------------------------
    optInstallNodeCB := TCheckBox.Create(WizardForm);
    with optInstallNodeCB do begin
      Parent := optionsPage.Surface;
      Left := ScaleX(8);
      Top := 0;
      Width := ScaleX(500);
      Height := ScaleX(16);
      OnClick := @updateNextOptionPage;
    end;

    optInstallIoBrokerCB := TCheckBox.Create(WizardForm);
    with optInstallIoBrokerCB do begin
      Parent := optionsPage.Surface;
      Left := ScaleX(8);
      Top := optInstallNodeCB.Top + optInstallNodeCB.Height + ScaleY(5);
      Width := ScaleX(500);
      Height := ScaleX(16);
      OnClick := @updateNextOptionPage;
    end;

    optFixIoBrokerCB := TCheckBox.Create(WizardForm);
    with optFixIoBrokerCB do begin
      Parent := optionsPage.Surface;
      Left := ScaleX(8);
      Top := optInstallIoBrokerCB.Top + optInstallIoBrokerCB.Height + ScaleY(5);
      Width := ScaleX(500);
      Height := ScaleX(16);
      OnClick := @updateNextOptionPage;
    end;

    optAddFirewallRuleCB := TCheckBox.Create(WizardForm);
    with optAddFirewallRuleCB do begin
      Parent := optionsPage.Surface;
      Left := ScaleX(8);
      Top := optFixIoBrokerCB.Top + optFixIoBrokerCB.Height + ScaleY(5);
      Width := ScaleX(500);
      Height := ScaleX(16);
      OnClick := @updateNextOptionPage;
    end;

    optServiceAutoStartCB := TCheckBox.Create(WizardForm);
    with optServiceAutoStartCB do begin
      Parent := optionsPage.Surface;
      Left := ScaleX(8);
      Top := optAddFirewallRuleCB.Top + optAddFirewallRuleCB.Height + ScaleY(5);
      Width := ScaleX(500);
      Height := ScaleX(16);
      OnClick := @updateNextOptionPage;
    end;

    optDataMigrationCB := TCheckBox.Create(WizardForm);
    with optDataMigrationCB do begin
      Parent := optionsPage.Surface;
      Left := ScaleX(8);
      Top := optServiceAutoStartCB.Top + optServiceAutoStartCB.Height + ScaleY(5);
      Width := ScaleX(500);
      Height := ScaleX(16);
      OnClick := @updateMigrationControls;
      Caption := ' ' + CustomMessage('DataMigrationCB');
    end;

    optDataMigrationButton := TButton.Create(WizardForm);
    with optDataMigrationButton do begin
      Parent := optionsPage.Surface;
      Left := ScaleX(25);
      Top := optDataMigrationCB.Top + optDataMigrationCB.Height + ScaleY(5);
      Width := ScaleX(100);
      Height := ScaleY(30);
      OnClick := @selectMigrationFolder;
      Caption := CustomMessage('DataMigrationButton');
    end;

    optDataMigrationLabel := TLabel.Create(WizardForm);
    with optDataMigrationLabel do begin
      Parent := optionsPage.Surface;
      Left := ScaleX(140);
      Top := optDataMigrationCB.Top + optDataMigrationCB.Height + ScaleY(12);
      Width := ScaleX(500);
      Height := ScaleY(30);
      OnClick := @selectMigrationFolder;
      Caption := 'Test Test Test Test Test';
    end;

    optAdditionalHintsLabel := TLabel.Create(WizardForm);
    with optAdditionalHintsLabel do begin
      Parent := optionsPage.Surface;
      Top := optDataMigrationButton.Top + optDataMigrationButton.Height + ScaleY(5);
      Width := summaryPage.SurfaceWidth - ScaleX(4);
      Height := ScaleY(80);
      AutoSize := False;
      Wordwrap := True;
    end;

    // Controls expert options page ----------------------------------------------------------------------------
    exoIntroLabel := TLabel.Create(WizardForm);
    with exoIntroLabel do begin
      Parent := expertOptionsPage.Surface;
      Top := scaleY(2);
      Width := expertOptionsPage.SurfaceWidth - ScaleX(4);
      Height := ScaleY(80);
      AutoSize := False;
      Wordwrap := True;
      Caption := CustomMessage('ExpertOptionsIntro');
    end;

    exoNewServerRB := TRadioButton.Create(WizardForm);
    with exoNewServerRB do begin
      Parent := expertOptionsPage.Surface;
      Top := exoIntroLabel.Top + exoIntroLabel.Height + ScaleY(1);
      Width := expertOptionsPage.SurfaceWidth - ScaleX(4);
      Height := ScaleX(14);
      Caption := ' ' + CustomMessage('ExpertNewServer');
      Checked := True;
      OnClick := @expertOptionChanged
    end;

    exoNewServerLabel := TLabel.Create(WizardForm);
    with exoNewServerLabel do begin
      Parent := expertOptionsPage.Surface;
      Top := exoNewServerRB.Top + exoNewServerRB.Height + ScaleY(5);
      Left := ScaleX(20);
      Width := expertOptionsPage.SurfaceWidth + ScaleX(20);
      Height := ScaleY(60);
      AutoSize := False;
      Wordwrap := True;
    end;

    exoChangeDirectoryButton := TButton.Create(WizardForm);
    with exoChangeDirectoryButton do begin
      Parent := expertOptionsPage.Surface;
      Left := ScaleX(20);
      Top := exoNewServerLabel.Top + exoNewServerLabel.Height + ScaleY(1);
      Width := ScaleX(250);
      Height := ScaleY(30);
      OnClick := @expertSelectDirectory;
      Caption := CustomMessage('ExpertChangeDirectory');
    end;

    exoMaintainServerRB := TRadioButton.Create(WizardForm);
    with exoMaintainServerRB do begin
      Parent := expertOptionsPage.Surface;
      Top := exoChangeDirectoryButton.Top + exoChangeDirectoryButton.Height + ScaleY(15);
      Width := expertOptionsPage.SurfaceWidth - ScaleX(4);
      Height := ScaleX(14);
      Caption := ' ' + CustomMessage('ExpertMaintainServer');
      OnClick := @expertOptionChanged
      Enabled := False;
    end;

    exoMaintainServerCombo := TComboBox.Create(WizardForm);
    with exoMaintainServerCombo do begin
      Parent := expertOptionsPage.Surface;
      Top := exoMaintainServerRB.Top + exoMaintainServerRB.Height + ScaleY(5);
      Left := ScaleX(20);
      Width := expertOptionsPage.SurfaceWidth - ScaleX(4);
      Height := ScaleY(14);
      Style := csDropDownList;
      Enabled := False;
      Sorted := False;
      Font.Name := 'Courier New';
    end;

    exoUninstallServerRB := TRadioButton.Create(WizardForm);
    with exoUninstallServerRB do begin
      Parent := expertOptionsPage.Surface;
      Top := exoMaintainServerCombo.Top + exoMaintainServerCombo.Height + ScaleY(20);
      Width := expertOptionsPage.SurfaceWidth - ScaleX(4);
      Height := ScaleX(14);
      Caption := ' ' + CustomMessage('ExpertUninstallServer');
      OnClick := @expertOptionChanged
      Enabled := False;
    end;

    exoUninstallServerCombo := TComboBox.Create(WizardForm);
    with exoUninstallServerCombo do begin
      Parent := expertOptionsPage.Surface;
      Top := exoUninstallServerRB.Top + exoUninstallServerRB.Height + ScaleY(5);
      Left := ScaleX(20);
      Width := expertOptionsPage.SurfaceWidth - ScaleX(4);
      Height := ScaleY(14);
      Style := csDropDownList;
      Enabled := False;
      Sorted := False;
      Font.Name := 'Courier New';
    end;


    // Controls expert settings page ---------------------------------------------------------------------------
    exsIntroLabel := TLabel.Create(WizardForm);
    with exsIntroLabel do begin
      Parent := expertSettingsPage.Surface;
      Top := scaleY(2);
      Width := expertSettingsPage.SurfaceWidth - ScaleX(4);
      Height := ScaleY(60);
      AutoSize := False;
      Wordwrap := True;
    end;

    exsServerNameLabel := TLabel.Create(WizardForm);
    with exsServerNameLabel do begin
      Parent := expertSettingsPage.Surface;
      Top := exsIntroLabel.Top + exsIntroLabel.Height + ScaleY(5);
      Width := expertOptionsPage.SurfaceWidth - ScaleX(4);
      Height := ScaleX(14);
      Caption := CustomMessage('ExpertServerName');
    end;

    exsServerNameEdit := TEdit.Create(WizardForm);
    with exsServerNameEdit do begin
      Parent := expertSettingsPage.Surface;
      Top := exsServerNameLabel.Top + exsServerNameLabel.Height + ScaleY(5);
      Width := ScaleX(100);
      Height := ScaleX(14);
      MaxLength := 15
      OnKeyPress := @keyPressServerName;
    end;

    exsStatesPortLabel := TLabel.Create(WizardForm);
    with exsStatesPortLabel do begin
      Parent := expertSettingsPage.Surface;
      Top := exsServerNameEdit.Top + exsServerNameEdit.Height + ScaleY(15);
      Width := expertOptionsPage.SurfaceWidth - ScaleX(4);
      Height := ScaleX(14);
      Caption := CustomMessage('ExpertStatesPort');
    end;

    exsStatesPortEdit := TEdit.Create(WizardForm);
    with exsStatesPortEdit do begin
      Parent := expertSettingsPage.Surface;
      Top := exsStatesPortLabel.Top + exsStatesPortLabel.Height + ScaleY(5);
      Width := ScaleX(100);
      Height := ScaleX(14);
      MaxLength := 5;
      OnKeyPress := @keyPressStatesPort;
    end;

    exsObjectsPortLabel := TLabel.Create(WizardForm);
    with exsObjectsPortLabel do begin
      Parent := expertSettingsPage.Surface;
      Top := exsStatesPortEdit.Top + exsStatesPortEdit.Height + ScaleY(15);
      Width := expertOptionsPage.SurfaceWidth - ScaleX(4);
      Height := ScaleX(14);
      Caption := CustomMessage('ExpertObjectsPort');
    end;

    exsObjectsPortEdit := TEdit.Create(WizardForm);
    with exsObjectsPortEdit do begin
      Parent := expertSettingsPage.Surface;
      Top := exsObjectsPortLabel.Top + exsObjectsPortLabel.Height + ScaleY(5);
      Width := ScaleX(100);
      Height := ScaleX(14);
      MaxLength := 5;
      OnKeyPress := @keyPressObjectsPort;
    end;

    exsAdminPortLabel := TLabel.Create(WizardForm);
    with exsAdminPortLabel do begin
      Parent := expertSettingsPage.Surface;
      Top := exsObjectsPortEdit.Top + exsObjectsPortEdit.Height + ScaleY(15);
      Width := expertOptionsPage.SurfaceWidth - ScaleX(4);
      Height := ScaleX(14);
      Caption := CustomMessage('ExpertAdminPort');
    end;

    exsAdminPortEdit := TEdit.Create(WizardForm);
    with exsAdminPortEdit do begin
      Parent := expertSettingsPage.Surface;
      Top := exsAdminPortLabel.Top + exsAdminPortLabel.Height + ScaleY(5);
      Width := ScaleX(100);
      Height := ScaleX(14);
      MaxLength := 5;
      OnKeyPress := @keyPressAdminPort;
    end;
  end;
end;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 Functions to install/deinstall/change system state
 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function downloadNodeJs: Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := False;
  if optInstallNodeCB.Checked = True then begin
    try
      progressPage.SetProgress(0, 1);
      progressPage.SetText(CustomMessage('DownloadingNodejs'), Format(CustomMessage('DownloadingNodejsVersion'), [rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch]));
      progressPage.Show
      try
        DownloadTemporaryFileAndCopy(rcmdNodeDownloadPath, 'node.msi', '', @OnDownloadProgressNode);
      except
        Log(GetExceptionMessage);
        MsgBox(Format(CustomMessage('DownloadErrorNode'), [rcmdNodeDownloadPath]), mbError, MB_OK);
        Exit;
      end;

      if (FileExists(getTempPath + '\node.msi')) then begin
        Log('Node.js download: Success!');
        Result := True;
      end
      else begin
        Log('Node.js download: No file!');
      end;
    except
      Log(GetExceptionMessage);
    finally
      progressPage.Hide
    end;
  end
  else begin
    Result := True;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function installNodeJs: Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  logText: AnsiString;
begin
  if optInstallNodeCB.Checked then begin
    Result := False;
    try
      marqueePage.SetText(CustomMessage('InstallingNodejs'), Format(CustomMessage('InstallingNodejsVersion'), [rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch]));
      marqueePage.Show
      marqueePage.Animate
      Result := execAndStoreOutput('msiexec /qn /l* ' + getLogNameNodeJsInstall + ' /i ' + getTempPath + '\node.msi', '', '', appInstPath);

      if LoadStringFromFile(getLogNameNodeJsInstall, logText) then begin
        if Pos('Configuration completed successfully', logText) = 0 then begin
          Log('Node.Js installation: Success!');
          Result := True;
        end
        else begin
          Log('Node.Js installation: Success message not found in log file!');
        end;
      end
      else begin
        Log('Node.Js installation: No log file found!');
      end;
      marqueePage.SetText(CustomMessage('InstallingNodejs'), '...');
    except
      Log(GetExceptionMessage);
    finally
      marqueePage.Hide
    end;
  end
  else begin
    Result := True;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure fixPrefixPath(logFileName: String);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  prefixPath: String;
begin
  // In rare cases the node installer does not create the global prefix directory.
  // If this happens, all calls of npx will fail. We create this directory as a workaround
  // if it does not exist yet:
  prefixPath := execAndReturnOutput('"' + nodePath + '\npm" prefix -g', False, '', '');
  Log('npm prefix path: ' + prefixPath);
  if dirExists(prefixPath) then begin
    SaveStringToFile(logFileName,
                     '----------------------------------------------------------------------------------------------------' + chr(13) + chr(10) +
                     'Npm prefix path exists: ' + prefixPath + chr(13) + chr(10) +
                     '----------------------------------------------------------------------------------------------------' + chr(13) + chr(10), True);
  end
  else begin
    SaveStringToFile(logFileName,
                     '----------------------------------------------' + chr(13) + chr(10) +
                     'Npm prefix path does NOT exist: ' + prefixPath + ' Try to create it.' + chr(13) + chr(10), True);

    if ForceDirectories(prefixPath) then begin
      SaveStringToFile(logFileName, 'Success!' + chr(13) + chr(10) +
                       '----------------------------------------------------------------------------------------------------' + chr(13) + chr(10), True);
    end
    else begin
      SaveStringToFile(logFileName, 'Directory could not be created!' + chr(13) + chr(10) +
                       '----------------------------------------------------------------------------------------------------' + chr(13) + chr(10), True);
    end;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function installIoBroker: Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  cmd: String;
  LogName: String;
  info: String;
  output: String;
begin
  result := False;
  cmd := '';
  LogName := ''
  info := '';

  if expertCB.Checked and exoNewServerRB.Checked then begin
    ForceDirectories(appInstPath);
    if (not SaveStringToFile(appInstPath + '\.env', 'iobservicename=' + iobServiceName, false)) then begin
      MsgBox(CustomMessage('ErrorServiceFile'), mbError, MB_OK);
      Exit;
    end;
  end;

  if optInstallIoBrokerCB.Checked then begin
    if iobServiceExists then begin
      // Service exists, but ioBroker not installed. We remove the Service
      stopIobService(iobServiceName, '');
      output := execAndReturnOutput('sc delete ' + iobServiceName + '.exe', False, '', '');
      Log('Delete Service: ' + output);
    end;
    gatherInstNodeData;
    cmd := '"' + nodePath + '\npx" --yes @iobroker/install@latest';
    LogName := getLogNameIoBrokerInstall;
    info := CustomMessage('InstallingIoBroker');
  end
  else begin
    if optFixIoBrokerCB.Checked then begin
      gatherInstNodeData;
      cmd := '"' + nodePath + '\npx" --yes @iobroker/fix@latest';
      LogName := getLogNameIoBrokerFix
      info := CustomMessage('FixingIoBroker');
    end
  end;

  if cmd <> '' then begin
    try
      marqueePage.SetText(info, '');
      marqueePage.Show
      marqueePage.Animate

      fixPrefixPath(LogName);

      // ioBroker.bat makes trouble when calling npx@iobroker..., delete it
      // Don't panic, fix will restore it anyway, and install will install it anyway
      DeleteFile(appInstPath + '\iobroker.bat');
      if execAndStoreOutput(cmd , LogName, nodePath, appInstPath) then begin

        if (FileExists(appInstPath + '\instDone')) then begin
          if expertCB.Checked and exoNewServerRB.Checked and optInstallIoBrokerCB.Checked or optDataMigrationCB.Checked then begin
            Result := reconfigureIoBroker(info, LogName);
            if not Result then begin
              MsgBox(CustomMessage('ReconfigureError'), mbError, MB_OK or MB_SETFOREGROUND);
              Exit;
            end;
          end;
          Log('ioBroker installation/fixing completed!');
          Result := checkIoBrokerRunning(info);
        end
        else begin
          Log('ioBroker installation/fixing did not run til the end!');
        end;
      end
      else begin
        Log('ioBroker installation/fixing was not executed due to unknown error!');
      end;

    except
      Log(GetExceptionMessage);
    finally
      marqueePage.Hide
    end;
  end
  else begin
    Result := True;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function stopIobService(serviceName: String; logFileName: String): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  output: String;
  i: Integer;
  pid: Integer;
begin
  Result := False;
  i := 0;
  pid := 0;

  while i < 15 do begin
    output := execAndReturnOutput('sc stop ' + serviceName + '.exe', True, '', '');
    Log('Stop Service: ' + output);
    if logFileName <> '' then begin
      SaveStringToFile(logFileName,
                       '----------------------------------------------' + chr(13) + chr(10) +
                       'Stop service ' + serviceName + '.exe:' + chr(13) + chr(10) +
                       output + chr(13) + chr(10), True);
    end;
    Sleep(2000);
    if not isIobServiceRunning(serviceName) then begin
      Result := True;
      Exit;
    end;
  end;

  if not Result then begin
    output := execAndReturnOutput('sc queryex ' + serviceName + '.exe | find /i "PID"', True, '', '');
    pid := StrToIntDef(Trim(Copy(output, pos(':', output) + 1, Length(output))), 0);
    if pid = 0 then begin
      Log('No pid found, Service is stopped.');
      Result := True;
    end
    else begin
      Log(Format('Pid %d found.', [pid]));
      output := execAndReturnOutput(Format('taskkill /f /t /pid %d', [pid]), True, '', '');
      Log(Format('taskkill /f /pid %d: ', [pid]) + output);
      SaveStringToFile(logFileName,
                       '----------------------------------------------' + chr(13) + chr(10) +
                       'Killed task of service ' + serviceName + '.exe:' + chr(13) + chr(10) +
                       output + chr(13) + chr(10), True);
      Result := True;
    end;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure retryTestReady(sender: TObject);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  if tryStopServiceAtNextRetry then begin
    marqueePage.Animate;
    marqueePage.SetText('', CustomMessage('TryStopIoB'));
    marqueePage.Show;
    stopIobService(iobServiceName, '');
    marqueePage.Hide;
  end;

  updateSummaryPage;

  WizardForm.NextButton.Enabled := readyToInstall;
  WizardForm.Update;

end;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 Inno Setup Event Functions
 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure DeinitializeSetup;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  fileNameToDelete: String;
  batchConent: String;
  batchFileName: String;
  resultCode: Integer;
begin
  if (Length(iobHomePath) > 3) and (Length(getTempPathName) > 5) then begin
    DelTree(getTempPath, True, True, True);
    if isDirectoryEmpty(iobHomePath) then begin
      DelTree(iobHomePath, True, False, False);
    end;
  end;

  if not updatedInstallerStarted then begin
    if RegKeyExists(HKEY_LOCAL_MACHINE, registryPendingDeleteKey ) then begin
      if RegQueryStringValue(HKEY_LOCAL_MACHINE, registryPendingDeleteKey, 'Executable', fileNameToDelete) then begin
        if Length(fileNameToDelete) > 5 then begin
          Log('Deleting file ' + fileNameToDelete);
          // We have to trick here to ensure that the temporary file is really deleted because it is locked by the current process:
          batchConent := ':try_delete' + #13 + #10 +
                'del "' + fileNameToDelete + '"' + #13 + #10 +
                'if exist "' + fileNameToDelete + '" goto try_delete' + #13 + #10 +
                'del %0';

          batchFileName := ExtractFilePath(ExpandConstant('{tmp}')) + 'removeTmpInstaller.bat';
          SaveStringToFile(batchFileName, batchConent, False);
          Exec(batchFileName, '', '', SW_HIDE, ewNoWait, resultCode);
          RegDeleteKeyIncludingSubkeys(HKEY_LOCAL_MACHINE, registryPendingDeleteKey);
        end;
      end;
    end;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function InitializeSetup: Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  infoForm: TSetupForm;
  infoLabel: TLabel;
  jsonParser: TJsonParser;
  jsonString: AnsiString;
  resultCode: Integer;
  fileName: String;
  downloadPath: String;
  downloadSize: Integer;
  tmpExecFinalPath: String;
  tmpExecTmpName: String;
  tmpExecTmpPath: String;
  onlineVersionStr: String;
  installedVersionStr: String;
  onlineMajor: Integer;
  onlineMinor: Integer;
  onlinePatch: Integer;
  installedMajor: Integer;
  installedMinor: Integer;
  installedPatch: Integer;
begin
  Result := True;
  updatedInstallerStarted := False;

  registryPendingDeleteKey := 'Software\ioBroker\pendingDelete';

  if not RegKeyExists(HKEY_LOCAL_MACHINE, registryPendingDeleteKey ) then begin
    // Check for installer update:
    // If any error occurs we go on silently, because there is no need to bother the user with info about a failed update check.
    try
      infoForm := CreateCustomForm;
      with infoForm do begin
        ClientWidth := ScaleX(250);
        ClientHeight := ScaleY(100);
        Caption := 'ioBroker - Automate your life';
        Position := poMainFormCenter;
        Color := clWhite;
      end;
      infoLabel := TLabel.Create(infoForm);
      with infoLabel do begin
        Top := ScaleY(40);
        Left := ScaleX(10);
        Height := ScaleY(20);
        Width := ScaleX(230);
        Anchors := [akLeft, akTop, akRight];
        Caption := CustomMessage('CheckingForUpdates');
        Alignment := taCenter;
        Parent := infoForm;
      end;
      infoForm.Show
      infoLabel.Refresh

      fileName := '~package.json';
      DownloadTemporaryFile(ExpandConstant('{#URL_IOB_BUILD_PACKAGE_JSON}'), fileName, '', @OnDownloadProgress);

      if FileExists(ExpandConstant('{tmp}') + '\' + fileName) then begin
        Log(ExpandConstant('{tmp}') + '\' + fileName + ' download: Success!');
        LoadStringFromFile(ExpandConstant('{tmp}') + '\' + fileName, jsonString);
        ClearJsonParser(jsonParser);
        ParseJson(JsonParser, jsonString);
        if Length(jsonParser.Output.Objects) > 0 then begin

          if FindJsonStrValue(jsonParser.Output, JsonParser.Output.Objects[0], 'version', onlineVersionStr) then begin
            installedVersionStr := '{#SetupSetting("AppVersion")}';
            Log('Update check: Found Online Installer version: ' + onlineVersionStr);
            Log('Update check: Installed Installer version: ' + installedVersionStr);

            if convertVersion(onlineVersionStr, onlineMajor, onlineMinor, onlinePatch) and
               convertVersion(installedVersionStr, installedMajor, installedMinor, installedPatch) then begin

              if (onlineMajor > installedMajor) or
                 ((onlineMajor = installedMajor) and (onlineMinor > installedMinor)) or
                 ((onlineMajor = installedMajor) and (onlineMinor = installedMinor) and (onlinePatch > installedPatch))then begin

                downloadPath := Format(ExpandConstant('{#URL_INSTALLER_DOWNLOAD}'), [onlineVersionStr]);
                infoForm.Hide

                try
                  downloadSize := DownloadTemporaryFileSize(downloadPath);
                except
                  downloadSize := 0;
                end;

                if(downloadSize > 0) then begin
                  // New Installer detected!
                  if MsgBox(Format(CustomMessage('DownloadInstallerAndInstall'), [onlineVersionStr,installedVersionStr]), mbConfirmation, mb_YesNo or MB_SETFOREGROUND) = IDYES then begin
                    try
                      infoLabel.Caption := Format(CustomMessage('DownloadingInstaller'), [onlineVersionStr]);;
                      infoForm.Show
                      infoLabel.Refresh

                      tmpExecTmpName := '~iobInst.exe';
                      tmpExecTmpPath := ExpandConstant('{tmp}') + '\' + tmpExecTmpName;
                      DownloadTemporaryFile(downloadPath, tmpExecTmpName, '', @OnDownloadProgress);
                      infoForm.Hide

                      if FileExists(tmpExecTmpPath) then begin
                        tmpExecFinalPath := ExpandConstant('{%TEMP}') + '\~iobInst' + installedVersionStr + '#' + onlineVersionStr + '.exe';

                        //
                        if (FileCopy(tmpExecTmpPath, tmpExecFinalPath, False)) and (FileExists(tmpExecFinalPath)) then begin
                          Log('Update check: Temporary Installer file at ' + tmpExecFinalPath);

                          MsgBox(Format(CustomMessage('StartInstaller'), [onlineVersionStr]), mbConfirmation, mb_OK or MB_SETFOREGROUND);
                          if Exec(tmpExecFinalPath, '', '', SW_SHOW, ewNoWait, resultCode) then begin
                            RegWriteStringValue(HKEY_LOCAL_MACHINE, registryPendingDeleteKey, 'Executable',  tmpExecFinalPath);
                            updatedInstallerStarted := True;
                            // Stop this instance of the installer, the new instance has already been started
                            Result := False;
                          end
                          else begin
                            // Exec failed
                            MsgBox(Format(CustomMessage('InstallerUpdateFailed'), [1]), mbConfirmation, mb_OK or MB_SETFOREGROUND);
                          end
                        end
                        else begin
                          // Copy Download File failed
                          MsgBox(Format(CustomMessage('InstallerUpdateFailed'), [2]), mbConfirmation, mb_OK or MB_SETFOREGROUND);
                        end;
                      end
                      else begin
                        // Download failed
                        MsgBox(Format(CustomMessage('InstallerUpdateFailed'), [3]), mbConfirmation, mb_OK or MB_SETFOREGROUND);
                      end;
                    except
                      // Download/Copy failed
                      MsgBox(Format(CustomMessage('InstallerUpdateFailed'), [4]), mbConfirmation, mb_OK or MB_SETFOREGROUND);
                    end;
                  end;
                end
                else begin
                  Log('Update check failed: New version found, but no download file found!');
                end;
              end;
            end
            else begin
              Log('Update check failed: Error in versions!');
            end;
          end;
        end;
      end
      else begin
        Log('Update check failed: ' + ExpandConstant('{tmp}') + '\' + fileName + ' download: No file!');
      end;
    except
      Log('Update check failed: Exception occurred!');
    finally
      infoForm.Free
    end;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function NextButtonClick(CurPageID: Integer): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := True;

  if CurPageID = wpSelectDir then begin

    if checkForStabilostickInstallation(ExpandConstant('{app}')) then begin
      MsgBox(CustomMessage('FolderStabilostick'), mbError, MB_OK or MB_SETFOREGROUND);
      Result := False;
      Exit;
    end;

    if Pos('&', ExpandConstant('{app}')) > 0 then begin
      MsgBox(Format(CustomMessage('FolderInvalidCharacter'),['&']), mbError, MB_OK or MB_SETFOREGROUND);
      Result := False;
      Exit;
    end;

    iobHomePath := ExpandConstant('{app}');
    appInstPath := iobHomePath;

    if iobExpertPath = '' then begin
      iobExpertPath := iobHomePath;
    end;
  end;

  // Actions for both, expert and not expert:
  if (summaryPage <> nil) and (CurPageID = summaryPage.ID) then begin
    updateOptionsPage;
  end;

  if not expertCB.Checked then begin
    // Only not expert:
    if (CurPageID = wpSelectDir) or
       ((CurPageID = wpWelcome) and not isFirstInstallerRun)
    then begin
      iobServiceName := 'ioBroker';
      iobServiceExists := False;
      updateSummaryPage;
    end;
  end
  else begin
    // Only expert:
    // Ensure that Node path of existing node installation is set correctly:
    gatherInstNodeData;

    if (CurPageID = wpSelectDir) or
       ((CurPageID = wpWelcome) and not isFirstInstallerRun)
    then begin
      updateExpertOptionsPage;
    end;
    if CurPageID = expertOptionsPage.ID then begin
      if exoNewServerRB.Checked then begin
        updateExpertSettingsPage;
      end
      else begin
        if exoMaintainServerRB.Checked then begin
          appInstPath := Copy(exoMaintainServerCombo.Text, pos('|', exoMaintainServerCombo.Text) + 2, Length(exoMaintainServerCombo.Text));
          updateSummaryPage;
        end;
        if exoUninstallServerRB.Checked then begin
          appInstPath := Copy(exoUninstallServerCombo.Text, pos('|', exoUninstallServerCombo.Text) + 2, Length(exoUninstallServerCombo.Text));
          iobServerName := Trim(Copy(exoUninstallServerCombo.Text, 1, pos('|', exoUninstallServerCombo.Text) - 1));
          try
            marqueePage.SetText(CustomMessage('GatherInformation'), 'ioBroker');
            marqueePage.Show
            marqueePage.Animate
            iobInstalled := gatherIoBrokerInfo;
          finally
            marqueePage.Hide
          end;
          // We continue also if no ioBroker was found to cleanup old fragments of an installation
        end;
      end;
    end;
    if CurPageID = expertSettingsPage.ID then begin
      Result := checkAndSetExpertSettings;
      if Result then begin
        updateSummaryPage;
      end;
    end;
  end;
 end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure CurPageChanged(CurPageID: Integer);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  if (summaryPage <> nil) and (CurPageId = summaryPage.id) then begin
    Wizardform.NextButton.Enabled := readyToInstall;
  end;

  expertCB.Enabled := (CurPageId = wpWelcome) and (expertCB.Checked and not expertInstallationExists or not expertCB.Checked);
  if (CurPageId <> wpWelcome) then begin
    expertCB.Visible :=  expertCB.Checked;
  end;

  if CurPageID = wpReady then begin
    if expertCB.Checked and exoUninstallServerRB.Checked then begin
      WizardForm.NextButton.Caption := CustomMessage('Uninstall');
      WizardForm.PageNameLabel.Caption := CustomMessage('ReadyUninstallTitle');;
      WizardForm.PageDescriptionLabel.Caption := CustomMessage('ReadyUninstallSubTitle');;
      WizardForm.ReadyLabel.Caption := CustomMessage('ReadyUninstall');
    end
    else begin
      if not optInstallIoBrokerCB.checked then begin
        WizardForm.NextButton.Caption := CustomMessage('Update');
        WizardForm.PageNameLabel.Caption := CustomMessage('ReadyMaintainTitle');;
        WizardForm.PageDescriptionLabel.Caption := CustomMessage('ReadyMaintainSubTitle');
        WizardForm.ReadyLabel.Caption := CustomMessage('ReadyMaintain');
      end
      else begin
        WizardForm.PageDescriptionLabel.Caption := CustomMessage('ReadyInstallSubTitle');
        WizardForm.ReadyLabel.Caption := CustomMessage('ReadyInstall');
      end;
    end;
  end;

  if CurPageID = wpFinished then begin
    WizardForm.FinishedLabel.Caption := CustomMessage('FinishedMessage');
  end;

  if (CurPageID = wpPreparing) or (CurPageID = wpInstalling) then begin
    WizardForm.PageNameLabel.Caption := 'ioBroker - Automate your life';
    WizardForm.PageDescriptionLabel.Caption := '';
  end;

end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure CurStepChanged(CurStep: TSetupStep);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  output: String;
  cont: Boolean;
  resultCode: Integer;
begin
  if CurStep = ssInstall then begin
    if expertCB.Checked and exoUninstallServerRB.Checked then begin
      Log('Directory to delete: ' + appInstPath);
      Log('Registry Key to delete: ' + expertRegServersRoot + iobServerName);
      Log('Service to delete: ' + iobServiceName);

      // Delete Files
      try
        marqueePage.SetText(CustomMessage('Uninstall'), Format(CustomMessage('DeleteService'), [iobServiceName]));
        marqueePage.Show
        marqueePage.Animate

        // Stop and remove the service
        stopIobService(iobServiceName, '');

        if nodepath = '' then gatherInstNodeData;

        output := execAndReturnOutput('"' + nodePath + '\node.exe" "' + appInstPath + '\uninstall.js"', True, nodepath, appInstPath);
        Log('Delete Service: ' + output);

        // Delete Registry entry
        if iobServerName <> '' then begin
          RegDeleteKeyIncludingSubkeys(HKEY_LOCAL_MACHINE, expertRegServersRoot + iobServerName);
        end;

        if UserDefAdminPort then begin
          DeleteFile(expandConstant('{group}') + '\[' + getIobServiceName('') + '] ioBroker Admin.url');
          DeleteFile(expandConstant('{group}') + '\[' + getIobServiceName('') + '] ioBroker Admin.lnk');
        end;

        marqueePage.SetText(CustomMessage('Uninstall'), Format(CustomMessage('Deleting'), ['']));
        DelTree(appInstPath + '\*.js', False, True, False);
        DelTree(appInstPath + '\*.md', False, True, False);
        DelTree(appInstPath + '\*.cmd', False, True, False);
        DelTree(appInstPath + '\*.bat', False, True, False);
        DelTree(appInstPath + '\*.json', False, True, False);
        DelTree(appInstPath + '\*.ps1', False, True, False);
        DelTree(appInstPath + '\*.sh', False, True, False);
        DeleteFile(appInstPath + '\LICENSE');
        DeleteFile(appInstPath + '\.env');
        DeleteFile(appInstPath + '\instDone');
        marqueePage.SetText(CustomMessage('Uninstall'), Format(CustomMessage('Deleting'), [appInstPath + '\daemon']));
        DelTree(appInstPath + '\daemon', True, True, True);
        marqueePage.SetText(CustomMessage('Uninstall'), Format(CustomMessage('Deleting'), [appInstPath + '\node_modules']));
        DelTree(appInstPath + '\node_modules', True, True, True);
        marqueePage.SetText(CustomMessage('Uninstall'), Format(CustomMessage('Deleting'), [appInstPath + '\install']));
        DelTree(appInstPath + '\install', True, True, True);
        marqueePage.SetText(CustomMessage('Uninstall'), Format(CustomMessage('Deleting'), [appInstPath + '\log']));
        DelTree(appInstPath + '\log', True, True, True);
        marqueePage.SetText(CustomMessage('Uninstall'), Format(CustomMessage('Deleting'), [appInstPath + '\semver']));
        DelTree(appInstPath + '\semver', True, True, True);
        marqueePage.SetText(CustomMessage('Uninstall'), Format(CustomMessage('Deleting'), [appInstPath + '\iobroker-data_old']));
        DelTree(appInstPath + '\iobroker-data_old', True, True, True);
        marqueePage.SetText(CustomMessage('Uninstall'), Format(CustomMessage('Deleting'), [appInstPath + '\iobroker-data_backup']));
        DelTree(appInstPath + '\iobroker-data_backup', True, True, True);
        RenameFile(appInstPath + '\iobroker-data', appInstPath + '\iobroker-data_backup');

        installationSuccessful := True;
      finally
        marqueePage.Hide
      end;
    end
    else begin
      if optDataMigrationCB.Checked then begin
        MsgBox(CustomMessage('MigrationHints'), mbInformation, MB_OK or MB_SETFOREGROUND);
      end;
      // Be sure that the path for the log files exists
      ForceDirectories(appInstPath + '\log');

      // Remove old log files and old semaphore file
      DeleteFile(getLogNameNodeJsInstall + '_old');
      DeleteFile(getLogNameIoBrokerInstall + '_old');
      DeleteFile(getLogNameIoBrokerFix + '_old');
      RenameFile(getLogNameNodeJsInstall, getLogNameNodeJsInstall + '_old');
      RenameFile(getLogNameIoBrokerInstall, getLogNameIoBrokerInstall + '_old');
      RenameFile(getLogNameIoBrokerFix, getLogNameIoBrokerFix + '_old');
      DeleteFile(appInstPath + '\instDone');

      cont := True;

      // Download Node.js
      if cont then begin
        if downloadNodeJs = False then begin
          // Download failed
          MsgBox(CustomMessage('DownloadFailedNoNodeJs'), mbError, MB_OK or MB_SETFOREGROUND);
          cont := False;
        end;
      end;

      if cont then begin
        if installNodeJs = False then begin
          MsgBox(CustomMessage('InstallationFailedNoNodeJs'), mbError, MB_OK or MB_SETFOREGROUND);
          Exec('notepad', getLogNameNodeJsInstall, '', SW_SHOWNORMAL, ewNoWait, resultCode);
          cont := False;
        end;
      end;

      if cont then begin
        if installIoBroker = False then begin
          if optInstallIoBrokerCB.Checked then begin
            MsgBox(CustomMessage('InstallationFailedIoBroker'), mbError, MB_OK or MB_SETFOREGROUND);
            Exec('notepad', getLogNameIoBrokerInstall, '', SW_SHOWNORMAL, ewNoWait, resultCode);
          end
          else begin
            MsgBox(CustomMessage('InstallationFailedIoBrokerFix'), mbError, MB_OK or MB_SETFOREGROUND);
            Exec('notepad', getLogNameIoBrokerFix, '', SW_SHOWNORMAL, ewNoWait, resultCode);
          end;
          cont := False;
        end;
      end;

      if cont then begin
        output := execAndReturnOutput(ExpandConstant('{sys}') + '\netsh advfirewall firewall delete rule name="Node for ioBroker (inbound)"', True, '', '');
        Log('Remove firewall inbound:' + output);
        output := execAndReturnOutput(ExpandConstant('{sys}') + '\netsh advfirewall firewall delete rule name="Node for ioBroker (outbound)"', True, '', '');
        Log('Remove firewall outbound:' + output);
        if optAddFirewallRuleCB.Checked then begin
          output := execAndReturnOutput(ExpandConstant('{sys}') + '\netsh advfirewall firewall add rule name="Node for ioBroker (inbound)" dir=in action=allow program="' + nodePath + '\node.exe" enable=yes', True, '', '');
          Log('Modify firewall inbound:' + output);
          output := execAndReturnOutput(ExpandConstant('{sys}') + '\netsh advfirewall firewall add rule name="Node for ioBroker (outbound)" dir=out action=allow program="' + nodePath + '\node.exe" enable=yes', True, '', '');
          Log('Modify firewall outbound:' + output);
        end;

        if not optServiceAutoStartCB.Checked then begin
          output := execAndReturnOutput('sc config ' + iobServiceName + '.exe start=demand', False, '', '');
          Log('Config service demand: ' + output);
        end
        else begin
          output := execAndReturnOutput('sc config ' + iobServiceName + '.exe start=auto', False, '', '');
          Log('Config service auto: ' + output);
        end;

        if ioBrokerNeedsStart then begin
          try
            marqueePage.SetText(CustomMessage('StartIoBroker'), '');
            marqueePage.Show
            marqueePage.Animate

            // In this case ioBroker was not started automatically, restart ioBroker
            // After installation and fix the service is started anyway
            output := execAndReturnOutput('sc start ' + iobServiceName + '.exe', False, '', '');
            Log('Start ioBroker service:' + output);
            cont := checkIoBrokerRunning(CustomMessage('StartIoBroker'));
          except
            cont := False;
          finally
            marqueePage.Hide
          end;
        end;
      end;

      if cont then begin
        installationSuccessful := True;
      end;
    end;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  if expertCB.Checked and exoUninstallServerRB.Checked then begin
    Result := 'ioBroker:';
    Result := Result + NewLine + Space + CustomMessage('SummaryUnInstallIoBroker1');
    Result := Result + NewLine + NewLine + Space + Space + Format(CustomMessage('SummaryUnInstallIoBroker2'), [appInstPath]);
    Result := Result + NewLine + Space + Space + Format(CustomMessage('SummaryUnInstallIoBroker3'), [iobServiceName]);
  end
  else begin
    Result := Result + 'Node.js:'
    if optInstallNodeCB.checked then begin
      if instNodeVersionMajor = 0 then begin
        Result := Result + NewLine + Space + Format(CustomMessage('SummaryInstallNodeJS'), [rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch]);
      end
      else begin
        Result := Result + NewLine + Space + Format(CustomMessage('SummaryUpdateNodeJS'), [instNodeVersionMajor, instNodeVersionMinor, instNodeVersionPatch, rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch]);
      end
    end
    else begin
      Result := Result + NewLine + Space + Format(CustomMessage('SummaryKeepNodeJS'), [instNodeVersionMajor, instNodeVersionMinor, instNodeVersionPatch]);
    end;

    if iobServiceExists then begin
      if iobInstalled = False then begin
        if optInstallIoBrokerCB.checked then begin
          Result := Result + NewLine + NewLine + 'ioBroker Service:';
          Result := Result + NewLine + Space + Format(CustomMessage('SummaryIoBrokerServiceRemove'), [appInstPath]);
        end
      end
    end;

    Result := Result + NewLine + NewLine + CustomMessage('SummaryFirewall');

    if optAddFirewallRuleCB.checked then begin
      if firewallRuleSet then begin
        Result := Result + NewLine + Space + Format(CustomMessage('SummaryChangeFirewallKeep'), [appInstPath]);
      end
      else begin
        Result := Result + NewLine + Space + Format(CustomMessage('SummaryChangeFirewall'), [appInstPath]);
      end
    end
    else begin
      if firewallRuleSet then begin
        Result := Result + NewLine + Space + Format(CustomMessage('SummaryFirewallRemove'), [appInstPath]);
      end
      else begin
        Result := Result + NewLine + Space + Format(CustomMessage('SummaryNoFirewallKeep'), [appInstPath]);
      end
    end;

    Result := Result + NewLine + NewLine + 'ioBroker:';

    if optInstallIoBrokerCB.checked then begin
      Result := Result + NewLine + Space + Format(CustomMessage('SummaryInstallIoBroker'), [appInstPath]);
      Result := Result + NewLine + Space + Format(CustomMessage('SummaryIoBrokerServiceCreateDyn'), [iobServiceName]);
    end
    else begin
      if iobversionMajor > 0 then begin
        Result := Result + NewLine + Space + Format(CustomMessage('SummaryKeepIoBroker'), [iobVersionMajor, iobVersionMinor, iobVersionPatch, appInstPath]);
      end
      else begin
        Result := Result + NewLine + Space + Format(CustomMessage('SummaryKeepIoBrokerProbably'), [appInstPath]);
      end
    end;

    if not expertCB.Checked or not exoUninstallServerRB.Checked then begin
      if optServiceAutoStartCB.Checked <> isIobServiceAutoStartReg(iobServiceName) then begin
        if optServiceAutoStartCB.Checked then begin
          Result := Result + NewLine + Space + Format(CustomMessage('SummaryChangeServiceToAuto'), [iobServiceName]);
        end
        else begin
          Result := Result + NewLine + Space + Format(CustomMessage('SummaryChangeServiceToMan'), [iobServiceName]);
        end;
      end
      else begin
        if optServiceAutoStartCB.Checked then begin
          Result := Result + NewLine + Space + Format(CustomMessage('SummaryKeepServiceToAuto'), [iobServiceName]);
        end
        else begin
          Result := Result + NewLine + Space + Format(CustomMessage('SummaryKeepServiceToMan'), [iobServiceName]);
        end;
      end;
    end;

    if optFixIoBrokerCB.checked then begin
      Result := Result + NewLine + Space + CustomMessage('SummaryExecuteFixer');
    end;

    Result := Result + NewLine + Space + CustomMessage('SummaryStartioBroker') + ' ' + Format(CustomMessage('Service'), [iobServiceName]);

    if expertCB.Checked and exoNewServerRB.Checked and optInstallIoBrokerCB.Checked or optDataMigrationCB.Checked then begin
      Result := Result + NewLine + Space + CustomMessage('SummaryShutdownBroker') + ' ' + Format(CustomMessage('Service'), [iobServiceName]);
      if optDataMigrationCB.Checked then begin
        Result := Result + NewLine + Space + Format(CustomMessage('CopyMigrationDataFrom'), [optDataMigrationLabel.Caption]);
      end;
      if iobServerName <> '' then begin
        Result := Result + NewLine + Space + Format(CustomMessage('SummaryNewServerName'), [iobServername]);
      end
      else begin
        Result := Result + NewLine + Space + Format(CustomMessage('SummaryNewServerName'), [GetEnv('USERDOMAIN')]);
      end;
      Result := Result + NewLine + Space + Format(CustomMessage('SummaryNewStatesObjectsPort'), [iobStatesPort, iobObjectsPort]);
      Result := Result + NewLine + Space + Format(CustomMessage('SummaryNewAdminPort'), [iobAdminPort]);
      Result := Result + NewLine + Space + CustomMessage('SummaryStartioBroker') + ' ' + Format(CustomMessage('Service'), [iobServiceName]);
    end;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function ShouldSkipPage(PageID: Integer): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := False;
  if not isFirstInstallerRun then begin
    if (PageID = wpLicense) or
       (PageID = wpSelectDir) then begin
      Result := True;
    end;
  end;

  if (PageID = wpPassword) or
     (PageID = wpInfoBefore) or
     (PageID = wpUserInfo) or
     (PageID = wpSelectComponents) or
     (PageID = wpSelectProgramGroup) or
     (PageID = wpSelectTasks) or
     (PageID = wpPreparing) or
     (PageID = wpInstalling)
  then begin
    Result := True;
  end;

  if not expertCB.Checked then begin
    if (PageID = expertOptionsPage.ID) or
       (PageID = expertSettingsPage.ID)
    then begin
      Result := True;
    end;
  end
  else begin
    if exoUninstallServerRB.Checked then begin
      if (PageID = summaryPage.ID) or
         (PageID = optionsPage.ID) or
         (PageID = expertSettingsPage.ID)
      then begin
        Result := True;
      end;
    end;
    if exoMaintainServerRB.Checked then begin
      if PageID = expertSettingsPage.ID
      then begin
        Result := True;
      end;
    end;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure InitializeWizard;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  appId: String;
  appRegKey: String;
  licTxt: String;
  regServerNames: TArrayOfString;
begin
  expertRegServersRoot := 'Software\ioBroker\Installer\Servers\';

  // Display own welcome page text
  WizardForm.WelcomeLabel2.height := WizardForm.height;
  WizardForm.WelcomeLabel2.Caption := CustomMessage('Intro');
  WizardForm.WizardBitmapImage.OnDblClick := @showExpertMode;

  // Expert Mode checkbox
  expertCB := TNewCheckBox.Create(WizardForm);
  expertCB.Parent := WizardForm;
  expertCB.Top := WizardForm.Height;
  expertCB.Left := ScaleX(25);
  expertCB.Width := ScaleX(200);
  expertCB.Caption := ' ' + CustomMessage('ExpertMode');
  expertCB.OnClick := @expertModeCBClicked;

  if RegGetSubkeyNames(HKEY_LOCAL_MACHINE, expertRegServersRoot, regServerNames) then begin
    if GetArrayLength(regServerNames) > 0 then begin
      expertCB.Checked := True;
    end;
  end;

  if not expertCB.Checked then begin
    expertCB.Visible := False;
  end;

  // Adapt Copyright date in license
  licTxt := WizardForm.LicenseMemo.Text;
  StringChangeEx(licTxt, '<now>', GetDateTimeString('yyyy', #0, #0), True);
  WizardForm.LicenseMemo.Text := licTxt;
  WizardForm.LicenseMemo.Font.Name := 'Courier New';

  // Initialize variables depending on expertMode
  expertModeCBClicked(nil);

  // Check if ioBroker was already installed with this installer
  appId := '{#SetupSetting("AppId")}';
  appId := Copy(appId, 2, Length(appId) - 1);

  appRegKey := 'Software\Microsoft\Windows\CurrentVersion\Uninstall\' + appId + '_is1';
  log(appRegKey);

  if RegKeyExists(HKEY_LOCAL_MACHINE, appRegKey ) then begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE, appRegKey, 'Inno Setup: App Path', appInstPath);
    isFirstInstallerRun := False;
    Log('ioBroker already installed in ' + appInstPath);
    iobHomePath := appInstPath;
  end
  else begin
    isFirstInstallerRun := True;
  end;

  // Will set iobHomePath if found in registry, otherwise it will stay empty
  RegQueryStringValue(HKEY_LOCAL_MACHINE, expertRegServersRoot, 'RootPath', iobExpertPath);
  if iobExpertPath = '' then begin
    iobExpertPath := iobHomePath;
  end;

  createPages;

  progressPage := CreateOutputProgressPage('ioBroker - Automate your life', '');
  marqueePage := CreateOutputMarqueeProgressPage('ioBroker - Automate your life', '');
end;


{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function PrepareToInstall(var NeedsRestart: Boolean): String;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  regServerNames: TArrayOfString;
  serviceName: String;
  i: Integer;
  msg: String;
begin
  Result := '';
  if expertCB.Checked and exoUninstallServerRB.Checked then begin
    if MsgBox(Format(CustomMessage('ReallyDeleteAndUninstall'), [appInstPath]), mbError, mb_YesNo or MB_SETFOREGROUND) = IDNO then begin
      Result := CustomMessage('UninstallationCancelled') ;
    end;
  end
  else begin
    if optInstallNodeCB.Checked then begin
      // Check if installations in expert mode are running
      msg := '';

      // First check the default service of a non expert installation:
      serviceName := getIoBrokerServiceNameFromEnv(iobHomePath);
      if isIobServiceRunning(serviceName) then begin
        msg := msg + chr(13) + chr(10) + ' - ' + serviceName;
      end;

      if RegGetSubkeyNames(HKEY_LOCAL_MACHINE, expertRegServersRoot, regServerNames) then begin
        for i := 0 to GetArrayLength(regServerNames)-1 do begin
          if RegQueryStringValue(HKEY_LOCAL_MACHINE, expertRegServersRoot + regServerNames[i], 'ServiceName', serviceName) then begin
            if isIobServiceRunning(serviceName) then begin
              msg := msg + chr(13) + chr(10) + ' - ' + serviceName;
            end;
          end;
        end;
        if msg <> '' then begin
          msg :=  chr(13) + chr(10) + msg + chr(13) + chr(10) + chr(13) + chr(10);
          if MsgBox(Format(CustomMessage('NodeInstallationRunningioBrokerExist'), [msg, chr(13) + chr(10)]), mbError, mb_YESNO or MB_SETFOREGROUND) = IDYES then begin
            for i := 0 to GetArrayLength(regServerNames)-1 do begin
              if RegQueryStringValue(HKEY_LOCAL_MACHINE, expertRegServersRoot + regServerNames[i], 'ServiceName', serviceName) then begin
                if isIobServiceRunning(serviceName) then begin
                  stopIobService(serviceName, '');
                end;
              end;
            end;
          end
          else begin
            Result := CustomMessage('NodeInstallationAborted');
          end;
        end;
      end;
    end;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function InitializeUninstall(): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  regServerNames: TArrayOfString;
  i: Integer;
  msg: String;
begin
  expertRegServersRoot := 'Software\ioBroker\Installer\Servers\';
  Result := True;
  msg := '';
  if RegGetSubkeyNames(HKEY_LOCAL_MACHINE, expertRegServersRoot, regServerNames) then begin
    for i := 0 to GetArrayLength(regServerNames)-1 do begin
      msg := msg + chr(13) + chr(10) + ' - ' + regServerNames[i];
    end;
    if i > 0 then begin
      msg :=  chr(13) + chr(10) + msg + chr(13) + chr(10) + chr(13) + chr(10);
      // Inno Setup does not support CustomMessage for uninstallation!?
      // Implemented only German and english
      if activeLanguage = 'german' then begin
        MsgBox(Format('ioBroker kann nicht auf diese Weise deinstalliert werden, da im Expertenmodus folgende ioBroker Server installiert wurden:%sBitte starte den Installer und verwende den Expertenmodus, um ioBroker Server Installationen zu deinstallieren.', [msg]), mbError, mb_Ok or MB_SETFOREGROUND);
      end
      else begin
        MsgBox(Format('ioBroker cannot be uninstalled in this way because the following ioBroker servers were installed in expert mode:%sPlease start the installer and use expert mode to uninstall ioBroker server installations.', [msg]), mbError, mb_Ok or MB_SETFOREGROUND);
      end;
      Result := False;
      Exit;
    end;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure DeinitializeUninstall;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  iobDataDirName: String;
begin
  iobDataDirName := ExpandConstant('{app}') + '\iobroker-data';
  DelTree(iobDataDirName + '_backup', True, True, True);
  RenameFile(iobDataDirName, iobDataDirName + '_backup');
end;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 Expert Mode and reconfiguration functions
 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure expertModeCBClicked(sender: TObject);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  if expertCB.Checked then begin
    // Will be set later in dialog
    appInstPath := '';
    iobStatesPort := 0;
    iobObjectsPort := 0;
    iobAdminPort := 0;
    iobTargetServiceName := '';
    iobServerName := '';
    expertCB.Enabled := not expertInstallationExists;
    if expertCB.Enabled then begin
      WizardForm.WelcomeLabel2.Caption := CustomMessage('ExpertIntro');
    end
    else begin
      WizardForm.WelcomeLabel2.Caption := CustomMessage('ExpertIntro') + CustomMessage('StandardModeNotAllowed');
    end;
  end
  else begin
    // Normal mode, i.e. appInstPath points to the one and only installation, the root path
    appInstPath := iobHomePath;
    iobStatesPort := 9000;
    iobObjectsPort := 9001;
    iobAdminPort := 8081;
    iobTargetServiceName := 'ioBroker';
    iobServerName := '';
    expertCB.Enabled := True;
    WizardForm.WelcomeLabel2.Caption := CustomMessage('Intro');
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure showExpertMode(sender: TObject);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  expertCB.Visible := True;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function checkAndSetExpertSettings: Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := True;
  if expertCB.Checked and exoNewServerRB.Checked then begin
    if (exsServerNameEdit.Text <> '') then begin
      // First character must not be numeric
      if (exsServerNameEdit.Text[1] >= '0') and (exsServerNameEdit.Text[1] <= '9') then begin
        WizardForm.ActiveControl := exsServerNameEdit;
        MsgBox(CustomMessage('ErrorFirstCharacterNumeric'), mbError, MB_OK);
        Result := False;
        Exit;
      end
      else begin
        iobServerName := exsServerNameEdit.Text;
        iobServiceName := 'iob_' + iobServerName;
        iobTargetServiceName := 'iob_' + iobServerName;
        appInstPath := iobExpertPath + '\' + iobServerName;
      end;
    end
    else begin
      WizardForm.ActiveControl := exsServerNameEdit;
      MsgBox(CustomMessage('ErrorEmptyString'), mbError, MB_OK);
      Result := False;
      Exit;
    end;

    Result := checkPort(exsStatesPortEdit, iobStatesPort);
    if not Result then Exit;

    Result := checkPort(exsObjectsPortEdit, iobObjectsPort);
    if not Result then Exit;

    Result := checkPort(exsAdminPortEdit, iobAdminPort);
    if not Result then Exit;

    if (iobStatesPort = iobObjectsPort) or (iobStatesPort = iobAdminPort) then begin
      WizardForm.ActiveControl := exsStatesPortEdit;
      MsgBox(CustomMessage('ErrorDuplicatePortNumber'), mbError, MB_OK);
      Result := False;
      Exit;
    end;
    if (iobObjectsPort = iobAdminPort) then begin
      WizardForm.ActiveControl := exsObjectsPortEdit;
      MsgBox(CustomMessage('ErrorDuplicatePortNumber'), mbError, MB_OK);
      Result := False;
      Exit;
    end;

    if not isDirectoryEmpty(appInstPath) then begin
      WizardForm.ActiveControl := exsServerNameEdit;
      MsgBox(Format(CustomMessage('ErrorDirectoryExists'), [appInstPath]), mbError, MB_OK);
      Result := False;
      Exit;
    end;
  end
  else begin
    Log('Internal Error! Check and Set Expert Settings was called for Maintain or uninstall!');
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure checkNumeric(var Key: char);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  if not (Key in [#8,#48,#49,#50,#51,#52,#53,#54,#55,#56,#57]) then Key := #0;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure checkAlphaNumeric(var key: Char);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  if not(
   (Key >= #65) and (Key <= #90) or
   (Key >= #97) and (Key <= #122))
  then checkNumeric(Key);
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure keyPressServerName(sender: TObject; var key: Char);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  checkAlphaNumeric(key);
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure keyPressStatesPort(sender: TObject; var key: Char);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  checkNumeric(key);
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure keyPressObjectsPort(sender: TObject; var key: Char);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  checkNumeric(key);
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure keyPressAdminPort(sender: TObject; var key: Char);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  checkNumeric(key);
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function checkPort(var edit: TEdit; var portNumber: Integer): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  portNumber := StrToIntDef(edit.Text, 0);
  if (portNumber <= 1023) or (portNumber > 65353) then begin
    WizardForm.ActiveControl := edit;
    MsgBox(CustomMessage('ErrorInvalidPortNumber'), mbError, MB_OK);
    Result := False;
  end
  else begin
    // ToDo: Warning if port is used by another ioBroker?
    Result := True;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function migrateIoBrokerData(source: String; target: String; logFileName: String): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  answer: Integer;
  resultStr: String;
begin
  resultStr := '';
  DelTree(target + '_old', True, True, True);
  repeat
    Result := RenameFile(target, target + '_old');
    if not Result then begin
      answer := MsgBox(Format(CustomMessage('MigrateDataErrorRename'), [target]), mbError, MB_RETRYCANCEL);
    end;
  until Result or (answer = IDCANCEL);

  if Result then begin
    resultStr := Format('Renamed old folder %s to %s successfully', [target, target + '_old']);
    repeat
      Result := directoryCopy(source, target);
      if not Result then begin
        answer := MsgBox(Format(CustomMessage('MigrateDataErrorCopy'), [optDataMigrationLabel.Caption, target]), mbError, MB_RETRYCANCEL);
      end;
    until Result or (answer = IDCANCEL);
    if Result then begin
      resultStr := resultStr + chr(13) + chr(10) + Format('Copied folder %s to %s successfully', [source, target]);
    end
    else begin
      resultStr := resultStr + chr(13) + chr(10) + Format('Error occurred when copying folder %s to %s', [source, target]);
    end;
  end
  else begin
      resultStr := Format('Error occurred when renaming folder %s to %s', [target, target + '_old']);
  end;
  SaveStringToFile(logFileName,
                   '----------------------------------------------' + chr(13) + chr(10) +
                   'migrateIoBrokerData:' + chr(13) + chr(10) +
                   resultStr + chr(13) + chr(10), True);
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function reconfigureIoBroker(info: String; logFileName: String): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  output: String;
begin
  Result := True;

  // Stop ioBroker:
  marqueePage.setText(info, CustomMessage('StoppIob'));
  Sleep(6000);
  stopIobService(iobServiceName, logFileName);

  if optDataMigrationCB.Checked then begin
    marqueePage.setText(info, Format(CustomMessage('MigrateData'), [optDataMigrationLabel.Caption]));
    migrateIoBrokerData(optDataMigrationLabel.Caption, appInstPath + '\iobroker-data', logFileName);
  end;

  marqueePage.setText(info, CustomMessage('UpdateAdminPort'));
  reconfigureIoBrokerAdminPort(iobAdminPort, logFileName);

  marqueePage.setText(info, CustomMessage('UpdateServerName'));
  reconfigureIoBrokerServerName(iobServername, logFileName);

  marqueePage.setText(info, CustomMessage('UpdateStatesObjectsPort'));
  reconfigureIoBrokerPorts(iobStatesPort, iobObjectsPort, logFileName);

  Log('Start ioBroker service:' + output);
  output := execAndReturnOutput('sc start ' + iobServiceName + '.exe', False, '', '');

  if iobServerName <> '' then begin
    RegWriteStringValue(HKEY_LOCAL_MACHINE, expertRegServersRoot + iobServerName, 'ServerName', iobServerName );
    RegWriteStringValue(HKEY_LOCAL_MACHINE, expertRegServersRoot + iobServerName, 'ServiceName', iobServiceName );
    RegWriteStringValue(HKEY_LOCAL_MACHINE, expertRegServersRoot + iobServerName, 'Path', appInstPath );
    RegWriteDWordValue(HKEY_LOCAL_MACHINE, expertRegServersRoot + iobServerName, 'StatesPort', iobstatesPort );
    RegWriteDWordValue(HKEY_LOCAL_MACHINE, expertRegServersRoot + iobServerName, 'ObjectsPort', iobObjectsPort );
    RegWriteDWordValue(HKEY_LOCAL_MACHINE, expertRegServersRoot + iobServerName, 'AdminPort', iobAdminPort );
  end;

  // We create a new entry if necessary, so remove the old one
  if UserDefAdminPort then begin
    DeleteFile(expandConstant('{group}') + '\[' + getIobServiceName('') + '] ioBroker Admin.lnk');
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function expertInstallationExists: Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  regServerNames: TArrayOfString;
begin
  Result := False;
  if RegGetSubkeyNames(HKEY_LOCAL_MACHINE, expertRegServersRoot, regServerNames) then begin
    Result := (GetArrayLength(regServerNames) > 1);
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function reconfigureIoBrokerPorts(statesPort: Integer; objectsPort: Integer; logFileName: String): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  i: Integer;
  JsonParser: TJsonParser;
  jsonString: AnsiString;
  jsonObject: TJsonObject;
  jsonPort: TJsonNumber;
  stringList: TStringList;
  stringArray: TArrayOfString;
  resultStr: String;
begin
  Result := False;
  resultStr := '----------------------------------------------' + chr(13) + chr(10) + 'reconfigureIoBrokerPorts:' + chr(13) + chr(10);
  if FileExists(appInstPath + '\iobroker-data\iobroker.json') then begin
    LoadStringFromFile(appInstPath + '\iobroker-data\iobroker.json', jsonString);
    ClearJsonParser(JsonParser);
    ParseJson(JsonParser, jsonString);
    if FindJsonObject(JsonParser.Output, JsonParser.Output.Objects[0], 'states', jsonObject) then begin
      if FindJsonNumber(JsonParser.Output, jsonObject, 'port', jsonPort) then begin
        UpdateJsonNumber(JsonParser.Output, jsonObject, 'port', statesPort);
        Log(Format('Updated states port to %d', [statesPort]));
        resultStr := resultStr + Format('Updated states port to %d', [statesPort]) + chr(13) + chr(10);
      end;
    end;
    if FindJsonObject(JsonParser.Output, JsonParser.Output.Objects[0], 'objects', jsonObject) then begin
      if FindJsonNumber(JsonParser.Output, jsonObject, 'port', jsonPort) then begin
        UpdateJsonNumber(JsonParser.Output, jsonObject, 'port', objectsPort);
        Log(Format('Updated objects port to %d', [objectsPort]));
        resultStr := resultStr + Format('Updated objects port to %d', [objectsPort]) + chr(13) + chr(10);
      end;
    end;
  end;

  stringList := TStringList.Create;
  try
    PrintJsonParserOutput(JsonParser.Output, stringList);
    SetLength(stringArray, stringList.Count);
    for i := 0 To stringList.Count-1 do begin
      stringArray[i] := stringList[i];
    end;
    FileCopy(appInstPath + '\iobroker-data\iobroker.json', appInstPath + '\iobroker-data\iobroker.json_backup', False);
    Result := SaveStringsToFile(appInstPath + '\iobroker-data\iobroker.json', stringArray, false);
    Log('Saved ' + appInstPath + '\iobroker-data\iobroker.json');
    resultStr := resultStr + 'Saved ' + appInstPath + '\iobroker-data\iobroker.json ' + Format('Result: %d', [Result]) + chr(13) + chr(10);
  finally
    stringList.Free;
  end;
  SaveStringToFile(logFileName, resultStr, True);
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function reconfigureIoBrokerAdminPort(adminPort: Integer; logFileName: String): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  cmd: String;
  resultStr: String;
begin
  Result := True;
  cmd := '"' + nodePath + '\node.exe" "' + appInstPath + '\node_modules\iobroker.js-controller/iobroker.js" set admin.0 --port ' + Format('%d', [adminPort]);
  Log (cmd);
  resultStr := execAndReturnOutput(cmd, True, nodePath, appInstPath);
  Log('reconfigureIoBrokerAdminPort: ' + cmd);
  Log(resultStr);
  SaveStringToFile(logFileName,
                   '----------------------------------------------' + chr(13) + chr(10) +
                   'reconfigureIoBrokerAdminPort:' + chr(13) + chr(10) +
                   resultStr + chr(13) + chr(10), True);
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function reconfigureIoBrokerServerName(serverName: String; logFileName: String): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  cmd: String;
  resultStr: String;
begin
  Result := True;
  if serverName <> '' then begin
    cmd := '"' + nodePath + '\node.exe" "' + appInstPath + '\node_modules\iobroker.js-controller/iobroker.js" host set ' + serverName;
  end else begin
    cmd := '"' + nodePath + '\node.exe" "' + appInstPath + '\node_modules\iobroker.js-controller/iobroker.js" host this';
  end;

  resultStr := execAndReturnOutput(cmd, True, nodePath, appInstPath);
  Log('reconfigureIoBrokerServerName: ' + cmd);
  Log(resultStr);
  SaveStringToFile(logFileName,
                   '----------------------------------------------' + chr(13) + chr(10) +
                   'reconfigureIoBrokerServerName:' + chr(13) + chr(10) +
                   resultStr + chr(13) + chr(10), True);
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure updateExpertOptionsPage;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  curInstServiceName: String;
  statesPort: Integer;
  objectsPort: Integer;
  adminPort: Integer;
  serverName: String;
  regServerNames: TArrayOfString;
  regPath: String;
  i: Integer;

begin
  exoMaintainServerCombo.Items.Clear;
  exoUninstallServerCombo.Items.Clear;

  // Check if a "base" installation is existing and add to server lists:
  if FileExists(iobHomePath + '\node_modules\iobroker.js-controller/iobroker.js')then begin
    try
      progressPage.SetText(CustomMessage('GatherInformation'), 'ioBroker');
      progressPage.Show
      progressPage.SetProgress(1,2);
      curInstServiceName := getIoBrokerServiceNameFromEnv(iobHomePath);
      gatherIobPortsAndServername(iobHomePath, statesPort, objectsPort, adminPort, serverName);
      exoMaintainServerCombo.Items.add(fillStringWithBlanks(serverName, 16) + ' | ' + iobHomePath);
      exoUninstallServerCombo.Items.add(fillStringWithBlanks(serverName, 16) + ' | ' + iobHomePath);
      progressPage.SetProgress(2,2);
    except
      Log(GetExceptionMessage);
    finally
      progressPage.Hide
    end;
  end;

  // Check if in the current expert path an installation is existing:
  if FileExists(iobExpertPath + '\node_modules\iobroker.js-controller/iobroker.js')then begin
    exoNewServerRB.Enabled := False;
    exoNewServerLabel.Caption := Format(CustomMessage('ExpertNewServerForbiddenDesc'), [iobExpertPath]);
    exoMaintainServerRB.Checked := True;
  end
  else begin
    exoNewServerRB.Enabled := True;
    exoNewServerLabel.Caption := CustomMessage('ExpertNewServerDesc') + chr(13) + chr(10) +
                                 Format(CustomMessage('ExpertNewServerIn'), [iobExpertPath]);
    exoNewServerRB.Checked := True;
  end;

  // Add servers stored in Registry to comboboxes
  if RegGetSubkeyNames(HKEY_LOCAL_MACHINE, expertRegServersRoot, regServerNames) then begin
    for i := 0 to GetArrayLength(regServerNames)-1 do begin
      if not RegQueryStringValue(HKEY_LOCAL_MACHINE, expertRegServersRoot + regServerNames[i], 'Path', regPath) then begin
        regPath := '<unknown>';
      end;
      exoMaintainServerCombo.Items.add(fillStringWithBlanks(regServerNames[i], 16) + ' | ' + regPath);
      exoUninstallServerCombo.Items.add(fillStringWithBlanks(regServerNames[i], 16) + ' | ' + regPath);
    end;
  end;

  if exoMaintainServerCombo.Items.Count > 0 then begin
    exoMaintainServerRB.Enabled := True;
    exoMaintainServerCombo.ItemIndex := 0;
  end;

  if exoUninstallServerCombo.Items.Count > 0 then begin
    exoUninstallServerRB.Enabled := True;
    exoUninstallServerCombo.ItemIndex := 0;
  end;

end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure getPortsAndServerNameForExpertSettingsPage(var statesPort: Integer; var objectsPort: Integer; var adminPort: Integer; var serverName: String);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  regServerNames: TArrayOfString;
  i: Integer;
  j: Integer;
  path: String;
  sprt: Cardinal;
  oprt: Cardinal;
  aprt: Cardinal;
  done: Boolean;
  modified: Boolean;
  srvName: String;
begin
  if exoNewServerRB.Checked then begin
    statesPort := 9010;
    objectsPort := 9011;
    adminPort := 8091;
    serverName := 'SmartHome';
    // Find most probably free ports not used by an existing iob installation:
    done := False;
    modified := True;
    while not done and modified do begin
      if RegGetSubkeyNames(HKEY_LOCAL_MACHINE, expertRegServersRoot, regServerNames) then begin
        if GetArrayLength(regServerNames) > 0 then begin
          modified := False;
          for i := 0 to GetArrayLength(regServerNames)-1 do begin
            RegQueryDWordValue(HKEY_LOCAL_MACHINE, expertRegServersRoot + regServerNames[i], 'StatesPort', sprt);
            RegQueryDWordValue(HKEY_LOCAL_MACHINE, expertRegServersRoot + regServerNames[i], 'ObjectsPort', oprt);
            RegQueryDWordValue(HKEY_LOCAL_MACHINE, expertRegServersRoot + regServerNames[i], 'AdminPort', aprt);
            if (sprt = statesPort) or (sprt = objectsPort) or (sprt = adminPort) or
               (oprt = statesPort) or (oprt = objectsPort) or (oprt = adminPort) or
               (aprt = statesPort) or (aprt = objectsPort) or (aprt = adminPort)
            then begin
              statesPort := statesPort + 10;
              objectsPort := objectsPort + 10;
              adminPort := adminPort + 10;
              modified := True;
            end;
          end;
        end
        else begin
          done := True;
        end;
      end
      else begin
        done := True;
      end;
    end;
    // Find not used server name:
    done := False;
    modified := True;
    j := 0;
    while not done and modified do begin
      j := j + 1;
      if RegGetSubkeyNames(HKEY_LOCAL_MACHINE, expertRegServersRoot, regServerNames) then begin
        if GetArrayLength(regServerNames) > 0 then begin
          modified := False;
          for i := 0 to GetArrayLength(regServerNames)-1 do begin
            RegQueryStringValue(HKEY_LOCAL_MACHINE, expertRegServersRoot + regServerNames[i], 'ServerName', srvName);
            if srvName = serverName then begin
              serverName := 'SmartHome' + IntToStr(j);
              modified := True;
            end
          end;
        end
        else begin
          done := True;
        end;
      end
      else begin
        done := True;
      end;
    end;
  end
  else begin
    if exoMaintainServerRB.Checked then begin
      path := Copy(exoMaintainServerCombo.Text, pos('|', exoMaintainServerCombo.Text) + 2, Length(exoMaintainServerCombo.Text));
    end
    else begin
      path := Copy(exoUninstallServerCombo.Text, pos('|', exoUninstallServerCombo.Text) + 2, Length(exoUninstallServerCombo.Text));
    end;
    try
      progressPage.SetText(CustomMessage('GatherInformation'), 'ioBroker');
      progressPage.Show
      progressPage.SetProgress(1,2);
      gatherIobPortsAndServername(path, statesPort, objectsPort, adminPort, serverName);
      progressPage.SetProgress(2,2);
    except
      Log(GetExceptionMessage);
    finally
      progressPage.Hide
    end;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure updateExpertSettingsPage;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  getPortsAndServerNameForExpertSettingsPage(iobStatesPort, iobObjectsPort, iobAdminPort, iobServerName);

  exsServerNameEdit.Text := iobServerName;
  exsStatesPortEdit.Text := IntToStr(iobStatesPort);
  exsObjectsPortEdit.Text := IntToStr(iobObjectsPort);
  exsAdminPortEdit.Text := IntToStr(iobAdminPort);

  if exoNewServerRB.Checked then begin
    expertSettingsPage.Description := CustomMessage('ExpertSettingsCaptionNew');
    exsIntroLabel.Caption := CustomMessage('ExpertSettingsIntroNewServer');
    exsServerNameEdit.Enabled := True;
    exsStatesPortEdit.Enabled := True;
    exsObjectsPortEdit.Enabled := True;
    exsAdminPortEdit.Enabled := True;
  end
  else begin
    exsServerNameEdit.Enabled := False;
    exsStatesPortEdit.Enabled := False;
    exsObjectsPortEdit.Enabled := False;
    exsAdminPortEdit.Enabled := False;
    if exoMaintainServerRB.Checked then begin
      expertSettingsPage.Description := CustomMessage('ExpertSettingsCaptionMaintain');
      exsIntroLabel.Caption := CustomMessage('ExpertSettingsIntroMaintainServer');
    end
    else begin
      expertSettingsPage.Description := CustomMessage('ExpertSettingsCaptionRemove');
      exsIntroLabel.Caption := CustomMessage('ExpertSettingsIntroRemoveServer');
    end;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure expertOptionChanged(sender: TObject);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  if exoNewServerRB.Checked then begin
    exoMaintainServerCombo.Enabled := False;
    exoUninstallServerCombo.Enabled := False;
  end;
  if exoMaintainServerRB.Checked then begin
    exoMaintainServerCombo.Enabled := True;
    exoUninstallServerCombo.Enabled := False;
  end;
  if exoUninstallServerRB.Checked then begin
    exoMaintainServerCombo.Enabled := False;
    exoUninstallServerCombo.Enabled := True;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function expertDirectoryAllowed(path: String; var retry: Boolean): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  retry := False;
  Result := not FileExists(path + '\node_modules\iobroker.js-controller/iobroker.js');

  if not Result then begin
    retry := MsgBox(Format(CustomMessage('DirForbidden'), [path]), mbError, MB_RETRYCANCEL) = IDRETRY;
  end
  else begin
    Result := Pos('&', path) = 0;
    if not Result then begin
      retry := MsgBox(Format(CustomMessage('FolderInvalidCharacter'),['&']), mbError, MB_RETRYCANCEL) = IDRETRY;
    end;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure expertSelectDirectory(sender: TObject);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  dir: String;
  subDir: String;
  s: String;
  i: Integer;
  p: Integer;
  valid: Boolean;
  abort: Boolean;
  retry: Boolean;
begin
  repeat
    dir := iobExpertPath;
    valid := True;
    abort := False;
    if BrowseForFolder(CustomMessage('SelectMigrationDir'), dir, True) then begin
      i := 0;
      s := RemoveBackslash(dir);
      subDir := '';
      repeat
        p := Pos('\',s);
        if p > 0 then begin
          if subDir <> '' then subdir := subDir + '\';
          subDir := subdir + Copy(s, 1, p-1);
          Log(subDir);
          if not expertDirectoryAllowed(subDir, retry) then begin
            valid := False;
            if retry then Break else Exit;
          end;
          s := Copy(s, p + 1, Length(s));
          i := i + 1;
        end
        else begin
          if subDir <> '' then subdir := subDir + '\';
          subDir := subDir + s;
          if not expertDirectoryAllowed(subDir, retry) then begin
            valid := False;
            if retry then Break else Exit;
          end;
          Log(s);
          s := '';
        end;
      until Length(s) = 0;
    end
    else begin
      valid := False;
      abort := True;
      break;
    end;
  until valid or abort;

  if valid then begin
    iobExpertPath := RemoveBackslash(dir);
    RegWriteStringValue(HKEY_LOCAL_MACHINE, expertRegServersRoot, 'RootPath', iobExpertPath );
  end;
  updateExpertOptionsPage;
end;


