//
// Seamless Sudo
//
// Copyright (C) 1995-2020, Yegor Mialyk. All Rights Reserved.
//
// Licensed under the MIT License. See the LICENSE file for details.
//

library Sud;

{$INCLUDE Compiler.pas}

{$R *.g.res}

uses
  Winapi.Windows,
  Winapi.ShellAPI,
  System.SysUtils,
  My.Lib;

procedure ExecuteW(hWnd: HWND; Instance: HINST; lpCmdLine: PChar; nCmdShow: Integer); stdcall;
begin
  if not AttachConsole(ATTACH_PARENT_PROCESS) then
  begin
    var code := GetLastError();
    AllocConsole();
    WriteLn('SU(d): Error attaching console: ' + SysErrorMessage(code));
    ReadLn;
    FreeConsole();
    Exit;
  end;

  var s: string;
  var Command := '';
  var StartupDir := '';

  var pCmd := lpCmdLine;
  if not GetParamStr(pCmd, s) or
    not GetParamStr(pCmd, StartupDir) or
    not GetParamStr(pCmd, Command) then
  begin
    WriteLn('SU(d): Error parsing commad line: ', lpCmdLine, '.');
    Exit;
  end;

  var NoWait := StrToBoolW(s);

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
    var code := GetLastError();
    WriteLn('SU(d): Cannot execute ''', Command, ''': ', SysErrorMessage(code));
    Exit;
  end;

  if not NoWait then
    WaitForSingleObject(SEI.hProcess, INFINITE);
end;

exports
  ExecuteW;

end.
