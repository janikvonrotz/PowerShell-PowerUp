<#
$Metadata = @{
	Title = "Send PowerShell Profile Error Report"
	Filename = "Send-PPErrorReport"
	Description = "Sends a default error Report based on the PowerShell Profile configurations."
	Tags = "powershell, profile, error, report"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-08-14"
	LastEditDate = "2013-08-14"
	Url = ""
	Version = "1.0.0"
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
    Sends a default error Report based on the PowerShell Profile configurations.

.DESCRIPTION
	Sends a default error Report based on the PowerShell Profile configurations.

.PARAMETER  FileName
	The name of the PowerShell Profile config file.

.EXAMPLE
	PS C:\> Send-PPErrorReport -FileName "Office365.mail.config.xml"
	
.NOTE
	The name of the configuration in the config file has to be "ErrorReport"
#>

	param(
		[Parameter(Mandatory=$true)]
		[String]
		$FileName
	)

	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
	

    # Output existing errors
    $Error

    # Create mail message
    $Body = ""
    foreach($Fail in $Error){
        $Body += $Fail.ToString() + $Fail.InvocationInfo.PositionMessage + "`n`n"
    }

    # Get mail receiver from config file
    [xml]$Config = get-content (Get-ChildItem -Path $PSconfigs.Path -Filter $FileName -Recurse).FullName
    $MailConfig = ($Config.Content.Mail | where {$_.Name -eq "ErrorReport"})

    # prepare for send-mailmessage function
    $From = $MailConfig.FromAddress
    $To = $MailConfig.ReplyToAddress
    $Subject = $env:COMPUTERNAME + " " + $MyInvocation.InvocationName + " #" + $(get-date -format o)
    $SmtpServer = $MailConfig.OutSmtpServer

    # send mail
    Send-MailMessage -To $To -From $From -Subject $Subject -Body $Body -SmtpServer $SmtpServer

    $error.clear()
}

