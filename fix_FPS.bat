@echo off
setlocal EnableDelayedExpansion

:: Define paths (assumes the script is in the Engine folder)
set "PAK_FILE=Engine.pak"
set "CONFIG_FILE=Config\CVarOverrides\Cutscene.cfg"
set "TEMP_DIR=temp_extract"
set "SEVEN_ZIP_PATH=%ProgramFiles%\7-Zip\7z.exe"
set "FULL_PAK=%CD%\%PAK_FILE%"

:: Check for required files
if not exist "%PAK_FILE%" (
    echo Error: %PAK_FILE% not found.
    goto end
)
if not exist "%SEVEN_ZIP_PATH%" (
    echo Error: 7-Zip not found.
    goto end
)

:: Create a backup of Engine.pak if it doesn't already exist
if not exist "Engine.pak.backup" (
    copy /Y "%PAK_FILE%" "Engine.pak.backup" >nul
    REM Backup created as Engine.pak.backup.
) else (
    REM Backup already exists as Engine.pak.backup.
)

:: Create temporary folder if it doesn't exist
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

:: Extract the configuration file (preserving folder structure)
"%SEVEN_ZIP_PATH%" x "%PAK_FILE%" "%CONFIG_FILE%" -o"%TEMP_DIR%" -y >nul
if not exist "%TEMP_DIR%\%CONFIG_FILE%" (
    echo Error: Extraction failed.
    goto cleanup
)

:: Replace "sys_MaxFPS=30" with "sys_MaxFPS=0" using PowerShell (preserves formatting)
powershell -Command "(Get-Content '%TEMP_DIR%\%CONFIG_FILE%' -Raw) -replace 'sys_MaxFPS=30','sys_MaxFPS=0' | Set-Content '%TEMP_DIR%\%CONFIG_FILE%'"

:: Delete the old file from the archive
"%SEVEN_ZIP_PATH%" d "%FULL_PAK%" "%CONFIG_FILE%" >nul
if errorlevel 1 (
    echo.
    echo ERROR: The file is being used by another process.
    echo Please close any open archive or Explorer windows locking the file and run the program again.
    goto cleanup
)

:: Add the modified file back into the archive (preserving its internal folder structure)
pushd "%TEMP_DIR%"
"%SEVEN_ZIP_PATH%" a "%FULL_PAK%" "%CONFIG_FILE%" >nul
if errorlevel 1 (
    echo.
    echo ERROR: The file is being used by another process.
    echo Please close any open archive or Explorer windows locking the file and run the program again.
    popd
    goto cleanup
)
popd

echo.
echo Done! sys_MaxFPS is now set to 0 with the original formatting preserved.

:cleanup
rd /s /q "%TEMP_DIR%" 2>nul
:end
endlocal
