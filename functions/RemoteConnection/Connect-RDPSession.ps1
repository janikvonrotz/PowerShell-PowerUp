<#
$Metadata = @{
	Title = "Connect Remote Desktop Session"
	Filename = "Start-RDPSession.ps1"
	Description = ""
	Tags = "powershell, remote, session, rdp"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-04-03"
    LastEditDate = "2013-09-26"
	Version = "2.1.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Connect-RDPSession{

<#
.SYNOPSIS
    Starts a remote desktop session

.DESCRIPTION
    Starts a remote desktop session with the parameters from the Remote config file and a RDP file.

.PARAMETER  Name
    Server names from the remote config file.

.EXAMPLE
    Connect-RDPSession -Names sharepoint
    Connect-RDPSession -Names sharepoint, dns
#>

	param (
        [parameter(Mandatory=$true)]
        [string[]]$Name
	)
    
    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    if ((Get-Command "cmdkey") -and (Get-Command "mstsc")){ 
    
         # Load Configurations
		$RDPDefaultFile = $(Get-ChildItem -Path $PSconfigs.Path -Filter $PStemplates.RDP.Name -Recurse).Fullname       
		$Servers = Get-RemoteConnections -Name $Name

        foreach($Server in $Servers){
		        
            $Servername = $Server.Name
            $Username = $Server.User

            # Delete existing user credentials
            $Null = Invoke-Expression "cmdkey /delete:'$Servername'"

            # Add user credentials
            $Null = Invoke-Expression "cmdkey /generic:'$Servername' /user:'$Username'"

            # Open remote session
            Invoke-Expression "mstsc '$RDPDefaultFile' /v:$Servername"
	    }
    }
}
