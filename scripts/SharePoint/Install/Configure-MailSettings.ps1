<#
.SYNOPSIS
	Configure SharePoint mail settings

.DESCRIPTION
	Configure the outgoing e-mail feature from sharepoint, which uses an outbound Simple Mail Transfer Protocol (SMTP) service to relay e-mail alerts and notifications

.LINK
	Technet article: http://technet.microsoft.com/en-us/library/cc288265%28v=office.15%29.aspx
#>

$Metadata = @{
	Title = "Configure Mail Settings"
	Filename = "configure-MailSettings.ps1"
	Description = "Configure SharePoint mail settings"
	Tags = "powershell, sharepoint, 2013, installation"
	Project = "SharePoint 2013 Install"
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-06-11"
	LastEditDate = "2013-06-11"
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
$PathToXmlFile = Get-ChildItem -Path $PSconfigs.Path -Filter '*.install.config.xml' -Recurse
[xml]$Config = get-content $PathToXmlFile.FullName

#--------------------------------------------------#
# main
#--------------------------------------------------#
$SPMail = $Config.Content.Global.SPMail

# Load Remote configurations
$s = rps $Config.Content.Global.SPServer.Key

$outsmtpserver = $SPMail.OutSmtpServer
$fromaddress =  $SPMail.FromAddress
$replytoaddress = $SPMail.ReplyToaddress

$ScriptBlock = (Write-Output "& stsadm -o email -outsmtpserver $outsmtpserver -fromaddress $fromaddress -replytoaddress $replytoaddress -codepage 65001" | Convert-StringToScriptBlock)

Invoke-Command -Session $s -ScriptBlock $ScriptBlock

Write-Host "Finished" -BackgroundColor Black -ForegroundColor Green
Read-Host "Press Enter to exit"

