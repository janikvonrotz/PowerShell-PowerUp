param(
	[string]$Version,
	[string]$Path,
	[switch]$Force,
	[switch]$Update,
	[switch]$Uninstall
)

$Url = "https://msysgit.googlecode.com/files/Git-1.8.5.2-preview20131230.exe"

$Url | %{

    Get-File -Url $_ -Path $Path
    
} | %{

    Write-Host "Installing Git ..."
    Start-Process -FilePath $(Join-Path $_.Path $_.Filename) -ArgumentList "/VERYSILENT" -Wait -NoNewWindow
    Write-Host "Installation of Git finished"
    Set-EnvironmentVariableValue -Name "Path" -Value "C:\Program Files (x86)\Git\bin" -Target "Machine" -Add
}