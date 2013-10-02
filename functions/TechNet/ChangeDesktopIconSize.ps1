################################################################################# 
#
# The sample scripts are not supported under any Microsoft standard support 
# program or service. The sample scripts are provided AS IS without warranty 
# of any kind. Microsoft further disclaims all implied warranties including, 
# without limitation, any implied warranties of merchantability or of fitness for 
# a particular purpose. The entire risk arising out of the use or performance of 
# the sample scripts and documentation remains with you. In no event shall 
# Microsoft, its authors, or anyone else involved in the creation, production, or 
# delivery of the scripts be liable for any damages whatsoever (including, 
# without limitation, damages for loss of business profits, business interruption, 
# loss of business information, or other pecuniary loss) arising out of the use 
# of or inability to use the sample scripts or documentation, even if Microsoft 
# has been advised of the possibility of such damages 
# 
################################################################################# 


$code = @'
using System;
using System.Runtime.InteropServices;
using Microsoft.Win32;

namespace Sample
{
    public enum WallpaperStyle : int
    {
        Tile, Center, Stretch, NoChange
    }

    public enum DesktopViewStyle : int
    {
        Large, Medium, Small, NoChange
    }

    public class DesktopHelper
    {
        //Declare functions in unmanaged APIs.
        private const int SPIF_UPDATEINIFILE = 0x0001;
        private const int SPIF_SENDWININICHANGE = 0x0002;
        private const int SPI_ICONHORIZONTALSPACING = 0x000D;
        private const int SPI_ICONVERTICALSPACING = 0x0018;
        private const int SPI_SETDESKWALLPAPER = 0x0014;
        private const int SPI_SETBORDER = 0x0006;
        private const int LVM_SETICONSPACING = 0x1035;
        private const int WM_MOUSEWHEEL = 0x020A;
        private const int MK_CONTROL = 0x0008;
        private const int WHEEL_DELTA = 120;
        private const int SW_HIDE = 0;
        private const int SW_SHOWNORMAL = 1;
        private const int COLOR_DESKTOP = 1;

        

