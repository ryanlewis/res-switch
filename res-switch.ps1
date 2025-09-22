# Resolution Switcher with WPF GUI
# Supports custom resolutions via configuration file

Add-Type -AssemblyName PresentationFramework

# Default configuration (used when no config file exists)
$defaultConfig = @{
    Resolutions = @(
        @{
            Name = "4K Ultra HD"
            Width = 3840
            Height = 2160
            Shortcut = "1"
        },
        @{
            Name = "Full HD"
            Width = 1920
            Height = 1080
            Shortcut = "2"
        },
        @{
            Name = "Gaming Mode"
            Width = 1280
            Height = 1024
            Shortcut = "3"
        }
    )
}

# Function to load configuration
function Get-Configuration {
    $configLocations = @(
        (Join-Path $PSScriptRoot "res-switch.psd1"),
        (Join-Path $env:USERPROFILE ".res-switch\res-switch.psd1")
    )

    foreach ($configPath in $configLocations) {
        if (Test-Path $configPath) {
            try {
                Write-Host "Loading configuration from: $configPath" -ForegroundColor Green
                $config = Import-PowerShellDataFile -Path $configPath

                # Validate configuration
                if (-not $config.Resolutions -or $config.Resolutions.Count -eq 0) {
                    Write-Warning "Invalid configuration: No resolutions defined. Using defaults."
                    return $defaultConfig
                }

                # Validate each resolution
                foreach ($res in $config.Resolutions) {
                    if (-not $res.Name -or -not $res.Width -or -not $res.Height) {
                        Write-Warning "Invalid resolution entry found. Using defaults."
                        return $defaultConfig
                    }
                    if ($res.Width -le 0 -or $res.Height -le 0) {
                        Write-Warning "Invalid resolution dimensions. Using defaults."
                        return $defaultConfig
                    }
                }

                return $config
            }
            catch {
                Write-Warning "Error loading configuration file: $_"
                Write-Warning "Using default configuration."
                return $defaultConfig
            }
        }
    }

    Write-Host "No configuration file found. Using default resolutions." -ForegroundColor Yellow
    return $defaultConfig
}

# Load configuration
$config = Get-Configuration
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class DisplaySettings {
    [DllImport("user32.dll")]
    public static extern int ChangeDisplaySettings(ref DEVMODE devMode, int flags);
    
    [DllImport("user32.dll")]
    public static extern int EnumDisplaySettings(string deviceName, int modeNum, ref DEVMODE devMode);
    
    public const int ENUM_CURRENT_SETTINGS = -1;
    public const int CDS_UPDATEREGISTRY = 0x01;
    public const int CDS_TEST = 0x02;
    public const int DISP_CHANGE_SUCCESSFUL = 0;
    public const int DISP_CHANGE_RESTART = 1;
    public const int DISP_CHANGE_FAILED = -1;
    
    [StructLayout(LayoutKind.Sequential)]
    public struct DEVMODE {
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        public string dmDeviceName;
        public short dmSpecVersion;
        public short dmDriverVersion;
        public short dmSize;
        public short dmDriverExtra;
        public int dmFields;
        public int dmPositionX;
        public int dmPositionY;
        public int dmDisplayOrientation;
        public int dmDisplayFixedOutput;
        public short dmColor;
        public short dmDuplex;
        public short dmYResolution;
        public short dmTTOption;
        public short dmCollate;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        public string dmFormName;
        public short dmLogPixels;
        public int dmBitsPerPel;
        public int dmPelsWidth;
        public int dmPelsHeight;
        public int dmDisplayFlags;
        public int dmDisplayFrequency;
    }
}
"@

