@echo off
set INCLUDE=C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\um;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\shared

set DCC=dcc32

if [%1] == [x64] set DCC=dcc64

del *.dll *.exe *.res

git rev-parse HEAD > commit.log

pp Common.pp
pp Manifest.pp
pp Su.pp
pp Sud.pp

del commit.log

rc su.g.rc
rc sud.g.rc

%DCC% Su.pas -NSSystem;Winapi;Vcl -q -u..\..\Projects\Lib
if %errorlevel% neq 0 exit /b 1

%DCC% Sud.pas -NSSystem;Winapi;Vcl -q -u..\..\Projects\Lib
if %errorlevel% neq 0 exit /b 1

if [%DCC%] == [dcc32] copy Su.exe ..\releases\Sudo\x86 & copy Sud.dll ..\releases\Sudo\x86
if [%DCC%] == [dcc64] copy Su.exe ..\releases\Sudo\x64 & copy Sud.dll ..\releases\Sudo\x64
