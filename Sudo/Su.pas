//
// Seamless Sudo
//
// Copyright (C) 1995-2023, Yegor Mialyk. All Rights Reserved.
//
// Licensed under the MIT License. See the LICENSE file for details.
//

{$APPTYPE CONSOLE}

program Su;

{$INCLUDE Compiler.pas}

{$R *.g.res}

uses
  Winapi.Windows,
  Winapi.WinNt,
  Winapi.ShellAPI,
  System.SysUtils,
  My.Lib;

{$INCLUDE Common.g.pas}

{$SETPEFLAGS IMAGE_FILE_RELOCS_STRIPPED}

function CtrlHandlerRoutine(dwCtrlType: DWORD): BOOL; stdcall;
begin
  WriteLn(#13#10'SU: Program aborted.');
  Result := False;
end;

var
  NoWait: Boolean = False;
  QuietMode: Boolean = False;
  AsSystem: Boolean = False;
  StartupDir: string = '';
  ConsolePid: string = '';

function GetSuCommandLine: string;
begin
  Result := '';

  if NoWait then
    Result := '-n';

  if QuietMode then
    Result := Result + ' -q';

  if StartupDir <> '' then
    Result := Result + ' -d "' + StartupDir + '"';
end;

{$INCLUDE RunAsSystem.pas}

begin
  SetConsoleCtrlHandler(@CtrlHandlerRoutine, True);

  var s: string;

  var pCmd := GetCommandLine();

  GetParamStr(pCmd, s);

  var ShowHelp := False;
  var InvalidOption := '';
  var ViaCmd := False;
  var ViaPs := False;
  var ViaPs1 := False;

  StartupDir := GetCurrentDir;

  repeat
    if TestSwitch(pCmd, '?', 'help', ShowHelp) then
    else
    if TestSwitch(pCmd, 'q', 'quiet', QuietMode) then
    else
    if TestSwitch(pCmd, 'd', 'startup-dir', StartupDir) then
    else
    if TestSwitch(pCmd, 's', 'system', AsSystem) then
    else
    if TestSwitch(pCmd, 'n', 'no-wait', NoWait) then
    else
    if TestSwitch(pCmd, 'c', 'cmd', ViaCmd) then
    else
    if TestSwitch(pCmd, 'ps', 'ps', ViaPs) then
    else
    if TestSwitch(pCmd, 'ps1', 'ps1', ViaPs1) then
    else
    if TestSwitch(pCmd, '', '--', ConsolePid) then
      Break
    else
    begin
      IsSwitch(pCmd, InvalidOption);
      Break;
    end;
  until False;

  var Command: string := Trim(pCmd);

  if ConsolePid <> '' then
  begin
    FreeConsole();

    var pid := DWORD(My.Lib.StrToInt(ConsolePid));
    if ErrorCode <> 0 then
      pid := ATTACH_PARENT_PROCESS;

    if not AttachConsole(pid) then
    begin
      ErrorCode := GetLastError();
      ShowMessageW('Error attaching to console: ' + SysErrorMessage(ErrorCode), 'Seamless Sudo');
      Exit;
    end;

    if AsSystem then
    begin
      RunAsSystem(Command);

      if ErrorCode <> 0 then
        WriteLn('SU(admin): Cannot execute ''', Command, ''' as SYSTEM: ', SysErrorMessage(ErrorCode));

      Exit;
    end;

    if not GetParamStr(pCmd, Command) then
    begin
      WriteLn('SU(admin): Error parsing command line.');
      Exit;
    end;

    var SEI: SHELLEXECUTEINFO;
    FillChar(SEI, SizeOf(SHELLEXECUTEINFO), 0);
    SEI.cbSize := SizeOf(SHELLEXECUTEINFO);
    SEI.fMask := SEE_MASK_DOENVSUBST or SEE_MASK_FLAG_NO_UI or SEE_MASK_NOCLOSEPROCESS or
      SEE_MASK_NOASYNC or SEE_MASK_NO_CONSOLE;
    SEI.lpFile := Pointer(Command);
    SEI.lpDirectory := Pointer(StartupDir);
    SEI.lpParameters := pCmd;
    SEI.nShow := SW_SHOWNORMAL;

    if not ShellExecuteEx(@SEI) then
    begin
      ErrorCode := GetLastError();
      WriteLn('SU(admin): Cannot execute ''', Command, ''': ', SysErrorMessage(ErrorCode));
      Exit;
    end;

    if not NoWait then
      WaitForSingleObject(SEI.hProcess, INFINITE);

    Exit;
  end;

  if (Command = '') or ShowHelp then
  begin
    WriteLn('SU - ', APP_NAME, ', version ', VERSION_STRING,
      ' | https://github.com/yegor-mialyk/tools', CRLF, COPYRIGHT_STRING, CRLF);
  end;

  if InvalidOption <> '' then
  begin
    WriteLn('SU: Invalid argument: ', InvalidOption);
    ExitCode := 2;
    Exit;
  end;

  if ShowHelp then
  begin
    WriteLn('Description:'#13#10,
      '  Runs a command as the Administrator or the SYSTEM account.'#13#10,
      '  User Account Control (UAC) may prompt the user for consent to run the command elevated.'#13#10,
      CRLF,
      'Usage:'#13#10,
      '  SU [options] <command> [arguments]'#13#10,
      CRLF,
      'Options:'#13#10,
      '  -?, --help                     This screen.'#13#10,
      '  -d, --startup-dir <directory>  Specify a startup directory (default: the current directory).'#13#10,
      '  -n, --no-wait                  Do not wait for the command to finish.'#13#10,
      '  -s, --system                   Run as SYSTEM by cloning the access token of winlogon.exe.'#13#10,
      '  -q, --quiet                    Suppress all SU messages and banners (except errors).'#13#10,
      '  -c, --cmd                      Run a command using Command Prompt (cmd.exe).'#13#10,
      '  -ps, --ps                      Run a command using PowerShell Core (pwsh.exe).'#13#10,
      '  -ps1, --ps1                    Run a command using the old version of PowerShell (powershell.exe).'#13#10,
      CRLF,
      'Note: Environment variables are expanded in both command and startup directory.'#13#10);
    ExitCode := 1;
    Exit;
  end;

  if Command = '' then
  begin
    WriteLn('SU: No command specified. Try ''su -?'' or ''su --help'' for more information.');
    ExitCode := 1;
    Exit;
  end;

  var CommandLine := GetSuCommandLine;

  if AsSystem then
    CommandLine := CommandLine + ' -s';

  if not QuietMode then
  begin
    if AsSystem then
      Write('Executing (as SYSTEM): ')
    else
      Write('Executing (as Administrator): ');

    WriteLn(Command, CRLF);
  end;

  if ViaCmd then
    Command := 'cmd.exe /c ' + Command
  else
    if ViaPs or ViaPs1 then
    begin
      var buffer: AnsiString;

      SetLength(buffer, Length(Command) * SizeOf(Char));
      Move(Pointer(Command)^, Pointer(buffer)^, Length(buffer));

      var pwsh: string;

      if ViaPs1 then
        pwsh := SearchFilePath('powershell.exe')
      else
        pwsh := SearchFilePath('pwsh.exe');

      if pwsh = '' then
      begin
        WriteLn('SU: Cannot find PowerShell executable module: ',
          T.Iff<string>(ViaPs, 'pwsh.exe', 'powershell.exe'));
        ExitCode := 1;
        Exit;
      end;

      Command := '"' + pwsh + '" -EncodedCommand ' + StringToWideString(Base64Encode(buffer));
    end;

  var SEI: SHELLEXECUTEINFO;
  FillChar(SEI, SizeOf(SHELLEXECUTEINFO), 0);
  SEI.cbSize := SizeOf(SHELLEXECUTEINFO);
  SEI.fMask := SEE_MASK_DOENVSUBST or SEE_MASK_FLAG_NO_UI or SEE_MASK_NOCLOSEPROCESS or
    SEE_MASK_NOASYNC or SEE_MASK_NO_CONSOLE;
  SEI.lpVerb := 'runas';
  SEI.lpFile := Pointer(ParamStr(0));
  SEI.lpParameters := PChar(CommandLine + ' ---- ' + IntToStr(GetCurrentProcessId()) + ' ' + Command);
  SEI.nShow := SW_HIDE;

  if not ShellExecuteEx(@SEI) then
  begin
    ErrorCode := GetLastError();
    WriteLn('SU: Cannot execute sudo as Administrator: ', SysErrorMessage(ErrorCode));
    ExitCode := 2;
    Exit;
  end;

  WaitForSingleObject(SEI.hProcess, INFINITE);
end.
