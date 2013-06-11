function Connect-RDPSession{
    <#
	    .SYNOPSIS
		    Starts a remote desktop session

	    .DESCRIPTION
		    Starts a remote desktop session with the parameters from the Remote config file and a RDP file.

	    .PARAMETER  Names
		    Server names from the remote config file

	    .EXAMPLE
		    Connect-RDPSession -Names sharepoint
            Connect-RDPSession -Names sharepoint,dns

    #>

	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param (
        [parameter(Mandatory=$true)][string[]]
		$Names
	)

	$Metadata = @{
		Title = "Connect Remote Desktop Session"
		Filename = "Start-RDPSession.ps1"
		Description = ""
		Tags = "powershell, remote, session, rdp"
		Project = ""
		Author = "Janik von Rotz"
		AuthorContact = "www.janikvonrotz.ch"
		CreateDate = "2013-04-03"
		LastEditDate = "2013-04-18"
		Version = "2.0.0"
		License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
    
    if ((Get-Command "cmdkey.exe") -and (Get-Command "mstsc.exe")) 
    { 
		#--------------------------------------------------#
		# Settings
		#--------------------------------------------------#
		$RDPDefaultFile = Get-ChildItem -Path $PSconfigs.Path -Filter Default.rdp -Recurse
        [string]$RDPDefaultFile = $RDPDefaultFile.Fullname

        #--------------------------------------------------#
        # Main
        #--------------------------------------------------#

        # Load Configurations
		$Config = Get-RemoteConnections -Names $Names

        foreach($Server in $Config){
		        
            $Servername = $Server.Name
            $Username = $Server.User

            # Delete existing user credentials
            $Null = Invoke-Expression "cmdkey /delete:'$Servername'"

            # Add user credentials
            $Null = Invoke-Expression "cmdkey /generic:'$Servername' /user:'$Username'"


            # Open remote session
            Invoke-Expression "mstsc.exe '$RDPDefaultFile' /v:$Servername"
	    }
    }
}
