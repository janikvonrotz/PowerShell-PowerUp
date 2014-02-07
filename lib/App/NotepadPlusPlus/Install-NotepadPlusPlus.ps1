param(
	[string]$Version,
	[string]$Path,
	[switch]$Force,
	[switch]$Update,
	[switch]$Uninstall
)

$Appname = "NotepadPlusPlus"
$Url = "http://download.tuxfamily.org/notepadplus/6.5.3/npp.6.5.3.Installer.exe"
$Path = "$(Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)\"

$Url | %{

    Get-File -Url $_ -Path $Path
    
} | %{

    Write-Host "Installing $Appname ..."
    Start-Process -FilePath $(Join-Path $_.Path $_.Filename) -ArgumentList "/S" -Wait -NoNewWindow
    Write-Host "Installation of $Appname finished."
}