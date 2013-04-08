#--------------------------------------------------#
#    Title: Check Print ID Code
#--------------------------------------------------#
#    File name: UpdatePrintIDCode.ps1
#    Description: [Description]
#    Tags: powershell, activedirectory, safecom
#    Project: [Projectname]
#
#    Author: Janik von Rotz
#    Author E-Mail: contact@janikvonrotz.ch
#
#    Create Date: 07.01.2013
#    Last Edit Date: 07.01.2013
#    Version: 1.0.0
#--------------------------------------------------#

<#
extensionAttribute1	Personalnummer	65038
extensionAttribute2	Kostenstelle	2000
extensionAttribute3	Print ID-Code	3288
/#>

$PrintIDCode = Read-Host "`nEnter the Print ID Code to check"

While ((Get-QADUser -SearchRoot "OU=vblusers2,DC=vbl,DC=ch" -LdapFilter ("(extensionAttribute3=" + $PrintIDCode + ")")))
{
	Write-Host "`nID not available!" -BackgroundColor Yellow -ForegroundColor Red
	$PrintIDCode = Read-Host `n"Enter a new Print ID Code to check"
}

Write-Host "`nPrint ID Code: $PrintIDCode is available" -BackgroundColor Green -ForegroundColor DarkGreen

Out-Clipboard $PrintIDCode

Write-Host "`nPrint ID Code copied to clipboard" -BackgroundColor Yellow -ForegroundColor Black

$null = Read-Host "`nPress Enter to exit"