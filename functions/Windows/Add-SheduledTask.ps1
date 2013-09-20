<#
$Metadata = @{
	Title = "Add sheduled task"
	Filename = " Add-SheduledTask.ps1"
	Description = ""
	Tags = "powershell, function, task"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-05-14"
	LastEditDate = "2013-09-20"
	Version = "2.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Add-SheduledTask{

<#
.SYNOPSIS
	Creates an Windows sheduled task

.DESCRIPTION
	Depending on a default xml template this function creates a sheduled Windows task.

.PARAMETER  Command
	Path or name to an executable.

.PARAMETER  Arguments
	Aditional arguments for the command.

.PARAMETER  WorkingDirectory
	Execution directory for the command, default is home path.

.PARAMETER  XMLFilename
	Name of the the xml template file from the PowerShell Profile configs folder. If doesn't exist a default file is created.
	
.EXAMPLE
	PS C:\> Add-Task -Title "Windows Task 1" -Command "powershell.exe" -Arguments "C:\PowerShell-Profile\Git-Update.ps1" -WorkingDirectory "C:\PowerShell-Profile" -XMLFilename "Default.task.config"

.NOTES
	This function depends on the Windows tool "SchTasks.exe".

#>

	param(
		[Parameter(Mandatory=$true)]
		[String]
		$Title,
		
		[Parameter(Mandatory=$true)]
		[String]
		$Command,
		
		[Parameter(Mandatory=$true)]
		[String]
		$Arguments,
		
		[Parameter(Mandatory=$false)]
		[String]
		$WorkingDirectory = $Home,
		
		[Parameter(Mandatory=$true)]
		[String]
		$XMLFilename
	)
	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
    
    # check file extension
    if([System.IO.Path]::GetExtension($XMLFilename) -ne ".xml"){
        $XmlFilename = $XMLFilename + ".xml"
    }
	
    # check if configuration file exists        
    $TaskTemplate = $PStemplates.Task.FullName    
	$Taskconfig = Join-Path -Path $PSconfigs.Path -ChildPath $XmlFilename
    
    if(!(Get-ChildItem -Path $PSconfigs.Path -Filter $XmlFilename -Recurse)){
    
        Write-Host "Copy default task config file to the config folder"        
		Copy-Item -Path $TaskTemplate -Destination $Taskconfig
	}  
    		
	# Update task definitions
	[xml]$TaskDefinition = (get-content $Taskconfig)	
	$TaskDefinition.Task.Actions.Exec.Command = $Command
	$TaskDefinition.Task.Actions.Exec.Arguments = $Arguments	
	$TaskDefinition.Task.Actions.Exec.WorkingDirectory = $WorkingDirectory	
	$TaskDefinition.Save($Taskconfig)

	# Create task
	Write-Warning ("Adding Windows sheduled task: " + $Title)
	SchTasks /Create /TN $Title /XML $Taskconfig
}