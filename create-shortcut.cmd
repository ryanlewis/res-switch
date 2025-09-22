@echo off
title Resolution Switcher - Create Desktop Shortcut
color 0A

echo.
echo Creating Desktop Shortcut for Resolution Switcher...
echo.

REM Get paths
set "desktop=%USERPROFILE%\Desktop"
set "scriptDir=%~dp0"
cd /d "%scriptDir%"

REM Create temporary PowerShell script with full paths
echo $WshShell = New-Object -ComObject WScript.Shell > "%scriptDir%temp_shortcut.ps1"
echo $desktop = [Environment]::GetFolderPath('Desktop') >> "%scriptDir%temp_shortcut.ps1"
echo $shortcut = $WshShell.CreateShortcut("$desktop\Resolution Switcher.lnk") >> "%scriptDir%temp_shortcut.ps1"
echo $shortcut.TargetPath = "powershell.exe" >> "%scriptDir%temp_shortcut.ps1"
echo $shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"%scriptDir%res-switch.ps1`"" >> "%scriptDir%temp_shortcut.ps1"
echo $shortcut.WorkingDirectory = "%scriptDir:~0,-1%" >> "%scriptDir%temp_shortcut.ps1"
echo $shortcut.IconLocation = "shell32.dll,15" >> "%scriptDir%temp_shortcut.ps1"
echo $shortcut.Description = "Quick resolution switcher for gaming" >> "%scriptDir%temp_shortcut.ps1"
echo $shortcut.WindowStyle = 7 >> "%scriptDir%temp_shortcut.ps1"
echo $shortcut.Save() >> "%scriptDir%temp_shortcut.ps1"

REM Run the PowerShell script
powershell -NoProfile -ExecutionPolicy Bypass -File "%scriptDir%temp_shortcut.ps1"

if %errorlevel% == 0 (
    echo [SUCCESS] Desktop shortcut created successfully!
    echo.
    echo Shortcut Details:
    echo   Location: %desktop%\Resolution Switcher.lnk
    echo   Target: PowerShell script (res-switch.ps1)
    echo.
    echo Keyboard shortcuts in the app:
    echo   Press 1 - Switch to 4K
    echo   Press 2 - Switch to 1080p
    echo   Press 3 - Switch to Gaming Mode [1280x1024]
    echo   Press ESC - Close the switcher
) else (
    echo [ERROR] Failed to create shortcut
)

REM Clean up temporary file
del "%scriptDir%temp_shortcut.ps1" 2>nul

echo.
pause