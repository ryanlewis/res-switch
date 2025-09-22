# Resolution Switcher with WPF GUI
# Allows quick switching between 4K, 1080p, and 1280x1024 resolutions

Add-Type -AssemblyName PresentationFramework
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

# WPF Window XAML
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Resolution Switcher" 
        Height="320" Width="400"
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
        <StackPanel Grid.Row="1" 
                    VerticalAlignment="Center" 
                    HorizontalAlignment="Center">
            
            <Button Name="Btn4K" 
                    Width="200" 
                    Height="45">
                <StackPanel HorizontalAlignment="Center">
                    <TextBlock Text="4K Ultra HD" FontWeight="Bold" TextAlignment="Center"/>
                    <TextBlock Text="3840 x 2160" FontSize="11" Foreground="#b0b0b0" TextAlignment="Center"/>
                </StackPanel>
            </Button>
            
            <Button Name="Btn1080p" 
                    Width="200" 
                    Height="45">
                <StackPanel HorizontalAlignment="Center">
                    <TextBlock Text="Full HD" FontWeight="Bold" TextAlignment="Center"/>
                    <TextBlock Text="1920 x 1080" FontSize="11" Foreground="#b0b0b0" TextAlignment="Center"/>
                </StackPanel>
            </Button>
            
            <Button Name="Btn1280" 
                    Width="200" 
                    Height="45">
                <StackPanel HorizontalAlignment="Center">
                    <TextBlock Text="Gaming Mode" FontWeight="Bold" TextAlignment="Center"/>
                    <TextBlock Text="1280 x 1024" FontSize="11" Foreground="#b0b0b0" TextAlignment="Center"/>
                </StackPanel>
            </Button>
        </StackPanel>
        
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

# Create Window
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Get controls
$btn4K = $window.FindName("Btn4K")
$btn1080p = $window.FindName("Btn1080p")
$btn1280 = $window.FindName("Btn1280")
$currentResText = $window.FindName("CurrentResText")
$statusText = $window.FindName("StatusText")

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
        $btn4K.Background = if ($current.Width -eq 3840 -and $current.Height -eq 2160) { "#007acc" } else { "#2d2d30" }
        $btn1080p.Background = if ($current.Width -eq 1920 -and $current.Height -eq 1080) { "#007acc" } else { "#2d2d30" }
        $btn1280.Background = if ($current.Width -eq 1280 -and $current.Height -eq 1024) { "#007acc" } else { "#2d2d30" }
    }
}

# Initial resolution check
Update-CurrentResolution

# Button click events
$btn4K.Add_Click({
    $statusText.Text = "Switching to 4K..."
    $statusText.Foreground = "#b0b0b0"
    Set-Resolution -Width 3840 -Height 2160 -DisplayName "4K (3840x2160)"
})

$btn1080p.Add_Click({
    $statusText.Text = "Switching to 1080p..."
    $statusText.Foreground = "#b0b0b0"
    Set-Resolution -Width 1920 -Height 1080 -DisplayName "1080p (1920x1080)"
})

$btn1280.Add_Click({
    $statusText.Text = "Switching to Gaming Mode..."
    $statusText.Foreground = "#b0b0b0"
    Set-Resolution -Width 1280 -Height 1024 -DisplayName "Gaming (1280x1024)"
})

# Add keyboard shortcuts
$window.Add_KeyDown({
    param($sender, $e)
    switch ($e.Key) {
        'D1' { $btn4K.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent))) }
        'D2' { $btn1080p.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent))) }
        'D3' { $btn1280.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent))) }
        'NumPad1' { $btn4K.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent))) }
        'NumPad2' { $btn1080p.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent))) }
        'NumPad3' { $btn1280.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent))) }
        'Escape' { $window.Close() }
    }
})

# Show window
$window.ShowDialog() | Out-Null
