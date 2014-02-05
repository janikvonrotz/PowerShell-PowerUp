param(
	[string]$Version,
	[string]$Path,
	[switch]$Force,
	[switch]$Update,
	[switch]$Uninstall
)

$Url = "https://chocolatey.org/install.ps1"

if(!(Get-Command "cinst" -ErrorAction SilentlyContinue)){

	iex ((new-object net.webclient).DownloadString($Url))
}