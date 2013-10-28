<#
$Metadata = @{
  Title = "Get Path"
	Filename = "Get-Path.ps1"
	Description = ""
	Tags = "powershell, function, Path"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-10-28"
	LastEditDate = "2013-10-28"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Get-Path {

<#
.SYNOPSIS
    Solves environment variabels, PowerShell variabels in static and relative path strings.

.DESCRIPTION
	This function returns a normalized path string of static or relative path which contains environment variabels or PowerShell variabels.

.PARAMETER  Path
	Path to resolve.

.EXAMPLE
	PS C:\> Get-Path "%ProgramFiles(x86)%\Git\bin"
    PS C:\> Get-Path "\apps"
    PS C:\> Get-Path "$Home"
#>

	param(
		[Parameter(Mandatory=$true)]
        [string]
		$Path
	)
    	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
    
    # evirontment variables
    $Path = [System.Environment]::ExpandEnvironmentVariables($Path)
    
    # powershell variables
    if($Path.contains("$")){$Path = Invoke-Expression $($_.Value)}
    
    # relative paths
    if($Path.StartsWith("\")){$Path = Join-Path -Path $(Get-Location).Path -Childpath $Path}
    
    # return path
    $Path
}