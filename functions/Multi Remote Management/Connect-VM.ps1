<#
$Metadata = @{
	Title = "Connect VM Session"
	Filename = "Connect-VM.ps1"
	Description = ""
	Tags = "powershell, remote, vm, connect"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-10-20"
    LastEditDate = "2013-10-02"
	Version = "3.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Connect-VM{

<#
.SYNOPSIS
    Connect vm Session.

.DESCRIPTION
    Connect vm Session. Requires VMware vSphere PowerCLI.

.PARAMETER  Name
    VMWare server names from the remote config file.

.EXAMPLEmi
    Connect-VM -Name vs1
#>

	param (
        [parameter(Mandatory=$true)]
        [string[]]$Name
	)
    
    #--------------------------------------------------#
    # modules
    #--------------------------------------------------#
    if((Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue) -eq $Null){Add-PSSnapin VMware.VimAutomation.Core}
    if((Get-PSSnapin VMware.VimAutomation.Vds -ErrorAction SilentlyContinue) -eq $Null){Add-PSSnapin VMware.VimAutomation.Vds}

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    
    # Load Configurations
	$Servers = Get-RemoteConnection -Name $Name

    $Servers | %{
		
		Open-VMConsoleWindow (Get-VM $_.Name)
        
    }
}