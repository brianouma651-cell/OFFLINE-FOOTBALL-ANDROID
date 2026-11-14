@echo off
setlocal
set "PROJECT=%~dp0OFFLINE_FOOTBALL_GODOT"
set "GODOT_EXE=%GODOT_EXE%"
if not defined GODOT_EXE (
  for /f "delims=" %%G in ('where godot.exe 2^>nul') do if not defined GODOT_EXE set "GODOT_EXE=%%G"
)
if not defined GODOT_EXE (
  for /f "delims=" %%G in ('where godot4.exe 2^>nul') do if not defined GODOT_EXE set "GODOT_EXE=%%G"
)
if not defined GODOT_EXE (
  echo ERROR: Godot 4 executable not found.
  echo Install Godot 4.3 or later, then add godot.exe to PATH or set GODOT_EXE.
  pause
  exit /b 1
)
"%GODOT_EXE%" --editor --path "%PROJECT%"
