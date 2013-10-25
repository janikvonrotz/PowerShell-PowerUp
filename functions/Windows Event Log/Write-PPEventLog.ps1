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
	LastEditDate = "2013-10-25"
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

.PARAMETER  EventLog
	Name of the event log.
    
.PARAMETER  EventID
	Provide an EventId.

.PARAMETER  Source
	Source parameter for the event log entry.
	
.PARAMETER  EntryType
	Provide an EntryType. Possible is Information, Warning, Error, FailureAudit, SuccessAudit
    
.PARAMETER  AppendSessionLog
	Appends the PowerShell session log to the message.

.EXAMPLE
	PS C:\> Write-PPEventLog -Message "User XY has not been notified" -Source "Application XY" -EntryType Warning -EventId 123 -WriteMessage -AppendSessionLog
#>

	param(        
        [Parameter(Mandatory=$true)]
		$Message,
        
        [Parameter(Mandatory=$false)]
		$EventLog,
        
        [Parameter(Mandatory=$false)]
		$EventId, 
               
        [Parameter(Mandatory=$false)]
		$Source,       
                
        [Parameter(Mandatory=$false)]
		[string]
        $EntryType,
        
		[switch]
        $WriteMessage,
		
        [switch]
        $AppendSessionLog
	)
	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
    $EventLogs =  Get-PPConfiguration $PSconfigs.EventLog.Filter | %{$_.Content.EventLog}
    
    if($EventLog){$EventLogs = $EventLogs | where{$_.Name -eq $EventLog}        
    }elseif($EventLogs){$EventLogs = $EventLogs | where{$_.Role -eq "Default"} | select -first 1
    }else{throw "Couldn't find event log configurations with role: Default in $($PSconfigs.Path)"}
    
    if($EventLogs -eq $null){throw "Couldn't find event log configurations in $($PSconfigs.Path)"}
    
    $EventLogs | %{   
    	    
        if(-not $EventId){    
            if($EntryType -eq "Error"){$EventId = $_.ErrorEventId        
            }elseif($EntryType -eq "Warning"){$EventId = $_.WarningEventId
            }elseif($EntryType -eq "FailureAudit"){$EventId = $_.FailureAudit     
            }elseif($EntryType -eq "SuccessAudit"){$EventId = $_.SuccessAudit
            }elseif($EntryType -eq "InformationEventId"){$EventId = $_.InformationEventId     
            }else{$EventId = $_.DefaultEventId}
        }
        
        if(-not $EntryType){$EntryType = $_.DefaultEntryType}
        
        if($WriteMessage){
    		if($EntryType -eq "Error"){Write-Error $Message    
    		}elseif($EntryType -eq "Warning"){Write-Warning $Message       
    		}else{Write-Host $Message}
        }
        
        if(-not $Source){
            $Source = $_.Source | where{$_.Role -eq "Default"} | %{"$($_.Name)"}
            if($Source -eq $null){throw "Couldn't find default source in event log configuration for: $($_.Name)"}
        }
             
        if($AppendSessionLog){
    		Copy-Item $PSlogs.SessionFile ("$($PSlogs.SessionFile).tmp")
    		$Message += "`n`n" + (Get-Content $PSlogs.SessionFile | Out-String)
    		Remove-Item ("$($PSlogs.SessionFile).tmp")
    	}       
        
        Write-EventLog -EventId $EventId -Message $Message -ComputerName $env:COMPUTERNAME -LogName $_.Name -Source $Source -EntryType $EntryType
    }
}