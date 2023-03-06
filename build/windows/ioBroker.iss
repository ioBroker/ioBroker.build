; ----------------------------------------------------------------------------------------------
; - ioBroker Windows Installer                                                                 -
; ----------------------------------------------------------------------------------------------
; -                                                                                            -
; - 21.05.2023 Bluefox: Initial version                                                        -
; - 03.03.2023 Gaspode: Improved look & feel, improved error handling, added several checks,   -
; -                     implemented more options                                               -
; - 04.03.2023 Gaspode: added several languages                                                -
; -                                                                                            -
; -                                                                                            -
; ----------------------------------------------------------------------------------------------

#define MyAppName "ioBroker automation platform"  
#define MyAppShortName "ioBroker"
#define MyAppLCShortName "iobroker"
#define MyAppPublisher "ioBroker GmbH"
#define MyAppURL "https://www.ioBroker.net/"
#define MyAppIcon "ioBroker.ico"

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

[Files]
Source: "resource\{#MyAppIcon}"; DestDir: "{app}"; Flags: ignoreversion
Source: "resource\port.bat"; DestDir: "{tmp}"
Source: "{tmp}\~iobinfo.json"; DestDir: "{app}"; Flags: external

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

//russian.Intro=ioBroker - это центральный сервер для умных домов и автоматизации.%n%nCioBroker вы получаете:%n- мощное, но простое в управлении решение от%n- удобный интерфейс%n- простая интеграция с существующими системами и службами%n- модульный дизайн%n- визуализация через Интернет%n- мобильный доступ%n- подключение к Alexa, Homekit многим другим системам умного дома%n- помощь от большого и активного сообщества%n%nioBroker - Automate your life%n%nInstaller Version {#MyAppVersion}

[Run]
Filename: http://localhost:8081/; Description: "{cm:OpenIoBrokerSettings}"; Flags: postinstall shellexec;  Check: success
Filename: {win}\explorer; Parameters: "{app}\log";Description: "{cm:OpenLogFileDirectory}"; Flags: postinstall shellexec;  Check: not success

[UninstallRun]
; Removes System Service
Filename: "{code:getNodePath}\node.exe"; Parameters: """{app}\uninstall.js"""; Flags: runhidden;

[UninstallDelete]
Type: filesandordirs; Name: "{app}\*.js"
Type: filesandordirs; Name: "{app}\*.md"
Type: filesandordirs; Name: "{app}\*.cmd"
Type: filesandordirs; Name: "{app}\*.bat"
Type: filesandordirs; Name: "{app}\*.json"
Type: filesandordirs; Name: "{app}\*.ps1"
Type: filesandordirs; Name: "{app}\*.sh"
Type: filesandordirs; Name: "{app}\LICENSE"
Type: filesandordirs; Name: "{app}\instDone"
Type: filesandordirs; Name: "{app}\daemon"
Type: filesandordirs; Name: "{app}\node_modules"
Type: filesandordirs; Name: "{app}\install"
Type: filesandordirs; Name: "{app}\log"
Type: filesandordirs; Name: "{app}\semver"

