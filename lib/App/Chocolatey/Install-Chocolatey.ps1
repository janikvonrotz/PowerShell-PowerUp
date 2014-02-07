param(
	[string]$Version,
	[string]$Path,
	[switch]$Force,
	[switch]$Update,
	[switch]$Uninstall
)

$Appname = "Chocolatey"
$Url = "https://chocolatey.org/install.ps1"

if(!(Get-Command "cinst" -ErrorAction SilentlyContinue) -or $Force){

	Invoke-Expression ((new-object net.webclient).DownloadString($Url))
    
}else{

    Write-Error "$Appname is already installed, use Force parameter to reinstall this app."
}