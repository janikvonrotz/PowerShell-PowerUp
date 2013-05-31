function Pause ($Message="Press any key to continue...")
{
Write-Host -NoNewLine $Message
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host ""
}

Write-Host -ForegroundColor Red "Check SharePoint Install Path in Server\Files\SetupFarmSilent\config.xml and Product Key (Standard or Enterprise)"
Pause

# Install Prerequisits
# --------------------
cd .\Server
Write-Host -ForegroundColor Yellow "SharePoint Prerequisits will be installed now"
try
{
	Start-Process -FilePath ".\PrerequisiteInstaller.exe" -WindowStyle Minimized -Wait
	If (-not $?) {throw}
}
catch {throw "- Error $LastExitCode occurred running setup.exe"}
Write-Host -ForegroundColor Yellow "SharePoint Prerequisits installation completed sucessfully" 


# Install Server
# --------------

Write-Host -ForegroundColor Yellow "SharePoint Binaries will be installed now"
try
{
	Start-Process ".\Setup.exe" -ArgumentList "/config `".\Files\SetupFarmSilent\Config.xml`"" -WindowStyle Minimized -Wait
	If (-not $?) {throw}
}
catch {throw "- Error $LastExitCode occurred running setup.exe"}
Write-Host -ForegroundColor Yellow "Installation completed sucessfully" 

# LP's Server
# -----------

# SharePoint Server DE
cd ..\LanguagePacks\DE
Write-Host -ForegroundColor Yellow "- SharePoint Server German LanguagePack will be installed now"
try
{
	Start-Process -FilePath ".\Setup.exe" -ArgumentList "/config `".\Files\SetupSilent\Config.xml`"" -WindowStyle Minimized -Wait
	If (-not $?) {throw}
}
catch {throw "- Error $LastExitCode occurred running setup.exe"}
Write-Host -ForegroundColor Yellow "- Installation completed sucessfully"


# SharePoint Server FR
cd ..\FR
Write-Host -ForegroundColor Yellow "- SharePoint Server France LanguagePack will be installed now" 
try
{
	Start-Process -FilePath ".\Setup.exe" -ArgumentList "/config `".\Files\SetupSilent\Config.xml`"" -WindowStyle Minimized -Wait
	If (-not $?) {throw}
}
catch {throw "- Error $LastExitCode occurred running setup.exe"}
Write-Host -ForegroundColor Yellow "- Installation completed sucessfully"


# SharePoint Server IT
cd ..\IT
Write-Host -ForegroundColor Yellow "- SharePoint Server Italian LanguagePack will be installed now"
try
{
	Start-Process -FilePath ".\Setup.exe" -ArgumentList "/config `".\Files\SetupSilent\Config.xml`"" -WindowStyle Minimized -Wait
	If (-not $?) {throw}
}
catch {throw "- Error $LastExitCode occurred running setup.exe"}
Write-Host -ForegroundColor Yellow "- Installation completed sucessfully"