# Function to generate XAML dynamically based on configuration
function Get-DynamicXaml {
    param($config)

    # Calculate window height based on number of resolutions
    $buttonCount = $config.Resolutions.Count
    $windowHeight = [Math]::Min(180 + ($buttonCount * 55), 600)  # Cap at 600px
    $windowWidth = if ($config.WindowWidth) { $config.WindowWidth } else { 400 }

    # Build button XAML for each resolution
    $buttonXaml = ""
    for ($i = 0; $i -lt $config.Resolutions.Count; $i++) {
        $res = $config.Resolutions[$i]
        $buttonXaml += @"
            <Button Name="ResBtn$i"
                    Width="200"
                    Height="45"
                    Tag="$($res.Width)x$($res.Height)">
                <StackPanel HorizontalAlignment="Center">
                    <TextBlock Text="$($res.Name)" FontWeight="Bold" TextAlignment="Center"/>
                    <TextBlock Text="$($res.Width) x $($res.Height)" FontSize="11" Foreground="#b0b0b0" TextAlignment="Center"/>
                </StackPanel>
            </Button>
"@
    }

    # Generate complete XAML
    [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Resolution Switcher"
        Height="$windowHeight" Width="$windowWidth"
        ResizeMode="CanMinimize"
        WindowStartupLocation="CenterScreen"
        Background="#1e1e1e">
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Background" Value="#2d2d30"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderBrush" Value="#3e3e42"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Padding" Value="10,5"/>
            <Setter Property="Margin" Value="5"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="4">
                            <ContentPresenter HorizontalAlignment="Center"
                                            VerticalAlignment="Center"
                                            Margin="{TemplateBinding Padding}"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#3e3e42"/>
                </Trigger>
                <Trigger Property="IsPressed" Value="True">
                    <Setter Property="Background" Value="#007acc"/>
                </Trigger>
            </Style.Triggers>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Title Section -->
        <Border Grid.Row="0" Background="#007acc" Padding="15">
            <StackPanel>
                <TextBlock Text="Resolution Switcher"
                          FontSize="20"
                          FontWeight="Bold"
                          Foreground="White"
                          HorizontalAlignment="Center"/>
                <TextBlock Name="CurrentResText"
                          Text="Current: Loading..."
                          FontSize="12"
                          Foreground="#e0e0e0"
                          HorizontalAlignment="Center"
                          Margin="0,5,0,0"/>
            </StackPanel>
        </Border>

        <!-- Button Section -->
        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
            <StackPanel Name="ButtonPanel"
                        VerticalAlignment="Center"
                        HorizontalAlignment="Center">
                $buttonXaml
            </StackPanel>
        </ScrollViewer>

        <!-- Status Bar -->
        <Border Grid.Row="2" Background="#2d2d30" Padding="10,5">
            <TextBlock Name="StatusText"
                      Text="Select a resolution to switch"
                      FontSize="11"
                      Foreground="#b0b0b0"
                      HorizontalAlignment="Center"/>
        </Border>
    </Grid>
</Window>
"@

    return $xaml
}

# Generate XAML based on configuration
$xaml = Get-DynamicXaml -config $config

# Create Window
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Get controls
$currentResText = $window.FindName("CurrentResText")
$statusText = $window.FindName("StatusText")

# Get dynamically created resolution buttons
$resolutionButtons = @()
for ($i = 0; $i -lt $config.Resolutions.Count; $i++) {
    $btn = $window.FindName("ResBtn$i")
    if ($btn) {
        $resolutionButtons += @{
            Button = $btn
            Resolution = $config.Resolutions[$i]
        }
    }
}

# Function to get current resolution
function Get-CurrentResolution {
    try {
        # Use WMI to get current resolution (more reliable)
        $videoController = Get-CimInstance -Class Win32_VideoController | Where-Object { $_.CurrentHorizontalResolution -ne $null } | Select-Object -First 1
        if ($videoController) {
            return @{
                Width = $videoController.CurrentHorizontalResolution
                Height = $videoController.CurrentVerticalResolution
                Frequency = if ($videoController.CurrentRefreshRate) { $videoController.CurrentRefreshRate } else { 60 }
            }
        }
    } catch {
        # Fallback to P/Invoke method
        try {
            $devMode = New-Object DisplaySettings+DEVMODE
            $devMode.dmSize = [System.Runtime.InteropServices.Marshal]::SizeOf($devMode)

            $result = [DisplaySettings]::EnumDisplaySettings($null, [DisplaySettings]::ENUM_CURRENT_SETTINGS, [ref]$devMode)

            if ($result) {
                return @{
                    Width = $devMode.dmPelsWidth
                    Height = $devMode.dmPelsHeight
                    Frequency = $devMode.dmDisplayFrequency
                }
            }
        } catch {}
    }
    return $null
}

# Function to change resolution
function Set-Resolution {
    param(
        [int]$Width,
        [int]$Height,
        [string]$DisplayName
    )
    
    try {
        $devMode = New-Object DisplaySettings+DEVMODE
        $devMode.dmSize = [System.Runtime.InteropServices.Marshal]::SizeOf($devMode)
        
        # Get current settings first to preserve other values
        [DisplaySettings]::EnumDisplaySettings($null, [DisplaySettings]::ENUM_CURRENT_SETTINGS, [ref]$devMode)
        
        # Update resolution
        $devMode.dmPelsWidth = $Width
        $devMode.dmPelsHeight = $Height
        $devMode.dmFields = 0x00080000 -bor 0x00100000  # DM_PELSWIDTH | DM_PELSHEIGHT
        
        # Test the change first
        $testResult = [DisplaySettings]::ChangeDisplaySettings([ref]$devMode, [DisplaySettings]::CDS_TEST)
        
        if ($testResult -eq [DisplaySettings]::DISP_CHANGE_SUCCESSFUL) {
            # Apply the change
            $result = [DisplaySettings]::ChangeDisplaySettings([ref]$devMode, [DisplaySettings]::CDS_UPDATEREGISTRY)
            
            switch ($result) {
                ([DisplaySettings]::DISP_CHANGE_SUCCESSFUL) {
                    $statusText.Text = "Successfully changed to $DisplayName"
                    $statusText.Foreground = "#90EE90"
                    Update-CurrentResolution
                    return $true
                }
                ([DisplaySettings]::DISP_CHANGE_RESTART) {
                    $statusText.Text = "Restart required for $DisplayName"
                    $statusText.Foreground = "#FFD700"
                    return $false
                }
                default {
                    $statusText.Text = "Failed to change to $DisplayName"
                    $statusText.Foreground = "#FF6B6B"
                    return $false
                }
            }
        } else {
            $statusText.Text = "$DisplayName not supported by display"
            $statusText.Foreground = "#FF6B6B"
            return $false
        }
    } catch {
        $statusText.Text = "Error: $($_.Exception.Message)"
        $statusText.Foreground = "#FF6B6B"
        return $false
    }
}

# Function to update current resolution display
function Update-CurrentResolution {
    $current = Get-CurrentResolution
    if ($current) {
        $currentResText.Text = "Current: $($current.Width) x $($current.Height) @ $($current.Frequency)Hz"

        # Highlight active resolution button
        foreach ($item in $resolutionButtons) {
            $isActive = ($current.Width -eq $item.Resolution.Width -and $current.Height -eq $item.Resolution.Height)
            $item.Button.Background = if ($isActive) { "#007acc" } else { "#2d2d30" }
        }
    }
}

# Initial resolution check
Update-CurrentResolution

# Setup button click events dynamically
foreach ($item in $resolutionButtons) {
    $resolution = $item.Resolution
    $button = $item.Button

    # Create script block with proper variable binding
    $clickHandler = [scriptblock]::Create(@"
        `$statusText.Text = 'Switching to $($resolution.Name)...'
        `$statusText.Foreground = '#b0b0b0'
        Set-Resolution -Width $($resolution.Width) -Height $($resolution.Height) -DisplayName '$($resolution.Name) ($($resolution.Width)x$($resolution.Height))'
"@)

    $button.Add_Click($clickHandler)
}

# Add keyboard shortcuts
$window.Add_KeyDown({
    param($sender, $e)

    # Handle number keys for resolution shortcuts
    $keyMap = @{
        'D1' = 0; 'D2' = 1; 'D3' = 2; 'D4' = 3; 'D5' = 4
        'D6' = 5; 'D7' = 6; 'D8' = 7; 'D9' = 8
        'NumPad1' = 0; 'NumPad2' = 1; 'NumPad3' = 2; 'NumPad4' = 3; 'NumPad5' = 4
        'NumPad6' = 5; 'NumPad7' = 6; 'NumPad8' = 7; 'NumPad9' = 8
    }

    if ($keyMap.ContainsKey($e.Key.ToString())) {
        $index = $keyMap[$e.Key.ToString()]
        if ($index -lt $resolutionButtons.Count) {
            $resolutionButtons[$index].Button.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent)))
        }
    }

    # Escape to close
    if ($e.Key -eq 'Escape') {
        $window.Close()
    }
})

# Show window
$window.ShowDialog() | Out-Null
