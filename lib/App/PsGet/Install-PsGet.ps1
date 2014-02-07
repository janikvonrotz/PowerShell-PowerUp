param(
	[string]$Version,
	[string]$Path,
	[switch]$Force,
	[switch]$Update,
	[switch]$Uninstall
)

$Appname = "PsGet"
$Url = "http://psget.net/GetPsGet.ps1"

if(-not (Get-Module -ListAvailable | where{$_.Name -eq "PsGet"}) -or $Force){

	Invoke-Expression (new-object Net.WebClient).DownloadString($Url)

}else{

    Write-Error "$Appname is already installed, use Force parameter to reinstall this app."
}