function Add-SheduledTask{

<#
.SYNOPSIS
	Creates an Windows sheduled task

.DESCRIPTION
	Depending on a default xml template this function creates a sheduled Windows task.

.PARAMETER  Command
	Path or name to an executable.

.PARAMETER  Arguments
	Aditional arguments for the command

.PARAMETER  WorkingDirectory
	Execution directory for the command

.PARAMETER  XMLFilename
	Name of the the xml template file
	
.PARAMETER	NewXMLFile
	Add an xml template file
	
.EXAMPLE
	PS C:\> Add-Task -Title "Windows Task 1" -Command "powershell.exe" -Arguments "C:\PowerShell-Profile\Git-Update.ps1" -WorkingDirectory "C:\PowerShell-Profile" -XMLFilename "Default.task.config.xml" [-NewXMLFile]

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
		
		[Parameter(Mandatory=$true)]
		[String]
		$WorkingDirectory,
		
		[Parameter(Mandatory=$true)]
		[String]
		$XMLFilename,
		
		[switch]
		$NewXMLFile
	)

$Metadata = @{
	Title = "Add sheduled task"
	Filename = " Add-SheduledTask.ps1"
	Description = ""
	Tags = "powershell, function, task"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-05-14"
	LastEditDate = "2013-05-14"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
    
	if($NewXMLFile){
		$ContentTaskConfigXml = @'
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2013-03-20T14:18:21.6393172</Date>
    <Author>Janik von Rotz (www.janikvonrotz.ch)</Author>
  </RegistrationInfo>
  <Triggers>
    <CalendarTrigger>
      <StartBoundary>2013-01-01T03:00:00</StartBoundary>
      <Enabled>true</Enabled>
      <ScheduleByDay>
        <DaysInterval>1</DaysInterval>
      </ScheduleByDay>
    </CalendarTrigger>
  </Triggers>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>P3D</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command></Command>
      <Arguments></Arguments>
      <WorkingDirectory></WorkingDirectory>
    </Exec>
  </Actions>
</Task>
'@	
    	# Write content to config file
    	Set-Content -Value $ContentTaskConfigXml -Path ($PSconfigs.Path + "\" + $XMLFilename)
    	Write-Warning ("`nAdded " + $XMLFilename + " to " + $Psconfigs.Path)
    }

	# get path to the xml template
	$PathToXML = Get-ChildItem -Path $PSconfigs.Path -Filter $XMLFilename -Recurse
	if($PathToXML -eq $Null){
		throw ("`nCouldn't find the xml template file!`nPlease create (Get-Help Add-SheduledTask) or add a xml template file to this directory: " + $PSconfigs.Path )
	}

		
	# Update task definitions
	[xml]$TaskDefinition = (get-content $PathToXML.Fullname)
	
	$TaskDefinition.Task.Actions.Exec.Command = $Command
	$TaskDefinition.Task.Actions.Exec.Arguments = $Arguments
	$TaskDefinition.Task.Actions.Exec.WorkingDirectory = $WorkingDirectory
	
	$TaskDefinition.Save($PathToXML.Fullname)

	# Create task
	Write-Warning ("`nAdding Windows sheduled task: " + $Title)
	SchTasks /Create /TN $Title /XML $PathToXML.Fullname
}
