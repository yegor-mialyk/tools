procedure RunAsSystem(const Command: string; const CommandArgs: PChar);
begin
  if not AdjustPrivilege(SE_DEBUG_NAME) then
    Exit;

  var WLPid := GetProcessPid('winlogon.exe');

  if WLPid = 0 then
    Exit;

  var ProcessHandle: TAutoHandle := OpenProcess(PROCESS_QUERY_INFORMATION, False, WLPid);

  if not ProcessHandle.Valid then
  begin
    ErrorCode := GetLastError();
    Exit;
  end;

  var TokenHandle: TAutoHandle;

  if not OpenProcessToken(ProcessHandle, TOKEN_DUPLICATE or TOKEN_ASSIGN_PRIMARY or TOKEN_QUERY, TokenHandle.Ptr^) then
  begin
    ErrorCode := GetLastError();
    Exit;
  end;

  if not ImpersonateLoggedOnUser(TokenHandle) then
  begin
    ErrorCode := GetLastError();
    Exit;
  end;

  var DuplicatedTokenHandle: TAutoHandle;

  if not DuplicateTokenEx(tokenHandle, TOKEN_ADJUST_DEFAULT or TOKEN_ADJUST_SESSIONID or TOKEN_QUERY or
    TOKEN_DUPLICATE or TOKEN_ASSIGN_PRIMARY, NULL, SecurityImpersonation, TokenPrimary, DuplicatedTokenHandle.Ptr^) then
  begin
    ErrorCode := GetLastError();
    Exit;
  end;

  var SI: STARTUPINFO;
  var PI: PROCESS_INFORMATION;

  FillChar(PI, SizeOf(PROCESS_INFORMATION), 0);
  FillChar(SI, SizeOf(STARTUPINFO), 0);
  SI.cb := SizeOf(STARTUPINFO);
  SI.dwFlags := STARTF_USESHOWWINDOW;
  SI.wShowWindow := SW_HIDE;

  if not CreateProcessWithTokenW(DuplicatedTokenHandle, 0, NULL,
    PChar('"' + GetAppPath + SuApp + '" ' + GetSuCommandLine +
    ' ---- ' + ConsolePid + ' "' + Command + '" ' + CommandArgs), 0, NULL, Pointer(StartupDir), SI, PI) then
  begin
    ErrorCode := GetLastError();
    Exit;
  end;

  WaitForSingleObject(PI.hProcess, INFINITE);

  CloseHandle(PI.hThread);
  CloseHandle(PI.hProcess);
end;
