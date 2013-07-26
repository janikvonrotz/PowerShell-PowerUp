function Connect-SSHSession{
    <#
	    .SYNOPSIS
		    Remote management for ssh sessions

	    .DESCRIPTION
		    Starts a ssh session with the parameters from the remote config file.

	    .PARAMETER  Names
		    Server names from the remote config file

	    .EXAMPLE
		   Connect-SSHSession -Names firewall

    #>

	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param (
        [parameter(Mandatory=$true)][string[]]
		$Names
	)

	$Metadata = @{
		Title = "Connect SSH Session"
		Filename = "Connect-SSHSession.ps1"
		Description = ""
		Tags = "powershell, remote, session, ssh"
		Project = ""
		Author = "Janik von Rotz"
		AuthorContact = "www.janikvonrotz.ch"
		CreateDate = "2013-05-13"
		LastEditDate = "2013-07-26"
		Version = "1.0.1"
		License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}


    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    if (Get-Command "putty.exe"){ 
    
        # Load Configurations
    	$Config = Get-RemoteConnections -Names $Names

        $Config | %{
    		
            # default settings
            $SSHPort = 22
            $Servername = $_.Name
            $Username = $_.User
            $PrivatKey = Invoke-Expression ($Command = '"' + $_.PrivatKey + '"')
            
    		#Get port
    		$_.Protocols | %{if ($_.Name -eq "ssh" -and $_.Port -ne ""){$SSHPort = $_.Port}}
            
    		#Set Protocol
            if($PrivatKey -eq ""){
                Invoke-Expression "putty $Username@$Servername -P $SSHPort -ssh" 
            }else{
                Invoke-Expression "putty $Username@$Servername -P $SSHPort -ssh -i '$PrivatKey'" 
            }
        }
    }
}