[Code]
#include "resource\JsonParser.pas"
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
{ Global variables are initialized with 0, '' or nil by default                                                                                                                                    }
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  appInstPath: String;

  instNodeVersionMajor: Integer;
  instNodeVersionMinor: Integer;
  instNodeVersionPatch: Integer;

  rcmdNodeVersionMajor: Integer;
  rcmdNodeVersionMinor: Integer;
  rcmdNodeVersionPatch: Integer;

  acceptedNodeVersions: array of Integer;

  iobVersionMajor: Integer;
  iobVersionMinor: Integer;
  iobVersionPatch: Integer;

  iobControllerFoundNoNode: Boolean;

  rcmdNodeDownloadPath: String;

  nodePath: String;

  summaryPage: TWizardPage;
  optionsPage: TWizardPage;

  info1NodeLabel: TLabel;
  info2NodeLabel: TLabel;
  info3NodeLabel: TLabel;
  info1IoBrokerLabel: TLabel;
  info2IoBrokerLabel: TLabel;
  info1IoBrokerRunLabel: TLabel;
  info2IoBrokerRunLabel: TLabel;
  info1Port9000Label: TLabel;
  info2Port9000Label: TLabel;
  info1Port9001Label: TLabel;
  info2Port9001Label: TLabel;
  info1Port8081Label: TLabel;
  info2Port8081Label: TLabel;
  summaryLabel: TLabel;

  installNodeCB: TCheckBox;
  installNodeLabel: TLabel;
  installIoBrokerCB: TCheckBox;
  installIoBrokerLabel: TLabel;
  fixIoBrokerCB: TCheckBox;
  fixIoBrokerLabel: TLabel;
  
  additionalHintsLabel: TLabel;

  retryButton: TButton;
  progressPage: TOutputProgressWizardPage;
  marqueePage: TOutputMarqueeProgressWizardPage;

  readyToInstall: Boolean;
  tryStopServiceAtNextRetry: Boolean;

  iobServiceName: String;
  iobServiceExists: Boolean;
  iobInstalled: Boolean;

  isUpgrade: Boolean;
  
  installationSuccessful: Boolean;

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
function FindJsonStrValue(
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
  Output: TJsonParserOutput; Parent: TJsonObject; Key: TJsonString;
  var Value: String): Boolean;
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
function FindJsonStrArray(
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
  Output: TJsonParserOutput; Parent: TJsonObject; Key: TJsonString;
  var values: TArrayOfString): Boolean;
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
function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  if Progress = ProgressMax then
    Log(Format('Successfully downloaded file to {tmp}: %s', [FileName]));
  Result := True;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function OnDownloadProgressNode(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  progressPage.SetProgress(Progress, ProgressMax);
  if Progress = ProgressMax then
    Log(Format('Successfully downloaded file to {tmp}: %s', [FileName]));
  Result := True;
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
    end else begin
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
function execAndReturnOutput(myCmd: String; allLines: Boolean): String;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  tmpTxtFileName: String;
  tmpBatFileName: String;
  resultCode: Integer;
  stdOutTxt: TArrayOfString;
  i: Integer;
begin
  Result := '';
  tmpTxtFileName := ExpandConstant('{tmp}') + '\~iobinst_tmp.txt';
  tmpBatFileName := ExpandConstant('{tmp}') + '\~iobinst_tmp.bat';

  if (SaveStringToFile(tmpBatFileName, '@' + myCmd, false)) then begin
    if (Exec(ExpandConstant('{cmd}'), '/C ' + tmpBatFileName + ' > "' + tmpTxtFileName + '"', '', SW_HIDE, ewWaitUntilTerminated, resultCode)) then begin
      if LoadStringsFromFile(tmpTxtFileName, stdOutTxt) then begin
        if GetArrayLength(stdOutTxt) > 0 then begin
          if allLines then begin
            for i := 0 to GetArrayLength(stdOutTxt)-1 do begin
              Result := Result + stdOutTxt[i] + '%n';
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
function execAndStoreOutput(myCmd: String; myLogFileName: String) : Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  tmpBatFileName: String;
  resultCode: Integer;
  logPart: String;
begin
  Result := False;
  tmpBatFileName := ExpandConstant('{tmp}') + '\~iobExec_tmp.bat';

  if myLogFileName <> '' then begin
    logPart := ' > "' + myLogFileName + '" 2>&1';
  end
  else begin
    logPart := '';
  end;


  if (SaveStringToFile(tmpBatFileName, '@' + myCmd + logPart, false)) then begin
    Sleep(1000);
    if (Exec(ExpandConstant('{cmd}'), '/C ' + tmpBatFileName + logPart, appInstPath, SW_HIDE, ewWaitUntilTerminated, resultCode)) then begin
      Result := True;
    end;
  end;
  DeleteFile(tmpBatFileName);
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
  ioBrokerEx := appInstPath + '\node_modules\iobroker.js-controller/iobroker.js';
  if (FileExists(ioBrokerEx)) then begin
    Result := True;
    if (nodePath <> '') then begin
      nodeJsEx := nodePath + '\node.exe';
      versionString := execAndReturnOutput('"' + nodeJsEx + '" "' + ioBrokerEx + '" --version', False);
      if (convertVersion(versionString, iobVersionMajor, iobVersionMinor, iobVersionPatch)) then begin
        Log(Format('Found ioBroker version: %d, %d, %d', [iobVersionMajor, iobVersionMinor, iobVersionPatch]));
      end
    end
    else begin
      iobControllerFoundNoNode := True;
      Log('ioBroker.js-controller found, but Node.js not found.');
    end
  end
  else begin
    Log('ioBroker.js-controller not found.');
  end
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function isIobServiceRunning: boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  statusString: String;
begin
  statusString := execAndReturnOutput('sc query ' + iobServiceName, True);
  Log(Format('ioBroker Service Status: %s', [statusString]));
  Result := pos('RUNNING', statusString) > 0;
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
    Result := isIobServiceRunning
  end
  else begin
    Log('ioBroker.js-controller not found.');
  end
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function getPortInfo(port: Integer): String;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := execAndReturnOutput(Format('%s\port.bat %d', [ExpandConstant('{tmp}'), port]), False);
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure gatherInstNodeData;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  versionString: String;
  found: boolean;
begin
  found := false;

  if RegKeyExists(GetHKLM, 'SOFTWARE\Node.js') then begin
    if (RegQueryStringValue(GetHKLM, 'SOFTWARE\Node.js', 'InstallPath', nodePath)) then begin
      if (nodePath <> '') then begin
        nodePath := RemoveBackslash(ExtractFilePath(nodePath));
        Log(Format('Found Node.js path: %s', [nodePath]));
        RegQueryStringValue(GetHKLM, 'SOFTWARE\Node.js', 'Version', versionString);
        if (nodePath <> '') then begin
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
function getNodePath(Param: String): String;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  gatherInstNodeData;
  Result := nodePath;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure gatherNodeData;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  JsonParser: TJsonParser;
  jsonString: AnsiString;
  nodeRecommendedStr: String;
  nodeAcceptedStrings: TArrayOfString;
  nodeLatestList: TArrayOfString;
  searchString: String;
  i: Integer;
  endPos: Integer;
  startPos: Integer;
  versionString: String;
  nodeFileName: String;
begin
  try
    if rcmdNodeVersionMajor = 0 then begin
      DownloadTemporaryFile('https://raw.githubusercontent.com/iobroker-community-adapters/ioBroker.info/master/admin/lib/data/infoData.json', '~iobinfo.json', '', @OnDownloadProgress);
      LoadStringFromFile(ExpandConstant('{tmp}') + '\~iobinfo.json', jsonString);
      ClearJsonParser(JsonParser);
      ParseJson(JsonParser, jsonString);
      FindJsonStrValue (JsonParser.Output, JsonParser.Output.Objects[0], 'nodeRecommended', nodeRecommendedStr);
      Log('--->Node Recommended: '+nodeRecommendedStr);
      Log('--->'+'https://nodejs.org/dist/latest-' + nodeRecommendedStr + '.x/SHASUMS256.txt');

      DownloadTemporaryFile('https://nodejs.org/dist/latest-' + nodeRecommendedStr + '.x/SHASUMS256.txt', '~nodeInfo.txt', '', @OnDownloadProgress);
      if LoadStringsFromFile(ExpandConstant('{tmp}') + '\~nodeInfo.txt', nodeLatestList) then begin
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
              rcmdNodeDownloadPath := 'https://nodejs.org/dist/latest-' + nodeRecommendedStr + '.x/' + nodeFileName;
              Log(rcmdNodeDownloadPath);
              if (convertVersion(versionString, rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch)) then begin
                Log(Format('Recommended Node version: %d, %d, %d', [rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch]));
              end;
              break;
            end;
          end;
        end;
      end;
      FindJsonStrArray (JsonParser.Output, JsonParser.Output.Objects[0], 'nodeAccepted', nodeAcceptedStrings);
      setArrayLength(acceptedNodeVersions, GetArrayLength(nodeAcceptedStrings));
      for i:=0 to GetArrayLength(nodeAcceptedStrings)-1 do begin
        acceptedNodeVersions[i] := StrToIntDef(Copy(nodeAcceptedStrings[i], 2, Length(nodeAcceptedStrings[i])-1), 0);
        Log(Format('--->Node Accepted: %d',[acceptedNodeVersions[i]]));
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
procedure retryTestReady(sender: TObject); forward;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure updateSummaryPage;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  portInfo: String;
  portInfoArray: TArrayOfString;
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
  maxProgress := 8;
  progress := 0;

  tryStopServiceAtNextRetry := False;

  iobServiceExists := (execAndReturnOutput('sc GetDisplayName ' + iobServiceName + ' | find /C "ioBroker"', False) = '1');

  progressPage.SetProgress(progress, maxProgress); progress := progress +1;
  progressPage.Show
  progressPage.SetText(CustomMessage('GatherInformation'), 'Node.js');
  gatherInstNodeData;

  progressPage.SetProgress(progress, maxProgress); progress := progress +1;
  progressPage.SetText(CustomMessage('GatherInformation'), 'ioBroker');
  iobInstalled := gatherIoBrokerInfo;

  progressPage.SetProgress(progress, maxProgress); progress := progress +1;
  iobRunning := gatherIoBrokerStatus;

  progressPage.SetProgress(progress, maxProgress); progress := progress +1;
  progressPage.SetText(CustomMessage('GatherInformation'), CustomMessage('RecommendenNodeVersion'));
  gatherNodeData;

  progressPage.SetProgress(progress, maxProgress); progress := progress +1;
  progressPage.SetText(CustomMessage('GatherInformation'), CustomMessage('RequiredPorts'));
  
  ExtractTemporaryFiles('{tmp}\port.bat');

  if instNodeVersionMajor = 0 then begin
    info1NodeLabel.Font.Color := clBlue;
    info1NodeLabel.Caption := '✗';
    info2NodeLabel.Caption := CustomMessage('NodeNotInstalled');
  end
  else begin
    if instNodeVersionMajor = rcmdNodeVersionMajor then begin
      info1NodeLabel.Font.Color := clGreen;
      info1NodeLabel.Caption := '✓';
      info2NodeLabel.Caption := Format(CustomMessage('NodeInstalled'), [instNodeVersionMajor, instNodeVersionMinor, instNodeVersionPatch, nodePath]);
    end
    else begin
      if isNodeVersionSupported(instNodeVersionMajor) then begin
        info1NodeLabel.Font.Color := clYellow;
        info1NodeLabel.Caption := '⚠';
        info2NodeLabel.Caption := Format(CustomMessage('NodeInstalled'), [instNodeVersionMajor, instNodeVersionMinor, instNodeVersionPatch, nodePath]);
      end
      else begin
        info1NodeLabel.Font.Color := clRed;
        info1NodeLabel.Caption := '⚠';
        info2NodeLabel.Caption := Format(CustomMessage('NodeInstalled'), [instNodeVersionMajor, instNodeVersionMinor, instNodeVersionPatch, nodePath]);
      end;
    end;
  end;

  info3NodeLabel.Caption := Format(CustomMessage('NodeRecommended'), [rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch]);

  if iobVersionMajor = 0 then begin
    if iobControllerFoundNoNode then begin
      info1IoBrokerLabel.Font.Color := clBlue;
      info1IoBrokerLabel.Caption := '?';
      info2IoBrokerLabel.Caption := Format(CustomMessage('IoBrokerControllerFoundNoNode'), [appInstPath]);
    end
    else begin
      info1IoBrokerLabel.Font.Color := clBlue;
      info1IoBrokerLabel.Caption := '✗';
      info2IoBrokerLabel.Caption := Format(CustomMessage('IoBrokerNotInstalled'), [appInstPath]);
    end
  end
  else begin
    info1IoBrokerLabel.Font.Color := clGreen;
    info1IoBrokerLabel.Caption := '✓';
    info2IoBrokerLabel.Caption := Format(CustomMessage('IoBrokerInstalled'), [iobVersionMajor, iobVersionMinor, iobVersionPatch, appInstPath]);
  end;

  if iobRunning then begin
    info1IoBrokerRunLabel.Font.Color := clRed;
    info1IoBrokerRunLabel.Caption := '⚠';
    info2IoBrokerRunLabel.Caption := CustomMessage('IoBrokerRunning');
    readyToInstall := False;
  end
  else begin
    info1IoBrokerRunLabel.Font.Color := clGreen;
    info1IoBrokerRunLabel.Caption := '✓';
    info2IoBrokerRunLabel.Caption := CustomMessage('IoBrokerNotRunning');
  end;
  
  portInfo := getPortInfo(9000);
  if portinfo <> '' then begin
    explode(portInfoArray, portInfo, ';');
    info1Port9000Label.Font.Color := clRed;
    info1Port9000Label.Caption := '⚠';
    info2Port9000Label.Caption := Format(CustomMessage('PortInUse'), [portInfoArray[0], portInfoArray[1], portInfoArray[2]]);
    readyToInstall := False;
    portsInUse := True;
  end
  else begin
    info1Port9000Label.Font.Color := clGreen;
    info1Port9000Label.Caption := '✓';
    info2Port9000Label.Caption := Format(CustomMessage('PortAvailable'), [9000]);
  end;
  progressPage.SetProgress(progress, maxProgress); progress := progress +1;
  
  portInfo := getPortInfo(9001);
  if portInfo <> '' then begin
    explode(portInfoArray, portInfo, ';');
    info1Port9001Label.Font.Color := clRed;
    info1Port9001Label.Caption := '⚠';
    info2Port9001Label.Caption := Format(CustomMessage('PortInUse'), [portInfoArray[0], portInfoArray[1], portInfoArray[2]]);
    readyToInstall := False;
    portsInUse := True;
  end
  else begin
    info1Port9001Label.Font.Color := clGreen;
    info1Port9001Label.Caption := '✓';
    info2Port9001Label.Caption := Format(CustomMessage('PortAvailable'), [9001]);
  end;
  progressPage.SetProgress(progress, maxProgress); progress := progress +1;
  
  portInfo := getPortInfo(8081);
  if portInfo <> '' then begin
    explode(portInfoArray, portInfo, ';');
    info1Port8081Label.Font.Color := clRed;
    info1Port8081Label.Caption := '⚠';
    info2Port8081Label.Caption := Format(CustomMessage('PortInUse'), [portInfoArray[0], portInfoArray[1], portInfoArray[2]]);
    readyToInstall := False;
    portsInUse := True;
  end
  else begin
    info1Port8081Label.Font.Color := clGreen;
    info1Port8081Label.Caption := '✓';
    info2Port8081Label.Caption := Format(CustomMessage('PortAvailable'), [8081]);
  end;
  progressPage.SetProgress(progress, maxProgress); progress := progress +1;

  DeleteFile('{tmp}\port.bat');

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
            summaryText := CustomMessage('warningService');
          end
        end
      end;
    end
  end;

  if readyToInstall then begin
    retryButton.Hide
  end
  else begin
    retryButton.Show
  end;

  summaryLabel.Caption := summaryText;

  progressPage.Hide;

end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure updateOptionsPage;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  additionalHintsLabel.Caption := '';

  if instNodeVersionMajor = 0 then begin
    installNodeCB.checked := True;
    installNodeLabel.Caption := Format(CustomMessage('InstallNodejs'),[rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch]);
    installNodeCB.Enabled := False;
    installNodeCB.Enabled := False;
  end
  else begin
    if instNodeVersionMajor > rcmdNodeVersionMajor then begin
      installNodeCB.checked := False;
      installNodeLabel.Caption := Format(CustomMessage('InstallNodejsMajorTooHigh'),[instNodeVersionMajor, instNodeVersionMinor, instNodeVersionPatch, rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch]);
      installNodeCB.Enabled := False;
      installNodeCB.Enabled := False;
      additionalHintsLabel.Caption := CustomMessage('NodejsMajorTooHigh');
    end
    else
      if isNodeVersionSupported(instNodeVersionMajor) = False then begin
        installNodeCB.checked := True;
        installNodeLabel.Caption := Format(CustomMessage('InstallNodejsMajorTooLow'),[instNodeVersionMajor, instNodeVersionMinor, instNodeVersionPatch, rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch]);
        installNodeCB.Enabled := False;
        installNodeCB.Enabled := False;
        additionalHintsLabel.Caption := CustomMessage('NodejsMajorTooLow');
      end
      else begin
        if (instNodeVersionMajor = rcmdNodeVersionMajor) and (instNodeVersionMinor = rcmdNodeVersionMinor) and (instNodeVersionPatch = rcmdNodeVersionPatch) then begin
          installNodeCB.checked := False;
          installNodeLabel.Caption := Format(CustomMessage('InstallNodejsAlreadyInstalled'),[instNodeVersionMajor, instNodeVersionMinor, instNodeVersionPatch, rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch]);
          installNodeCB.Enabled := True;
          installNodeCB.Enabled := True;
        end
        else begin
          installNodeCB.checked := True;
          installNodeLabel.Caption := Format(CustomMessage('UpdateNodejs'),[instNodeVersionMajor, instNodeVersionMinor, instNodeVersionPatch, rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch]);
          installNodeCB.Enabled := True;
          installNodeCB.Enabled := True;
        end
      end
  end;

  if (iobVersionMajor = 0) and (iobControllerFoundNoNode = False) then begin
    installIoBrokerCB.checked := True;
    installIoBrokerLabel.Caption := Format(CustomMessage('InstallIoBroker'),[appInstPath]);
    installIoBrokerCB.Enabled := True;
    installIoBrokerCB.Enabled := True;

    fixIoBrokerCB.checked := False;
    fixIoBrokerLabel.Caption := Format(CustomMessage('FixIoBroker'),[appInstPath]);
    fixIoBrokerCB.Enabled := False;
    fixIoBrokerCB.Enabled := False;
  end
  else begin
    installIoBrokerCB.checked := False;
    installIoBrokerLabel.Caption := Format(CustomMessage('InstallIoBrokeralreadyInstalled'),[appInstPath]);
    installIoBrokerCB.Enabled := False;
    installIoBrokerCB.Enabled := False;

    fixIoBrokerCB.checked := True;
    fixIoBrokerLabel.Caption := Format(CustomMessage('FixIoBroker'),[appInstPath]);
    fixIoBrokerCB.Enabled := True;
    fixIoBrokerCB.Enabled := True;
  end;
end;
 
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure updateNextOptionPage(sender: TObject);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  WizardForm.NextButton.Enabled := True;
  if (installNodeCB <> nil) and (installNodeCB <> nil) and (installNodeCB <> nil) then begin
    WizardForm.NextButton.Enabled := (installNodeCB.Checked or installIoBrokerCB.Checked or fixIoBrokerCB.Checked);
  end;
  WizardForm.Update;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure createPages;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  if summaryPage = nil then begin
    if isUpgrade then begin
      summaryPage := CreateCustomPage(wpWelcome, 'ioBroker - Automate your life', '');
    end
    else begin
      summaryPage := CreateCustomPage(wpSelectDir, 'ioBroker - Automate your life', '');
    end;

    optionsPage := CreateCustomPage(summaryPage.ID, 'ioBroker - Automate your life', '');

    info1NodeLabel := TLabel.Create(WizardForm);
    info1NodeLabel.Parent := summaryPage.Surface;
    info1NodeLabel.Left := ScaleX(8);
    info1NodeLabel.Top := ScaleY(2);
    info1NodeLabel.Width := ScaleX(12); 
    info1NodeLabel.Height := ScaleX(12);
    info1NodeLabel.Font.Style := [fsBold];

    info2NodeLabel := TLabel.Create(WizardForm);
    info2NodeLabel.Parent := summaryPage.Surface;
    info2NodeLabel.Left := ScaleX(22);
    info2NodeLabel.Top := ScaleY(2);
    info2NodeLabel.Width := summaryPage.SurfaceWidth - ScaleX(22); 
    info2NodeLabel.Height := ScaleY(16);

    info3NodeLabel := TLabel.Create(WizardForm);
    info3NodeLabel.Parent := summaryPage.Surface;
    info3NodeLabel.Left := ScaleX(22);
    info3NodeLabel.Top := info1NodeLabel.Top + info1NodeLabel.Height + ScaleY(4);
    info3NodeLabel.Width := summaryPage.SurfaceWidth - ScaleX(22); 
    info3NodeLabel.Height := ScaleY(16);


    info1IoBrokerLabel := TLabel.Create(WizardForm);
    info1IoBrokerLabel.Parent := summaryPage.Surface;
    info1IoBrokerLabel.Left := ScaleX(8);
    info1IoBrokerLabel.Top := info3NodeLabel.Top + info1NodeLabel.Height + ScaleY(12);
    info1IoBrokerLabel.Width := ScaleX(12);
    info1IoBrokerLabel.Height := ScaleY(12);
    info1IoBrokerLabel.Font.Style := [fsBold];
    
    info2IoBrokerLabel := TLabel.Create(WizardForm);
    info2IoBrokerLabel.Parent := summaryPage.Surface;
    info2IoBrokerLabel.Left := ScaleX(22);
    info2IoBrokerLabel.Top := info3NodeLabel.Top + info1NodeLabel.Height + ScaleY(12);
    info2IoBrokerLabel.Width := summaryPage.SurfaceWidth - ScaleX(22); 
    info2IoBrokerLabel.Height := ScaleY(12);


    info1IoBrokerRunLabel := TLabel.Create(WizardForm);
    info1IoBrokerRunLabel.Parent := summaryPage.Surface;
    info1IoBrokerRunLabel.Left := ScaleX(8);
    info1IoBrokerRunLabel.Top := info1IoBrokerLabel.Top + info1IoBrokerLabel.Height + ScaleY(4);
    info1IoBrokerRunLabel.Width := ScaleX(12);
    info1IoBrokerRunLabel.Height := ScaleY(12);
    info1IoBrokerRunLabel.Font.Style := [fsBold];
    
    info2IoBrokerRunLabel := TLabel.Create(WizardForm);
    info2IoBrokerRunLabel.Parent := summaryPage.Surface;
    info2IoBrokerRunLabel.Left := ScaleX(22);
    info2IoBrokerRunLabel.Top := info1IoBrokerLabel.Top + info1IoBrokerLabel.Height + ScaleY(4);
    info2IoBrokerRunLabel.Width := summaryPage.SurfaceWidth - ScaleX(22); 
    info2IoBrokerRunLabel.Height := ScaleY(12);

    
    info1Port9000Label := TLabel.Create(WizardForm);
    info1Port9000Label.Parent := summaryPage.Surface;
    info1Port9000Label.Left := ScaleX(8);
    info1Port9000Label.Top := info2IoBrokerRunLabel.Top + info2IoBrokerRunLabel.Height + ScaleY(12);
    info1Port9000Label.Width := ScaleX(12);
    info1Port9000Label.Height := ScaleY(12);
    info1Port9000Label.Font.Style := [fsBold];
    
    info2Port9000Label := TLabel.Create(WizardForm);
    info2Port9000Label.Parent := summaryPage.Surface;
    info2Port9000Label.Left := ScaleX(22);
    info2Port9000Label.Top := info2IoBrokerRunLabel.Top + info2IoBrokerRunLabel.Height + ScaleY(12);
    info2Port9000Label.Width := summaryPage.SurfaceWidth - ScaleX(22); 
    info2Port9000Label.Height := ScaleY(12);

    
    info1Port9001Label := TLabel.Create(WizardForm);
    info1Port9001Label.Parent := summaryPage.Surface;
    info1Port9001Label.Left := ScaleX(8);
    info1Port9001Label.Top := info1Port9000Label.Top + info1Port9000Label.Height + ScaleY(4);
    info1Port9001Label.Width := ScaleX(12);
    info1Port9001Label.Height := ScaleY(12);
    info1Port9001Label.Font.Style := [fsBold];
    
    info2Port9001Label := TLabel.Create(WizardForm);
    info2Port9001Label.Parent := summaryPage.Surface;
    info2Port9001Label.Left := ScaleX(22);
    info2Port9001Label.Top := info1Port9000Label.Top + info1Port9000Label.Height + ScaleY(4);
    info2Port9001Label.Width := summaryPage.SurfaceWidth - ScaleX(22); 
    info2Port9001Label.Height := ScaleY(12);

    
    info1Port8081Label := TLabel.Create(WizardForm);
    info1Port8081Label.Parent := summaryPage.Surface;
    info1Port8081Label.Left := ScaleX(8);
    info1Port8081Label.Top := info1Port9001Label.Top + info1Port9001Label.Height + ScaleY(4);
    info1Port8081Label.Width := ScaleX(12);
    info1Port8081Label.Height := ScaleY(12);
    info1Port8081Label.Font.Style := [fsBold];
    
    info2Port8081Label := TLabel.Create(WizardForm);
    info2Port8081Label.Parent := summaryPage.Surface;
    info2Port8081Label.Left := ScaleX(22);
    info2Port8081Label.Top := info1Port9001Label.Top + info1Port9001Label.Height + ScaleY(4);
    info2Port8081Label.Width := summaryPage.SurfaceWidth - ScaleX(22); 
    info2Port8081Label.Height := ScaleY(12);

    summaryLabel := TLabel.Create(WizardForm);
    summaryLabel.Parent := summaryPage.Surface; 
    summaryLabel.Top := info1Port8081Label.Top + info1Port8081Label.Height + ScaleY(10);
    summaryLabel.Width := summaryPage.SurfaceWidth - ScaleX(4); 
    summaryLabel.Height := ScaleY(80);
    summaryLabel.AutoSize := False;
    summaryLabel.Wordwrap := True;

    retryButton := TButton.Create(WizardForm);
    retryButton.Parent := summaryPage.Surface; 
    retryButton.Top := summaryLabel.Top + summaryLabel.Height + ScaleY(4);
    retryButton.Width := ScaleX(100);
    retryButton.Height := ScaleY(30);
    retryButton.Caption := CustomMessage('CheckAgain');
    retryButton.OnClick := @retryTestReady;


    installNodeCB := TCheckBox.Create(WizardForm);
    installNodeCB.Parent := optionsPage.Surface;
    installNodeCB.Left := ScaleX(8);
    installNodeCB.Top := ScaleY(2);
    installNodeCB.Width := ScaleX(12); 
    installNodeCB.Height := ScaleX(12);
    installNodeCB.OnClick := @updateNextOptionPage;

    installNodeLabel := TLabel.Create(WizardForm);
    installNodeLabel.Parent := optionsPage.Surface;
    installNodeLabel.Left := ScaleX(28);
    installNodeLabel.Top := ScaleY(2);
    installNodeLabel.Width := summaryPage.SurfaceWidth - ScaleX(22); 
    installNodeLabel.Height := ScaleY(16);

    installIoBrokerCB := TCheckBox.Create(WizardForm);
    installIoBrokerCB.Parent := optionsPage.Surface;
    installIoBrokerCB.Left := ScaleX(8);
    installIoBrokerCB.Top := installNodeCB.Top + installNodeCB.Height + ScaleY(10);
    installIoBrokerCB.Width := ScaleX(12); 
    installIoBrokerCB.Height := ScaleX(12);
    installIoBrokerCB.OnClick := @updateNextOptionPage;

    installIoBrokerLabel := TLabel.Create(WizardForm);
    installIoBrokerLabel.Parent := optionsPage.Surface;
    installIoBrokerLabel.Left := ScaleX(28);
    installIoBrokerLabel.Top := installNodeCB.Top + installNodeCB.Height + ScaleY(10);
    installIoBrokerLabel.Width := summaryPage.SurfaceWidth - ScaleX(22); 
    installIoBrokerLabel.Height := ScaleY(16);

    fixIoBrokerCB := TCheckBox.Create(WizardForm);
    fixIoBrokerCB.Parent := optionsPage.Surface;
    fixIoBrokerCB.Left := ScaleX(8);
    fixIoBrokerCB.Top := installIoBrokerLabel.Top + installIoBrokerLabel.Height + ScaleY(10);
    fixIoBrokerCB.Width := ScaleX(12); 
    fixIoBrokerCB.Height := ScaleX(12);
    fixIoBrokerCB.OnClick := @updateNextOptionPage;

    fixIoBrokerLabel := TLabel.Create(WizardForm);
    fixIoBrokerLabel.Parent := optionsPage.Surface;
    fixIoBrokerLabel.Left := ScaleX(28);
    fixIoBrokerLabel.Top := installIoBrokerLabel.Top + installIoBrokerLabel.Height + ScaleY(10);
    fixIoBrokerLabel.Width := summaryPage.SurfaceWidth - ScaleX(22); 
    fixIoBrokerLabel.Height := ScaleY(16);

    additionalHintsLabel := TLabel.Create(WizardForm);
    additionalHintsLabel.Parent := optionsPage.Surface; 
    additionalHintsLabel.Top := fixIoBrokerCB.Top + fixIoBrokerCB.Height + ScaleY(10);
    additionalHintsLabel.Width := summaryPage.SurfaceWidth - ScaleX(4); 
    additionalHintsLabel.Height := ScaleY(80);
    additionalHintsLabel.AutoSize := False;
    additionalHintsLabel.Wordwrap := True;

  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function NextButtonClick(CurPageID: Integer): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  
  if (CurPageID = wpSelectDir) or ((CurPageID = wpWelcome) and isUpgrade) then begin

    iobServiceName := 'iobroker.exe';
    iobServiceExists := False;

    if CurPageID = wpSelectDir then begin
      appInstPath := ExpandConstant('{app}');
    end;
    updateSummaryPage;
  end;

  if (summaryPage <> nil) and (CurPageID = summaryPage.ID) then begin
    updateOptionsPage;
  end;

  Result := True;
 end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure retryTestReady(sender: TObject);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  i: Integer;
  output: String;
begin
  if tryStopServiceAtNextRetry then begin
    progressPage.SetProgress(0,5);
    progressPage.SetText('ioBroker - Automate your life', CustomMessage('TryStopIoB'));
    progressPage.Show;
    output := execAndReturnOutput('sc stop ' + iobServiceName, False);
    Log('Stop Service: ' + output);
    // Wait to ensure ioBroker is really down
    for i := 0 to 20 do begin
      Sleep(500);
      progressPage.SetProgress(i,20);
    end;
    progressPage.Hide;
  end;

  updateSummaryPage;

  WizardForm.NextButton.Enabled := readyToInstall;
  WizardForm.Update;

end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure CurPageChanged(CurPageID: Integer);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  if (summaryPage <> nil) and (CurPageId = summaryPage.id) then begin
    Wizardform.NextButton.Enabled := readyToInstall;
  end;
end;


{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function downloadNodeJs: Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := False;
  if installNodeCB.Checked = True then begin
    try
      progressPage.SetProgress(0, 1);
      progressPage.SetText(CustomMessage('DownloadingNodejs'), Format(CustomMessage('DownloadingNodejsVersion'), [rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch]));
      progressPage.Show
      DownloadTemporaryFile(rcmdNodeDownloadPath, 'node.msi', '', @OnDownloadProgressNode);

      if (FileExists(ExpandConstant('{tmp}') + '\node.msi')) then begin
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

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function installNodeJs: Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  logText: AnsiString;
begin
  if installNodeCB.Checked then begin
    Result := False;
    try
      marqueePage.SetText(CustomMessage('InstallingNodejs'), Format(CustomMessage('InstallingNodejsVersion'), [rcmdNodeVersionMajor, rcmdNodeVersionMinor, rcmdNodeVersionPatch]));
      marqueePage.Show
      marqueePage.Animate
      Result := execAndStoreOutput('msiexec /qn /l* ' + getLogNameNodeJsInstall + ' /i ' + ExpandConstant('{tmp}') + '\node.msi', '');

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
function installioBroker: Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  cmd: String;
  LogName: String;
  info: String;
  output: String;
  iobServiceOK: Boolean;
  portInfo: String;
  i: Integer;
begin
  result := False;
  cmd := '';
  LogName := ''
  info := '';

  if installIoBrokerCB.Checked then begin
    if iobServiceExists then begin
      // Service exists, but ioBroker not installed. We remove the Service
      output := execAndReturnOutput('sc stop ' + iobServiceName, False);
      Log('Stop Service: ' + output);
      output := execAndReturnOutput('sc delete ' + iobServiceName, False);
      Log('Delete Service: ' + output);
    end;
    gatherInstNodeData;
    cmd := '"' + nodePath + '\npx" --yes @iobroker/install@latest';
    LogName := getLogNameIoBrokerInstall;
    info := CustomMessage('InstallingIoBroker');
  end
  else begin
    if fixIoBrokerCB.Checked then begin
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
      // ioBroker.bat makes trouble when calling npx@iobroker..., delete it
      // Don't panic, fix will restore it anyway, and install will install it anyway
      DeleteFile(appInstPath + '\iobroker.bat');
      if execAndStoreOutput(cmd , LogName) then begin
        if (FileExists(appInstPath + '\instDone')) then begin
          Log('ioBroker installation completed!');
          marqueePage.SetText(info, CustomMessage('WaitForService'));
          for i := 0 to 15 do begin
            Sleep(1000);
            iobServiceOK := isIobServiceRunning;
            if iobServiceOK then break;
          end;
          if iobServiceOK then begin
            Log('ioBroker service was started!');
            marqueePage.SetText(info, CustomMessage('WaitForAdmin'));
            for i := 0 to 1000 do begin
              portInfo := getPortInfo(8081);
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
          end
        end
        else begin
          Log('ioBroker installation did not run til the end!');
        end;
        Log('ioBroker installation was not executed due to unknown error!');
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
function nodeJsUpdateOnly: Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := (installIoBrokerCB.Checked = False) and (fixIoBrokerCB.Checked);
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure CurStepChanged(CurStep: TSetupStep);
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  output: String;
  cont: Boolean;
  decision: Integer;
  resultCode: Integer;
begin
  if CurStep = ssInstall then begin

    // Be sure that the path for the log files exists
    ForceDirectories(appInstPath + '\log');

    // Remove old log files and old semaphore file
    DeleteFile(getLogNameNodeJsInstall);
    DeleteFile(getLogNameIoBrokerInstall);
    DeleteFile(getLogNameIoBrokerFix);
    DeleteFile(appInstPath + '\instDone');

    cont := True;

    // Download Node.js
    if cont then begin
      if downloadNodeJs = False then begin
        // Download failed
        decision := MsgBox(CustomMessage('DownloadFailedNoNodeJs'), mbError, MB_OK or MB_SETFOREGROUND);
        cont := False;
      end;
    end;

    if cont then begin
      if installNodeJs = False then begin
        decision := MsgBox(CustomMessage('InstallationFailedNoNodeJs'), mbError, MB_OK or MB_SETFOREGROUND);
        Exec('notepad', getLogNameNodeJsInstall, '', SW_SHOWNORMAL, ewNoWait, resultCode);
        cont := False;
      end;
    end;

    if cont then begin
      if installioBroker = False then begin
        if installIoBrokerCB.Checked then begin
          decision := MsgBox(CustomMessage('InstallationFailedIoBroker'), mbError, MB_OK or MB_SETFOREGROUND);
          Exec('notepad', getLogNameIoBrokerInstall, '', SW_SHOWNORMAL, ewNoWait, resultCode);
        end
        else begin
          decision := MsgBox(CustomMessage('InstallationFailedIoBrokerFix'), mbError, MB_OK or MB_SETFOREGROUND);
          Exec('notepad', getLogNameIoBrokerFix, '', SW_SHOWNORMAL, ewNoWait, resultCode);
        end;
        cont := False;
      end;
    end;

    if cont then begin
      if nodeJsUpdateOnly then begin
        // In this case only Node.js was updated, restart ioBroker
        // After installation and fix the service is started anyway
        output := execAndReturnOutput('sc start ' + iobServiceName, False);
        Log('Start ioBroker service:' + output);
      end;
    end;

    if cont then begin
      installationSuccessful := True;
    end;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function success: Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := installationSuccessful;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := Result + 'Node.js:'
  if installNodeCB.checked then begin
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
      if installIoBrokerCB.checked then begin
        Result := Result + NewLine + NewLine + 'ioBroker Service:';
        Result := Result + NewLine + Space + Format(CustomMessage('SummaryIoBrokerServiceRemove'), [appInstPath]);
      end
    end
  end;


  Result := Result + NewLine + NewLine + 'ioBroker:';

  if installIoBrokerCB.checked then begin
    Result := Result + NewLine + Space + Format(CustomMessage('SummaryInstallIoBroker'), [appInstPath]);
    Result := Result + NewLine + Space + Format(CustomMessage('SummaryIoBrokerServiceCreate'), [appInstPath]);
  end
  else begin
    if iobversionMajor > 0 then begin
      Result := Result + NewLine + Space + Format(CustomMessage('SummaryKeepIoBroker'), [iobVersionMajor, iobVersionMinor, iobVersionPatch, appInstPath]);
    end
    else begin
      Result := Result + NewLine + Space + Format(CustomMessage('SummaryKeepIoBrokerProbably'), [appInstPath]);
    end
  end;

  if fixIoBrokerCB.checked then begin
    Result := Result + NewLine + Space + CustomMessage('SummaryExecuteFixer');
  end
  else begin
    Result := Result + NewLine + Space + CustomMessage('SummaryNotExecuteFixer');
  end;

  Result := Result + NewLine + Space + CustomMessage('SummaryStartioBroker');

end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
function ShouldSkipPage(PageID: Integer): Boolean;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
begin
  Result := False;
  if isUpgrade then begin
    if (PageID = wpLicense) or
       (PageID = wpSelectDir) then begin
      Result := true;
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
    Result := true;
  end;
end;

{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
procedure InitializeWizard;
{--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
var
  appId: String;
  appRegKey: String;
  licTxt: String;

begin
  // Display own welcome package
  WizardForm.WelcomeLabel2.Caption := CustomMessage('Intro');

  // Adapt Copyright date in license
  licTxt := WizardForm.LicenseMemo.Text;
  StringChangeEx(licTxt, '<now>', GetDateTimeString('yyyy', #0, #0), True);
  WizardForm.LicenseMemo.Text := licTxt;
  WizardForm.LicenseMemo.Font.Name := 'Courier New';


  // Check if ioBroker was already installed with this installer
  appId := '{#SetupSetting("AppId")}';
  appId := Copy(appId, 2, Length(appId) - 1);

  appRegKey := 'Software\Microsoft\Windows\CurrentVersion\Uninstall\' + appId + '_is1';
  log(appRegKey);
   
  if RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{97DA02F5-2E8C-4B96-BB42-61ED2BBF34DF}_is1' ) then begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE, appRegKey, 'Inno Setup: App Path', appInstPath);
    isUpgrade := True;
    Log('ioBroker already installed in '+appInstPath);
  end;

  createPages;

  progressPage := CreateOutputProgressPage('ioBroker - Automate your life', '');
  marqueePage := CreateOutputMarqueeProgressPage('ioBroker - Automate your life', '');
end;