        [DllImport("user32.dll", EntryPoint = "SystemParametersInfo", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern bool SystemParametersInfoSet(int uAction, int uParam, object lpvParam, int fuWinIni);
        [DllImport("user32.dll", EntryPoint = "SystemParametersInfo", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern int SystemParametersInfoSetWallpaper(int uAction, int uParam, string lpvParam, int fuWinIni);
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr SendMessage(IntPtr hWnd, int msg, int wParam, int lParam);
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, string lpszClass, string lpszWindow);
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern bool UpdateWindow(IntPtr hWnd);
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern bool SetSysColors(int cElements, int[] lpaElements, int[] lpaRgbValues);

        //Helper functions
        private static IntPtr GetDesktopHandle()
        {
            IntPtr hDesk = IntPtr.Zero;
            IntPtr hwndIcon = FindWindow("Progman", null);
            IntPtr hChild = FindWindowEx(hwndIcon, IntPtr.Zero, "SHELLDLL_DefView", null);
            if (hChild != IntPtr.Zero) 
            {
                hDesk = FindWindowEx(hChild, IntPtr.Zero, "SysListView32", null);
            }
            return hDesk;
        }

        private static void RemoveWallpaper() 
        {
            SystemParametersInfoSetWallpaper(SPI_SETDESKWALLPAPER, 0, "", SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE);
        }

        private static int MakeLong(int lowPart, int highPart)
        {
            return (int)(((ushort)lowPart) | (uint)(highPart << 16));
        }

        //Pubilc functions
        public static void SetIconSpacing(int size)
        {
            int hSpacing = size + 32;
            int vSpacing = size + 32;
            IntPtr hWnd = GetDesktopHandle();
            if (hWnd != IntPtr.Zero )
            {
                int lParamMsg = MakeLong(hSpacing, vSpacing);
                SystemParametersInfoSet(SPI_ICONHORIZONTALSPACING, hSpacing, null, SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE);
                SystemParametersInfoSet(SPI_ICONVERTICALSPACING, vSpacing, null, SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE);
                SendMessage(hWnd, LVM_SETICONSPACING, 0, lParamMsg);
                ShowWindow(hWnd, SW_HIDE);
                ShowWindow(hWnd, SW_SHOWNORMAL);
            }
        }

        public static void SetWallpaper(string path, WallpaperStyle style)
        {
            if (path == string.Empty )
            {
                RemoveWallpaper();
            }
            else if (System.IO.File.Exists(path) && 
                (
                    path.Trim().ToLowerInvariant().EndsWith(".bmp")||
                    path.Trim().ToLowerInvariant().EndsWith(".jpg")||
                    path.Trim().ToLowerInvariant().EndsWith(".jpeg")
                ))
            {
                SystemParametersInfoSetWallpaper(SPI_SETDESKWALLPAPER, 0, path, SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE);
                RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
                switch (style)
                {
                    case WallpaperStyle.Stretch:
                        key.SetValue(@"WallpaperStyle", "2");
                        key.SetValue(@"TileWallpaper", "0");
                        break;
                    case WallpaperStyle.Center:
                        key.SetValue(@"WallpaperStyle", "1");
                        key.SetValue(@"TileWallpaper", "0");
                        break;
                    case WallpaperStyle.Tile:
                        key.SetValue(@"WallpaperStyle", "1");
                        key.SetValue(@"TileWallpaper", "1");
                        break;
                    case WallpaperStyle.NoChange:
                        break;
                }
                key.Close();
            }
        }

        public static void SetBorder(int size) 
        {
            SystemParametersInfoSet(SPI_SETBORDER, size, null, SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE);
        }

        public static void SetColor(byte r, byte g, byte b)
        {
            //Remove the current wallpaper
            RemoveWallpaper();
            System.Drawing.Color color= System.Drawing.Color.FromArgb(r,g,b);
            int[] elements = {COLOR_DESKTOP};
            int[] colors = { System.Drawing.ColorTranslator.ToWin32(color) }; 
            SetSysColors(elements.Length, elements, colors);
            RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Colors", true);
            key.SetValue(@"Background", string.Format("{0} {1} {2}", color.R, color.G, color.B));
            
        }

        public static void SetDesktopView(DesktopViewStyle style) 
        {
            if (style != DesktopViewStyle.NoChange)
                {
                IntPtr hWnd = GetDesktopHandle();
                ShowWindow(hWnd, SW_HIDE);
                int scale = 0;
                // Resize the icons to smallest
                int wParam = MakeLong(MK_CONTROL, -WHEEL_DELTA);
                int lParam = 0;
                for (int i = 0; i < 50; i++)
                {
                    SendMessage(hWnd, WM_MOUSEWHEEL, wParam, 0);
                }
                switch (style)
                {
                    case DesktopViewStyle.Large:
                        scale = 17;
                        break;
                    case DesktopViewStyle.Medium:
                        scale = 11;
                        break;
                    case DesktopViewStyle.Small:
                        scale = 6;
                        break;
                }
                wParam = MakeLong(MK_CONTROL, WHEEL_DELTA);
                //Resize the icons
                for (int i = 0; i < scale; i++)
                {
                    SendMessage(hWnd, WM_MOUSEWHEEL, wParam, lParam);
                }
                ShowWindow(hWnd, SW_SHOWNORMAL);
            }
        }
    }
}

'@
$type = Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing.dll -PassThru 
    
Function Set-OSCIconSpacing
{
    <#
        .SYNOPSIS
            Set-OSCIconSpacing can be used to change the desktop icon spacing.
        .DESCRIPTION
            Set-OSCIconSpacing is an advanced function which can be used to change the icon spacing of your desktop. 
            When you use this function, the icon horizontal spacing and the icon vertical spacing will be set to the same size.
        .PARAMETER IconSpacing
            Indicates the icon spacing size.
            You can specify a value in 0~150 for this parameter.
        .EXAMPLE
            Set-OSCIconSpacing -IconSpacing 50
            #Change the icon spacing size to 50.
        .LINK
            Windows PowerShell Advanced Function
            http://technet.microsoft.com/en-us/library/dd315326.aspx
        .LINK
            SystemParametersInfo function
            http://msdn.microsoft.com/en-us/library/windows/desktop/ms724947(v=vs.85).aspx
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position=1, Mandatory=$true)]
        [ValidateRange(0,150)]
        [int] $IconSpacing
    )
    Process
    {
        [Sample.DesktopHelper]::SetIconSpacing($IconSpacing)
        return
    }
}

Function Set-OSCWallpaper
{
    <#
        .SYNOPSIS
            Set-OSCWallpaper can be used to change the desktop wallpaper.
        .DESCRIPTION
            Set-OSCWallpaper is an advanced function which can be used to change the desktop wallpaper. 
            You can set a picture of the following file types as the wallpaper:
            (.bmp, .jpg, .jpeg)
        .PARAMETER Path
            Indicates the path of picture that you want to set.
        .PARAMETER $Style
            Indicates the style of the wallpaper position. This parameter can be one of the following values:
            (Tile, Center, Stretch, NoChange)
            If you ignore this parameter, 'NoChange' will be set by default.
        .EXAMPLE
            Set-OSCWallpaper -Path "C:\test.jpg" -Style "Stretch"
            #Change the wallpaper to "C:\test.jpg" using the stretch mode.
        .LINK
            Windows PowerShell Advanced Function
            http://technet.microsoft.com/en-us/library/dd315326.aspx
        .LINK
            SystemParametersInfo function
            http://msdn.microsoft.com/en-us/library/windows/desktop/ms724947(v=vs.85).aspx
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias("FullName")]
        [string] $Path,
        [Parameter(Position=1, Mandatory=$false)]
        [Sample.WallpaperStyle] $Style = [Sample.WallpaperStyle]::NoChange
    )
    Process
    {
        if (Test-Path $Path)
        {
            [Sample.DesktopHelper]::SetWallpaper($Path,$Style)
        }
        else
        {
            Write-Warning $Messages.FileDoesNotExist
        }
        return
    }
}

