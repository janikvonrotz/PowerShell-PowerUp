function Get-LogDate {
<#
.SYNOPSIS
	logstamp string to datetime

.DESCRIPTION
	Returns the datetime from a logstamp string

.PARAMETER  LogStamp
	A logstamp string from the command Get-LogStamp

.EXAMPLE
	PS C:\> Get-LogDate -LogStamp $String

.OUTPUTS
	System.datetime
#>

param(
		[Parameter(Mandatory=$true)]
		[String]
		$LogStamp
)

	$Metadata = @{
		Title = "Get Log Date"
		Filename = "Get-LogDate.ps1"
		Description = ""
		Tags = "powershell, functions"
		Project = ""
		Author = "Janik von Rotz"
		AuthorContact = "www.janikvonrotz.ch"
		CreateDate = "2013-05-08"
		LastEditDate = "2013-05-08"
		Version = "1.0.0"
		License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
	return [datetime]::ParseExact($LogStamp, "yyyy-MM-dd HH-mm-ss", $null)
}