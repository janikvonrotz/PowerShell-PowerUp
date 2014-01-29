<#
$Metadata = @{
	Title = "Send PowerShell PowerUp Error Report"
	Filename = "Send-PPErrorReport.ps1"
	Description = "Sends a default error Report based on the PowerShell PowerUp configurations."
	Tags = "powershell, profile, error, report"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-08-14"
	LastEditDate = "2013-10-21"
	Url = ""
	Version = "1.1.2"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Send-PPErrorReport{

<#
.SYNOPSIS
  Sends a default error Report based on the PowerShell PowerUp configurations.

.DESCRIPTION
	Sends a default error Report based on the PowerShell PowerUp configurations.

.PARAMETER  FileName
	The name of the PowerShell PowerUp config file.

.PARAMETER  ScriptName
	The name of the PowerShell PowerUp script that throws the error.
	
.PARAMETER  ClearErrorVariable
	Clear PowerShell error variable.

.EXAMPLE
	PS C:\> Send-PPErrorReport -FileName "Office365.mail.config.xml" -ScriptName $MyInvocation.InvocationName

.NOTES
	The name of the configuration in the config file has to be "ErrorReport"
#>

	param(
		[Parameter(Mandatory=$true)]
		[String]
		$FileName,

        [Parameter(Mandatory=$true)]
		[String]
		$ScriptName,
		
		[switch]
		$ClearErrorVariable  
	)

	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
	
	if($Error){ 	
		# output existing errors
		$Error
		
		# reset
		$Body = ""

		# create body message
		$Error | foreach{$Body += $_.ToString() + $_.InvocationInfo.PositionMessage + "`n`n"}

		# Get mail receiver from config file
		$Mail = Get-PPConfiguration $PSconfigs.Mail.Filter | %{$_.Content.Mail | where{$_.Name -eq $PSconfigs.Mail.ErrorClass}} | select -first 1

		# send mail
		Send-MailMessage -To $Mail.ReplyToAddress -From $Mail.FromAddress -Subject ($env:COMPUTERNAME + " " + $ScriptName + " #" + $(get-date -format o)) -Body $Body -SmtpServer $Mail.OutSmtpServer

		# clear error variable
		if($ClearErrorVariable){$error.clear()}
	}
}

