<#
$Metadata = @{
	Title = "Write PowerShell Profile Error Event Log"
	Filename = "Write-PPEventLog.ps1"
	Description = ""
	Tags = "powershell, profile, function, write, error, event, log"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-10-21"
	LastEditDate = "2013-11-18"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Write-PPErrorEventLog{

<#
.SYNOPSIS
	If an error occured this function writes an event log.

.DESCRIPTION
	If an error occured this function writes an event log.

.PARAMETER  Message
	Message for the event log entry. The Error log will be add after this message.

.PARAMETER  Source
	Source parameter for the event log entry.
	
.PARAMETER  ClearErrorVariable
	Clear PowerShell error variable.
	
.EXAMPLE
	PS C:\> Write-PPErrorEventLog -Message "An error occured!" -Source "MyApplication" -ClearErrorVariable
#>

	param(        
        [Parameter(Mandatory=$false)]
		[string]$Message,
        
        [Parameter(Mandatory=$false)]
		[string]$Source,
		
		[switch]
		$ClearErrorVariable  
	)
	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#   
    if($Error){
        $Error | %{$ErrorLog += "$($_.ToString()) $($_.InvocationInfo.PositionMessage) `n`n"}
        
        if($Message){$ErrorLog = "$Message `n`n" + $ErrorLog}
        
        if($ClearErrorVariable){$Error.clear()}
        
        Write-PPEventLog -Message $ErrorLog -Source $Source -EntryType Error -WriteMessage
    }
}