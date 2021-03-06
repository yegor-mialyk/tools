//
// Seamless Sudo
//
// Copyright (C) 1995-2020, Yegor Mialyk. All Rights Reserved.
//
// Licensed under the MIT License. See the LICENSE file for details.
//

{$APPTYPE CONSOLE}

program Su;

{$INCLUDE Compiler.pas}

{$R *.g.res}

uses
  Winapi.Windows,
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

begin
  SetConsoleCtrlHandler(@CtrlHandlerRoutine, True);

  var s: string;

  var pCmd := GetCommandLine();
  GetParamStr(pCmd, s);

  var ShowHelp := False;
  var QuietMode := False;
  var NoWait := False;
  var InvalidOption := '';
  var Command := '';

  var StartupDir := GetCurrentDir;

  repeat
    if TestSwitch(pCmd, '?', 'help', ShowHelp) then
    else
    if TestSwitch(pCmd, 'q', 'quiet', QuietMode) then
    else
    if TestSwitch(pCmd, 'd', 'startup-dir', StartupDir) then
    else
    if TestSwitch(pCmd, 'n', 'no-wait', NoWait) then
    else
    if IsSwitch(pCmd, InvalidOption) or
      not GetParamStr(pCmd, Command) or (Command <> '') then
      Break;
  until False;

  if (Command = '') or ShowHelp then
  begin
    WriteLn('SU - ', APP_NAME, ', version ', VERSION_STRING,
      ' | https://github.com/yegor-mialyk/tools', CRLF,
      COPYRIGHT_STRING, CRLF);
  end;

  if InvalidOption <> '' then
  begin
    WriteLn('SU: Invalid option: ', InvalidOption);
    ExitCode := 2;
    Exit;
  end;

  if ShowHelp then
  begin
    WriteLn('Description:'#13#10,
      '  Runs a command as administrator.'#13#10,
      '  User Account Control (UAC) may prompt the user for consent to run the command elevated.'#13#10,
      CRLF,
      'Usage:'#13#10,
      '  SU [options] <command> [arguments]'#13#10,
      CRLF,
      'Options:'#13#10,
      '  -?, --help                     This screen.'#13#10,
      '  -d, --startup-dir <directory>  Specify a startup directory (default: the current directory).'#13#10,
      '  -n, --no-wait                  Do not wait for the command to finish.'#13#10,
      '  -q, --quiet                    Suppress all SU messages and banners (except errors).'#13#10,
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

  var CommandArgs: string := pCmd;

  if not QuietMode then
    WriteLn('Executing: ', Command, CommandArgs, CRLF);

  var SEI: SHELLEXECUTEINFO;
  FillChar(SEI, SizeOf(SHELLEXECUTEINFO), 0);
  SEI.cbSize := SizeOf(SHELLEXECUTEINFO);
  SEI.fMask := SEE_MASK_DOENVSUBST or SEE_MASK_FLAG_NO_UI or SEE_MASK_NOCLOSEPROCESS or
    SEE_MASK_NOASYNC or SEE_MASK_NO_CONSOLE;
  SEI.lpVerb := 'runas';
  SEI.lpFile := 'rundll32.exe';
  SEI.lpParameters := PChar('"' + GetAppPath + 'sud.dll",Execute ' + BoolToStrW(NoWait) +
    ' "' + StartupDir + '" "' + Command + '" ' + CommandArgs);
  SEI.nShow := SW_SHOWNORMAL;

  if not ShellExecuteEx(@SEI) then
  begin
    var code := GetLastError();
    WriteLn('SU: Cannot execute sudo demon (sud.dll): ', SysErrorMessage(code));
    ExitCode := 2;
    Exit;
  end;

  WaitForSingleObject(SEI.hProcess, INFINITE);
end.
