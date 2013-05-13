function Connect-SCPSession{
    <#
	    .SYNOPSIS
		    Remote management for scp sessions

	    .DESCRIPTION
		    Starts a scp session with the parameters from the remote config file.

	    .PARAMETER  Names
		    Server names from the remote config file

	    .EXAMPLE
		   Connect-SCPSession -Names firewall

    #>

	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param (
        [parameter(Mandatory=$true)][string[]]
		$Names
	)

	$Metadata = @{
		Title = "Connect SCP Session"
		Filename = "Connect-SCPSession.ps1"
		Description = ""
		Tags = "powershell, remote, session, scp"
		Project = ""
		Author = "Janik von Rotz"
		AuthorContact = "www.janikvonrotz.ch"
		CreateDate = "2013-05-13"
		LastEditDate = "2013-05-13"
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
   if (Get-Command "winscp.exe"){ 

        # Load Configurations
    	$Config = Get-RemoteConnections -Names $Names

        $Config | %{
    		
            # default settings
            $SCPPort = 22
            $Servername = $_.Server
            $Username = $_.User
            $PrivatKey = Invoke-Expression ($Command = '"' + $_.PrivatKey + '"')
            
    		#Get port
    		$_.Protocols | %{if ($_.Name -eq "scp" -and $_.Port -ne ""){$SCPPort = $_.Port}}
            
    		#Set Protocol
            if($PrivatKey -eq ""){
                Invoke-Expression ("WinSCP.exe scp://$Username@$Servername" + ":$SCPPort")
            }else{
                Invoke-Expression ("WinSCP.exe scp://$Username@$Servername :$SCPPort" + ":$SCPPort /privatekey='$PrivatKey'" )
            }
        }
    }
}