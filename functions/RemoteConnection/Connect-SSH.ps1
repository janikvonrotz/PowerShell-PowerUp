<#
$Metadata = @{
	Title = "Connect SSH Session"
	Filename = "Connect-SSH.ps1"
	Description = ""
	Tags = "powershell, remote, session, ssh"
	Project = ""
	Author = "Janik von Rotz"
    AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-05-17"
    LastEditDate = "2013-10-02"
	Version = "3.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Connect-SSH{

<#
.SYNOPSIS
    Remote management for ssh sessions.

.DESCRIPTION
    Starts a ssh session with the parameters from the remote config file.

.PARAMETER  Name
    Server names from the remote config file.

.EXAMPLE
    Connect-SSH -Name firewall
#>

	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param (
        [parameter(Mandatory=$true)]
        [string[]]$Name
	)


    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    if (Get-Command "putty"){ 
    
        # Load Configurations
    	$Config = grc -Name $Name

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