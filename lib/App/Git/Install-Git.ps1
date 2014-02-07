param(
	[string]$Version,
	[string]$Path,
	[switch]$Force,
	[switch]$Update,
	[switch]$Uninstall
)

$Appname = "Git"
$Url = "https://msysgit.googlecode.com/files/Git-1.8.5.2-preview20131230.exe"
$Path = "$(Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)\"

$Url | %{

    Get-File -Url $_ -Path $Path
    
} | %{

    Write-Host "Installing $Appname ..."
    Start-Process -FilePath $(Join-Path $_.Path $_.Filename) -ArgumentList "/VERYSILENT" -Wait -NoNewWindow
    Write-Host "Installation of $Appname finished."
    Set-EnvironmentVariableValue -Name "Path" -Value "C:\Program Files (x86)\Git\bin" -Target "Machine" -Add
}