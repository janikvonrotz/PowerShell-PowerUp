<#
$Metadata = @{
	Title = "Write PowerShell Profile Event Log"
	Filename = "Write-PPEventLog.ps1"
	Description = ""
	Tags = "powershell, profile, function, write, event, log"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-10-21"
	LastEditDate = "2013-10-21"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Write-PPEventLog{

<#
.SYNOPSIS
	Writes to event log with default parameters provided by the PowerShell Profile configuration.

.DESCRIPTION
	Writes to event log with default parameters provided by the PowerShell Profile configuration.

.PARAMETER  Message
	Message for the event log entry.

.PARAMETER  Source
	Source of the log event.
    
.PARAMETER  EventID
	Provide an EventId.

.PARAMETER  EventLogSource
	Source parameter for the event log entry.
	
.PARAMETER  EntryType
	Provide an EntryType. Possible is Information, Warning, Error, FailureAudit, SuccessAudit
    
.PARAMETER  AppendSessionLog
	Appends the PowerShell session log to the message.

.EXAMPLE
	PS C:\> Write-PPEventLog -Message "User XY has not been notified" -Source $MyInvocation.InvocationName -EntryType Warning
#>

	param(        
        [Parameter(Mandatory=$true)]
		$Message,

        [Parameter(Mandatory=$true)]
		$Source,
        
        [Parameter(Mandatory=$false)]
		$EventId,
        
        [Parameter(Mandatory=$false)]
		$EventLogSource,
        
        [Parameter(Mandatory=$false)]
		[string]
        $EntryType,
        
        [switch]
        $AppendSessionLog
	)
	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
    if($EntryType -eq "Error"){Write-Error $Message    
    }elseif($EntryType -eq "Warning"){Write-Warning $Message       
    }else{Write-Host $Message}
    
    $Message = $Source + "`n`n" + $Message
    
    if(-not $EventId){
    
        if($EntryType -eq "Error"){$EventId = $PSlogs.ErrorEventId        
        }elseif($EntryType -eq "Warning"){$EventId = $PSlogs.WarningEventId            
        }else{$EventId = $PSlogs.InformationEventId}
    }
    
    if(-not $EventLogSource){$EventLogSource = "PowerShell Profile"}        
    if($AppendSessionLog){
		Copy-Item $PSlogs.SessionFile ("$($PSlogs.SessionFile).tmp")
		$Message += Get-Content $PSlogs.SessionFile | Out-String
		Remove-Item ("$($PSlogs.SessionFile).tmp")
	}
    
    if(-not $EntryType){ Write-EventLog -EventId $EventId -Message $Message -ComputerName $env:COMPUTERNAME -LogName $PSlogs.EventLogName -Source $EventLogSource
    }else{Write-EventLog -EventId $EventId -Message $Message -EntryType $EntryType -ComputerName $env:COMPUTERNAME -LogName $PSlogs.EventLogName -Source $EventLogSource}
}