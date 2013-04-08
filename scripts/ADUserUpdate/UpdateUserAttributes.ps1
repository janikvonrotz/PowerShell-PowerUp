#--------------------------------------------------#
#    Title: Update AD-User Attributes
#--------------------------------------------------#
#    File name: UpdateUserAttributes.ps1
#    Description: [Description]
#    Tags: powershell, activedirectory
#    Project: [Projectname]
#
#    Author: Janik von Rotz
#    Author E-Mail: contact@janikvonrotz.ch
#
#    Create Date: 07.01.2013
#    Last Edit Date: 09.01.2013
#    Version: 1.0.2
#--------------------------------------------------#

<#
extensionAttribute1	Personalnummer	65038
extensionAttribute2	Kostenstelle	2000
extensionAttribute3	Print ID-Code	3288
/#>

  # Settings
$File = [string](Get-Location) + "\MitarbeiterListe.csv"

$pw = Read-Host "Enter password" -AsSecureString

Connect-QADService -ConnectionAccount "vbl\administrator" -ConnectionPassword $pw

  # Convert CSV File to UTF-8
$Content = Get-Content $File
Set-Content $Content -Encoding utf8 -Path $File

$CSVContent = Import-Csv -Path MitarbeiterListe.csv -Delimiter ";"

foreach ($user in $CSVContent)
{
	Get-QADUser $user.SamAccountName | Set-QADUser -objectAttributes @{extensionAttribute1=$user.Personalnummer; extensionAttribute2=$user.Kostenstelle; extensionAttribute3=$user.PrintIDCode}	
}