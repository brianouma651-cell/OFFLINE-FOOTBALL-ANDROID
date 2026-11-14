@echo off
setlocal
set "ROOT=%~dp0"
if not exist "%ROOT%\project.godot" (
  echo ERROR: Could not find project.godot beside this script.
  pause
  exit /b 1
)
where py >nul 2>nul
if %errorlevel%==0 (
  set "PY=py -3"
) else (
  where python >nul 2>nul
  if errorlevel 1 (
    echo ERROR: Python 3 is required for source regression tests.
    pause
    exit /b 1
  )
  set "PY=python"
)
echo Running all bundled source regression tests...
for %%F in ("%ROOT%\tests_stage*.py") do (
  echo.
  echo === %%~nxF ===
  %PY% "%%~fF"
  if errorlevel 1 (
    echo FAILED: %%~nxF
    pause
    exit /b 1
  )
)
echo.
echo ALL SOURCE REGRESSION TESTS PASSED.
echo NOTE: These tests do not replace Godot runtime or Android phone testing.
pause
exit /b 0
