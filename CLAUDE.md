# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Windows display resolution switching utility built with PowerShell and WPF. It provides a graphical interface for quickly switching between common display resolutions (4K, 1080p, and 1280x1024).

## Architecture

The application consists of the main PowerShell GUI and supporting scripts:

1. **res-switch.ps1**: Main application - WPF GUI with P/Invoke calls to Windows Display APIs
2. **res-switch.bat**: Batch file launcher that runs PowerShell with Bypass execution policy
3. **create-shortcut.cmd**: Creates a desktop shortcut that launches the PowerShell script directly with appropriate settings and a monitor icon

## Key Technical Details

### Display Resolution Management
- Uses P/Invoke to call Windows user32.dll functions (ChangeDisplaySettings, EnumDisplaySettings)
- Primary method uses WMI (Win32_VideoController) with P/Invoke as fallback
- Tests resolution changes before applying them using CDS_TEST flag

### WPF GUI Implementation
- Dark theme with custom button styling
- Shows current resolution and refresh rate
- Highlights the currently active resolution button
- Keyboard shortcuts: 1 (4K), 2 (1080p), 3 (1280x1024), ESC (close)

### Resolution Presets
- 4K: 3840 x 2160
- 1080p: 1920 x 1080
- Gaming: 1280 x 1024

## Development Notes

### Running the Application
- Direct execution: `powershell.exe -ExecutionPolicy Bypass -File res-switch.ps1`
- Via batch file: Run `res-switch.bat`
- Via desktop shortcut: Run `create-shortcut.cmd` to create a desktop shortcut

### Testing Resolution Changes
The application uses the CDS_TEST flag to verify if a resolution is supported before attempting to apply it. This prevents invalid resolution changes that could leave the display in an unusable state.