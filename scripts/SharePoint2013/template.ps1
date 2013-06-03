<#
.SYNOPSIS
	Create Active Directory Default User

.DESCRIPTION
	Initial deployment administrative and service accounts in SharePoint 2013

.LINK
	Technet article: http://technet.microsoft.com/en-us/library/ee662513.aspx
#>

$Metadata = @{
	Title = ""
	Filename = ""
	Description = ""
	Tags = "powershell, sharepoint, 2013, installation"
	Project = "SharePoint 2013 Install"
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-05-22"
	LastEditDate = "2013-05-22"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

#--------------------------------------------------#
# settings
#--------------------------------------------------#
$PathToXmlFile = Get-ChildItem -Path (Get-Location).path -Filter '*.install.config.xml' -Recurse
[xml]$Config = get-content $PathToXmlFile

#--------------------------------------------------#
# modules
#--------------------------------------------------#
Import-Module Quest.ActiveRoles.ArsPowerShellSnapIn -ErrorAction SilentlyContinue

#--------------------------------------------------#
# main
#--------------------------------------------------#
$ADDefaultUser = $Config.Content.ADDefaultUser
foreach($Account in $ADDefaultUser.Accounts)


Filename:

[Index]_[Verb]-[System][Noun].ps1
