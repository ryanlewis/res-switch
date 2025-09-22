# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Windows display resolution switching utility built with PowerShell and WPF. It provides a graphical interface for quickly switching between display resolutions. The application supports custom resolution configurations via PowerShell Data files (PSD1), allowing users to define their own resolution presets.

## Architecture

The application consists of the main PowerShell GUI and supporting scripts:

1. **res-switch.ps1**: Main application - WPF GUI with P/Invoke calls to Windows Display APIs, supports configuration via PSD1 files
2. **res-switch.psd1.example**: Example configuration file showing how to define custom resolutions
3. **res-switch.bat**: Batch file launcher that runs PowerShell with Bypass execution policy
4. **create-shortcut.cmd**: Creates a desktop shortcut that launches the PowerShell script directly with appropriate settings and a monitor icon

## Key Technical Details

### Display Resolution Management
- Uses P/Invoke to call Windows user32.dll functions (ChangeDisplaySettings, EnumDisplaySettings)
- Primary method uses WMI (Win32_VideoController) with P/Invoke as fallback
- Tests resolution changes before applying them using CDS_TEST flag

### WPF GUI Implementation
- Dark theme with custom button styling
- Dynamically generates UI based on configured resolutions
- Shows current resolution and refresh rate
- Highlights the currently active resolution button
- Keyboard shortcuts: 1-9 (for up to 9 resolutions), ESC (close)
- Window height adjusts automatically based on number of resolutions

### Configuration System
- Supports PowerShell Data files (.psd1) for safe configuration
- Configuration locations checked in order:
  1. Same directory as script: `res-switch.psd1`
  2. User profile: `%USERPROFILE%\.res-switch\res-switch.psd1`
  3. Built-in defaults if no config found
- Each resolution configuration includes:
  - Name: Display name for the button
  - Width: Horizontal resolution in pixels
  - Height: Vertical resolution in pixels
  - Shortcut: Optional keyboard shortcut (1-9)

### Default Resolution Presets
When no configuration file exists, these defaults are used:
- 4K Ultra HD: 3840 x 2160
- Full HD: 1920 x 1080
- Gaming Mode: 1280 x 1024

## Development Notes

### Running the Application
- Direct execution: `powershell.exe -ExecutionPolicy Bypass -File res-switch.ps1`
- Via batch file: Run `res-switch.bat`
- Via desktop shortcut: Run `create-shortcut.cmd` to create a desktop shortcut

### Testing Resolution Changes
The application uses the CDS_TEST flag to verify if a resolution is supported before attempting to apply it. This prevents invalid resolution changes that could leave the display in an unusable state.

### Creating Custom Configurations
To test with custom resolutions:
1. Copy `res-switch.psd1.example` to `res-switch.psd1`
2. Edit the PSD1 file to add/modify resolutions
3. Run the application - it will automatically load the configuration
4. The console output will indicate if configuration was loaded or if defaults are being used