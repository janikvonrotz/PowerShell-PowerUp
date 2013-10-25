<#
$Metadata = @{
	Title = "Update Scheduled Task"
	Filename = "Update-ScheduledTask.ps1"
	Description = ""
	Tags = "powershell, function, update, task"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-10-07"
	LastEditDate = "2013-10-25"
	Version = "1.1.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Update-ScheduledTask{

<#
.SYNOPSIS
	Updates Windows scheduled tasks.

.DESCRIPTION
	Updates Windows scheduled tasks depending on configuration files.
	
.EXAMPLE
	PS C:\> Update-ScheduledTask

.NOTES
	Requirments: PowerShell Profile Installation.

#>

	param(
        
	)

	#--------------------------------------------------#
	# functions
	#--------------------------------------------------#
	function Get-WindowsScheduledTasks{
    
        param(
            $Folder
        )
        
        # get tasks
        $Folder.GetTasks(0) | Foreach-Object {
	        New-Object -TypeName PSCustomObject -Property @{
	            'Name' = $_.Name
                'Path' = $_.Path
                'State' = $_.State
                'Enabled' = $_.Enabled
                'LastRunTime' = $_.LastRunTime
                'LastTaskResult' = $_.LastTaskResult
                'NumberOfMissedRuns' = $_.NumberOfMissedRuns
                'NextRunTime' = $_.NextRunTime
                'Author' =  ([xml]$_.xml).Task.RegistrationInfo.Author
                'UserId' = ([xml]$_.xml).Task.Principals.Principal.UserID
                'Description' = ([xml]$_.xml).Task.RegistrationInfo.Description
            }
        }
        
        # check for subfolders and their tasks
        $Folder.getfolders(1) | %{Get-WindowsScheduledTasks -Folder $_} 
    }
    
    
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
    
    # Read configuration files
    $ScheduledTasks = Get-ChildItem -Path $PSconfigs.Path -Filter $PSconfigs.Task.Filter -Recurse
    
    # get existing tasks
    $WindowsScheduledTasks = new-object -com("Schedule.Service")
    ($WindowsScheduledTasks).connect($env:COMPUTERNAME) 
    $WindowsScheduledTasks = Get-WindowsScheduledTasks -Folder $WindowsScheduledTasks.getfolder("\")
    
    $ScheduledTasks | %{    
    
        $Task = [xml]$(get-content $_.FullName) 
        
        # resolve PowerShell variables 
        $FilePathTemp = $_.FullName + "temp.xml"        
        if($Task.Task.Actions.Exec.Command.contains("$")){$Task.Task.Actions.Exec.Command = Invoke-Expression $Task.Task.Actions.Exec.Command}
        if($Task.Task.Actions.Exec.Arguments.contains("$")){$Task.Task.Actions.Exec.Arguments = Invoke-Expression $Task.Task.Actions.Exec.Arguments}
        if($Task.Task.Actions.Exec.WorkingDirectory.contains("$")){$Task.Task.Actions.Exec.WorkingDirectory = [string](Invoke-Expression $Task.Task.Actions.Exec.WorkingDirectory)}
        $Task.Save($FilePathTemp)  
           
        $Title = $Task.task.RegistrationInfo.Description             

        if($WindowsScheduledTasks | where{$_.Description -eq $Title}){
               
            Write-Host "Update Windows scheduled task: $Title"            
            SCHTASKS /DELETE /TN $Title /F
            SCHTASKS /Create /TN $Title /XML $FilePathTemp
            
        }else{       
                  
            Write-Host "Adding Windows scheduled task: $Title"            
            SCHTASKS /Create /TN $Title /XML $FilePathTemp            
        } 
        
        Remove-Item -Path $FilePathTemp     
    }
}