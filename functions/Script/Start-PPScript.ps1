<#
$Metadata = @{
	Title = "Start PowerShell PowerUp Script"
	Filename = "Start-PPScript.ps1"
	Description = ""
	Tags = ""
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2014-05-06"
	LastEditDate = "2014-05-06"
	Url = ""
	Version = "0.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Start-PPScript{

<#
.SYNOPSIS
    Run a PowerShell PowerUp script.

.DESCRIPTION
	Run a PowerShell PowerUp script which is stored in the script folder. Or run a script by it's shorcut name or key

.PARAMETER Name
	Name of the scripts or name of the script shortcut or shortcut key.

.PARAMETER Arguments
	Name of the scripts or name of the script shortcut or shortcut key.
	
.EXAMPLE
	PS C:\> Start-PPScript -Name Script1.ps1 -Arguments "-Start"

.EXAMPLE
	PS C:\> Start-PPScript -Name s1
#>

    [CmdletBinding()]
    param(

        [Parameter(Mandatory=$true)]
		[String]
		$Name,
		
		[Parameter(Mandatory=$false)]
		[String]
		$Arguments
	)
  
    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    
    $ScriptShortcut = Get-PPScript -Name $Name -Shortcut
    
    $(if( -not $ScriptShortcut){
    
        Get-PPScript -Name $Name | select -First 1
        
    }else{
    
        Get-PPScript -Name $ScriptShortcut.Filename
    
    }) | %{            

        iex "& `"$($_.Fullname)`" $(if($Arguments){$Arguments})"
    }
}