Function Set-OSCWindowBorder
{
    <#
        .SYNOPSIS
            Set-OSCWindowBorder can be used to change the desktop window sizing border.
        .DESCRIPTION
            Set-OSCWindowBorder is an advanced function which can be used to change the window sizing border of your desktop. 
        .PARAMETER Border
            Indicates the window sizing border. 
            You can specify a value in 0~50 for this parameter.
        .EXAMPLE
            Set-OSCWindowBorder -Border 1
            #Change the window sizing border to 1.
        .LINK
            Windows PowerShell Advanced Function
            http://technet.microsoft.com/en-us/library/dd315326.aspx
        .LINK
            SystemParametersInfo function
            http://msdn.microsoft.com/en-us/library/windows/desktop/ms724947(v=vs.85).aspx
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position=0, Mandatory=$true)]
        [ValidateRange(0,50)]
           [int] $Border
    )
    Process
    {
        [Sample.DesktopHelper]::SetBorder($Border)
        return
    }
}

Function Set-OSCDesktopColor
{
    <#
        .SYNOPSIS
            Set-OSCDesktopColor can be used to change the desktop background color.
        .DESCRIPTION
            Set-OSCDesktopColor is an advanced function which can be used to change the background color of your desktop. 
            This function will first remove the current desktop wallpaper.
        .PARAMETER R
            Indicates the three colors (red, green, blue)in the RGB color model.
            You can specify a value in 0~255 for each parameter (R,G,B).
            If you ignore these parameters, the background color will be set to the default color.
        .EXAMPLE
            Set-OSCDesktopColor -R 0 -G 0 -B 255
            #Change the desktop background color to blue.
        .LINK
            Windows PowerShell Advanced Function
            http://technet.microsoft.com/en-us/library/dd315326.aspx
        .LINK
            SetSysColors function
            http://msdn.microsoft.com/en-us/library/windows/desktop/ms724940(v=vs.85).aspx
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position=0, Mandatory=$true)]
        [ValidateRange(0,255)]
        [int] $R,
        [Parameter(Position=1, Mandatory=$true)]
        [ValidateRange(0,255)]
        [int] $G,
        [Parameter(Position=2, Mandatory=$true)]
        [ValidateRange(0,255)]
        [int] $B 
    )
    Process
    {
        [Sample.DesktopHelper]::SetColor($R,$G,$B)
        return
    }
}

Function Set-OSCDesktopView
{
    <#
        .SYNOPSIS
            Set-OSCDesktopView can be used to change the desktop icon view.
        .DESCRIPTION
            Set-OSCDesktopView is an advanced function which can be used to change the view of desktop icons. 
            It simulates the view change operation of the desktop context menu.
        .PARAMETER DesktopView
            Indicates the view you want to set for your desktop. You can set it to one of the following values:
            (Large, Medium, Small, NoChange)
            If you ignore this parameter, 'NoChange' will be set by default.
        .EXAMPLE
            Set-OSCDesktopView -DesktopView "Small"
            #Change the desktop icon view to display small icons.
        .LINK
            Windows PowerShell Advanced Function
            http://technet.microsoft.com/en-us/library/dd315326.aspx
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position=0, Mandatory=$false)]
        [Sample.DesktopViewStyle] $DesktopView = [Sample.DesktopViewStyle]::NoChange
    )
    Process
    {
        [Sample.DesktopHelper]::SetDesktopView($DesktopView);
        return
    }
}

Function Set-OSCDesktopDefault
{
    <#
        .SYNOPSIS
            Set-OSCDesktopDefault can be used to restore the default settings for your desktop.
        .DESCRIPTION
            Set-OSCDesktopDefault is an advanced function which can be used to change the window border, the desktop background color, icon spacing, and icons view to its default values.
        .EXAMPLE
            Set-OSCDesktopDefault
            #Restore the default settings
        .LINK
            Windows PowerShell Advanced Function
            http://technet.microsoft.com/en-us/library/dd315326.aspx
    #>
    [CmdletBinding()]
    Param()
    Process
    {
        [Sample.DesktopHelper]::SetColor(58, 110, 165)
        [Sample.DesktopHelper]::SetBorder(0)
        [Sample.DesktopHelper]::SetIconSpacing(75)
        [Sample.DesktopHelper]::SetDesktopView([Sample.DesktopViewStyle]::Medium);
        return
    }
}