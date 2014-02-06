param(
	[string]$Version,
	[string]$Path,
	[switch]$Force,
	[switch]$Update,
	[switch]$Uninstall
)

$Url = "http://download.tuxfamily.org/notepadplus/6.5.3/npp.6.5.3.Installer.exe"

$Url | %{

    Get-File -Url $_ -Path $Path
    
} | %{

    Write-Host "Installing NotepadPlusPlus ..."
    Start-Process -FilePath $(Join-Path $_.Path $_.Filename) -ArgumentList "/S" -Wait -NoNewWindow
    Write-Host "Installation of NotepadPlusPlus finished"
}