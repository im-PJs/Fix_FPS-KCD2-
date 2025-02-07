@echo off
setlocal EnableDelayedExpansion

:: ==================================================
:: Cutscene FPS Unlock - Version 1.1
:: Last Updated: 2/7/25
:: ==================================================

:: Define paths
set "PAK_FILE=Engine.pak"
set "CONFIG_FILE=Config\CVarOverrides\Cutscene.cfg"
set "TEMP_DIR=temp_extract"
set "NEW_ARCHIVE=Engine_new.pak"

echo.
echo *** Starting sys_MaxFPS Modification Process ***
echo.

:: Check that the archive exists
if not exist "%PAK_FILE%" (
    echo [Error] %PAK_FILE% not found in the current directory.
    pause
    goto end
)

:: Create a backup if needed
if not exist "Engine.pak.backup" (
    copy /Y "%PAK_FILE%" "Engine.pak.backup" >nul
    echo [Info] Backup created as Engine.pak.backup.
) else (
    echo [Info] Backup already exists.
)

echo.
echo [Info] Preparing temporary extraction directory...
:: Clean up any previous temporary folder
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"

echo [Info] Extracting archive...
:: Extract the archive using tar
tar -xf "%PAK_FILE%" -C "%TEMP_DIR%"
if errorlevel 1 (
    echo [Error] Extraction failed. The archive may not be a valid zip.
    pause
    goto cleanup
)

echo [Info] Verifying extracted files...
:: Verify extraction of the configuration file
if not exist "%TEMP_DIR%\%CONFIG_FILE%" (
    echo [Error] %CONFIG_FILE% not found in the archive.
    pause
    goto cleanup
)

echo [Info] Modifying configuration file...
:: Modify the configuration file (replace sys_MaxFPS=30 with sys_MaxFPS=0)
powershell -Command "(Get-Content '%TEMP_DIR%\%CONFIG_FILE%' -Raw) -replace 'sys_MaxFPS=30','sys_MaxFPS=0' | Set-Content '%TEMP_DIR%\%CONFIG_FILE%'" >nul

echo [Info] Recompressing archive...
:: Recompress the folder into a new archive without an extra directory layer
tar -cf "%NEW_ARCHIVE%" -C "%TEMP_DIR%" *
if errorlevel 1 (
    echo [Error] Failed to create new archive.
    pause
    goto cleanup
)

echo [Info] Replacing original archive...
:: Replace the original archive
move /Y "%NEW_ARCHIVE%" "%PAK_FILE%" >nul

echo.
echo *** Done! sys_MaxFPS is now set to 0. ***
pause

:cleanup
rd /s /q "%TEMP_DIR%" 2>nul
:end
endlocal
