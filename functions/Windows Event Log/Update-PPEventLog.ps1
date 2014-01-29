<#
$Metadata = @{
	Title = "Update PowerShell PowerUp Event Log"
	Filename = "Update-PPEventLog.ps1"
	Description = ""
	Tags = "powershell, profile, function, update, event, log"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-10-22"
	LastEditDate = "2014-01-29"
	Version = "1.1.1"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>


function Update-PPEventLog{

<#
.SYNOPSIS
	Updates the windows evenlogs based on the config files in the PowerShell PowerUp config folder.

.DESCRIPTION
	Updates the windows evenlogs based on the config files in the PowerShell PowerUp config folder.

.EXAMPLE
	PS C:\> Update-PPEventLog
#>

	param(
	)
	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
	Get-PPConfiguration $PSconfigs.EventLog.Filter | %{$_.Content.EventLog} | %{
	
		$EventLog = Get-WmiObject win32_nteventlogfile -filter "filename='$($_.Name)'"
        
		if(-not ($EventLog)){
			
			Write-Host "Create event log: $($_.Name)"
			New-EventLog -LogName $_.Name -Source $_.Source -ErrorAction SilentlyContinue
			$EventLog = Get-WmiObject win32_nteventlogfile -filter "filename='$($_.Name)'"
		}		
        
		$SourcesTO = ($_.Source | %{"$($_.Name)"}) + ($_.Source | where{$_.Expression} | %{$_.Expression | iex})
		$SourcesIS = $EventLog.Sources
		
		# add sources
		Compare-Object $SourcesTO $SourcesIS -passThru | Where-Object{ $_.SideIndicator -eq '<=' } | %{
			Write-Host "Add source: $_ to event log: $($EventLog.LogfileName)"
			New-EventLog -Source $_ -LogName $EventLog.LogfileName
		}
		
		# remove sources
		Compare-Object $SourcesTO $SourcesIS -passThru | Where-Object{ $_.SideIndicator -eq '=>' } | %{
			Write-Host "Remove source: $_ from event log: $($EventLog.LogfileName)"
			Remove-EventLog -Source $_
		}
	}
}