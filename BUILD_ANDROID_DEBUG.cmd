@echo off
setlocal
set "PROJECT=%~dp0"
set "APK=%PROJECT%\build\OfflineFootball-debug.apk"
set "GODOT_EXE=%GODOT_EXE%"
if not defined GODOT_EXE (
  for /f "delims=" %%G in ('where godot.exe 2^>nul') do if not defined GODOT_EXE set "GODOT_EXE=%%G"
)
if not defined GODOT_EXE (
  for /f "delims=" %%G in ('where godot4.exe 2^>nul') do if not defined GODOT_EXE set "GODOT_EXE=%%G"
)
if not defined GODOT_EXE (
  echo ERROR: Godot 4 executable not found. Install Godot 4.3+ and add it to PATH.
  pause
  exit /b 1
)
if not exist "%PROJECT%\export_presets.cfg" (
  echo ERROR: Android export preset is missing.
  pause
  exit /b 1
)
if not defined ANDROID_HOME if not defined ANDROID_SDK_ROOT (
  echo WARNING: ANDROID_HOME and ANDROID_SDK_ROOT are not set.
  echo Configure the Android SDK path in Godot Editor Settings before exporting.
)
if not defined JAVA_HOME (
  echo WARNING: JAVA_HOME is not set. Godot may still find a configured JDK.
  echo Configure the Java SDK path in Godot Editor Settings if export fails.
)
if not exist "%PROJECT%\build" mkdir "%PROJECT%\build"
echo Step 1/3: Importing project resources and checking project load...
"%GODOT_EXE%" --headless --editor --path "%PROJECT%" --quit
if errorlevel 1 (
  echo ERROR: Godot project import or parse check failed.
  pause
  exit /b 1
)
echo Step 2/3: Running a short headless scene startup check...
"%GODOT_EXE%" --headless --path "%PROJECT%" --quit-after 5
if errorlevel 1 (
  echo ERROR: Game startup check failed. Review Godot output above.
  pause
  exit /b 1
)
echo Step 3/3: Exporting Android debug APK...
"%GODOT_EXE%" --headless --path "%PROJECT%" --export-debug "Android" "%APK%"
if errorlevel 1 (
  echo ERROR: Android export failed.
  echo Check Android SDK/JDK paths, matching export templates, and Godot Android build tools.
  pause
  exit /b 1
)
if not exist "%APK%" (
  echo ERROR: Godot returned without creating the expected APK.
  pause
  exit /b 1
)
echo.
echo APK CREATED: %APK%
echo Install it on your Android phone and test offline before considering it a release.
pause
exit /b 0
