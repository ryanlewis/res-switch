# res-switch 🖥️

A lightweight Windows display resolution switcher with a WPF GUI. Quickly switch between common display resolutions (4K, 1080p, and 1280x1024) with a single click or keyboard shortcut.

## 💡 Motivation

I created this tool to solve a specific problem: when I need to use 1280x1024 resolution for certain games on my primary monitor, allowing the game to switch to that resolution causes all windows and applications on my secondary monitor to get offset and pushed off-screen. This tool provides a quick way to switch resolutions first without disrupting my multi-monitor setup.

## ⚠️ Disclaimer

**USE AT YOUR OWN RISK**: This software modifies your display settings. While it includes safety checks and tests resolution compatibility before applying changes, I am not responsible for any issues that may occur to your monitor, display settings, or computer system. All resolution changes can be reverted through Windows Display Settings if needed.

## ✨ Features

- **Simple Dark Theme GUI** - Simple, clean interface built with WPF
- **Quick Resolution Switching** - Switch between presets instantly:
  - 4K Ultra HD (3840 x 2160)
  - Full HD (1920 x 1080)
  - Gaming Mode (1280 x 1024)
- **Keyboard Shortcuts**:
  - Press `1` - Switch to 4K
  - Press `2` - Switch to 1080p
  - Press `3` - Switch to Gaming Mode
  - Press `ESC` - Close the application
- **Current Resolution Display** - Shows your current resolution and refresh rate

## 🚀 Quick Start (Remote Execution)

Run directly from PowerShell without downloading:

```powershell
iwr -useb https://raw.githubusercontent.com/ryanlewis/res-switch/main/res-switch.ps1 | iex
```

## 📦 Installation

### Method 1: Clone and Run

```bash
# Clone the repository
git clone https://github.com/ryanlewis/res-switch.git
cd res-switch

# Run via batch file (easiest)
.\res-switch.bat

# Or run directly with PowerShell
powershell.exe -ExecutionPolicy Bypass -File res-switch.ps1
```

### Method 2: Download Script Only

```powershell
# Download the script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ryanlewis/res-switch/main/res-switch.ps1" -OutFile "res-switch.ps1"

# Run it
powershell.exe -ExecutionPolicy Bypass -File res-switch.ps1
```

### Method 3: Create Desktop Shortcut

If you've cloned the repository, you can create a convenient desktop shortcut:

```bash
# Run the shortcut creator
.\create-shortcut.cmd
```

This creates a desktop shortcut with:
- Monitor icon
- Direct PowerShell execution (bypasses execution policy)
- Hidden console window for cleaner experience

## 🎮 Usage

1. Launch the application using any of the methods above
2. The GUI will display your current resolution at the top
3. Click on any resolution button to switch, or use keyboard shortcuts (1, 2, 3)
4. The active resolution is highlighted in blue
5. Status messages appear at the bottom for feedback
6. Press ESC or close the window to exit

## 🔧 Technical Details

### Architecture

The application uses:
- **PowerShell** as the scripting engine
- **WPF (Windows Presentation Framework)** for the GUI
- **P/Invoke** to call Windows Display APIs (`user32.dll`)
- **WMI** as the primary method for resolution detection with P/Invoke fallback

### How It Works

1. Queries current display settings using WMI (`Win32_VideoController`)
2. Uses `ChangeDisplaySettings` from `user32.dll` for resolution changes
3. Tests resolution compatibility with `CDS_TEST` flag before applying
4. Updates the registry to make changes persistent (`CDS_UPDATEREGISTRY`)

### File Structure

```
res-switch/
├── res-switch.ps1        # Main PowerShell script with WPF GUI
├── res-switch.bat        # Batch launcher (bypasses execution policy)
├── create-shortcut.cmd   # Creates desktop shortcut with icon
├── CLAUDE.md             # AI assistant instructions
└── README.md             # This file
```

## 💻 System Requirements

- **Windows 10/11** (Windows 7/8 may work but untested)
- **PowerShell 5.0** or higher (comes with Windows 10+)
- **.NET Framework 4.5** or higher (for WPF)

## 🛡️ Security

- The script uses Windows built-in APIs only
- No external dependencies or network requests (except for remote execution)
- Resolution changes are tested before applying to prevent display issues
- All changes are reversible through Windows Display Settings

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 🐛 Known Issues

- Some laptops may not support all resolutions depending on hardware
- Multiple monitor setups currently affect only the primary display
- Custom refresh rates are not yet supported (uses display default)

## 📝 TODO

- [ ] Add custom resolution input option
- [ ] Support for multiple monitors
- [ ] Remember user preferences
- [ ] Add more gaming-focused resolutions (1440p, ultrawide)
- [ ] System tray integration for quick access

## 👤 Author

**Ryan Lewis**

- GitHub: [@ryanlewis](https://github.com/ryanlewis)

## 🙏 Acknowledgments

- Built with PowerShell and WPF
- Uses Windows Display APIs for reliable resolution switching
- Inspired by the need for quick resolution changes during gaming sessions

---

⭐ Star this repository if you find it useful!