@echo off
setlocal EnableDelayedExpansion

:: Define variables
set "PAK_FILE=Engine.pak"
set "CONFIG_FILE=Config/CVarOverrides/Cutscene.cfg"
set "BACKUP_FILE=Engine.pak.backup"

echo --------------------------------------------
echo  Cutscene FPS Unlock (Fully Automatic)
echo  Version 1.2 - 2/7/25
echo --------------------------------------------

:: Check that the archive exists
if not exist "%PAK_FILE%" (
    echo [ERROR] Engine.pak not found.
    echo Make sure this file exists in the same folder as this script.
    goto end
)

:: Create a backup if needed
if not exist "%BACKUP_FILE%" (
    copy /Y "%PAK_FILE%" "%BACKUP_FILE%" >nul
    echo [INFO] Backup created: %BACKUP_FILE%
    echo If anything goes wrong, you can restore it by running:
    echo.
    echo     copy /Y "%BACKUP_FILE%" "%PAK_FILE%"
    echo.
) else (
    echo [WARNING] Backup already exists. If you need to restore it, run:
    echo.
    echo     copy /Y "%BACKUP_FILE%" "%PAK_FILE%"
    echo.
)

echo [INFO] Updating FPS settings...
echo.

:: Run PowerShell to display the current snippet, update the file, then display the updated snippet.
powershell -NoProfile -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; $zip=[System.IO.Compression.ZipFile]::Open('%PAK_FILE%','Update'); $entry=$zip.GetEntry('%CONFIG_FILE%'); if($entry -eq $null){ Write-Error 'Entry not found'; exit 1 } else { $reader=New-Object System.IO.StreamReader($entry.Open()); $content=$reader.ReadToEnd(); $reader.Close(); Write-Host ''; Write-Host '----- Current file snippet -----' -ForegroundColor Yellow; $lines=$content -split \"`r?`n\"; $match=($lines | Select-String -Pattern 'sys_MaxFPS=30' | Select-Object -First 1); if($match){ $idx=$match.LineNumber - 1 } else { $idx=0 }; $start=[Math]::Max(0, $idx-4); $end=[Math]::Min($lines.Length-1, $idx+4); $lines[$start..$end] | ForEach-Object { Write-Host $_ -ForegroundColor White }; Write-Host '--------------------------------' -ForegroundColor Yellow; $newContent=$content -replace 'sys_MaxFPS=30','sys_MaxFPS=0'; $entry.Delete(); $newEntry=$zip.CreateEntry('%CONFIG_FILE%'); $writer=New-Object System.IO.StreamWriter($newEntry.Open()); $writer.Write($newContent); $writer.Close(); Write-Host ''; Write-Host '----- Updated file snippet -----' -ForegroundColor Green; $newLines=$newContent -split \"`r?`n\"; $match2=($newLines | Select-String -Pattern 'sys_MaxFPS=0' | Select-Object -First 1); if($match2){ $idx2=$match2.LineNumber - 1 } else { $idx2=0 }; $start2=[Math]::Max(0, $idx2-4); $end2=[Math]::Min($newLines.Length-1, $idx2+4); $newLines[$start2..$end2] | ForEach-Object { Write-Host $_ -ForegroundColor White }; Write-Host '--------------------------------' -ForegroundColor Green } $zip.Dispose();"

if %ERRORLEVEL%==0 (
    echo.
    echo Done! sys_MaxFPS is now set to 0. Feel free to delete the .bat file or keep it, your choice
) else (
    echo.
    echo Update failed.
)

:end
echo.
echo --------------------------------------------
echo Done! You can now close this window.
pause
echo --------------------------------------------
endlocal
