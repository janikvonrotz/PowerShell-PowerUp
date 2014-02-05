param(
	[string]$Version,
	[string]$Path,
	[switch]$Force,
	[switch]$Update,
	[switch]$Uninstall
)

$Url = "http://psget.net/GetPsGet.ps1"

if(!(Get-Module -ListAvailable | where{$_.Name -eq "PsGet"})){

	iex (new-object Net.WebClient).DownloadString($Url)
}